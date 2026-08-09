#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MacPorts functions

macports::is_macports_installed() {

    cmd_exists "port"

}

macports::is_port_installed() {

    # Check if 'MacPorts' is installed.

    is_macports_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -    

    sudo port installed | grep "$1"

}

macports::port_install() {

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

macports::port_install_from_file() {

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

macports::macports_update() {

    # Check if 'MacPorts' is installed.

    is_macports_installed || return 1    

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update port(s)

    sudo port selfupdate

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_macports_installed() { macports::is_macports_installed "$@"; }
is_port_installed() { macports::is_port_installed "$@"; }
port_install() { macports::port_install "$@"; }
port_install_from_file() { macports::port_install_from_file "$@"; }
macports_update() { macports::macports_update "$@"; }
