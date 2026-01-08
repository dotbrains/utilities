#!/bin/bash

# shellcheck source=/dev/null

# Version
export UTILITIES_VERSION="1.0.0"

# Configuration
UTILITIES_DEBUG="${UTILITIES_DEBUG:-false}"
UTILITIES_MODULES="${UTILITIES_MODULES:-all}"
UTILITIES_CACHE_DIR="${UTILITIES_CACHE_DIR:-}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

source_file_from_utilities() {

	local file="$1"
	local url="https://raw.githubusercontent.com/dotbrains/utilities/master/scripts/$file"
	local cache_file=""
	local content=""
	local curl_exit_code=0

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Debug logging
	if [[ "$UTILITIES_DEBUG" == "true" ]]; then
		echo "[utilities] Loading: $file" >&2
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Use caching if enabled
	if [[ -n "$UTILITIES_CACHE_DIR" ]]; then
		cache_file="$UTILITIES_CACHE_DIR/$file"

		# Create cache directory if it doesn't exist
		if [[ ! -d "$(dirname "$cache_file")" ]]; then
			mkdir -p "$(dirname "$cache_file")" 2>/dev/null || {
				echo "[utilities] ERROR: Failed to create cache directory" >&2
				return 1
			}
		fi

		# Use cached version if it exists and is not empty
		if [[ -f "$cache_file" && -s "$cache_file" ]]; then
			if [[ "$UTILITIES_DEBUG" == "true" ]]; then
				echo "[utilities] Using cached: $cache_file" >&2
			fi
			source "$cache_file"
			return $?
		fi

		# Download with timeout and cache
		if curl -f -s -S --connect-timeout 10 --max-time 30 "$url" -o "$cache_file" 2>/dev/null; then
			# Validate that downloaded file is not empty
			if [[ ! -s "$cache_file" ]]; then
				if [[ "$UTILITIES_DEBUG" == "true" ]]; then
					echo "[utilities] ERROR: Downloaded file is empty: $file" >&2
				fi
				rm -f "$cache_file" 2>/dev/null
				return 1
			fi

			source "$cache_file"
			return $?
		else
			# Clean up failed download
			rm -f "$cache_file" 2>/dev/null
			if [[ "$UTILITIES_DEBUG" == "true" ]]; then
				echo "[utilities] ERROR: Failed to download: $url" >&2
			fi
			return 1
		fi
	fi

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	# Standard remote sourcing (no cache) with timeout and validation
	content="$(curl -f -s -S --connect-timeout 10 --max-time 30 "$url" 2>/dev/null)"
	curl_exit_code=$?

	# Check for curl errors
	if [[ $curl_exit_code -ne 0 ]]; then
		if [[ "$UTILITIES_DEBUG" == "true" ]]; then
			echo "[utilities] ERROR: Failed to fetch $url (exit code: $curl_exit_code)" >&2
		fi
		return 1
	fi

	# Validate content is not empty
	if [[ -z "$content" ]]; then
		if [[ "$UTILITIES_DEBUG" == "true" ]]; then
			echo "[utilities] ERROR: Empty response from: $url" >&2
		fi
		return 1
	fi

	# Source the content
	source /dev/stdin <<<"$content"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Helper function to check if a module should be loaded
should_load_module() {
	local module="$1"

	# Load all modules if UTILITIES_MODULES is "all"
	if [[ "$UTILITIES_MODULES" == "all" ]]; then
		return 0
	fi

	# Check if module is in the comma-separated list
	if [[ ",$UTILITIES_MODULES," == *",$module,"* ]]; then
		return 0
	fi

	return 1
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

		# MacPorts
		source_file_from_utilities "modules/macports/macports.sh"
	fi

	# Homebrew
	if should_load_module "homebrew"; then
		source_file_from_utilities "modules/homebrew/brew.sh"
	fi

	# Gofish
	if should_load_module "gofish"; then
		source_file_from_utilities "modules/gofish/gofish.sh"
	fi

	# Git
	if should_load_module "git"; then
		source_file_from_utilities "modules/git/git.sh"
	fi

	# Fish
	if should_load_module "fish"; then
		source_file_from_utilities "modules/fish/fish.sh"
		source_file_from_utilities "modules/fish/omf.sh"
		source_file_from_utilities "modules/fish/fisher.sh"
	fi

	# Java
	if should_load_module "java"; then
		source_file_from_utilities "modules/java/sdkman.sh"
	fi

	# Go
	if should_load_module "go"; then
		source_file_from_utilities "modules/go/go.sh"
	fi

	# Rust
	if should_load_module "rust"; then
		source_file_from_utilities "modules/rust/cargo.sh"
	fi

	# Python
	if should_load_module "python"; then
		source_file_from_utilities "modules/python/pip.sh"
		source_file_from_utilities "modules/python/pip3.sh"
		source_file_from_utilities "modules/python/pyenv.sh"
	fi

	# Node
	if should_load_module "node"; then
		source_file_from_utilities "modules/node/npm.sh"
	fi

	# Ruby
	if should_load_module "ruby"; then
		source_file_from_utilities "modules/ruby/gem.sh"
	fi

}

main
