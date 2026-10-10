from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_no_renaming_as_refinement.md"
SRC = ROOT / "kernel/mojo/c1/carrier/no_renaming_refinement.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_doc_declares_no_renaming_term_with_required_fields():
    body = text(DOC)
    assert "Terminology declaration: NoRenamingAsRefinement" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_renaming_only_rule_is_explicit():
    body = text(DOC)
    assert "RenamingOnly(C0, C1)" in body
    assert "not StrictCarrierRefinement" in body
    assert "Names, display order, file paths" in body


def test_source_compares_finite_content_not_display_name():
    body = text(SRC)
    assert "struct CarrierContent" in body
    assert "struct CarrierPresentation" in body
    assert "display_name_id" in body
    assert "fn same_content" in body
    assert "fn renaming_only" in body
    assert "return same_content(a.content, b.content)" in body


def test_strict_refinement_rejects_renaming_only():
    body = text(SRC)
    assert "if renaming_only(before, after):" in body
    assert "return False" in body
    assert "fn demo_renaming_rejected" in body


def test_productive_certificate_required():
    body = text(SRC)
    for term in [
        "measure_decreases",
        "opposite_side_separation",
        "boundary_equality_refinement",
        "missing_theorem_catalogue_link",
    ]:
        assert term in body
    assert "fn productive_certificate" in body


def test_no_global_or_rank2_overclaim():
    body = text(SRC)
    assert "fn proves_c1() -> Bool:" in body
    assert "return False" in body
    assert "fn rank2_circle_primitive_available() -> Bool:" in body
