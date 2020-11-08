#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fisher functions

does_fish_plugins_exist() {

    [[ -f fish_plugins ]] || [[ -f "$HOME"/.config/fish/fish_plugins ]]

}

is_fisher_installed() {

    fish_cmd_exists "fisher" && does_fish_plugins_exist

}

is_fisher_pkg_installed() {

    does_fish_plugins_exist && fish -c "fisher list | grep $1" &> /dev/null

}

fisher_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `fisher` is installed.

    is_fisher_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified package.

    if ! is_fisher_pkg_installed "$PACKAGE"; then
        fish -c "fisher install $PACKAGE"
    fi

}

fisher_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [[ -e "$FILE_PATH" ]]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            fisher_install "$PACKAGE"
        done

    fi
}

fisher_update() {

    # Check if `fisher` is installed.

    is_fisher_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update package(s)

    fish -c "fisher update"

}
