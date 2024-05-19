#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# brew functions

is_brew_installed() {

    if ! cmd_exists "brew"; then
        return 1
    fi

}

brew_cleanup() {

    # By default brew does not uninstall older versions
    # of formulas so, in order to remove them, `brew cleanup`
    # needs to be used.
    #
    # https://github.com/Homebrew/brew/blob/496fff643f352b0943095e2b96dbc5e0f565db61/share/doc/homebrew/FAQ.md#how-do-i-uninstall-old-versions-of-a-formula

    brew cleanup

}

use_python3=false  # Set a default value for use_python3

show_help() {

    echo "Usage: $0 [-f file_path] [-p]"
    echo "  -f, --file    Path to the Brewfile"
    echo "  -p, --python3 Use python3 instead of default brew command"
    echo "  -h, --help    Display this help message"
}

reset_args() {

	file_path=""
	use_python3=false

    unset file_path
    unset use_python3

}

parse_args() {

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--file)
                if [[ -n "$2" ]]; then
                    file_path="$2"

                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    show_help
                    exit 1
                fi
                ;;
            -p|--python3)
                use_python3=true
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$file_path" ]]; then
        echo "Error: file path is required." >&2
        show_help
        exit 1
    fi

}

brew_bundle_install() {

	# Get current directory path relative to this script
	local script_dir=""
	script_dir="$(dirname "${BASH_SOURCE[0]}")"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Parse arguments
    parse_args "$@"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `brew` is installed.
    if ! command -v brew &>/dev/null; then
        echo "'brew' is not installed."
		reset_args
        return 1
    fi

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
                echo "Python3 script executed successfully."
				reset_args
                return 0
            else
                echo "Python3 script execution failed."
				reset_args
                return 1
            fi
        else
            echo "Running 'brew bundle install' with $file_path"
            if brew bundle install -v --file="$file_path"; then
                echo "Brewfile installation succeeded."
				reset_args
                return 0
            else
                echo "Brewfile installation failed."
				reset_args
                return 1
            fi
        fi
    else
        echo "The Brewfile does not exist at the specified path: '$file_path'"
		reset_args
        return 1
    fi

}

brew_install() {

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

    if ! brew "$CMD" list | grep "$FORMULA" &> /dev/null; then
		brew "$CMD" install "$FORMULA"
    fi

}

brew_prefix() {

    local path=""

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if path="$(brew --prefix 2> /dev/null)"; then
        printf "%s" "$path"
        return 0
    else
		return 1
    fi

}

brew_tap() {

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    brew tap "$1" &> /dev/null

}

brew_update() {

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    brew update

}

brew_upgrade() {

    brew upgrade

}

brew_upgrade_formulae() {

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	brew  upgrade "$2"

}
