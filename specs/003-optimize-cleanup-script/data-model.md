# Data Model: Cleanup Script Optimization

## Entities

### Media File
- **Represents**: A file within configured media directories.
- **Fields**:
  - Path
  - File name
  - Media type (movie, TV, other)
  - Detected metadata (title, year, season/episode when available)

### Cleanup Action
- **Represents**: A planned or executed change for a media file.
- **Fields**:
  - Action type (move, rename, delete)
  - Source path
  - Target path (if applicable)
  - Reason/rule applied
  - Reversible flag

### Cleanup Run
- **Represents**: A single execution of cleanup over configured directories.
- **Fields**:
  - Run timestamp
  - Input dataset identifier (reference snapshot description)
  - Action list (ordered list of Cleanup Action)
  - Summary counts (actions by type)

## Relationships
- A Cleanup Run contains many Cleanup Actions.
- Each Cleanup Action targets one Media File.

## Validation Rules
- Action list must be deterministic for identical input datasets.
- Action list equivalence is evaluated before execution.
- Mixed media types must preserve equivalent action lists across runs.

## State Transitions
- Cleanup Action: planned -> executed (or planned -> skipped if no longer applicable).
- Cleanup Run: initialized -> planned -> executed -> completed.
