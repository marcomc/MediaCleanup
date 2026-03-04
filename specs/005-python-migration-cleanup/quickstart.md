# Quickstart: Python-Only MediaCleanup Migration

## Prerequisites

- Python 3.11+
- macOS or Linux
- Writable user-local install directory (default `~/.local/bin`)

## Install

```sh
make install
```

## Configure

1. Copy `mediacleanup.toml.sample` to `~/.mediacleanup.toml`.
2. Update `media_dirs` and `allowed_file_ext`.
3. Legacy shell-style config is unsupported and must be recreated.

## Run

```sh
./mediacleanup.py --dry-run
./mediacleanup.py --apply
```

## Validation

```sh
make check-prereq
make lint
make test
```

## Active Artifact Scope for Bash-Reference Cleanup

- Runtime entrypoints and scripts in repository root and `/scripts`
- User docs: `README.md`, `AGENTS.md`
- Active feature docs under `/specs/005-python-migration-cleanup`

## End-to-End Verification

- **Mandatory macOS gate**: run fixture-based dry-run and apply and verify expected parity.
- **Linux smoke**: run install + dry-run/apply in container and confirm no parity regression.

## Timed Setup Check

Measure from clean environment to first successful dry-run.
Target: under 10 minutes.
