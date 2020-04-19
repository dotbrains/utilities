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

    declare -r FILE_PATH="$1"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install formulae.

    if [[ -e "$FILE_PATH" ]]; then

        brew bundle install -v --file="$FILE_PATH"

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
