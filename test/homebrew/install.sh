install_homebrew() {

    printf "\n" |
        /bin/bash -c \
            "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

}

get_homebrew_git_config_file_path() {

    local path=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if path="$(brew --repository 2>/dev/null)/.git/config"; then
        printf "%s" "$path"
        return 0
    else
        return 1
    fi

}

opt_out_of_analytics() {

    local path=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Try to get the path of the `Homebrew` git config file.

    path="$(get_homebrew_git_config_file_path)" ||
        return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Opt-out of Homebrew's analytics.
    # https://github.com/Homebrew/brew/blob/0c95c60511cc4d85d28f66b58d51d85f8186d941/share/doc/homebrew/Analytics.md#opting-out

    if [[ "$(git config --file="$path" --get homebrew.analyticsdisabled)" != "true" ]]; then
        git config --file="$path" --replace-all homebrew.analyticsdisabled true &>/dev/null
    fi

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    if ! command -v brew &>/dev/null; then
        install_homebrew
        opt_out_of_analytics
    fi

    if command -v brew &>/dev/null; then
        if [[ -d "$(brew --prefix)/bin" ]]; then
            export PATH="$(brew --prefix)/bin:$PATH"
        fi

        if [[ -d "$(brew --prefix)/sbin" ]]; then
            export PATH="$(brew --prefix)/sbin:$PATH"
        fi
    fi

}

main
