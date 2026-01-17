# Feature Specification: Organize TV Shows by Series and Season

**Feature Branch**: `001-organize-tv-shows`  
**Created**: 2026-01-17  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

## Clarifications

### Session 2026-01-17

- Q: How should the script distinguish series folders from temporary drop
  folders? → A: Use a hidden marker file inside series folders (e.g., `.tvshow`).
- Q: How should season folder naming be normalized? → A: Always use two-digit
  season folders (S01, S02, ...).
- Q: How should unparseable files be handled? → A: Leave them in the root.
- Q: How should series folder matching handle letter case? → A: Match
  case-insensitively while using the canonical name from the filename.
- Q: Which files should be organized into series folders? → A: Only files with
  allowed media or subtitle extensions.

### User Story 1 - Organize Episodes by Series (Priority: P1)

As a user, I want TV episodes placed under a series folder with a season
subfolder so my library is structured and easy to browse.

**Why this priority**: This is the core value of the feature and is the main
reason for changing the cleanup flow.

**Independent Test**: Drop a set of episodes in a target root and verify they
end up in `Series.Name/S07` (or the correct season), with no files left in the
root.

**Acceptance Scenarios**:

1. **Given** episode files named like `Series.Name.S07E10.*` in the root,
   **When** the cleanup script runs, **Then** they are moved to
   `Series.Name/S07/`.
2. **Given** a series folder does not exist, **When** the cleanup script runs,
   **Then** the series folder and season subfolder are created and populated.

---

### User Story 2 - Normalize and Flatten Incoming Drops (Priority: P2)

As a user, I want files that arrive in random subfolders to be moved to the root
and renamed before organizing so the library stays consistent.

**Why this priority**: Incoming downloads are often messy, and consistent
processing avoids fragmentation and missed moves.

**Independent Test**: Place files inside nested folders, run the script, and
confirm files are flattened to the root, renamed, then organized into series and
season folders.

**Acceptance Scenarios**:

1. **Given** episodes inside randomly named subfolders, **When** the cleanup
   script runs, **Then** the files are first moved to the root before any
   organizing occurs.
2. **Given** filenames with mixed punctuation, **When** the cleanup script runs,
   **Then** names are normalized before series and season placement.

---

### User Story 3 - Preserve TV Series Folders (Priority: P3)

As a user, I want the script to distinguish series folders from temporary
download folders so it does not delete or merge series directories incorrectly.

**Why this priority**: Protecting organized series folders prevents data loss
and repeated cleanup work.

**Independent Test**: Create a series folder with a marker, add new episodes to
root, run the script, and confirm the series folder is reused and preserved.

**Acceptance Scenarios**:

1. **Given** an existing series folder, **When** new episodes for that series
   arrive, **Then** the script adds them to the existing season subfolder.
2. **Given** a folder without a series marker, **When** the script cleans
   subfolders, **Then** it is treated as an incoming drop and flattened.

---

### Edge Cases

- Episodes without a recognizable season/episode pattern are left in the root
  for manual review and are not moved into series folders.
- Files that match multiple possible series folder names are grouped into the
  single canonical series folder name derived from the filename.
- Season numbers that are a single digit (e.g., S7) are normalized to two-digit
  season folders (e.g., S07).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST move all files in nested subfolders to the root
  before organizing by series and season.
- **FR-002**: The system MUST normalize filenames using the existing renaming
  rules before organizing by series and season.
- **FR-003**: The system MUST extract the series name and season number from
  filenames and place episodes under `Series.Name/Sxx/`, with season folders
  normalized to two digits (S01, S02, ...).
- **FR-004**: The system MUST create a series folder and season subfolder if
  they do not already exist.
- **FR-005**: The system MUST avoid creating duplicate series folders and reuse
  the canonical series folder name derived from filenames, matching existing
  series folders case-insensitively.
- **FR-006**: The system MUST place a hidden `.tvshow` marker file in series
  folders so they are not treated as temporary download folders during cleanup.
- **FR-007**: The system MUST leave files without a recognized season pattern
  at the root for manual handling.
- **FR-008**: The system MUST only organize files with allowed media or
  subtitle extensions and leave other files in the root.

### Key Entities *(include if feature involves data)*

- **Series**: A TV show identified by the series name in the filename.
- **Season**: A numeric season bucket for a series, represented as `Sxx`.
- **Episode File**: A media file that includes series and season identifiers.

### Assumptions

- Filenames contain a series name and a season/episode token such as `S07E10`.
- The series name is the portion of the filename before the season/episode token
  after normalization.
- The same series name should always map to a single folder name.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of episode files with valid season patterns are placed in the
  correct series and season folders after one run.
- **SC-002**: No duplicate series folders exist for the same series name after a
  cleanup run.
- **SC-003**: All existing series folders are preserved and reused when new
  episodes are processed.
- **SC-004**: Files without recognizable season patterns remain in the root and
  are not moved into series folders.
