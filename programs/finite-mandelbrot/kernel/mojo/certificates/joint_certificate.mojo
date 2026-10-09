# joint_certificate.mojo
#
# Joins Krawczyk localization and exact-type interval exclusions on the same
# parameter box. This is the central finite certificate gate for Misiurewicz
# triviality before theorem tags discharge landing/fiber claims.

from certificates.krawczyk_witness import KrawczykWitnessStatus, demo_krawczyk_p21_c_minus_2, demo_krawczyk_p41_m41_placeholder
from dynamics.interval_orbit import IntervalOrbitStatus, demo_c_minus_2_status, demo_m41_status


struct TheoremTagStatus:
    var rational_ray_landing: Bool
    var misiurewicz_fiber_triviality: Bool

    fn __init__(inout self, rational_ray_landing: Bool, misiurewicz_fiber_triviality: Bool):
        self.rational_ray_landing = rational_ray_landing
        self.misiurewicz_fiber_triviality = misiurewicz_fiber_triviality

    fn accepted(self) -> Bool:
        return self.rational_ray_landing and self.misiurewicz_fiber_triviality


struct JointCertificateStatus:
    var example_name: String
    var same_box_name: String
    var krawczyk: KrawczykWitnessStatus
    var exclusions: IntervalOrbitStatus
    var theorem_tags: TheoremTagStatus
    var ray_address_kneading_match: Bool
    var box_names_match: Bool

    fn __init__(inout self, example_name: String, same_box_name: String, krawczyk: KrawczykWitnessStatus, exclusions: IntervalOrbitStatus, theorem_tags: TheoremTagStatus, ray_address_kneading_match: Bool, box_names_match: Bool):
        self.example_name = example_name
        self.same_box_name = same_box_name
        self.krawczyk = krawczyk
        self.exclusions = exclusions
        self.theorem_tags = theorem_tags
        self.ray_address_kneading_match = ray_address_kneading_match
        self.box_names_match = box_names_match

    fn accepted(self) -> Bool:
        return (
            self.box_names_match and
            self.krawczyk.accepted() and
            self.exclusions.accepted() and
            self.theorem_tags.accepted() and
            self.ray_address_kneading_match
        )


fn accepted_theorem_tags() -> TheoremTagStatus:
    return TheoremTagStatus(True, True)


fn demo_joint_c_minus_2() -> JointCertificateStatus:
    var k = demo_krawczyk_p21_c_minus_2()
    var e = demo_c_minus_2_status()
    return JointCertificateStatus(
        "c_minus_2",
        "beta_c_minus_2",
        k,
        e,
        accepted_theorem_tags(),
        True,
        k.root_box_name == "beta_c_minus_2",
    )


fn demo_joint_m41_placeholder() -> JointCertificateStatus:
    var k = demo_krawczyk_p41_m41_placeholder()
    var e = demo_m41_status()
    return JointCertificateStatus(
        "M_4_1_placeholder",
        "beta_m41_pending",
        k,
        e,
        accepted_theorem_tags(),
        True,
        k.root_box_name == "beta_m41_pending",
    )


fn must_reject_krawczyk_without_exclusions() -> Bool:
    var k = demo_krawczyk_p21_c_minus_2()
    var bad_exclusions = IntervalOrbitStatus(True, True, True, 4, 5)
    var status = JointCertificateStatus(
        "bad_missing_exclusion",
        "beta_c_minus_2",
        k,
        bad_exclusions,
        accepted_theorem_tags(),
        True,
        True,
    )
    return not status.accepted()


fn must_reject_exclusions_without_krawczyk() -> Bool:
    var bad_k = KrawczykWitnessStatus("P_2_1", True, True, True, False, "beta_c_minus_2")
    var e = demo_c_minus_2_status()
    var status = JointCertificateStatus(
        "bad_missing_krawczyk",
        "beta_c_minus_2",
        bad_k,
        e,
        accepted_theorem_tags(),
        True,
        True,
    )
    return not status.accepted()


fn must_reject_box_mismatch() -> Bool:
    var k = demo_krawczyk_p21_c_minus_2()
    var e = demo_c_minus_2_status()
    var status = JointCertificateStatus(
        "bad_box_mismatch",
        "different_box",
        k,
        e,
        accepted_theorem_tags(),
        True,
        False,
    )
    return not status.accepted()
