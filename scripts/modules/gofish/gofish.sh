#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# gofish functions

gofish::is_gofish_installed() {

    if ! cmd_exists "gofish"; then
        return 1
    fi

}

gofish::gofish_cleanup() {

    # By default gofish does not uninstall older versions
    # of fishfood so, in order to remove them, `gofish cleanup`
    # needs to be used.
    #
    # https://gofi.sh/#install

    gofish cleanup

}

gofish::gofish_update() {

    # Check if `gofish` is installed.

    is_gofish_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    gofish update

}

gofish::gofish_upgrade() {

    # Check if `gofish` is installed.

    is_gofish_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    gofish upgrade

}


gofish::gofish_install() {

    declare -r FOOD="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `gofish` is installed.

    is_gofish_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified fish food.

    if ! gofish list | grep "$FOOD" &> /dev/null; then
		gofish install "$FOOD"
    fi

}

gofish::gofish_install_from_file() {

    declare -r FILE_PATH="$1"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `gofish` is installed.

    is_gofish_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install fish food.

    if [[ -e "$FILE_PATH" ]]; then

		regex["comment"]='^#(.*)'
		regex["food"]='food "(.*)"'

		cat < "$FILE_PATH" | while read -r LINE; do
            if [[ ${LINE} =~ ${regex["comment"]} ]]; then
                continue
            elif [[ ${LINE} =~ ${regex["food"]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}

				gofish_install "$PACKAGE"
			fi
		done

    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_gofish_installed() { gofish::is_gofish_installed "$@"; }
gofish_cleanup() { gofish::gofish_cleanup "$@"; }
gofish_update() { gofish::gofish_update "$@"; }
gofish_upgrade() { gofish::gofish_upgrade "$@"; }
gofish_install() { gofish::gofish_install "$@"; }
gofish_install_from_file() { gofish::gofish_install_from_file "$@"; }
