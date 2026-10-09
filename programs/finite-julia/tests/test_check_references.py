"""The reference check, on this repository and on trees built to fail.

The engine is upstream and tested there; what this repository owns is its
policy, so these cases are about the policy: that it passes here, that every
attestation names a repository, and that no attestation quietly shadows a
file this repository actually has.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import check_references as policy_module
from references.check_references import Policy, check, tracked_files

ROOT = Path(__file__).resolve().parents[1]
POLICY = policy_module.POLICY


def test_this_repository_passes_its_own_reference_check():
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "check_references.py")],
        capture_output=True, text=True, cwd=ROOT, check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_every_attestation_names_a_repository():
    assert POLICY.external and POLICY.external_tasks
    assert all(where for where in POLICY.external.values())
    assert all(where for where in POLICY.external_tasks.values())


def test_no_attestation_shadows_a_file_this_repository_has():
    """An attested path that exists here would excuse a real reference from
    being checked."""
    tracked = set(tracked_files(ROOT))
    assert not (set(POLICY.external) & tracked)


def test_a_stale_reference_is_caught():
    files = {"docs/note.md": "see `docs/gone.md`"}
    assert check(files, ["docs/note.md"], set(), Policy()) == [
        "docs/note.md: path `docs/gone.md` is not a tracked file, a unique basename, or a listed external reference"
    ]


def test_an_undefined_task_is_caught():
    files = {"README.md": "run `pixi run nowhere`"}
    assert check(files, ["README.md"], {"test"}, Policy()) == [
        "README.md: task `pixi run nowhere` is not defined in pixi.toml"
    ]


def test_the_skipped_files_are_the_ones_that_build_fixtures():
    """Skipping is narrow and named: whole directories are not exempt."""
    assert POLICY.skipped_prefixes == (
        "tests/test_exact_arithmetic_audit.py",
        "tests/test_check_references.py",
    )
