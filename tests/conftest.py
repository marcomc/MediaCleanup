from __future__ import annotations

from pathlib import Path


def write_config(path: Path, media_dir: Path, extras: str = "") -> None:
    content = [
        "media_dirs = [",
        f'  "{media_dir}",',
        "]",
        "allowed_file_ext = [",
        '  "mkv",',
        '  "srt",',
        '  "DS_Store",',
        "]",
    ]
    if extras:
        content.append(extras)
    path.write_text("\n".join(content) + "\n", encoding="utf-8")
