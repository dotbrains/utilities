#!/bin/bash

# shellcheck source=/dev/null

if [ "$(uname -a)" == "Linux" ] && grep -qEi 'debian|buntu|kali' /etc/*release; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/debian/base.sh")"
elif [ "$(uname -a)" == "Darwin" ]; then
	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/darwin/base.sh")"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pyenv functions

is_pyenv_installed() {

    if ! cmd_exists "pyenv"; then
        return 1
    fi

}

is_pyenv_plugin_installed() {

    local PLUGIN_READABLE_NAME="$1"
    local PYENV_PLUGINS_DIRECTORY="$HOME/.pyenv/plugins/"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [ ! -d "$PYENV_PLUGINS_DIRECTORY/$PLUGIN_READABLE_NAME" ]; then
        return 1
    fi

}

pyenv_install() {

    local PLUGIN_GIT_URL="$1"
    local PLUGIN_READABLE_NAME
    local PYENV_PLUGINS_DIRECTORY="$HOME/.pyenv/plugins/"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    PLUGIN_READABLE_NAME="$(
            echo "$PLUGIN_GIT_URL" | \
            cut -d "/" -f5 | \
            cut -d "." -f1
        )"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `pyenv` is installed.

    is_pyenv_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Make sure the pyenv plugin's directory exists

    if [ ! -d "$PYENV_PLUGINS_DIRECTORY" ]; then
        mkdir -p "$PYENV_PLUGINS_DIRECTORY"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pyenv_plugin_installed "$PLUGIN_READABLE_NAME"; then
        execute \
            "cd $PYENV_PLUGINS_DIRECTORY \
            && git clone $PLUGIN_GIT_URL" \
            "pyenv ($PLUGIN_READABLE_NAME)"
    else
         print_success "($PLUGIN_READABLE_NAME) is already installed"
    fi

}
