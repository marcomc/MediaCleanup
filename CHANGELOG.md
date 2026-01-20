# Changelog

All notable changes to this project will be documented in this file.

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

- Initial `cleanup_media.sh` workflow for organizing media libraries.
- Config support via `~/.mediacleanup.conf` and `mediacleanup.conf.sample`.
- TV show organization into series/season folders with `.tvshow` markers.
- Movie series grouping into prefix folders with `.movieseries` markers.
- Action logging to stdout plus structured action lists in `/tmp/mediacleanup`.
- Specifications, data models, and quickstart guides under `specs/`.

### Changed

- Filename normalization rules and logging output for better clarity.
- File processing flow to improve filtering and cleanup performance.

### Removed

- Standalone `rename.sh` utility in favor of `cleanup_media.sh`.

### Docs

- README usage, behavior notes, and performance references.
- Task lists for TV shows, movie series, and cleanup optimizations.
