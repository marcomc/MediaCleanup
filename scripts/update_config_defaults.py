#!/usr/bin/env python3
"""Append newly supported config options without overwriting user settings."""

from __future__ import annotations

import argparse
import datetime as dt
import os
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError as exc:  # pragma: no cover
    raise SystemExit("Python 3.11+ is required") from exc

DEFAULT_CONFIG = Path.home() / ".mediacleanup.toml"

# Add new top-level options here as the CLI evolves.
DEFAULT_OPTIONS: dict[str, str] = {
    "output_style": '"vibrant"',
}


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Append missing config options to ~/.mediacleanup.toml safely."
    )
    parser.add_argument(
        "--config",
        default=os.environ.get("CONFIG_PATH", str(DEFAULT_CONFIG)),
        help="Path to .toml config (defaults to ~/.mediacleanup.toml)",
    )
    return parser.parse_args(argv)


def load_toml(path: Path) -> dict:
    try:
        return tomllib.loads(path.read_text(encoding="utf-8"))
    except tomllib.TOMLDecodeError as exc:
        raise SystemExit(f"Invalid TOML config at {path}: {exc}") from exc


def _first_table_index(lines: list[str]) -> int | None:
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            return idx
    return None


def append_missing_options(path: Path, data: dict) -> list[str]:
    missing = [key for key in DEFAULT_OPTIONS if key not in data]
    if not missing:
        return []

    timestamp = dt.datetime.now(dt.UTC).strftime("%Y-%m-%dT%H:%M:%SZ")
    patch_lines: list[str] = [
        f"# Added by make update-config ({timestamp})",
    ]
    for key in missing:
        patch_lines.append(f"{key} = {DEFAULT_OPTIONS[key]}")

    original = path.read_text(encoding="utf-8")
    lines = original.splitlines()
    table_start = _first_table_index(lines)

    if table_start is None:
        # Keep root keys at root and preserve all user-provided values.
        if lines and lines[-1].strip():
            lines.append("")
        lines.extend(patch_lines)
        rendered = "\n".join(lines) + "\n"
    else:
        insert_at = table_start
        block = patch_lines + [""]
        lines[insert_at:insert_at] = block
        rendered = "\n".join(lines)
        if original.endswith("\n"):
            rendered += "\n"

    path.write_text(rendered, encoding="utf-8")
    return missing


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    config_path = Path(os.path.expanduser(args.config)).resolve()

    if not config_path.exists():
        print(f"Config not found at {config_path}. Run `make install` first.")
        return 1

    data = load_toml(config_path)
    added = append_missing_options(config_path, data)
    if added:
        print(f"Updated {config_path}")
        print(f"Added options: {', '.join(added)}")
    else:
        print(f"No changes needed for {config_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
