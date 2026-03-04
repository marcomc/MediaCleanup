# Data Model: Logging Levels and Dry-Run

**Date**: 2026-01-20
**Spec**: ./specs/004-logging-dry-run/spec.md

## Entities

### Run Session

Represents a single cleanup execution.

**Fields**:
- **run_id**: Unique run identifier (timestamp-based string).
- **run_mode**: `dry-run` or `apply`.
- **log_level**: `ERROR`, `WARN`, `INFO`, `DEBUG`.
- **start_time**: Run start timestamp.
- **end_time**: Run end timestamp.
- **summary_counts**: Totals by action type and outcome (performed, simulated, skipped, failed).

**Validation rules**:
- `run_mode` MUST be `dry-run` unless explicitly set to `apply`.
- `log_level` MUST be one of the supported levels; otherwise the run fails without actions.

**State transitions**:
- `initialized` -> `running` -> `completed` or `failed`.

### Log Entry

A single output message emitted during a run.

**Fields**:
- **level**: `ERROR`, `WARN`, `INFO`, `DEBUG`.
- **message**: Human-readable text.
- **related_action**: Optional reference to an action record.

**Validation rules**:
- Every log entry MUST include a `level`.
- Entries below the configured `log_level` MUST be suppressed.

### Action Record

Represents an intended or completed filesystem action.

**Fields**:
- **action_type**: `MOVE`, `RENAME`, `DELETE`, `RMDIR` (existing action types).
- **target_path**: Target file or directory path.
- **source_path**: Source path when applicable.
- **outcome**: `performed`, `simulated`, `skipped`, `failed`.

**Validation rules**:
- `outcome` MUST match the run mode (`simulated` only in dry-run).
- Each action MUST be counted in the run summary.

## Relationships

- **Run Session** has many **Log Entries**.
- **Run Session** has many **Action Records**.
- **Log Entry** may reference one **Action Record**.
