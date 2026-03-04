# MediaCleanup Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-03-04

## Active Technologies

- Python 3.11+ + Python standard library, pytest, ruff, markdownlint-cli (005-python-migration-cleanup)
- Local filesystem + user config file (`~/.mediacleanup.toml`) (005-python-migration-cleanup)

- Python 3.11+ (CLI runtime)
- Standard library file/path operations
- pytest for automated validation
- Local filesystem under configured media directories

## Project Structure

```text
src/
tests/
```

## Commands

- `make check-prereq`
- `make lint`
- `make test`
- `make install`
- `make uninstall`

## Code Style

- Python: explicit path handling, deterministic transformations, safe IO guards

## Recent Changes

- 005-python-migration-cleanup: Added Python 3.11+ + Python standard library, pytest, ruff, markdownlint-cli

- 005-python-migration-cleanup: Python-first runtime, installer, config format, and validation workflow.

<!-- MANUAL ADDITIONS START -->
- Script updates must pass linting and unresolved issues must be fixed instead of silenced.
<!-- MANUAL ADDITIONS END -->
