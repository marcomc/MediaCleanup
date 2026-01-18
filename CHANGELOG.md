# Changelog

All notable changes to this project will be documented in this file.

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
