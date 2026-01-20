# Contract: Cleanup Run Logging and Dry-Run

**Date**: 2026-01-20
**Spec**: /Users/mmassari/Development/MediaCleanup/specs/004-logging-dry-run/spec.md

## Inputs

- Run mode selected per execution (default dry-run, apply only when explicitly requested).
- Log level selected per execution (ERROR, WARN, INFO, DEBUG).

## Outputs

- Consistent, human-readable log messages labeled with priority level.
- Run start timestamp, run end timestamp, and summary timestamp.
- Summary with counts by action type and outcome (performed, simulated, skipped, failed).

## Rules

- Without an explicit apply option, all actions are simulated and marked as such.
- With the apply option, actions are performed and logged with outcomes.
- If an unrecognized log level is provided, the run ends without actions.
- Messages below the selected log level are suppressed.
- An ERROR-only mode shows only error messages.
