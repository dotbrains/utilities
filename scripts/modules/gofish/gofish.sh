#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# gofish functions

is_gofish_installed() {

    if ! cmd_exists "gofish"; then
        return 1
    fi

}

gofish_cleanup() {

    # By default gofish does not uninstall older versions
    # of fishfood so, in order to remove them, `gofish cleanup`
    # needs to be used.
    #
    # https://gofi.sh/#install

    gofish cleanup

}

gofish_update() {

    # Check if `gofish` is installed.

    is_gofish_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    gofish update

}

gofish_upgrade() {

    # Check if `gofish` is installed.

    is_gofish_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    gofish upgrade

}


gofish_install() {

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

gofish_install_from_file() {

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
