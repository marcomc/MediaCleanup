# Implementation Plan: Python-Only MediaCleanup Migration

**Branch**: `005-python-migration-cleanup` | **Date**: 2026-03-04 | **Spec**: `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/spec.md`
**Input**: Feature specification from `/specs/005-python-migration-cleanup/spec.md`

## Summary

Migrate MediaCleanup from Bash to a Python-only runtime while preserving existing cleanup behavior and safety guarantees. Replace active Bash runtime/tooling/docs with Python-first equivalents, enforce new config format only, support macOS and Linux, and require full macOS end-to-end validation before completion.

## Technical Context

**Language/Version**: Python 3.11+  
**Primary Dependencies**: Python standard library, pytest, ruff, markdownlint-cli  
**Storage**: Local filesystem + user config file (`~/.mediacleanup.toml`)  
**Testing**: pytest (unit + integration), fixture-driven end-to-end dry-run/apply checks  
**Target Platform**: macOS and Linux  
**Project Type**: Single-project CLI utility  
**Performance Goals**: Dry-run/apply on representative fixtures complete within current baseline ±15%; deterministic repeat runs produce no new changes at steady state  
**Constraints**: No destructive changes without explicit apply mode; remove Bash from active runtime/user docs; reject legacy config format  
**Scale/Scope**: Multiple media roots and thousands of files per root; logs + action-list artifact retained

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- ✅ Destructive operations remain limited to explicit configured user-owned paths.
- ✅ Rename/move/delete operations remain pre-logged for reversibility.
- ✅ Environment-specific configuration remains externalized (user config, top-level defaults).
- ✅ README/lint workflow updates are part of scope.
- ✅ Constitution language is aligned to Python-first governance for this feature scope.
- ✅ Implementation gate remains: re-check constitution alignment after design and before completion.

## Project Structure

### Documentation (this feature)

```text
specs/005-python-migration-cleanup/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── cleanup-run.openapi.yaml
└── tasks.md
```

### Source Code (repository root)

```text
src/
├── mediacleanup.py
└── __init__.py

scripts/
└── install_mediacleanup.py

tests/
└── test_mediacleanup.py

mediacleanup.py
Makefile
README.md
AGENTS.md
CHANGELOG.md
mediacleanup.toml.sample
```

**Structure Decision**: Keep single-project CLI layout. Replace root shell entrypoint and shell installer with Python equivalents, preserve `src/` + `tests/` organization, and update project-level docs/tooling in place.

## Phase 0: Research Plan

Produce `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/research.md` with final decisions for:

1. Python CLI entrypoint/package layout for parity and maintainability.
2. New config schema + strict validation strategy (legacy format rejected with migration guidance).
3. Cross-platform macOS/Linux filesystem handling details for safe moves/renames/deletes.
4. Test strategy split (unit/integration/E2E) and representative fixture coverage.
5. Lint/quality gate replacement for shellcheck-era workflow.
6. Bash-reference removal boundary (active vs historical docs).
7. Constitution amendment scope to align governance with Python-first reality.

Each item must include: **Decision**, **Rationale**, **Alternatives considered**.

## Phase 1: Design & Contracts

### Data Model

Create `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/data-model.md` defining:

- **CleanupRun**: run_id, mode, timestamps, duration, status, counters.
- **ActionRecord**: action type, source, destination, outcome, timestamp.
- **ConfigurationProfile**: media_dirs, allowed_file_ext, log level/defaults, validation rules.
- **MediaRoot**: root path, accessibility state, marker-discovery role.
- **DocumentationArtifact**: path, active/historical classification, Bash-reference status.

Include relationships, uniqueness, and state transitions where relevant.

### Contracts

Create `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/contracts/cleanup-run.openapi.yaml` as behavioral contract for run lifecycle and action reporting:

- `POST /cleanup-runs` (start dry-run or apply run)
- `GET /cleanup-runs/{runId}` (run summary)
- `GET /cleanup-runs/{runId}/actions` (action list retrieval)
- `GET /health/validation` (validation readiness snapshot)

Document expected failures: invalid config, unsafe paths, collisions, unreadable roots.

### Quickstart

Create `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/quickstart.md` covering:

- prerequisites (Python 3.11+, macOS/Linux)
- install flow
- new config creation (legacy format unsupported)
- dry-run/apply usage
- lint/test commands
- active-doc/runtime Bash-removal verification
- mandatory macOS full E2E validation step
- Linux smoke validation step for install + dry-run/apply parity
- timed setup verification step for the under-10-minute success criterion

### Agent Context Update

Run:

`/Users/mmassari/Development/MediaCleanup/.specify/scripts/bash/update-agent-context.sh codex`

Ensure only new Python-era technologies/workflows are added and manual AGENTS additions are preserved.

## Phase 2 Preview (for `/speckit.tasks`)

Task breakdown will include:

1. Implement Python runtime entrypoint + core cleanup logic parity.
2. Replace installer and config sample with Python-first versions.
3. Remove active Bash runtime artifacts and in-scope references.
4. Update docs/governance files for Python-first workflow.
5. Add/adjust unit/integration/E2E tests and fixtures.
6. Run lint/tests; enforce macOS E2E gate; record evidence.

## Public Interfaces / Contracts to Preserve or Add

- CLI flags: `--dry-run`, `--apply`, `--log-level`, `--help`, `--version` (and config override if retained).
- Config contract: `~/.mediacleanup.toml` with required keys `media_dirs`, `allowed_file_ext`; legacy config rejected with actionable guidance.
- Action-list artifact contract: tab-separated `ACTION<TAB>SOURCE<TAB>DEST` in `/tmp/mediacleanup/action-list-<timestamp>.txt`.
- Design-time API contract: `contracts/cleanup-run.openapi.yaml`.

## Test Cases and Acceptance Scenarios

1. Dry-run yields zero filesystem mutations.
2. Apply mode performs expected move/rename/delete/marker operations.
3. Deterministic repeat runs converge to steady state.
4. Missing/invalid config fails with actionable error.
5. Unsafe/ambiguous paths are rejected.
6. TV episode and movie-series organization parity is preserved.
7. Destination collision behavior is deterministic and logged.
8. Installer behavior with existing config and permission-denied targets is correct.
9. Active docs/runtime contain no in-scope Bash references after migration.
10. Linux smoke checks pass and macOS full E2E validation passes.
11. Install-and-first-run flow is timed and completes in under 10 minutes.

## Assumptions and Defaults

- Bash reference removal applies to active runtime and active user docs; historical/archive mentions may remain as context.
- Legacy config is not auto-migrated; users recreate config from guidance/sample.
- macOS and Linux are supported platforms; macOS is required full validation gate.
- OpenAPI contract is a behavior specification artifact for planning/testing.

## Post-Design Constitution Re-Check Criteria

Plan is only complete if post-design re-check confirms:

- no safety principle regressions,
- reversibility/traceability maintained,
- configuration externalization maintained,
- README + lint/test workflow updated,
- constitution amended to remove shell-only policy conflict.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
| --------- | ---------- | ----------------------------------- |
| Constitution amendment in feature | Existing governance conflicts with approved Python-only direction | Deferring amendment would keep plan in policy violation |
