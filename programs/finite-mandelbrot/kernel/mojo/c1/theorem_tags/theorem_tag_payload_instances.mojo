# Source-specific theorem-tag payload instances for the c=-2 path.
#
# The finite checks below verify source scope and instance data against the
# BigZ/Q replay (`bigq_landing_target_adapter`: Krawczyk localization, the five
# forbidden-collision exclusions on the same box, and the 1/2 ray-address
# orbit). Final import remains fail-closed when parameter association or
# proof-grade classification is absent. No analytic theorem is reproved here.

from finite_exact.bigint_z import bigz_add, bigz_from_i64, bigz_mul
from dynamics.bigq_ray_address import BigQRayOrbitStatus, verify_bigq_one_half_orbit
from certificates.c_minus_2.bigq_landing_target_adapter import BigQLandingTargetAssociation, verify_bigq_c_minus_2_landing_target_association
from certificates.c_minus_2.proof_grade_landing_target_association import ProofGradeLandingTargetAssociation, verify_proof_grade_c_minus_2_landing_target_association
from certificates.c_minus_2.proof_grade_misiurewicz_trivial_fiber_classification import ProofGradeMisiurewiczTrivialFiberClassification, verify_c_minus_2_misiurewicz_trivial_fiber_classification


struct TheoremSourceRef(ImplicitlyCopyable):
    var citation_key: String
    var source_title: String
    var covered_class: String

    def __init__(out self, citation_key: String, source_title: String, covered_class: String):
        self.citation_key = citation_key
        self.source_title = source_title
        self.covered_class = covered_class

    def complete(self) -> Bool:
        return self.citation_key.byte_length() > 0 and self.source_title.byte_length() > 0 and self.covered_class.byte_length() > 0


struct RationalRayLandingInstance(Copyable):
    var source: TheoremSourceRef
    var rays: BigQRayOrbitStatus
    var address_num: Int64
    var address_den: Int64
    var landing_box_name: String
    var landing_target_association: BigQLandingTargetAssociation
    var proof_grade_landing_target_association: ProofGradeLandingTargetAssociation
    var excludes_generic_boundary_use: Bool

    def __init__(out self, source: TheoremSourceRef, rays: BigQRayOrbitStatus, address_num: Int64, address_den: Int64, landing_box_name: String, landing_target_association: BigQLandingTargetAssociation, proof_grade_landing_target_association: ProofGradeLandingTargetAssociation, excludes_generic_boundary_use: Bool):
        self.source = source
        self.rays = rays.copy()
        self.address_num = address_num
        self.address_den = address_den
        self.landing_box_name = landing_box_name
        self.landing_target_association = landing_target_association.copy()
        self.proof_grade_landing_target_association = proof_grade_landing_target_association
        self.excludes_generic_boundary_use = excludes_generic_boundary_use

    def source_metadata_checked(self) -> Bool:
        return (
            self.source.complete() and self.source.citation_key == "SchleicherRationalParameterRays" and
            self.source.covered_class == "preperiodic rational parameter rays" and
            self.address_num == 1 and self.address_den == 2 and
            self.landing_box_name == "beta_c_minus_2" and self.excludes_generic_boundary_use
        )

    def source_scope_checked(self) -> Bool:
        return (
            self.source_metadata_checked() and
            self.rays.arithmetic_replay_accepted() and self.rays.preperiod == 1 and self.rays.period == 1 and
            self.landing_target_association.finite_replay_associated()
        )

    def final_import_admissible(self) -> Bool:
        return (
            self.source_metadata_checked() and
            self.proof_grade_landing_target_association.proof_grade_associated()
        )


struct MisiurewiczTrivialFiberInstance(Copyable):
    var source: TheoremSourceRef
    var association: BigQLandingTargetAssociation
    var ell: Int
    var period: Int
    var proof_grade_classification: ProofGradeMisiurewiczTrivialFiberClassification
    var excludes_generic_boundary_use: Bool

    def __init__(out self, source: TheoremSourceRef, association: BigQLandingTargetAssociation, ell: Int, period: Int, proof_grade_classification: ProofGradeMisiurewiczTrivialFiberClassification, excludes_generic_boundary_use: Bool):
        self.source = source
        self.association = association.copy()
        self.ell = ell
        self.period = period
        self.proof_grade_classification = proof_grade_classification
        self.excludes_generic_boundary_use = excludes_generic_boundary_use

    def source_scope_checked(self) -> Bool:
        return (
            self.source.complete() and self.source.citation_key == "SchleicherFibersLC" and
            self.source.covered_class == "Misiurewicz parameters" and
            self.association.finite_replay_associated() and
            self.association.box_name == "beta_c_minus_2" and
            self.ell == 2 and self.period == 1 and self.excludes_generic_boundary_use
        )

    def final_import_admissible(self) -> Bool:
        return (
            self.source.complete() and
            self.source.citation_key == "SchleicherFibersLC" and
            self.source.covered_class == "Misiurewicz parameters" and
            self.ell == 2 and self.period == 1 and
            self.excludes_generic_boundary_use and
            self.proof_grade_classification.class_specific_trivial_fiber_accepted()
        )


def schleicher_rational_parameter_ray_source() -> TheoremSourceRef:
    return TheoremSourceRef(
        "SchleicherRationalParameterRays",
        "Rational Parameter Rays of the Mandelbrot Set",
        "preperiodic rational parameter rays",
    )


def schleicher_misiurewicz_fiber_source() -> TheoremSourceRef:
    return TheoremSourceRef(
        "SchleicherFibersLC",
        "On Fibers and Local Connectivity of Mandelbrot and Multibrot Sets",
        "Misiurewicz parameters",
    )


# The replayed box is `beta_c_minus_2` at half-width `2^-8`, the radius the
# retired checked-Int64 localization used; the BigZ replay reproduces its
# Krawczyk image and exclusion verdicts there exactly.
comptime C_MINUS_2_HALF_WIDTH_DEN_POWER = 8


def c_minus_2_landing_instance() -> RationalRayLandingInstance:
    # 1/2 with an unreduced numerator beyond Int64, as in the BigZ replays.
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    return RationalRayLandingInstance(
        schleicher_rational_parameter_ray_source(),
        verify_bigq_one_half_orbit(beyond_i64, bigz_mul(beyond_i64, bigz_from_i64(2))),
        1,
        2,
        "beta_c_minus_2",
        verify_bigq_c_minus_2_landing_target_association(C_MINUS_2_HALF_WIDTH_DEN_POWER),
        verify_proof_grade_c_minus_2_landing_target_association(),
        True,
    )


def c_minus_2_trivial_fiber_instance() -> MisiurewiczTrivialFiberInstance:
    return MisiurewiczTrivialFiberInstance(
        schleicher_misiurewicz_fiber_source(),
        verify_bigq_c_minus_2_landing_target_association(C_MINUS_2_HALF_WIDTH_DEN_POWER),
        2,
        1,
        verify_c_minus_2_misiurewicz_trivial_fiber_classification(),
        True,
    )


def rational_landing_payload_source_checks_ready() -> Bool:
    var landing = c_minus_2_landing_instance()
    return landing.source_scope_checked()


def rational_landing_payload_proof_grade_association_ready() -> Bool:
    var landing = c_minus_2_landing_instance()
    return landing.source_scope_checked() and landing.final_import_admissible()


def misiurewicz_trivial_fiber_payload_source_checks_ready() -> Bool:
    var fiber = c_minus_2_trivial_fiber_instance()
    return fiber.source_scope_checked() and fiber.final_import_admissible()


def theorem_tag_payload_instances_smoke() -> Bool:
    return (
        rational_landing_payload_source_checks_ready() and
        rational_landing_payload_proof_grade_association_ready() and
        misiurewicz_trivial_fiber_payload_source_checks_ready()
    )


def next_priority_after_proof_grade_landing_association() -> String:
    return "CanonicalFiniteCertificateIncidenceReplay"


def next_priority_after_payload_source_checks() -> String:
    return next_priority_after_proof_grade_landing_association()
