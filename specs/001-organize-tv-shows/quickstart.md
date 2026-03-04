# Quickstart: Organize TV Shows by Series and Season

**Date**: 2026-01-17
**Spec**: ./specs/001-organize-tv-shows/spec.md

## Goal

Normalize TV episode filenames, flatten incoming drops, and organize episodes
into `Series.Name/Sxx/` folders with a `.tvshow` marker.

## Steps

1. Review `MEDIA_DIRS` and `ALLOWED_FILE_EXT` in `~/.mediacleanup.conf` to
   ensure they match your storage locations and allowed file types.
2. Drop new files anywhere within the target media root; nested folders will be
   flattened to the root during cleanup.
3. Run the cleanup script from the repository root:

   ```bash
   ./mediacleanup.sh
   ```

4. Verify that series folders contain a `.tvshow` marker and season subfolders
   (e.g., `Series.Name/S07/`).
5. Check the root for any files left for manual review (unparseable or
   non-media).
