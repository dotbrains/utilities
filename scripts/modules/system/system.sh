#!/bin/bash

# shellcheck source=/dev/null
# shellcheck disable=2144,2010,2062,2063,2035

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# System functions

read_kernel_name() {

	uname -s

}

read_os_name() {

    local kernelName=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    kernelName="$(read_kernel_name)"

    if [[ "$kernelName" == "Darwin" ]]; then
        printf "macos"
    elif [[ "$kernelName" == "Linux" ]] && [[ -e "/etc/os-release" ]] || [[ -e "/usr/lib/os-release" ]]; then
        local conf=""

        if test -r /etc/os-release ; then
            conf="/etc/os-release"
        else
            conf="/usr/lib/os-release"
        fi

        awk -F= '$1=="ID" { print $2 ;}' "$conf" | sed -e 's/^"//' -e 's/"$//'
    fi

}

read_os_version() {

    local kernelName=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    kernelName="$(uname -s)"

    if [[ "$kernelName" == "Darwin" ]]; then
        defaults read loginwindow SystemVersionStampAsString
    elif [[ "$kernelName" == "Linux" ]] && [[ -e "/etc/os-release" ]] || [[ -e "/usr/lib/os-release" ]]; then
        local conf=""

        if test -r /etc/os-release ; then
            conf="/etc/os-release"
        else
            conf="/usr/lib/os-release"
        fi

        awk -F= '$1=="VERSION_ID" { print $2 ;}' "$conf" | sed -e 's/^"//' -e 's/"$//'
    fi

}

get_os() {

    local os=""
    local kernelName=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    kernelName="$(uname -s)"

    if [[ "$kernelName" == "Darwin" ]]; then
        os="macos"
    elif [[ "$kernelName" == "Linux" ]] && [[ -e "/etc/os-release" ]] || [[ -e "/usr/lib/os-release" ]]; then
        if [[ "$(read_os_name)" == "ubuntu" ]]; then
            os="ubuntu"

            if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null; then
                os="windows"
            fi
        elif [[ "$(read_os_name)" == "kali" ]]; then
            os="kali-linux"
        fi
    else
        os="$kernelName"
    fi

    printf "%s" "$os"

}

get_os_version() {

    printf "%s" read_os_version

}

is_supported_version() {

    declare -a v1=("${1//./ }")
    declare -a v2=("${2//./ }")
    local i=""

    # Fill empty positions in v1 with zeros.
    for (( i=${#v1[@]}; i<${#v2[@]}; i++ )); do
        v1[i]=0
    done


    for (( i=0; i<${#v1[@]}; i++ )); do

        # Fill empty positions in v2 with zeros.
        if [[ -z ${v2[i]} ]]; then
            v2[i]=0
        fi

        if (( 10#${v1[i]} < 10#${v2[i]} )); then
            return 1
        elif (( 10#${v1[i]} > 10#${v2[i]} )); then
            return 0
        fi

    done

}

set_trap() {

    trap -p "$1" | grep "$2" &> /dev/null \
        || trap '$2' "$1"

}

symlink() {

    local sourceFile=""
    local targetFile=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sourceFile="$1"
    targetFile="$2"

    if [[ ! -e "$targetFile" ]]; then

        sudo ln -fs "$sourceFile" "$targetFile"

    elif [[ "$(readlink "$targetFile")" == "$sourceFile" ]]; then
        print_success "$targetFile → $sourceFile"
    else
		ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"

            if answer_is_yes; then

                sudo rm -rf "$targetFile"

                sudo ln -fs "$sourceFile" "$targetFile"

            else
                print_error "$targetFile → $sourceFile"
            fi
	fi

}

cmd_exists() {

    LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `.bash.local` exists within the `$HOME` directory

    if [[ -f "$LOCAL_BASH_CONFIG_FILE" ]]; then
        . "$LOCAL_BASH_CONFIG_FILE"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    command -v "$1" &> /dev/null

}

mkd() {

    if [[ -n "$1" ]]; then
        if [[ -e "$1" ]]; then
            if [[ ! -d "$1" ]]; then
                print_error "$1 - a file with the same name already exists!"
            else
                print_success "$1"
            fi
        else
            mkdir -p "$1"
        fi
    fi

}

set_default_shell() {

    declare -r EXECUTABLE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! grep -q "$EXECUTABLE_PATH" "/etc/shells"; then
        echo "$EXECUTABLE_PATH" | sudo tee -a /etc/shells
    fi

    if [[ "$SHELL" != "$EXECUTABLE_PATH" ]]; then
        sudo chsh -s "$EXECUTABLE_PATH"
    fi

}

# appends text to the end of the $HOME/.bashrc or $HOME/.bash.local
# USAGE: append_to_bashrc "source $HOME/.asdf/asdf.sh" 1
# If "1" is present, then it will skip a new line in the file.
# see: https://github.com/thoughtbot/laptop/blob/master/mac#L14:1
append_to_bashrc() {

    local text="$1"
    local skip_new_line="${2:-0}"
    local bashrc=""

    if [[ -w "$HOME/.bash.local" ]]; then
        bashrc="$HOME/.bash.local"
    else
        bashrc="$HOME/.bashrc"
    fi

    if ! grep -Fqs "$text" "$bashrc"; then
        if [[ "$skip_new_line" -eq 1 ]]; then
            printf "%s\n" "$text" >> "$bashrc"
        else
            printf "\n%s\n" "$text" >> "$bashrc"
        fi
    fi

}

# extract any type of compressed file
function extract {

    echo Extracting "$1" ...
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"  ;;
            *.tar.gz)    tar xzf "$1"  ;;
            *.bz2)       bunzip2 "$1"  ;;
            *.rar)       rar x "$1"    ;;
            *.gz)        gunzip "$1"   ;;
            *.tar)       tar xf "$1"  ;;
            *.tbz2)      tar xjf "$1"  ;;
            *.tgz)       tar xzf "$1"  ;;
            *.zip)       unzip "$1"   ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"  ;;
            *)        echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi

}

#see: https://stackoverflow.com/a/8106460/5290011
add_cron_job () {

    local FREQUENCY="$1"
    local CMD="$2"
    local JOB="$FREQUENCY $CMD"

    ! [[ "$(crontab -l | grep "$JOB")" =~ $JOB ]] \
        && cat <(grep -f -i -v "$CMD" <(crontab -l)) <(echo "$JOB") | crontab -

}

uncomment_str() {

    FILE="$1"
    KEY="$2"

    sed -i "$FILE" -e "/$KEY/s/#//g"

}

# see: https://unix.stackexchange.com/a/416596/173825
add_value_and_uncomment() {

    FILE="$1"
    KEY="$2"
    VALUE="$3"

    sed -i "$FILE" -e "/^$KEY/{s/.//; s|.$|$VALUE\"|}"

}

replace_str() {

    FILE="$1"
    KEY="$2"
    PATTERN="$3"
    REPLACEMENT="$4"

	sed -i "$FILE" -e "/$KEY/s/$PATTERN/$REPLACEMENT/g"

}

jq_replace() {

	x="$1"
	field="$2"
	value="$3"

	if cmd_exists "jq"; then
		jq ".\"$field\" |= \"$value\"" "$x" > tmp.$$.json && mv tmp.$$.json "$x"
	else
		if [[ "$(read_os_name)" = "linux" ]]; then
			sudo apt install jq -qqy
		else
			if cmd_exists "brew"; then
				brew install jq

				jq ".\"$field\" |= \"$value\"" "$x" > tmp.$$.json && mv tmp.$$.json "$x"
			fi
		fi
	fi

}
