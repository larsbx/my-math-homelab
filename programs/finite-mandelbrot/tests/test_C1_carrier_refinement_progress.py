from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_carrier_refinement_progress.md"
SRC = ROOT / "kernel/mojo/c1/carrier/carrier_refinement_progress.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_terms_are_governed_with_genealogy_and_leaks():
    body = text(DOC)
    assert "Terminology declaration: strict carrier refinement" in body
    assert "Terminology declaration: missing theorem/catalogue link" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_progress_dichotomy_outcomes_are_named():
    body = text(DOC)
    src = text(SRC)
    for term in [
        "StrictCarrierRefinement",
        "MissingTheoremCatalogueLink",
        "BoundaryEqualityRefinement",
        "RefinesToOppositeSideSeparation",
    ]:
        assert term in body
        assert term in src


def test_carrier_obstruction_is_productive_but_not_c1_proof():
    src = text(SRC)
    assert "is_productive" in src
    assert "proves_c1" in src
    assert "proves_singleton_fiber" in src
    assert "False, False" in src
    assert "carrier_progress_dichotomy_pending" in src


def test_rank2_circle_primitive_remains_unavailable():
    src = text(SRC)
    body = text(DOC)
    assert "rank2_circle_primitive_available" in src
    assert "return False" in src
    assert "No case may introduce a circle" in body


def test_no_renderer_or_bounded_search_shortcut_language():
    combined = (text(DOC) + "\n" + text(SRC)).lower()
    assert "renderer proves" not in combined
    assert "numerical image proves" not in combined
    assert "bounded search proves" not in combined
