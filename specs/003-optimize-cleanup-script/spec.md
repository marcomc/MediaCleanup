<!-- markdownlint-disable MD013 -->
# Feature Specification: Cleanup Script Optimization

**Feature Branch**: `003-optimize-cleanup-script`  
**Created**: 2026-01-17  
**Status**: Draft  
**Input**: User description: "I want to optimise the cleanup script possibly making it faster and with no code duplications"

## Clarifications

### Session 2026-01-17

- Q: How should outcome equivalence be determined for comparisons? → A: Equivalence is based on the generated action list before execution.
- Q: Should performance targets include absolute runtime values? → A: Percentage only (no absolute runtime target).
- Q: Can optimization change cleanup rules or configuration behavior? → A: No, optimization must not change cleanup rules or configuration behavior.
- Q: Should the reference dataset size be explicitly defined? → A: No explicit size requirement; any representative dataset is acceptable.
- Q: Should action list equivalence apply across mixed media types? → A: Yes, action list equivalence must hold across mixed media types.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Faster Cleanup Runs (Priority: P1)

As a user running media cleanup, I want the cleanup run to finish faster on the same set of files so I can get results sooner without changing outcomes.

**Why this priority**: Run time directly impacts user productivity and is the primary pain point.

**Independent Test**: Run cleanup on a fixed sample set before and after the change and verify the runtime improvement with identical outputs.

**Acceptance Scenarios**:

1. **Given** a fixed media directory snapshot, **When** I run cleanup, **Then** the run completes within the target time improvement and produces the same pre-execution action list as before.
2. **Given** a fixed media directory snapshot, **When** I run cleanup twice, **Then** the runtime stays within the expected range and results are identical across runs.

---

### User Story 2 - Consistent Behavior Across Cleanup Actions (Priority: P2)

As a user, I want cleanup actions to behave consistently across similar cases so I can trust that all files are treated the same way.

**Why this priority**: Removing duplicated logic should eliminate inconsistencies that confuse users.

**Independent Test**: Use a dataset with similar file patterns and verify that the same rules apply across all applicable files.

**Acceptance Scenarios**:

1. **Given** multiple files that match the same cleanup rules, **When** I run cleanup, **Then** each file is handled consistently and in the same way.

---

### User Story 3 - No Behavioral Regression (Priority: P3)

As a user, I want the optimized cleanup to preserve existing outcomes so I do not need to re-learn or reconfigure my workflow.

**Why this priority**: Performance improvements should not introduce unexpected behavior changes.

**Independent Test**: Compare the before-and-after action reports for a representative dataset and confirm they match.

**Acceptance Scenarios**:

1. **Given** a representative media directory, **When** I run cleanup before and after the optimization, **Then** the resulting actions and outputs are equivalent.

---

### Edge Cases

- When the media directory contains a very large number of files (e.g., 100,000+), cleanup completes without errors and logs total runtime and action counts.
- Files with unusual or inconsistent naming formats are left unchanged and logged as skipped with a clear reason.
- If a cleanup run is interrupted and restarted, reruns remain deterministic and do not introduce new actions beyond the pre-execution action list.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST produce the same pre-execution action list for the same input dataset as prior to optimization.
- **FR-002**: System MUST reduce cleanup runtime by at least 25% on the reference dataset described in Assumptions, using percentage-only targets.
- **FR-003**: System MUST apply identical cleanup rules consistently across all files that match those rules.
- **FR-004**: Users MUST be able to run cleanup without changing existing configuration or usage.
- **FR-006**: System MUST preserve existing cleanup rules and configuration behavior; changes are limited to refactoring and performance improvements.
- **FR-005**: System MUST provide deterministic results for repeated runs on an unchanged dataset.
- **FR-007**: System MUST preserve pre-execution action list equivalence across mixed media types in a representative dataset.
- **FR-008**: System MUST log each planned move, rename, or delete before execution with enough detail to reverse it.
- **FR-009**: System MUST restrict actions to configured media roots and reject ambiguous or root-level paths.
- **FR-010**: System MUST provide a pre-execution action list output suitable for comparison between runs.

### Key Entities *(include if feature involves data)*

- **Media File**: A file within the configured media directories, including its name, location, and detected metadata.
- **Cleanup Action**: A planned or executed change applied to a media file (e.g., move, rename, delete).
- **Cleanup Run**: A single execution of cleanup over a set of media directories, producing a list of actions and outcomes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Cleanup completes at least 25% faster on the reference dataset while producing the same pre-execution action list.
- **SC-002**: 100% of repeated runs on an unchanged dataset yield identical action lists.
- **SC-003**: At least 95% of users report no regression in cleanup behavior on existing workflows during validation.
- **SC-004**: Zero new incorrect cleanup actions are introduced when compared against the reference dataset.

## Assumptions

- A reference dataset exists (or will be created) that represents typical usage and can be reused for before/after comparisons, without requiring a fixed size.
- Existing cleanup rules and user configuration are treated as the baseline behavior to preserve.
- Performance measurement will be based on total run time for the full cleanup, not partial steps.
