# Homebrew Module

Homebrew package manager utilities for macOS and Linux.

## Platform Support

- ✅ macOS (Darwin) - `/opt/homebrew` or `/usr/local`
- ✅ Linux - `/home/linuxbrew/.linuxbrew`

## Dependencies

- curl
- Homebrew (functions will check/initialize)
- python3 (optional, for `brew.py` script)

## Functions

### `get_brew_default_path()`
Get the default Homebrew installation path for the current platform.

**Returns:** Homebrew path string

**Usage:**
```bash
BREW_PATH=$(get_brew_default_path)
echo "Homebrew installed at: $BREW_PATH"
```

---

### `initialize_brew()`
Manually initialize Homebrew if not already in PATH. Sets up environment and adds to PATH.

**Usage:**
```bash
initialize_brew
brew --version
```

---

### `is_brew_installed()`
Check if Homebrew is installed on the system.

**Returns:** 0 if installed, 1 otherwise

**Usage:**
```bash
if is_brew_installed; then
    echo "Homebrew is available"
fi
```

---

### `brew_cleanup()`
Remove older versions of installed formulas.

**Usage:**
```bash
brew_cleanup
```

---

### `brew_bundle_install(options...)`
Install packages from a Brewfile.

**Options:**
- `-f, --file <path>` - Path to Brewfile (required)
- `-p, --python3` - Use Python script instead of `brew bundle`
- `-h, --help` - Display help

**Usage:**
```bash
brew_bundle_install -f "Brewfile"
brew_bundle_install -f "$HOME/.config/Brewfile" -p
```

**Note:** The Python option (`-p`) uses `brew.py` for advanced Brewfile processing.

---

## Brewfile Format

Brewfile follows standard Homebrew Bundle syntax:

```ruby
# Taps
tap "homebrew/cask"
tap "homebrew/cask-fonts"

# Packages
brew "git"
brew "wget"
brew "node"

# Casks (macOS only)
cask "visual-studio-code"
cask "docker"

# Mac App Store apps (macOS only)
mas "Xcode", id: 497799835
```

## Examples

### Basic Brewfile Installation

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

if ! is_brew_installed; then
    error "Homebrew not installed"
    error "Install from: https://brew.sh"
    exit 1
fi

bot "Installing packages from Brewfile"
brew_bundle_install -f "Brewfile"

success "All packages installed"
brew_cleanup
```

### Conditional Installation

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

if is_macos; then
    if is_brew_installed; then
        action "Updating Homebrew"
        execute "brew update" "Updating package lists"
        
        action "Installing from Brewfile"
        brew_bundle_install -f "$HOME/.config/Brewfile"
        
        action "Cleaning up"
        brew_cleanup
        
        ok "Homebrew packages up to date"
    else
        warn "Homebrew not installed"
    fi
fi
```

### Using Python Script

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

# Use Python script for advanced processing
brew_bundle_install -f "Brewfile.extended" -p
```

## Notes

- The module automatically initializes Homebrew if found but not in PATH
- `brew_bundle_install` accepts standard Brewfile format
- Python option provides alternative installation method via `brew.py`
- Functions handle both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`) macOS installations
