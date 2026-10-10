from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT = ROOT / "docs" / "alignment_audit_deep_research_findings.md"
MOJO_POLICY = ROOT / "docs" / "mojo_first_execution_policy.md"
STATUS = ROOT / "kernel/mojo/theorem_kernel/alignment_audit_status.mojo"
KERNEL = ROOT / "kernel/mojo/theorem_kernel/mojo_theorem_kernel.mojo"
CALCULUS = ROOT / "docs" / "finite-certificate-calculus.md"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_deep_research_findings_are_recorded():
    body = text(AUDIT)
    assert "deep literature" in body
    assert "PersistentNonSeparation" in body
    assert "fiber-triviality strength" in body
    assert "MLC-strength" in body


def test_open_frontier_strength_gate_is_explicit():
    body = text(AUDIT) + "\n" + text(STATUS)
    assert "OPEN_FRONTIER" in body
    assert "MLC_STRENGTH_CANDIDATE" in body or "mlc_strength_candidate" in body
    assert "ResidualFrontierRefinement" in body
    assert "theorem_proved" in body


def test_finite_state_does_not_prove_global_termination():
    body = text(AUDIT) + "\n" + text(STATUS)
    assert "finite carrier at each stage does not imply" in body
    assert "bounded_search_proves_global_termination(policy: AlignmentPolicy)" in body
    assert "finite_state_alone_proves_well_foundedness(policy: AlignmentPolicy)" in body
    assert "return policy.bounded_search_global" in body


def test_mojo_is_first_class_execution_and_finite_theorem_kernel():
    body = text(MOJO_POLICY) + "\n" + text(STATUS) + "\n" + text(KERNEL)
    assert "Mojo is the default first-class language" in body
    assert "finite proof-object theorem kernel" in body
    assert "mojo_is_first_class_execution_language(policy: AlignmentPolicy)" in body
    assert "mojo_is_finite_theorem_kernel() -> Bool" in body
    assert "return True" in body


def test_mojo_kernel_does_not_reprove_imported_analytic_theorems():
    body = text(MOJO_POLICY) + "\n" + text(STATUS) + "\n" + text(KERNEL)
    assert "mojo_reproves_imported_analytic_theorems(policy: AlignmentPolicy)" in body
    assert "mojo_reproves_external_analytic_theorems() -> Bool" in body
    assert "theorem_tags_require_import_validation(policy: AlignmentPolicy)" in body
    assert "TheoremTagImport" in body
    assert "return False" in body


def test_separator_catalogue_adequacy_replaces_extensionality_for_new_work():
    body = text(AUDIT) + "\n" + text(MOJO_POLICY) + "\n" + text(STATUS)
    assert "SeparatorCatalogueSoundness" in body
    assert "SeparatorCatalogueCompleteness" in body
    assert "SeparatorCatalogueAdequacy" in body
    assert "legacy_catalogue_extensionality_name_retired_for_new_work" in body


def test_rank2_layer_restriction_not_absolute_ontology_claim():
    body = text(AUDIT) + "\n" + text(MOJO_POLICY) + "\n" + text(STATUS) + "\n" + text(KERNEL)
    assert "layer restriction" in body
    assert "not primitive constructors" in body or "must not expose primitive constructors" in body
    assert "rank2_circle_primitive_available(policy: AlignmentPolicy)" in body
    assert "rank2_higher_layer_adapter_required(policy: AlignmentPolicy)" in body
    assert "rank2_circle_primitive_available_in_kernel() -> Bool" in body


def test_exact_type_galois_invariance_correction_is_incorporated():
    body = text(CALCULUS)
    assert "Exact critical-orbit type is constant on each irreducible factor" in body
    assert "section C1" in body
    assert "Galois conjugates can mix exact-type and lower-type roots" not in body
    assert "pointwise" in body
    assert "same-box exclusions as its canonical verifier policy" in body


def test_alignment_policy_is_data_checked_not_literal_functions():
    body = text(STATUS)
    assert "struct AlignmentPolicy" in body
    assert "alignment_policy_valid(policy: AlignmentPolicy)" in body
    assert "return policy.mojo_first_class" in body
    assert "return policy.rank2_circle_primitive" in body
