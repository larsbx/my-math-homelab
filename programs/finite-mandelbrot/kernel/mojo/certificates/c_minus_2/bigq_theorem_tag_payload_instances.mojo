# Source-specific theorem payload records for the BigZ/Q c=-2 replay.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Finite source-scope matching is executable. Attaching and accepting the
# cited classical classifications is a separate, deliberately absent step.

from finite_exact.bigint_z import bigz_add, bigz_from_i64, bigz_mul
from finite_exact.rat_q import Q, q_from_bigz
from certificates.c_minus_2.bigq_landing_target_adapter import BigQLandingTargetAssociation, verify_bigq_c_minus_2_landing_target_association


struct BigQTheoremSourceRef(Copyable):
    var citation_key: String
    var source_title: String
    var covered_class: String

    def __init__(out self, citation_key: String, source_title: String, covered_class: String):
        self.citation_key = citation_key
        self.source_title = source_title
        self.covered_class = covered_class

    def complete(self) -> Bool:
        return (
            self.citation_key.byte_length() > 0 and self.source_title.byte_length() > 0 and
            self.covered_class.byte_length() > 0
        )


struct BigQRationalRayLandingInstance(Copyable):
    var source: BigQTheoremSourceRef
    var address: Q
    var association: BigQLandingTargetAssociation
    var excludes_generic_boundary_use: Bool
    var classification_proof_attached: Bool

    def __init__(out self, source: BigQTheoremSourceRef, address: Q, association: BigQLandingTargetAssociation, excludes_generic_boundary_use: Bool, classification_proof_attached: Bool):
        self.source = source.copy()
        self.address = address.copy()
        self.association = association.copy()
        self.excludes_generic_boundary_use = excludes_generic_boundary_use
        self.classification_proof_attached = classification_proof_attached

    def finite_source_scope_matched(self) -> Bool:
        return (
            self.source.complete() and self.source.citation_key == "SchleicherRationalParameterRays" and
            self.source.covered_class == "preperiodic rational parameter rays" and
            self.address.eq(Q(1, 2)) and self.excludes_generic_boundary_use and
            self.association.finite_replay_associated()
        )

    def final_import_admissible(self) -> Bool:
        return (
            self.finite_source_scope_matched() and self.classification_proof_attached and
            self.association.theorem_import_accepted()
        )


struct BigQMisiurewiczTrivialFiberInstance(Copyable):
    var source: BigQTheoremSourceRef
    var association: BigQLandingTargetAssociation
    var ell: Int
    var period: Int
    var excludes_generic_boundary_use: Bool
    var classification_proof_attached: Bool

    def __init__(out self, source: BigQTheoremSourceRef, association: BigQLandingTargetAssociation, ell: Int, period: Int, excludes_generic_boundary_use: Bool, classification_proof_attached: Bool):
        self.source = source.copy()
        self.association = association.copy()
        self.ell = ell
        self.period = period
        self.excludes_generic_boundary_use = excludes_generic_boundary_use
        self.classification_proof_attached = classification_proof_attached

    def finite_source_scope_matched(self) -> Bool:
        return (
            self.source.complete() and self.source.citation_key == "SchleicherFibersLC" and
            self.source.covered_class == "Misiurewicz parameters" and
            self.association.finite_replay_associated() and self.ell == 2 and self.period == 1 and
            self.excludes_generic_boundary_use
        )

    def final_import_admissible(self) -> Bool:
        return self.finite_source_scope_matched() and self.classification_proof_attached


def bigq_ray_landing_source() -> BigQTheoremSourceRef:
    return BigQTheoremSourceRef(
        "SchleicherRationalParameterRays",
        "Rational Parameter Rays of the Mandelbrot Set",
        "preperiodic rational parameter rays",
    )


def bigq_trivial_fiber_source() -> BigQTheoremSourceRef:
    return BigQTheoremSourceRef(
        "SchleicherFibersLC",
        "On Fibers and Local Connectivity of Mandelbrot and Multibrot Sets",
        "Misiurewicz parameters",
    )


def bigq_c_minus_2_landing_instance(half_width_den_power: Int) -> BigQRationalRayLandingInstance:
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    var address = q_from_bigz(beyond_i64, bigz_mul(beyond_i64, bigz_from_i64(2)))
    return BigQRationalRayLandingInstance(
        bigq_ray_landing_source(), address,
        verify_bigq_c_minus_2_landing_target_association(half_width_den_power),
        True, False,
    )


def bigq_c_minus_2_trivial_fiber_instance(half_width_den_power: Int) -> BigQMisiurewiczTrivialFiberInstance:
    return BigQMisiurewiczTrivialFiberInstance(
        bigq_trivial_fiber_source(),
        verify_bigq_c_minus_2_landing_target_association(half_width_den_power),
        2, 1, True, False,
    )


def bigq_theorem_payload_replay_smoke() -> Bool:
    var landing = bigq_c_minus_2_landing_instance(8)
    var fiber = bigq_c_minus_2_trivial_fiber_instance(8)
    var ambiguous_landing = bigq_c_minus_2_landing_instance(0)
    return (
        landing.finite_source_scope_matched() and fiber.finite_source_scope_matched() and
        not landing.classification_proof_attached and not fiber.classification_proof_attached and
        not landing.final_import_admissible() and not fiber.final_import_admissible() and
        not ambiguous_landing.finite_source_scope_matched()
    )
