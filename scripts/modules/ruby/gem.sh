#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# gem functions

gem::is_ruby_installed() {

    if ! cmd_exists "gem"; then
        return 1
    fi

}

gem::gem_install() {

    local gem="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `ruby` is installed.

    is_ruby_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! gem query -i -n "$gem" > /dev/null 2>&1; then
        sudo gem install "$gem"
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_ruby_installed() { gem::is_ruby_installed "$@"; }
gem_install() { gem::gem_install "$@"; }
