"""The seam between the Mojo declarations, the run receipts, and the policy.

`kernel/mojo_smoke/claims.mojo` (vendored) prints a receipt line, `kernel/run_tests.sh` turns
the lines of a passing test into rows of `kernel/build/claim-receipts.tsv`, and
the `coverage` check of `claim_governance.toml` reads those rows. Three
languages, one format: these tests pin it without a Mojo toolchain, so a
change to either end that breaks the other is caught here rather than by a
silent loss of coverage in CI.

That the audit itself passes is `tests/test_claim_governance.py`.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from claim_governance.checks.coverage import RECEIPTS_FORMAT, declarations  # noqa: E402
from claim_governance.policy import load_policy  # noqa: E402
from claim_governance.repo import Repo  # noqa: E402

POLICY = load_policy(ROOT / "claim_governance.toml")
COVERAGE = POLICY.coverage
DECLARER = (ROOT / "kernel" / "mojo_smoke" / "claims.mojo").read_text(encoding="utf-8")
RUNNER = (ROOT / "kernel" / "run_tests.sh").read_text(encoding="utf-8")
PREFIXES = {"claim": "claim-receipt:", "contract": "contract-receipt:"}


def test_the_policy_watches_the_mojo_tests_and_the_runner_receipts():
    assert COVERAGE.tests == ("kernel/tests/test_*.mojo",)
    assert COVERAGE.receipts == "kernel/build/claim-receipts.tsv"
    assert f"RECEIPTS=${{CLAIM_RECEIPTS:-{COVERAGE.receipts.removeprefix('kernel/')}}}" in RUNNER
    assert f"printf '{RECEIPTS_FORMAT}\\n' > \"$RECEIPTS\"" in RUNNER


def test_every_mojo_test_declares_what_it_guards():
    repo = Repo(ROOT, POLICY.scan.exclude)
    files = repo.files(COVERAGE.tests)
    assert len(files) >= 30
    assert all(declarations(COVERAGE, repo, rel) for rel in files)


def test_each_declaration_prints_the_prefix_the_runner_reads():
    for kind, prefix in PREFIXES.items():
        assert f'print("{prefix}", ' in DECLARER, kind


def test_the_runner_strips_exactly_the_prefix_and_its_separating_space():
    """The awk offsets are the one place the three languages could drift."""
    for kind, prefix in PREFIXES.items():
        offset = int(re.search(rf'/\^{re.escape(prefix)} /.*substr\(\$0, (\d+)\)', RUNNER).group(1))
        assert offset == len(prefix) + 2


def test_the_runner_turns_a_printed_receipt_into_a_row_the_check_accepts(tmp_path):
    out = tmp_path / "log"
    out.write_text("[PASS] test_something\n"
                   f"{PREFIXES['claim']} OverlapProductivity\n"
                   f"{PREFIXES['contract']} a contract with spaces\n"
                   "8 tests passed.\n", encoding="utf-8")
    script = re.search(r"awk -v path=\"kernel/\$test\" '\n(.*?)' \"\$LOG\"", RUNNER, re.S).group(1)
    rows = subprocess.run(["awk", "-v", "path=kernel/tests/test_x.mojo", script, str(out)],
                          capture_output=True, text=True, check=True).stdout
    assert rows == ("kernel/tests/test_x.mojo\tclaim\tOverlapProductivity\n"
                    "kernel/tests/test_x.mojo\tcontract\ta contract with spaces\n")


def test_the_required_classes_are_the_ones_whose_warrant_is_a_computation():
    """A finite-domain or evidence claim has no source but an exact finite
    run, so requiring a test for it states the repository's own discipline;
    requiring one of a manuscript- or Lean-backed claim would not."""
    assert set(COVERAGE.require_classes) == {"finite-domain", "evidence"}
    required = {c.name for c in POLICY.ledger if c.status in COVERAGE.require_classes}
    assert required == {
        "BoundedDegree3Exclusion",
        "BoundedDegree2WedgeProductivity",
        "OneStepContextEquality",
        "FiniteCollarDeath",
        "CorpusDeterminantSplit",
        "BoundedPureDiscreteSpectrum",
    }


def test_the_generated_graph_carries_the_proof_record_ledger_and_only_that():
    policy = tomllib.loads((ROOT / "claim_governance.toml").read_text(encoding="utf-8"))
    records = set(json.loads((ROOT / "proof" / "tla" / "ledger.json").read_text(encoding="utf-8"))["records"])
    graph = json.loads((ROOT / "docs" / "claim-relationship-graph.json").read_text(encoding="utf-8"))
    claims = {n["id"] for n in graph["nodes"] if n["kind"] == "claim"}
    assert claims == records
    assert claims < {c["name"] for c in policy["claim"]}, "the hand-written claims are not nodes of the proof-record ledger"
