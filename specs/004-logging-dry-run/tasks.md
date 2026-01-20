---

description: "Task list for Logging Levels and Dry-Run"
---

# Tasks: Logging Levels and Dry-Run

**Input**: Design documents from `/specs/004-logging-dry-run/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Define log level and run mode defaults near the top of `cleanup_media.sh`
- [x] T002 Add command-line option parsing for `--log-level`, `--apply`, `--dry-run`, and `--help` in `cleanup_media.sh`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T003 Implement log level validation with fail-fast behavior for invalid values in `cleanup_media.sh`
- [ ] T004 Implement a centralized logging helper with level filtering and consistent formatting in `cleanup_media.sh`
- [x] T005 Add run session tracking (start/end timestamps and summary counts) in `cleanup_media.sh`
- [x] T006 Wire action recording to update per-action summary counts in `cleanup_media.sh`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Readable Run Output (Priority: P1) 🎯 MVP

**Goal**: Provide clear, consistent output with priority labels and accurate summaries.

**Independent Test**: Run a cleanup on a small sample and confirm formatted, labeled output and a matching summary.

### Implementation for User Story 1

- [ ] T007 [US1] Update `log_action`, `log_step`, and `log_dir_header` to use the new logging helper in `cleanup_media.sh`
- [ ] T008 [US1] Emit summary output with timestamps and counts in `cleanup_media.sh`
- [ ] T009 [US1] Strip media root prefixes from screen log paths in `cleanup_media.sh`

**Checkpoint**: User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Preview Changes Safely (Priority: P2)

**Goal**: Default to dry-run and allow explicit apply behavior with simulated outputs.

**Independent Test**: Run without apply and confirm no changes; run with apply and confirm actions execute.

### Implementation for User Story 2

- [x] T010 [US2] Enforce default dry-run mode with `--apply` override in `cleanup_media.sh`
- [x] T011 [US2] Update `plan_move`, `plan_rename`, `plan_remove`, and `plan_remove_dir` to simulate or execute based on mode in `cleanup_media.sh`
- [x] T012 [US2] Mark simulated actions in output and ensure the summary states no changes when dry-run in `cleanup_media.sh`

**Checkpoint**: User Story 2 should be independently functional

---

## Phase 5: User Story 3 - Control Verbosity (Priority: P3)

**Goal**: Allow users to adjust verbosity with standard levels, including ERROR-only.

**Independent Test**: Run with WARN and confirm INFO/DEBUG are suppressed; run with ERROR and confirm only errors appear.

### Implementation for User Story 3

- [ ] T013 [US3] Apply level filtering across all log output in `cleanup_media.sh`
- [ ] T014 [US3] Add ERROR-only level handling and validation in `cleanup_media.sh`

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T015 [P] Update usage and behavior notes for new flags in `README.md`
- [ ] T016 [P] Align validation steps with new flags in `specs/004-logging-dry-run/quickstart.md`
- [ ] T017 Run `shellcheck` on `cleanup_media.sh` and address findings in `cleanup_media.sh`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - No dependencies on other stories

### Parallel Opportunities

- T015 and T016 can run in parallel since they touch different files.
- User story tasks are sequential within `cleanup_media.sh` due to shared edits.

---

## Parallel Example: User Story 1

```bash
# No parallel tasks for US1: tasks touch the same file (cleanup_media.sh).
```

## Parallel Example: User Story 2

```bash
# No parallel tasks for US2: tasks touch the same file (cleanup_media.sh).
```

## Parallel Example: User Story 3

```bash
# No parallel tasks for US3: tasks touch the same file (cleanup_media.sh).
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deliver MVP
3. Add User Story 2 → Test independently
4. Add User Story 3 → Test independently
5. Finish Polish tasks

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Avoid cross-story dependencies that break independence
