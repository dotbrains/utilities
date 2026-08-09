#!/bin/bash

# shellcheck source=/dev/null
# shellcheck disable=2144,2010,2062,2063,2035

smu::import base
smu::import apt

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# see: https://stackoverflow.com/a/22099005/5290011
debian::fix_broken_symlinks_in() {

    TARGET="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! package_is_installed "symlinks"; then
        install_package "symlinks" "symlinks"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [[ -d "$TARGET" ]]; then
        symlinks -rd "$TARGET"
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

fix_broken_symlinks_in() { debian::fix_broken_symlinks_in "$@"; }
