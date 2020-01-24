#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# sdkman functions

is_sdkman_installed() {

    if ! cmd_exists "sdk"; then
        return 1
    fi

}

sdk_install() {

    local -r candidate="${1}"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `sdkman` is installed.

    is_sdkman_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sdk install "$candidate"

}

set_default_sdk() {

    local -r candidate="${1}"
    local -r version="${2}"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sdk default "$candidate" "$version"

}
