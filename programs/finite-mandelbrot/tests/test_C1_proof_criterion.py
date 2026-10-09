from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_proof_definition_and_priority.md"
SRC = ROOT / "kernel/mojo/c1/proof/proof_criterion.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_c1_proof_definition_is_priority_zero():
    body = text(DOC) + "\n" + text(SRC)
    assert "Status: PRIORITY_ZERO" in body
    assert "fn c1_priority() -> String" in body
    assert 'return "PRIORITY_ZERO"' in body
    assert "C1 proof work outranks all other repo tasks" in body


def test_c1_target_and_dual_statement_are_defined():
    body = text(DOC) + "\n" + text(SRC)
    assert "A != B  =>  exists k. Separated_k(A,B)" in body
    assert "forall k. not Separated_k(A,B)  =>  BoundaryEquality(A,B)" in body
    assert "fn c1_target_statement() -> String" in body
    assert "fn c1_dual_statement() -> String" in body


def test_all_required_proof_blocks_are_named():
    body = text(DOC) + "\n" + text(SRC)
    for block in [
        "SeparatorCatalogueSoundness",
        "SeparatorCatalogueCompleteness",
        "SeparatorCatalogueAdequacy",
        "FiberDefinitionAdapter",
        "ResidualClosureNoMissingLinks",
        "ExitClosureForC1",
        "C1FinalProofObject",
    ]:
        assert block in body
    assert "c1_completion_requires_all_blocks() -> Bool" in body
    assert "return True" in body


def test_missing_link_exit_is_forbidden_in_final_c1_proof():
    body = text(DOC) + "\n" + text(SRC)
    assert "forbidden outcome" in body
    assert "MissingTheoremCatalogueLink" in body
    assert "c1_completion_allows_missing_link_exit() -> Bool" in body
    assert "missing_link_exit_allowed_in_final_proof" in body
    assert "False,  # final proof may not leave MissingTheoremCatalogueLink open" in body


def test_mojo_theorem_kernel_final_check_is_required():
    body = text(DOC) + "\n" + text(SRC)
    assert "Mojo theorem-kernel certificate" in body
    assert "finite proof object checked by the Mojo theorem kernel" in body
    assert "mojo_kernel_must_check_final_proof_object() -> Bool" in body
    assert "theorem_tag_import_validation_required" in body


def test_current_status_names_highest_priority_open_block():
    body = text(DOC) + "\n" + text(SRC)
    assert "C1 is not proved" in body
    assert "highest_priority_open_block() -> String" in body
    assert 'return "ResidualClosureNoMissingLinks"' in body
    assert 'return "SeparatorCatalogueAdequacyProofObjects"' in body
    assert 'return "FiberDefinitionAdapterProofObject"' in body
    assert 'return "C1FinalProofObject"' in body


def test_insufficient_evidence_is_explicitly_rejected():
    body = text(DOC) + "\n" + text(SRC)
    for phrase in [
        "bounded search with no counterexample",
        "renderer/picture shrinkage",
        "finite carrier state at each step without global descent",
        "a residual proof that still allows MissingTheoremCatalogueLink",
    ]:
        assert phrase in body
    assert "bounded_search_sufficient" in body
    assert "False,  # bounded search is never sufficient" in body


def test_rank2_circle_remains_unavailable_for_c1():
    body = text(SRC)
    assert "rank2_circle_primitive_available_for_c1() -> Bool" in body
    assert "return False" in body
