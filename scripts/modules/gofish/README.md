# Gofish Module

Gofish package manager utilities.

## Platform Support

- ✅ All platforms

## Dependencies

- gofish

## Functions

### `is_gofish_installed()`
Check if Gofish is installed.

### `gofish_install()`
Install Gofish.

### `is_gofish_pkg_installed(package)`
Check if a Gofish package is installed.

### `gofish_pkg_install(package)`
Install a Gofish package.

**Usage:**
```bash
if is_gofish_installed; then
    gofish_pkg_install "hugo"
fi
```
