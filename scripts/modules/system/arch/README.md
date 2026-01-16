# Arch Linux Module

Package management and system utilities for Arch Linux.

## Functions

### Package Management

#### `pacman_update()`

Synchronize the package databases.

```bash
pacman_update
```

#### `pacman_upgrade()`

Upgrade all packages that are out of date.

```bash
pacman_upgrade
```

#### `package_is_installed(package)`

Check if a package is installed.

```bash
if package_is_installed "vim"; then
    echo "vim is installed"
fi
```

#### `install_package(package)`

Install a package using pacman if it's not already installed.

```bash
install_package "git"
install_package "base-devel"
```

#### `remove_package(package)`

Remove a package and its dependencies.

```bash
remove_package "firefox"
```

#### `auto_remove()`

Remove orphaned packages (packages that were installed as dependencies and are no longer needed).

```bash
auto_remove
```

### AUR Support

#### `aur_helper_is_installed(helper)`

Check if an AUR helper is installed.

```bash
if aur_helper_is_installed "yay"; then
    echo "yay is installed"
fi
```

#### `install_aur_package(package [helper])`

Install a package from the AUR using an AUR helper (default: yay).

```bash
# Using default helper (yay)
install_aur_package "google-chrome"

# Using specific helper
install_aur_package "spotify" "paru"
```

**Note:** The AUR helper must be installed before using this function.

### Batch Installation

#### `pacman_install_from_file(file_path)`

Install multiple packages from a file.

**File format:**

```
# Comments are supported
pacman "git"
pacman "base-devel"
pacman "vim"
aur "google-chrome"
aur "spotify" [helper: "paru"]
remove "nano"
```

**Usage:**

```bash
pacman_install_from_file "packages.txt"
```

**Supported directives:**
- `pacman "package"` - Install from official repositories
- `aur "package"` - Install from AUR (using yay by default)
- `aur "package" [helper: "helper_name"]` - Install from AUR using specific helper
- `remove "package"` - Remove package
- `# comment` - Comments (ignored)

## System Utilities

#### `fix_broken_symlinks_in(directory)`

Find and fix broken symbolic links in a directory.

```bash
fix_broken_symlinks_in "/usr/local/bin"
```

**Note:** Requires the `symlinks` package.

## Example Usage

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/utilities.sh")"

# Check if running on Arch Linux
if is_arch_linux; then
    action "Detected Arch Linux"
    
    # Update system
    pacman_update
    pacman_upgrade
    
    # Install packages
    install_package "git"
    install_package "vim"
    install_package "base-devel"
    
    # Install AUR packages (if yay is installed)
    if aur_helper_is_installed "yay"; then
        install_aur_package "google-chrome"
        install_aur_package "spotify"
    fi
    
    # Clean up orphans
    auto_remove
    
    success "Arch Linux setup complete"
fi
```

## Dependencies

- `pacman` - Package manager (included with Arch Linux)
- `symlinks` - For `fix_broken_symlinks_in()` (auto-installed if needed)
- AUR helper (`yay`, `paru`, etc.) - For AUR package installation (must be installed manually)

## Notes

- All functions require appropriate permissions (sudo)
- The `--noconfirm` flag is used for non-interactive installation
- AUR helpers must be installed separately before using AUR functions
