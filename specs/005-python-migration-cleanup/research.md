# Research: Python-Only MediaCleanup Migration

## Decision 1: Python CLI entrypoint and package layout

- **Decision**: Use `mediacleanup.py` root launcher calling `src/mediacleanup.py` `main()`.
- **Rationale**: Keeps executable UX stable while allowing module-level testing.
- **Alternatives considered**: Single monolithic root script; package console entrypoint only.

## Decision 2: Config schema and validation

- **Decision**: Require `~/.mediacleanup.toml` with `media_dirs` and `allowed_file_ext`; reject legacy shell-style config.
- **Rationale**: Explicit typed schema reduces parsing ambiguity and improves portability.
- **Alternatives considered**: Dual support of old/new formats; one-time auto migration.

## Decision 3: macOS/Linux filesystem handling

- **Decision**: Use `pathlib`, `os.walk`, and explicit root-scope checks for all destructive operations.
- **Rationale**: Portable and testable path handling across supported platforms.
- **Alternatives considered**: shell subprocess wrappers; platform-specific branches.

## Decision 4: Test strategy

- **Decision**: pytest unit/integration coverage plus fixture-based E2E checks; mandatory full macOS gate and Linux smoke validation.
- **Rationale**: Balances confidence and execution time while meeting acceptance criteria.
- **Alternatives considered**: integration-only testing; manual QA only.

## Decision 5: Quality gates

- **Decision**: Use `make lint` (`py_compile` + `markdownlint`) and `make test` (`pytest`).
- **Rationale**: Lightweight and deterministic checks for this repository.
- **Alternatives considered**: heavier lint/type toolchain in this migration.

## Decision 6: Active vs historical Bash references

- **Decision**: Remove legacy references from active runtime/user docs, allow contextual references in historical spec folders.
- **Rationale**: Matches clarified scope and avoids rewriting archival history.
- **Alternatives considered**: remove all references globally; keep references in active docs.

## Decision 7: Governance alignment

- **Decision**: Amend constitution wording from shell-first to Python-first while preserving safety principles.
- **Rationale**: Prevents policy conflict and keeps MUST-level controls enforceable.
- **Alternatives considered**: temporary exception; delayed amendment.

## Validation Evidence

- macOS full E2E: passed (`alpha.show.s01e03.mkv` reorganized to `Alpha.Show/S01`, movie series grouped, unsupported files pruned).
- Linux smoke parity: passed in Docker (`python:3.11-slim`) for install + dry-run + apply flow on representative fixture.
- Timed setup under 10 minutes: passed (install + first dry-run measured at **0.54s** in clean temporary environment).
