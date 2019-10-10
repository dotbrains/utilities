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
	source_file_from_utilities "modules/system/system.sh"
	source_file_from_utilities "modules/system/network.sh"

	# APT & other system functions (Only required for 'linux'-based systems)
	if uname -a | grep -q "Linux" && grep -qEi 'debian|buntu|kali' /etc/*release; then
		source_file_from_utilities "modules/system/debian/system.sh"
		source_file_from_utilities "modules/system/debian/apt.sh"
	fi

	# System functions (Only required for 'darwin'-based systems)
	if uname -a | grep -q "Darwin"; then
		source_file_from_utilities "modules/system/darwin/system.sh"
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
