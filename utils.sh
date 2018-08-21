#!/bin/bash

set_default_shell() {

    declare -r EXECUTABLE_PATH="$1"
    declare -r SHELL_READABLE_NAME="basename $1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! grep -q "$EXECUTABLE_PATH" "/etc/shells"; then
        execute \
            "echo $EXECUTABLE_PATH | sudo tee -a /etc/shells" \
            "Add ($SHELL_READABLE_NAME) to '/etc/shells'"
    fi

    if [[ "$SHELL" != "$EXECUTABLE_PATH" ]]; then
        execute \
            "sudo chsh -s $EXECUTABLE_PATH" \
            "\$SHELL -> ($EXECUTABLE_PATH)"
    else
        print_success "($SHELL_READABLE_NAME) is already the default \$SHELL"
    fi

}


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

# appends text to the end of the $HOME/.bashrc or $HOME/.bash.local
# USAGE: append_to_bashrc "source $HOME/.asdf/asdf.sh" 1
# If "1" is present, then it will skip a new line in the file.
# see: https://github.com/thoughtbot/laptop/blob/master/mac#L14:1
append_to_bashrc() {

    local text="$1"
    local skip_new_line="${2:-0}"
    local bashrc=""

    if [ -w "$HOME/.bash.local" ]; then
        bashrc="$HOME/.bash.local"
    else
        bashrc="$HOME/.bashrc"
    fi

    if ! grep -Fqs "$text" "$bashrc"; then
        if [ "$skip_new_line" -eq 1 ]; then
            printf "%s\n" "$text" >> "$bashrc"
        else
            printf "\n%s\n" "$text" >> "$bashrc"
        fi
    fi

}

cmd_exists() {

    LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `.bash.local` exists within the `$HOME` directory

    if [ -f "$LOCAL_BASH_CONFIG_FILE" ]; then
        . "$LOCAL_BASH_CONFIG_FILE"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    command -v "$1" &> /dev/null

}

kill_all_subprocesses() {

    local i=""

    for i in $(jobs -p); do
        kill "$i"
        wait "$i" &> /dev/null
    done

}

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

is_connected_to_internet() {

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

read_os_name() {

    local kernelName=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    kernelName="$(uname -s)"

    if [ "$kernelName" == "Darwin" ]; then
        printf "macos"
    elif [ "$kernelName" == "Linux" ] && [ -e "/etc/os-release" ] || [ -e "/usr/lib/os-release" ]; then
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

    if [ "$kernelName" == "Darwin" ]; then
        defaults read loginwindow SystemVersionStampAsString
    elif [ "$kernelName" == "Linux" ] && [ -e "/etc/os-release" ] || [ -e "/usr/lib/os-release" ]; then
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

    if [ "$kernelName" == "Darwin" ]; then
        os="macos"
    elif [ "$kernelName" == "Linux" ] && [ -e "/etc/os-release" ] || [ -e "/usr/lib/os-release" ]; then
        if [ "$(read_os_name)" == "ubuntu" ]; then
            os="ubuntu"

            if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
                os="windows"
            fi
        elif [ "$(read_os_name)" == "kali" ]; then
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

    declare -a v1=(${1//./ })
    declare -a v2=(${2//./ })
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

symlink() {

    local sourceFile=""
    local targetFile=""
    local skipQuestions=false

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    skip_questions "$1" \
        && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sourceFile="$2"
    targetFile="$3"

    if [ ! -e "$targetFile" ] || $skipQuestions; then

        execute \
            "sudo ln -fs $sourceFile $targetFile" \
            "$targetFile → $sourceFile"

    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
        print_success "$targetFile → $sourceFile"
    else

        if ! $skipQuestions; then

            ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"

            if answer_is_yes; then

                sudo rm -rf "$targetFile"

                execute \
                    "sudo ln -fs $sourceFile $targetFile" \
                    "$targetFile → $sourceFile"

            else
                print_error "$targetFile → $sourceFile"
            fi

        fi
    fi

}

# see: https://stackoverflow.com/a/22099005/5290011
fix_broken_symlinks_in() {

    TARGET="$1"
    DESCRIPTION="$2"

    if [ -d "$TARGET" ]; then
        if cmd_exists "symlinks"; then
            execute \
                "symlinks -rd $TARGET" \
                "$DESCRIPTION"
        else
            execute \
                "find . -type l -exec sh -c 'for x; do [ -e $x ] || rm -rf $x; done' _ {} +" \
                "$DESCRIPTION"
        fi
    fi

}

mkd() {

    if [ -n "$1" ]; then
        if [ -e "$1" ]; then
            if [ ! -d "$1" ]; then
                print_error "$1 - a file with the same name already exists!"
            else
                print_success "$1"
            fi
        else
            execute "mkdir -p $1" "$1"
        fi
    fi

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

    if [ "$1" -eq 0 ]; then
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

set_trap() {

    trap -p "$1" | grep "$2" &> /dev/null \
        || trap '$2' "$1"

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

download() {

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

# extract any type of compressed file
function extract {

    echo Extracting "$1" ...
    if [ -f "$1" ] ; then
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# file-manipluation functions

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

	if [ "$(which jq)" ] ; then
		jq ".\"$field\" |= \"$value\"" "$x" > tmp.$$.json && mv tmp.$$.json "$x"
	else
		sudo apt install jq -qqy

		jq ".\"$field\" |= \"$value\"" "$x" > tmp.$$.json && mv tmp.$$.json "$x"
	fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# git functions

clone_git_repo_in() {

    TARGET="$1"
    URL="$2"
    APP_NAME="$3"

    if ! [ -d "$TARGET" ]; then
        execute \
            "git clone $URL $TARGET" \
            "git (install $APP_NAME)"
    else
        print_success "($APP_NAME) is already installed."
    fi

}

is_git_repository() {

    git rev-parse &> /dev/null

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# APT functions

add_key() {

    wget -qO - "$1" | sudo apt-key add - &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output

}

add_ppa() {

    sudo add-apt-repository -y ppa:"$1" &> /dev/null \
        && sudo apt update --fix-missing &> /dev/null

}

add_gpg_key_with_dearmor() {

    sudo curl -s "$1" | gpg --dearmor > "$2" \
        && sudo mv "$2" /etc/apt/trusted.gpg.d/"$2"

}

add_to_source_list() {


    if ! [ -e "/etc/apt/sources.list.d/$2" ]; then
        sudo sh -c "printf 'deb $1' >> '/etc/apt/sources.list.d/$2'" \
            && sudo apt update --fix-missing &> /dev/null
    fi

}

autoremove() {

    # Remove packages that were automatically installed to satisfy
    # dependencies for other packages and are no longer needed.

    execute \
        "sudo apt-get autoremove -qqy" \
        "APT (autoremove)"

}

fix_dpkg() {

    declare -a files=("/var/lib/dpkg/lock" "/var/cache/apt/archives/lock")

    for i in "${files[@]}"
    do
        # If there is a dpkg lock, then remove it.
        if [ -e "$i" ]; then
            sudo rm -rf "$i" &> /dev/null
        fi
    done

    sudo dpkg --configure -a &> /dev/null

}

package_is_installed() {

    dpkg -s "$1" &> /dev/null

}

remove_system_package() {

    declare -r PACKAGE_READABLE_NAME="$1"
    local PACKAGE="$2"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    execute \
        "sudo apt remove $PACKAGE -qqy \
            && sudo apt purge $PACKAGE -qqy \
            && sudo apt autoremove -qqy \
            && sudo apt clean" \
        "APT remove ($PACKAGE_READABLE_NAME)"

}

remove_package() {

    declare -r PACKAGE_READABLE_NAME="$1"
    local PACKAGE="$2"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if package_is_installed "$PACKAGE"; then
        execute \
            "sudo apt remove $PACKAGE -qqy \
                && sudo apt purge $PACKAGE -qqy \
                && sudo apt autoremove -qqy \
                && sudo apt clean" \
            "APT remove ($PACKAGE_READABLE_NAME)"
    else
        print_warning "($PACKAGE_READABLE_NAME) is not installed"
    fi

}

upgrade_package() {

    declare -r PACKAGE_READABLE_NAME="$1"
    declare -r PACKAGE="$2"

    if package_is_installed "$PACKAGE"; then
       execute \
            "sudo apt install --only-upgrade -qqy $PACKAGE" \
            "$PACKAGE_READABLE_NAME (upgrade)"
    fi

}

install_package() {

    declare -r PACKAGE_READABLE_NAME="$1"
    declare -r PACKAGE="$2"

    if ! package_is_installed "$PACKAGE"; then
        fix_dpkg
        execute "sudo apt-get install --allow-unauthenticated -qqy $PACKAGE" "$PACKAGE_READABLE_NAME"
        #                                      suppress output ─┘│
        #            assume "yes" as the answer to all prompts ──┘
    else
        print_success "($PACKAGE_READABLE_NAME) is already installed."
    fi

}

apt_install_from_file() {

    declare -r FILE_PATH="$1"

    declare -A regex
    regex["comment"]='^#(.*)'
    regex["ppa"]='ppa "(.*)"'
    regex["apt"]='apt "(.*)"'
    regex["deb"]='deb "(.*)" \[args: "(.*)", "(.*)", "(.*)"\]'
    regex["gpg_dearmor"]='gpg-dearmor "(.*)" \[args: "(.*)"\]'
    regex["gpg"]='gpg "(.*)" \[args: "(.*)"\]'
    regex["source"]='source "(.*)" \[args: "(.*)"\]'
    regex["remove"]='remove "(.*)"'
    regex["remove_system"]='remove-system "(.*)"'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

        # Update & upgrade system prior to installing packages
        apt_update
        apt_upgrade

        printf "\n"

        cat < "$FILE_PATH" | while read -r LINE; do
            if [[ $LINE =~ ${regex[comment]} ]]; then
                continue
            elif [[ $LINE =~ ${regex[ppa]} ]]; then
                PPA=${BASH_REMATCH[1]}
                add_ppa "$PPA"
            elif [[ $LINE =~ ${regex[apt]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}
                install_package "$PACKAGE" "$PACKAGE"
            elif [[ $LINE =~ ${regex[deb]} ]]; then
                PACKAGE_READABLE_NAME=${BASH_REMATCH[1]}
                URL=${BASH_REMATCH[2]}
                TARGET_PATH=${BASH_REMATCH[3]}
                FILE_NAME=${BASH_REMATCH[4]}
                DEB_FILE_PATH="$TARGET_PATH/$FILE_NAME"

                install_gdebi "$URL" "$DEB_FILE_PATH" "$PACKAGE_READABLE_NAME" "$PACKAGE_READABLE_NAME"
            elif [[ $LINE =~ ${regex[gpg_dearmor]} ]]; then
                FILE_NAME=${BASH_REMATCH[1]}
                URL=${BASH_REMATCH[2]}

                add_gpg_key_with_dearmor "$URL" "$FILE_NAME"
            elif [[ $LINE =~ ${regex[gpg]} ]]; then
                URL=${BASH_REMATCH[1]}

                add_key "$URL"
            elif [[ $LINE =~ ${regex[source]} ]]; then
                FILE_NAME=${BASH_REMATCH[1]}
                DATA=${BASH_REMATCH[2]}

                add_to_source_list "$DATA" "$FILE_NAME"
            elif [[ $LINE =~ ${regex[remove]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}

                remove_package "$PACKAGE" "$PACKAGE"
            elif [[ $LINE =~ ${regex[remove_system]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}

                remove_system_package "$PACKAGE" "$PACKAGE"
            fi
        done

        printf "\n"

    fi

}

# see: https://unix.stackexchange.com/a/332979/173825
install_gdebi() {

    declare -r URL="$1"
    declare -r FILE_PATH="$2"
    declare -r PACKAGE="$3"
    declare -r PACKAGE_READABLE_NAME="$4"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! cmd_exists "gdebi"; then
        install_package "gdebi" "gdebi"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install deb using gdebi

    if [ ! -e "$FILE_PATH" ]; then

        if ! package_is_installed "$PACKAGE"; then
            execute \
                "wget $URL -qO $FILE_PATH && \
                sudo gdebi -n -q $FILE_PATH && \
                sudo rm -rf $FILE_PATH && sudo apt autoremove -qqy" \
                "$PACKAGE_READABLE_NAME"
        else
            print_success "($PACKAGE_READABLE_NAME) is already installed."
        fi

    fi
}

# see: https://unix.stackexchange.com/a/159114/173825
install_deb() {

    declare -r URL="$1"
    declare -r FILE_PATH="$2"
    declare -r PACKAGE="$3"
    declare -r PACKAGE_READABLE_NAME="$4"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install deb

    if [ ! -e "$FILE_PATH" ]; then

        if ! package_is_installed "$PACKAGE"; then
            execute \
                "wget $URL -qO $FILE_PATH && \
                sudo dpkg -i $FILE_PATH && sudo apt install -f && \
                sudo rm -rf $FILE_PATH && sudo apt autoremove -qqy" \
                "$PACKAGE_READABLE_NAME"
        else
            print_success "($PACKAGE_READABLE_NAME) is already installed."
        fi

    fi

}

apt_update() {

    fix_dpkg

    # Resynchronize the package index files from their sources and fix any missing dependencies.

    execute \
        "sudo apt-get update --fix-missing && \
        sudo apt-get install -f" \
        "APT (update)"

}

apt_upgrade() {

    fix_dpkg

    # Install the newest versions of all packages installed.

    execute \
        "export DEBIAN_FRONTEND=\"noninteractive\" \
            && sudo apt-get -o Dpkg::Options::=\"--force-confnew\" upgrade -qqy --allow-unauthenticated" \
        "APT (upgrade)"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pip functions

is_pip_installed() {

    if ! cmd_exists "pip"; then
        print_error "(pip) is not installed."
        return 1
    fi

}

is_pip_pkg_installed() {

    pip list | grep "$1" > /dev/null 2>&1

}

pip_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `pip` is installed.

    is_pip_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pip_pkg_installed "$PACKAGE"; then
        execute \
            "python -m pip install --quiet $PACKAGE" \
            "$PACKAGE"
    else
        print_success "($PACKAGE) is already installed."
    fi

}

pip_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            pip_install "$PACKAGE"
        done

    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pip3 functions

is_pip3_installed() {

    if ! cmd_exists "pip3"; then
        print_error "(pip3) is not installed."
        return 1
    fi

}

is_pip3_pkg_installed() {

    pip3 list | grep "$1" > /dev/null 2>&1

}

pip3_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `pip3` is installed.

    is_pip3_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pip3_pkg_installed "$PACKAGE"; then
        execute \
            "sudo pip3 install --quiet $PACKAGE" \
            "$PACKAGE"
    else
        print_success "($PACKAGE) is already installed."
    fi

}

pip3_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            pip3_install "$PACKAGE"
        done

    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pyenv functions

is_pyenv_installed() {

    if ! cmd_exists "pyenv"; then
        return 1
    fi

}

is_pyenv_plugin_installed() {

    local PLUGIN_READABLE_NAME="$1"
    local PYENV_PLUGINS_DIRECTORY="$HOME/.pyenv/plugins/"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [ ! -d "$PYENV_PLUGINS_DIRECTORY/$PLUGIN_READABLE_NAME" ]; then
        return 1
    fi

}

pyenv_install() {

    local PLUGIN_GIT_URL="$1"
    local PLUGIN_READABLE_NAME="$(
        echo "$PLUGIN_GIT_URL" | \
        cut -d "/" -f5 | \
        cut -d "." -f1
    )"
    local PYENV_PLUGINS_DIRECTORY="$HOME/.pyenv/plugins/"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `pyenv` is installed.

    is_pyenv_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Make sure the pyenv plugin's directory exists

    if [ ! -d "$PYENV_PLUGINS_DIRECTORY" ]; then
        mkdir -p "$PYENV_PLUGINS_DIRECTORY"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! is_pyenv_plugin_installed "$PLUGIN_READABLE_NAME"; then
        execute \
            "cd $PYENV_PLUGINS_DIRECTORY \
            && git clone $PLUGIN_GIT_URL" \
            "pyenv ($PLUGIN_READABLE_NAME)"
    else
         print_success "($PLUGIN_READABLE_NAME) is already installed"
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# brew functions

is_brew_installed() {

    if ! cmd_exists "brew"; then
        print_error "(brew) is not installed."
        return 1
    fi

}

brew_cleanup() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # By default brew does not uninstall older versions
    # of formulas so, in order to remove them, `brew cleanup`
    # needs to be used.
    #
    # https://github.com/Homebrew/brew/blob/496fff643f352b0943095e2b96dbc5e0f565db61/share/doc/homebrew/FAQ.md#how-do-i-uninstall-old-versions-of-a-formula

    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew cleanup" \
        "brew (cleanup)"

    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew cask cleanup" \
        "brew (cask cleanup)"

}


brew_bundle_install() {

    declare -r FILE_PATH="$1"

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install formulae.

    if [ -e "$FILE_PATH" ]; then

        execute \
            ". $LOCAL_BASH_CONFIG_FILE \
                && brew bundle install -v --file=\"$FILE_PATH\"" \
            "brew (bundle install $FILE_PATH)"

    fi
}

brew_install() {

    declare -r CMD="$3"
    declare -r FORMULA="$1"
    declare -r TAP_VALUE="$2"

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `brew` is installed.

    is_brew_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # If `brew tap` needs to be executed,
    # check if it executed correctly.

    if [ -n "$TAP_VALUE" ]; then
        if ! brew_tap "$TAP_VALUE"; then
            print_error "$FORMULA_READABLE_NAME ('brew tap $TAP_VALUE' failed)"
            return 1
        fi
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified formula.

    if brew "$CMD" list | grep "$FORMULA" &> /dev/null; then
        print_success "($FORMULA) is already installed"
    else
        execute \
            ". $LOCAL_BASH_CONFIG_FILE \
                && brew $CMD install $FORMULA" \
            "$FORMULA"
    fi

}

brew_prefix() {

    local path=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if path="$(brew --prefix 2> /dev/null)"; then
        printf "%s" "$path"
        return 0
    else
        print_error "brew (get prefix)"
        return 1
    fi

}

brew_tap() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    . "$LOCAL_BASH_CONFIG_FILE" \
        && brew tap "$1" &> /dev/null

}

brew_update() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew update" \
        "brew (update)"

}

brew_upgrade() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew upgrade" \
        "brew (upgrade)"

}

brew_upgrade_formulae() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    execute \
        ". $LOCAL_BASH_CONFIG_FILE \
            && brew  upgrade $2" \
        "brew (upgrade $1)"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# node functions

is_npm_installed() {

    if ! cmd_exists "npm"; then
        print_error "(npm) is not installed."
        return 1
    fi

}

is_npm_pkg_installed() {

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    . "$LOCAL_BASH_CONFIG_FILE" \
        && npm list --depth 1 --global "$1" > /dev/null 2>&1

}

npm_install() {

    declare -r PACKAGE="$1"

    local LOCAL_BASH_CONFIG_FILE="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `npm` is installed.

    is_npm_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified package.

    if ! is_npm_pkg_installed "$PACKAGE"; then
        execute \
            ". $LOCAL_BASH_CONFIG_FILE \
                && npm install --global --silent $PACKAGE" \
            "$PACKAGE"
    else
        print_success "($PACKAGE) is already installed."
    fi

}

npm_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            npm_install "$PACKAGE"
        done

    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fish functions

fish_cmd_exists() {

    fish -c "$1 -v" &> /dev/null

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# omf functions

is_omf_installed() {

    if ! fish_cmd_exists "omf" && [ ! -d "$HOME/.local/share/omf" ] && [ ! -d "$HOME/.config/omf" ]; then
        return 1
    fi

}

is_omf_pkg_installed() {

    fish -c "omf list | grep $1" &> /dev/null

}

omf_install() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `omf` is installed.

    is_omf_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified package.

    if ! is_omf_pkg_installed "$PACKAGE"; then
        execute \
            "fish -c \"omf install $PACKAGE\"" \
            "omf (install $PACKAGE)"
    else
        print_success "($PACKAGE) is already installed."
    fi

}

omf_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            omf_install "$PACKAGE"
        done

    fi

}

omf_update() {

    # Check if `omf` is installed.

    is_omf_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update package(s)

    execute \
        "fish -c \"omf update\"" \
        "omf (update)"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fisher functions

is_fisher_installed() {

    if ! fish_cmd_exists "fisher"; then
        return 1
    fi

}

is_fisher_pkg_installed() {

    fish -c "fisher ls | grep $1" &> /dev/null

}

fisher_install() {

    declare -r PACKAGE="$(echo "$1" | cut -d '/' -f 2)"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `fisher` is installed.

    is_fisher_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install the specified package.

    if ! is_fisher_pkg_installed "$PACKAGE"; then
        execute \
            "fish -c \"fisher $PACKAGE\"" \
            "fisher (install $PACKAGE)"
    else
        print_success "($PACKAGE) is already installed."
    fi

}

fisher_install_from_file() {

    declare -r FILE_PATH="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [ -e "$FILE_PATH" ]; then

        cat < "$FILE_PATH" | while read -r PACKAGE; do
            if [[ "$PACKAGE" == *"#"* || -z "$PACKAGE" ]]; then
                continue
            fi

            fisher_install "$PACKAGE"
        done

    fi
}

fisher_update() {

    # Check if `fisher` is installed.

    is_fisher_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Update package(s)

    execute \
        "fish -c \"fisher up\"" \
        "fisher (update)"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# tacklebox functions

is_tacklebox_installed() {

    if ! [ -d "$HOME/.tacklebox" ] && ! [ -d "$HOME/.tackle" ]; then
        return 1
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# gem functions

is_ruby_installed() {

    if ! cmd_exists "gem"; then
        return 1
    fi

}

gem_install() {

    local gem="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `ruby` is installed.

    is_ruby_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! gem query -i -n "$gem" > /dev/null 2>&1; then
        execute \
            "sudo gem install $gem" \
            "gem install ($gem)"
    else
        print_success "($gem) is already installed"
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# go functions

is_go_installed() {

    if ! cmd_exists "go"; then
        return 1
    fi

}

go_install() {

    local package="$1"
    local PACKAGE_READABLE_NAME

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    PACKAGE_READABLE_NAME="$(
        echo $package | \
        cut -d "/" -f3
    )"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if `go` is installed.

    is_go_installed || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [ ! -d "$GOBIN/$PACKAGE_READABLE_NAME" ]; then
        execute \
            "go get $package" \
            "go install ($PACKAGE_READABLE_NAME)"
    else
        print_success "($PACKAGE_READABLE_NAME) is already installed"
    fi

}
