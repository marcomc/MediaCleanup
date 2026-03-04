# Research: Movie Series Support

**Date**: 2026-01-17
**Spec**: ./specs/002-movie-series-support/spec.md

## Decision 1: Movie Series Detection Threshold

**Decision**: Group any prefix shared by two or more movies in the root, unless
an existing `.movieseries` folder already exists for that prefix.
**Rationale**: Matches the clarified behavior and avoids grouping singletons
while respecting established folders.
**Alternatives considered**: Require sequel tokens; require pre-existing folder.

## Decision 2: Movie Series Marker

**Decision**: Use `.movieseries` as the marker file.
**Rationale**: Clear and consistent with `.tvshow` semantics.
**Alternatives considered**: `.movieserie`, dual markers.

## Decision 3: Series Folder Naming

**Decision**: Use the full prefix before the first numeric suffix or Roman
numeral to name the movie series folder.
**Rationale**: Fits existing filename patterns and preserves recognizable
series titles.
**Alternatives considered**: Two-word prefix, last-dot truncation.
