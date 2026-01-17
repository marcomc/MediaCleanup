---

description: "Task list for Cleanup Script Optimization"
---

<!-- markdownlint-disable MD013 -->
# Tasks: Cleanup Script Optimization

**Input**: Design documents from `/specs/003-optimize-cleanup-script/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/
**Tests**: Not requested
**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish baseline measurements and artifacts

- [x] T001 Create baseline benchmark log in `specs/003-optimize-cleanup-script/benchmarks.md` with dataset description and initial runtime/action list snapshot
- [x] T002 [P] Capture baseline action list output in `specs/003-optimize-cleanup-script/action-list-baseline.txt` from the current `cleanup_media.sh` run

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared refactor groundwork required for all stories

- [x] T003 Audit and preserve pre-execution logging for move/rename/delete actions in `cleanup_media.sh`
- [x] T004 Add explicit guard checks for configured media roots and reject ambiguous/root paths in `cleanup_media.sh`
- [x] T005 Extract shared helper functions in `cleanup_media.sh` for common rule application and logging
- [x] T006 Normalize rule evaluation order in `cleanup_media.sh` to ensure deterministic pre-execution action list

**Checkpoint**: Foundation ready - user story implementation can begin

---

## Phase 3: User Story 1 - Faster Cleanup Runs (Priority: P1) 🎯 MVP

**Goal**: Reduce runtime by at least 25% without changing outputs

**Independent Test**: Re-run cleanup on the reference dataset and confirm runtime improves by 25% while action list matches baseline

### Implementation for User Story 1

- [x] T007 [US1] Add runtime timing capture in `cleanup_media.sh` for total run duration
- [x] T008 [US1] Consolidate repeated filesystem scans into single-pass operations in `cleanup_media.sh`
- [x] T009 [US1] Reduce repeated parsing by caching derived values in `cleanup_media.sh`
- [x] T010 [US1] Record post-optimization timings in `specs/003-optimize-cleanup-script/benchmarks.md`

**Checkpoint**: User Story 1 is complete and independently verifiable

---

## Phase 4: User Story 2 - Consistent Behavior Across Cleanup Actions (Priority: P2)

**Goal**: Ensure identical rule behavior across similar cases by removing duplication

**Independent Test**: Run cleanup on a dataset with similar file patterns and confirm consistent action list entries

### Implementation for User Story 2

- [x] T011 [US2] Centralize rule evaluation into a single code path in `cleanup_media.sh`
- [x] T012 [US2] Align per-type handling to shared helpers in `cleanup_media.sh` to eliminate inconsistent branching

**Checkpoint**: User Story 2 is complete and independently verifiable

---

## Phase 5: User Story 3 - No Behavioral Regression (Priority: P3)

**Goal**: Preserve existing outcomes and determinism

**Independent Test**: Compare pre-execution action list with baseline for mixed media datasets and confirm identical results

### Implementation for User Story 3

- [x] T013 [US3] Add or update action list snapshot output in `cleanup_media.sh` for before/after comparisons
- [x] T014 [US3] Document regression verification steps in `specs/003-optimize-cleanup-script/quickstart.md`
- [x] T015 [US3] Verify unchanged configuration compatibility in `specs/003-optimize-cleanup-script/benchmarks.md`

**Checkpoint**: User Story 3 is complete and independently verifiable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validation, documentation, and quality gates

- [x] T016 [P] Address `shellcheck` findings in `cleanup_media.sh`
- [x] T017 [P] Address `markdownlint` findings in `specs/003-optimize-cleanup-script/spec.md` and `specs/003-optimize-cleanup-script/tasks.md`
- [x] T018 [P] Update `README.md` if any flags, outputs, or behavior notes change
- [x] T019 [P] Run quickstart validation and record results in `specs/003-optimize-cleanup-script/benchmarks.md`
- [x] T020 [P] Record regression review summary for zero incorrect actions in `specs/003-optimize-cleanup-script/benchmarks.md`
- [x] T021 [P] Record validation feedback rate (target 95% no-regression) in `specs/003-optimize-cleanup-script/benchmarks.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - blocks all user stories
- **User Stories (Phase 3+)**: Depend on Foundational completion
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational - independent of US1
- **User Story 3 (P3)**: Can start after Foundational - independent of US1/US2

### Parallel Opportunities

- Setup: T002 can run in parallel with T001
- Polish: T016, T017, T018, T019, T020, T021 can run in parallel
- After Foundational: US1, US2, US3 phases can run in parallel if staffed

---

## Parallel Example: User Story 1

```bash
Task: "Add runtime timing capture in cleanup_media.sh"
Task: "Reduce repeated parsing by caching derived values in cleanup_media.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate runtime improvement and action list equivalence

### Incremental Delivery

1. Setup + Foundational
2. User Story 1 → verify performance and equivalence
3. User Story 2 → verify consistency on similar cases
4. User Story 3 → verify no regressions on mixed media datasets
5. Polish → finalize documentation and quality checks
