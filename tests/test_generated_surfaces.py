"""Generated surfaces are functions of the corpus table, and the vendored
packages are byte-identical to their pins.

Both checks fail closed in the refuse-to-proceed direction: a hand-edited
surface or a locally patched vendored file fails the build rather than
drifting.
"""

import subprocess
import sys
from pathlib import Path

from parameter_corpus import CORPUS, GATE, TagStatus

ROOT = Path(__file__).resolve().parents[1]


def run(script: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(ROOT / script), *args],
        capture_output=True,
        text=True,
        cwd=ROOT,
    )


def test_regime_ledger_is_current():
    result = run("tools/make_regime_ledger.py", "--check")
    assert result.returncode == 0, result.stdout + result.stderr


def test_vendored_packages_match_their_pins():
    result = run("vendor/python/vendoring/check_vendored_sync.py")
    assert result.returncode == 0, result.stdout + result.stderr


def test_ledger_points_every_tag_at_the_gate_that_judged_it():
    text = (ROOT / "docs" / "J1_regime_ledger.md").read_text(encoding="utf-8")
    assert "theorem tag (gated)" in text
    assert GATE in text
    assert "A gate verdict is not a proof" in text


def test_gate_judges_every_tag_the_corpus_uses():
    """A tag in the ledger that the gate never judged is a tag nobody checked."""
    gate = (ROOT / GATE).read_text(encoding="utf-8")
    for row in CORPUS:
        if row.theorem_tag is not None:
            assert row.theorem_tag in gate, f"{row.key}: {row.theorem_tag} is not in {GATE}"
            assert row.tag_status is not TagStatus.NONE


def test_a_row_without_a_tag_has_no_gate_verdict_either():
    for row in CORPUS:
        assert (row.theorem_tag is None) == (row.tag_status is TagStatus.NONE)


def test_gate_states_what_it_did_not_do():
    gate = (ROOT / GATE).read_text(encoding="utf-8")
    assert "What this gate did not do" in gate
    assert "NOT GATED" in gate
