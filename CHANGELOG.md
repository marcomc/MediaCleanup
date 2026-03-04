# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Interactive `make install`/`make uninstall` entries that copy `mediacleanup.sh`, prompt for media folders, build `~/.mediacleanup.conf`, and verify prerequisites via `make check-prereq`.
- `LICENSE` (MIT) so the project carries an explicit copyright notice.

### Changed

- Renamed the primary script to `mediacleanup.sh`, updated the README/specs, and removed literal user-specific system paths so documentation stays publish-ready.
- `mediacleanup.conf.sample` and the runtime default config path now rely on `${HOME}` instead of user-specific system prefixes.
- Script now fails when `~/.mediacleanup.conf` is missing and points users to `make install` or the sample, since the installer is the canonical place to create configs.
- `make install` now runs `scripts/install-mediacleanup.sh`, which sanitizes user input and clears stray escape sequences so hitting Enter cleanly accepts the default directory prompt.
- The installer now fails early when `$INSTALL_DIR` is not writable, explains the permission issue, and tells you to rerun with sudo or change `INSTALL_DIR`.

## 1.1.0 - 2026-01-20

### Added

- Dry-run mode that stages planned changes in memory and requires `--apply` for real changes.
- Log level controls (ERROR/WARN/INFO/DEBUG) with INFO default and debug full-path output.
- Run summary table with action/outcome counts.

### Changed

- Screen output now omits media root prefixes by default.
- Dry-run logging uses virtual state for collision-aware planning.
- Dry-run virtual state stores paths with NUL delimiters to handle edge-case filenames.

### Docs

- Updated README and quickstart to cover new logging and dry-run behavior.

## 1.0.0 - 2026-01-18

### Added

- Initial `mediacleanup.sh` workflow for organizing media libraries.
- Config support via `~/.mediacleanup.conf` and `mediacleanup.conf.sample`.
- TV show organization into series/season folders with `.tvshow` markers.
- Movie series grouping into prefix folders with `.movieseries` markers.
- Action logging to stdout plus structured action lists in `/tmp/mediacleanup`.
- Specifications, data models, and quickstart guides under `specs/`.

### Changed

- Filename normalization rules and logging output for better clarity.
- File processing flow to improve filtering and cleanup performance.

### Removed

- Standalone `rename.sh` utility in favor of `mediacleanup.sh`.

### Docs

- README usage, behavior notes, and performance references.
- Task lists for TV shows, movie series, and cleanup optimizations.
