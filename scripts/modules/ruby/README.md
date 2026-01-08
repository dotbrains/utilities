# Ruby Module

Ruby gem package management utilities.

## Platform Support

- ✅ All platforms

## Dependencies

- ruby
- gem

## Functions

### `is_ruby_installed()`
Check if Ruby/gem is installed.

**Returns:** 0 if installed, 1 otherwise

### `gem_install(gem)`
Install a Ruby gem if not already installed.

**Parameters:**
- `$1` - Gem name

**Usage:**
```bash
if is_ruby_installed; then
    gem_install "bundler"
    gem_install "rails"
fi
```

## Examples

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

if ! is_ruby_installed; then
    error "Ruby not installed"
    exit 1
fi

action "Installing Ruby gems"
gem_install "bundler"
gem_install "jekyll"
success "Gems installed"
```
