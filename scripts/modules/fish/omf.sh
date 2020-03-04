#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# omf functions

is_omf_installed() {

    if ! fish_cmd_exists "omf" && [[ ! -d "$HOME/.local/share/omf" ]]; then
        return 1
    fi

}

is_omf_pkg_installed() {

    fish -c "omf list | grep $1" &> /dev/null

}

omf_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `omf` is installed.

    is_omf_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified package.

    if ! is_omf_pkg_installed "$PACKAGE"; then
        fish -c "omf install $PACKAGE"
    fi

}

omf_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [[ -e "$FILE_PATH" ]]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            omf_install "$PACKAGE"
        done

    fi

}

omf_update() {

    # Check if `omf` is installed.

    is_omf_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update package(s)

    fish -c "omf update"

}
