# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-08

### Added
- Comprehensive documentation for all modules
- Root README.md with quick start guide and module overview
- Per-module README files with function documentation
- Central FUNCTIONS.md reference index
- DEPENDENCIES.md listing requirements per module
- CONTRIBUTING.md with contribution guidelines
- SECURITY.md with security best practices
- Debug mode support via UTILITIES_DEBUG environment variable
- Selective module loading via UTILITIES_MODULES environment variable
- Optional caching via UTILITIES_CACHE_DIR environment variable
- Semantic versioning support

### Changed
- Enhanced utilities.sh with version constant (UTILITIES_VERSION)
- Improved error handling in source_file_from_utilities() with timeouts
- Better network failure handling with 10s connect timeout, 30s max timeout
- Updated GitHub Actions workflows to use actions/checkout@v4
- Reorganized documentation into docs/ directory
- Enhanced test workflow with bash version display and additional validation

### Documentation
- Base module: 29 functions documented
- System module: 20 functions documented
- Git module: 2 functions documented
- Homebrew module: 5 functions documented
- Python module: pip, pip3, and pyenv functions documented
- Node module: npm and npx functions documented
- Fish module: fish, OMF, and Fisher functions documented
- Ruby module: gem functions documented
- Rust module: cargo functions documented
- Go module: go functions documented
- Java module: SDKMAN functions documented
- Gofish module: gofish functions documented
- MacPorts module: macports functions documented

### Testing
- Created integration_test.sh for testing core features
- Added tests for version constant, debug mode, selective loading, and caching
- Enhanced CI workflow with additional validation tests
- Shellcheck validation on all shell scripts

### CI/CD
- Added automated release workflow (release.yml)
- Added linting workflow (lint.yml) with markdown linting and link checking
- Added markdownlint configuration
- Added markdown-link-check configuration
- Added status badges to README (Tests, Lint, Release, License, Shell, Platform)

### Features
- Empty file validation to prevent sourcing of corrupt downloads
- Cache directory creation with error handling
- Failed download cleanup
- Debug error messages for troubleshooting
- Graceful handling of network failures

## [Unreleased]

### Planned
- Enhanced testing infrastructure with unit and integration tests
- CI/CD improvements with automated releases
- Markdown linting and link validation
- Version badges and status indicators

---

[1.0.0]: https://github.com/dotbrains/utilities/releases/tag/v1.0.0
