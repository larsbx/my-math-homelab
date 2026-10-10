# smoke_tests.mojo
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Smoke-test harness for the finite-regime Mandelbrot computation layer.
#
# These tests are intentionally narrow. They preserve the computations already
# used in the research notes while marking the gap between arithmetic smoke
# tests and a full proof-carrying validator.
#
# Each case is named after the contract it checks, and a name that is a
# governed term is used in the sense that term carries in
# docs/terminology-registry.md; naming a case asserts nothing beyond the
# verdict the case returned. Cases are independent and all of them run, so one
# failure does not hide the next: see vendor/mojo/mojo_smoke/report.mojo.

from polynomial.poly_z import smoke_poly_identities
from certificates.cert_types import MisCertHeader, JointBoxWitness, TheoremTags
from finite_exact.rat_q import Q, bigq_storage_smoke, demo_q_normalization, demo_q_order, q_cancellation_smoke
from finite_exact.closed_interval import IQ, ComplexIQ, demo_interval_mul, demo_complex_quadrance_point, bigq_interval_conformance_smoke
from polynomial.poly_interval_eval import eval_p21, demo_poly_interval_eval_status
from certificates.krawczyk_witness import verify_p21_krawczyk_c_minus_2, bigq_krawczyk_replay_smoke
from dynamics.interval_orbit import bigq_exact_type_exclusion_replay_smoke, invalid_orbit_config_rejection_smoke
from dynamics.bigq_ray_address import bigq_ray_address_replay_smoke
from certificates.c_minus_2.bigq_landing_target_adapter import bigq_landing_target_replay_smoke
from certificates.c_minus_2.proof_grade_landing_target_association import proof_grade_landing_target_association_smoke
from certificates.c_minus_2.proof_grade_misiurewicz_trivial_fiber_classification import proof_grade_misiurewicz_trivial_fiber_classification_smoke
from certificates.c_minus_2.bigq_theorem_tag_payload_instances import bigq_theorem_payload_replay_smoke
from certificates.c_minus_2.bigq_finite_certificate_gate import bigq_finite_certificate_gate_smoke
from certificates.c_minus_2.bigq_certificate_incidence import bigq_certificate_incidence_smoke
from c1.proof.final_proof_block_ledger import FinalEvidencePolicy, canonical_final_evidence_policy, final_evidence_policy_valid, final_ledger_ready_for_c1, current_priority_block, next_immediate_block
from c1.residual.residual_closure_no_missing_links import FinalExitKind, accepted_final_exit, rejected_final_exit
from c1.theorem_tags.theorem_tag_assumption_payloads import AssumptionPayloadKind, PayloadConclusionKind, PayloadStrengthClass, allowed_payload_kind, allowed_payload_conclusion, allowed_payload_strength, theorem_tag_payload_admissible, rational_parameter_ray_landing_payload_scaffold, fiber_definition_payload_scaffold, generic_mlc_payload_rejected, bounded_search_payload_rejected
from c1.theorem_tags.theorem_tag_import_ledger import ImportConclusionKind, ImportStrengthClass, ImportStatus, allowed_conclusion_kind, allowed_strength_class, forbidden_strength_class, rational_parameter_ray_landing_tag_ready, fiber_definition_equivalence_tag_ready, known_trivial_fiber_class_tag_ready, tuning_kneading_substitution_tag_ready, harmonic_measure_fibre_triviality_tag_ready, harmonic_measure_tag_discharges_a_named_pair, theorem_tag_admissible_for_final
from c1.residual.residual_directive_carrier import residual_directive_carrier_smoke
from c1.carrier.carrier_density_profile import carrier_density_profile_smoke
from c1.separator.separated_density import separated_density_smoke
from certificates.misiurewicz_catalogue import misiurewicz_catalogue_smoke
from c1.wake.misiurewicz_prefix_graph import misiurewicz_prefix_graph_smoke
from finite_exact.integer_gcd import gcd_int, gcd_i64, gcd_i64_or_one
from dynamics.ray_address import RayAddr, same_ray_addr, ray_addr_before
from rational_dynamics.rational import double_mod_one, fraction_equal, fraction_from_i64
from arithmetic.rational_trig import demo_spread_orthogonal_axes, demo_ray_addr_doubling_half
from theorem_kernel.alignment_audit_status import AlignmentPolicy, canonical_alignment_policy, alignment_policy_valid
from theorem_kernel.mojo_optimization_contract import OptimizationPolicy, canonical_optimization_policy, optimization_policy_valid
from c1.proof.final_proof_object_skeleton import C1FinalProofObject, FinalProofAcceptancePolicy, canonical_final_proof_acceptance_policy, final_proof_acceptance_policy_valid, accepts_c1_final_proof_object, rejects_missing_link_final_exit, skeleton_alone_proves_c1
from arithmetic.cert_backend import cert_backend_smoke
from c1.theorem_tags.theorem_tag_payload_instances import theorem_tag_payload_instances_smoke
from finite_exact.exact_decimal import exact_decimal_smoke
from finite_exact.bigint_z import bigint_z_phase_one_smoke, bigint_z_phase_two_smoke, bigint_z_phase_three_smoke, bigz_long_division_smoke
from arithmetic.bigint_adapter import bigint_adapter_phase_one_smoke, bigint_adapter_phase_two_smoke, bigint_adapter_complete_smoke
from arithmetic.rat_backend_plan import q_backend_migration_smoke
from mojo_smoke.report import SmokeReport, smoke_report_smoke
from dynamics.angle_tuning import angle_tuning_smoke
from dynamics.limb_streams import limb_streams_smoke
from dynamics.projective_multiset import projective_multiset_smoke
from dynamics.critical_relation_bridge import critical_relation_bridge_smoke
from dynamics.critical_type_census import critical_type_census_smoke
from dynamics.critical_type_sieve import critical_type_sieve_smoke
from dynamics.exact_type_irreducibility import exact_type_irreducibility_smoke
from dynamics.multiset_b3_localization import multiset_b3_localization_smoke
from dynamics.critical_relation_multiset import critical_relation_multiset_smoke
from dynamics.critical_relation_residual_multiset import critical_relation_residual_multiset_smoke
from dynamics.r41_algebraic_root_certificate import r41_algebraic_root_certificate_smoke


def test_rational_field_laws() -> Bool:
    # docs/rational-interval-arithmetic-spec.md section 1.3: decidable
    # equality, associativity, distributivity, lossless cancellation.
    var a = Q(1, 3)
    var b = Q(1, 7)
    var c = Q(-2, 9)
    return (
        Q(1, 10).add(Q(2, 10)).eq(Q(3, 10)) and
        a.add(b).add(c).eq(a.add(b.add(c))) and
        a.mul(b.add(c)).eq(a.mul(b).add(a.mul(c))) and
        a.add(b).sub(b).eq(a) and
        Q(1, 3).lt(Q(1, 2))
    )


def test_interval_enclosure_laws() -> Bool:
    # docs/rational-interval-arithmetic-spec.md sections 2.2 to 2.5: the
    # dependency problem, subdistributivity, and the tighter square.
    var x = IQ(Q(1, 1), Q(3, 1))
    var y = IQ(Q(-1, 1), Q(2, 1))
    var z = IQ(Q(2, 1), Q(5, 1))
    var d = x.sub(x)
    var lhs = x.mul(y.add(z))
    var rhs = x.mul(y).add(x.mul(z))
    return (
        d.lo.eq(Q(-2, 1)) and d.hi.eq(Q(2, 1)) and d.contains_zero().value and
        lhs.subset_of(rhs).value and
        y.square().subset_of(y.mul(y)).value and not y.mul(y).subset_of(y.square()).value and
        x.excludes_zero().value and not y.excludes_zero().value
    )


def test_interval_polynomial_evaluation() -> Bool:
    var c_minus_2 = ComplexIQ.singleton(Q(-2, 1), Q.zero())
    var value = eval_p21(c_minus_2)
    var status = demo_poly_interval_eval_status()
    return (
        value.re.lo.eq(Q.zero()) and value.re.hi.eq(Q.zero()) and
        value.im.lo.eq(Q.zero()) and value.im.hi.eq(Q.zero()) and
        status.scaffold_accepted() and not status.certificate_ready()
    )


def test_final_proof_ledger_policy() -> Bool:
    var canonical = canonical_final_evidence_policy()
    var unsafe = FinalEvidencePolicy(True, False, False, False, False)
    return (
        final_evidence_policy_valid(canonical) and
        not final_evidence_policy_valid(unsafe) and
        not final_ledger_ready_for_c1() and
        current_priority_block() == "ResidualClosureNoMissingLinks" and
        next_immediate_block() == "TheoremTagPayloadInstances"
    )


def test_typed_final_exit_kinds() -> Bool:
    return (
        accepted_final_exit(FinalExitKind.finite_separation()) and
        accepted_final_exit(FinalExitKind.boundary_equality()) and
        accepted_final_exit(FinalExitKind.established_trivial_fiber()) and
        rejected_final_exit(FinalExitKind.missing_theorem_catalogue_link()) and
        rejected_final_exit(FinalExitKind.open_analytic_assumption()) and
        rejected_final_exit(FinalExitKind.bounded_search_failure()) and
        rejected_final_exit(FinalExitKind.label_equality_only()) and
        not accepted_final_exit(FinalExitKind(99))
    )


def test_typed_theorem_payload_kinds() -> Bool:
    return (
        allowed_payload_kind(AssumptionPayloadKind.rational_ray_landing()) and
        allowed_payload_conclusion(PayloadConclusionKind.ray_landing()) and
        allowed_payload_strength(PayloadStrengthClass.adapter_only()) and
        allowed_payload_strength(PayloadStrengthClass.local_landing()) and
        allowed_payload_strength(PayloadStrengthClass.class_specific_fiber_triviality()) and
        allowed_payload_strength(PayloadStrengthClass.class_specific_local_connectivity()) and
        not allowed_payload_kind(AssumptionPayloadKind(99)) and
        not allowed_payload_conclusion(PayloadConclusionKind(99)) and
        not allowed_payload_strength(PayloadStrengthClass(99)) and
        theorem_tag_payload_admissible(rational_parameter_ray_landing_payload_scaffold()) and
        theorem_tag_payload_admissible(fiber_definition_payload_scaffold()) and
        generic_mlc_payload_rejected() and
        bounded_search_payload_rejected()
    )


def test_typed_theorem_import_kinds() -> Bool:
    return (
        allowed_conclusion_kind(ImportConclusionKind.rational_ray_landing()) and
        allowed_strength_class(ImportStrengthClass.finite_only()) and
        forbidden_strength_class(ImportStrengthClass.global_mlc()) and
        not allowed_conclusion_kind(ImportConclusionKind(99)) and
        not allowed_strength_class(ImportStrengthClass(99)) and
        not theorem_tag_admissible_for_final(rational_parameter_ray_landing_tag_ready()) and
        not theorem_tag_admissible_for_final(fiber_definition_equivalence_tag_ready()) and
        not theorem_tag_admissible_for_final(known_trivial_fiber_class_tag_ready()) and
        allowed_conclusion_kind(ImportConclusionKind.tuning_kneading_substitution()) and
        not theorem_tag_admissible_for_final(tuning_kneading_substitution_tag_ready()) and
        allowed_conclusion_kind(ImportConclusionKind.harmonic_measure_fibre_triviality()) and
        not theorem_tag_admissible_for_final(harmonic_measure_fibre_triviality_tag_ready()) and
        not harmonic_measure_tag_discharges_a_named_pair() and
        ImportStatus.checked().code != ImportStatus.scaffolded().code
    )


def test_canonical_gcd_helpers() raises -> Bool:
    return (
        gcd_int(-54, 24) == 6 and
        gcd_int(0, 0) == 0 and
        gcd_i64(-54, 24) == 6 and
        gcd_i64(0, 0) == 0 and
        gcd_i64_or_one(0, 0) == 1
    )


def test_canonical_ray_addresses() -> Bool:
    var one_third = RayAddr(1, 3)
    var one_half = RayAddr(1, 2)
    return (
        one_third.normalized() and
        not RayAddr(2, 4).normalized() and
        fraction_equal(double_mod_one(fraction_from_i64(1, 3)), fraction_from_i64(2, 3)) and
        ray_addr_before(one_half, one_third) and
        same_ray_addr(one_third, RayAddr(1, 3)) and
        fraction_equal(double_mod_one(fraction_from_i64(1, 2)), fraction_from_i64(0, 1))
    )


def test_canonical_rational_geometry() -> Bool:
    var spread_value = demo_spread_orthogonal_axes()
    var doubled_half = demo_ray_addr_doubling_half()
    return (
        spread_value.eq(Q.one()) and
        fraction_equal(doubled_half, fraction_from_i64(0, 1))
    )


def test_alignment_policy_data() -> Bool:
    var canonical = canonical_alignment_policy()
    var unsafe = AlignmentPolicy(True, True, True, True, False, False, False, True, True)
    return alignment_policy_valid(canonical) and not alignment_policy_valid(unsafe)


def test_optimization_policy_data() -> Bool:
    var canonical = canonical_optimization_policy()
    var unsafe = OptimizationPolicy("Mojo", "Mojo", True, False, False, True, True, True, True, True)
    return optimization_policy_valid(canonical) and not optimization_policy_valid(unsafe)


def test_final_proof_object_policy_data() -> Bool:
    var policy = canonical_final_proof_acceptance_policy()
    var unsafe_policy = FinalProofAcceptancePolicy(False, True, True, True, True, False, False)
    var complete = C1FinalProofObject(True, True, True, True, True, True, True, True, True, True, True, True, True)
    var missing_link = C1FinalProofObject(True, True, True, True, True, True, True, True, False, True, True, True, True)
    return (
        final_proof_acceptance_policy_valid(policy) and
        not final_proof_acceptance_policy_valid(unsafe_policy) and
        accepts_c1_final_proof_object(complete) and
        not accepts_c1_final_proof_object(missing_link) and
        rejects_missing_link_final_exit(policy) and
        not skeleton_alone_proves_c1(policy)
    )


def test_headers() -> Bool:
    # c = -2: critical type (ell,k)=(2,1), ray-address preperiod lambda=1, ray period n=1.
    var c_minus_2 = MisCertHeader(2, 1, 3, 1)
    if not c_minus_2.header_ok():
        return False

    # M_{4,1}: critical type (ell,k)=(4,1), horizon H=6, ray period n=3.
    # This checks the corrected distinction: ray period n can exceed orbit period k.
    var m41 = MisCertHeader(4, 1, 6, 3)
    if not m41.header_ok():
        return False

    return True


def test_joint_box_gate() -> Bool:
    # The gate must reject unless the same beta supports both localization and
    # forbidden-collision exclusion.
    var ok = JointBoxWitness(True, True, True)
    if not ok.accepts():
        return False

    var no_exclusion = JointBoxWitness(True, False, True)
    if no_exclusion.accepts():
        return False

    var wrong_box = JointBoxWitness(True, True, False)
    if wrong_box.accepts():
        return False

    return True


def test_theorem_tags() -> Bool:
    var ok = TheoremTags(True, True)
    if not ok.accepts():
        return False

    var missing_fiber = TheoremTags(True, False)
    if missing_fiber.accepts():
        return False

    return True


def run_smoke_tests() raises -> Bool:
    """Run every case, naming each one. Cases are independent, so the
    suite does not stop at the first failure: one run names every broken
    contract instead of only the earliest."""
    var report = SmokeReport()
    _ = report.record("bigq storage", bigq_storage_smoke())
    _ = report.record("Q backend migration", q_backend_migration_smoke())
    _ = report.record("polynomial identities", smoke_poly_identities())
    _ = report.record("certificate headers", test_headers())
    _ = report.record("joint box gate", test_joint_box_gate())
    _ = report.record("theorem tags", test_theorem_tags())
    _ = report.record("Q normalization", demo_q_normalization())
    _ = report.record("Q order", demo_q_order())
    _ = report.record("interval multiplication", demo_interval_mul())
    _ = report.record("complex quadrance point", demo_complex_quadrance_point())
    _ = report.record("bigq interval conformance", bigq_interval_conformance_smoke())
    _ = report.record("rational field laws", test_rational_field_laws())
    _ = report.record("interval enclosure laws", test_interval_enclosure_laws())
    _ = report.record("interval polynomial evaluation", test_interval_polynomial_evaluation())
    _ = report.record("Krawczyk witness at c = -2", verify_p21_krawczyk_c_minus_2(8))
    _ = report.record("bigq Krawczyk replay", bigq_krawczyk_replay_smoke())
    _ = report.record("bigq exact-type exclusion replay", bigq_exact_type_exclusion_replay_smoke())
    _ = report.record("invalid orbit config rejection", invalid_orbit_config_rejection_smoke())
    _ = report.record("bigq ray address replay", bigq_ray_address_replay_smoke())
    _ = report.record("bigq landing target replay", bigq_landing_target_replay_smoke())
    _ = report.record("proof-grade landing target association", proof_grade_landing_target_association_smoke())
    _ = report.record("proof-grade Misiurewicz trivial-fiber classification", proof_grade_misiurewicz_trivial_fiber_classification_smoke())
    _ = report.record("bigq theorem payload replay", bigq_theorem_payload_replay_smoke())
    _ = report.record("bigq finite certificate gate", bigq_finite_certificate_gate_smoke())
    _ = report.record("bigq certificate incidence", bigq_certificate_incidence_smoke())
    _ = report.record("final proof ledger policy", test_final_proof_ledger_policy())
    _ = report.record("typed final exit kinds", test_typed_final_exit_kinds())
    _ = report.record("typed theorem payload kinds", test_typed_theorem_payload_kinds())
    _ = report.record("typed theorem import kinds", test_typed_theorem_import_kinds())
    _ = report.record("canonical gcd helpers", test_canonical_gcd_helpers())
    _ = report.record("canonical ray addresses", test_canonical_ray_addresses())
    _ = report.record("canonical rational geometry", test_canonical_rational_geometry())
    _ = report.record("alignment policy data", test_alignment_policy_data())
    _ = report.record("optimization policy data", test_optimization_policy_data())
    _ = report.record("final proof object policy data", test_final_proof_object_policy_data())
    _ = report.record("certificate backend", cert_backend_smoke())
    _ = report.record("theorem tag payload instances", theorem_tag_payload_instances_smoke())
    _ = report.record("residual directive carrier", residual_directive_carrier_smoke())
    _ = report.record("exact angle tuning", angle_tuning_smoke())
    _ = report.record("limb streams by rotation number", limb_streams_smoke())
    _ = report.record("separated density", separated_density_smoke())
    _ = report.record("carrier density profile", carrier_density_profile_smoke())
    _ = report.record("Misiurewicz exact-type catalogue", misiurewicz_catalogue_smoke())
    _ = report.record("Misiurewicz prefix graph", misiurewicz_prefix_graph_smoke())
    _ = report.record("bigint Z phase one", bigint_z_phase_one_smoke())
    _ = report.record("bigint adapter phase one", bigint_adapter_phase_one_smoke())
    _ = report.record("bigint Z phase two", bigint_z_phase_two_smoke())
    _ = report.record("bigint adapter phase two", bigint_adapter_phase_two_smoke())
    _ = report.record("bigint Z phase three", bigint_z_phase_three_smoke())
    _ = report.record("bigint adapter complete", bigint_adapter_complete_smoke())
    _ = report.record("exact decimal", exact_decimal_smoke())
    _ = report.record("bigz long division", bigz_long_division_smoke())
    _ = report.record("Q cancellation", q_cancellation_smoke())
    _ = report.record("smoke reporter", smoke_report_smoke())
    _ = report.record("projective multiset", projective_multiset_smoke())
    _ = report.record("critical-relation bridge", critical_relation_bridge_smoke())
    _ = report.record("critical type census", critical_type_census_smoke())
    _ = report.record("critical type sieve", critical_type_sieve_smoke())
    _ = report.record("exact-type irreducibility", exact_type_irreducibility_smoke())
    _ = report.record("multiset B3 localization", multiset_b3_localization_smoke())
    _ = report.record("critical-relation divisor multiset", critical_relation_multiset_smoke())
    _ = report.record("R41 residual divisor multiset", critical_relation_residual_multiset_smoke())
    _ = report.record("R41 algebraic roots", r41_algebraic_root_certificate_smoke())
    report.print_summary("finite-regime Mandelbrot smoke suite")
    return report.all_passed()

def require_smoke_success(ok: Bool) raises:
    if not ok:
        raise Error("finite-regime Mandelbrot smoke tests: FAIL")


def main() raises:
    require_smoke_success(run_smoke_tests())
    print("finite-regime Mandelbrot smoke tests: PASS")
