# Research: Cleanup Script Optimization

## Decision: Performance measurement method
- Rationale: Comparing total runtime on a fixed dataset with the same pre-execution action list provides a stable, user-facing metric.
- Alternatives considered: Measuring individual sub-steps only; focusing solely on CPU time.

## Decision: Equivalence definition for regression checks
- Rationale: Pre-execution action list equivalence avoids variability from filesystem side effects and preserves intended behavior.
- Alternatives considered: Final filesystem state comparison; requiring both action list and filesystem state to match.

## Decision: Scope of changes
- Rationale: Limit changes to refactoring and performance improvements to avoid altering cleanup rules or configuration behavior.
- Alternatives considered: Allowing rule changes to improve speed; allowing only bug-fix rule changes.

## Decision: Reference dataset sizing
- Rationale: A representative dataset without fixed size provides flexibility across user libraries while enabling consistent before/after comparison.
- Alternatives considered: Mandated size thresholds (e.g., 50k–100k files).

## Decision: Mixed media type coverage
- Rationale: Ensures action list equivalence across movies, TV, and other media to prevent regressions in mixed libraries.
- Alternatives considered: No explicit mixed-media requirement.
