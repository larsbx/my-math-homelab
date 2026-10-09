from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CLASSIFICATION = ROOT / "kernel/mojo/certificates/c_minus_2/proof_grade_misiurewicz_trivial_fiber_classification.mojo"
TAGS = ROOT / "kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo"
GATE = ROOT / "kernel/mojo/certificates/c_minus_2/bigq_finite_certificate_gate.mojo"
SMOKE = ROOT / "kernel/mojo/smoke/smoke_tests.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_classification_is_bound_to_exact_c_minus_2_type_2_1():
    body = read(CLASSIFICATION)
    assert "self.landing_target.proof_grade_associated()" in body
    assert "self.target_num == -2 and self.target_den == 1" in body
    assert "self.ell == 2 and self.period == 1" in body
    assert "self.target_num == self.landing_target.target_num" in body
    assert "self.ell == self.landing_target.ell" in body
    assert "landing.target_exact_type_verified" in body


def test_class_specific_import_requires_exact_ledger_payload_and_source():
    body = read(CLASSIFICATION)
    assert "misiurewicz_c_minus_2_trivial_fiber_tag_checked" in body
    assert "misiurewicz_trivial_fiber_payload_scaffold" in body
    assert 'self.citation_key == "SchleicherFibersLC"' in body
    assert 'self.covered_class == "Misiurewicz parameters"' in body
    assert "AssumptionPayloadKind.known_trivial_fiber().code" in body
    assert "ImportStrengthClass.classical_class_specific().code" in body
    assert "theorem_tag_admissible_for_final(self.record)" in body
    assert "theorem_tag_payload_admissible(self.payload)" in body


def test_wrong_target_type_source_and_payload_family_are_negative_controls():
    body = read(CLASSIFICATION)
    assert "not wrong_target.class_specific_trivial_fiber_accepted()" in body
    assert "not wrong_type.class_specific_trivial_fiber_accepted()" in body
    assert "not wrong_source.class_specific_trivial_fiber_accepted()" in body
    assert "AssumptionPayloadKind.rational_ray_landing()" in body
    assert "not wrong_payload_kind.class_specific_trivial_fiber_accepted()" in body


def test_global_boundaries_remain_hard_false():
    body = read(CLASSIFICATION)
    assert "def proves_generic_mlc(self) -> Bool: return False" in body
    assert "def proves_all_fibers_trivial(self) -> Bool: return False" in body
    assert "def proves_residual_closure_no_missing_links(self) -> Bool: return False" in body
    assert "def proves_c1(self) -> Bool: return False" in body


def test_payload_instance_consumes_classification_without_proof_grade_localization():
    tags = read(TAGS)
    block = tags[tags.index("struct MisiurewiczTrivialFiberInstance"):tags.index("def schleicher_rational_parameter_ray_source")]
    final = block[block.index("def final_import_admissible"):]
    assert "ProofGradeMisiurewiczTrivialFiberClassification" in block
    assert "class_specific_trivial_fiber_accepted()" in final
    assert "proof_grade_accepted()" not in final


def test_complete_certificate_stays_closed_at_the_bigq_gate():
    gate = read(GATE)
    assert "return self.finite_inputs_accepted() and self.theorem_tags_accepted()" in gate
    assert "status.finite_inputs_accepted()" in gate
    assert "not status.theorem_tags_accepted() and not status.certificate_accepted()" in gate
    assert "def proves_c1(self) -> Bool:\n        return False" in gate


def test_classification_is_compiler_wired(mojo_smoke):
    smoke = read(SMOKE)
    assert "from certificates.c_minus_2.proof_grade_misiurewicz_trivial_fiber_classification import proof_grade_misiurewicz_trivial_fiber_classification_smoke" in smoke
    assert 'report.record("proof-grade Misiurewicz trivial-fiber classification"' in smoke
    assert mojo_smoke.case_passed("proof-grade Misiurewicz trivial-fiber classification")
