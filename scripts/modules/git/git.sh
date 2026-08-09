#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# git functions

git::clone_git_repo_in() {

    TARGET="$1"
    URL="$2"

    if ! [[ -d "$TARGET" ]]; then
        git clone "$URL" "$TARGET"
    fi

}

git::is_git_repository() {

    git rev-parse &> /dev/null

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

clone_git_repo_in() { git::clone_git_repo_in "$@"; }
is_git_repository() { git::is_git_repository "$@"; }
