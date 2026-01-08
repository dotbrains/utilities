# Rust Module

Rust cargo package management utilities.

## Platform Support

- ✅ All platforms

## Dependencies

- rust
- cargo

## Functions

### `is_cargo_installed()`

Check if Cargo is installed.

### `cargo_install(crate)`

Install a Rust crate via cargo.

**Usage:**

```bash
if is_cargo_installed; then
    cargo_install "ripgrep"
    cargo_install "bat"
fi
```
