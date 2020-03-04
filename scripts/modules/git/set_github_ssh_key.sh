#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

copy_public_ssh_key_to_clipboard () {

    print_warning "Please copy the following public SSH key ($1) to the clipboard"
    printf "\n"
    [[ -e "$1" ]] && tail "$1"
    printf "\n"

}

generate_ssh_keys() {

    ssh-keygen -t rsa -b 4096 -f "$1"

    printf "\n"

    print_result $? "Generate SSH keys"

}

open_github_ssh_page() {

    declare -r GITHUB_SSH_URL="https://github.com/settings/ssh"

    print_warning "Please add the public SSH key to GitHub ($GITHUB_SSH_URL)"

}

set_github_ssh_key() {

    local sshKeyFileName="$HOME/.ssh/id_rsa"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # If there is already a file with that
    # name, remove it.

    if [[ -f "$sshKeyFileName" ]]; then
        rm -rf "$sshKeyFileName".pub
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    generate_ssh_keys "${sshKeyFileName}"
    copy_public_ssh_key_to_clipboard "${sshKeyFileName}.pub"
    open_github_ssh_page

    printf "\n"

    test_ssh_connection \
        && rm "${sshKeyFileName}.pub"

    printf "\n"

}

test_ssh_connection() {

    while true; do

        ssh -T git@github.com &> /dev/null
        [[ $? -eq 1 ]] && break

        sleep 5

    done

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n • Set up GitHub SSH keys\n\n"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ssh -T git@github.com &> /dev/null

    if [[ $? -ne 1 ]]; then
        set_github_ssh_key
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    print_result $? "Set up GitHub SSH keys"

}

main
