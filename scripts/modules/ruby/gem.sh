#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# gem functions

is_ruby_installed() {

    if ! cmd_exists "gem"; then
        return 1
    fi

}

gem_install() {

    local gem="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `ruby` is installed.

    is_ruby_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! gem query -i -n "$gem" > /dev/null 2>&1; then
        sudo gem install "$gem"
    fi

}
