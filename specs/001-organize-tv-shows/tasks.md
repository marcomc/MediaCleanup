---

description: "Task list for organizing TV shows by series and season"
---

# Tasks: Organize TV Shows by Series and Season

**Input**: Design documents from `/specs/001-organize-tv-shows/`
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

- [x] T001 Update README.md with folder organization behavior and naming rules
- [x] T002 [P] Add season/series detection notes to mediacleanup.sh

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story
can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Implement series/season parsing helpers in mediacleanup.sh
- [x] T004 Implement `.tvshow` marker detection/creation in mediacleanup.sh
- [x] T005 Implement case-insensitive series folder lookup in mediacleanup.sh
- [x] T006 Implement allowed-extension filtering for organization in
  mediacleanup.sh
- [x] T007 Implement explicit handling for unparseable files in
  mediacleanup.sh
- [x] T008 Add logging for all move/rename/delete actions in mediacleanup.sh

**Checkpoint**: Foundation ready - user story implementation can now begin in
parallel

---

## Phase 3: User Story 1 - Organize Episodes by Series (Priority: P1) 🎯 MVP

**Goal**: Place episode files into `Series.Name/Sxx/` folders based on filename
series/season tokens.

**Independent Test**: Drop multiple `Series.Name.S07E*.mkv` files in a root
folder and verify they land in `Series.Name/S07/`.

### Implementation for User Story 1

- [x] T009 [US1] Create series folder (if missing) in mediacleanup.sh
- [x] T010 [US1] Create season subfolder (if missing) in mediacleanup.sh
- [x] T011 [US1] Move eligible episode files to series/season folders in
  mediacleanup.sh

**Checkpoint**: User Story 1 should be fully functional and testable
independently

---

## Phase 4: User Story 2 - Normalize and Flatten Incoming Drops (Priority: P2)

**Goal**: Ensure files in random subfolders are flattened and normalized before
organization.

**Independent Test**: Place episodes inside nested folders and confirm they are
flattened to the root, renamed, then organized.

### Implementation for User Story 2

- [x] T012 [US2] Move nested files to root before normalization in
  mediacleanup.sh
- [x] T013 [US2] Ensure normalization runs before series/season organization in
  mediacleanup.sh

**Checkpoint**: User Story 2 should be fully functional and testable
independently

---

## Phase 5: User Story 3 - Preserve TV Series Folders (Priority: P3)

**Goal**: Distinguish series folders from temporary drop folders to avoid
accidental deletion or flattening.

**Independent Test**: Add `.tvshow` markers to existing series folders and
confirm they are preserved during cleanup.

### Implementation for User Story 3

- [x] T014 [US3] Skip flattening directories containing `.tvshow` in
  mediacleanup.sh
- [x] T015 [US3] Ensure marker is created for new series folders in
  mediacleanup.sh

**Checkpoint**: User Story 3 should be fully functional and testable
independently

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T016 [P] Run shellcheck on mediacleanup.sh (if available)
- [x] T017 [P] Run markdownlint on updated Markdown files
- [x] T018 [P] Validate runtime duration on a sample library and note results in
  README.md performance notes section

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

- Parsing helpers before folder creation
- Folder creation before file moves
- Marker rules before skip/cleanup behavior

### Parallel Opportunities

- T002, T016, T017, and T018 can run in parallel with other tasks
- T009 and T010 can run in parallel after parsing helpers are complete
- T014 and T015 can run in parallel with other story tasks once markers exist

---

## Parallel Example: User Story 1

```bash
Task: "Create series folder (if missing) in mediacleanup.sh"
Task: "Create season subfolder (if missing) in mediacleanup.sh"
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
