# Debian/Ubuntu Module

Package management and system utilities for Debian-based Linux distributions (Debian, Ubuntu, Kali Linux).

## Functions

### Package Management

#### `apt_update()`

Resynchronize the package index files from sources.

```bash
apt_update
```

#### `apt_upgrade()`

Install the newest versions of all packages currently installed.

```bash
apt_upgrade
```

#### `package_is_installed(package)`

Check if a package is installed via APT.

```bash
if package_is_installed "vim"; then
    echo "vim is installed"
fi
```

#### `install_package(package)`

Install a package using APT if it's not already installed.

```bash
install_package "git"
install_package "build-essential"
```

#### `remove_package(package)`

Remove a package if it's installed, including purging configuration files.

```bash
remove_package "apache2"
```

#### `remove_system_package(package)`

Force remove a system package regardless of installation status.

```bash
remove_system_package "snapd"
```

**Warning:** Use with caution as this doesn't check if the package is installed.

#### `upgrade_package(package)`

Upgrade a specific package to the latest version.

```bash
upgrade_package "nodejs"
```

#### `auto_remove()`

Remove packages that were automatically installed as dependencies and are no longer needed.

```bash
auto_remove
```

### Repository Management

#### `add_ppa(ppa_name)`

Add a Personal Package Archive (PPA) repository.

```bash
add_ppa "graphics-drivers/ppa"
add_ppa "deadsnakes/ppa"
```

**Note:** Ubuntu/Mint only. Automatically updates package lists after adding.

#### `add_key(url)`

Add a GPG key from a URL for package verification.

```bash
add_key "https://example.com/repository-key.gpg"
```

#### `add_gpg_key_with_dearmor(url, filename)`

Add a GPG key with dearmor to `/etc/apt/trusted.gpg.d/`.

```bash
add_gpg_key_with_dearmor "https://example.com/key.asc" "example.gpg"
```

#### `add_to_source_list(deb_line, filename)`

Add a repository to `/etc/apt/sources.list.d/`.

```bash
add_to_source_list "https://example.com/debian stable main" "example.list"
```

### Snap Packages

#### `snap_is_installed(package)`

Check if a Snap package is installed.

```bash
if snap_is_installed "spotify"; then
    echo "Spotify is installed"
fi
```

#### `install_snap_package(package [arguments])`

Install a Snap package with optional arguments.

```bash
install_snap_package "spotify"
install_snap_package "code" "--classic"
install_snap_package "kubectl" "--classic"
```

**Note:** Automatically installs and configures snapd if not present.

### Ubuntu Make

#### `umake_is_installed(package, category)`

Check if an Ubuntu Make package is installed.

```bash
if umake_is_installed "pycharm" "ide"; then
    echo "PyCharm is installed"
fi
```

#### `install_umake_package(package, category, lang)`

Install development tools using Ubuntu Make.

```bash
install_umake_package "pycharm" "ide" "en"
install_umake_package "android-studio" "android" "en"
```

### .deb Package Installation

#### `install_deb(url, filename, package)`

Download and install a `.deb` package from a URL.

```bash
install_deb "https://example.com/app.deb" "app.deb" "app-name"
```

**Process:**

1. Downloads to `~/Downloads/`
2. Installs with `dpkg -i`
3. Fixes dependencies with `apt-get install -f`
4. Cleans up

#### `install_gdebi(url, filename, package)`

Download and install a `.deb` package using gdebi (handles dependencies better).

```bash
install_gdebi "https://example.com/app.deb" "app.deb" "app-name"
```

### Batch Installation

#### `apt_install_from_file(file_path)`

Install multiple packages from a file with various directives.

**File format:**

```text
# Comments are supported
apt "git"
apt "build-essential"
ppa "graphics-drivers/ppa"
snap "spotify" [args: "--classic"]
umake "pycharm" [args: "ide", "en"]
deb "vscode" [args: "https://example.com/vscode.deb", "vscode.deb"]
gpg_dearmor "docker.gpg" [args: "https://example.com/docker.asc"]
gpg "https://example.com/key.gpg" [args: ""]
source "example.list" [args: "https://example.com/debian stable main"]
remove "nano"
remove_system "snapd"
```

**Usage:**

```bash
apt_install_from_file "packages.txt"
```

**Supported directives:**

- `apt "package"` - Install from APT
- `ppa "ppa-name"` - Add PPA repository
- `snap "package" [args: "arguments"]` - Install Snap package
- `umake "package" [args: "category", "language"]` - Install with Ubuntu Make
- `deb "package" [args: "url", "filename"]` - Install .deb from URL
- `gpg_dearmor "filename" [args: "url"]` - Add GPG key with dearmor
- `gpg "url" [args: ""]` - Add GPG key
- `source "filename" [args: "deb-line"]` - Add to sources.list.d
- `remove "package"` - Remove package
- `remove_system "package"` - Force remove system package
- `# comment` - Comments (ignored)

### Security

#### `scan_pkg_for_virus(file_path)`

Scan a package file for viruses using ClamAV.

```bash
scan_pkg_for_virus "~/Downloads/suspicious.deb"
```

**Features:**

- Auto-installs ClamAV if not present
- Updates virus database if older than 7 days
- Scans recursively with alerts

## System Utilities

### `fix_broken_symlinks_in(directory)`

Find and fix broken symbolic links in a directory.

```bash
fix_broken_symlinks_in "/usr/local/bin"
```

**Note:** Requires the `symlinks` package (auto-installed if needed).

## Example Usage

### Basic Package Management

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/smeltery/utilities/master/utilities.sh")"

if is_debian; then
    action "Updating system"
    apt_update
    apt_upgrade
    
    # Install packages
    install_package "git"
    install_package "vim"
    install_package "curl"
    
    # Clean up
    auto_remove
    
    success "System updated"
fi
```

### Advanced Installation

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/smeltery/utilities/master/utilities.sh")"

if is_debian; then
    bot "Setting up development environment"
    
    # Update system
    action "Updating system"
    apt_update
    apt_upgrade
    
    # Add repositories
    action "Adding repositories"
    add_ppa "deadsnakes/ppa"
    add_ppa "git-core/ppa"
    
    # Install packages
    action "Installing packages"
    install_package "python3.11"
    install_package "git"
    install_package "build-essential"
    
    # Install Snap packages
    action "Installing Snap packages"
    install_snap_package "code" "--classic"
    install_snap_package "spotify"
    
    # Install from .deb
    action "Installing VS Code"
    install_gdebi \
        "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" \
        "vscode.deb" \
        "code"
    
    # Clean up
    auto_remove
    
    ok "Development environment ready!"
fi
```

### Batch Installation from File

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/smeltery/utilities/master/utilities.sh")"

if is_debian; then
    bot "Installing packages from file"
    
    # Install from packages.txt
    apt_install_from_file "packages.txt"
    
    ok "All packages installed!"
fi
```

## Dependencies

- `apt-get` / `apt` - Package manager (included with Debian/Ubuntu)
- `dpkg` - Package management (included with Debian/Ubuntu)
- `add-apt-repository` - PPA management (install `software-properties-common`)
- `snapd` - For Snap packages (auto-installed if needed)
- `gdebi` - For .deb installation (auto-installed if needed)
- `symlinks` - For fixing broken symlinks (auto-installed if needed)
- `clamav` - For virus scanning (auto-installed if needed)

## Notes

- All package installation functions require sudo privileges
- The `-qqy` flags are used for quiet, non-interactive installation
- Failed installations are automatically cleaned up
- Virus database updates run automatically if older than 7 days
- Ubuntu Make is only available on Ubuntu-based distributions

## Platform Support

- ✅ Ubuntu (all versions)
- ✅ Debian (all versions)
- ✅ Kali Linux
- ✅ Linux Mint
- ⚠️ Other Debian derivatives (most functions should work)
