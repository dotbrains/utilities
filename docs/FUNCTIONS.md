# Function Reference

Complete alphabetical index of all available functions across all modules.

## Base Module

| Function | Description | Module |
|----------|-------------|---------|
| `action(message)` | Print action message | [base](scripts/base/README.md) |
| `answer_is_yes()` | Check if user response is yes | [base](scripts/base/README.md) |
| `ask(question)` | Prompt user for input | [base](scripts/base/README.md) |
| `ask_for_confirmation(question)` | Prompt for yes/no confirmation | [base](scripts/base/README.md) |
| `ask_for_sudo()` | Request and maintain sudo privileges | [base](scripts/base/README.md) |
| `bot(message)` | Print message with bot emoji | [base](scripts/base/README.md) |
| `cancelled(message)` | Print cancellation message | [base](scripts/base/README.md) |
| `error(message)` | Print error message | [base](scripts/base/README.md) |
| `execute(command [message])` | Execute command with spinner | [base](scripts/base/README.md) |
| `get_answer()` | Get last user input | [base](scripts/base/README.md) |
| `kill_all_subprocesses()` | Kill all background jobs | [base](scripts/base/README.md) |
| `ok(message)` | Print success message | [base](scripts/base/README.md) |
| `print_error(message [details])` | Print formatted error | [base](scripts/base/README.md) |
| `print_error_stream()` | Print errors from stdin | [base](scripts/base/README.md) |
| `print_in_color(text color)` | Print colored text | [base](scripts/base/README.md) |
| `print_in_green(text)` | Print green text | [base](scripts/base/README.md) |
| `print_in_purple(text)` | Print purple text | [base](scripts/base/README.md) |
| `print_in_red(text)` | Print red text | [base](scripts/base/README.md) |
| `print_in_yellow(text)` | Print yellow text | [base](scripts/base/README.md) |
| `print_question(message)` | Print question prompt | [base](scripts/base/README.md) |
| `print_result(exit_code message)` | Print result based on exit code | [base](scripts/base/README.md) |
| `print_success(message)` | Print formatted success | [base](scripts/base/README.md) |
| `print_warning(message)` | Print formatted warning | [base](scripts/base/README.md) |
| `running(message)` | Print running message | [base](scripts/base/README.md) |
| `show_spinner(pid command message)` | Display animated spinner | [base](scripts/base/README.md) |
| `skip_questions(args...)` | Check for non-interactive mode | [base](scripts/base/README.md) |
| `success(message)` | Print success message | [base](scripts/base/README.md) |
| `terminal(command)` | Open new Terminal window (macOS) | [base](scripts/base/README.md) |
| `warn(message)` | Print warning message | [base](scripts/base/README.md) |

## System Module

| Function | Description | Module |
|----------|-------------|---------|
| `add_cron_job(frequency command)` | Add cron job | [system](scripts/modules/system/README.md) |
| `add_to_path_if_not_exists(path)` | Add to PATH if missing | [system](scripts/modules/system/README.md) |
| `add_value_and_uncomment(file key value)` | Add value and uncomment line | [system](scripts/modules/system/README.md) |
| `append_to_bashrc(text [skip_newline])` | Append to bashrc/bash.local | [system](scripts/modules/system/README.md) |
| `cmd_exists(command)` | Check if command exists | [system](scripts/modules/system/README.md) |
| `extract(file)` | Extract compressed file | [system](scripts/modules/system/README.md) |
| `get_os()` | Get normalized OS name | [system](scripts/modules/system/README.md) |
| `get_os_version()` | Get OS version | [system](scripts/modules/system/README.md) |
| `is_debian()` | Check if Debian/Ubuntu | [system](scripts/modules/system/README.md) |
| `is_macos()` | Check if macOS | [system](scripts/modules/system/README.md) |
| `is_supported_version(current required)` | Compare versions | [system](scripts/modules/system/README.md) |
| `jq_replace(file field value)` | Replace JSON field | [system](scripts/modules/system/README.md) |
| `mkd(directory)` | Create directory | [system](scripts/modules/system/README.md) |
| `read_kernel_name()` | Get kernel name | [system](scripts/modules/system/README.md) |
| `read_os_name()` | Get OS identifier | [system](scripts/modules/system/README.md) |
| `read_os_version()` | Get OS version | [system](scripts/modules/system/README.md) |
| `replace_str(file key pattern replacement)` | Replace pattern in file | [system](scripts/modules/system/README.md) |
| `set_default_shell(executable_path)` | Set default shell | [system](scripts/modules/system/README.md) |
| `set_trap(signal command)` | Set signal trap | [system](scripts/modules/system/README.md) |
| `symlink(source target)` | Create symlink | [system](scripts/modules/system/README.md) |
| `uncomment_str(file key)` | Uncomment lines | [system](scripts/modules/system/README.md) |

## Git Module

| Function | Description | Module |
|----------|-------------|---------|
| `clone_git_repo_in(target url)` | Clone git repository | [git](scripts/modules/git/README.md) |
| `is_git_repository()` | Check if in git repo | [git](scripts/modules/git/README.md) |

## Homebrew Module

| Function | Description | Module |
|----------|-------------|---------|
| `brew_bundle_install(options...)` | Install from Brewfile | [homebrew](scripts/modules/homebrew/README.md) |
| `brew_cleanup()` | Clean up old formulas | [homebrew](scripts/modules/homebrew/README.md) |
| `get_brew_default_path()` | Get Homebrew path | [homebrew](scripts/modules/homebrew/README.md) |
| `initialize_brew()` | Initialize Homebrew | [homebrew](scripts/modules/homebrew/README.md) |
| `is_brew_installed()` | Check if Homebrew installed | [homebrew](scripts/modules/homebrew/README.md) |

## Python Module

| Function | Description | Module |
|----------|-------------|---------|
| `is_pip_installed()` | Check if pip installed | [python](scripts/modules/python/README.md) |
| `is_pip_pkg_installed(package)` | Check if pip package installed | [python](scripts/modules/python/README.md) |
| `is_pip3_installed()` | Check if pip3 installed | [python](scripts/modules/python/README.md) |
| `is_pip3_pkg_installed(package)` | Check if pip3 package installed | [python](scripts/modules/python/README.md) |
| `is_pyenv_installed()` | Check if pyenv installed | [python](scripts/modules/python/README.md) |
| `pip_install(package)` | Install pip package | [python](scripts/modules/python/README.md) |
| `pip_install_from_file(file_path)` | Install from requirements | [python](scripts/modules/python/README.md) |
| `pip3_install(package)` | Install pip3 package | [python](scripts/modules/python/README.md) |
| `pip3_install_from_file(file_path)` | Install from requirements | [python](scripts/modules/python/README.md) |
| `pyenv_install(version)` | Install Python version | [python](scripts/modules/python/README.md) |

## Node Module

| Function | Description | Module |
|----------|-------------|---------|
| `is_npm_installed()` | Check if npm installed | [node](scripts/modules/node/README.md) |
| `is_npm_pkg_installed(package)` | Check if npm package installed | [node](scripts/modules/node/README.md) |
| `is_npx_installed()` | Check if npx installed | [node](scripts/modules/node/README.md) |
| `is_yarn_pkg_installed(package)` | Check if yarn package installed | [node](scripts/modules/node/README.md) |
| `npm_install(package)` | Install npm package globally | [node](scripts/modules/node/README.md) |
| `npm_install_from_file(file_path)` | Install from package list | [node](scripts/modules/node/README.md) |
| `npx_install(package)` | Install via yarn/npx | [node](scripts/modules/node/README.md) |
| `sudo_npm_install(package)` | Install npm package with sudo | [node](scripts/modules/node/README.md) |

## Ruby Module

| Function | Description | Module |
|----------|-------------|---------|
| `gem_install(gem)` | Install Ruby gem | [ruby](scripts/modules/ruby/README.md) |
| `is_ruby_installed()` | Check if Ruby installed | [ruby](scripts/modules/ruby/README.md) |

## Fish Module

| Function | Description | Module |
|----------|-------------|---------|
| `fish_cmd_exists(command)` | Check if command exists in Fish | [fish](scripts/modules/fish/README.md) |
| `fisher_install()` | Install Fisher | [fish](scripts/modules/fish/README.md) |
| `fisher_install_package(package)` | Install Fisher plugin | [fish](scripts/modules/fish/README.md) |
| `fisher_package_is_installed(package)` | Check if Fisher plugin installed | [fish](scripts/modules/fish/README.md) |
| `is_fisher_installed()` | Check if Fisher installed | [fish](scripts/modules/fish/README.md) |
| `is_omf_installed()` | Check if OMF installed | [fish](scripts/modules/fish/README.md) |
| `omf_install()` | Install Oh My Fish | [fish](scripts/modules/fish/README.md) |
| `omf_install_package(package)` | Install OMF package | [fish](scripts/modules/fish/README.md) |
| `omf_package_is_installed(package)` | Check if OMF package installed | [fish](scripts/modules/fish/README.md) |

## Rust Module

| Function | Description | Module |
|----------|-------------|---------|
| `cargo_install(crate)` | Install Rust crate | [rust](scripts/modules/rust/README.md) |
| `is_cargo_installed()` | Check if Cargo installed | [rust](scripts/modules/rust/README.md) |

## Go Module

| Function | Description | Module |
|----------|-------------|---------|
| `go_install(package)` | Install Go package | [go](scripts/modules/go/README.md) |
| `is_go_installed()` | Check if Go installed | [go](scripts/modules/go/README.md) |

## Java Module

| Function | Description | Module |
|----------|-------------|---------|
| `is_sdkman_installed()` | Check if SDKMAN installed | [java](scripts/modules/java/README.md) |
| `sdk_install(candidate [version])` | Install SDK via SDKMAN | [java](scripts/modules/java/README.md) |
| `sdkman_install()` | Install SDKMAN | [java](scripts/modules/java/README.md) |

## Gofish Module

| Function | Description | Module |
|----------|-------------|---------|
| `gofish_install()` | Install Gofish | [gofish](scripts/modules/gofish/README.md) |
| `gofish_pkg_install(package)` | Install Gofish package | [gofish](scripts/modules/gofish/README.md) |
| `is_gofish_installed()` | Check if Gofish installed | [gofish](scripts/modules/gofish/README.md) |
| `is_gofish_pkg_installed(package)` | Check if Gofish package installed | [gofish](scripts/modules/gofish/README.md) |

## MacPorts Module

| Function | Description | Module |
|----------|-------------|---------|
| `is_macports_installed()` | Check if MacPorts installed | [macports](scripts/modules/macports/README.md) |
| `is_macports_port_installed(port)` | Check if port installed | [macports](scripts/modules/macports/README.md) |
| `macports_install(port)` | Install MacPorts port | [macports](scripts/modules/macports/README.md) |

## Quick Search Tips

- Use your browser's find function (Ctrl/Cmd+F) to search for specific functions
- Functions are organized alphabetically within each module
- Click module links for detailed documentation and usage examples
- Most functions follow naming pattern: `<tool>_<action>` or `is_<tool>_installed`

## Common Patterns

### Check if tool is installed
```bash
if is_<tool>_installed; then
    # Tool-specific operations
fi
```

### Install packages
```bash
<tool>_install "package-name"
<tool>_install_from_file "path/to/file"
```

### OS detection
```bash
if is_macos; then
    # macOS-specific code
elif is_debian; then
    # Debian/Ubuntu-specific code
fi
```
