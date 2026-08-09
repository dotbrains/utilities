#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pyenv functions

pyenv::is_pyenv_installed() {

    if ! cmd_exists "pyenv"; then
        return 1
    fi

}

pyenv::is_pyenv_plugin_installed() {

    local PLUGIN_READABLE_NAME="$1"
    local PYENV_PLUGINS_DIRECTORY="$HOME/.pyenv/plugins/"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [[ ! -d "$PYENV_PLUGINS_DIRECTORY/$PLUGIN_READABLE_NAME" ]]; then
        return 1
    fi

}

pyenv::pyenv_install() {

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

    if [[ ! -d "$PYENV_PLUGINS_DIRECTORY" ]]; then
        mkdir -p "$PYENV_PLUGINS_DIRECTORY"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pyenv_plugin_installed "$PLUGIN_READABLE_NAME"; then
        cd "$PYENV_PLUGINS_DIRECTORY" \
            && git clone "$PLUGIN_GIT_URL"
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

is_pyenv_installed() { pyenv::is_pyenv_installed "$@"; }
is_pyenv_plugin_installed() { pyenv::is_pyenv_plugin_installed "$@"; }
pyenv_install() { pyenv::pyenv_install "$@"; }
