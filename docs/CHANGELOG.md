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

## [1.1.0] - 2026-01-16

### Added

- Enhanced support for Arch Linux

### Changed

- Updated platform badge color in README.md to black for macOS and Linux

### Fixed

- Fixed markdown linting errors and dead link

## [1.1.1] - 2026-01-16

### Changed

- Renamed `test/` directory to `tests/` for better naming convention
- Updated all references to test scripts in documentation and CI workflows

## [1.2.0] - 2026-08-09

### Added

- `import.sh`: import-based library entry point defining `smu::import`
- Selective, file-granular module imports with idempotent loading
  (each file is sourced at most once per shell)
- Module dependency declarations: every module file declares its own
  dependencies via `smu::import` (e.g. `homebrew` pulls in `base`)
- Remote fetches are pinned to the release tag matching
  `UTILITIES_VERSION`, with fallback to `master` and override via
  `UTILITIES_REF`
- Integration tests for no-side-effect sourcing, selective import,
  idempotent import, and unknown-module errors

### Changed

- `utilities.sh` is now a thin backwards-compatible facade over
  `import.sh`; sourcing it still loads the full library filtered by
  `UTILITIES_MODULES`
- Module files no longer download `base/base.sh` from `master` at
  source time; the embedded `curl` calls were replaced with
  `smu::import` declarations (removes ~20 network calls per load and
  the unpinned dependency on `master`)
- `source_file()` in the network module now resolves through the
  importer (local checkout, cache, then pinned remote)

### Removed

- Direct standalone sourcing of individual module files without the
  importer (previously possible because each file self-downloaded its
  dependencies from `master`); load modules through `import.sh` or
  `utilities.sh` instead

## [Unreleased]

### Planned

- Enhanced testing infrastructure with unit and integration tests
- CI/CD improvements with automated releases

---

[1.2.0]: https://github.com/dotbrains/utilities/releases/tag/v1.2.0
[1.1.1]: https://github.com/dotbrains/utilities/releases/tag/v1.1.1
[1.1.0]: https://github.com/dotbrains/utilities/releases/tag/v1.1.0
[1.0.0]: https://github.com/dotbrains/utilities/releases/tag/v1.0.0
