# MacPorts Module

MacPorts package manager utilities for macOS.

## Platform Support

- ✅ macOS only

## Dependencies

- MacPorts

## Functions

### `is_macports_installed()`
Check if MacPorts is installed.

### `macports_install(port)`
Install a MacPorts port.

### `is_macports_port_installed(port)`
Check if a port is installed.

**Usage:**
```bash
if is_macos && is_macports_installed; then
    macports_install "wget"
fi
```
