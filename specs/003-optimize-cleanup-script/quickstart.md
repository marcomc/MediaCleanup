# Quickstart: Cleanup Script Optimization

## Goals
- Preserve pre-execution action list equivalence.
- Improve runtime by at least 25% on a representative dataset.
- Avoid any cleanup rule or configuration changes.

## Validate Behavior
1. Prepare a representative dataset snapshot.
2. Run cleanup to capture the pre-execution action list baseline.
3. Run cleanup again after optimization and compare action lists for equivalence.

## Validate Performance
1. Measure total runtime for the baseline run on the representative dataset.
2. Measure total runtime after optimization.
3. Confirm at least 25% improvement using percentage-only comparison.

## Safety Checks
- Confirm all move/rename/delete operations are logged before execution.
- Confirm target paths are constrained to configured media roots.
- Confirm configuration variables remain near the top of the script.

## Quality Checks
- Run `shellcheck` on modified shell scripts when available.
- Run `markdownlint` on updated Markdown files.
