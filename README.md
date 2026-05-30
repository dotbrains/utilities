# Utilities

[![Tests](https://github.com/dotbrains/utilities/actions/workflows/tests.yml/badge.svg)](https://github.com/dotbrains/utilities/actions/workflows/tests.yml)
[![Lint](https://github.com/dotbrains/utilities/actions/workflows/lint.yml/badge.svg)](https://github.com/dotbrains/utilities/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/dotbrains/utilities)](https://github.com/dotbrains/utilities/releases/latest)
[![License: PolyForm Shield 1.0.0](https://img.shields.io/badge/License-PolyForm%20Shield%201.0.0-blue.svg)](https://polyformproject.org/licenses/shield/1.0.0/)
[![Shell](https://img.shields.io/badge/shell-bash%203.2%2B-blue)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-black)](#platform-support)

A curated collection of bash utility functions and modules for streamlined shell scripting across macOS and Linux systems.

## Overview

This repository provides 20+ reusable bash functions organized into modules covering package managers, version control, programming languages, and system utilities. The entire library can be sourced with a single command, making it ideal for bootstrap scripts, dotfile management, and automation tasks.

**Version:** 1.0.0

## Quick Start

### Basic Usage

Source the utilities in your bash script with a single command:

```bash
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/utilities.sh")"
```

**Note:** The `/dev/stdin` syntax is required due to [bash 3.2 compatibility on macOS](https://stackoverflow.com/a/32596626/5290011).

### Version Pinning (Recommended)

For production use, pin to a specific version to ensure stability:

```bash
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"
```

### Example Script

```bash
#!/bin/bash

# Load utilities
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

# Use utility functions
bot "Starting setup..."

if is_macos; then
    action "Detected macOS"

    if ! cmd_exists "brew"; then
        error "Homebrew not found"
        exit 1
    fi

    brew_bundle_install -f "Brewfile"
    success "Homebrew packages installed"
fi

ok "Setup complete!"
```

## Available Modules

| Module | Description | Platform |
|--------|-------------|----------|
| **base** | Core utility functions (prompts, colors, spinners, execution) | All |
| **system** | OS detection, path management, file operations | All |
| **network** | Network utilities | All |
| **homebrew** | Homebrew package manager functions | macOS, Linux |
| **macports** | MacPorts package manager functions | macOS |
| **gofish** | Gofish package manager functions | All |
| **apt** | APT package manager functions | Debian/Ubuntu |
| **pacman** | Pacman package manager functions | Arch Linux |
| **git** | Git repository utilities | All |
| **fish** | Fish shell utilities and plugin managers | All |
| **npm** | Node.js and npm utilities | All |
| **pip** | Python pip utilities | All |
| **pip3** | Python pip3 utilities | All |
| **pyenv** | Python version manager utilities | All |
| **gem** | Ruby gem utilities | All |
| **cargo** | Rust cargo utilities | All |
| **go** | Go language utilities | All |
| **sdkman** | Java SDKMAN utilities | All |

## Key Features

### 🎨 Rich Output Functions

- Color-coded messages (success, error, warning, action)
- Interactive prompts with confirmation
- Progress spinners for long-running commands

### 🔧 System Utilities

- Cross-platform OS detection
- PATH management
- File operations (symlinks, extraction, directory creation)
- Shell configuration helpers

### 📦 Package Manager Integration

- Unified interface for multiple package managers
- Conditional loading based on platform
- Brewfile support with optional Python-based installer

### 🔐 Security Considerations

- Scripts are sourced directly from GitHub
- **Recommendation:** Review code before using in production
- **Best Practice:** Pin to specific version tags
- **Optional:** Cache scripts locally for offline/airgapped environments

## Advanced Usage

### Debug Mode

Enable verbose logging to see which modules are being loaded:

```bash
export UTILITIES_DEBUG=true
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"
```

### Selective Module Loading

Load only specific modules for faster sourcing:

```bash
export UTILITIES_MODULES="homebrew,git"
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"
```

### Local Caching

Cache scripts locally to improve performance and enable offline usage:

```bash
export UTILITIES_CACHE_DIR="$HOME/.cache/dotbrains/utilities"
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"
```

## Documentation

- [Function Reference](docs/FUNCTIONS.md) - Complete list of all available functions
- [Module Documentation](scripts/) - Detailed documentation for each module
- [Dependencies](docs/DEPENDENCIES.md) - Requirements for each module
- [Contributing](docs/CONTRIBUTING.md) - Guidelines for contributors
- [Security](docs/SECURITY.md) - Security best practices and considerations
- [Changelog](docs/CHANGELOG.md) - Version history and changes

## Requirements

- **Bash:** 3.2+ (macOS default) or 4.0+
- **curl:** Required for remote sourcing
- **Module-specific dependencies:** See [DEPENDENCIES.md](docs/DEPENDENCIES.md)

## Platform Support

- ✅ macOS (Darwin) - All versions
- ✅ Ubuntu/Debian Linux
- ✅ Arch Linux
- ⚠️ Other Linux distributions - Base functionality supported, some modules may require adaptation

## Testing

The repository includes comprehensive testing:

**Shellcheck validation:**

```bash
./tests/main.sh
```

**Integration tests:**

```bash
./tests/integration_test.sh
```

Tests run automatically on push via GitHub Actions for both Ubuntu and macOS.

### Reproducible dev environment (Flox)

A [Flox](https://flox.dev) manifest at `.flox/env/manifest.toml` pins the toolchain CI uses — `bash`, `shellcheck`, and `nodejs` (for `npx markdownlint-cli2`). Activating it gives contributors the same versions on macOS or Linux, avoiding the "works in CI but not locally" gap:

```bash
# From the utilities/ directory:
flox activate

# Inside the activated shell you can run the same checks CI runs:
./tests/main.sh
./tests/integration_test.sh
npx markdownlint-cli2 "**/*.md"
```

Pinning bash here is especially valuable: the library targets bash 3.2 (macOS default) and a pinned bash version makes regression tests against that floor reproducible.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

Licensed under [PolyForm Shield 1.0.0](https://polyformproject.org/licenses/shield/1.0.0/).
See [LICENSE](LICENSE) for details.

## Acknowledgments

This collection has been curated and refined over years of dotfile management and system automation. Many functions are inspired by or adapted from various open-source projects and community contributions.

---

**Questions?** Open an issue on GitHub.
**Want to help?** Check out [CONTRIBUTING.md](docs/CONTRIBUTING.md).
