#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# omf functions

omf::is_omf_installed() {

    if ! fish_cmd_exists "omf" && [[ ! -d "$HOME/.local/share/omf" ]]; then
        return 1
    fi

}

omf::is_omf_pkg_installed() {

    fish -c "omf list | grep $1" &> /dev/null

}

omf::omf_install() {

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

omf::omf_install_from_file() {

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

omf::omf_update() {

    # Check if `omf` is installed.

    is_omf_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update package(s)

    fish -c "omf update"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_omf_installed() { omf::is_omf_installed "$@"; }
is_omf_pkg_installed() { omf::is_omf_pkg_installed "$@"; }
omf_install() { omf::omf_install "$@"; }
omf_install_from_file() { omf::omf_install_from_file "$@"; }
omf_update() { omf::omf_update "$@"; }
