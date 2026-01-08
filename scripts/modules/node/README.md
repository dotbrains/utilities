# Node Module

Node.js and npm package management utilities.

## Platform Support

- ✅ All platforms

## Dependencies

- node
- npm
- npx (optional)

## Functions

### `is_npm_installed()`

Check if npm is installed.

### `is_npx_installed()`

Check if npx is installed.

### `is_npm_pkg_installed(package)`

Check if an npm global package is installed.

### `is_yarn_pkg_installed(package)`

Check if a yarn global package is installed.

### `npm_install(package)`

Install an npm package globally.

### `sudo_npm_install(package)`

Install an npm package globally with sudo.

### `npx_install(package)`

Install a package via yarn using npx.

### `npm_install_from_file(file_path)`

Install npm packages from a file.

## Examples

```bash
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

if is_npm_installed; then
    npm_install "typescript"
    npm_install "eslint"
fi
```
