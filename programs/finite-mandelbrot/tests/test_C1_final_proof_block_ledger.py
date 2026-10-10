from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_final_proof_block_ledger.md"
SRC = ROOT / "kernel/mojo/c1/proof/final_proof_block_ledger.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ledger_names_all_required_final_blocks():
    body = read(DOC) + "\n" + read(SRC)
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


def test_current_statuses_are_conservative():
    src = read(SRC)
    assert 'ProofBlockStatus("ResidualClosureNoMissingLinks", False, False, True, False, True)' in src
    assert 'ProofBlockStatus("SeparatorCatalogueSoundness", False, True, False, False, True)' in src
    assert 'ProofBlockStatus("TheoremTagImportSoundness", False, True, False, False, True)' in src
    assert "final_ledger_ready_for_c1() -> Bool" in src


def test_final_readiness_requires_proved_checked_blocks_only():
    src = read(SRC)
    assert "proved_or_imported_checked" in src
    assert "not block.scaffolded" in src
    assert "not block.open_frontier" in src
    assert "not block.research_only" in src


def test_forbidden_final_evidence_is_rejected():
    body = read(DOC) + "\n" + read(SRC)
    for hook in [
        "missing_link_exit_allowed_in_final(policy: FinalEvidencePolicy) -> Bool",
        "bounded_search_allowed_as_final_evidence(policy: FinalEvidencePolicy) -> Bool",
        "label_only_equality_allowed_as_final_evidence(policy: FinalEvidencePolicy) -> Bool",
        "unchecked_theorem_tag_allowed_in_final(policy: FinalEvidencePolicy) -> Bool",
        "rank2_locus_primitive_allowed_in_final(policy: FinalEvidencePolicy) -> Bool",
    ]:
        assert hook in body
    assert "final_evidence_policy_valid(policy: FinalEvidencePolicy)" in body
    assert "return policy.missing_link_exit" in body


def test_priority_and_next_block_are_explicit():
    body = read(DOC) + "\n" + read(SRC)
    assert "current_priority_block() -> String" in body
    assert "return residual_closure_no_missing_links_status().name" in body
    assert "next_immediate_block() -> String" in body
    assert "return theorem_tag_payload_instances_status().name" in body


def test_policy_and_priority_are_derived_from_ledger_data():
    src = read(SRC)
    assert "struct FinalEvidencePolicy" in src
    assert "canonical_final_evidence_policy()" in src
    assert "return FinalEvidencePolicy(False, False, False, False, False)" in src
    assert "def import_ledger_created()" in src
    assert "theorem_tag_import_ledger_status().proved_or_imported_checked" in src
