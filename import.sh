#!/bin/bash

# shellcheck source=/dev/null

# import.sh - the library entry point for the smeltery utilities.
#
# Consumers source this file once and then import only the modules they
# need, similar to selective imports in other languages:
#
#   source "$HOME/set-me-up/dotfiles/utilities/import.sh"
#   smu::import base
#   smu::import homebrew
#
# Sourcing this file has no side effects beyond defining the smu::*
# functions and the UTILITIES_* configuration variables. Module files are
# only loaded when explicitly imported. Every import is idempotent: a
# module that has already been loaded is never sourced twice.
#
# Module resolution order (per file):
#   1. Local checkout (scripts/ next to this file)
#   2. Cache directory (UTILITIES_CACHE_DIR, when set)
#   3. Remote fetch pinned to UTILITIES_REF, falling back to master
#
# Configuration:
#   UTILITIES_DEBUG      "true" to log module loading to stderr
#   UTILITIES_CACHE_DIR  directory used to cache remote downloads
#   UTILITIES_REF        git ref for remote fetches (default: v<version>)
#   SMU_UTILITIES        consumers may use this to locate this file

# Guard against being sourced more than once.
if [[ -n "${SMU_IMPORT_LOADED:-}" ]]; then
    return 0
fi
SMU_IMPORT_LOADED="true"

# Version
export UTILITIES_VERSION="1.3.0"

# Configuration
UTILITIES_DEBUG="${UTILITIES_DEBUG:-false}"
UTILITIES_CACHE_DIR="${UTILITIES_CACHE_DIR:-}"
UTILITIES_REF="${UTILITIES_REF:-v$UTILITIES_VERSION}"
UTILITIES_REMOTE="${UTILITIES_REMOTE:-https://raw.githubusercontent.com/smeltery/utilities}"

# Registry of modules that have already been imported.
# A space-delimited string keeps this compatible with bash 3.2 (macOS),
# which has no associative arrays.
SMU_IMPORTED=" "

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

smu::debug() {

    if [[ "$UTILITIES_DEBUG" == "true" ]]; then
        echo "[utilities] $1" >&2
    fi

    return 0

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

smu::error() {

    echo "[utilities] ERROR: $1" >&2

    return 0

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Directory containing this file, used to resolve the local scripts/ tree.
# When import.sh is sourced from a pipe (e.g. curl | bash) there is no
# meaningful directory and resolution falls through to cache/remote.

smu::utilities_dir() {

    local dir=""

    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || return 1

    echo "$dir"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

smu::fetch() {

    local url="$1"

    curl -f -s -S --connect-timeout 10 --max-time 30 "$url" 2>/dev/null

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Fetch a file relative to scripts/ from the pinned ref, falling back to
# master so that new refs remain usable before their release tag exists.

smu::fetch_module() {

    local file="$1"
    local content=""

    content="$(smu::fetch "$UTILITIES_REMOTE/$UTILITIES_REF/scripts/$file")"

    if [[ -z "$content" && "$UTILITIES_REF" != "master" ]]; then
        smu::debug "Ref '$UTILITIES_REF' unavailable for $file, falling back to master"
        content="$(smu::fetch "$UTILITIES_REMOTE/master/scripts/$file")"
    fi

    if [[ -z "$content" ]]; then
        return 1
    fi

    echo "$content"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Load a single file (path relative to scripts/) into the current shell.
# Resolution order: local checkout, cache, remote (pinned ref -> master).

smu::load_file() {

    local file="$1"
    local utilities_dir=""
    local local_file=""
    local cache_file=""
    local content=""

    smu::debug "Loading: $file"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Local checkout

    utilities_dir="$(smu::utilities_dir)"
    local_file="$utilities_dir/scripts/$file"

    if [[ -n "$utilities_dir" && -f "$local_file" && -s "$local_file" ]]; then
        smu::debug "Using local: $local_file"
        source "$local_file"
        return $?
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Cache

    if [[ -n "$UTILITIES_CACHE_DIR" ]]; then
        cache_file="$UTILITIES_CACHE_DIR/$file"

        if [[ ! -d "$(dirname "$cache_file")" ]]; then
            mkdir -p "$(dirname "$cache_file")" 2>/dev/null || {
                smu::error "Failed to create cache directory"
                return 1
            }
        fi

        if [[ -f "$cache_file" && -s "$cache_file" ]]; then
            smu::debug "Using cached: $cache_file"
            source "$cache_file"
            return $?
        fi

        if content="$(smu::fetch_module "$file")" && [[ -n "$content" ]]; then
            printf '%s\n' "$content" >"$cache_file"
            source "$cache_file"
            return $?
        fi

        rm -f "$cache_file" 2>/dev/null
        smu::error "Failed to fetch: $file"
        return 1
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Remote (no cache)

    if content="$(smu::fetch_module "$file")" && [[ -n "$content" ]]; then
        source /dev/stdin <<<"$content"
        return $?
    fi

    smu::error "Failed to fetch: $file"
    return 1

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Map a module name to one or more files relative to scripts/.
# Unknown names are treated as paths relative to scripts/ or
# scripts/modules/ (with or without the .sh extension).

smu::resolve() {

    local name="$1"

    case "$name" in
        base)
            echo "base/base.sh"
            ;;
        system)
            # Core system helpers plus the platform-specific layer,
            # mirroring the platform detection previously performed by
            # utilities.sh.
            local files="modules/system/system.sh modules/system/network.sh"

            if [[ "$(uname -s)" == "Linux" ]]; then
                if grep -qEi 'debian|buntu|kali' /etc/*release 2>/dev/null; then
                    files="$files modules/system/debian/system.sh modules/system/debian/apt.sh"
                elif grep -qEi 'arch' /etc/*release 2>/dev/null; then
                    files="$files modules/system/arch/system.sh modules/system/arch/pacman.sh"
                fi
            elif [[ "$(uname -s)" == "Darwin" ]]; then
                files="$files modules/system/darwin/system.sh"
            fi

            echo "$files"
            ;;
        network)
            echo "modules/system/network.sh"
            ;;
        debian)
            echo "modules/system/debian/system.sh modules/system/debian/apt.sh"
            ;;
        apt)
            echo "modules/system/debian/apt.sh"
            ;;
        arch)
            echo "modules/system/arch/system.sh modules/system/arch/pacman.sh"
            ;;
        pacman)
            echo "modules/system/arch/pacman.sh"
            ;;
        darwin)
            echo "modules/system/darwin/system.sh"
            ;;
        homebrew | brew)
            echo "modules/homebrew/brew.sh"
            ;;
        macports)
            echo "modules/macports/macports.sh"
            ;;
        git)
            echo "modules/git/git.sh"
            ;;
        fish)
            echo "modules/fish/fish.sh modules/fish/omf.sh modules/fish/fisher.sh"
            ;;
        omf)
            echo "modules/fish/omf.sh"
            ;;
        fisher)
            echo "modules/fish/fisher.sh"
            ;;
        java | sdkman)
            echo "modules/java/sdkman.sh"
            ;;
        go)
            echo "modules/go/go.sh"
            ;;
        gofish)
            echo "modules/gofish/gofish.sh"
            ;;
        rust | cargo)
            echo "modules/rust/cargo.sh"
            ;;
        python)
            echo "modules/python/pip.sh modules/python/pip3.sh modules/python/pyenv.sh"
            ;;
        pip)
            echo "modules/python/pip.sh"
            ;;
        pip3)
            echo "modules/python/pip3.sh"
            ;;
        pyenv)
            echo "modules/python/pyenv.sh"
            ;;
        node | npm)
            echo "modules/node/npm.sh"
            ;;
        ruby | gem)
            echo "modules/ruby/gem.sh"
            ;;
        *)
            # Path-style name: normalize to a file relative to scripts/.
            local path="${name#scripts/}"
            path="${path%.sh}.sh"

            local utilities_dir=""
            utilities_dir="$(smu::utilities_dir)"

            if [[ -n "$utilities_dir" && -f "$utilities_dir/scripts/$path" ]]; then
                echo "$path"
            elif [[ -n "$utilities_dir" && -f "$utilities_dir/scripts/modules/$path" ]]; then
                echo "modules/$path"
            elif [[ "$path" == modules/* || "$path" == base/* ]]; then
                echo "$path"
            else
                echo "modules/$path"
            fi
            ;;
    esac

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Import one or more modules by name. Already-loaded files are skipped,
# so diamond dependencies between modules are safe.

smu::import() {

    local name=""
    local file=""
    local files=""
    local status=0

    if [[ $# -eq 0 ]]; then
        smu::error "smu::import requires at least one module name"
        return 1
    fi

    for name in "$@"; do
        files="$(smu::resolve "$name")"

        for file in $files; do
            if [[ "$SMU_IMPORTED" == *" $file "* ]]; then
                smu::debug "Already imported: $file"
                continue
            fi

            SMU_IMPORTED="$SMU_IMPORTED$file "

            if ! smu::load_file "$file"; then
                # Allow the module to be retried after a failed import.
                SMU_IMPORTED="${SMU_IMPORTED/ $file / }"
                smu::error "Failed to import: $name ($file)"
                status=1
            fi
        done
    done

    return $status

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Legacy API kept for backwards compatibility with existing consumers of
# utilities.sh. Sources a file (relative to scripts/) unconditionally.

source_file_from_utilities() {

    smu::load_file "$1"

}
