#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# brew functions

brew::get_brew_default_path() {

    local path=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # MacOS Homebrew default path
    if [[ -d "/opt/homebrew" ]]; then
        path="/opt/homebrew"
    elif [[ -d "/usr/local" ]]; then
        path="/usr/local"
    fi

    # Linux Homebrew default path
    if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
        path="/home/linuxbrew/.linuxbrew"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    printf "%s" "$path"

}

brew::initialize_brew() {

    # Manually initialize Homebrew if it is not already initialized

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Determine the OS
    OS=$(uname)

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # MacOS Homebrew initialization
    if [ "$OS" = "Darwin" ]; then
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            add_to_path_if_not_exists "/opt/homebrew/bin"
        elif [ -f /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)"
            add_to_path_if_not_exists "/usr/local/bin"
        fi
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Linux Homebrew initialization
    if [ "$OS" = "Linux" ] && [ -d /home/linuxbrew/.linuxbrew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        add_to_path_if_not_exists "/home/linuxbrew/.linuxbrew/bin"
    fi

}

brew::is_brew_installed() {

    # Attempt to initialize brew in the current shell context
    # If brew truly is not installed, preceding existence check will fail
    initialize_brew

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! cmd_exists "brew"; then
        local brew_path="$(get_brew_default_path)"

        if [[ -n "$brew_path" ]]; then
            return 1
        fi
    fi

}

brew::brew_cleanup() {

    # By default brew does not uninstall older versions
    # of formulas so, in order to remove them, `brew cleanup`
    # needs to be used.
    #
    # https://github.com/Homebrew/brew/blob/496fff643f352b0943095e2b96dbc5e0f565db61/share/doc/homebrew/FAQ.md#how-do-i-uninstall-old-versions-of-a-formula

    brew cleanup

}

use_python3=false # Set a default value for use_python3

brew::show_help() {

    echo "Usage: $0 [-f file_path] [-p]"
    echo "  -f, --file    Path to the Brewfile"
    echo "  -p, --python3 Use python3 instead of default brew command"
    echo "  -h, --help    Display this help message"
}

brew::reset_args() {

    file_path=""
    use_python3=false

    unset file_path
    unset use_python3

}

brew::parse_args() {

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
        -h | --help)
            show_help
            exit 0
            ;;
        -f | --file)
            if [[ -n "$2" ]]; then
                file_path="$2"

                shift 2
            else
                error "Error: Argument for $1 is missing" >&2
                show_help
                exit 1
            fi
            ;;
        -p | --python3)
            use_python3=true
            shift
            ;;
        *)
            error "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$file_path" ]]; then
        error "Error: file path is required." >&2
        show_help
        exit 1
    fi

}

brew::brew_bundle_install() {

    # Get current directory path relative to this script
    local script_dir=""
    script_dir="$(dirname "${BASH_SOURCE[0]}")"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Parse arguments
    parse_args "$@"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if 'brew' is installed
    if ! is_brew_installed; then
        warn "'brew' is not installed."
        reset_args
        return 1
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install formulae.
    if [[ -e "$file_path" ]]; then
        if $use_python3; then
            # Make sure python3 is installed
            if ! command -v python3 &>/dev/null; then
                brew install python3
            fi

            echo "Running python3 brew.py with $file_path"
            local python_script_path="$script_dir/brew.py"
            if python3 "$python_script_path" -f "$file_path"; then
                success "Python3 script executed successfully."
                reset_args
                return 0
            else
                error "Python3 script execution failed."
                reset_args
                return 1
            fi
        else
            echo "Running 'brew bundle install' with $file_path"
            if brew bundle install -v --file="$file_path"; then
                success "Brewfile installation succeeded."
                reset_args
                return 0
            else
                error "Brewfile installation failed."
                reset_args
                return 1
            fi
        fi
    else
        error "The Brewfile does not exist at the specified path: '$file_path'"
        reset_args
        return 1
    fi

}

brew::brew_install() {

    declare -r CMD="$3"
    declare -r FORMULA="$1"
    declare -r TAP_VALUE="$2"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # If `brew tap` needs to be executed,
    # check if it executed correctly.

    if [[ -n "$TAP_VALUE" ]]; then
        if ! brew_tap "$TAP_VALUE"; then
            return 1
        fi
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified formula.

    if ! brew "$CMD" list | grep "$FORMULA" &>/dev/null; then
        brew "$CMD" install "$FORMULA"
    fi

}

brew::brew_prefix() {

    local path=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if path="$(brew --prefix 2>/dev/null)"; then
        printf "%s" "$path"
        return 0
    else
        return 1
    fi

}

brew::brew_tap() {

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    brew tap "$1" &>/dev/null

}

brew::brew_update() {

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    brew update

}

brew::brew_upgrade() {

    brew upgrade

}

brew::brew_upgrade_formulae() {

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    brew upgrade "$2"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

get_brew_default_path() { brew::get_brew_default_path "$@"; }
initialize_brew() { brew::initialize_brew "$@"; }
is_brew_installed() { brew::is_brew_installed "$@"; }
brew_cleanup() { brew::brew_cleanup "$@"; }
show_help() { brew::show_help "$@"; }
reset_args() { brew::reset_args "$@"; }
parse_args() { brew::parse_args "$@"; }
brew_bundle_install() { brew::brew_bundle_install "$@"; }
brew_install() { brew::brew_install "$@"; }
brew_prefix() { brew::brew_prefix "$@"; }
brew_tap() { brew::brew_tap "$@"; }
brew_update() { brew::brew_update "$@"; }
brew_upgrade() { brew::brew_upgrade "$@"; }
brew_upgrade_formulae() { brew::brew_upgrade_formulae "$@"; }
