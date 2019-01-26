#!/bin/bash

# shellcheck source=/dev/null

if [ "$(uname -a)" == "Linux" ] && grep -qEi 'debian|buntu|kali' /etc/*release; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/debian/base.sh")"
elif [ "$(uname -a)" == "Darwin" ]; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/darwin/base.sh")"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# omf functions

is_omf_installed() {

    if ! fish_cmd_exists "omf" && [ ! -d "$HOME/.local/share/omf" ]; then
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
        execute \
            "fish -c \"omf install $PACKAGE\"" \
            "omf (install $PACKAGE)"
    else
        print_success "($PACKAGE) is already installed."
    fi

}

omf_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

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

    execute \
        "fish -c \"omf update\"" \
        "omf (update)"

}
