# Implementation Plan: Organize TV Shows by Series and Season

**Branch**: `001-organize-tv-shows` | **Date**: 2026-01-17 | **Spec**: /Users/mmassari/Development/MediaCleanup/specs/001-organize-tv-shows/spec.md
**Input**: Feature specification from `/specs/001-organize-tv-shows/spec.md`

## Summary

Organize TV episode files into `Series.Name/Sxx/` folders after flattening
incoming subfolders and normalizing filenames, while preserving existing series
folders with a `.tvshow` marker and avoiding duplicate series directories.

## Technical Context

**Language/Version**: Bash (macOS system bash)  
**Primary Dependencies**: Standard macOS shell tools (find, mv, rm, awk, sed,
tr)  
**Storage**: Local filesystem under configured media directories  
**Testing**: Manual verification on sample folders and dry-run logging review  
**Target Platform**: macOS  
**Project Type**: Single project (shell scripts in repo root)  
**Performance Goals**: Complete one cleanup run within minutes for a personal
library  
**Constraints**: Only operate within explicit `MEDIA_DIRS`; avoid destructive
actions outside configured roots  
**Scale/Scope**: Thousands of files per run in a single-user media library

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Confirm destructive operations are limited to explicit, user-owned paths.
- Confirm rename/move/delete operations are logged for reversibility.
- Confirm environment-specific configuration lives in top-level variables.
- Confirm `README.md` updates and linting steps are planned for doc/script
  edits.

**Gate Status (pre-design)**: Pass

## Phase 0: Research

**Output**: /Users/mmassari/Development/MediaCleanup/specs/001-organize-tv-shows/research.md

- Decisions captured for marker files, season naming, case handling, and file
  eligibility.

## Phase 1: Design

**Outputs**:

- /Users/mmassari/Development/MediaCleanup/specs/001-organize-tv-shows/data-model.md
- /Users/mmassari/Development/MediaCleanup/specs/001-organize-tv-shows/contracts/file-organization.md
- /Users/mmassari/Development/MediaCleanup/specs/001-organize-tv-shows/quickstart.md

**Agent Context Updated**: /Users/mmassari/Development/MediaCleanup/AGENTS.md

## Constitution Check (post-design)

- Confirm destructive operations are limited to explicit, user-owned paths.
- Confirm rename/move/delete operations are logged for reversibility.
- Confirm environment-specific configuration lives in top-level variables.
- Confirm `README.md` updates and linting steps are planned for doc/script
  edits.

**Gate Status (post-design)**: Pass

## Project Structure

### Documentation (this feature)

```text
specs/001-organize-tv-shows/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code (repository root)

```text
.
├── cleanup_media.sh
├── rename.sh
└── README.md
```

**Structure Decision**: Single project with root-level shell scripts and
specs under `specs/001-organize-tv-shows/`.

## Complexity Tracking

No constitution violations identified.
