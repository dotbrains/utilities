#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# npm functions

is_npm_installed() {

    if ! cmd_exists "npm"; then
        return 1
    fi

}

is_npx_installed() {

    if ! cmd_exists "npx"; then
        return 1
    fi

}

is_npm_pkg_installed() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    . "$LOCAL_BASH_CONFIG_FILE" \
        && npm list --depth 1 --global "$1" > /dev/null 2>&1

}

is_yarn_pkg_installed() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    . "$LOCAL_BASH_CONFIG_FILE" \
        && npx yarn global list --depth=0 | grep "$1" > /dev/null 2>&1

}


npm_install() {

    declare -r PACKAGE="$1"

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `npm` is installed.

    is_npm_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `npx` is installed.

    is_npm_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified package.

    if ! is_npm_pkg_installed "$PACKAGE"; then
        . "$LOCAL_BASH_CONFIG_FILE" \
                && npm install --global "$PACKAGE"
    fi

}

npx_install() {

    declare -r PACKAGE="$1"

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `npx` is installed.

    is_npx_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified package.

    if ! is_yarn_pkg_installed "$PACKAGE"; then
        . "$LOCAL_BASH_CONFIG_FILE" \
                && npx yarn global add "$PACKAGE" --prefix /usr/local
    fi

}

npm_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [[ -e "$FILE_PATH" ]]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            npm_install "$PACKAGE"
        done

    fi

}
