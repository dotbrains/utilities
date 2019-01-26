#!/bin/bash

# shellcheck source=/dev/null

if [ "$(uname -a)" == "Linux" ] && grep -qEi 'debian|buntu|kali' /etc/*release; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/debian/base.sh")"
elif [ "$(uname -a)" == "Darwin" ]; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/darwin/base.sh")"
fi

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

    if [ ! -f "$HOME/.cargo/bin/$package" ]; then
        execute \
            "cargo install --quiet $package" \
            "cargo install ($package)"
    else
        print_success "($package) is already installed"
    fi

}
