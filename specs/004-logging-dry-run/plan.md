# Implementation Plan: Logging Levels and Dry-Run

**Branch**: `004-logging-dry-run` | **Date**: 2026-01-20 | **Spec**: ./specs/004-logging-dry-run/spec.md
**Input**: Feature specification from `/specs/004-logging-dry-run/spec.md`

## Summary

Add leveled logging with consistent output formatting, introduce a safe default dry-run mode requiring explicit apply, and ensure summaries reflect action outcomes.

## Technical Context

**Language/Version**: Bash (macOS system bash)  
**Primary Dependencies**: Standard macOS shell tools (find, mv, rm, awk, sed, tr)  
**Storage**: Local filesystem under configured media directories  
**Testing**: Manual verification on representative sample runs; run `shellcheck` and `markdownlint` when available  
**Target Platform**: macOS  
**Project Type**: Single script repository  
**Performance Goals**: No material runtime regression on the same dataset  
**Constraints**: Preserve path guards; log destructive actions before execution; screen output should omit media root prefixes (DEBUG shows full paths); default log level INFO with no INFO prefix; default to dry-run unless explicitly applied; no external dependencies  
**Scale/Scope**: Personal media libraries ranging from small samples to large collections (100k+ files)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Confirm destructive operations are limited to explicit, user-owned paths. (Planned: retain and reuse `MEDIA_DIRS` path validation.)
- Confirm rename/move/delete operations are logged for reversibility. (Planned: preserve action logging and ensure summaries include outcomes.)
- Confirm environment-specific configuration lives in top-level variables. (Planned: keep configuration variables at the top of the script.)
- Confirm `README.md` updates and linting steps are planned for doc/script edits. (Planned: update usage notes for new flags; run `shellcheck`/`markdownlint`.)

**Gate Status (pre-design)**: Pass

## Phase 0: Research

**Output**: ./specs/004-logging-dry-run/research.md

- Decisions captured for default run mode, log levels, invalid input handling, timestamp policy, and configuration mechanism.

## Phase 1: Design

**Outputs**:

- ./specs/004-logging-dry-run/data-model.md
- ./specs/004-logging-dry-run/contracts/run-logging.md
- ./specs/004-logging-dry-run/quickstart.md

**Agent Context Updated**: ./AGENTS.md

## Constitution Check (post-design)

- Confirm destructive operations are limited to explicit, user-owned paths.
- Confirm rename/move/delete operations are logged for reversibility.
- Confirm environment-specific configuration lives in top-level variables.
- Confirm `README.md` updates and linting steps are planned for doc/script edits.

**Gate Status (post-design)**: Pass

## Project Structure

### Documentation (this feature)

```text
specs/004-logging-dry-run/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code (repository root)

```text
mediacleanup.sh
mediacleanup.conf.sample
README.md
```

**Structure Decision**: Single script repository with root-level shell scripts; logging/dry-run changes apply to `mediacleanup.sh`, with README updates for usage.

## Complexity Tracking

No constitution violations identified.
