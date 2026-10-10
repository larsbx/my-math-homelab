"""Lean 4 in the oracle loop: Lean recomputes the arithmetic side and certifies exported data.

The gate fails, never skips, when `lake` is missing (install: https://github.com/leanprover/elan).
"""
import os
import shutil
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
LEAN = ROOT / "proof" / "langlands"


def lake() -> str:
    found = shutil.which("lake") or shutil.which("lake", path=str(Path.home() / ".elan" / "bin"))
    if not found:
        pytest.fail("lake not found: install elan (https://github.com/leanprover/elan); the Lean gate never skips")
    return found


@pytest.mark.slow
def test_exported_data_is_deterministic_and_current():
    r = subprocess.run(["python3", str(ROOT / "tools" / "export_lean_data.py"), "--check"], cwd=ROOT)
    assert r.returncode == 0, "proof/langlands/LanglandsOracles/Data*.lean is stale: run tools/export_lean_data.py"


@pytest.mark.slow
def test_lean_certificates_build():
    env = {**os.environ, "PATH": f"{Path.home() / '.elan' / 'bin'}:{os.environ.get('PATH', '')}"}
    r = subprocess.run([lake(), "build"], cwd=LEAN, capture_output=True, text=True, env=env)
    assert r.returncode == 0, r.stdout[-4000:] + r.stderr[-4000:]
    assert "sorry" not in r.stdout


@pytest.mark.slow
def test_lean_axiom_audit():
    """Every certificate depends on nothing beyond propext / Quot.sound: no sorry, no native_decide."""
    env = {**os.environ, "PATH": f"{Path.home() / '.elan' / 'bin'}:{os.environ.get('PATH', '')}"}
    r = subprocess.run([lake(), "env", "lean", "Audit.lean"], cwd=LEAN, capture_output=True, text=True, env=env)
    assert r.returncode == 0, r.stdout + r.stderr
    assert "sorryAx" not in r.stdout and "ofReduceBool" not in r.stdout, r.stdout
    assert "Classical.choice" not in r.stdout, r.stdout
    assert r.stdout.count("depends on axioms") + r.stdout.count("does not depend on any axioms") == 67
