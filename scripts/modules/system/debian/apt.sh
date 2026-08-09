#!/bin/bash

# shellcheck disable=SC2086
# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# APT functions

apt::add_key() {

    wget -qO - "$1" | sudo apt-key add - &> /dev/null
    #     │└─ write output to file
    #     └─ don't show output

}

apt::add_ppa() {

    sudo add-apt-repository -y ppa:"$1" &> /dev/null \
        && sudo apt-get update --fix-missing &> /dev/null

}

apt::add_gpg_key_with_dearmor() {

    sudo curl -s "$1" | gpg --dearmor > "$2" \
        && sudo mv "$2" /etc/apt/trusted.gpg.d/"$2"

}

apt::add_to_source_list() {


    if ! [[ -e "/etc/apt/sources.list.d/$2" ]]; then
        sudo sh -c "printf 'deb $1' >> '/etc/apt/sources.list.d/$2'" \
            && sudo apt-get update --fix-missing &> /dev/null
    fi

}

apt::auto_remove() {

    # Remove packages that were automatically installed to satisfy
    # dependencies for other packages and are no longer needed.

    sudo apt-get autoremove -qqy

}

apt::apt_update() {

    # Resynchronize the package index files.

    sudo apt-get update

}

apt::apt_upgrade() {

    # Install the newest versions of all packages installed.

	sudo apt-get upgrade -y

}

apt::package_is_installed() {

    dpkg -s "$1" &> /dev/null

}

apt::snap_is_installed() {

    snap list | grep "$1" &> /dev/null

}

apt::umake_is_installed() {

	[[ -d "$HOME/.local/share/umake/$2/$1" ]]

}

apt::remove_system_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    sudo apt-get remove "$PACKAGE" -qqy \
            && sudo apt-get purge "$PACKAGE" -qqy \
            && sudo apt-get autoremove -qqy \
            && sudo apt-get clean

}

apt::remove_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if package_is_installed "$PACKAGE"; then
        sudo apt-get remove "$PACKAGE" -qqy \
                && sudo apt-get purge "$PACKAGE" -qqy \
                && sudo apt-get autoremove -qqy \
                && sudo apt-get clean
    fi

}

apt::upgrade_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if package_is_installed "$PACKAGE"; then
		sudo apt-get install --only-upgrade -qqy "$PACKAGE"
    fi

}

apt::install_package() {

    declare -r PACKAGE="$1"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! package_is_installed "$PACKAGE"; then
        sudo apt-get install --allow-unauthenticated -qqy "$PACKAGE"
    #                            suppress output ─┘│
    #  assume "yes" as the answer to all prompts ──┘
    fi

}

apt::install_snap_package() {

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

apt::install_umake_package() {

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
apt::install_gdebi() {

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
apt::install_deb() {

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

apt::apt_install_from_file() {

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

apt::apt_remove_from_file() {

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

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Inverse of apt_install_from_file: removes everything declared in the
    # given file. The forward-only directives `remove` and `remove_system`
    # are deliberately ignored (running them on uninstall would re-execute
    # forward state changes).

    if [[ ! -e "$FILE_PATH" ]]; then
        return 0
    fi

    cat < "$FILE_PATH" | while read -r LINE; do
        if [[ ${LINE} =~ ${regex["comment"]} ]]; then
            continue
        elif [[ ${LINE} =~ ${regex["ppa"]} ]]; then
            PPA=${BASH_REMATCH[1]}

            sudo add-apt-repository --remove -y ppa:"$PPA" &> /dev/null
        elif [[ ${LINE} =~ ${regex["apt"]} ]]; then
            PACKAGE=${BASH_REMATCH[1]}

            remove_package "$PACKAGE"
        elif [[ ${LINE} =~ ${regex["snap"]} ]]; then
            PACKAGE=${BASH_REMATCH[1]}

            if snap_is_installed "$PACKAGE"; then
                sudo snap remove "$PACKAGE" &> /dev/null
            fi
        elif [[ ${LINE} =~ ${regex["umake"]} ]]; then
            # umake state isn't tracked symmetrically — skip with a notice.
            print_warning "umake-managed package skipped on uninstall (manual cleanup required)"
        elif [[ ${LINE} =~ ${regex["deb"]} ]]; then
            PACKAGE=${BASH_REMATCH[1]}

            remove_package "$PACKAGE"
        elif [[ ${LINE} =~ ${regex["gpg_dearmor"]} ]]; then
            FILE_NAME=${BASH_REMATCH[1]}

            sudo rm -f "/etc/apt/trusted.gpg.d/$FILE_NAME"
        elif [[ ${LINE} =~ ${regex["gpg"]} ]]; then
            # apt-key removal requires the key id, which we don't store —
            # leave the key in place. Removing keys without the id risks
            # breaking other repos that share the same keyring.
            print_warning "apt-key entry left in place (key id not tracked in packages file)"
        elif [[ ${LINE} =~ ${regex["source"]} ]]; then
            FILE_NAME=${BASH_REMATCH[1]}

            sudo rm -f "/etc/apt/sources.list.d/$FILE_NAME"
        fi
    done

    sudo apt-get autoremove -qqy &> /dev/null
    sudo apt-get update &> /dev/null

}

apt::scan_pkg_for_virus() {

	declare -r FILE_PATH="$1"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Check if clamscan is installed

	if ! package_is_installed "clamav"; then
		install_package "clamav"
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Update virus database if it's older than 7 days

	if [[ ! -e "/var/lib/clamav/daily.cvd" ]] || \
		[[ "$(find "/var/lib/clamav/daily.cvd" -mtime +7)" ]]; then
		sudo freshclam
	fi
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Scan provided package for viruses

	if [[ -e "$FILE_PATH" ]]; then
		clamscan --bell -i -r "$FILE_PATH"
	fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

add_key() { apt::add_key "$@"; }
add_ppa() { apt::add_ppa "$@"; }
add_gpg_key_with_dearmor() { apt::add_gpg_key_with_dearmor "$@"; }
add_to_source_list() { apt::add_to_source_list "$@"; }
auto_remove() { apt::auto_remove "$@"; }
apt_update() { apt::apt_update "$@"; }
apt_upgrade() { apt::apt_upgrade "$@"; }
package_is_installed() { apt::package_is_installed "$@"; }
snap_is_installed() { apt::snap_is_installed "$@"; }
umake_is_installed() { apt::umake_is_installed "$@"; }
remove_system_package() { apt::remove_system_package "$@"; }
remove_package() { apt::remove_package "$@"; }
upgrade_package() { apt::upgrade_package "$@"; }
install_package() { apt::install_package "$@"; }
install_snap_package() { apt::install_snap_package "$@"; }
install_umake_package() { apt::install_umake_package "$@"; }
install_gdebi() { apt::install_gdebi "$@"; }
install_deb() { apt::install_deb "$@"; }
apt_install_from_file() { apt::apt_install_from_file "$@"; }
apt_remove_from_file() { apt::apt_remove_from_file "$@"; }
scan_pkg_for_virus() { apt::scan_pkg_for_virus "$@"; }
