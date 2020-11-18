#!/bin/bash

# shellcheck disable=SC2086
# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# APT functions

add_key() {

    wget -qO - "$1" | sudo apt-key add - &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output

}

add_ppa() {

    sudo add-apt-repository -y ppa:"$1" &> /dev/null \
        && sudo apt-get update --fix-missing &> /dev/null

}

add_gpg_key_with_dearmor() {

    sudo curl -s "$1" | gpg --dearmor > "$2" \
        && sudo mv "$2" /etc/apt/trusted.gpg.d/"$2"

}

add_to_source_list() {


    if ! [[ -e "/etc/apt/sources.list.d/$2" ]]; then
        sudo sh -c "printf 'deb $1' >> '/etc/apt/sources.list.d/$2'" \
            && sudo apt-get update --fix-missing &> /dev/null
    fi

}

auto_remove() {

    # Remove packages that were automatically installed to satisfy
    # dependencies for other packages and are no longer needed.

    sudo apt-get autoremove -qqy

}

apt_update() {

    # Resynchronize the package index files.

    sudo apt-get update

}

apt_upgrade() {

    # Install the newest versions of all packages installed.

	sudo apt-get upgrade -y

}

package_is_installed() {

    dpkg -s "$1" &> /dev/null

}

snap_is_installed() {

    snap list | grep "$1" &> /dev/null

}

umake_is_installed() {

	[[ -d "$HOME/.local/share/umake/$2/$1" ]]

}

remove_system_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sudo apt-get remove "$PACKAGE" -qqy \
            && sudo apt-get purge "$PACKAGE" -qqy \
            && sudo apt-get autoremove -qqy \
            && sudo apt-get clean

}

remove_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if package_is_installed "$PACKAGE"; then
        sudo apt-get remove "$PACKAGE" -qqy \
                && sudo apt-get purge "$PACKAGE" -qqy \
                && sudo apt-get autoremove -qqy \
                && sudo apt-get clean
    fi

}

upgrade_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if package_is_installed "$PACKAGE"; then
		sudo apt-get install --only-upgrade -qqy "$PACKAGE"
    fi

}

install_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! package_is_installed "$PACKAGE"; then
        sudo apt-get install --allow-unauthenticated -qqy "$PACKAGE"
    #                            suppress output ─┘│
    #  assume "yes" as the answer to all prompts ──┘
    fi

}

install_snap_package() {

    declare -r PACKAGE="$1"
	declare -r ARGUMENTS="$2"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	if ! package_is_installed "snapd"; then
		install_package "snapd"

		sudo systemctl start snapd && \
		sudo systemctl enable snapd

		sudo systemctl start apparmor && \
		sudo systemctl enable apparmor
	fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! snap_is_installed "$PACKAGE"; then
        sudo snap install "$PACKAGE" ${ARGUMENTS}
    fi

}

install_umake_package() {

    declare -r PACKAGE="$1"
	declare -r CATEGORY="$2"
    declare -r LANG="$3"

    declare -r DEST_DIR="$HOME/.local/share/umake/$CATEGORY/$PACKAGE"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	install_snap_package "ubuntu-make" "--classic"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! umake_is_installed "$PACKAGE" "$CATEGORY"; then
        umake "$CATEGORY" "$PACKAGE" "$DEST_DIR" --lang "$LANG"
    fi

}

# see: https://unix.stackexchange.com/a/332979/173825
install_gdebi() {

    declare -r URL="$1"
    declare -r FILE_NAME="$2"
    declare -r PACKAGE="$3"

    declare -r FILE_PATH="$HOME/Downloads/$FILE_NAME"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    install_package "gdebi"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install deb using gdebi

    if ! package_is_installed "$PACKAGE"; then
		wget "$URL" -qO "$FILE_PATH" &> /dev/null && \
			sudo gdebi -n -q "$FILE_PATH" && \
			sudo rm -rf "$FILE_PATH" && \
			sudo apt-get autoremove -qqy && \
			sudo apt-get update
	fi
}

# see: https://unix.stackexchange.com/a/159114/173825
install_deb() {

    declare -r URL="$1"
    declare -r FILE_NAME="$2"
    declare -r PACKAGE="$3"

    declare -r FILE_PATH="$HOME/Downloads/$FILE_NAME"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install deb

    if ! package_is_installed "$PACKAGE"; then
		wget "$URL" -qO "$FILE_PATH" &> /dev/null && \
			sudo dpkg -i "$FILE_PATH" && sudo apt-get install -f && \
			sudo rm -rf "$FILE_PATH" && \
			sudo apt-get autoremove -qqy && \
			sudo apt-get update
	fi

}

apt_install_from_file() {

    declare -r FILE_PATH="$1"

    declare -A regex
    regex["comment"]='^#(.*)'
    regex["ppa"]='ppa "(.*)"'
    regex["apt"]='apt "(.*)"'
    regex["snap"]='snap "(.*)" \[args: "(.*)"\]'
   	regex["umake"]='umake "(.*)" \[args: "(.*)", "(.*)"\]'
    regex["deb"]='deb "(.*)" \[args: "(.*)", "(.*)"\]'
    regex["gpg_dearmor"]='gpg_dearmor "(.*)" \[args: "(.*)"\]'
    regex["gpg"]='gpg "(.*)" \[args: "(.*)"\]'
    regex["source"]='source "(.*)" \[args: "(.*)"\]'
    regex["remove"]='remove "(.*)"'
    regex["remove_system"]='remove_system "(.*)"'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install package(s)

    if [[ -e "$FILE_PATH" ]]; then

        # Update & upgrade system prior to installing packages
        apt_update
        apt_upgrade

        cat < "$FILE_PATH" | while read -r LINE; do
            if [[ ${LINE} =~ ${regex["comment"]} ]]; then
                continue
            elif [[ ${LINE} =~ ${regex["ppa"]} ]]; then
                PPA=${BASH_REMATCH[1]}

				add_ppa "$PPA"
            elif [[ ${LINE} =~ ${regex["apt"]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}

				install_package "$PACKAGE"
            elif [[ ${LINE} =~ ${regex["snap"]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}
				ARGUMENTS=${BASH_REMATCH[2]}

				install_snap_package "$PACKAGE" "$ARGUMENTS"
			elif [[ ${LINE} =~ ${regex["umake"]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}
				CATEGORY=${BASH_REMATCH[2]}
				LANG=${BASH_REMATCH[3]}

				install_umake_package "$PACKAGE" "$CATEGORY" "$LANG"
            elif [[ ${LINE} =~ ${regex["deb"]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}
                URL=${BASH_REMATCH[2]}
                FILE_NAME=${BASH_REMATCH[3]}

                install_gdebi "$URL" "$FILE_NAME" "$PACKAGE"
            elif [[ ${LINE} =~ ${regex["gpg_dearmor"]} ]]; then
                FILE_NAME=${BASH_REMATCH[1]}
                URL=${BASH_REMATCH[2]}

                add_gpg_key_with_dearmor "$URL" "$FILE_NAME" && \
					sudo apt-get update &> /dev/null
            elif [[ ${LINE} =~ ${regex["gpg"]} ]]; then
                URL=${BASH_REMATCH[1]}

                add_key "$URL" && \
					sudo apt-get update &> /dev/null
            elif [[ ${LINE} =~ ${regex["source"]} ]]; then
                FILE_NAME=${BASH_REMATCH[1]}
                DATA=${BASH_REMATCH[2]}

                add_to_source_list "$DATA" "$FILE_NAME"
            elif [[ ${LINE} =~ ${regex["remove"]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}

                remove_package "$PACKAGE"
            elif [[ ${LINE} =~ ${regex["remove_system"]} ]]; then
                PACKAGE=${BASH_REMATCH[1]}

                remove_system_package "$PACKAGE"
            fi
        done
    fi

}
