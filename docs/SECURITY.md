# Security Policy

## Security Considerations

### Remote Sourcing

This library is designed to be sourced directly from GitHub via curl. While convenient, this approach has important security implications:

#### Risks

1. **Man-in-the-Middle Attacks:** Scripts are fetched over HTTPS, but compromised DNS or network infrastructure could redirect requests
2. **Repository Compromise:** If the GitHub repository is compromised, malicious code could be distributed
3. **Supply Chain:** Dependencies and external scripts could introduce vulnerabilities
4. **Unreviewed Updates:** Using `master` branch means getting latest changes without review

#### Mitigations

**1. Pin to Specific Versions (Recommended)**

```bash
# Instead of master branch
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/master/utilities.sh")"

# Use tagged releases
source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh")"
```

**2. Review Code Before Use**

```bash
# Download and review first
curl -o utilities.sh "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh"
less utilities.sh  # Review the code

# Then use it
source utilities.sh
```

**3. Local Caching**

For production or airgapped environments:

```bash
# Cache locally
mkdir -p "$HOME/.local/lib/utilities"
cd "$HOME/.local/lib/utilities"
git clone https://github.com/dotbrains/utilities.git
cd utilities
git checkout v1.0.0  # Pin to specific version

# Source locally
source "$HOME/.local/lib/utilities/utilities.sh"
```

**4. Verify Checksums (Future)**

Future releases may include checksums for verification:

```bash
# Download
curl -o utilities.sh "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh"
curl -o utilities.sh.sha256 "https://raw.githubusercontent.com/dotbrains/utilities/v1.0.0/utilities.sh.sha256"

# Verify
sha256sum -c utilities.sh.sha256

# Source if valid
source utilities.sh
```

## Best Practices

### For Users

1. **Pin Versions:** Always use tagged releases in production
2. **Review Changes:** Review CHANGELOG.md before upgrading
3. **Test First:** Test in non-production environments before deploying
4. **Limit Scope:** Use `UTILITIES_MODULES` to load only needed modules
5. **Monitor Usage:** Audit which scripts use these utilities
6. **Local Cache:** Consider local caching for critical systems

### For Contributors

1. **No Secrets:** Never commit secrets, API keys, or credentials
2. **Input Validation:** Validate all user inputs
3. **Safe Defaults:** Use safe defaults that require explicit opt-in for risky operations
4. **Error Handling:** Fail safely and provide clear error messages
5. **Privilege Escalation:** Only request sudo when absolutely necessary
6. **Code Review:** All changes should be reviewed before merging

## Sensitive Operations

### Sudo Usage

Functions that require sudo privileges:

- `ask_for_sudo()` - Request admin access
- `symlink()` - May require sudo for system paths
- `gem_install()` - Installs gems with sudo
- Various package manager operations

**Best Practice:** Only use sudo-requiring functions when necessary, and review what they do.

### Network Operations

Functions that make network requests:

- All module loading (via curl from GitHub)
- `brew_bundle_install()` - Downloads packages
- Package installation functions

**Best Practice:** Use in trusted network environments or with cached versions.

### File System Modifications

Functions that modify files/directories:

- `symlink()` - Creates symbolic links
- `mkd()` - Creates directories
- `extract()` - Extracts archives
- Configuration file modifications

**Best Practice:** Review target paths before execution.

## Reporting Security Issues

### Please Do Not

- Open public issues for security vulnerabilities
- Disclose vulnerabilities publicly before they are fixed

### Please Do

1. Email security concerns to the repository maintainer
2. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fixes (if any)
3. Allow reasonable time for a fix before public disclosure

## Security Updates

Security updates will be:

- Released as patch versions (e.g., v1.0.1)
- Documented in CHANGELOG.md with `[SECURITY]` prefix
- Announced in GitHub Releases
- Applied to supported versions

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Code Signing (Future)

Future releases may include:

- GPG signatures for release tags
- Signed commits
- Checksums for verification

## Audit Trail

The git history provides a complete audit trail of all changes:

```bash
# View commit history
git log --oneline

# View specific file history
git log --follow scripts/modules/system/system.sh

# View changes in a commit
git show <commit-hash>
```

## Compliance

### Use in Regulated Environments

If using in regulated environments (financial, healthcare, etc.):

1. **Fork and Review:** Fork the repository and perform security review
2. **Internal Hosting:** Host on internal infrastructure
3. **Version Control:** Strictly control versions used
4. **Access Logging:** Log all usage of utilities
5. **Compliance Review:** Have compliance team review before use

## Questions?

For security questions or concerns, please contact the repository maintainer through GitHub.

---

**Remember:** Security is a shared responsibility. Always review code you execute, especially code with elevated privileges or network access.
