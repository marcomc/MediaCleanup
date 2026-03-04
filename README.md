# MediaCleanup

MediaCleanup is a Python CLI utility that organizes media libraries and produces
reversible action logs.

## Command

Run with:

```sh
./mediacleanup.py --dry-run
./mediacleanup.py --apply
./mediacleanup.py --log-level DEBUG
./mediacleanup.py --version
```

## Behavior

- Reads media roots and extension allowlist from `~/.mediacleanup.toml`
- Moves nested files to root (outside recognized series/movie roots)
- Normalizes filenames deterministically
- Organizes TV episodes into `Series.Name/Sxx/` with `.tvshow` marker
- Groups movie series with `.movieseries` markers when prefixes repeat
- Removes unsupported files
- Writes action list output to `/tmp/mediacleanup/action-list-<timestamp>.txt`

## Modes

- `--dry-run` (default): simulate operations without filesystem mutations
- `--apply`: execute file operations
- `--no-virtual`: dry-run without virtual model

## Configuration

Create `~/.mediacleanup.toml` from `mediacleanup.toml.sample`.
Legacy shell-style config is rejected with migration guidance.

## Safety

- Destructive operations are limited to configured absolute media roots
- Moves, renames, deletes, and directory removals are logged
- Repeated runs converge to a deterministic steady state

## Development

```sh
make check-prereq
make lint
make test
```
