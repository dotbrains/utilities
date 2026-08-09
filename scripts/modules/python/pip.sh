#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pip functions

pip::is_pip_installed() {

    if ! cmd_exists "pip"; then
        return 1
    fi

}

pip::is_pip_pkg_installed() {

    pip list | grep "$1" > /dev/null 2>&1

}

pip::pip_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `pip` is installed.

    is_pip_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pip_pkg_installed "$PACKAGE"; then
        python -m pip install --quiet "$PACKAGE"
    fi

}

pip::pip_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [[ -e "$FILE_PATH" ]]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            pip_install "$PACKAGE"
        done

    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_pip_installed() { pip::is_pip_installed "$@"; }
is_pip_pkg_installed() { pip::is_pip_pkg_installed "$@"; }
pip_install() { pip::pip_install "$@"; }
pip_install_from_file() { pip::pip_install_from_file "$@"; }
