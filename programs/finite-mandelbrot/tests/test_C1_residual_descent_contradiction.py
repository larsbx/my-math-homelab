from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_residual_descent_contradiction.md"
SRC = ROOT / "kernel/mojo/c1/residual/residual_descent_contradiction.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_residual_descent_has_governed_terminology():
    body = text(DOC)
    assert "Terminology declaration: residual descent contradiction" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_all_residual_hypotheses_are_required():
    src = text(SRC)
    for token in [
        "persistent_nonseparation",
        "no_missing_link",
        "no_boundary_equality",
        "canonical_carrier_content",
        "residual_frontier_refinement",
        "strict_refinement_wellfounded",
    ]:
        assert token in src
    assert "residual_descent_ready" in src


def test_allowed_residual_exits_are_explicit():
    src = text(SRC)
    for token in [
        "finite_separation",
        "boundary_equality_refinement",
        "missing_theorem_catalogue_link",
        "established_trivial_fiber_tag",
    ]:
        assert token in src
    assert "has_allowed_exit" in src


def test_contradiction_does_not_claim_c1_or_singleton_fiber():
    src = text(SRC)
    assert "proves_c1" in src
    assert "proves_singleton_fiber" in src
    assert "ResidualDescentConclusion(True, True, False, False)" in src


def test_no_bounded_search_or_rank2_circle_shortcut():
    src = text(SRC)
    assert "bounded_search_proves_residual_contradiction" in src
    assert "return False" in src
    assert "rank2_circle_primitive_available" in src
    assert "circle" in src.lower()
    assert "disk" not in src.lower()
    assert "circumference" not in src.lower()
