# Research: Logging Levels and Dry-Run

**Date**: 2026-01-20
**Spec**: /Users/mmassari/Development/MediaCleanup/specs/004-logging-dry-run/spec.md

## Decision 1: Default run mode

- **Decision**: Default to dry-run; real changes require an explicit `--apply` option.
- **Rationale**: Safer default for a destructive script and aligns with reversible, cautious execution.
- **Alternatives considered**: Default to real run; remember last-used mode.

## Decision 2: Log level set

- **Decision**: Support ERROR, WARN, INFO, DEBUG, plus an ERROR-only mode.
- **Rationale**: Covers common troubleshooting needs while allowing minimal output for automation.
- **Alternatives considered**: INFO-only default without an ERROR-only option.

## Decision 3: Invalid log level handling

- **Decision**: Fail the run immediately and notify the user on unrecognized log level.
- **Rationale**: Prevents silent misconfiguration and avoids ambiguous logging behavior.
- **Alternatives considered**: Fallback to INFO with a warning; ignore invalid input.

## Decision 4: Timestamp policy

- **Decision**: Include timestamps only at run start, run end, and summary.
- **Rationale**: Keeps per-line output clean while still anchoring run timing for audits.
- **Alternatives considered**: Timestamp every message; no timestamps at all.

## Decision 5: Run configuration mechanism

- **Decision**: Log level and dry-run/apply are set per run using command-line options.
- **Rationale**: Keeps behavior explicit and scriptable without persistent state.
- **Alternatives considered**: Configuration file defaults; environment variables; interactive prompts.
