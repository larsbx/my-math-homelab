from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_carrier_progress_dichotomy.md"
SRC = ROOT / "kernel/mojo/c1/carrier/carrier_progress_dichotomy.mojo"


def read(path):
    return path.read_text(encoding="utf-8")


def test_dichotomy_document_has_governed_declaration():
    body = read(DOC)
    assert "Terminology declaration: carrier progress dichotomy" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_dichotomy_has_exact_productive_cases():
    body = read(DOC)
    for term in [
        "StrictCarrierRefinement",
        "MissingTheoremCatalogueLink",
        "BoundaryEqualityRefinement",
        "RefinesToOppositeSideSeparation",
    ]:
        assert term in body
        assert term in read(SRC)


def test_scaffold_rejects_invalid_inputs_and_unknown_kinds():
    src = read(SRC)
    assert "not input.accepted" in src
    assert "not input.has_incidence_carrier" in src
    assert "not input.has_governed_terms" in src
    assert "not allowed_dichotomy_kind(kind)" in src
    assert "rejected" in src


def test_dichotomy_does_not_prove_c1_or_singleton_fiber():
    src = read(SRC)
    assert "self.proves_c1 = False" in src
    assert "self.proves_singleton_fiber = False" in src


def test_rank2_circle_is_rejected_in_dichotomy_layer():
    body = read(DOC).lower()
    src = read(SRC)
    assert "no case may invoke a circle" in body
    assert "rank2_circle_primitive_available() -> Bool" in src
    assert "return False" in src
    assert "input.rank2_circle_used" in src
