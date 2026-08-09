#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# cargo functions

cargo::is_cargo_installed() {

    if ! cmd_exists "cargo"; then
        return 1
    fi

}

cargo::cargo_install() {

    local package="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `cargo` is installed.

    is_cargo_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [[ ! -f "$HOME/.cargo/bin/$package" ]]; then
        cargo install --quiet "$package"
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_cargo_installed() { cargo::is_cargo_installed "$@"; }
cargo_install() { cargo::cargo_install "$@"; }
