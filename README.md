# MediaCleanup

MediaCleanup is a Python 3.11+ CLI that reorganizes media folders in place,
records everything it would do in action logs, and can run in a safe dry-run mode
before touching any files.

## Requirements

- Python 3.11 or newer (tomllib is required and bundled in 3.11+)
- Git checkout of this repository (see `make install` / `make uninstall`)
- `gh` CLI authenticated when you want to create releases

## Command overview

Use the bundled CLI directly from the repo:

```sh
./mediacleanup.py --dry-run
./mediacleanup.py --apply
./mediacleanup.py --log-level DEBUG
./mediacleanup.py --output-style pro
./mediacleanup.py --version
make update-config
```

## CLI reference

- `--dry-run` (default) / `--apply`: choose simulation or actual filesystem changes. These options are mutually exclusive.
- `--log-level LEVEL`: control verbosity (`ERROR`, `WARN`, `INFO`, `DEBUG`). `--verbose` is shorthand for `--log-level DEBUG`.
- `--no-virtual`: prevent building the in-memory model, useful for very large trees where you only want the action log and counters.
- `--config PATH`: point to a custom TOML configuration file (defaults to `~/.mediacleanup.toml`).
- `--output-style STYLE`: override the theme (`minimal`, `vibrant`, `pro`) set in the config, valid for a single run.
- `--version`: print the packaged version number (`2.1.0`) and exit immediately.

## Configuration

Copy `mediacleanup.toml.sample` to `~/.mediacleanup.toml` and edit it:

```
output_style = "vibrant"
media_dirs = [
  "${HOME}/Media/TV Shows",
  "${HOME}/Media/Movies",
]
allowed_file_ext = ["mp4", "mkv", "avi", "srt"]
```

- `media_dirs` must contain absolute paths; the CLI rejects relative roots or `/`, `.` formats.
- `allowed_file_ext` entries normalize to lowercase and drop leading dots; invalid strings are skipped with a warning.
- `output_style` must match one of the supported themes; `make update-config` (backed by `scripts/update_config_defaults.py`) safely inserts newly required keys without overwriting your values.
- Legacy `.conf` or shell-style configs are rejected with a clear migration message.

## Behavior

- Reads every configured media root and allowed extension list before processing.
- Builds a virtual state (with `--dry-run` and no `--no-virtual`) to ensure deterministic simulations.
- Moves files from nested directories into the root so that they can be normalized/organized consistently.
- Normalizes filenames by stripping punctuation, capitalizing segments, and trimming numeric suffixes when appropriate.
- Detects TV episodes, creates `Series.Name/Sxx/` directories, and uses `.tvshow` markers so reruns recognize the series root.
- Detects movie series by shared prefixes, moves them under `Series.Name/` roots, and creates `.movieseries` markers to avoid reprocessing.
- Removes files that do not match the allowed extensions list (except for `.DS_Store`, which is also cleaned if present).
- Removes empty directories after cleaning (and deletes stray `.DS_Store` markers).
- All changes are tracked in `/tmp/mediacleanup/action-list-<timestamp>.txt` with tab-delimited `ACTION<TAB>source<TAB>dest` entries.

## Safety

- Operates only under the configured absolute media roots; anything outside is untouched.
- Every move/rename/delete/rmdir/mkdir/touch is logged both on the console and in the action list file.
- Repeated runs converge: once files are normalized and organized, rerunning in dry-run will quickly report “skipped” for everything else.

## Output & samples

You can read the summary at the end of the CLI output. A typical dry-run looks like:

```text
────────────────────────────────────────────────────────────────────── MEDIA CLEANUP
▶ Run started at 2026-03-04 17:47:23 (dry-run)
Mode: DRY-RUN | Virtual model: on | Log level: INFO | Theme: minimal
──────────────────────────────────────────────────────────────────────
▸ /private/tmp/mediacleanup-sample/TV
› Moving files from nested dirs to root
· Simulating move: Season-1/Sample.Show.S01E01.mp4 -> Sample.Show.S01E01.mp4
› Normalizing filenames
· Simulating rename: Sample.Show.S01E01.mp4 -> Sample.Show.S01e01.mp4
› Organizing episode files
· Simulating mkdir: Sample.Show
· Simulating marker: Sample.Show/.tvshow
· Simulating mkdir: Sample.Show/S01
· Simulating move: Sample.Show.S01e01.mp4 -> Sample.Show/S01/Sample.Show.S01E01.mp4
› Organizing movie series
› Removing unwanted files
› Removing empty subdirectories
· Simulating rmdir: Season-1
──────────────────────────────────────────────────────────────────────
▸ /private/tmp/mediacleanup-sample/Movies
› Moving files from nested dirs to root
› Normalizing filenames
› Organizing episode files
› Organizing movie series
› Removing unwanted files
› Removing empty subdirectories
› Cleanup complete in 0s
› Action list recorded at /tmp/mediacleanup/action-list-20260304174723.txt
· Run ended at 2026-03-04 17:47:23
────────────────────────────────────────────────────────────────────── RUN SUMMARY
# Summary at 2026-03-04 17:47:23
- Actions
Moves           2
Renames         1
Deletes         0
Rmdirs          1
Mkdirs          2
Touches         1
- Outcome
Simulated       7
Skipped         0
› Dry-run: no changes made.
› To apply these changes, run again with --apply.
```

Action list files remain in `/tmp/mediacleanup`, and only the five most recent files are kept automatically.

## Development

```sh
make check-prereq
make lint
make test
make install
make uninstall
```
