# Java Module

SDKMAN utilities for Java version management.

## Platform Support

- ✅ All platforms

## Dependencies

- SDKMAN

## Functions

### `is_sdkman_installed()`

Check if SDKMAN is installed.

### `sdkman_install()`

Install SDKMAN.

### `sdk_install(candidate [version])`

Install an SDK via SDKMAN.

**Usage:**

```bash
if is_sdkman_installed; then
    sdk_install "java" "17.0.1-tem"
    sdk_install "gradle"
fi
```
