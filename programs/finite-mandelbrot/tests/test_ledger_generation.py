"""Every ledger surface is the declarative C1 record specification, and nothing else.

`proof/c1/records.toml` owns the claim/proof state. `tools/make_ledger.py`
validates and renders it into the Mojo mirror, Markdown block table, claim
entries, index, TLA+ ledger and typed relationship graph. These tests assert
that generated surfaces agree with that single declarative source.
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
sys.path.insert(0, str(ROOT / "vendor" / "python"))

import make_ledger as ml  # noqa: E402

MOJO = (ROOT / "kernel/mojo/c1/proof/final_proof_block_ledger.mojo").read_text(encoding="utf-8")
DOC = (ROOT / "docs" / "C1_final_proof_block_ledger.md").read_text(encoding="utf-8")
POLICY = tomllib.loads((ROOT / "claim_governance.toml").read_text(encoding="utf-8"))
LEDGER = json.loads((ROOT / "ledger.json").read_text(encoding="utf-8"))
GRAPH = json.loads((ROOT / "docs" / "C1_claim_relationship_graph.json").read_text(encoding="utf-8"))
RECORD_SPEC = tomllib.loads((ROOT / "proof" / "c1" / "records.toml").read_text(encoding="utf-8"))
CLASS_FLAGS = ("proved-or-imported-checked", "scaffolded", "open-frontier", "research-only")


def status_of(name: str) -> str:
    """The class the Mojo mirror gives a block, read off its four flags."""
    flags = re.search(rf'ProofBlockStatus\("{name}", (\w+), (\w+), (\w+), (\w+), (\w+)\)', MOJO).groups()
    live = [cls for cls, flag in zip(CLASS_FLAGS, flags) if flag == "True"]
    assert len(live) == 1, (name, flags)
    return live[0]


def required_in_mojo(name: str) -> bool:
    return re.search(rf'ProofBlockStatus\("{name}",(?:\s*\w+,){{4}}\s*(\w+)\)', MOJO).group(1) == "True"


def test_every_generated_surface_is_current():
    assert subprocess.run([sys.executable, str(ROOT / "tools" / "make_ledger.py"), "--check"],
                          capture_output=True, text=True).returncode == 0


def test_generation_is_a_pure_function_of_the_declarative_records():
    """Running the generator twice changes nothing."""
    before = {p: p.read_text(encoding="utf-8") for p in (ROOT / "kernel/mojo/c1/proof/final_proof_block_ledger.mojo",
                                                         ROOT / "docs" / "C1_final_proof_block_ledger.md",
                                                         ROOT / "claim_governance.toml", ROOT / "ledger.json")}
    assert subprocess.run([sys.executable, str(ROOT / "tools" / "make_ledger.py")], capture_output=True).returncode == 0
    assert {p: p.read_text(encoding="utf-8") for p in before} == before


def test_the_claim_ledger_is_exactly_the_declarative_record_set():
    declared = {record["name"] for record in RECORD_SPEC["record"]}
    assert declared == set(ml.TABLE)
    assert {c["name"] for c in POLICY["claim"]} == declared == set(LEDGER["records"])


def test_generator_contains_mechanism_not_theorem_status_table():
    source = (ROOT / "tools" / "make_ledger.py").read_text(encoding="utf-8")
    assert 'SPEC_PATH = ROOT / "proof" / "c1" / "records.toml"' in source
    assert "TABLE: dict[str, tuple] = {" not in source
    assert "open frontier: missing-link exits are not eliminated" not in source


def test_the_mojo_mirror_carries_every_block_and_only_blocks():
    named = set(re.findall(r'ProofBlockStatus\("(\w+)"', MOJO))
    assert named == set(ml.TABLE) - {ml.ROOT_RECORD}


def test_a_block_has_one_status_and_the_surfaces_agree_on_it():
    labels = ml.STATUS_LABELS
    for claim in POLICY["claim"]:
        name, status = claim["name"], claim["status"]
        if name == ml.ROOT_RECORD:
            continue
        assert status_of(name) == status, name
        assert f"| `{name}` | `{labels[status]}` |" in DOC, name


def test_required_for_final_is_the_root_record_edge_and_nothing_else():
    required = set(ml.required())
    for name in set(ml.TABLE) - {ml.ROOT_RECORD}:
        assert required_in_mojo(name) == (name in required), name
    edges = {e["source"] for e in GRAPH["edges"] if e["type"] == "implicative" and e["target"] == ml.ROOT_RECORD}
    assert edges == required


def test_the_final_readiness_predicate_conjoins_exactly_the_required_blocks():
    body = MOJO.split("def final_ledger_ready_for_c1()")[1].split("def ")[0]
    assert set(re.findall(r"block_ready_for_final\((\w+)_status\(\)\)", body)) == {ml.snake(n) for n in ml.required()}


def test_no_block_is_ready_while_any_required_one_is_unchecked():
    """The conservative rule the ledger exists to enforce, read off the records."""
    assert any(status_of(name) != "proved-or-imported-checked" for name in ml.required())
    assert 'ProofBlockStatus("ResidualClosureNoMissingLinks", False, False, True, False, True)' in MOJO


def test_the_generated_files_say_they_are_generated():
    for body in (MOJO, DOC, (ROOT / "docs" / "C1_ledger_index.md").read_text(encoding="utf-8")):
        assert "do not edit" in body
