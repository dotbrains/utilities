#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# npm functions

npm::is_npm_installed() {

    if ! cmd_exists "npm"; then
        return 1
    fi

}

npm::is_npx_installed() {

    if ! cmd_exists "npx"; then
        return 1
    fi

}

npm::is_npm_pkg_installed() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    . "$LOCAL_BASH_CONFIG_FILE" \
        && npm list --depth 1 --global "$1" > /dev/null 2>&1

}

npm::is_yarn_pkg_installed() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    . "$LOCAL_BASH_CONFIG_FILE" \
        && npx yarn global list --depth=0 | grep "$1" > /dev/null 2>&1

}

npm::sudo_npm_install() {

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
                && sudo npm install --global "$PACKAGE"
    fi

}


npm::npm_install() {

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

npm::npx_install() {

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

npm::npm_install_from_file() {

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_npm_installed() { npm::is_npm_installed "$@"; }
is_npx_installed() { npm::is_npx_installed "$@"; }
is_npm_pkg_installed() { npm::is_npm_pkg_installed "$@"; }
is_yarn_pkg_installed() { npm::is_yarn_pkg_installed "$@"; }
sudo_npm_install() { npm::sudo_npm_install "$@"; }
npm_install() { npm::npm_install "$@"; }
npx_install() { npm::npx_install "$@"; }
npm_install_from_file() { npm::npm_install_from_file "$@"; }
