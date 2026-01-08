# Fish Module

Fish shell utilities and plugin managers (OMF, Fisher).

## Platform Support

- ✅ All platforms (requires Fish shell)

## Dependencies

- fish shell

## Modules

### fish.sh

#### `fish_cmd_exists(command)`

Check if a command exists in Fish shell.

**Usage:**

```bash
if fish_cmd_exists "fisher"; then
    echo "Fisher is installed"
fi
```

### omf.sh

Oh My Fish plugin manager functions.

#### `is_omf_installed()`

Check if OMF is installed.

#### `omf_install()`

Install Oh My Fish.

#### `omf_package_is_installed(package)`

Check if an OMF package is installed.

#### `omf_install_package(package)`

Install an OMF package.

### fisher.sh

Fisher plugin manager functions.

#### `is_fisher_installed()`

Check if Fisher is installed.

#### `fisher_install()`

Install Fisher.

#### `fisher_package_is_installed(package)`

Check if a Fisher plugin is installed.

#### `fisher_install_package(package)`

Install a Fisher plugin.
