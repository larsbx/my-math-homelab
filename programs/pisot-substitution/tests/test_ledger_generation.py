"""The proof-dependency ledger is generated from proof/tla/ledger.json and says what the old hand-written models said."""

from __future__ import annotations

import json
import re
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import make_ledger  # noqa: E402
from proof_records import generate_ledgers as gl  # noqa: E402

MODELS = ("FormalProductivityGateAssumed", "Open", "Imports", "G1AndProducer", "G1Only", "G1AndC4", "RenewalGateAssumed", "SpectralGateAssumed", "OverlapGateAssumed", "AllSeedOverlapGateAssumed", "AllSeedStrictZipperGateAssumed")


def reachable(model: str) -> set[str]:
    text = (ROOT / "proof" / "tla" / f"MCLedger{model}.tla").read_text(encoding="utf-8")
    body = text[text.index("Reachable == {"):text.index("EventuallyReachable")]
    return set(re.findall(r'"([A-Za-z0-9_]+)"', body))


def test_generated_surfaces_are_current():
    result = subprocess.run([sys.executable, str(ROOT / "tools" / "make_ledger.py"), "--check"], capture_output=True, text=True, check=False)
    assert result.returncode == 0, result.stdout


def test_every_ledger_node_is_a_validated_record_with_a_generated_claim():
    analysis = gl.analyse(gl.load_ledger(ROOT / "proof" / "tla" / "ledger.json"))
    names = {e.name for e in analysis.entries}
    tla = (ROOT / "proof" / "tla" / "Ledger.tla").read_text(encoding="utf-8")
    assert names == set(re.findall(r'^    "([A-Za-z0-9_]+)",?$', tla[tla.index("ResultSet == {"):tla.index("RequiresDef")], re.M))
    policy = tomllib.loads((ROOT / "claim_governance.toml").read_text(encoding="utf-8"))
    claims = {c["name"]: c for c in policy["claim"]}
    assert names <= set(claims)
    assert claims["G1"]["status"] == "open" and claims["CoincidenceDensityOne"]["status"] == "proved" and claims["SinkSCCReduction"]["status"] == "conditional"
    assert claims["DensityToPDSBridge"]["status"] == "imported" and claims["V5Thm51"]["status"] == "retired"
    assert claims["PDSOverlapRoute"]["status"] == "conditional"
    statuses = {e.name: e.status for e in analysis.entries}
    assert all(claims[n]["status"] == s for n, s in statuses.items())


def test_status_overrides_are_recorded_in_the_records():
    data = json.loads((ROOT / "proof" / "tla" / "ledger.json").read_text(encoding="utf-8"))
    for name in make_ledger.STATUS_NOTES:
        record = data["records"][name]
        assert any(t.startswith("status:") for t in record["tags"]) and ["status_note", make_ledger.STATUS_NOTES[name]] in record["evidence"]


def test_models_state_what_the_hand_written_configurations_demonstrated():
    open_set = reachable("Open")
    assert "SpectralBlackBox" in open_set and "G1b1BoundedDiscrepancy" in open_set and "SwapOverlapFiniteness" in open_set
    for gate in ("PDS", "LoadBearingSCC", "SCCProducer", "G1b2RenewalFiniteness", "ConcentrationAuxB", "OverlapProductivity", "PDSImpliesRepoG1", "V5Thm51"):
        assert gate not in open_set, gate
    assert "DensityToPDSBridge" not in open_set and "DensityToPDSBridge" in reachable("Imports")
    assert "PDS" in reachable("G1AndProducer") and "PDS" in reachable("G1AndC4")
    assert "LoadBearingSCC" in reachable("G1Only") and "PDS" not in reachable("G1Only")
    assert "G1" in reachable("RenewalGateAssumed")
    assert "PDSSpectralRoute" in reachable("SpectralGateAssumed")
    assert {"CoincidenceDensityOne", "PDSOverlapRoute"} <= reachable("OverlapGateAssumed")
    assert all("V5Thm51" not in reachable(m) for m in MODELS)


def test_check_script_runs_every_generated_model_and_no_stale_model_remains():
    script = (ROOT / "proof" / "tla" / "check.sh").read_text(encoding="utf-8")
    for model in MODELS:
        assert f'"MCLedger{model}:HOLD"' in script
        assert (ROOT / "proof" / "tla" / f"MCLedger{model}.cfg").exists()
    assert not list((ROOT / "proof" / "tla").glob("MCArchitecture*"))
    assert "MCArchitecture" not in script


def test_all_seed_overlap_route_establishes_canonical_g1_and_downstream():
    analysis = gl.analyse(gl.load_ledger(ROOT / "proof" / "tla" / "ledger.json"))
    by_name = {e.name: e for e in analysis.entries}
    g1 = by_name["G1"]
    assert g1.routes == (("G1FromRenewal",), ("G1OverlapRoute",), ("G1HalfCoincidenceRoute",), ("G1FormalProductivityRoute",))
    assert g1.status == "open"
    done = gl.established(analysis, ("AllSeedOverlapProductivity",))
    assert {"G1OverlapRoute", "G1", "SinkSCCReduction", "LoadBearingSCC"} <= done
    assert done == reachable("AllSeedOverlapGateAssumed")
    assert not {"G1FromRenewal", "G1b2RenewalFiniteness", "PDS", "SCCProducer", "OverlapProductivity"} & done
    cfg = (ROOT / "proof/tla/MCLedgerAllSeedOverlapGateAssumed.cfg").read_text()
    assert "    G1NotEstablished\n" not in cfg
    assert "    G1b2RenewalFinitenessNotEstablished\n" in cfg
    assert "    PDSNotEstablished\n" in cfg
    assert "G1" not in reachable("Open") and "G1" not in reachable("Imports")
    assert "G1" not in reachable("OverlapGateAssumed")  # one seed is not all seeds
    assert "G1" in reachable("RenewalGateAssumed")


def test_strict_zipper_exclusion_route_establishes_canonical_g1_without_productivity():
    analysis = gl.analyse(gl.load_ledger(ROOT / "proof" / "tla" / "ledger.json"))
    done = gl.established(analysis, ("AllSeedStrictZipperExclusion",))
    assert {"G1HalfCoincidenceRoute", "G1", "SinkSCCReduction", "LoadBearingSCC"} <= done
    assert done == reachable("AllSeedStrictZipperGateAssumed")
    # excluding strict zippers gives finiteness, not productivity or PDS
    assert not {"G1OverlapRoute", "AllSeedOverlapProductivity", "OverlapProductivity", "PDS", "PDSOverlapRoute", "SCCProducer", "G1b2RenewalFiniteness"} & done
    cfg = (ROOT / "proof/tla/MCLedgerAllSeedStrictZipperGateAssumed.cfg").read_text()
    assert "    G1NotEstablished\n" not in cfg
    assert "    PDSNotEstablished\n" in cfg
    assert "G1HalfCoincidenceRoute" not in reachable("AllSeedOverlapGateAssumed")  # the gates are separate nodes


def test_formal_productivity_reaches_g1_and_both_pds_routes_but_not_pds():
    analysis = gl.analyse(gl.load_ledger(ROOT / "proof" / "tla" / "ledger.json"))
    gate = ("FormalProductivity", "PisotMeyerProperty", "OverlapCoincidenceCriterion", "DensityToPDSBridge")
    done = gl.established(analysis, gate)
    assert done == reachable("FormalProductivityGateAssumed")
    assert {"G1FormalProductivityRoute", "G1", "PDSFormalProductivityRoute", "PDSFormalProductivitySeedRoute"} <= done
    # FP discharges the routes directly; it does not establish the weaker seed gates
    assert not {"PDS", "SCCProducer", "OverlapProductivity", "AllSeedOverlapProductivity", "AllSeedStrictZipperExclusion",
                "PDSOverlapRoute", "G1OverlapRoute", "G1HalfCoincidenceRoute"} & done
    # each PDS route needs its own import
    alone = gl.established(analysis, ("FormalProductivity",))
    assert "G1" in alone and not {"PDSFormalProductivityRoute", "PDSFormalProductivitySeedRoute"} & alone


def test_box_and_leftmost_certificates_are_unconditional_and_not_g1_routes():
    analysis = gl.analyse(gl.load_ledger(ROOT / "proof" / "tla" / "ledger.json"))
    unconditional = {"BoxCycleContainment", "BoxAutomatonCertificate", "LeftmostChainCycleStructure", "LeftmostChainG1Certificate"}
    assert unconditional <= reachable("Open")
    assert "FormalProductivity" not in reachable("Open")
    # Corollary LC5 is per specimen; its uniform form is false, so it is no G1 branch
    g1 = {e.name: e for e in analysis.entries}["G1"]
    assert all("LeftmostChainG1Certificate" not in branch for branch in g1.routes)


def test_alternative_routes_are_bound_to_the_canonical_record_identity():
    from dataclasses import replace
    from proof_records.records import identified
    records = make_ledger.records()
    g1 = records["G1"]
    branches = json.loads(g1.field("dependency_alternatives"))
    assert branches == [[records[r].id] for r in ("G1FromRenewal", "G1OverlapRoute", "G1HalfCoincidenceRoute", "G1FormalProductivityRoute")]
    removed = identified(replace(g1, id="", evidence=tuple((k,v) for k,v in g1.evidence if k != "dependency_alternatives")))
    assert removed.id != g1.id
    assert all(e.record_id != removed.id for e in records["SinkSCCReduction"].depends_on)


def test_per_specimen_pds_certificate_needs_both_imports_and_only_the_shortcut():
    analysis = gl.analyse(gl.load_ledger(ROOT / "proof/tla/ledger.json"))
    entries = {e.name: e for e in analysis.entries}
    names = {e.record.id: e.name for e in analysis.entries}
    certificate = entries["BoxAutomatonPDSCertificate"]
    assert {names[r] for r in certificate.closure.reached} == {
        "BoxAutomatonPDSCertificate", "BoxAutomatonCertificate", "BoxCycleContainment",
        "PisotMeyerProperty", "OverlapCoincidenceCriterion",
    }
    assert certificate.status == "proved"
    assert "BoxAutomatonPDSCertificate" not in reachable("Open")
    assert "BoxAutomatonPDSCertificate" in reachable("Imports")
    for single_import in ("PisotMeyerProperty", "OverlapCoincidenceCriterion"):
        done = gl.established(analysis, (single_import, "FormalProductivity"))
        assert not {"BoxAutomatonPDSCertificate", "PDSFormalProductivityRoute"} & done


def test_reconciled_certificates_do_not_supply_their_uniform_premises():
    analysis = gl.analyse(gl.load_ledger(ROOT / "proof/tla/ledger.json"))
    records = make_ledger.records()
    assert "if every vertex" in records["BoxAutomatonPDSCertificate"].statement
    assert "right-infinite" in records["LeftmostChainCycleStructure"].statement
    assert "no terminal leftmost cycle" in records["LeftmostChainG1Certificate"].statement
    gates = {"PDS", "G1", "FormalProductivity", "OverlapProductivity",
             "AllSeedOverlapProductivity", "AllSeedStrictZipperExclusion"}
    for done in (reachable("Open"), reachable("Imports"),
                 gl.established(analysis, tuple(make_ledger.BOX_LC_REVIEWED))):
        assert not gates & done
    # Competing registrations map to these canonical nodes, rather than becoming
    # additional claims that could drift independently.
    assert not {"PotentialOverlapFiniteDescent", "OverlapCycleBoxBound",
                "BoxFormalProductivityEquivalence", "BoxProductivityEquivalence",
                "BoxPDSCertificate", "PisotFamilyMeyerProperty", "LeftmostChainSign",
                "LeftmostChainSignPreservation", "LeftmostChainPeriodicPair"} & set(records)


def test_review_evidence_remains_bound_to_each_reconciled_record():
    for name in make_ledger.BOX_LC_REVIEWED:
        record = make_ledger.records()[name]
        assert record.field("review_source") == make_ledger.BOX_LC_REVIEW
        assert record.field("review_date") == "2026-10-08"
        assert record.field("source_revision") == make_ledger.BOX_LC_BASELINE
        assert record.field("reconciled_source_revision") == make_ledger.BOX_LC_RECONCILED_BASELINE
        assert record.field("human_review_pending") == "true"
        for field in ("review_source", "additional_review_source", "reconciliation_source"):
            assert (ROOT / record.field(field)).is_file()


def test_model_rejects_false_g1_nonestablishment_with_tlc(tmp_path):
    import os
    import shutil
    import pytest
    jar = os.environ.get("TLA_TOOLS")
    if not jar or not Path(jar).is_file() or not shutil.which("java"):
        pytest.skip("set TLA_TOOLS to check the alternative dependency model")
    model = "MCLedgerAllSeedOverlapGateAssumed"
    for name in ("ProofArchitecture.tla", "Ledger.tla", model + ".tla", model + ".cfg"):
        shutil.copyfile(ROOT / "proof" / "tla" / name, tmp_path / name)
    cfg = tmp_path / (model + ".cfg")
    cfg.write_text(cfg.read_text().replace("    TypeOK\n", "    TypeOK\n    G1NotEstablished\n"))
    out = subprocess.run(["java", "-XX:+UseSerialGC", "-cp", jar, "tlc2.TLC", "-workers", "1", model],
                         cwd=tmp_path, capture_output=True, text=True, timeout=60)
    assert "Invariant G1NotEstablished is violated" in out.stdout, out.stdout + out.stderr
