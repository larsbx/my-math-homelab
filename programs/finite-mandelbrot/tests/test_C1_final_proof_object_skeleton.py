from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_final_proof_object_skeleton.md"
SRC = ROOT / "kernel/mojo/c1/proof/final_proof_object_skeleton.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_final_proof_skeleton_declares_required_blocks():
    body = text(DOC) + "\n" + text(SRC)
    for block in [
        "SeparatorCatalogueSoundness",
        "SeparatorCatalogueCompleteness",
        "FiberDefinitionAdapter",
        "ResidualClosureNoMissingLinks",
        "ExitClosureForC1",
        "BoundaryEqualitySoundness",
        "TheoremTagImportSoundness",
    ]:
        assert block in body


def test_final_acceptance_requires_all_blocks_and_guards():
    body = text(SRC)
    assert "def all_required_blocks_checked" in body
    assert "def all_final_guards_checked" in body
    assert "def accepts_c1_final_proof_object" in body
    assert "all_required_blocks_checked(proof) and all_final_guards_checked(proof)" in body


def test_missing_link_exit_is_forbidden_in_final_proof():
    body = text(DOC) + "\n" + text(SRC)
    assert "MissingTheoremCatalogueLink" in body
    assert "forbidden in the final proof" in body
    assert "missing_link_exit_absent" in body
    assert "rejects_missing_link_final_exit(policy: FinalProofAcceptancePolicy)" in body
    assert "return policy.rejects_missing_link_exit" in body


def test_final_skeleton_rejects_known_shortcuts():
    body = text(DOC) + "\n" + text(SRC)
    for phrase in [
        "bounded search",
        "label-only equality",
        "rank-2 circle",
        "generic landing claims without theorem tags",
        "unchecked imported analytic theorem",
    ]:
        assert phrase in body
    assert "final_proof_rejects_bounded_search_shortcut" in body
    assert "final_proof_rejects_rank2_locus_primitive" in body
    assert "final_proof_rejects_label_only_equality" in body


def test_skeleton_does_not_claim_c1_by_itself():
    body = text(DOC) + "\n" + text(SRC)
    assert "skeleton_alone_proves_c1(policy: FinalProofAcceptancePolicy)" in body
    assert "return policy.skeleton_alone_proves_c1" in body
    assert "the final proof is not complete" in body


def test_next_priority_is_block_ledger():
    body = text(DOC) + "\n" + text(SRC)
    assert "FinalProofBlockLedger" in body
    assert "next_priority_target() -> String" in body


def test_acceptance_policy_is_explicit_data_with_a_validator():
    body = text(SRC)
    assert "struct FinalProofAcceptancePolicy(ImplicitlyCopyable)" in body
    assert "def canonical_final_proof_acceptance_policy" in body
    assert "def final_proof_acceptance_policy_valid" in body
    assert "not policy.reproves_imported_analytic_theorems" in body
    assert "not policy.skeleton_alone_proves_c1" in body
