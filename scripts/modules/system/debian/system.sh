#!/bin/bash

# shellcheck source=/dev/null
# shellcheck disable=2144,2010,2062,2063,2035

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/modules/system/debian/apt.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# see: https://stackoverflow.com/a/22099005/5290011
fix_broken_symlinks_in() {

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
