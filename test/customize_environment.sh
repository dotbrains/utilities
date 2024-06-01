#!/bin/bash

# This script is used to install the necessary dependencies for
# the testing of the scripts.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

os_name=$(uname -s | tr '[:upper:]' '[:lower:]')

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Linux

if [[ "$os_name" = "linux" ]]; then

    sudo add-apt-repository multiverse
    sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty-backports restricted main universe"
    sudo apt update -qqy

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sudo apt install -qqy shellcheck

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# MacOS

elif [[ "$os_name" = "darwin" ]]; then

    brew update

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    brew install shellcheck

fi
