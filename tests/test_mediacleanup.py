from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

import pytest

from src.mediacleanup import main
from tests.conftest import write_config


@pytest.fixture()
def media_config(tmp_path: Path) -> tuple[Path, Path]:
    media_dir = tmp_path / "media"
    media_dir.mkdir(parents=True)
    config = tmp_path / "config.toml"
    write_config(config, media_dir)
    return media_dir, config


def test_missing_config_fails(tmp_path: Path) -> None:
    with pytest.raises(SystemExit):
        main(["--config", str(tmp_path / "missing.toml")])


def test_legacy_config_rejected(tmp_path: Path) -> None:
    conf = tmp_path / "legacy.toml"
    conf.write_text('MEDIA_DIRS=("/tmp")\nALLOWED_FILE_EXT=("mkv")\n', encoding="utf-8")
    with pytest.raises(SystemExit):
        main(["--config", str(conf)])


def test_invalid_root_path_rejected(tmp_path: Path) -> None:
    conf = tmp_path / "bad.toml"
    conf.write_text('media_dirs = ["/"]\nallowed_file_ext = ["mkv"]\n', encoding="utf-8")
    with pytest.raises(SystemExit):
        main(["--config", str(conf)])


def test_invalid_output_style_rejected(tmp_path: Path) -> None:
    conf = tmp_path / "bad-style.toml"
    conf.write_text(
        'media_dirs = ["/tmp/media"]\nallowed_file_ext = ["mkv"]\noutput_style = "neon"\n',
        encoding="utf-8",
    )
    with pytest.raises(SystemExit):
        main(["--config", str(conf)])


def test_cli_output_style_overrides_config(media_config: tuple[Path, Path], capsys: pytest.CaptureFixture[str]) -> None:
    media_dir, config = media_config
    write_config(config, media_dir, extras='output_style = "minimal"')

    assert main(["--config", str(config), "--dry-run", "--no-virtual", "--output-style", "pro"]) == 0
    output = capsys.readouterr().out
    assert "Theme: pro" in output


def test_dry_run_no_mutation(media_config: tuple[Path, Path]) -> None:
    media_dir, config = media_config
    nested = media_dir / "nested"
    nested.mkdir()
    source = nested / "show.s01e01.mkv"
    source.write_text("x", encoding="utf-8")

    assert main(["--config", str(config), "--dry-run", "--no-virtual"]) == 0
    assert source.exists()
    assert not (media_dir / "show.s01e01.mkv").exists()


def test_apply_parity_tv_and_movie(media_config: tuple[Path, Path]) -> None:
    media_dir, config = media_config
    (media_dir / "the.show.s01e02.mkv").write_text("ep", encoding="utf-8")
    (media_dir / "matrix.1.mkv").write_text("m1", encoding="utf-8")
    (media_dir / "matrix.2.mkv").write_text("m2", encoding="utf-8")
    (media_dir / "junk.jpg").write_text("x", encoding="utf-8")

    assert main(["--config", str(config), "--apply"]) == 0

    assert (media_dir / "The.Show" / ".tvshow").is_file()
    assert (media_dir / "The.Show" / "S01" / "The.Show.S01e02.mkv").is_file()
    assert (media_dir / "Matrix" / ".movieseries").is_file()
    assert (media_dir / "Matrix" / "Matrix.1.mkv").is_file()
    assert (media_dir / "Matrix" / "Matrix.2.mkv").is_file()
    assert not (media_dir / "junk.jpg").exists()


def test_collision_and_repeat_run(media_config: tuple[Path, Path]) -> None:
    media_dir, config = media_config
    nested = media_dir / "sub"
    nested.mkdir()
    (nested / "sample.mkv").write_text("first", encoding="utf-8")
    (media_dir / "sample.mkv").write_text("existing", encoding="utf-8")

    assert main(["--config", str(config), "--apply"]) == 0
    assert (media_dir / "sample.mkv").read_text(encoding="utf-8") == "existing"
    # second run should be steady state
    assert main(["--config", str(config), "--apply"]) == 0


def test_ds_store_respected_when_allowed(media_config: tuple[Path, Path]) -> None:
    media_dir, config = media_config
    ds_store = media_dir / ".DS_Store"
    ds_store.write_text("metadata", encoding="utf-8")

    assert main(["--config", str(config), "--apply"]) == 0
    assert ds_store.exists()


def test_installer_permission_denied(tmp_path: Path) -> None:
    install_script = Path(__file__).resolve().parents[1] / "scripts" / "install_mediacleanup.py"
    install_dir = tmp_path / "not_a_dir"
    install_dir.write_text("block", encoding="utf-8")

    env = os.environ.copy()
    env["INSTALL_DIR"] = str(install_dir)
    env["CONFIG_PATH"] = str(tmp_path / "config.toml")

    proc = subprocess.run(
        [sys.executable, str(install_script)],
        input="\n\n\n",
        text=True,
        capture_output=True,
        env=env,
    )
    assert proc.returncode == 1
    assert "Failed to write" in proc.stdout


def test_doc_consistency_scan() -> None:
    root = Path(__file__).resolve().parents[1]
    allowed_historical = {
        root / "specs" / "001-organize-tv-shows",
        root / "specs" / "002-movie-series-support",
        root / "specs" / "003-optimize-cleanup-script",
        root / "specs" / "004-logging-dry-run",
    }

    active_files = [
        root / "README.md",
        root / "AGENTS.md",
        root / "CHANGELOG.md",
        root / "Makefile",
        root / "mediacleanup.py",
        root / "src" / "mediacleanup.py",
        root / "scripts" / "install_mediacleanup.py",
        root / "specs" / "005-python-migration-cleanup" / "spec.md",
        root / "specs" / "005-python-migration-cleanup" / "plan.md",
        root / "specs" / "005-python-migration-cleanup" / "tasks.md",
    ]

    banned = ["mediacleanup.sh", "install-mediacleanup.sh", "~/.mediacleanup.conf"]
    for path in active_files:
        text = path.read_text(encoding="utf-8")
        for needle in banned:
            assert needle not in text, f"{needle} found in {path}"

    for old in allowed_historical:
        assert old.exists()


def test_update_config_adds_missing_options_without_overwrite(tmp_path: Path) -> None:
    script = Path(__file__).resolve().parents[1] / "scripts" / "update_config_defaults.py"
    config = tmp_path / "config.toml"
    config.write_text(
        "\n".join(
            [
                'media_dirs = ["/tmp/media"]',
                'allowed_file_ext = ["mkv"]',
                "",
            ]
        ),
        encoding="utf-8",
    )

    proc = subprocess.run(
        [sys.executable, str(script), "--config", str(config)],
        text=True,
        capture_output=True,
    )
    assert proc.returncode == 0
    out = config.read_text(encoding="utf-8")
    assert 'media_dirs = ["/tmp/media"]' in out
    assert 'allowed_file_ext = ["mkv"]' in out
    assert 'output_style = "vibrant"' in out


def test_update_config_no_changes_when_up_to_date(tmp_path: Path) -> None:
    script = Path(__file__).resolve().parents[1] / "scripts" / "update_config_defaults.py"
    config = tmp_path / "config.toml"
    config.write_text(
        "\n".join(
            [
                'media_dirs = ["/tmp/media"]',
                'allowed_file_ext = ["mkv"]',
                'output_style = "pro"',
                "",
            ]
        ),
        encoding="utf-8",
    )
    before = config.read_text(encoding="utf-8")

    proc = subprocess.run(
        [sys.executable, str(script), "--config", str(config)],
        text=True,
        capture_output=True,
    )
    assert proc.returncode == 0
    after = config.read_text(encoding="utf-8")
    assert before == after
    assert "No changes needed" in proc.stdout
