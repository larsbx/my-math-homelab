from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/c1/separator/separation_grammar.mojo"
CHECKLIST = ROOT / "docs" / "C1_proof_obligation_checklist.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_separation_grammar_objects_exist():
    src = read(SRC)
    assert "from dynamics.ray_address import RayAddr" in src
    assert "struct LandingTag" in src
    assert "struct LandedRay" in src
    assert "struct SeparationLine" in src
    assert "struct SeparationCatalogue" in src
    assert "struct SameFiberLevel" in src
    assert "struct FiberNestStatus" in src


def test_generic_singleton_claim_is_rejected():
    src = read(SRC)
    assert "claims_generic_singleton" in src
    assert "not self.claims_generic_singleton" in src
    assert "fn must_reject_generic_singleton_claim" in src
    assert "return not bad.c1_bridge_ready()" in src


def test_c1_proof_obligations_are_explicit():
    doc = read(CHECKLIST)
    for token in ["PO-1", "PO-2", "PO-3", "PO-4", "PO-5", "PO-6", "PO-7"]:
        assert token in doc
    assert "The project contribution is not a proof of MLC" in doc
    assert "No unconditional generic co-landing certificate may be claimed" in doc


def test_secondary_work_is_blocked_from_critical_path():
    doc = read(CHECKLIST)
    for token in [
        "bigint backend implementation",
        "hash-root serialization",
        "renderer/pixel pipeline",
        "finite-field shadow experiments",
        "Krawczyk optimization",
    ]:
        assert token in doc


def test_no_analytic_shortcuts_in_separation_grammar():
    src = read(SRC).lower()
    forbidden = ["float64", "cmath", "numpy", "atan(", "radian", "degree", "sin(", "cos(", "tan(", "pixel"]
    for token in forbidden:
        assert token not in src
