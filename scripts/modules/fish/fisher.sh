#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fisher functions

fisher::does_fish_plugins_exist() {

    [[ -f fish_plugins ]] || [[ -f "$HOME"/.config/fish/fish_plugins ]]

}

fisher::is_fisher_installed() {

    fish_cmd_exists "fisher" && does_fish_plugins_exist

}

fisher::is_fisher_pkg_installed() {

    does_fish_plugins_exist && fish -c "fisher list | grep $1" &> /dev/null

}

fisher::fisher_install() {

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

fisher::fisher_install_from_file() {

    # Check if `fisher` is installed.

    is_fisher_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    
    
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

fisher::fisher_update() {

    # Check if `fisher` is installed.

    is_fisher_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update package(s)

    fish -c "fisher update"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

does_fish_plugins_exist() { fisher::does_fish_plugins_exist "$@"; }
is_fisher_installed() { fisher::is_fisher_installed "$@"; }
is_fisher_pkg_installed() { fisher::is_fisher_pkg_installed "$@"; }
fisher_install() { fisher::fisher_install "$@"; }
fisher_install_from_file() { fisher::fisher_install_from_file "$@"; }
fisher_update() { fisher::fisher_update "$@"; }
