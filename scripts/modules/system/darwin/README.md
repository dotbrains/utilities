# Darwin (macOS) Module

System utilities specifically for macOS (Darwin).

## Functions

### Application Installation

#### `install_from_URL(url)`

Download and install macOS applications from a URL. Supports multiple file formats.

**Supported formats:**

- `.dmg` - Disk images
- `.pkg` - Package installers
- `.zip` - Compressed archives containing `.app` or `.dmg` files

```bash
install_from_URL "https://example.com/app.dmg"
install_from_URL "https://example.com/installer.pkg"
install_from_URL "https://example.com/archive.zip"
```

**Process:**

1. Downloads the file to a temporary directory
2. Extracts/mounts the file based on type
3. Copies `.app` to `/Applications` or runs `.pkg` installer
4. Cleans up temporary files

#### `install_dmg(path)`

Mount a DMG file and install the application inside.

```bash
install_dmg "/path/to/app.dmg"
```

**Process:**

1. Mounts the DMG file
2. Copies `.app` to `/Applications` or runs `.pkg` installer
3. Ejects the DMG

### Dock Management

#### `add_app_to_dock(app_name)`

Add an application to the macOS Dock.

```bash
add_app_to_dock "Terminal"
add_app_to_dock "Safari"
add_app_to_dock "Visual Studio Code"
```

**Note:** The application must be installed on the system.

#### `add_folder_to_dock(folder_path [options])`

Add a folder to the macOS Dock with customizable display options.

```bash
# Basic usage
add_folder_to_dock "~/Downloads"

# With custom options
add_folder_to_dock "~/Downloads" -d 0 -s 2 -v 1
add_folder_to_dock "/Applications" --displayas 1 --sortby 1 --viewcontentas 3
```

**Options:**

| Option | Short | Values | Description |
|--------|-------|--------|-------------|
| `--sortby` | `-s` | `1-5` | Sort method |
| `--displayas` | `-d` | `0-1` | Display style |
| `--viewcontentas` | `-v` | `0-3` | View style |

**Sort options (`-s`):**

- `1` - Name (default)
- `2` - Date Added
- `3` - Date Modified
- `4` - Date Created
- `5` - Kind

**Display options (`-d`):**

- `0` - Stack (default)
- `1` - Folder

**View options (`-v`):**

- `0` - Automatic (default)
- `1` - Fan
- `2` - Grid
- `3` - List

#### `add_spacer_to_dock()`

Add an empty spacer to the macOS Dock for organization.

```bash
add_spacer_to_dock
```

#### `clear_dock()`

Remove all persistent icons from the macOS Dock.

```bash
clear_dock
```

**Warning:** This removes all applications from the Dock. Use with caution.

#### `reset_dock()`

Reset the macOS Dock to default settings.

```bash
reset_dock
```

**Note:** This will restart the Dock process.

## Example Usage

### Install Applications

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/smeltery/utilities/master/utilities.sh")"

if is_macos; then
    action "Installing macOS applications"
    
    # Install from various sources
    install_from_URL "https://example.com/MyApp.dmg"
    install_from_URL "https://example.com/OtherApp.pkg"
    install_from_URL "https://example.com/archive.zip"
    
    success "Applications installed"
fi
```

### Customize Dock

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/smeltery/utilities/master/utilities.sh")"

if is_macos; then
    action "Customizing Dock"
    
    # Clear existing dock
    clear_dock
    
    # Add essential applications
    add_app_to_dock "Safari"
    add_app_to_dock "Terminal"
    add_app_to_dock "Visual Studio Code"
    
    # Add spacer
    add_spacer_to_dock
    
    # Add frequently used folders
    add_folder_to_dock "~/Downloads" -d 0 -s 2 -v 2
    add_folder_to_dock "~/Documents" -d 1 -s 1 -v 3
    add_folder_to_dock "/Applications" -d 0 -s 1 -v 2
    
    success "Dock customized"
    
    # Restart Dock to apply changes
    killall Dock
fi
```

### Complete Setup Script

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/smeltery/utilities/master/utilities.sh")"

if is_macos; then
    bot "Setting up macOS"
    
    # Install applications
    action "Installing applications"
    install_from_URL "https://example.com/app1.dmg"
    install_from_URL "https://example.com/app2.pkg"
    
    # Configure Dock
    action "Configuring Dock"
    clear_dock
    add_app_to_dock "Safari"
    add_app_to_dock "Terminal"
    add_spacer_to_dock
    add_folder_to_dock "~/Downloads" -s 2
    
    # Restart Dock
    killall Dock
    
    ok "macOS setup complete!"
fi
```

## Dependencies

- `curl` - For downloading files
- `hdiutil` - For mounting DMG files (included with macOS)
- `unzip` - For extracting ZIP files (included with macOS)
- `defaults` - For Dock configuration (included with macOS)

## Notes

- Most functions require sudo privileges for installation
- Dock changes take effect after restarting the Dock (`killall Dock`)
- Application names must match exactly as they appear in the Applications folder
- The `install_from_URL` function uses `set -x` for verbose output during installation
- Temporary files are automatically cleaned up after installation

## Credits

- Dock management functions contributed by [@rpavlick](https://github.com/rpavlick/add_to_dock)
- DMG installation approach inspired by community solutions
