#!/bin/bash

# shellcheck source=/dev/null
# shellcheck disable=SC2086,SC2009

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Base functions

answer_is_yes() {

    [[ "$REPLY" =~ ^[Yy]$ ]] \
        && return 0 \
        || return 1

}

ask() {

    print_question "$1"
    read -r

}

ask_for_confirmation() {

    print_question "$1 (y/n) "
    read -r -n 1
    printf "\n"

}

ask_for_sudo() {

    # Ask for the administrator password upfront.

    sudo -v &> /dev/null

    # Update existing `sudo` time stamp
    # until this script has finished.
    #
    # https://gist.github.com/cowboy/3118588

    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &

}

get_answer() {

    printf "%s" "$REPLY"

}

kill_all_subprocesses() {

    local i=""

    for i in $(jobs -p); do
        kill "$i"
        wait "$i" &> /dev/null
    done

}

# Open new terminal window from the command line using v3 syntax for applescript as needed in terminal Version 3+
# This script blocks until the cmd is executed in the new terminal window then closes the new terminal window.
#
# Usage:
#     terminal [CMD]             Open a new terminal window and execute CMD
#
# Example:
#     terminal cd "$HOME"
#
# Credit:
#     Forked from https://gist.github.com/vyder/96891b93f515cb4ac559e9132e1c9086
#     Inspired by tab.bash by @bobthecow
#     link: https://gist.github.com/bobthecow/757788

terminal() {

	# Mac OS only
	[[ "$(uname -s)" != "Darwin" ]] && {
		echo 'Mac OS Only'
		return
	}

    local cmd=""
    local args="$*"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [[ -n "$args" ]]; then
        cmd="$args"
    fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	osascript <<EOF
tell application id "com.apple.Terminal"
	set T to do script
	set W to the id of window 1 where its tab 1 = T
	do script "${cmd}" in T
	repeat
		delay 0.05
		if not busy of T then exit repeat
	end repeat
	close window id W
end tell
EOF

}

# Allows the executing of a command within
# a 'x-terminal-emulator' or 'Terminal.app', whilst, showing
# a spinner within the parent shell.
#
# Does not open a new terminal window on:
# 1. Darwin-based Operating Systems (Mac OS)
# 2. Windows-Subsystem-Linux (WSL)
#
# see: https://stackoverflow.com/a/54371378/5290011
# see: https://stackoverflow.com/q/54359083/5290011
# see: https://stackoverflow.com/q/54358021/5290011
# see: https://unix.stackexchange.com/questions/137782/launching-a-terminal-emulator-without-knowing-which-ones-are-installed

execute() {

	local -r CMDS="$1"
	local -r MSG="${2:-$1}"

	local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

	uname -a | grep -q "Darwin" || \
	uname -a | grep -q "Linux" && \
	[[ -z "$SSH_TTY" ]] && \
		local -r EXIT_STATUS_FILE="$(mktemp /tmp/XXXXX)"

	local exitCode=0
	local cmdsPID=""

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	if uname -a | grep -q "Darwin" && [[ -z "$SSH_TTY" ]]; then
		terminal "$CMDS 2> $TMP_FILE ; echo \$? > $EXIT_STATUS_FILE"

		# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		cmdsPID="$(\
				ps ax | \
				grep -v grep | \
				grep -v terminal | \
				grep "$CMDS" | grep "$TMP_FILE" | grep "$EXIT_STATUS_FILE" | \
				xargs | \
				cut -d ' ' -f 1\
			)"
	elif uname -a | grep -q "Linux" && [[ -z "$SSH_TTY" ]]; then
		x-terminal-emulator -e "$CMDS 2> $TMP_FILE ; echo \$? > $EXIT_STATUS_FILE" &> /dev/null

		# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		cmdsPID="$(\
				ps ax | \
				grep -v "grep" | \
				grep "sh -c" | grep "$CMDS" | grep "$TMP_FILE" | grep "$EXIT_STATUS_FILE" | \
				xargs | \
				cut -d ' ' -f 1\
			)"
	else
		eval "$CMDS" \
			&> /dev/null \
			2> "$TMP_FILE" &

		cmdsPID=$!
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Show a spinner if the commands
	# require more time to complete.

	show_spinner "$cmdsPID" "$CMDS" "$MSG"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Wait for the commands to no longer be executing
	# in the background, and then get their exit code.

	if uname -a | grep -q "Darwin" || \
		uname -a | grep -q "Linux" && \
		! grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null || \
		[[ -z "$SSH_TTY" ]]; then
		until [[ -s "$EXIT_STATUS_FILE" ]];
		do
			sleep 1
		done

		exitCode="$(cat "$EXIT_STATUS_FILE")"
	else
		wait "$cmdsPID" &> /dev/null

		exitCode=$?
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Print output based on what happened.

	print_result "$exitCode" "$MSG"

	if [[ "$exitCode" -ne 0 ]]; then
		print_error_stream < "$TMP_FILE"
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Remove temporary files.

	rm -rf "$TMP_FILE"

	uname -a | grep -q "Darwin" || \
	uname -a | grep -q "Linux" && \
	! grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null || \
	[[ -z "$SSH_TTY" ]] && \
		rm -rf "$EXIT_STATUS_FILE"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	return "$exitCode"

}

show_spinner() {

    local -r FRAMES='/-\|'

    # shellcheck disable=SC2034
    local -r NUMBER_OR_FRAMES=${#FRAMES}

    local -r CMDS="$2"
    local -r MSG="$3"
    local -r PID="$1"

    local i=0
    local frameText=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Provide more space so that the text hopefully
    # doesn't reach the bottom line of the terminal window.
    #
    # This is a workaround for escape sequences not tracking
    # the buffer position (accounting for scrolling).
    #
    # See also: https://unix.stackexchange.com/a/278888

    printf "\n\n\n"
    tput cuu 3

    tput sc

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Display spinner while the commands are being executed.

    while kill -0 "$PID" &>/dev/null; do

        frameText="   [${FRAMES:i++%NUMBER_OR_FRAMES:1}] $MSG"

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        # Print frame text.

        printf "%s\n" "$frameText"

        sleep 0.2

        # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        # Clear frame text.

        tput rc

    done

}

# Colors
ESC_SEQ="\x1b["
COL_RESET=${ESC_SEQ}"39;49;00m"
COL_RED=${ESC_SEQ}"31;01m"
COL_GREEN=${ESC_SEQ}"32;01m"
COL_YELLOW=${ESC_SEQ}"33;01m"
COL_BLUE=${ESC_SEQ}"\e[96m"

# Weights
export bold=$(tput bold)
export normal=$(tput sgr0)

ok() {

  echo -e "$COL_GREEN[ok]$COL_RESET $1"

}

bot() {

  echo -e "$COL_BLUE(っ◕‿◕)っ$COL_RESET - $1"

}

running() {

  echo -en "$COL_YELLOW ⇒ $COL_RESET $1: "

}

action() {

  echo -e "$COL_YELLOW[action]:$COL_RESET ⇒ $1"

}

warn() {

  echo -e "$COL_YELLOW[warning]$COL_RESET $1"

}

success() {

  echo -e "$COL_GREEN[success]$COL_RESET $1"

}

error() {

  echo -e "$COL_RED[error]$COL_RESET $1"

}

cancelled() {

  echo -e "$COL_RED[cancelled]$COL_RESET $1"

}

print_error() {

    print_in_red "   [✖] $1 $2\n"

}

print_error_stream() {

    while read -r line; do
        if [[ -z "$line" ]]; then
            continue;
        fi

        print_error "↳ ERROR: $line"
    done

}

print_in_color() {

    printf "%b" \
        "$(tput setaf "$2" 2> /dev/null)" \
        "$1" \
        "$(tput sgr0 2> /dev/null)"

}

print_in_green() {

    print_in_color "$1" 2

}

print_in_purple() {

    print_in_color "$1" 5

}

print_in_red() {

    print_in_color "$1" 1

}

print_in_yellow() {

    print_in_color "$1" 3

}

print_question() {

    print_in_yellow "   [?] $1"

}

print_result() {

    if [[ "$1" -eq 0 ]]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    return "$1"

}

print_success() {

    print_in_green "   [✔] $1\n"

}

print_warning() {

    print_in_yellow "   [!] $1\n"

}

skip_questions() {

	while :; do
        case $1 in
            -y|--yes) return 0;;
                   *) break;;
        esac
        shift 1
    done

    return 1

}
