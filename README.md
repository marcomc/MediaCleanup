# MediaCleanup

Two small Bash utilities for organizing media files. `cleanup_media.sh`
normalizes a media library and produces rename logs. `rename.sh` can revert
those renames using the log output.

## cleanup_media.sh

Scope:

- Operates on the directories listed in `MEDIA_DIRS` (Google Drive/pCloud paths
  by default).
- Moves files from nested subdirectories up to the directory root, skipping
  series folders marked with `.tvshow` or season subfolders.
- Removes empty non-series directories after moves.
- Normalizes filenames for allowed media/subtitle extensions by replacing
  non-alphanumeric characters with dots, squeezing dots, capitalizing each
  dot-separated segment, and stripping trailing non-year numbers.
- Organizes episodes into `Series.Name/Sxx/` folders using the season token in
  the filename and adds a `.tvshow` marker to series folders.
- Deletes files with unsupported extensions.
- Leaves files without a recognized season token in the root for manual review.

Usage:

```bash
./cleanup_media.sh
```

Notes:

- This script moves, renames, and deletes files. Review `MEDIA_DIRS` and
  `VIDEO_EXTENSIONS` before running.
- The rename log lines look like `Renaming Old.Name.mkv to New.Name.mkv` and can
  be used by `rename.sh`.

Performance notes:

- Runtime depends on library size and disk performance. Record sample run
  timing here once measured.

## rename.sh

Scope:

- Reads a log file containing lines like `Renaming <old> to <new>`.
- Attempts to rename `<new>` back to `<old>` for each line.

Usage:

```bash
./rename.sh /path/to/rename.log
```

Notes:

- The log entries from `cleanup_media.sh` only include base names, not full
  paths. Run `rename.sh` in the directory where the files live or adjust the log
  to include paths.
