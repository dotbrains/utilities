#!/bin/bash

# shellcheck source=/dev/null
# shellcheck disable=SC2317

# utilities.sh - legacy compatibility facade.
#
# Historically consumers sourced this file to load the entire utilities
# library in one go. The library is now import-based: import.sh defines
# smu::import and modules are loaded selectively. New consumers should
# source import.sh directly and import only what they need:
#
#   source "$HOME/set-me-up/dotfiles/utilities/import.sh"
#   smu::import base
#   smu::import homebrew
#
# This facade preserves the historical behavior: sourcing it loads the
# base and system modules plus every module group allowed by
# UTILITIES_MODULES (default: all).
#
# Configuration (in addition to the variables honored by import.sh):
#   UTILITIES_MODULES    comma-separated module groups to load, or "all"

UTILITIES_MODULES="${UTILITIES_MODULES:-all}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Bootstrap import.sh: local checkout first, then cache, then remote.

if [[ -z "${SMU_IMPORT_LOADED:-}" ]]; then

    smu_bootstrap_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
    smu_bootstrap_remote="${UTILITIES_REMOTE:-https://raw.githubusercontent.com/dotbrains/utilities}"
    smu_bootstrap_ref="${UTILITIES_REF:-master}"
    smu_bootstrap_url="$smu_bootstrap_remote/$smu_bootstrap_ref/import.sh"

    if [[ -n "$smu_bootstrap_dir" && -f "$smu_bootstrap_dir/import.sh" && -s "$smu_bootstrap_dir/import.sh" ]]; then
        source "$smu_bootstrap_dir/import.sh"
    elif [[ -n "${UTILITIES_CACHE_DIR:-}" && -f "$UTILITIES_CACHE_DIR/import.sh" && -s "$UTILITIES_CACHE_DIR/import.sh" ]]; then
        source "$UTILITIES_CACHE_DIR/import.sh"
    elif [[ -n "${UTILITIES_CACHE_DIR:-}" ]]; then
        mkdir -p "$UTILITIES_CACHE_DIR" 2>/dev/null
        if curl -f -s -S --connect-timeout 10 --max-time 30 "$smu_bootstrap_url" -o "$UTILITIES_CACHE_DIR/import.sh" 2>/dev/null &&
            [[ -s "$UTILITIES_CACHE_DIR/import.sh" ]]; then
            source "$UTILITIES_CACHE_DIR/import.sh"
        else
            rm -f "$UTILITIES_CACHE_DIR/import.sh" 2>/dev/null
            echo "[utilities] ERROR: Failed to bootstrap import.sh from $smu_bootstrap_url" >&2
            return 1 2>/dev/null || exit 1
        fi
    else
        smu_bootstrap_content="$(curl -f -s -S --connect-timeout 10 --max-time 30 "$smu_bootstrap_url" 2>/dev/null)"

        if [[ -n "$smu_bootstrap_content" ]]; then
            source /dev/stdin <<<"$smu_bootstrap_content"
        else
            echo "[utilities] ERROR: Failed to bootstrap import.sh from $smu_bootstrap_url" >&2
            return 1 2>/dev/null || exit 1
        fi

        unset smu_bootstrap_content
    fi

    unset smu_bootstrap_dir smu_bootstrap_remote smu_bootstrap_ref smu_bootstrap_url

fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Helper function to check if a module group should be loaded

should_load_module() {

    local module="$1"

    # Load all modules if UTILITIES_MODULES is "all"
    if [[ "$UTILITIES_MODULES" == "all" ]]; then
        return 0
    fi

    # Check if module is in the comma-separated list
    if [[ ",$UTILITIES_MODULES," == *",$module,"* ]]; then
        return 0
    fi

    return 1

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Base and system helpers are always loaded. The system group includes
# the platform-specific layer (debian/arch/darwin) for the current OS.

smu::import base
smu::import system

# MacPorts (Only required for 'darwin'-based systems)
if [[ "$(uname -s)" == "Darwin" ]]; then
    smu::import macports
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Optional module groups, filtered by UTILITIES_MODULES.

for smu_module_group in homebrew gofish git fish java go rust python node ruby; do
    if should_load_module "$smu_module_group"; then
        smu::import "$smu_module_group"
    fi
done

unset smu_module_group
