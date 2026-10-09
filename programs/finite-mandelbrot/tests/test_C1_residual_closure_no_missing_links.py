from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_residual_closure_no_missing_links.md"
SRC = ROOT / "kernel/mojo/c1/residual/residual_closure_no_missing_links.mojo"
CRITERION = ROOT / "docs" / "C1_proof_definition_and_priority.md"


def body(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_priority_block_is_declared_and_explained():
    text = body(DOC) + "\n" + body(SRC)
    assert "Status: priority-zero open proof block" in text
    assert "ResidualClosureNoMissingLinks" in text
    assert "current_priority_block() -> String" in text
    assert 'return "ResidualClosureNoMissingLinks"' in text


def test_declaration_has_genealogy_leaks_and_use_discipline():
    text = body(DOC)
    for field in [
        "Terminology declaration:",
        "Genealogy:",
        "Bridge claim:",
        "Known leaks:",
        "Use discipline:",
    ]:
        assert field in text
    assert "fiber-triviality / MLC strength" in text


def test_required_dependencies_are_explicit():
    text = body(DOC) + "\n" + body(SRC)
    for required in [
        "PersistentNonSeparation",
        "SeparatorCatalogueAdequacy",
        "FiberDefinitionAdapter",
        "ExitClosureForC1",
        "NoOpenMissingTheoremCatalogueLink",
    ]:
        assert required in text
    assert "residual_closure_dependencies_ready" in text


def test_only_three_final_exits_are_accepted():
    text = body(SRC)
    for accepted in [
        "finite_separation",
        "boundary_equality",
        "established_trivial_fiber",
    ]:
        assert accepted in text
    assert "accepted_final_exit" in text
    assert "accepted_final_exit(kind: FinalExitKind)" in text


def test_final_exit_kind_is_typed_not_free_form_string():
    text = body(SRC)
    assert "struct FinalExitKind" in text
    assert "var final_exit_kind: FinalExitKind" in text
    assert "final_exit_kind: String" not in text
    assert "accepted_final_exit(kind: String)" not in text


def test_missing_link_and_shortcuts_are_rejected():
    text = body(DOC) + "\n" + body(SRC)
    for rejected in [
        "missing_theorem_catalogue_link",
        "open_analytic_assumption",
        "bounded_search_failure",
        "label_equality_only",
    ]:
        assert rejected in text
    assert "missing_link_exit_allowed_in_final_c1_proof() -> Bool" in text
    assert "bounded_search_establishes_persistent_nonseparation() -> Bool" in text
    assert "return False" in text


def test_imported_theorems_and_boundary_equality_have_payload_checks():
    text = body(SRC)
    assert "imported_theorem_assumption_payloads" in text
    assert "boundary_equality_uses_content_not_label" in text
    assert "FinalExitKind.established_trivial_fiber()" in text
    assert "FinalExitKind.boundary_equality()" in text


def test_no_rank2_locus_shortcut_and_not_c1_by_itself():
    text = body(DOC) + "\n" + body(SRC)
    assert "rank2_circle_disk_arc_locus_available() -> Bool" in text
    assert "uses_rank2_locus_primitive" in text
    assert "proves_c1_by_itself() -> Bool" in text
    assert "This block does not prove C1 alone" in text


def test_next_block_is_final_proof_object_skeleton():
    text = body(DOC) + "\n" + body(SRC)
    assert "C1FinalProofObjectSkeleton" in text
    assert "next_priority_block_after_residual_closure" in text
