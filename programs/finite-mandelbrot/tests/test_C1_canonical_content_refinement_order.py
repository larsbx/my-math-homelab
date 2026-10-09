from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_canonical_content_refinement_order.md"
SRC = ROOT / "kernel/mojo/c1/carrier/canonical_content_refinement_order.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_refinement_order_has_governed_declaration():
    body = read(DOC)
    assert "Terminology declaration: CanonicalContentRefinementOrder" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_four_accepted_order_cases_are_documented_and_encoded():
    doc = read(DOC)
    src = read(SRC)
    for name in [
        "ObligationDischarge",
        "CarrierSplit",
        "BoundaryCandidateDischarge",
        "MissingLinkExposure",
    ]:
        assert name in src
    for phrase in [
        "Obligation discharge",
        "Carrier split",
        "Boundary candidate discharge",
        "Missing-link exposure",
    ]:
        assert phrase in doc


def test_renaming_reordering_and_synonym_changes_are_rejected():
    body = read(DOC)
    src = read(SRC)
    assert "changing display labels" in body
    assert "reordering atoms" in body
    assert "replacing a term by a synonym" in body
    assert "display_label_only" in src
    assert "return False" in src


def test_missing_link_exposure_is_productive_but_not_c1():
    src = read(SRC)
    assert "theorem_or_catalogue_link_named" in src
    assert "missing_link_exposure" in src
    assert "fn proves_c1() -> Bool:" in src
    assert "return False" in src


def test_no_rank2_circle_or_locus_primitives():
    combined = (read(DOC) + "\n" + read(SRC)).lower()
    assert "rank2_circle_primitive_available" in combined
    assert "circle primitive available" not in combined
    assert "analytic locus objects" in combined or "analytic locus language" in combined
