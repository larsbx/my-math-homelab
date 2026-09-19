"""Generated surfaces are functions of the corpus table, and the vendored
packages are byte-identical to their pins.

Both checks fail closed in the refuse-to-proceed direction: a hand-edited
surface or a locally patched vendored file fails the build rather than
drifting.
"""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run(script: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(ROOT / "tools" / script), *args],
        capture_output=True,
        text=True,
        cwd=ROOT,
    )


def test_regime_ledger_is_current():
    result = run("make_regime_ledger.py", "--check")
    assert result.returncode == 0, result.stdout + result.stderr


def test_vendored_packages_match_their_pins():
    result = run("check_vendored_sync.py")
    assert result.returncode == 0, result.stdout + result.stderr


def test_ledger_marks_every_theorem_tag_unverified():
    text = (ROOT / "docs" / "J1_regime_ledger.md").read_text(encoding="utf-8")
    assert "theorem tag (unverified)" in text
    assert "no literature gate has been run" in text
