# Dependencies

This document lists the dependencies required for each module in the utilities library.

## Core Requirements

All modules require:
- **bash** 3.2+ (macOS default) or 4.0+
- **curl** - For remote sourcing

## Module Dependencies

### Base Module
**Platform:** All

**Required:**
- bash 3.2+
- Standard Unix utilities: tput, ps, grep, sed

**Optional:**
- None

---

### System Module
**Platform:** All

**Required:**
- bash 3.2+
- uname, grep, sed, awk
- readlink (for symlinks)

**Optional:**
- sudo (for privileged operations)
- jq (for JSON manipulation - auto-installed if needed)

---

### Git Module
**Platform:** All

**Required:**
- git

**Optional:**
- None

---

### Homebrew Module
**Platform:** macOS, Linux

**Required:**
- curl

**Optional:**
- Homebrew (checked/initialized by functions)
- python3 (for brew.py script functionality)

**Installation:**
- macOS: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Linux: See https://docs.brew.sh/Homebrew-on-Linux

---

### MacPorts Module
**Platform:** macOS only

**Required:**
- MacPorts

**Installation:**
- https://www.macports.org/install.php

---

### Gofish Module
**Platform:** All

**Optional:**
- Gofish (can be installed via module functions)

**Installation:**
- curl -fsSL https://raw.githubusercontent.com/fishworks/gofish/main/scripts/install.sh | bash

---

### APT Module
**Platform:** Debian/Ubuntu Linux

**Required:**
- apt-get
- dpkg

**Optional:**
- sudo (for privileged operations)

---

### Python Module
**Platform:** All

**Required (per sub-module):**
- **pip.sh:** python, pip
- **pip3.sh:** python3, pip3
- **pyenv.sh:** pyenv

**Installation:**
- pip: Usually included with Python
- pyenv: https://github.com/pyenv/pyenv#installation

---

### Node Module
**Platform:** All

**Required:**
- node
- npm

**Optional:**
- npx (usually included with npm 5.2+)
- yarn

**Installation:**
- https://nodejs.org/
- Or via package manager (brew, apt, etc.)

---

### Ruby Module
**Platform:** All

**Required:**
- ruby
- gem

**Installation:**
- macOS: Included by default
- Linux: `apt install ruby-full` or equivalent

---

### Rust Module
**Platform:** All

**Required:**
- rust
- cargo

**Installation:**
- curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

---

### Go Module
**Platform:** All

**Required:**
- go

**Installation:**
- https://golang.org/doc/install
- Or via package manager

---

### Java Module
**Platform:** All

**Required:**
- SDKMAN

**Installation:**
- curl -s "https://get.sdkman.io" | bash

---

### Fish Module
**Platform:** All (requires Fish shell)

**Required:**
- fish shell

**Optional (per sub-module):**
- **omf.sh:** Oh My Fish
- **fisher.sh:** Fisher plugin manager

**Installation:**
- fish: https://fishshell.com/
- OMF: curl -L https://get.oh-my.fish | fish
- Fisher: Available through fish package managers

---

## Conditional Loading

The main `utilities.sh` script automatically detects the platform and loads only relevant modules:

- **macOS (Darwin):**
  - Loads: base, system, network, homebrew, macports, git, fish, npm, pip, pyenv, gem, cargo, go, sdkman, gofish
  
- **Debian/Ubuntu Linux:**
  - Loads: base, system, network, apt, homebrew, git, fish, npm, pip, pyenv, gem, cargo, go, sdkman, gofish

- **Other Linux:**
  - Loads: base, system, network, homebrew, git, fish, npm, pip, pyenv, gem, cargo, go, sdkman, gofish

## Minimal Installation

For a minimal setup with just core utilities:

```bash
# Only bash and curl required
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

# Base and system modules will always be available
if cmd_exists "git"; then
    # Git module functions available
fi
```

## Checking Dependencies

Use the provided `is_*_installed()` functions to check for dependencies before use:

```bash
if is_brew_installed; then
    # Homebrew operations
fi

if is_npm_installed; then
    # npm operations
fi
```
