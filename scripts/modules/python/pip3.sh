#!/bin/bash

# shellcheck source=/dev/null

if [ "$(uname -a)" == "Linux" ] && grep -qEi 'debian|buntu|kali' /etc/*release; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/debian/base.sh")"
elif [ "$(uname -a)" == "Darwin" ]; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/darwin/base.sh")"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pip3 functions

is_pip3_installed() {

    if ! cmd_exists "pip3"; then
        print_error "(pip3) is not installed."
        return 1
    fi

}

is_pip3_pkg_installed() {

    pip3 list | grep "$1" > /dev/null 2>&1

}

pip3_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `pip3` is installed.

    is_pip3_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pip3_pkg_installed "$PACKAGE"; then
        execute \
            "sudo pip3 install --quiet $PACKAGE" \
            "$PACKAGE"
    else
        print_success "($PACKAGE) is already installed."
    fi

}

pip3_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            pip3_install "$PACKAGE"
        done

    fi

}
