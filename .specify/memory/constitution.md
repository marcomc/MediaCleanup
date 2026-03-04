<!--
Sync Impact Report:
- Version change: N/A -> 0.1.0
- Modified principles: N/A (initial constitution)
- Added sections: Core Principles, Operational Safety, Development Workflow, Governance
- Removed sections: None
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md (checked, no changes required)
  - ✅ .specify/templates/tasks-template.md (checked, no changes required)
- Follow-up TODOs:
  - TODO(RATIFICATION_DATE): adoption date not provided
-->
# MediaCleanup Constitution

## Core Principles

### I. Safe, Explicit File Operations

All destructive operations MUST be scoped to explicit, user-owned paths declared
in configuration variables. Scripts MUST log every move, rename, and delete
action before executing it so changes are auditable.

### II. Deterministic, Idempotent Processing

Running a script multiple times MUST not introduce new changes after it reaches
a steady state. Normalization rules MUST be deterministic so the same input
yields the same output each run.

### III. Reversibility and Traceability

Renames and moves MUST produce logs that allow reversion. If a change cannot be
reverted, it MUST be explicitly documented as irreversible.

### IV. Minimal, Standard Dependencies

The primary implementation MUST use Python and standard library capabilities
where practical. Additional dependencies MUST be minimal, justified, and
clearly documented. Platform-specific assumptions MUST be explicit.

### V. Configuration Over Hardcoding

All environment-specific paths and behavioral switches MUST live in clearly
named configuration entries or top-level constants and be documented in
`README.md`.

## Operational Safety

- Tools MUST be reviewed for target paths and extension allowlists before
  execution.
- Destructive actions (delete/move) MUST never target root or ambiguous paths.
- If a tool touches multiple storage providers, each target MUST be a
  distinct top-level directory to avoid cross-volume confusion.

## Development Workflow

- Changes to Python tooling MUST keep path handling explicit and avoid unsafe
  wildcard expansion.
- Run Python linting on modified Python files and fix reported issues or
  document justified exceptions.
- Run `markdownlint` on modified Markdown files and fix issues before commit.
- Update `README.md` whenever tool usage or behavior changes.

## Governance

- This constitution supersedes any other development guidance in the repository.
- Amendments require documenting the change, updating the version, and recording
  the rationale in the Sync Impact Report at the top of this file.
- Versioning follows semantic versioning: MAJOR for breaking governance changes,
  MINOR for new principles/sections, PATCH for clarifications.
- Compliance is reviewed during plan/spec generation and before changes are
  merged into the main branch.

**Version**: 0.1.0 | **Ratified**: TODO(RATIFICATION_DATE): adoption date not
provided | **Last Amended**: 2026-01-17
