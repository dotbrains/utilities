#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# sdkman functions

sdkman::is_sdkman_installed() {

    if ! cmd_exists "sdk"; then
        return 1
    fi

}

sdkman::sdk_install() {

    local -r candidate="${1}"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `sdkman` is installed.

    is_sdkman_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sdk install "$candidate"

}

sdkman::set_default_sdk() {

    local -r candidate="${1}"
    local -r version="${2}"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sdk default "$candidate" "$version"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_sdkman_installed() { sdkman::is_sdkman_installed "$@"; }
sdk_install() { sdkman::sdk_install "$@"; }
set_default_sdk() { sdkman::set_default_sdk "$@"; }
