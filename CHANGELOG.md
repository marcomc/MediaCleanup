# Changelog

All notable changes to this project will be documented in this file.

## 1.2.0 - 2026-03-04

### Added

- Interactive `make install`/`make uninstall` entries that copy `mediacleanup.sh`, prompt for media folders, build `~/.mediacleanup.conf`, and verify prerequisites via `make check-prereq`.
- `LICENSE` (MIT) so the project carries an explicit copyright notice.
- `SCRIPT_VERSION` plus `--version`/help output so `mediacleanup.sh` can self-report 1.2.0.
- Installer now prints confirmation when the binary lands in `${HOME}/.local/bin/mediacleanup`.

### Changed

- Renamed the primary script to `mediacleanup.sh`, updated the README/specs, and removed literal user-specific system paths so documentation stays publish-ready.
- `mediacleanup.conf.sample` and the runtime default config path now rely on `${HOME}` instead of user-specific system prefixes.
- Script now fails when `~/.mediacleanup.conf` is missing and points users to `make install` or the sample, since the installer is the canonical place to create configs.
- `make install` hands off to `scripts/install-mediacleanup.sh`, which cleans up stray escape sequences, defaults to `${HOME}/.local/bin`, installs the binary as `mediacleanup` (no `.sh`), checks for an existing config before doing any prompts, leaves existing configs untouched when you decline to overwrite them, and asks about Google Drive (and directory) settings only when it is creating or overwriting the config file.
- Installer defaults to `${HOME}/.local/bin` so the binary lands in your user-local bin path.
- The installer now fails early when `$INSTALL_DIR` is not writable, explains the permission issue, and tells you to rerun with sudo or change `INSTALL_DIR`.
- Documented the release in AGENTS/CHANGELOG and kept MarkdownLint fully satisfied so the repo is ready for publication.

## 1.1.0 - 2026-01-20

### Added (1.1.0)

- Dry-run mode that stages planned changes in memory and requires `--apply` for real changes.
- Log level controls (ERROR/WARN/INFO/DEBUG) with INFO default and debug full-path output.
- Run summary table with action/outcome counts.

### Changed (1.1.0)

- Screen output now omits media root prefixes by default.
- Dry-run logging uses virtual state for collision-aware planning.
- Dry-run virtual state stores paths with NUL delimiters to handle edge-case filenames.

### Docs (1.1.0)

- Updated README and quickstart to cover new logging and dry-run behavior.

## 1.0.0 - 2026-01-18

### Added (1.0.0)

- Initial `mediacleanup.sh` workflow for organizing media libraries.
- Config support via `~/.mediacleanup.conf` and `mediacleanup.conf.sample`.
- TV show organization into series/season folders with `.tvshow` markers.
- Movie series grouping into prefix folders with `.movieseries` markers.
- Action logging to stdout plus structured action lists in `/tmp/mediacleanup`.
- Specifications, data models, and quickstart guides under `specs/`.

### Changed (1.0.0)

- Filename normalization rules and logging output for better clarity.
- File processing flow to improve filtering and cleanup performance.

### Removed (1.0.0)

- Standalone `rename.sh` utility in favor of `mediacleanup.sh`.

### Docs (1.0.0)

- README usage, behavior notes, and performance references.
- Task lists for TV shows, movie series, and cleanup optimizations.
