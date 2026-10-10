"""Shared fixtures for the Python audit and oracle suite.

The Mojo smoke suite is the canonical executable check. A Python test that
wants to assert what Mojo actually does should run it, not read its source:
`mojo_smoke` runs it once per session and hands back the named case verdicts
it printed.
"""

from __future__ import annotations

import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
# Repository tools, then the vendored Python packages (vendor/python, pinned in vendored.toml).
sys.path[:0] = [str(ROOT / "tools"), str(ROOT / "vendor" / "python")]

from mojo_include import mojo_run  # noqa: E402
PASS_PREFIX = "[PASS] "
FAIL_PREFIX = "[FAIL] "


@dataclass(frozen=True)
class SmokeRun:
    """One run of `kernel/mojo/smoke/smoke_tests.mojo` and the cases it named."""

    returncode: int
    output: str
    passed: tuple[str, ...]
    failed: tuple[str, ...]

    def case_passed(self, name: str) -> bool:
        return name in self.passed

    @property
    def total(self) -> int:
        return len(self.passed) + len(self.failed)


@pytest.fixture(scope="session")
def mojo_smoke() -> SmokeRun:
    """Run the canonical Mojo smoke suite once and parse its named verdicts."""
    result = subprocess.run(
        mojo_run("kernel/mojo/smoke/smoke_tests.mojo"),
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    output = result.stdout + result.stderr
    names = lambda prefix: tuple(
        line[len(prefix):].strip()
        for line in output.splitlines()
        if line.startswith(prefix)
    )
    return SmokeRun(result.returncode, output, names(PASS_PREFIX), names(FAIL_PREFIX))
