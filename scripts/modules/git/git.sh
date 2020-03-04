#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# git functions

clone_git_repo_in() {

    TARGET="$1"
    URL="$2"

    if ! [[ -d "$TARGET" ]]; then
        git clone "$URL" "$TARGET"
    fi

}

is_git_repository() {

    git rev-parse &> /dev/null

}
