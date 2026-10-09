# Proof-grade landing-target association for the c=-2 theorem-tag path.
# Specification: docs/rational-interval-arithmetic-spec.md (sections 1, 5, 6.2).
#
# This module upgrades only the finite association
#
#     rational address 1/2  ->  exact critical-orbit type (2,1)  ->  c = -2
#
# to the BigZ/normalized-Q proof path.  The analytic ray-landing statement is
# still an explicit imported theorem premise.  No bounded localization, float,
# generic MLC claim, fiber-triviality claim, or residual-closure claim is used.

from finite_exact.bigint_z import BigZ, bigz_add, bigz_eq, bigz_from_i64, bigz_mul, bigz_sub
from finite_exact.rat_q import Q
from dynamics.bigq_ray_address import BigQRayOrbitStatus, verify_bigq_one_half_orbit
from c1.theorem_tags.theorem_tag_import_ledger import ImportConclusionKind, ImportStrengthClass, TheoremTagRecord, rational_parameter_ray_landing_c_minus_2_tag_checked, theorem_tag_admissible_for_final
from c1.theorem_tags.theorem_tag_assumption_payloads import AssumptionPayloadKind, PayloadConclusionKind, PayloadStrengthClass, TheoremTagPayload, rational_parameter_ray_landing_payload_scaffold, theorem_tag_payload_admissible


struct BigZPoly2(Copyable):
    var c0: BigZ
    var c1: BigZ
    var c2: BigZ

    def __init__(out self, c0: BigZ, c1: BigZ, c2: BigZ):
        self.c0 = c0.copy()
        self.c1 = c1.copy()
        self.c2 = c2.copy()


struct BigZPoly4(Copyable):
    var c0: BigZ
    var c1: BigZ
    var c2: BigZ
    var c3: BigZ
    var c4: BigZ

    def __init__(out self, c0: BigZ, c1: BigZ, c2: BigZ, c3: BigZ, c4: BigZ):
        self.c0 = c0.copy()
        self.c1 = c1.copy()
        self.c2 = c2.copy()
        self.c3 = c3.copy()
        self.c4 = c4.copy()


def bigz_poly4_equal(a: BigZPoly4, b: BigZPoly4) -> Bool:
    return (
        bigz_eq(a.c0, b.c0) and bigz_eq(a.c1, b.c1) and
        bigz_eq(a.c2, b.c2) and bigz_eq(a.c3, b.c3) and
        bigz_eq(a.c4, b.c4)
    )


def square_bigz_poly2(p: BigZPoly2) -> BigZPoly4:
    var two = bigz_from_i64(2)
    return BigZPoly4(
        bigz_mul(p.c0, p.c0),
        bigz_mul(two, bigz_mul(p.c0, p.c1)),
        bigz_add(
            bigz_mul(p.c1, p.c1),
            bigz_mul(two, bigz_mul(p.c0, p.c2)),
        ),
        bigz_mul(two, bigz_mul(p.c1, p.c2)),
        bigz_mul(p.c2, p.c2),
    )


def q2_from_critical_orbit_recurrence() -> BigZPoly2:
    # Q_0 = 0, Q_1 = C, Q_2 = Q_1^2 + C = C^2 + C.
    return BigZPoly2(bigz_from_i64(0), bigz_from_i64(1), bigz_from_i64(1))


def q3_from_critical_orbit_recurrence() -> BigZPoly4:
    # Q_3 = Q_2^2 + C.
    var q2 = q2_from_critical_orbit_recurrence()
    var squared = square_bigz_poly2(q2)
    return BigZPoly4(
        squared.c0,
        bigz_add(squared.c1, bigz_from_i64(1)),
        squared.c2,
        squared.c3,
        squared.c4,
    )


def raw_r21_from_critical_orbit_recurrence() -> BigZPoly4:
    # R_{2,1} = Q_3 - Q_2.
    var q2 = q2_from_critical_orbit_recurrence()
    var q3 = q3_from_critical_orbit_recurrence()
    return BigZPoly4(
        bigz_sub(q3.c0, q2.c0),
        bigz_sub(q3.c1, q2.c1),
        bigz_sub(q3.c2, q2.c2),
        q3.c3,
        q3.c4,
    )


def factorized_r21_cubed_c_plus_two() -> BigZPoly4:
    # C^3(C+2) = 2 C^3 + C^4.
    return BigZPoly4(
        bigz_from_i64(0),
        bigz_from_i64(0),
        bigz_from_i64(0),
        bigz_from_i64(2),
        bigz_from_i64(1),
    )


def proof_grade_r21_factorization_verified() -> Bool:
    var raw = raw_r21_from_critical_orbit_recurrence()
    var factorized = factorized_r21_cubed_c_plus_two()
    return (
        bigz_poly4_equal(raw, factorized) and
        bigz_eq(raw.c0, bigz_from_i64(0)) and
        bigz_eq(raw.c1, bigz_from_i64(0)) and
        bigz_eq(raw.c2, bigz_from_i64(0)) and
        bigz_eq(raw.c3, bigz_from_i64(2)) and
        bigz_eq(raw.c4, bigz_from_i64(1))
    )


def exact_critical_orbit_type_2_1(c: Q) -> Bool:
    if not c.accepted():
        return False
    var q0 = Q.zero()
    var q1 = q0.square().add(c)
    var q2 = q1.square().add(c)
    var q3 = q2.square().add(c)
    return (
        q0.accepted() and q1.accepted() and q2.accepted() and q3.accepted() and
        not q0.eq(q1) and not q0.eq(q2) and not q1.eq(q2) and
        q3.eq(q2)
    )


def zero_is_lower_type_for_r21() -> Bool:
    var c = Q.zero()
    var q0 = Q.zero()
    var q1 = q0.square().add(c)
    return q0.eq(q1)


struct P21ExactTargetWitness(Copyable):
    var target: Q
    var factorization_verified: Bool
    var zero_lower_type_verified: Bool

    def __init__(out self, target: Q, factorization_verified: Bool, zero_lower_type_verified: Bool):
        self.target = target.copy()
        self.factorization_verified = factorization_verified
        self.zero_lower_type_verified = zero_lower_type_verified

    def complete_factorization_identifies_target(self) -> Bool:
        # The exact factorization R_{2,1}=C^3(C+2) has only the candidate roots
        # C=0 and C=-2.  C=0 is rejected as lower type; the remaining linear
        # factor is C+2.
        return (
            self.factorization_verified and self.zero_lower_type_verified and
            self.target.eq(Q(-2, 1)) and
            exact_critical_orbit_type_2_1(self.target)
        )


def verify_c_minus_2_exact_target() -> P21ExactTargetWitness:
    return P21ExactTargetWitness(
        Q(-2, 1),
        proof_grade_r21_factorization_verified(),
        zero_is_lower_type_for_r21(),
    )


struct RationalLandingTheoremImportWitness(ImplicitlyCopyable):
    var record: TheoremTagRecord
    var payload: TheoremTagPayload
    var citation_key: String
    var source_title: String
    var covered_class: String
    var critical_orbit_preperiod_offset: Int
    var period_preserved: Bool
    var covers_strictly_preperiodic_addresses: Bool

    def __init__(
        out self,
        record: TheoremTagRecord,
        payload: TheoremTagPayload,
        citation_key: String,
        source_title: String,
        covered_class: String,
        critical_orbit_preperiod_offset: Int,
        period_preserved: Bool,
        covers_strictly_preperiodic_addresses: Bool,
    ):
        self.record = record
        self.payload = payload
        self.citation_key = citation_key
        self.source_title = source_title
        self.covered_class = covered_class
        self.critical_orbit_preperiod_offset = critical_orbit_preperiod_offset
        self.period_preserved = period_preserved
        self.covers_strictly_preperiodic_addresses = covers_strictly_preperiodic_addresses

    def accepted(self) -> Bool:
        return (
            self.citation_key == "SchleicherRationalParameterRays" and
            self.source_title == "Rational Parameter Rays of the Mandelbrot Set" and
            self.covered_class == "preperiodic rational parameter rays" and
            self.record.name == "RationalParameterRayLanding" and
            self.record.conclusion_kind.code == ImportConclusionKind.rational_ray_landing().code and
            self.record.strength_class.code == ImportStrengthClass.classical_local().code and
            self.payload.tag_name == self.record.name and
            self.payload.payload_kind.code == AssumptionPayloadKind.rational_ray_landing().code and
            self.payload.conclusion_kind.code == PayloadConclusionKind.ray_landing().code and
            self.payload.strength_class.code == PayloadStrengthClass.local_landing().code and
            self.critical_orbit_preperiod_offset == 1 and self.period_preserved and
            self.covers_strictly_preperiodic_addresses and
            theorem_tag_admissible_for_final(self.record) and
            theorem_tag_payload_admissible(self.payload)
        )


def checked_rational_landing_theorem_import() -> RationalLandingTheoremImportWitness:
    var record = rational_parameter_ray_landing_c_minus_2_tag_checked()
    return RationalLandingTheoremImportWitness(
        record,
        rational_parameter_ray_landing_payload_scaffold(),
        "SchleicherRationalParameterRays",
        "Rational Parameter Rays of the Mandelbrot Set",
        "preperiodic rational parameter rays",
        1,
        True,
        True,
    )


struct ProofGradeLandingTargetAssociation(ImplicitlyCopyable):
    var theorem_import: RationalLandingTheoremImportWitness
    var ray_replay_accepted: Bool
    var ray_preperiod: Int
    var ray_period: Int
    var target_num: Int64
    var target_den: Int64
    var factorization_verified: Bool
    var zero_lower_type_verified: Bool
    var target_exact_type_verified: Bool
    var ell: Int
    var period: Int

    def __init__(
        out self,
        theorem_import: RationalLandingTheoremImportWitness,
        ray_replay_accepted: Bool,
        ray_preperiod: Int,
        ray_period: Int,
        target_num: Int64,
        target_den: Int64,
        factorization_verified: Bool,
        zero_lower_type_verified: Bool,
        target_exact_type_verified: Bool,
        ell: Int,
        period: Int,
    ):
        self.theorem_import = theorem_import
        self.ray_replay_accepted = ray_replay_accepted
        self.ray_preperiod = ray_preperiod
        self.ray_period = ray_period
        self.target_num = target_num
        self.target_den = target_den
        self.factorization_verified = factorization_verified
        self.zero_lower_type_verified = zero_lower_type_verified
        self.target_exact_type_verified = target_exact_type_verified
        self.ell = ell
        self.period = period

    def proof_grade_associated(self) -> Bool:
        return (
            self.theorem_import.accepted() and
            self.ray_replay_accepted and
            self.ray_preperiod + self.theorem_import.critical_orbit_preperiod_offset == self.ell and
            self.ray_period == self.period and
            self.ell == 2 and self.period == 1 and
            self.target_num == -2 and self.target_den == 1 and
            self.factorization_verified and self.zero_lower_type_verified and
            self.target_exact_type_verified
        )

    def proves_fiber_triviality(self) -> Bool:
        return False

    def proves_c1(self) -> Bool:
        return False

    def proves_residual_closure_no_missing_links(self) -> Bool:
        return False


def verify_proof_grade_c_minus_2_landing_target_association() -> ProofGradeLandingTargetAssociation:
    # Use a representation of 1/2 whose unreduced numerator is already beyond
    # Int64 to exercise the unbounded BigZ/Q path before normalization.
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    var rays = verify_bigq_one_half_orbit(
        beyond_i64,
        bigz_mul(beyond_i64, bigz_from_i64(2)),
    )
    var target = verify_c_minus_2_exact_target()
    return ProofGradeLandingTargetAssociation(
        checked_rational_landing_theorem_import(),
        rays.arithmetic_replay_accepted(),
        rays.preperiod,
        rays.period,
        -2,
        1,
        target.factorization_verified,
        target.zero_lower_type_verified,
        target.complete_factorization_identifies_target(),
        2,
        1,
    )


def proof_grade_landing_target_association_smoke() -> Bool:
    var association = verify_proof_grade_c_minus_2_landing_target_association()
    var wrong_target = ProofGradeLandingTargetAssociation(
        association.theorem_import,
        association.ray_replay_accepted,
        association.ray_preperiod,
        association.ray_period,
        -1,
        1,
        association.factorization_verified,
        association.zero_lower_type_verified,
        association.target_exact_type_verified,
        2,
        1,
    )
    var wrong_import = RationalLandingTheoremImportWitness(
        association.theorem_import.record,
        association.theorem_import.payload,
        "WrongSource",
        association.theorem_import.source_title,
        association.theorem_import.covered_class,
        1,
        True,
        True,
    )
    var wrong_source = ProofGradeLandingTargetAssociation(
        wrong_import,
        association.ray_replay_accepted,
        association.ray_preperiod,
        association.ray_period,
        association.target_num,
        association.target_den,
        association.factorization_verified,
        association.zero_lower_type_verified,
        association.target_exact_type_verified,
        2,
        1,
    )
    var wrong_payload = TheoremTagPayload(
        "RationalParameterRayLanding",
        AssumptionPayloadKind.fiber_definition(),
        PayloadConclusionKind.ray_landing(),
        PayloadStrengthClass.local_landing(),
        True,
        True,
        True,
        True,
        True,
        False,
        False,
    )
    var wrong_payload_import = RationalLandingTheoremImportWitness(
        association.theorem_import.record,
        wrong_payload,
        association.theorem_import.citation_key,
        association.theorem_import.source_title,
        association.theorem_import.covered_class,
        1,
        True,
        True,
    )
    var wrong_payload_kind = ProofGradeLandingTargetAssociation(
        wrong_payload_import,
        association.ray_replay_accepted,
        association.ray_preperiod,
        association.ray_period,
        association.target_num,
        association.target_den,
        association.factorization_verified,
        association.zero_lower_type_verified,
        association.target_exact_type_verified,
        2,
        1,
    )
    return (
        association.proof_grade_associated() and
        not wrong_target.proof_grade_associated() and
        not wrong_source.proof_grade_associated() and
        not wrong_payload_kind.proof_grade_associated() and
        not association.proves_fiber_triviality() and
        not association.proves_c1() and
        not association.proves_residual_closure_no_missing_links()
    )

