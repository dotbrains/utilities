# Python Module

Python package management utilities for pip, pip3, and pyenv.

## Platform Support

- ✅ All platforms

## Dependencies

- python/pip (for pip.sh)
- python3/pip3 (for pip3.sh)
- pyenv (for pyenv.sh)

## Modules

### pip.sh

#### `is_pip_installed()`

Check if pip is installed.

#### `is_pip_pkg_installed(package)`

Check if a pip package is installed.

#### `pip_install(package)`

Install a pip package if not already installed.

#### `pip_install_from_file(file_path)`

Install packages from a requirements file.

**Usage:**

```bash
pip_install "requests"
pip_install_from_file "requirements.txt"
```

### pip3.sh

Same functions as pip.sh but for pip3:

- `is_pip3_installed()`
- `is_pip3_pkg_installed(package)`
- `pip3_install(package)`
- `pip3_install_from_file(file_path)`

### pyenv.sh

#### `is_pyenv_installed()`

Check if pyenv is installed.

#### `pyenv_install(version)`

Install a Python version via pyenv.

**Usage:**

```bash
if is_pyenv_installed; then
    pyenv_install "3.11.0"
fi
```
