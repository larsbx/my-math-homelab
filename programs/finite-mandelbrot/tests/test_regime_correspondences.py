from pathlib import Path
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "schemas/regime_correspondences.toml"
AUDIT = ROOT / "tools" / "audit_regime_correspondences.py"


def load_spec():
    with SPEC.open("rb") as handle:
        return tomllib.load(handle)


def test_correspondence_spec_has_closed_classes_and_statuses():
    data = load_spec()
    assert data["schema_version"] == 1
    assert set(data["allowed_classes"]) == {
        "exact_algebraic_realization", "axiom_preserving_finite_analogue",
        "finite_certificate_surrogate", "symbolic_encoding", "prohibited_correspondence",
    }
    assert set(data["allowed_statuses"]) == {
        "defined", "implemented_tested", "theorem_dependent", "prohibited",
    }


def test_every_mapping_declares_preservation_leaks_and_boundary():
    for entry in load_spec()["correspondence"]:
        for field in ("analytic_concepts", "finite_term", "preserves", "does_not_inherit", "domain_conditions", "evidence", "proof_boundary"):
            assert entry[field]


def test_core_policy_mappings_are_seeded():
    entries = {entry["id"]: entry for entry in load_spec()["correspondence"]}
    assert {
        "rank2-coordinate-record", "unit-quadrance-rotor", "rational-ray-address",
        "rational-box-half-width", "formal-polynomial-derivative",
        "rational-box-krawczyk-replay", "landing-association-replay",
        "unit-circle-primitive",
    } <= entries.keys()
    assert entries["landing-association-replay"]["status"] == "theorem_dependent"
    assert "C1" in entries["landing-association-replay"]["does_not_inherit"]
    assert entries["unit-circle-primitive"]["symbols"] == []


def test_executable_bindings_have_matching_source_tags():
    result = subprocess.run([sys.executable, str(AUDIT)], cwd=ROOT, text=True, capture_output=True)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "Regime correspondence audit passed." in result.stdout


def test_global_proof_boundaries_remain_noninherited():
    joined = "\n".join(item for entry in load_spec()["correspondence"] for item in entry["does_not_inherit"])
    assert "certificate acceptance" in joined
    assert "C1" in joined
    assert "ResidualClosureNoMissingLinks" in joined
