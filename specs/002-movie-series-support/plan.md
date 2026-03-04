# Implementation Plan: Movie Series Support

**Branch**: `002-movie-series-support` | **Date**: 2026-01-17 | **Spec**: ./specs/002-movie-series-support/spec.md
**Input**: Feature specification from `/specs/002-movie-series-support/spec.md`

## Summary

Keep standalone movies in the root, group movie series with shared prefixes
into folders marked by `.movieseries`, and preserve those folders while keeping
TV show rules as the highest precedence.

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

**Output**: ./specs/002-movie-series-support/research.md

- Decisions captured for movie series detection, prefix naming, and marker
  handling.

## Phase 1: Design

**Outputs**:

- ./specs/002-movie-series-support/data-model.md
- ./specs/002-movie-series-support/contracts/movie-organization.md
- ./specs/002-movie-series-support/quickstart.md

**Agent Context Updated**: ./AGENTS.md

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
specs/002-movie-series-support/
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
├── mediacleanup.sh
└── README.md
```

**Structure Decision**: Single project with root-level shell scripts and
specs under `specs/002-movie-series-support/`.

## Complexity Tracking

No constitution violations identified.
