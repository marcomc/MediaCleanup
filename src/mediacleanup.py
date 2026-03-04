#!/usr/bin/env python3
"""MediaCleanup CLI implementation."""

from __future__ import annotations

import argparse
import datetime as dt
import os
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

try:
    import tomllib
except ModuleNotFoundError as exc:  # pragma: no cover
    raise SystemExit("Python 3.11+ is required") from exc

SCRIPT_VERSION = "2.0.0"
SERIES_MARKER = ".tvshow"
MOVIE_MARKER = ".movieseries"
DEFAULT_CONFIG = Path.home() / ".mediacleanup.toml"
ACTION_LOG_DIR = Path("/tmp/mediacleanup")

LOG_LEVELS = {"ERROR": 0, "WARN": 1, "INFO": 2, "DEBUG": 3}


@dataclass
class Counters:
    move: int = 0
    rename: int = 0
    delete: int = 0
    rmdir: int = 0
    mkdir: int = 0
    touch: int = 0
    performed: int = 0
    simulated: int = 0
    skipped: int = 0
    failed: int = 0


@dataclass
class Config:
    media_dirs: list[Path]
    allowed_extensions: set[str]


@dataclass
class VirtualState:
    files: set[Path] = field(default_factory=set)
    dirs: set[Path] = field(default_factory=set)

    def add_file(self, path: Path) -> None:
        self.files.add(path)
        self.ensure_dir(path.parent)

    def add_dir(self, path: Path) -> None:
        self.ensure_dir(path)

    def ensure_dir(self, path: Path) -> None:
        current = path
        while str(current) not in {"", ".", "/"}:
            self.dirs.add(current)
            current = current.parent

    def remove_file(self, path: Path) -> None:
        self.files.discard(path)

    def remove_dir(self, path: Path) -> None:
        self.dirs.discard(path)


@dataclass
class Context:
    config: Config
    run_mode: str
    log_level: str
    no_virtual: bool
    action_list_file: Path
    counters: Counters = field(default_factory=Counters)
    virtual: VirtualState | None = None
    series_roots: set[Path] = field(default_factory=set)
    movie_roots: set[Path] = field(default_factory=set)

    @property
    def use_virtual(self) -> bool:
        return self.virtual is not None


class Logger:
    def __init__(self, ctx: Context) -> None:
        self.ctx = ctx
        self._color = sys.stdout.isatty()
        self._reset = "\033[0m" if self._color else ""
        self._dir = "\033[34m" if self._color else ""
        self._step = "\033[32m" if self._color else ""
        self._action = "\033[37m" if self._color else ""

    def _enabled(self, level: str) -> bool:
        return LOG_LEVELS[level] <= LOG_LEVELS[self.ctx.log_level]

    def _print(self, level: str, message: str) -> None:
        if not self._enabled(level):
            return
        if level == "INFO":
            print(message)
        else:
            print(f"[{level}] {message}")

    def debug(self, message: str) -> None:
        self._print("DEBUG", message)

    def warn(self, message: str) -> None:
        self._print("WARN", message)

    def error(self, message: str) -> None:
        self._print("ERROR", message)

    def action(self, message: str) -> None:
        self._print("INFO", f"{self._action}{message}{self._reset}")

    def step(self, message: str) -> None:
        self._print("INFO", f"{self._step}{message}{self._reset}")

    def dir_header(self, message: str) -> None:
        self._print("INFO", f"{self._dir}== {message}{self._reset}")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Organize media folders from ~/.mediacleanup.toml")
    parser.add_argument("--log-level", default="INFO")
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--dry-run", action="store_true", help="Simulate actions (default)")
    parser.add_argument("--apply", action="store_true", help="Apply actions")
    parser.add_argument("--no-virtual", action="store_true", help="Disable virtual dry-run model")
    parser.add_argument("--config", default=str(DEFAULT_CONFIG), help="Path to .toml config")
    parser.add_argument("--version", action="store_true", help="Print version and exit")
    args = parser.parse_args(argv)

    if args.version:
        print(SCRIPT_VERSION)
        raise SystemExit(0)

    if args.verbose:
        args.log_level = "DEBUG"
    args.log_level = str(args.log_level).upper()
    if args.log_level not in LOG_LEVELS:
        raise SystemExit(f"Invalid log level: {args.log_level}")

    if args.apply and args.dry_run:
        raise SystemExit("Use either --dry-run or --apply, not both")
    args.run_mode = "apply" if args.apply else "dry-run"
    return args


def _validate_root_path(path: Path) -> None:
    if not path.is_absolute() or str(path) in {"/", "", ".", ".."}:
        raise SystemExit(f"Invalid media directory: {path}")


def _load_toml(path: Path) -> dict:
    try:
        return tomllib.loads(path.read_text(encoding="utf-8"))
    except tomllib.TOMLDecodeError as exc:
        raise SystemExit(f"Invalid TOML config at {path}: {exc}") from exc


def load_config(path: Path) -> Config:
    if not path.exists():
        raise SystemExit(
            f"Config missing at {path}; run `make install` or copy `mediacleanup.toml.sample`."
        )

    # Legacy format rejection with actionable guidance.
    if path.suffix == ".conf":
        raise SystemExit(
            "Legacy .conf format is not supported. Create ~/.mediacleanup.toml from mediacleanup.toml.sample."
        )
    text = path.read_text(encoding="utf-8")
    if "MEDIA_DIRS=(" in text or "ALLOWED_FILE_EXT=(" in text:
        raise SystemExit(
            "Legacy shell config detected. Recreate configuration in ~/.mediacleanup.toml using mediacleanup.toml.sample."
        )

    data = _load_toml(path)
    media_dirs = data.get("media_dirs")
    allowed = data.get("allowed_file_ext")

    if not isinstance(media_dirs, list) or not isinstance(allowed, list):
        raise SystemExit("Config must contain `media_dirs` and `allowed_file_ext` arrays")

    dirs: list[Path] = []
    for value in media_dirs:
        if not isinstance(value, str):
            raise SystemExit("All media_dirs entries must be strings")
        expanded = Path(os.path.expandvars(os.path.expanduser(value))).resolve()
        _validate_root_path(expanded)
        dirs.append(expanded)

    valid: set[str] = set()
    invalid: list[str] = []
    for ext in allowed:
        if not isinstance(ext, str):
            invalid.append(str(ext))
            continue
        normalized = ext[1:] if ext.startswith(".") else ext
        if re.fullmatch(r"[A-Za-z0-9_-]+", normalized):
            valid.add(normalized.lower())
        else:
            invalid.append(ext)

    if invalid:
        print(f"[WARN] Ignoring invalid extension entries: {', '.join(invalid)}", file=sys.stderr)
    if not valid:
        raise SystemExit("No valid extensions remain in allowed_file_ext")

    return Config(media_dirs=dirs, allowed_extensions=valid)


def init_action_file() -> Path:
    ACTION_LOG_DIR.mkdir(parents=True, exist_ok=True)
    run_id = dt.datetime.now().strftime("%Y%m%d%H%M%S")
    out = ACTION_LOG_DIR / f"action-list-{run_id}.txt"
    out.write_text("", encoding="utf-8")
    return out


def prune_action_logs(keep: int = 5) -> None:
    files = sorted(ACTION_LOG_DIR.glob("action-list-*.txt"), key=lambda p: p.stat().st_mtime, reverse=True)
    for old in files[keep:]:
        old.unlink(missing_ok=True)


def _record_action(ctx: Context, action: str, source: Path, dest: Path | None) -> None:
    with ctx.action_list_file.open("a", encoding="utf-8") as fh:
        fh.write(f"{action}\t{source}\t{dest or ''}\n")


def _bump(ctx: Context, action: str, outcome: str) -> None:
    action_key = {
        "MOVE": "move",
        "RENAME": "rename",
        "DELETE": "delete",
        "RMDIR": "rmdir",
        "MKDIR": "mkdir",
        "TOUCH": "touch",
    }.get(action)
    if action_key:
        setattr(ctx.counters, action_key, getattr(ctx.counters, action_key) + 1)
    setattr(ctx.counters, outcome, getattr(ctx.counters, outcome) + 1)


def _format_media_path(ctx: Context, path: Path) -> str:
    if ctx.log_level == "DEBUG":
        return str(path)
    for root in ctx.config.media_dirs:
        if path == root:
            return root.name
        try:
            return str(path.relative_to(root))
        except ValueError:
            continue
    return str(path)


def _path_exists(ctx: Context, path: Path) -> bool:
    if ctx.use_virtual:
        return path in ctx.virtual.files or path in ctx.virtual.dirs
    return path.exists()


def _file_exists(ctx: Context, path: Path) -> bool:
    if ctx.use_virtual:
        return path in ctx.virtual.files
    return path.is_file()


def _dir_exists(ctx: Context, path: Path) -> bool:
    if ctx.use_virtual:
        return path in ctx.virtual.dirs
    return path.is_dir()


def _allowed(ctx: Context, name: str) -> bool:
    if not name:
        return False
    # Match legacy behavior for dotfiles like ".DS_Store" where the extension
    # should be interpreted as "DS_Store".
    if name.startswith(".") and name.count(".") == 1 and len(name) > 1:
        suffix = name[1:].lower()
    elif "." in name:
        suffix = name.rsplit(".", 1)[1].lower()
    else:
        suffix = ""
    return suffix in ctx.config.allowed_extensions


def _should_process(ctx: Context, name: str) -> bool:
    return bool(name) and not name.startswith(".") and _allowed(ctx, name)


def _execute_file_op(ctx: Context, log: Logger, action: str, verb: str, source: Path, dest: Path) -> bool:
    src = _format_media_path(ctx, source)
    dst = _format_media_path(ctx, dest)
    _record_action(ctx, action, source, dest)

    if ctx.run_mode == "dry-run":
        log.action(f"Simulating {verb}: {src} -> {dst}")
        _bump(ctx, action, "simulated")
        if ctx.use_virtual:
            ctx.virtual.remove_file(source)
            ctx.virtual.add_file(dest)
        return True

    try:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(source), str(dest))
        log.action(f"{verb.capitalize()} file: {src} -> {dst}")
        _bump(ctx, action, "performed")
        return True
    except OSError:
        log.error(f"Failed to {verb}: {src} -> {dst}")
        _bump(ctx, action, "failed")
        return False


def _plan_move(ctx: Context, log: Logger, src: Path, dst: Path) -> bool:
    return _execute_file_op(ctx, log, "MOVE", "move", src, dst)


def _plan_rename(ctx: Context, log: Logger, src: Path, dst: Path) -> bool:
    return _execute_file_op(ctx, log, "RENAME", "rename", src, dst)


def _plan_remove(ctx: Context, log: Logger, target: Path) -> bool:
    _record_action(ctx, "DELETE", target, None)
    display = _format_media_path(ctx, target)

    if ctx.run_mode == "dry-run":
        if target.name != ".DS_Store":
            log.action(f"Simulating delete: {display}")
        _bump(ctx, "DELETE", "simulated")
        if ctx.use_virtual:
            ctx.virtual.remove_file(target)
        return True

    try:
        target.unlink()
        if target.name != ".DS_Store":
            log.action(f"Deleting: {display}")
        _bump(ctx, "DELETE", "performed")
        return True
    except OSError:
        if target.name != ".DS_Store":
            log.error(f"Failed to delete: {display}")
        _bump(ctx, "DELETE", "failed")
        return False


def _plan_mkdir(ctx: Context, log: Logger, path: Path) -> bool:
    _record_action(ctx, "MKDIR", path, None)
    display = _format_media_path(ctx, path)

    if ctx.run_mode == "dry-run":
        log.action(f"Simulating mkdir: {display}")
        _bump(ctx, "MKDIR", "simulated")
        if ctx.use_virtual:
            ctx.virtual.add_dir(path)
        return True

    try:
        path.mkdir(parents=True, exist_ok=True)
        log.action(f"Creating directory: {display}")
        _bump(ctx, "MKDIR", "performed")
        return True
    except OSError:
        log.error(f"Failed to create directory: {display}")
        _bump(ctx, "MKDIR", "failed")
        return False


def _plan_touch(ctx: Context, log: Logger, path: Path) -> bool:
    _record_action(ctx, "TOUCH", path, None)
    display = _format_media_path(ctx, path)

    if ctx.run_mode == "dry-run":
        log.action(f"Simulating marker: {display}")
        _bump(ctx, "TOUCH", "simulated")
        if ctx.use_virtual:
            ctx.virtual.add_file(path)
        return True

    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.touch(exist_ok=True)
        log.action(f"Creating marker: {display}")
        _bump(ctx, "TOUCH", "performed")
        return True
    except OSError:
        log.error(f"Failed to create marker: {display}")
        _bump(ctx, "TOUCH", "failed")
        return False


def _plan_rmdir(ctx: Context, log: Logger, path: Path) -> bool:
    _record_action(ctx, "RMDIR", path, None)
    display = _format_media_path(ctx, path)

    if ctx.run_mode == "dry-run":
        log.action(f"Simulating rmdir: {display}")
        _bump(ctx, "RMDIR", "simulated")
        if ctx.use_virtual:
            ctx.virtual.remove_dir(path)
        return True

    try:
        path.rmdir()
        log.action(f"Removing directory: {display}")
        _bump(ctx, "RMDIR", "performed")
        return True
    except OSError:
        log.error(f"Failed to remove directory: {display}")
        _bump(ctx, "RMDIR", "failed")
        return False


def _list_files_all(ctx: Context, root: Path) -> list[Path]:
    if ctx.use_virtual:
        pref = f"{root}/"
        return sorted([f for f in ctx.virtual.files if str(f).startswith(pref)])
    files: list[Path] = []
    for cur, _, names in os.walk(root):
        base = Path(cur)
        for n in names:
            files.append(base / n)
    return sorted(files)


def _list_files_root(ctx: Context, root: Path) -> list[Path]:
    if ctx.use_virtual:
        pref = f"{root}/"
        out: list[Path] = []
        for p in ctx.virtual.files:
            if str(p).startswith(pref) and len(p.relative_to(root).parts) == 1:
                out.append(p)
        return sorted(out)

    files = [p for p in root.iterdir() if p.is_file()]
    if ctx.run_mode == "apply":
        files = [f for f in files if _allowed(ctx, f.name)]
    return sorted(files)


def _list_files_nested(ctx: Context, root: Path) -> list[Path]:
    if ctx.use_virtual:
        pref = f"{root}/"
        out = []
        for p in ctx.virtual.files:
            if str(p).startswith(pref) and len(p.relative_to(root).parts) >= 2:
                out.append(p)
        return sorted(out)

    files: list[Path] = []
    for cur, _, names in os.walk(root):
        curp = Path(cur)
        if curp == root:
            continue
        for n in names:
            files.append(curp / n)
    return sorted(files)


def _under_any(path: Path, roots: Iterable[Path]) -> bool:
    for root in roots:
        try:
            path.relative_to(root)
            return True
        except ValueError:
            continue
    return False


def _build_roots(ctx: Context, root: Path) -> None:
    ctx.series_roots.clear()
    ctx.movie_roots.clear()
    if not _dir_exists(ctx, root):
        return

    if ctx.use_virtual:
        children = [d for d in ctx.virtual.dirs if d.parent == root]
    else:
        children = [d for d in root.iterdir() if d.is_dir()]

    for child in children:
        if _file_exists(ctx, child / SERIES_MARKER):
            ctx.series_roots.add(child)
        if _file_exists(ctx, child / MOVIE_MARKER):
            ctx.movie_roots.add(child)


def _find_root_by_name(roots: set[Path], name: str) -> Path | None:
    name_lc = name.lower()
    for root in roots:
        if root.name.lower() == name_lc:
            return root
    return None


def _normalize_name(name: str) -> str:
    new_name = re.sub(r"[^A-Za-z0-9!?]", ".", name)
    new_name = new_name.translate(str.maketrans({c: "." for c in "()[]{}"}))
    new_name = re.sub(r"\.+", ".", new_name).lstrip(".")

    if "." not in new_name:
        return new_name

    stem, ext = new_name.rsplit(".", 1)
    parts = [p[:1].upper() + p[1:].lower() if p else "" for p in stem.split(".")]
    normalized = ".".join(parts) + f".{ext}"

    tail = re.fullmatch(r"(.*)\.([0-9]+)", normalized)
    if tail and not re.fullmatch(r"[0-9]{4}", tail.group(2)):
        normalized = tail.group(1)
    return normalized


def _move_nested_to_root(ctx: Context, log: Logger, root: Path) -> None:
    log.step("Moving files from nested dirs to root")
    for file_path in _list_files_nested(ctx, root):
        if _under_any(file_path, ctx.series_roots) or _under_any(file_path, ctx.movie_roots):
            continue
        if file_path.name == ".DS_Store":
            _plan_remove(ctx, log, file_path)
            continue
        dest = root / file_path.name
        if _path_exists(ctx, dest):
            log.action(f"Skipping existing file: {_format_media_path(ctx, dest)}")
            _bump(ctx, "MOVE", "skipped")
            continue
        _plan_move(ctx, log, file_path, dest)


def _normalize_filenames(ctx: Context, log: Logger, root: Path) -> None:
    log.step("Normalizing filenames")
    for file_path in _list_files_root(ctx, root):
        if not _should_process(ctx, file_path.name):
            continue
        new_name = _normalize_name(file_path.name)
        if new_name and new_name != file_path.name:
            _plan_rename(ctx, log, file_path, file_path.parent / new_name)


def _organize_series(ctx: Context, log: Logger, root: Path) -> None:
    log.step("Organizing episode files")
    for file_path in _list_files_root(ctx, root):
        if not _should_process(ctx, file_path.name):
            continue
        stem = file_path.stem
        match = re.match(r"^(.+)\.([Ss][0-9]{1,2})[Ee][0-9]{1,2}", stem)
        if not match:
            continue

        series_name = match.group(1)
        season = int(match.group(2)[1:])
        season_dir_name = f"S{season:02d}"

        series_root = _find_root_by_name(ctx.series_roots, series_name) or (root / series_name)
        if not _dir_exists(ctx, series_root):
            _plan_mkdir(ctx, log, series_root)

        marker = series_root / SERIES_MARKER
        if not _file_exists(ctx, marker):
            _plan_touch(ctx, log, marker)
        ctx.series_roots.add(series_root)

        season_dir = series_root / season_dir_name
        if not _dir_exists(ctx, season_dir):
            _plan_mkdir(ctx, log, season_dir)

        dest = season_dir / file_path.name
        if _path_exists(ctx, dest):
            log.action(f"Skipping existing file: {_format_media_path(ctx, dest)}")
            _bump(ctx, "MOVE", "skipped")
            continue
        _plan_move(ctx, log, file_path, dest)


def _movie_prefix(name: str) -> str | None:
    if re.search(r"[Ss][0-9]{1,2}[Ee][0-9]{1,2}", name):
        return None
    roman = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"}
    out = []
    for token in name.split("."):
        if not token:
            continue
        if token.isdigit() or token.upper() in roman:
            break
        out.append(token)
    if not out:
        return None
    return ".".join(out)


def _organize_movies(ctx: Context, log: Logger, root: Path) -> None:
    log.step("Organizing movie series")
    pairs: list[tuple[str, Path]] = []
    counts: dict[str, int] = {}
    for file_path in _list_files_root(ctx, root):
        if not _should_process(ctx, file_path.name):
            continue
        prefix = _movie_prefix(file_path.stem)
        if not prefix:
            continue
        pairs.append((prefix, file_path))
        counts[prefix] = counts.get(prefix, 0) + 1

    for prefix, file_path in pairs:
        existing = _find_root_by_name(ctx.movie_roots, prefix)
        if not existing and counts[prefix] < 2:
            continue
        movie_root = existing or (root / prefix)
        if not _dir_exists(ctx, movie_root):
            _plan_mkdir(ctx, log, movie_root)

        marker = movie_root / MOVIE_MARKER
        if not _file_exists(ctx, marker):
            _plan_touch(ctx, log, marker)
        ctx.movie_roots.add(movie_root)

        dest = movie_root / file_path.name
        if _path_exists(ctx, dest):
            log.action(f"Skipping existing file: {_format_media_path(ctx, dest)}")
            _bump(ctx, "MOVE", "skipped")
            continue
        _plan_move(ctx, log, file_path, dest)


def _remove_unwanted(ctx: Context, log: Logger, root: Path) -> None:
    log.step("Removing unwanted files")
    for file_path in _list_files_all(ctx, root):
        if file_path.name in {SERIES_MARKER, MOVIE_MARKER}:
            continue
        if not _allowed(ctx, file_path.name):
            _plan_remove(ctx, log, file_path)


def _dir_has_child_dirs(ctx: Context, path: Path) -> bool:
    if ctx.use_virtual:
        pref = f"{path}/"
        return any(d != path and str(d).startswith(pref) for d in ctx.virtual.dirs)
    return any(c.is_dir() for c in path.iterdir())


def _dir_has_non_ds_files(ctx: Context, path: Path) -> bool:
    if ctx.use_virtual:
        pref = f"{path}/"
        return any(str(f).startswith(pref) and f.name != ".DS_Store" for f in ctx.virtual.files)
    return any(c.is_file() and c.name != ".DS_Store" for c in path.iterdir())


def _remove_empty_dirs(ctx: Context, log: Logger, root: Path) -> None:
    log.step("Removing empty subdirectories")
    changed = True
    while changed:
        changed = False
        if ctx.use_virtual:
            dirs = sorted(ctx.virtual.dirs, key=lambda p: len(p.parts), reverse=True)
        else:
            dirs = sorted([p for p in root.rglob("*") if p.is_dir()], key=lambda p: len(p.parts), reverse=True)

        for d in dirs:
            if d == root:
                continue
            try:
                d.relative_to(root)
            except ValueError:
                continue
            if _file_exists(ctx, d / SERIES_MARKER) or _file_exists(ctx, d / MOVIE_MARKER):
                continue
            if _dir_has_child_dirs(ctx, d):
                continue
            if _dir_has_non_ds_files(ctx, d):
                continue
            ds = d / ".DS_Store"
            if _file_exists(ctx, ds):
                _plan_remove(ctx, log, ds)
            _plan_rmdir(ctx, log, d)
            changed = True


def _init_virtual(ctx: Context, log: Logger) -> None:
    start = dt.datetime.now()
    v = VirtualState()
    for root in ctx.config.media_dirs:
        if not root.is_dir():
            log.warn(f"Skipping missing media directory: {root}")
            continue
        for cur, dirs, files in os.walk(root):
            curp = Path(cur)
            v.add_dir(curp)
            for d in dirs:
                v.add_dir(curp / d)
            for f in files:
                v.add_file(curp / f)
    elapsed = int((dt.datetime.now() - start).total_seconds() * 1000)
    log.debug(f"Virtual state initialized: {len(v.files)} files, {len(v.dirs)} directories in {elapsed}ms")
    ctx.virtual = v


def _run_for_root(ctx: Context, log: Logger, root: Path) -> None:
    if not root.exists() and not ctx.use_virtual:
        log.warn(f"Skipping missing media directory: {root}")
        return
    _build_roots(ctx, root)
    _move_nested_to_root(ctx, log, root)
    _normalize_filenames(ctx, log, root)
    _organize_series(ctx, log, root)
    _organize_movies(ctx, log, root)
    _remove_unwanted(ctx, log, root)
    _remove_empty_dirs(ctx, log, root)


def _summary(ctx: Context, log: Logger, start: dt.datetime, end: dt.datetime) -> None:
    log.step(f"Cleanup complete in {int((end-start).total_seconds())}s")
    log.step(f"Action list recorded at {ctx.action_list_file}")
    log.action(f"Run ended at {end.strftime('%Y-%m-%d %H:%M:%S')}")
    log.step(f"Summary at {end.strftime('%Y-%m-%d %H:%M:%S')}:")
    log.step("Action   Count")
    log.step(f"Moves    {ctx.counters.move}")
    log.step(f"Renames  {ctx.counters.rename}")
    log.step(f"Deletes  {ctx.counters.delete}")
    log.step(f"Rmdirs   {ctx.counters.rmdir}")
    log.step(f"Mkdirs   {ctx.counters.mkdir}")
    log.step(f"Touches  {ctx.counters.touch}")
    log.step("Outcome   Count")
    if ctx.run_mode == "apply":
        log.step(f"Performed {ctx.counters.performed}")
    if ctx.run_mode == "dry-run":
        log.step(f"Simulated {ctx.counters.simulated}")
    log.step(f"Skipped   {ctx.counters.skipped}")
    if ctx.run_mode == "apply":
        log.step(f"Failed    {ctx.counters.failed}")
    if ctx.run_mode == "dry-run":
        log.step("Dry-run: no changes made.")
        log.step("To apply these changes, run again with --apply.")


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    config_path = Path(os.path.expanduser(args.config)).resolve()
    config = load_config(config_path)
    action_file = init_action_file()

    ctx = Context(
        config=config,
        run_mode=args.run_mode,
        log_level=args.log_level,
        no_virtual=args.no_virtual,
        action_list_file=action_file,
    )
    log = Logger(ctx)

    if ctx.run_mode == "dry-run" and not ctx.no_virtual:
        _init_virtual(ctx, log)
        if not ctx.virtual.files and not ctx.virtual.dirs:
            log.warn("No accessible media directories found")

    start = dt.datetime.now()
    log.action(f"Run started at {start.strftime('%Y-%m-%d %H:%M:%S')} ({ctx.run_mode})")

    for root in ctx.config.media_dirs:
        log.dir_header(str(root))
        _run_for_root(ctx, log, root)

    end = dt.datetime.now()
    _summary(ctx, log, start, end)
    prune_action_logs()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
