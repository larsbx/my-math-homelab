from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSOC = ROOT / "kernel/mojo/certificates/c_minus_2/proof_grade_landing_target_association.mojo"
TAGS = ROOT / "kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo"
SMOKE = ROOT / "kernel/mojo/smoke/smoke_tests.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_association_uses_bigz_q_not_checked_width_localization():
    body = read(ASSOC)
    assert "from finite_exact.bigint_z import" in body
    assert "from finite_exact.rat_q import Q" in body
    assert "verify_bigq_one_half_orbit" in body
    assert "CheckedLocalizationEnvelope" not in body
    assert "Krawczyk" not in body
    assert "checked_width" not in body


def test_raw_r21_factorization_is_replayed_from_the_critical_orbit_recurrence():
    body = read(ASSOC)
    assert "def q2_from_critical_orbit_recurrence()" in body
    assert "def q3_from_critical_orbit_recurrence()" in body
    assert "def raw_r21_from_critical_orbit_recurrence()" in body
    assert "def factorized_r21_cubed_c_plus_two()" in body
    assert "bigz_poly4_equal(raw, factorized)" in body
    assert "bigz_eq(raw.c3, bigz_from_i64(2))" in body
    assert "bigz_eq(raw.c4, bigz_from_i64(1))" in body


def test_target_is_exact_type_2_1_and_zero_is_lower_type():
    body = read(ASSOC)
    assert "def exact_critical_orbit_type_2_1(c: Q) -> Bool" in body
    assert "not q0.eq(q1)" in body
    assert "not q0.eq(q2)" in body
    assert "not q1.eq(q2)" in body
    assert "q3.eq(q2)" in body
    assert "def zero_is_lower_type_for_r21() -> Bool" in body
    assert "self.target.eq(Q(-2, 1))" in body


def test_external_landing_theorem_is_an_explicit_checked_import():
    body = read(ASSOC)
    assert "struct RationalLandingTheoremImportWitness" in body
    assert '"SchleicherRationalParameterRays"' in body
    assert '"preperiodic rational parameter rays"' in body
    assert "rational_parameter_ray_landing_c_minus_2_tag_checked" in body
    assert "var record = TheoremTagRecord(" not in body
    assert "theorem_tag_admissible_for_final(self.record)" in body
    assert "self.payload.payload_kind.code == AssumptionPayloadKind.rational_ray_landing().code" in body
    assert "theorem_tag_payload_admissible(self.payload)" in body
    assert "self.critical_orbit_preperiod_offset == 1" in body
    assert "self.period_preserved" in body


def test_proof_grade_association_has_wrong_source_and_wrong_target_negative_controls():
    body = read(ASSOC)
    assert "self.target_num == -2 and self.target_den == 1" in body
    assert "        -1,\n        1," in body
    assert '"WrongSource"' in body
    assert "not wrong_target.proof_grade_associated()" in body
    assert "var rays: BigQRayOrbitStatus" not in body
    assert "var target: P21ExactTargetWitness" not in body
    assert "not wrong_source.proof_grade_associated()" in body
    assert "AssumptionPayloadKind.fiber_definition()" in body
    assert "not wrong_payload_kind.proof_grade_associated()" in body


def test_association_does_not_promote_fiber_c1_or_residual_closure():
    body = read(ASSOC)
    assert "def proves_fiber_triviality(self) -> Bool:\n        return False" in body
    assert "def proves_c1(self) -> Bool:\n        return False" in body
    assert "def proves_residual_closure_no_missing_links(self) -> Bool:\n        return False" in body


def test_c1_landing_payload_uses_proof_grade_association_and_names_successor():
    tags = read(TAGS)
    assert "var proof_grade_landing_target_association: ProofGradeLandingTargetAssociation" in tags
    assert "verify_proof_grade_c_minus_2_landing_target_association()" in tags
    assert "def source_metadata_checked(self) -> Bool" in tags
    assert "self.proof_grade_landing_target_association.proof_grade_associated()" in tags
    final_block = tags[tags.index("def final_import_admissible(self) -> Bool"):tags.index("struct MisiurewiczTrivialFiberInstance")]
    assert "self.source_metadata_checked()" in final_block
    assert "self.source_scope_checked()" not in final_block
    assert "rational_landing_payload_proof_grade_association_ready()" in tags
    assert "landing.final_import_admissible()" in tags
    assert "fiber.final_import_admissible()" in tags
    assert 'return "CanonicalFiniteCertificateIncidenceReplay"' in tags


def test_proof_grade_association_is_compiler_wired(mojo_smoke):
    smoke = read(SMOKE)
    assert "from certificates.c_minus_2.proof_grade_landing_target_association import proof_grade_landing_target_association_smoke" in smoke
    assert 'report.record("proof-grade landing target association"' in smoke
    assert mojo_smoke.case_passed("proof-grade landing target association")
