#!/bin/bash

# shellcheck source=/dev/null

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

execute() {

	local -r CMDS="$1"
	local -r MSG="${2:-$1}"
	local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

	local exitCode=0
	local cmdsPID=""

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# If the current process is ended,
	# also end all its subprocesses.

	set_trap "EXIT" "kill_all_subprocesses"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Execute commands in background

	eval "$CMDS" \
		&> /dev/null \
		2> "$TMP_FILE" &

	cmdsPID=$!

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Show a spinner if the commands
	# require more time to complete.

	show_spinner "$cmdsPID" "$CMDS" "$MSG"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Wait for the commands to no longer be executing
	# in the background, and then get their exit code.

	wait "$cmdsPID" &> /dev/null
	exitCode=$?

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Print output based on what happened.

	print_result $exitCode "$MSG"

	if [ $exitCode -ne 0 ]; then
		print_error_stream < "$TMP_FILE"
	fi

	rm -rf "$TMP_FILE"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	return $exitCode

}
