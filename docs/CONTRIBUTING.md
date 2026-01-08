# Contributing to Utilities

Thank you for your interest in contributing! This document provides guidelines for contributing to the utilities repository.

## Code of Conduct

Be respectful, constructive, and professional in all interactions.

## How to Contribute

### Reporting Bugs

1. Check if the issue already exists in GitHub Issues
2. Include the following in your report:
   - OS and version (macOS version, Linux distribution)
   - Bash version (`bash --version`)
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant error messages or logs

### Suggesting Enhancements

1. Open a GitHub Issue with the `enhancement` label
2. Clearly describe the feature and its use case
3. Explain why this enhancement would be useful
4. Consider backwards compatibility

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature-name`)
3. Make your changes following our coding standards
4. Test your changes thoroughly
5. Update documentation as needed
6. Commit with clear, descriptive messages
7. Push to your fork
8. Open a Pull Request

## Coding Standards

### Shell Script Guidelines

#### Style
- Use bash 3.2 compatible syntax (macOS default)
- Indent with tabs (as used in existing code)
- Use descriptive variable names
- Add comments for complex logic

#### Best Practices
```bash
# Good: Use local variables in functions
function_name() {
    local variable_name="value"
    # ...
}

# Good: Check command existence before use
if cmd_exists "tool"; then
    # Use tool
fi

# Good: Provide user feedback
action "Performing operation"
execute "command" "User-friendly message"
success "Operation complete"

# Good: Handle errors
if ! command; then
    error "Command failed"
    return 1
fi
```

#### Function Naming
- Use descriptive names: `install_package()` not `inst()`
- Follow existing patterns: `is_tool_installed()`, `tool_install()`
- Use snake_case for function names

#### Error Handling
- Always check return codes for critical operations
- Provide meaningful error messages
- Use the base module's output functions (error, warn, etc.)

### Documentation

#### Function Documentation
Every new function must be documented in its module's README:

```markdown
### `function_name(param1 [param2])`
Brief description of what the function does.

**Parameters:**
- `$1` - Description of first parameter
- `$2` - Optional: Description of optional parameter

**Returns:** Description of return value/code

**Usage:**
```bash
# Example usage
function_name "value1"
```
```

#### Update Central Documentation
When adding functions:
1. Add to module's README.md
2. Add to FUNCTIONS.md index
3. Update CHANGELOG.md

### Testing

#### shellcheck
All scripts must pass shellcheck:

```bash
./test/main.sh
```

#### Manual Testing
Test your changes on:
- macOS (if applicable)
- Ubuntu/Debian (if applicable)
- bash 3.2 (macOS default)
- bash 4.0+ (modern Linux)

#### Test Cases
Consider:
- Does it work when the tool is not installed?
- Does it work when the tool is already installed?
- Does it handle errors gracefully?
- Does it work in non-interactive mode?

## Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- MAJOR: Incompatible API changes
- MINOR: New functionality (backwards compatible)
- PATCH: Bug fixes (backwards compatible)

### Release Checklist

1. **Update Version**
   - Update `UTILITIES_VERSION` in `utilities.sh`
   - Update version in `README.md`

2. **Update CHANGELOG.md**
   - Move items from [Unreleased] to new version section
   - Add release date
   - Include all changes since last release

3. **Test**
   - Run shellcheck tests: `./test/main.sh`
   - Manual testing on macOS and Linux
   - Test version pinning with new tag

4. **Create Release**
   ```bash
   git tag -a v1.x.x -m "Release v1.x.x"
   git push origin v1.x.x
   ```

5. **GitHub Release**
   - Create release on GitHub
   - Use CHANGELOG content for release notes
   - Attach any relevant assets

## Module Structure

When adding a new module:

```
scripts/modules/tool-name/
├── README.md          # Module documentation
├── tool.sh            # Main module script
└── helper.sh          # Optional helper scripts
```

### Module Template

```bash
#!/bin/bash

# shellcheck source=/dev/null

source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/scripts/base/base.sh")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# tool-name functions

is_tool_installed() {
    if ! cmd_exists "tool"; then
        return 1
    fi
}

tool_install() {
    local package="$1"
    
    # Check if tool is installed
    is_tool_installed || return 1
    
    # Perform operation
    # ...
}
```

## Questions?

- Open an issue for questions
- Check existing documentation
- Review similar modules for patterns

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to make this project better!
