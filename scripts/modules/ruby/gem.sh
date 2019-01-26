#!/bin/bash

# shellcheck source=/dev/null

if [ "$(uname -a)" == "Linux" ] && grep -qEi 'debian|buntu|kali' /etc/*release; then
		source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/debian/base.sh")"
elif [ "$(uname -a)" == "Darwin" ]; then
		 source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/darwin/base.sh")"
fi

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
        execute \
            "sudo gem install $gem" \
            "gem install ($gem)"
    else
        print_success "($gem) is already installed"
    fi

}
