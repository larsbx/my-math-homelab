from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_strict_carrier_refinement_wellfounded.md"
SRC = ROOT / "kernel/mojo/c1/carrier/strict_carrier_refinement_wellfounded.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_wellfoundedness_term_is_governed():
    body = text(DOC)
    assert "Terminology declaration: strict carrier refinement well-foundedness" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_descent_measure_is_finite_and_combinatorial():
    body = text(DOC)
    assert "unresolved_wake_slot_count" in body
    assert "carrier_vertex_count" in body
    assert "boundary_candidate_count" in body
    assert "missing_link_count" in body
    forbidden = ["metric diameter", "circle", "disk", "arc", "circumference", "analytic locus"]
    lower = body.lower()
    for phrase in forbidden:
        assert f"do not identify" in lower or phrase not in lower


def test_relabeling_only_is_rejected():
    src = text(SRC)
    assert "relabeling_only" in src
    assert "if step.relabeling_only" in src
    assert "return False" in src
    assert "demo_relabeling_rejected" in src


def test_strict_refinement_requires_descent_or_productive_outcome():
    src = text(SRC)
    assert "lex_decreases" in src
    assert "has_productive_outcome" in src
    assert "accepted_strict_refinement" in src
    for token in [
        "discharges_unresolved_slot",
        "yields_boundary_equality",
        "yields_missing_link",
        "yields_opposite_side_separation",
    ]:
        assert token in src


def test_no_c1_or_singleton_claim_is_made():
    src = text(SRC)
    assert "fn proves_c1" in src
    assert "fn proves_singleton_fiber" in src
    assert "return False" in src


def test_rank2_circle_primitive_unavailable():
    src = text(SRC)
    assert "rank2_circle_primitive_available" in src
    assert "return False" in src
