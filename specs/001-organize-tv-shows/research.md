# Research: Organize TV Shows by Series and Season

**Date**: 2026-01-17
**Spec**: ./specs/001-organize-tv-shows/spec.md

## Decision 1: Series Folder Marker

**Decision**: Use a hidden `.tvshow` marker file inside series folders.
**Rationale**: Explicit marker prevents accidental cleanup of organized folders
and is easy to detect without maintaining a separate registry.
**Alternatives considered**: Detect `Sxx` subfolders; maintain a root allowlist.

## Decision 2: Season Folder Naming

**Decision**: Always normalize season folders to two digits (S01, S02, ...).
**Rationale**: Keeps consistent naming, aligns with existing filename
normalization, and avoids duplicate season folders.
**Alternatives considered**: Preserve detected digits; mixed acceptance.

## Decision 3: Unparseable Files

**Decision**: Leave files without a recognized season pattern in the root.
**Rationale**: Prevents misplacement and flags files for manual review.
**Alternatives considered**: Move to a dedicated unsorted folder.

## Decision 4: Series Folder Matching

**Decision**: Match existing series folders case-insensitively, using canonical
name from the normalized filename.
**Rationale**: Avoids duplicate folders caused by casing differences while
preserving canonical naming.
**Alternatives considered**: Case-sensitive match; force lowercase folders.

## Decision 5: Extension Filtering

**Decision**: Only organize allowed media or subtitle extensions.
**Rationale**: Prevents moving archives or unrelated files that match patterns.
**Alternatives considered**: Organize any file with a season pattern.
