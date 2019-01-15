#!/bin/bash

# shellcheck source=/dev/null

source_file_from_utilities() {

	source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/scripts/$1")"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

	# Base
	source_file_from_utilities "base/base.sh"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# System
	source_file_from_utilities "modulessystem/system.sh"
	source_file_from_utilities "modules/system/network.sh"

	# APT (Only required for 'linux'-based systems)
	if [ "$(read_os_name)" == "linux" ] && grep -qEi 'debian|buntu|mint' "/etc/*release"; then
		source_file_from_utilities "modules/system/debian/apt.sh"
	fi

	# Homebrew
	source_file_from_utilities "modules/homebrew/brew.sh"

	# Git
	source_file_from_utilities "modules/git/git.sh"

	# Fish
	source_file_from_utilities "modules/fish/fish.sh"
	source_file_from_utilities "modules/fish/omf.sh"
	source_file_from_utilities "modules/fish/fisher.sh"

	# Java
	source_file_from_utilities "modules/java/sdkman.sh"

	# Go
	source_file_from_utilities "modules/go/go.sh"

	# Rust
	source_file_from_utilities "modules/rust/cargo.sh"

	# Python
	source_file_from_utilities "modules/python/pip.sh"
	source_file_from_utilities "modules/python/pip3.sh"
	source_file_from_utilities "modules/python/pyenv.sh"

	# Node
	source_file_from_utilities "modules/node/npm.sh"

	# Ruby
	source_file_from_utilities "modules/ruby/gem.sh"

}

main
