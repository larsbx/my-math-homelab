# BigZ/Q finite-certificate composition boundary for c=-2.
#
# This gate reports finite replay separately from theorem imports and complete
# certificate acceptance. The latter two remain fail-closed.

from certificates.c_minus_2.bigq_landing_target_adapter import BigQLandingTargetAssociation, verify_bigq_c_minus_2_landing_target_association
from certificates.c_minus_2.bigq_theorem_tag_payload_instances import BigQRationalRayLandingInstance, BigQMisiurewiczTrivialFiberInstance, bigq_c_minus_2_landing_instance, bigq_c_minus_2_trivial_fiber_instance


struct BigQFiniteCertificateStatus(Copyable):
    var association: BigQLandingTargetAssociation
    var landing_tag: BigQRationalRayLandingInstance
    var fiber_tag: BigQMisiurewiczTrivialFiberInstance

    def __init__(out self, association: BigQLandingTargetAssociation, landing_tag: BigQRationalRayLandingInstance, fiber_tag: BigQMisiurewiczTrivialFiberInstance):
        self.association = association.copy()
        self.landing_tag = landing_tag.copy()
        self.fiber_tag = fiber_tag.copy()

    def finite_inputs_accepted(self) -> Bool:
        return (
            self.association.finite_replay_associated() and
            self.landing_tag.finite_source_scope_matched() and
            self.fiber_tag.finite_source_scope_matched()
        )

    def theorem_tags_accepted(self) -> Bool:
        return self.landing_tag.final_import_admissible() and self.fiber_tag.final_import_admissible()

    def certificate_accepted(self) -> Bool:
        return self.finite_inputs_accepted() and self.theorem_tags_accepted()

    def proves_c1(self) -> Bool:
        return False

    def proves_residual_closure_no_missing_links(self) -> Bool:
        return False


def bigq_c_minus_2_finite_certificate(half_width_den_power: Int) -> BigQFiniteCertificateStatus:
    return BigQFiniteCertificateStatus(
        verify_bigq_c_minus_2_landing_target_association(half_width_den_power),
        bigq_c_minus_2_landing_instance(half_width_den_power),
        bigq_c_minus_2_trivial_fiber_instance(half_width_den_power),
    )


def bigq_finite_certificate_gate_smoke() -> Bool:
    var status = bigq_c_minus_2_finite_certificate(8)
    var narrow = bigq_c_minus_2_finite_certificate(80)
    var ambiguous = bigq_c_minus_2_finite_certificate(0)
    var rejected = bigq_c_minus_2_finite_certificate(-1)
    return (
        status.finite_inputs_accepted() and narrow.finite_inputs_accepted() and
        not ambiguous.finite_inputs_accepted() and not rejected.finite_inputs_accepted() and
        not status.theorem_tags_accepted() and not status.certificate_accepted() and
        not status.proves_c1() and not status.proves_residual_closure_no_missing_links()
    )
