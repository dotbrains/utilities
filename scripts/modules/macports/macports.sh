#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MacPorts functions

is_macports_installed() {

    cmd_exists "port"

}

is_port_installed() {

    # Check if 'MacPorts' is installed.

    is_macports_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    

    sudo port installed | grep "$1"

}

port_install() {

    declare -r PORT="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if 'MacPorts' is installed.

    is_macports_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified port.

    if ! is_port_installed "$PORT"; then
        sudo port install "$PORT"
    fi

}

port_install_from_file() {

    # Check if 'MacPorts' is installed.

    is_macports_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install port(s)

    if [[ -e "$FILE_PATH" ]]; then

        cat < "$FILE_PATH" | while read -r PORT; do
            if [[ "$PORT" == *"#"* || -z "$PORT" ]]; then
                continue
            fi

            port_install "$PORT"
        done

    fi    

}

macports_update() {

    # Check if 'MacPorts' is installed.

    is_macports_installed || return 1    

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update port(s)

    sudo port selfupdate

}