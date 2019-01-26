#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# git functions

clone_git_repo_in() {

    TARGET="$1"
    URL="$2"
    APP_NAME="$3"

    if ! [ -d "$TARGET" ]; then
        execute \
            "git clone $URL $TARGET" \
            "git (install $APP_NAME)"
    else
        print_success "($APP_NAME) is already installed."
    fi

}

is_git_repository() {

    git rev-parse &> /dev/null

}
