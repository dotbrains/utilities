#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fish functions

fish_cmd_exists() {

    fish -c "$1 -v" &> /dev/null

}
