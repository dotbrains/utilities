# System Module

System utilities for OS detection, PATH management, file operations, shell configuration, and general system tasks.

## Platform Support

- ✅ macOS (Darwin)
- ✅ Linux (all distributions)

## Dependencies

- bash 3.2+
- Standard Unix utilities (uname, grep, sed, awk)
- sudo (for some operations)

## Functions

### OS Detection

#### `is_macos()`

Check if running on macOS.

**Returns:** 0 if macOS, 1 otherwise

**Usage:**

```bash
if is_macos; then
    echo "Running on macOS"
fi
```

---

#### `is_debian()`

Check if running on Debian-based Linux.

**Returns:** 0 if Debian/Ubuntu, 1 otherwise

---

#### `read_kernel_name()`

Get the kernel name (Darwin, Linux, etc.).

**Returns:** Kernel name string

---

#### `read_os_name()`

Get the OS identifier (macos, ubuntu, kali, etc.).

**Returns:** OS name string

---

#### `read_os_version()`

Get the OS version number.

**Returns:** Version string

---

#### `get_os()`

Get normalized OS name (macos, ubuntu, kali-linux, windows).

**Returns:** OS identifier

**Usage:**

```bash
OS=$(get_os)
if [[ "$OS" == "macos" ]]; then
    # macOS-specific code
fi
```

---

### PATH Management

#### `add_to_path_if_not_exists(path)`

Add directory to PATH if not already present. Works with bash, zsh, and fish shells.

**Parameters:**

- `$1` - Path to add

**Usage:**

```bash
add_to_path_if_not_exists "/usr/local/bin"
add_to_path_if_not_exists "$HOME/.local/bin"
```

---

### File Operations

#### `symlink(source target)`

Create a symlink with interactive overwrite prompt.

**Parameters:**

- `$1` - Source file path
- `$2` - Target symlink path

**Usage:**

```bash
symlink "$HOME/dotfiles/vimrc" "$HOME/.vimrc"
```

---

#### `mkd(directory)`

Create directory if it doesn't exist, with error handling.

**Parameters:**

- `$1` - Directory path to create

**Usage:**

```bash
mkd "$HOME/.config/myapp"
```

---

#### `extract(file)`

Extract any type of compressed file (supports tar, gz, zip, bz2, rar, 7z, etc.).

**Parameters:**

- `$1` - Path to compressed file

**Usage:**

```bash
extract "archive.tar.gz"
extract "package.zip"
```

---

### Shell Configuration

#### `set_default_shell(executable_path)`

Set the default shell for the current user.

**Parameters:**

- `$1` - Path to shell executable

**Usage:**

```bash
set_default_shell "/usr/local/bin/fish"
```

---

#### `append_to_bashrc(text [skip_newline])`

Append text to `~/.bashrc` or `~/.bash.local` if not already present.

**Parameters:**

- `$1` - Text to append
- `$2` - Optional: 1 to skip newline before text

**Usage:**

```bash
append_to_bashrc "export EDITOR=vim"
append_to_bashrc "source ~/.aliases" 1
```

---

### Utility Functions

#### `cmd_exists(command)`

Check if a command exists in PATH.

**Parameters:**

- `$1` - Command name

**Returns:** 0 if exists, 1 otherwise

**Usage:**

```bash
if cmd_exists "git"; then
    echo "Git is installed"
fi
```

---

#### `is_supported_version(current required)`

Compare version numbers to check if current >= required.

**Parameters:**

- `$1` - Current version (e.g., "1.2.3")
- `$2` - Required version (e.g., "1.2.0")

**Returns:** 0 if supported, 1 otherwise

**Usage:**

```bash
if is_supported_version "$(ruby --version)" "2.5.0"; then
    echo "Ruby version is sufficient"
fi
```

---

#### `set_trap(signal command)`

Set a trap for a signal if not already set.

**Parameters:**

- `$1` - Signal name (EXIT, INT, etc.)
- `$2` - Command to execute

**Usage:**

```bash
set_trap EXIT "rm -f /tmp/tempfile"
```

---

### Text Processing

#### `uncomment_str(file key)`

Uncomment lines in a file matching a key.

**Parameters:**

- `$1` - File path
- `$2` - Search key

---

#### `add_value_and_uncomment(file key value)`

Add a value to a key and uncomment the line.

**Parameters:**

- `$1` - File path
- `$2` - Key to search for
- `$3` - Value to add

---

#### `replace_str(file key pattern replacement)`

Replace a pattern in lines matching a key.

**Parameters:**

- `$1` - File path
- `$2` - Key to search for
- `$3` - Pattern to replace
- `$4` - Replacement text

---

#### `jq_replace(file field value)`

Replace a JSON field value using jq (installs jq if needed).

**Parameters:**

- `$1` - JSON file path
- `$2` - Field name
- `$3` - New value

**Usage:**

```bash
jq_replace "config.json" "version" "1.2.3"
```

---

### Cron Jobs

#### `add_cron_job(frequency command)`

Add a cron job if it doesn't already exist.

**Parameters:**

- `$1` - Cron frequency (e.g., "0 \*\* \*\*")
- `$2` - Command to execute

**Usage:**

```bash
add_cron_job "0 2 * * *" "~/scripts/backup.sh"
```

---

## Examples

### Cross-Platform Script

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

OS=$(get_os)
case "$OS" in
    macos)
        bot "Detected macOS"
        ;;
    ubuntu)
        bot "Detected Ubuntu"
        ;;
    *)
        warn "Unknown OS: $OS"
        ;;
esac

# Add custom bin to PATH
add_to_path_if_not_exists "$HOME/bin"

# Ensure git is installed
if ! cmd_exists "git"; then
    error "Git not found"
    exit 1
fi

success "Environment validated"
```

### File Management

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

# Create directory structure
mkd "$HOME/.config/myapp"
mkd "$HOME/.local/share/myapp"

# Create symlinks for config files
symlink "$PWD/config.yml" "$HOME/.config/myapp/config.yml"
symlink "$PWD/aliases.sh" "$HOME/.bash_aliases"

# Extract archive
if [[ -f "data.tar.gz" ]]; then
    extract "data.tar.gz"
fi

ok "Setup complete"
```
