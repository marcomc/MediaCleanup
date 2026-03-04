# Changelog

All notable changes to this project are documented in this file.

## [2.0.0] - 2026-03-04

### Added

- Python CLI runtime (`mediacleanup.py` + `src/mediacleanup.py`) with dry-run/apply parity behavior.
- Python installer workflow (`scripts/install_mediacleanup.py`).
- TOML configuration sample (`mediacleanup.toml.sample`).
- pytest coverage for dry-run safety, apply parity, collisions, config validation, and doc consistency checks.

### Changed

- Project workflow, docs, and build targets are Python-first.
- Makefile now provides Python install/lint/test/check-prereq targets.
- Governance/spec artifacts for feature 005 include parity, Linux smoke, and timed setup criteria.

### Removed

- Legacy shell runtime and installer from active workflow.

## [1.2.0] - 2026-03-04

- Added interactive install/uninstall/check-prereq entries for the previous runtime.
- Added explicit project license and version reporting.

## [1.1.0] - 2026-01-20

- Added dry-run virtual planning, log-level controls, and run summaries.

## [1.0.0] - 2026-01-18

- Added initial MediaCleanup workflow and specification set.
