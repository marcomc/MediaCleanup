# Removal order proposal

## Goal

Investigate whether we can safely move the “Removing unwanted files” pass ahead of the “Moving files from nested dirs to root” and “Normalizing filenames” steps so the CLI touches each file fewer times, while keeping all allowed media intact.

## Current assumptions

- Removal currently runs after normalization and organization; it scans every file under the configured roots and deletes anything whose extension is not whitelisted.
- Moving/normalization assume files are present (including nested ones) before they are renamed/moved into canonical locations and marker directories.

## Acceptance criteria

1. Any reordered pipeline must not delete media that only becomes valid after normalization or movement.
2. The action list/logs remain deterministic, and dry-runs with no changes can still be used to preview the steps.
3. If a strict reorder doesn’t meet (1)–(2), a documented alternative (e.g., merging removal into later scans or skipping passes for already-conforming files) is proposed.

## Experiment plan

1. Build a virtual dry-run scenario with nested files to observe the behavior when removal runs first; capture logs/action counts and compare against the baseline.
2. Document whether the early removal pass sees the normalized names or the pre-move paths, and whether any allowed files are deleted.
3. If unsafe, outline a merged pass or conditional skip and describe how to keep the action list consistent.
