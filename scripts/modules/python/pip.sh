#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pip functions

is_pip_installed() {

    if ! cmd_exists "pip"; then
        return 1
    fi

}

is_pip_pkg_installed() {

    pip list | grep "$1" > /dev/null 2>&1

}

pip_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `pip` is installed.

    is_pip_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pip_pkg_installed "$PACKAGE"; then
        python -m pip install --quiet "$PACKAGE"
    fi

}

pip_install_from_file() {

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
