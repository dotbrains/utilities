#!/bin/bash

# shellcheck disable=SC2086
# shellcheck source=/dev/null

smu::import base

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Pacman functions for Arch Linux

pacman::pacman_update() {

	# Synchronize the package databases.

	sudo pacman -Sy

}

pacman::pacman_upgrade() {

	# Upgrade all packages that are out of date.

	sudo pacman -Syu --noconfirm

}

pacman::package_is_installed() {

	pacman -Qi "$1" &> /dev/null

}

pacman::aur_helper_is_installed() {

	command -v "$1" &> /dev/null

}

pacman::auto_remove() {

	# Remove packages that were installed as dependencies
	# and are no longer required by any package.

	local orphans
	orphans=$(pacman -Qdtq)

	if [[ -n "$orphans" ]]; then
		echo "$orphans" | sudo pacman -Rns --noconfirm -
	fi

}

pacman::remove_package() {

	declare -r PACKAGE="$1"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	if package_is_installed "$PACKAGE"; then
		sudo pacman -Rns --noconfirm "$PACKAGE"
	fi

}

pacman::install_package() {

	declare -r PACKAGE="$1"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	if ! package_is_installed "$PACKAGE"; then
		sudo pacman -S --noconfirm "$PACKAGE"
	fi

}

pacman::install_aur_package() {

	declare -r PACKAGE="$1"
	declare -r AUR_HELPER="${2:-yay}" # Default to yay if not specified

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Ensure AUR helper is installed
	if ! aur_helper_is_installed "$AUR_HELPER"; then
		echo "AUR helper '$AUR_HELPER' not found. Please install it first."
		return 1
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	if ! package_is_installed "$PACKAGE"; then
		"$AUR_HELPER" -S --noconfirm "$PACKAGE"
	fi

}

pacman::pacman_install_from_file() {

	declare -r FILE_PATH="$1"

	declare -A regex
	regex["comment"]='^#(.*)'
	regex["pacman"]='pacman "(.*)"'
	regex["aur"]='aur "(.*)"( \[helper: "(.*)"\])?'
	regex["remove"]='remove "(.*)"'

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Install package(s)

	if [[ -e "$FILE_PATH" ]]; then

		# Update system prior to installing packages
		pacman_update
		pacman_upgrade

		cat < "$FILE_PATH" | while read -r LINE; do
			if [[ ${LINE} =~ ${regex["comment"]} ]]; then
				continue
			elif [[ ${LINE} =~ ${regex["pacman"]} ]]; then
				PACKAGE=${BASH_REMATCH[1]}

				install_package "$PACKAGE"
			elif [[ ${LINE} =~ ${regex["aur"]} ]]; then
				PACKAGE=${BASH_REMATCH[1]}
				AUR_HELPER=${BASH_REMATCH[3]:-yay}

				install_aur_package "$PACKAGE" "$AUR_HELPER"
			elif [[ ${LINE} =~ ${regex["remove"]} ]]; then
				PACKAGE=${BASH_REMATCH[1]}

				remove_package "$PACKAGE"
			fi
		done

	fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Backwards-compatible aliases (pre-1.3.0 unnamespaced names).
# New code should call the namespaced functions above.

pacman_update() { pacman::pacman_update "$@"; }
pacman_upgrade() { pacman::pacman_upgrade "$@"; }
package_is_installed() { pacman::package_is_installed "$@"; }
aur_helper_is_installed() { pacman::aur_helper_is_installed "$@"; }
auto_remove() { pacman::auto_remove "$@"; }
remove_package() { pacman::remove_package "$@"; }
install_package() { pacman::install_package "$@"; }
install_aur_package() { pacman::install_aur_package "$@"; }
pacman_install_from_file() { pacman::pacman_install_from_file "$@"; }
