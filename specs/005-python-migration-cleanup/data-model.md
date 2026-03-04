# Data Model: Python-Only MediaCleanup Migration

## Entities

### CleanupRun

- **Description**: One execution session of the cleanup command.
- **Fields**:
  - `run_id` (string, unique, timestamp based)
  - `mode` (`dry-run` | `apply`)
  - `start_time` (datetime)
  - `end_time` (datetime)
  - `duration_seconds` (integer)
  - `status` (`completed` | `failed`)
  - `counters` (object: moves, renames, deletes, rmdirs, mkdirs, touches, outcomes)
- **Validation**:
  - `mode` required
  - `run_id` immutable within run

### ActionRecord

- **Description**: Planned or executed filesystem operation.
- **Fields**:
  - `action_type` (`MOVE` | `RENAME` | `DELETE` | `RMDIR` | `MKDIR` | `TOUCH`)
  - `source_path` (absolute path)
  - `destination_path` (absolute path, nullable)
  - `outcome` (`simulated` | `performed` | `skipped` | `failed`)
- **Validation**:
  - `destination_path` required for move/rename
  - records are append-only for traceability

### ConfigurationProfile

- **Description**: User-supplied runtime config.
- **Fields**:
  - `media_dirs` (array of absolute paths)
  - `allowed_file_ext` (array of extension tokens)
- **Validation**:
  - root path must be absolute and not `/`
  - extension token must match `[A-Za-z0-9_-]+` after optional dot stripping
  - legacy shell-style config text is rejected

### MediaRoot

- **Description**: A configured top-level library location.
- **Fields**:
  - `path` (absolute path)
  - `exists` (boolean)
  - `access_state` (`readable` | `missing` | `unreadable`)
- **Validation**:
  - destructive operations restricted to descendants of `path`

### DocumentationArtifact

- **Description**: In-scope file for active workflow cleanup checks.
- **Fields**:
  - `path`
  - `scope` (`active-runtime` | `active-doc` | `historical`)
  - `contains_legacy_reference` (boolean)

## Relationships

- One `CleanupRun` has many `ActionRecord` entries.
- One `ConfigurationProfile` has many `MediaRoot` entries.
- `DocumentationArtifact` supports validation of FR-014 and SC-003.

## State Notes

- Dry-run and apply share planning logic; only outcome state differs (`simulated` vs `performed`).
- Repeat apply runs should converge with no additional state-changing actions at steady state.
