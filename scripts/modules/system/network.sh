#!/bin/bash

# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Network functions

network::download() {

    local URL="$1"
    local OUTPUT="$2"

    if cmd_exists "curl"; then

        curl -LsSo "$OUTPUT" "$URL" &> /dev/null
        #     │││└─ write output to file
        #     ││└─ show error messages
        #     │└─ don't show the progress meter
        #     └─ follow redirects

        return $?

    elif cmd_exists "wget"; then

        wget -qO "$OUTPUT" "$URL" &> /dev/null
        #     │└─ write output to file
        #     └─ don't show output

        return $?
    fi

    return 1

}

network::is_connected_to_internet() {

    # The IP for the server you wish to ping (8.8.8.8 is a public Google DNS server)
    SERVER=8.8.8.8

    # Only send two pings, sending output to /dev/null
    # If the return code from ping ($?) is not 0 (meaning there was an error)
    if ping -c2 ${SERVER} > /dev/null; then
        return 1
    else
        return 0
    fi

}

network::source_file() {

	TARGET="$1"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Resolves local checkout, cache, then the pinned remote ref.
	smu::load_file "$TARGET"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

download() { network::download "$@"; }
is_connected_to_internet() { network::is_connected_to_internet "$@"; }
source_file() { network::source_file "$@"; }
