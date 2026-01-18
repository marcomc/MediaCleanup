# MediaCleanup

Single Bash utility for organizing media files. `cleanup_media.sh`
normalizes a media library and produces action logs.

## cleanup_media.sh

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
./cleanup_media.sh
./cleanup_media.sh --help # for usage details
```

Notes:

- This script moves, renames, and deletes files. Review `MEDIA_DIRS` and
  `ALLOWED_FILE_EXT` before running.
- If `~/.mediacleanup.conf` is missing, the script seeds it from
  `mediacleanup.conf.sample` and exits so you can personalize it before
  rerunning.
- The script emits pre-execution action logs for moves, renames, deletes, and
  empty directory removals in the format `ACTION SOURCE -> DEST` to stdout.
- A structured action list is written to `/tmp/mediacleanup/action-list-<timestamp>.txt`
  with tab-separated fields: `ACTION<TAB>SOURCE<TAB>DEST`. This file can be used
  to compare runs or drive reversibility tooling.

Performance notes:

- Runtime depends on library size and disk performance. Sample run: 14.02s
  (file count not captured).
