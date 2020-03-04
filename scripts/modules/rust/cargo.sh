#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# cargo functions

is_cargo_installed() {

    if ! cmd_exists "cargo"; then
        return 1
    fi

}

cargo_install() {

    local package="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `cargo` is installed.

    is_cargo_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [[ ! -f "$HOME/.cargo/bin/$package" ]]; then
        cargo install --quiet "$package"
    fi

}
