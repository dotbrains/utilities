#!/bin/bash

# shellcheck source=/dev/null

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Allows the executing of a command within
# a 'x-terminal-emulator', whilist, showing
# a spinner within the parent shell.
# see: https://stackoverflow.com/a/54371378/5290011
# see: https://stackoverflow.com/q/54359083/5290011
# see: https://stackoverflow.com/q/54358021/5290011
# see: https://unix.stackexchange.com/questions/137782/launching-a-terminal-emulator-without-knowing-which-ones-are-installed

execute() {

	local -r CMDS="$1"
	local -r MSG="${2:-$1}"

	local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

	[ -n "$XAUTHORITY" ] && \
		local -r EXIT_STATUS_FILE="$(mktemp /tmp/XXXXX)"

	local exitCode=0
	local cmdsPID=""

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	if [ -z "$XAUTHORITY" ]; then
		eval "$CMDS" \
			&> /dev/null \
			2> "$TMP_FILE" &

		cmdsPID=$!
	else
		x-terminal-emulator -e "$CMDS 2> $TMP_FILE ; echo \$? > $EXIT_STATUS_FILE" &> /dev/null

		cmdsPID="$(\
					ps ax | \
					grep -v "grep" | \
					grep "sh -c" | grep "$CMDS" | grep "$TMP_FILE" | grep "$EXIT_STATUS_FILE" | \
					xargs | \
					cut -d ' ' -f 1\
				)"
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Show a spinner if the commands
	# require more time to complete.

	show_spinner "$cmdsPID" "$CMDS" "$MSG"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Wait for the commands to no longer be executing
	# in the background, and then get their exit code.

	if [ -z "$XAUTHORITY" ]; then
		wait "$cmdsPID" &> /dev/null

		exitCode=$?
	else
		until [ -s "$EXIT_STATUS_FILE" ];
		do
			sleep 1
		done

		exitCode="$(cat "$EXIT_STATUS_FILE")"
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Print output based on what happened.

	print_result "$exitCode" "$MSG"

	if [ "$exitCode" -ne 0 ]; then
		print_error_stream < "$TMP_FILE"
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Remove temporary files.

	rm -rf "$TMP_FILE"

	[ -n "$XAUTHORITY" ] && \
		rm -rf "$EXIT_STATUS_FILE"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	return "$exitCode"

}
