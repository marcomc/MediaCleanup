# Contract: TV Show File Organization

**Date**: 2026-01-17
**Spec**: /Users/mmassari/Development/MediaCleanup/specs/001-organize-tv-shows/spec.md

## Inputs

- Root media directories defined in `MEDIA_DIRS`
- Episode files with normalized names containing a season token (e.g., `S07E10`)
- Allowed media/subtitle extensions defined in `VIDEO_EXTENSIONS`

## Outputs

- Series folders named after the canonical series name (e.g., `Shameless.Us`)
- Season subfolders named `Sxx` under each series
- `.tvshow` marker file inside each series folder

## Rules

- Only files with allowed extensions are organized into series folders.
- Season folders always use two-digit naming (`S01`, `S02`, ...).
- Series folder matching is case-insensitive; the canonical name is derived from
  the filename.
- Files without a recognized season token remain in the root.
