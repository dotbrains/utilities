#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

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


brew_bundle_install() {

    local file_path=""
    local use_python3=false

    # Parse command-line options.
    local options
	options=$(getopt -o f:p --long file:,python3 -n 'brew_bundle_install' -- "$@") || {
		echo "Failed parsing options." >&2
		return 1
	}

    # Note the quotes around `$options`: they are essential!
    eval set -- "$options"

    while true; do
        case "$1" in
        -f|--file)
            file_path="$2"
            shift 2
            ;;
        -p|--python3)
            use_python3=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option: $1"
            return 1
            ;;
        esac
    done

    # Check if `brew` is installed.
    is_brew_installed || return 1

    # Install formulae.
    if [[ -e "$file_path" ]]; then
        if $use_python3; then
            # Make sure python3 is installed
            if ! command -v python3 &> /dev/null; then
                brew install python3
            fi

            if python3 brew.py -f "$file_path"; then
                return 0
            else
                return 1
            fi
        fi

        if brew bundle install -v --file="$file_path"; then
            return 0
        else
            return 1
        fi
    else
        print_error "File does not exist: $file_path"
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
