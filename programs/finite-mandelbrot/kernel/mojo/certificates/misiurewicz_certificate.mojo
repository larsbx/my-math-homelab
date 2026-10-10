# misiurewicz_certificate.mojo
#
# Finite certificate envelope for Misiurewicz triviality.
#
# A classical analytic singleton is never primitive here. The certificate emits
# an incidence PointVertex whose carrier consists of finite vertices: a root
# handle, a ray-address set, and the dyadic isolating box.

from certificates.certificate_incidence import CertificateIncidenceStatus, demo_c_minus_2_certificate_incidence, demo_m41_certificate_incidence_placeholder
from certificates.joint_certificate import JointCertificateStatus, demo_joint_c_minus_2, demo_joint_m41_placeholder
from dynamics.vertex_incidence import PointVertex, misiurewicz_point_vertex


struct RootHandle:
    var polynomial_name: String
    var box_name: String
    var krawczyk_witness_name: String
    var squarefree_localization: Bool

    fn __init__(inout self, polynomial_name: String, box_name: String, krawczyk_witness_name: String, squarefree_localization: Bool):
        self.polynomial_name = polynomial_name
        self.box_name = box_name
        self.krawczyk_witness_name = krawczyk_witness_name
        self.squarefree_localization = squarefree_localization

    fn valid(self) -> Bool:
        return self.squarefree_localization and len(self.polynomial_name) > 0 and len(self.box_name) > 0


struct RayAddressDatum:
    var name: String
    var preperiod: Int
    var ray_period: Int
    var orbit_period: Int
    var finite_count: Int
    var kneading_match: Bool

    fn __init__(inout self, name: String, preperiod: Int, ray_period: Int, orbit_period: Int, finite_count: Int, kneading_match: Bool):
        self.name = name
        self.preperiod = preperiod
        self.ray_period = ray_period
        self.orbit_period = orbit_period
        self.finite_count = finite_count
        self.kneading_match = kneading_match

    fn valid(self) -> Bool:
        return (
            self.preperiod >= 0 and
            self.ray_period >= 1 and
            self.orbit_period >= 1 and
            (self.ray_period % self.orbit_period == 0) and
            self.finite_count >= 1 and
            self.kneading_match
        )


struct TheoremTags:
    var rational_ray_landing: Bool
    var misiurewicz_fiber_triviality: Bool

    fn __init__(inout self, rational_ray_landing: Bool, misiurewicz_fiber_triviality: Bool):
        self.rational_ray_landing = rational_ray_landing
        self.misiurewicz_fiber_triviality = misiurewicz_fiber_triviality

    fn valid(self) -> Bool:
        return self.rational_ray_landing and self.misiurewicz_fiber_triviality


struct MisiurewiczCertificate:
    var name: String
    var ell: Int
    var orbit_period: Int
    var horizon: Int
    var root: RootHandle
    var rays: RayAddressDatum
    var joint: JointCertificateStatus
    var incidence: CertificateIncidenceStatus
    var tags: TheoremTags

    fn __init__(inout self, name: String, ell: Int, orbit_period: Int, horizon: Int, root: RootHandle, rays: RayAddressDatum, joint: JointCertificateStatus, incidence: CertificateIncidenceStatus, tags: TheoremTags):
        self.name = name
        self.ell = ell
        self.orbit_period = orbit_period
        self.horizon = horizon
        self.root = root
        self.rays = rays
        self.joint = joint
        self.incidence = incidence
        self.tags = tags

    fn lambda_preperiod(self) -> Int:
        return self.ell - 1

    fn valid_header(self) -> Bool:
        return self.ell >= 1 and self.orbit_period >= 1 and self.horizon >= self.ell + self.orbit_period

    fn accepted(self) -> Bool:
        return (
            self.valid_header() and
            self.rays.preperiod == self.lambda_preperiod() and
            self.rays.orbit_period == self.orbit_period and
            self.root.valid() and
            self.rays.valid() and
            self.joint.accepted() and
            self.incidence.accepted() and
            self.tags.valid()
        )


fn c_minus_2_certificate() -> MisiurewiczCertificate:
    var root = RootHandle("P_2_1", "beta_c_minus_2", "Krawczyk_P_2_1_beta_c_minus_2", True)
    var rays = RayAddressDatum("theta_1_2", 1, 1, 1, 1, True)
    var tags = TheoremTags(True, True)
    return MisiurewiczCertificate(
        "c_minus_2_certificate",
        2,
        1,
        3,
        root,
        rays,
        demo_joint_c_minus_2(),
        demo_c_minus_2_certificate_incidence(),
        tags,
    )


fn m41_certificate_placeholder() -> MisiurewiczCertificate:
    var root = RootHandle("P_4_1", "beta_m41_pending", "Krawczyk_P_4_1_beta_m41_pending", True)
    var rays = RayAddressDatum("theta_9_11_15_over_56", 3, 3, 1, 3, True)
    var tags = TheoremTags(True, True)
    return MisiurewiczCertificate(
        "M_4_1_certificate_placeholder",
        4,
        1,
        6,
        root,
        rays,
        demo_joint_m41_placeholder(),
        demo_m41_certificate_incidence_placeholder(),
        tags,
    )


fn demo_c_minus_2_certificate_accepted() -> Bool:
    return c_minus_2_certificate().accepted()


fn demo_m41_certificate_rejected_until_krawczyk_lands() -> Bool:
    return not m41_certificate_placeholder().accepted()
