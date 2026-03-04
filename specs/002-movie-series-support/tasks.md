---

description: "Task list for movie series support"
---

# Tasks: Movie Series Support

**Input**: Design documents from `/specs/002-movie-series-support/`
**Prerequisites**: plan.md (required), spec.md (required for user stories),
research.md, data-model.md, contracts/

**Tests**: Tests are not requested for this feature.

**Organization**: Tasks are grouped by user story to enable independent
implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Update README.md with movie series behavior and marker usage
- [x] T002 [P] Document `.movieseries` handling in mediacleanup.sh

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story
can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Implement movie-series prefix parser in mediacleanup.sh
- [x] T004 Implement `.movieseries` marker detection/creation in
  mediacleanup.sh
- [x] T005 Implement movie-series folder lookup (case-insensitive) in
  mediacleanup.sh
- [x] T006 Ensure TV show detection continues to take precedence in
  mediacleanup.sh
- [x] T007 Add logging for all move/rename/delete actions in mediacleanup.sh

**Checkpoint**: Foundation ready - user story implementation can now begin in
parallel

---

## Phase 3: User Story 1 - Keep Standalone Movies at Root (Priority: P1) 🎯 MVP

**Goal**: Leave standalone movie files in the root directory.

**Independent Test**: Drop a standalone movie in the root and verify it remains
there after cleanup.

### Implementation for User Story 1

- [x] T008 [US1] Skip moving standalone movie files in mediacleanup.sh
- [x] T009 [US1] Prevent movie grouping when only a single prefix match exists
  in mediacleanup.sh

**Checkpoint**: User Story 1 should be fully functional and testable
independently

---

## Phase 4: User Story 2 - Group Movie Series into Folders (Priority: P2)

**Goal**: Group movie series into prefix folders with `.movieseries` markers.

**Independent Test**: Place multiple movies with the same prefix and verify they
move into a shared folder with `.movieseries`.

### Implementation for User Story 2

- [x] T010 [US2] Create movie series folder (if missing) in mediacleanup.sh
- [x] T011 [US2] Add `.movieseries` marker to series folder in
  mediacleanup.sh
- [x] T012 [US2] Move matching movie files into series folder in
  mediacleanup.sh

**Checkpoint**: User Story 2 should be fully functional and testable
independently

---

## Phase 5: User Story 3 - Preserve Movie Series Folders (Priority: P3)

**Goal**: Protect `.movieseries` folders from cleanup or flattening.

**Independent Test**: Mark a folder with `.movieseries`, add a matching movie,
run cleanup, and verify the folder remains and the movie is moved inside.

### Implementation for User Story 3

- [x] T013 [US3] Skip flattening directories containing `.movieseries` in
  mediacleanup.sh
- [x] T014 [US3] Allow grouping into existing `.movieseries` folders even with
  only one new matching file in mediacleanup.sh

**Checkpoint**: User Story 3 should be fully functional and testable
independently

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T015 [P] Run shellcheck on mediacleanup.sh (if available)
- [x] T016 [P] Run markdownlint on updated Markdown files

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user
  stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2)
- **User Story 2 (P2)**: Can start after Foundational (Phase 2)
- **User Story 3 (P3)**: Can start after Foundational (Phase 2)

### Within Each User Story

- Prefix parsing before folder creation
- Folder creation before file moves
- Marker rules before skip/cleanup behavior

### Parallel Opportunities

- T002, T015, and T016 can run in parallel with other tasks
- T010 and T011 can run in parallel after prefix parsing is complete
- T013 and T014 can run in parallel with other story tasks once markers exist

---

## Parallel Example: User Story 2

```bash
Task: "Create movie series folder (if missing) in mediacleanup.sh"
Task: "Add .movieseries marker to series folder in mediacleanup.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Expand to additional stories if desired

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Validate
3. Add User Story 2 → Test independently → Validate
4. Add User Story 3 → Test independently → Validate
5. Polish and documentation
