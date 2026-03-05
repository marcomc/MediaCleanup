# Changelog

All notable changes to this project are documented in this file.

## [2.1.0] - 2026-03-04

### Added

- Themed CLI output styles (`minimal`, `vibrant`, `pro`) with ANSI + Unicode/ASCII terminal compatibility fallbacks.
- New `--output-style` CLI option with config-backed defaults via `output_style` in `~/.mediacleanup.toml`.
- `make update-config` target and `scripts/update_config_defaults.py` to safely add newly supported config keys without overwriting existing user values.
- Additional pytest coverage for output style validation/override behavior and config update behavior.

### Changed

- Run/log presentation now uses structured banners, directory headers, and summary sections while preserving existing operational information.
- Config updater now inserts missing top-level keys before table sections to avoid scope errors in TOML files that include tables.
- Log messages for `move`/`rename` are now printed as aligned `from`/`to` pairs with wrapping so long filenames stay legible, and the README documents the refreshed CLI summary/output format along with the config/runtime expectations.
- The CLI no longer imports `__version__` via relative imports when installed standalone; the package `__version__` mirrors `SCRIPT_VERSION` so the new installer script keeps working without import errors.

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
