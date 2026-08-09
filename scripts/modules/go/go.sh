#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# go functions

go::is_go_installed() {

    if ! cmd_exists "go"; then
        return 1
    fi

}

go::go_install() {

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_go_installed() { go::is_go_installed "$@"; }
go_install() { go::go_install "$@"; }
