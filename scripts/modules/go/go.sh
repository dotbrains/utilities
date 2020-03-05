#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# go functions

is_go_installed() {

    if ! cmd_exists "go"; then
        return 1
    fi

}

go_install() {

    local package="$1"
    local PACKAGE_READABLE_NAME

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    PACKAGE_READABLE_NAME="$(
        basename "$package"
    )"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `go` is installed.

    is_go_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [[ ! -d "$GOBIN/$PACKAGE_READABLE_NAME" ]] && [[ ! -f "$GOBIN/$PACKAGE_READABLE_NAME" ]]; then
        go get -u "$package"
    fi

}
