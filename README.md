# MediaCleanup

Single Bash utility for organizing media files. `mediacleanup.sh`
normalizes a media library and produces action logs.

## mediacleanup.sh

Scope:

- Operates on the directories listed in `MEDIA_DIRS` (Google Drive/pCloud paths
  by default) or those loaded from `~/.mediacleanup.conf` if present.
- Moves files from nested subdirectories up to the directory root, skipping
  series folders marked with `.tvshow` or season subfolders.
- Removes empty non-series directories after moves.
- Normalizes filenames for allowed media/subtitle extensions by replacing
  non-alphanumeric characters with dots, squeezing dots, capitalizing each
  dot-separated segment, and stripping trailing non-year numbers.
- Organizes episodes into `Series.Name/Sxx/` folders using the season token in
  the filename and adds a `.tvshow` marker to series folders.
- Groups movie series into prefix folders with a `.movieseries` marker when
  multiple movies share the same prefix; standalone movies stay in the root.
- Deletes files with unsupported extensions (based on `ALLOWED_FILE_EXT`).
- Leaves files without a recognized season token in the root for manual review.

Usage:

```bash
./mediacleanup.sh
./mediacleanup.sh --log-level WARN
./mediacleanup.sh --dry-run
./mediacleanup.sh --apply
./mediacleanup.sh --help # for usage details
```

Options:

- `--log-level LEVEL`: `ERROR`, `WARN`, `INFO`, or `DEBUG` (default: `INFO`)
- `--dry-run`: simulate actions (default)
- `--apply`: perform actions
- `--no-virtual`: disable virtual state in dry-run (slower, but direct)

Notes:

- This script moves, renames, and deletes files. Review `MEDIA_DIRS` and
  `ALLOWED_FILE_EXT` before running.
- If `~/.mediacleanup.conf` is missing, run `make install` or copy
  `mediacleanup.conf.sample` to create it before rerunning.
- Screen output omits the media root prefix by default; `--log-level DEBUG`
  shows full paths. INFO-level lines do not include a `[INFO]` prefix.
- Dry-run stages planned moves/renames in memory so later steps use the
  projected layout while leaving the filesystem unchanged.
- Series roots are recognized only when a `.tvshow` marker is present; without
  the marker a folder is treated as non-series.
- When virtual state is disabled (`--no-virtual`), root file scans used by
  normalization and organization are filtered to `ALLOWED_FILE_EXT` for speed.
- `ALLOWED_FILE_EXT` accepts extensions with or without a leading dot. Each
  entry must be alphanumeric and may include `_` or `-` (examples: `mkv`,
  `.mp4`, `srt`, `ass`). Invalid entries are skipped; if none remain the
  script fails fast.
- The script emits pre-execution action logs for moves, renames, deletes, and
  empty directory removals to stdout.
- A structured action list is written to `/tmp/mediacleanup/action-list-<timestamp>.txt`
  with tab-separated fields: `ACTION<TAB>SOURCE<TAB>DEST`. This file can be used
  to compare runs or drive reversibility tooling.

Performance notes:

- Runtime depends on library size and disk performance. Sample run: 14.02s
  (file count not captured).
