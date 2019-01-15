#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/utilities.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# brew functions

is_brew_installed() {

    if ! cmd_exists "brew"; then
        print_error "(brew) is not installed."
        return 1
    fi

}

brew_cleanup() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # By default brew does not uninstall older versions
    # of formulas so, in order to remove them, `brew cleanup`
    # needs to be used.
    #
    # https://github.com/Homebrew/brew/blob/496fff643f352b0943095e2b96dbc5e0f565db61/share/doc/homebrew/FAQ.md#how-do-i-uninstall-old-versions-of-a-formula

    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew cleanup" \
        "brew (cleanup)"

}


brew_bundle_install() {

    declare -r FILE_PATH="$1"

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install formulae.

    if [ -e "$FILE_PATH" ]; then

        execute \
            ". $LOCAL_BASH_CONFIG_FILE \
                && brew bundle install -v --file=\"$FILE_PATH\"" \
            "brew (bundle install $FILE_PATH)"

    fi
}

brew_install() {

    declare -r CMD="$3"
    declare -r FORMULA="$1"
    declare -r TAP_VALUE="$2"

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # If `brew tap` needs to be executed,
    # check if it executed correctly.

    if [ -n "$TAP_VALUE" ]; then
        if ! brew_tap "$TAP_VALUE"; then
            print_error "$FORMULA_READABLE_NAME ('brew tap $TAP_VALUE' failed)"
            return 1
        fi
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified formula.

    if brew "$CMD" list | grep "$FORMULA" &> /dev/null; then
        print_success "($FORMULA) is already installed"
    else
        execute \
            ". $LOCAL_BASH_CONFIG_FILE \
                && brew $CMD install $FORMULA" \
            "$FORMULA"
    fi

}

brew_prefix() {

    local path=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if path="$(brew --prefix 2> /dev/null)"; then
        printf "%s" "$path"
        return 0
    else
        print_error "brew (get prefix)"
        return 1
    fi

}

brew_tap() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    . "$LOCAL_BASH_CONFIG_FILE" \
        && brew tap "$1" &> /dev/null

}

brew_update() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew update" \
        "brew (update)"

}

brew_upgrade() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew upgrade" \
        "brew (upgrade)"

}

brew_upgrade_formulae() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew  upgrade $2" \
        "brew (upgrade $1)"

}
