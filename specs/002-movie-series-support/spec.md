# Feature Specification: Movie Series Support

**Feature Branch**: `002-movie-series-support`  
**Created**: 2026-01-17  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

## Clarifications

### Session 2026-01-17

- Q: When should movie series grouping occur? → A: Group any prefix shared by
  two or more matching files (including companion subtitles).
- Q: Which marker should identify movie series folders? → A: Use `.movieseries`.
- Q: How should the movie series folder name be derived? → A: Use the full
  prefix before the first numeric suffix or Roman numeral.
- Q: When should grouping use an existing `.movieseries` folder? → A: Require
  two or more matches unless a `.movieseries` folder already exists.

### User Story 1 - Keep Standalone Movies at Root (Priority: P1)

As a user, I want standalone movies to remain in the root of the media directory
so they are easy to find without extra folders.

**Why this priority**: Most movies are standalone and should not be grouped,
which is the primary expected behavior.

**Independent Test**: Place a movie file without a season/episode token or
series prefix pattern in the root and verify it stays in the root after cleanup.

**Acceptance Scenarios**:

1. **Given** a movie filename without season/episode tokens, **When** the script
   runs, **Then** the file remains in the root directory.
2. **Given** mixed TV and movie files, **When** the script runs, **Then** only
   TV episodes are moved into series folders and movies remain in the root.

---

### User Story 2 - Group Movie Series into Folders (Priority: P2)

As a user, I want movies that share a common series prefix to be grouped into a
folder marked as a movie series.

**Why this priority**: Movie series need organization while still distinguishing
from TV series.

**Independent Test**: Place multiple movie files starting with the same
prefix (e.g., `The.Crow.*`) and verify they are moved into
`The.Crow/` with a `.movieseries` marker.

**Acceptance Scenarios**:

1. **Given** multiple movies that share a prefix, **When** the script runs,
   **Then** they are moved to a single series folder named after the prefix.
2. **Given** the series folder does not exist, **When** the script runs,
   **Then** it is created and a `.movieseries` marker is added.

---

### User Story 3 - Preserve Movie Series Folders (Priority: P3)

As a user, I want movie series folders to be protected from cleanup so they are
not deleted or flattened.

**Why this priority**: Preserving series folders avoids losing grouped movies
and prevents future organization churn.

**Independent Test**: Create a movie series folder with `.movieseries`, add new
matching movies to the root, and confirm they are moved into the existing folder.

**Acceptance Scenarios**:

1. **Given** an existing `.movieseries` folder, **When** new matching movies
   arrive, **Then** they are moved into that folder.
2. **Given** an unmarked folder, **When** cleanup runs, **Then** it is treated
   as a temporary drop folder and may be flattened if empty.

---

### Edge Cases

- A movie title contains a year token (e.g., `Movie.Title.2019`) and should
  still be treated as standalone unless it matches a series prefix rule.
- A single movie with a prefix should not be grouped into a series folder unless
  multiple matching files exist (including companion subtitles).
- Movie files that look like TV episodes (contain SxxExx) are still treated as
  TV shows, not movie series.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST leave standalone movie files in the root
  directory.
- **FR-002**: The system MUST detect movie series by identifying multiple
  matching files (including companion subtitles) sharing a common prefix in the
  root (two or more matches), unless a matching `.movieseries` folder already
  exists.
- **FR-003**: The system MUST group matching movie series files into a folder
  named after the full prefix before the first numeric suffix or Roman numeral.
- **FR-004**: The system MUST create a `.movieseries` marker file inside movie
  series folders.
- **FR-005**: The system MUST preserve `.movieseries` folders from cleanup or
  flattening operations.
- **FR-006**: The system MUST ensure TV show rules continue to take precedence
  when filenames include SxxExx tokens.

### Key Entities *(include if feature involves data)*

- **Movie File**: A media file that lacks TV season/episode tokens.
- **Movie Series**: A collection of movie files sharing a prefix and marked by
  `.movieseries`.

### Assumptions

- A movie series is determined by a shared filename prefix before a numeric
  suffix or trailing token.
- Series grouping can be triggered by a matching movie plus its companion
  subtitle file.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of standalone movies remain in the root after one run.
- **SC-002**: All detected movie series are grouped into folders with
  `.movieseries` markers.
- **SC-003**: No `.movieseries` folders are removed or flattened by cleanup.
