"""The theorem/research Markdown source guard fails closed on C0 controls."""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "tools" / "check_markdown_source.py"


def run(*targets: Path, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *(str(target) for target in targets)],
        capture_output=True,
        text=True,
        check=False,
        cwd=cwd,
    )


def test_repository_theorem_and_research_markdown_has_no_c0_controls():
    result = run(ROOT / "README.md", ROOT / "docs", ROOT / "manuscripts")
    assert result.returncode == 0, result.stdout + result.stderr


def test_guard_rejects_mangled_latex_negative_control(tmp_path):
    damaged = tmp_path / "damaged-research-note.md"
    damaged.write_bytes(
        b"$\\rho=\\beta$\n$\\tau\\to0$\n"
        .replace(b"\\r", b"\r")
        .replace(b"\\b", b"\x08")
        .replace(b"\\t", b"\t")
    )

    result = run(damaged)

    assert result.returncode == 1
    assert "unexpected C0 control 0x0d" in result.stdout
    assert "unexpected C0 control 0x08" in result.stdout
    assert "unexpected C0 control 0x09" in result.stdout


def test_guard_rejects_missing_explicit_target(tmp_path):
    missing = tmp_path / "does-not-exist.md"
    result = run(missing)
    assert result.returncode == 1
    assert "target does not exist" in result.stdout


def test_guard_defaults_are_root_anchored(tmp_path):
    result = run(cwd=tmp_path)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "OK Markdown source integrity:" in result.stdout
