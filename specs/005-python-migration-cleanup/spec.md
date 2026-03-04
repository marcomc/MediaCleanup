# Feature Specification: Python-Only MediaCleanup Migration

**Feature Branch**: `005-python-migration-cleanup`  
**Created**: 2026-03-04  
**Status**: Draft  
**Input**: User description: "Port MediaCleanup to Python, migrate supporting tools and documentation, remove Bash traces, and verify the tool works correctly with full testing."

## Clarifications

### Session 2026-03-04

- Q: Should Bash-reference removal apply to all repository files or only active runtime/user-facing artifacts? → A: Remove Bash references from active runtime and active user-facing documentation; historical/archive mentions may remain for context.
- Q: Should legacy configuration be migrated automatically or replaced with a new required format? → A: Require only the new configuration format; users must recreate configuration manually using migration guidance.
- Q: Which operating systems must be officially supported by this migration? → A: Support macOS and Linux as officially supported platforms for runtime, setup workflow, and validation.
- Q: What validation depth is required to claim the migration works correctly? → A: Require unit/integration checks and end-to-end dry-run/apply validation on representative fixtures, with full execution required on macOS.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run Cleanup with Python Command (Priority: P1)

As a maintainer, I can run the cleanup process through a Python-based command and get the same outcomes as today so daily media organization continues without interruption.

**Why this priority**: The core value of the project is reliable media cleanup execution. If command behavior changes or breaks, the migration fails regardless of documentation updates.

**Independent Test**: Can be fully tested by running dry-run and apply executions on a representative media fixture and confirming expected moves, renames, removals, markers, and summaries are produced.

**Acceptance Scenarios**:

1. **Given** a valid project configuration and sample media files, **When** the maintainer runs a dry-run cleanup command, **Then** the system reports planned actions and leaves files unchanged.
2. **Given** the same setup, **When** the maintainer runs apply mode, **Then** the system performs the planned file operations and records an action list.
3. **Given** an invalid or missing configuration, **When** the maintainer runs the command, **Then** the system fails fast with clear guidance on remediation.

---

### User Story 2 - Install and Configure Without Bash Workflow (Priority: P2)

As a maintainer, I can install and configure the tool using updated project workflows that do not depend on Bash scripts.

**Why this priority**: Migration is incomplete if setup still requires legacy shell workflows; installation and configuration must align with the new runtime direction.

**Independent Test**: Can be tested by running the documented install flow in a clean environment and verifying executable placement, configuration generation, and first-run readiness.

**Acceptance Scenarios**:

1. **Given** a clean macOS or Linux environment, **When** the maintainer follows installation steps, **Then** the tool installs successfully and provides a usable default configuration.
2. **Given** an existing legacy configuration, **When** installation or first-run validation is performed, **Then** the workflow clearly reports that legacy format is unsupported and guides the maintainer to recreate configuration in the new format.

---

### User Story 3 - Use Consistent Python-Only Project Guidance (Priority: P3)

As a contributor, I can rely on project documentation and supporting artifacts that consistently describe the Python-based workflow.

**Why this priority**: Inconsistent documentation increases onboarding time, causes execution errors, and reintroduces deprecated workflows.

**Independent Test**: Can be tested by scanning repository docs/spec artifacts and confirming no remaining Bash workflow references while all required Python commands are documented.

**Acceptance Scenarios**:

1. **Given** the repository documentation set, **When** a contributor follows command examples and workflow notes, **Then** every referenced path and command is valid for the Python-based toolchain.
2. **Given** the same documentation set, **When** a contributor searches for deprecated Bash workflow references, **Then** no authoritative project document instructs use of removed Bash tooling.

---

### Edge Cases

- Existing media directories are unavailable or partially unreadable during a run.
- Destination file names collide with existing files during move/rename actions.
- Config extension lists include invalid entries and require validation behavior.
- Dry-run mode must still provide accurate collision and marker planning without changing filesystem content.
- Installation is invoked where target binary directories are not writable.
- Linux runtime behavior diverges from macOS path/permission expectations and must still satisfy parity requirements.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a Python-based primary command that supports dry-run and apply execution modes for the media cleanup workflow.
- **FR-002**: The system MUST preserve existing cleanup behavior for file normalization, episode organization, movie-series grouping, marker handling, and unsupported-file removal.
- **FR-003**: The system MUST keep destructive operations gated so no filesystem mutations occur unless apply mode is explicitly selected.
- **FR-004**: The system MUST produce human-readable run logs and a structured action list artifact for every run.
- **FR-005**: The system MUST provide installation and configuration workflows that are fully usable without legacy Bash scripts.
- **FR-006**: The system MUST update all user-facing project documentation and project-governance documents to describe only the supported Python workflow.
- **FR-007**: The system MUST remove deprecated Bash executables and Bash references from active runtime and active user-facing documentation that conflict with the Python-first workflow.
- **FR-008**: The system MUST include automated validation that covers core cleanup behavior in dry-run and apply modes.
- **FR-009**: The system MUST include repository-level quality checks so code and documentation updates can be validated before release.
- **FR-010**: The system MUST fail fast with actionable error messages for missing configuration, invalid configuration values, and non-runnable prerequisites.
- **FR-011**: The system MUST reject legacy configuration formats and provide explicit migration guidance for creating the required new configuration format.
- **FR-012**: The system MUST provide equivalent supported behavior on macOS and Linux for installation, dry-run/apply execution, and validation workflow.
- **FR-013**: The system MUST require successful unit/integration checks and full end-to-end dry-run/apply validation on macOS before completion is accepted.
- **FR-014**: The system MUST treat active-path Bash cleanup as in-scope for these artifacts: runtime entrypoints and scripts under repository root and `/scripts`, plus user-facing project documentation (`README.md`, `AGENTS.md`, and active feature docs under `/specs/005-python-migration-cleanup`).
- **FR-015**: The system MUST define fixture coverage for validation to include at minimum: nested files, TV episode organization, movie series grouping, filename normalization, unsupported extension removal, destination collisions, unreadable directory handling, and install permission-denied handling.
- **FR-016**: The system MUST block implementation acceptance until constitution language is updated to remove shell-only governance conflicts for this feature scope.

### Key Entities *(include if feature involves data)*

- **Cleanup Run**: A single execution session with mode, timestamps, per-action counts, per-outcome counts, and run-level status.
- **Configuration Profile**: User-maintained settings that define cleanup roots and allowed extensions.
- **Action Record**: A structured row representing one planned or executed operation with action type, source path, and destination path.
- **Media Root**: A configured filesystem root that scopes all cleanup operations.
- **Documentation Artifact**: Any authoritative repository document that defines usage, installation, constraints, and contributor workflow.

## Assumptions

- Current cleanup behavior in production usage is the functional baseline and should remain stable after migration.
- Existing users accept configuration format updates as long as migration guidance and a sample configuration are provided.
- Existing users migrating from legacy configuration will recreate their configuration manually using documented guidance.
- Maintainers can run the project with a modern Python runtime available locally on macOS or Linux.
- Existing spec/history files should be updated where they are considered active project guidance.
- Historical or archived records may retain Bash references when those references are clearly contextual and not presented as active workflow guidance.
- The OpenAPI contract produced for this feature is a design and validation artifact, not a commitment to expose a runtime network API.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of previously supported core cleanup scenarios (rename, move, marker creation, unwanted-file removal) produce equivalent outcomes under the new primary command on the same fixture dataset.
- **SC-002**: 100% of dry-run test scenarios perform zero filesystem mutations while still emitting complete planned-action output.
- **SC-003**: A full repository scan of authoritative docs and active workflow files finds zero remaining references to deprecated Bash execution paths.
- **SC-004**: Contributors can complete install-and-first-run setup in under 10 minutes using only documented Python-first instructions.
- **SC-005**: Automated test and lint checks complete successfully in local validation before merge, with no unresolved blocking findings.
- **SC-006**: End-to-end dry-run and apply validations on representative fixtures pass on macOS with zero mismatches against expected outcomes.
- **SC-007**: Linux smoke validation for install, dry-run, and apply completes successfully on the same representative fixture suite with no parity regressions against expected outcomes.
