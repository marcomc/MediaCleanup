# Data Model: Organize TV Shows by Series and Season

**Date**: 2026-01-17
**Spec**: /Users/mmassari/Development/MediaCleanup/specs/001-organize-tv-shows/spec.md

## Entities

### Series

- **Identifier**: Canonical series name derived from filename prefix
- **Attributes**:
  - `name`: Normalized series name (e.g., `Shameless.Us`)
  - `marker`: Presence of `.tvshow` marker file
- **Relationships**:
  - Has many Seasons

### Season

- **Identifier**: `Sxx` folder under a Series
- **Attributes**:
  - `number`: Two-digit season number string (e.g., `S07`)
- **Relationships**:
  - Belongs to one Series
  - Contains many Episode Files

### Episode File

- **Identifier**: File name including series and season token
- **Attributes**:
  - `filename`: Normalized filename
  - `extension`: Media or subtitle extension
  - `series_name`: Derived series name
  - `season_number`: Two-digit season number
- **Relationships**:
  - Belongs to one Season

## Validation Rules

- Series names are derived from the filename prefix before the season token.
- Season folders must be two-digit (`S01`, `S02`, ...).
- Only files with allowed media or subtitle extensions are eligible.
- Files without a recognized season token stay at the root.
