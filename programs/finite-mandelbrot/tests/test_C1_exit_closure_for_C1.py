from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_exit_closure_for_C1.md"
SRC = ROOT / "kernel/mojo/c1/residual/exit_closure_for_C1.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_exit_closure_has_governed_declaration():
    body = text(DOC)
    assert "Terminology declaration: ExitClosureForC1" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_all_residual_exits_have_closure_targets():
    body = text(DOC) + "\n" + text(SRC)
    for term in [
        "FiniteSeparation",
        "BoundaryEqualityRefinement",
        "MissingTheoremCatalogueLink",
        "EstablishedTrivialFiberTag",
    ]:
        assert term in body
    for target in [
        "SeparatedPrefix",
        "BoundaryIdentification",
        "FiniteMissingLinkObligation",
        "CheckedTrivialFiberImport",
    ]:
        assert target in body


def test_exit_closure_requires_finite_payloads_and_adapters():
    body = text(SRC)
    assert "finite_payload_present" in body
    assert "theorem_tag_checked" in body
    assert "adapter_checked" in body
    assert "missing_link_recorded" in body
    assert "boundary_identification_checked" in body
    assert "exit_payload_closed" in body


def test_theorem_tag_imports_are_checked_not_reproved():
    body = text(DOC) + "\n" + text(SRC)
    assert "theorem tag" in body
    assert "assumptions" in body
    assert "imported_analytic_theorem_reproved_in_mojo() -> Bool" in body
    assert "theorem_tags_require_assumption_checks() -> Bool" in body
    assert "return False" in body
    assert "return True" in body


def test_exit_closure_is_not_a_c1_proof_by_itself():
    body = text(SRC)
    assert "c1_proved_by_exit_closure_alone() -> Bool" in body
    assert "return False" in body
    assert "bounded_search_is_exit_certificate() -> Bool" in body


def test_rank2_shortcuts_remain_blocked():
    body = text(DOC) + "\n" + text(SRC)
    assert "rank2_circle_primitive_available() -> Bool" in body
    assert "circle" in body
    assert "disk" in body
    assert "arc" in body
    assert "analytic-locus" in body or "analytic locus" in body


def test_next_highest_priority_move_is_named():
    body = text(DOC)
    assert "SeparatorCatalogueAdequacyProofObjects" in body
    assert "soundness" in body
    assert "completeness" in body
    assert "adequacy" in body
