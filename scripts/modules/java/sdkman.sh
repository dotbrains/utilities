#!/bin/bash

# shellcheck source=/dev/null

if [ "$(uname -a)" == "Linux" ] && grep -qEi 'debian|buntu|kali' /etc/*release; then
		source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/debian/base.sh")"
elif [ "$(uname -a)" == "Darwin" ]; then
		 source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/darwin/base.sh")"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# sdkman functions

is_sdkman_installed() {

    if ! cmd_exists "sdk"; then
        return 1
    fi

}

sdk_install() {

    local -r candidate="${1}"
    local -r version="${2}"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `sdkman` is installed.

    is_sdkman_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    execute \
        "sdk install $candidate $version" \
        "sdk install ($candidate $version)"

}

set_default_sdk() {

    local -r candidate="${1}"
    local -r version="${2}"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    execute \
        "sdk default $candidate $version" \
        "sdk set default ($candidate $version)"

}
