#!/bin/bash

# This script is used to test the scripts for syntax errors.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    # 'At first you're like "shellcheck is awesome" but then you're
    #  like "wtf[,] [why] are we still using bash[?]"'.
    #
    #  (from: https://twitter.com/astarasikov/status/568825996532707330)

    find \
        ../scripts \
        ../test \
        -type f \
        -exec shellcheck \
        -e SC1090 \
        -e SC1091 \
        -e SC2155 \
        -e SC2164 \
        -e SC2009 \
        {} +

}

main
