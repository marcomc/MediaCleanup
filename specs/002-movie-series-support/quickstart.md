# Quickstart: Movie Series Support

**Date**: 2026-01-17
**Spec**: ./specs/002-movie-series-support/spec.md

## Goal

Keep standalone movies in the root while grouping movie series into folders
marked with `.movieseries`.

## Steps

1. Review `MEDIA_DIRS` and `ALLOWED_FILE_EXT` in `~/.mediacleanup.conf` to
   ensure they match your storage locations and allowed file types.
2. Place movie files in the root of your Movies directory; series folders can
   be pre-created with `.movieseries` if desired.
3. Run the cleanup script from the repository root:

   ```bash
   ./mediacleanup.sh
   ```

4. Verify that standalone movies remain in the root while series movies move
   into prefix folders with `.movieseries`.
