# Data Model: Movie Series Support

**Date**: 2026-01-17
**Spec**: /Users/mmassari/Development/MediaCleanup/specs/002-movie-series-support/spec.md

## Entities

### Movie File

- **Identifier**: File name without TV season/episode tokens
- **Attributes**:
  - `filename`: Normalized filename
  - `extension`: Media or subtitle extension
  - `prefix`: Derived movie series prefix (if any)
- **Relationships**:
  - May belong to a Movie Series

### Movie Series

- **Identifier**: Folder name derived from prefix
- **Attributes**:
  - `name`: Series prefix name
  - `marker`: Presence of `.movieseries`
  - `match_count`: Number of matching movies used to trigger grouping
- **Relationships**:
  - Contains many Movie Files

## Validation Rules

- Movie series grouping requires two or more matching prefixes unless a
  `.movieseries` folder already exists.
- Folder name is the prefix before the first numeric suffix or Roman numeral.
- Files with SxxExx tokens are treated as TV shows, not movies.
