# Contract: Movie Series Organization

**Date**: 2026-01-17
**Spec**: ./specs/002-movie-series-support/spec.md

## Inputs

- Root media directories defined in `MEDIA_DIRS`
- Movie files without SxxExx tokens
- Allowed media/subtitle extensions defined in `ALLOWED_FILE_EXT`

## Outputs

- Standalone movies remain in the root
- Movie series folders named after the series prefix
- `.movieseries` marker file inside each movie series folder

## Rules

- Group matching files (including companion subtitles) when two or more share a
  prefix, unless a matching `.movieseries` folder already exists.
- Folder name is the prefix before the first numeric suffix or Roman numeral.
- TV episode rules take precedence when SxxExx tokens are present.
