# MediaCleanup Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-01-17

## Active Technologies

- Bash (macOS system bash) + Standard macOS shell tools (find, mv, rm, awk, sed, tr) (003-optimize-cleanup-script)
- Local filesystem under configured media directories (003-optimize-cleanup-script)
- Bash (macOS system bash) + Standard macOS shell tools (find, mv, rm, awk, sed, tr) (002-movie-series-support)
- Bash (macOS system bash) + Standard macOS shell tools (find, mv, rm, awk, sed, tr) (001-organize-tv-shows)

## Project Structure

```text
src/
tests/
```

## Commands

## Add commands for Bash (macOS system bash)

## Code Style

Bash (macOS system bash): Follow standard conventions

## Recent Changes

- 004-logging-dry-run: Added Bash (macOS system bash) + Standard macOS shell tools (find, mv, rm, awk, sed, tr)
- 003-optimize-cleanup-script: Added Bash (macOS system bash) + Standard macOS shell tools (find, mv, rm, awk, sed, tr)
- 003-optimize-cleanup-script: Added Local filesystem under configured media directories

<!-- MANUAL ADDITIONS START -->
- Script updates must pass linting (e.g., shellcheck) and any uncovered issues must be resolved rather than silenced.
- Markdown files must pass MarkdownLint as part of the workflow; `MD013` (line length) is globally disabled via the repository config.
<!-- MANUAL ADDITIONS END -->
