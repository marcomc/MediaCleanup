# Feature Specification: Logging Levels and Dry-Run

**Feature Branch**: `004-logging-dry-run`  
**Created**: 2026-01-20  
**Status**: Draft  
**Input**: User description: "I wan to - Improve the logging system with cleaner output and log levels. - Add dry-run mode."

## Clarifications

### Session 2026-01-20

- Q: How are log level and dry-run set for a run? → A: Per-run command-line options for log level and dry-run.
- Q: What is the default mode for a run? → A: Default is dry-run; real changes require an explicit `--apply` option.
- Q: How should invalid log levels be handled? → A: Fail the run immediately on invalid log level.
- Q: Should timestamps be included in output? → A: Include timestamps only at start, end, and summary.
- Q: Should there be a lowest-noise mode? → A: Add an errors-only option.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Readable Run Output (Priority: P1)

As a user running a cleanup, I want clear, consistent output with message priority labels so I can quickly understand what happened and spot problems.

**Why this priority**: This is the primary feedback channel during a run and must be trustworthy to make decisions.

**Independent Test**: Run a cleanup on a small sample and confirm every message uses the same format and includes a priority label, with a summary that matches the run outcome.

**Acceptance Scenarios**:

1. **Given** a standard run with mixed actions, **When** the run completes, **Then** each message shows a priority label and the output format is consistent throughout.
2. **Given** a run that includes warnings or errors, **When** output is reviewed, **Then** warning and error messages are clearly distinguishable from informational messages.

---

### User Story 2 - Preview Changes Safely (Priority: P2)

As a cautious user, I want a dry-run option to preview intended changes so I can verify safety before making any changes.

**Why this priority**: Users need confidence that changes are correct before modifying media.

**Independent Test**: Run the tool in dry-run mode against a sample set and verify that no changes occur while all intended actions are listed.

**Acceptance Scenarios**:

1. **Given** dry-run mode is enabled, **When** a cleanup is executed, **Then** no items are modified and the output lists all intended actions as simulated.
2. **Given** dry-run mode is enabled, **When** the summary is displayed, **Then** it clearly states that no changes were made.

---

### User Story 3 - Control Verbosity (Priority: P3)

As a user who runs cleanups regularly, I want to adjust output verbosity so routine runs stay quiet while troubleshooting stays detailed.

**Why this priority**: Different contexts need different levels of detail without changing functionality.

**Independent Test**: Run the same cleanup at two different verbosity settings and confirm the output content changes accordingly.

**Acceptance Scenarios**:

1. **Given** the log level is set to warnings only, **When** a run includes informational messages, **Then** only warnings and errors appear in the output.
2. **Given** the log level is set to debug, **When** a run is executed, **Then** detailed step messages are included in the output.

---

### Edge Cases

- What happens when there are no items to process?
- How does the system handle an unrecognized log level selection?
- What happens when an action fails due to an access or permission issue?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST output messages in a consistent, human-readable format for the entire run.
- **FR-002**: System MUST label each message with a priority level (ERROR, WARN, INFO, DEBUG).
- **FR-003**: System MUST allow users to choose a priority level for a run.
- **FR-004**: System MUST default to INFO when no level is specified.
- **FR-005**: System MUST suppress messages below the selected priority level.
- **FR-006**: System MUST provide a dry-run mode that performs no changes while reporting intended actions.
- **FR-007**: System MUST clearly mark simulated actions in dry-run output and state "no changes made" in the summary.
- **FR-008**: System MUST provide a run summary that includes counts of actions by type and outcome (performed, simulated, skipped, failed).
- **FR-009**: System MUST fail the run and notify the user when an unrecognized level is provided.
- **FR-010**: System MUST allow users to set log level and dry-run per run using command-line options.
- **FR-011**: System MUST default to dry-run unless an explicit apply option is provided.
- **FR-012**: System MUST perform real changes only when `--apply` is specified.
- **FR-013**: System MUST include timestamps at run start, run end, and in the summary.
- **FR-014**: System MUST support an ERROR-only level that shows only error messages.

### Functional Requirement Acceptance Criteria

- **FR-001/FR-002**: Every message in a run includes a priority label and follows a single, consistent format.
- **FR-003/FR-004/FR-005**: When set to WARN, only WARN and ERROR messages are displayed; when not set, INFO is the default.
- **FR-006/FR-007**: Dry-run mode produces a list of simulated actions and explicitly states that no changes were made.
- **FR-008**: The summary includes totals by action type and outcome that match the per-item actions.
- **FR-009**: An unrecognized level results in a user-visible notice and the run ends without actions.
- **FR-010**: A run can be configured via options without changing any persistent settings.
- **FR-011/FR-012**: Without `--apply`, all actions are simulated; with `--apply`, actions are performed.
- **FR-013**: Start, end, and summary timestamps are present while individual messages omit timestamps.
- **FR-014**: When set to ERROR, only error messages are displayed.

### Key Entities *(include if feature involves data)*

- **Run Session**: A single cleanup execution with selected priority level, run mode, and start/end time.
- **Log Entry**: A message with a priority level, text, and an optional related action.
- **Action Record**: An intended or completed action with type, target item, and outcome (performed, simulated, skipped, failed).

## Assumptions

- The standard priority levels are ERROR, WARN, INFO, and DEBUG.
- Log level and dry-run are set per run and do not persist across runs.
- Invalid log levels cause the run to exit without actions.
- Default behavior is a dry-run unless `--apply` is specified.
- No external integrations or new storage systems are required.
- Out of scope: changing cleanup rules, adding new media types, or introducing long-term log storage.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of output messages include a priority label from the supported set.
- **SC-002**: In dry-run mode, 0 items are modified compared to the pre-run state.
- **SC-003**: When the log level is set to WARN, output contains zero INFO or DEBUG messages.
- **SC-004**: Run summaries match actual outcomes with 0 discrepancies between per-item actions and totals.
