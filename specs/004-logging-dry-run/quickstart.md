# Quickstart: Logging Levels and Dry-Run

## Goals
- Provide clear, leveled output with consistent formatting.
- Default to safe dry-run behavior unless explicitly applied.
- Ensure summaries match per-action outcomes.

## Validate Logging Output
1. Run the script on a small sample set.
2. Confirm INFO-level messages do not include a `[INFO]` prefix.
3. Confirm warnings and errors are visually distinct from informational output.

## Validate Log Levels
1. Run with log level set to WARN.
2. Confirm INFO and DEBUG messages are suppressed.
3. Run with log level set to ERROR and confirm only error messages are shown.
4. Run with log level set to DEBUG and confirm full media paths are shown.

## Validate Dry-Run Default
1. Run without apply enabled.
2. Confirm no files change and simulated actions are clearly marked.
3. Confirm the summary explicitly states no changes were made.
4. Confirm dry-run stages planned moves/renames so later steps use the projected layout.

## Validate Apply Mode
1. Run with apply enabled on a controlled dataset.
2. Confirm actions are performed and outcomes are recorded.

## Safety Checks
- Verify output includes timestamps at run start, end, and summary.
- Verify the run aborts if an invalid log level is provided.

## Quality Checks
- Run `shellcheck` on modified shell scripts when available.
- Run `markdownlint` on updated Markdown files.
