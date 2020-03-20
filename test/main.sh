#!/bin/bash

# shellcheck source=/dev/null

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/utilities.sh")"

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
		! -path '../scripts/plugins/*' \
        -exec shellcheck \
                -e SC1090 \
                -e SC1091 \
                -e SC2155 \
                -e SC2164 \
				-e SC2009 \
         {} +

    print_result $? "Run code through ShellCheck"

}

main
