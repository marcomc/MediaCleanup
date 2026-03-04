# Tasks: Python-Only MediaCleanup Migration

**Input**: Design documents from `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/`  
**Prerequisites**: plan.md, spec.md  
**Tests**: Included (spec requires automated validation and macOS end-to-end verification).  
**Organization**: Tasks are grouped by user story so each story is independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Task can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: User story label (`[US1]`, `[US2]`, `[US3]`) for story-phase tasks only
- Every task includes at least one exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish Python project scaffolding and baseline tooling.

- [ ] T001 Create Python package entry scaffold in `/Users/mmassari/Development/MediaCleanup/src/__init__.py`
- [ ] T002 Create root CLI launcher in `/Users/mmassari/Development/MediaCleanup/mediacleanup.py`
- [ ] T003 [P] Create Python installer script scaffold in `/Users/mmassari/Development/MediaCleanup/scripts/install_mediacleanup.py`
- [ ] T004 [P] Add Python lint/test/install targets in `/Users/mmassari/Development/MediaCleanup/Makefile`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core behavior and safety infrastructure required by all user stories.

**⚠️ CRITICAL**: No user story implementation starts before this phase completes.

- [ ] T005 Implement CLI argument parsing and mode selection (`--dry-run`, `--apply`, `--log-level`, `--version`) in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T006 Implement structured action logging and summary counters in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T007 Implement explicit path-safety guards for configured media roots in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T008 Implement config loader/validator for new `~/.mediacleanup.toml` format in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T009 [P] Add shared media fixture generator helpers in `/Users/mmassari/Development/MediaCleanup/tests/conftest.py`
- [ ] T010 Add foundational regression tests for config validation and unsafe path rejection in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`

**Checkpoint**: Foundation complete; user stories can now be developed and tested independently.

---

## Phase 3: User Story 1 - Run Cleanup with Python Command (Priority: P1) 🎯 MVP

**Goal**: Preserve cleanup behavior parity under a Python command with dry-run/apply safety.

**Independent Test**: Run dry-run and apply against representative fixtures; verify parity for move/rename/delete/markers/action-list output and zero mutation in dry-run.

### Tests for User Story 1

- [ ] T011 [US1] Add dry-run no-mutation integration test in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`
- [ ] T012 [US1] Add apply-mode parity integration test for TV/movie organization in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`
- [ ] T013 [US1] Add collision-handling and deterministic repeat-run test in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`

### Implementation for User Story 1

- [ ] T014 [US1] Implement move-files-to-root and empty-subdir cleanup workflow in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T015 [US1] Implement filename normalization rules in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T016 [US1] Implement TV episode organization with `.tvshow` marker behavior in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T017 [US1] Implement movie series grouping with `.movieseries` marker behavior in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T018 [US1] Implement unsupported-file pruning and action-list artifact writing in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T019 [US1] Wire root launcher to package `main()` and verify CLI parity in `/Users/mmassari/Development/MediaCleanup/mediacleanup.py`

**Checkpoint**: User Story 1 is independently functional and testable (MVP).

---

## Phase 4: User Story 2 - Install and Configure Without Bash Workflow (Priority: P2)

**Goal**: Provide Python-only installation and new-format configuration workflow.

**Independent Test**: Execute install flow in clean fixture environment and verify binary creation, config creation, and explicit rejection guidance for legacy config format.

### Tests for User Story 2

- [ ] T020 [US2] Add installer behavior tests (new install + existing config prompt path) in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`
- [ ] T021 [US2] Add legacy-config rejection and migration-guidance test in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`

### Implementation for User Story 2

- [ ] T022 [US2] Implement interactive install flow, binary copy, and config creation in `/Users/mmassari/Development/MediaCleanup/scripts/install_mediacleanup.py`
- [ ] T023 [US2] Replace sample config with TOML schema and required keys in `/Users/mmassari/Development/MediaCleanup/mediacleanup.toml.sample`
- [ ] T024 [US2] Update install/uninstall/check-prereq commands for Python workflow in `/Users/mmassari/Development/MediaCleanup/Makefile`
- [ ] T025 [US2] Ensure runtime surfaces actionable errors for missing/invalid/legacy config in `/Users/mmassari/Development/MediaCleanup/src/mediacleanup.py`
- [ ] T026 [US2] Add explicit permission-denied installer handling test coverage in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`

**Checkpoint**: User Story 2 works independently and does not require Bash installer/runtime usage.

---

## Phase 5: User Story 3 - Use Consistent Python-Only Project Guidance (Priority: P3)

**Goal**: Align active documentation and governance with Python-only workflow.

**Independent Test**: Search active runtime/user documentation and confirm no conflicting Bash guidance remains; all command examples are valid for Python workflow.

### Tests for User Story 3

- [ ] T027 [US3] Add doc-consistency verification test for active Bash-reference exclusions in `/Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py`

### Implementation for User Story 3

- [ ] T028 [US3] Update usage/install/config docs to Python-only guidance in `/Users/mmassari/Development/MediaCleanup/README.md`
- [ ] T029 [US3] Update project workflow/technology guidance to Python-first in `/Users/mmassari/Development/MediaCleanup/AGENTS.md`
- [ ] T030 [US3] Record migration release notes and behavior changes in `/Users/mmassari/Development/MediaCleanup/CHANGELOG.md`
- [ ] T031 [US3] Confirm and finalize governance/template workflow references for Python-first policy in `/Users/mmassari/Development/MediaCleanup/.specify/memory/constitution.md`

**Checkpoint**: User Story 3 is independently verifiable by documentation scan + command validation.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, contracts/design artifacts, and release readiness checks.

- [ ] T032 [P] Create design data model document in `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/data-model.md`
- [ ] T033 [P] Create behavior contract in `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/contracts/cleanup-run.openapi.yaml`
- [ ] T034 [P] Create migration quickstart verification guide (including in-scope active artifact list) in `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/quickstart.md`
- [ ] T035 Complete constitution gate re-check and record pass/fail evidence in `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/plan.md`
- [ ] T036 Run Python and Markdown quality gates via `/Users/mmassari/Development/MediaCleanup/Makefile`
- [ ] T037 Run macOS full end-to-end validation and record results in `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/research.md`
- [ ] T038 Run Linux install + dry-run/apply smoke parity validation and record results in `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/research.md`
- [ ] T039 Measure install-and-first-run elapsed time and record under-10-minute evidence in `/Users/mmassari/Development/MediaCleanup/specs/005-python-migration-cleanup/research.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies.
- **Phase 2 (Foundational)**: depends on Phase 1; blocks all user stories.
- **Phase 3 (US1)**: depends on Phase 2; defines MVP.
- **Phase 4 (US2)**: depends on Phase 2; can run in parallel with US1 after foundation is stable, but usually follows MVP completion.
- **Phase 5 (US3)**: depends on Phase 2; can run in parallel with US2 if staffed.
- **Phase 6 (Polish)**: depends on completion of selected user stories.

### User Story Dependencies

- **US1 (P1)**: no dependency on other stories.
- **US2 (P2)**: no dependency on US1 implementation details; shares foundational config/runtime layers.
- **US3 (P3)**: depends on final decisions from US1/US2 so docs reflect actual behavior.

### Dependency Graph (Story Completion Order)

- `Foundational -> US1 -> (US2, US3) -> Polish`

---

## Parallel Execution Examples

### User Story 1

```sh
Task: "T011 [US1] Add dry-run no-mutation integration test in /Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py"
Task: "T012 [US1] Add apply-mode parity integration test in /Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py"
Task: "T013 [US1] Add collision/repeat-run deterministic test in /Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py"
```

### User Story 2

```sh
Task: "T020 [US2] Add installer behavior tests in /Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py"
Task: "T021 [US2] Add legacy-config rejection test in /Users/mmassari/Development/MediaCleanup/tests/test_mediacleanup.py"
Task: "T023 [US2] Replace sample config in /Users/mmassari/Development/MediaCleanup/mediacleanup.toml.sample"
```

### User Story 3

```sh
Task: "T028 [US3] Update README Python-only guidance in /Users/mmassari/Development/MediaCleanup/README.md"
Task: "T029 [US3] Update AGENTS Python-first workflow in /Users/mmassari/Development/MediaCleanup/AGENTS.md"
Task: "T030 [US3] Update migration release notes in /Users/mmassari/Development/MediaCleanup/CHANGELOG.md"
```

---

## Implementation Strategy

### MVP First (US1)

1. Complete Phase 1 and Phase 2.
2. Deliver Phase 3 (US1) fully.
3. Validate US1 independent tests and parity behavior.
4. Demo/release MVP behavior before extending scope.

### Incremental Delivery

1. Add US2 install/config workflow once US1 is stable.
2. Add US3 docs/governance alignment after runtime/install behavior is final.
3. Finish with cross-cutting artifacts and release gates in Phase 6.

### Validation Rule

All tasks must preserve dry-run safety and reversibility logging; macOS full E2E validation is mandatory before completion.
