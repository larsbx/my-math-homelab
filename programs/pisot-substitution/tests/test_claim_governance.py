"""The repository's claim-governance policy holds on every status surface.

The policy lives in ``claim_governance.toml``; the checker is the vendored
``tools/claim_governance`` package pinned in ``vendored.toml``.  This test
runs the same audit as CI so that ``pytest`` alone catches a status surface
that disagrees with the claim ledger.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from claim_governance import load_policy, run  # noqa: E402

POLICY = ROOT / "claim_governance.toml"


def test_policy_covers_every_live_claim_map_row():
    policy = load_policy(POLICY)
    claim_map = policy.ledger and next(
        s.path for c in policy.ledger for s in c.surfaces if s.path.startswith("docs/claim-status")
    )
    text = (ROOT / claim_map).read_text(encoding="utf-8")
    section = text.split("## Live claim map", 1)[1].split("\n## ", 1)[0]
    rows = [line for line in section.splitlines() if line.startswith("| ") and "**" in line]
    anchored = {s.anchor for c in policy.ledger for s in c.surfaces if s.path == claim_map and s.anchor}
    unanchored = [row for row in rows if not any(row.startswith(anchor) for anchor in anchored)]
    assert not unanchored, f"claim map rows without a ledger entry: {unanchored}"


def test_status_surfaces_agree_with_the_ledger():
    findings = run(load_policy(POLICY), ROOT)
    assert not findings, "\n" + "\n".join(f.render() for f in findings)
