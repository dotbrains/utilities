# Git Module

Git repository utilities for cloning and repository detection.

## Platform Support

- ✅ All platforms

## Dependencies

- git

## Functions

### `clone_git_repo_in(target url)`
Clone a git repository into a target directory if it doesn't already exist.

**Parameters:**
- `$1` - Target directory path
- `$2` - Git repository URL

**Usage:**
```bash
clone_git_repo_in "$HOME/.config/nvim" "https://github.com/user/nvim-config.git"
```

---

### `is_git_repository()`
Check if the current directory is inside a git repository.

**Returns:** 0 if in a git repo, 1 otherwise

**Usage:**
```bash
if is_git_repository; then
    echo "Inside a git repository"
    git status
fi
```

## Examples

```bash
#!/bin/bash

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"

# Clone dotfiles if not present
DOTFILES_DIR="$HOME/.dotfiles"
clone_git_repo_in "$DOTFILES_DIR" "https://github.com/username/dotfiles.git"

# Navigate to project directory
cd "$HOME/projects/myapp" || exit 1

if is_git_repository; then
    action "Pulling latest changes"
    git pull
else
    error "Not a git repository"
    exit 1
fi
```
