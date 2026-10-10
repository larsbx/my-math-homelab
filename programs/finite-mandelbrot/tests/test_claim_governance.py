"""The repository's claim-governance policy holds on every surface.

The policy lives in ``claim_governance.toml``; the checker is the vendored
``vendor/python/claim_governance`` package pinned in ``vendored.toml``.  The Mojo
proof-block ledger and its Markdown mirror must agree with the ledger in the
policy, and C1 must remain recorded as an open frontier.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from claim_governance import load_policy, run  # noqa: E402

POLICY = ROOT / "claim_governance.toml"


def test_every_required_proof_block_is_in_the_ledger():
    policy = load_policy(POLICY)
    names = {c.name for c in policy.ledger}
    ledger = (ROOT / "docs" / "C1_final_proof_block_ledger.md").read_text(encoding="utf-8")
    rows = [line.split("`")[1] for line in ledger.splitlines() if line.startswith("| `")]
    assert rows and set(rows) <= names, sorted(set(rows) - names)
    assert next(c for c in policy.ledger if c.name == "C1").status == "open-frontier"


def test_status_surfaces_agree_with_the_ledger():
    findings = run(load_policy(POLICY), ROOT)
    assert not findings, "\n" + "\n".join(f.render() for f in findings)
