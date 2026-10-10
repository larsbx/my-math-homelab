# certificate_incidence.mojo
#
# Incidence-bearing certificate wrappers.
#
# The certificate core does not emit analytic singletons. When a Misiurewicz
# certificate is accepted, it emits a PointVertex: a finite vertex whose carrier
# is the finite set of vertices supplied by the certificate record.

from certificates.joint_certificate import JointCertificateStatus, demo_joint_c_minus_2, demo_joint_m41_placeholder
from dynamics.vertex_incidence import PointVertex, VertexSet, Vertex, root_handle_vertex, ray_addr_set_vertex, box_vertex, misiurewicz_point_vertex


struct CertificateIncidence:
    var status: JointCertificateStatus
    var root_handle: Vertex
    var ray_addr_set: Vertex
    var box: Vertex
    var emitted: PointVertex

    fn __init__(inout self, status: JointCertificateStatus, root_handle: Vertex, ray_addr_set: Vertex, box: Vertex, emitted: PointVertex):
        self.status = status
        self.root_handle = root_handle
        self.ray_addr_set = ray_addr_set
        self.box = box
        self.emitted = emitted

    fn accepted(self) -> Bool:
        return self.status.accepted() and self.emitted.valid()

    fn carrier_size(self) -> Int:
        return self.emitted.carrier.size


fn build_certificate_incidence(status: JointCertificateStatus, poly_name: String, ray_set_name: String) -> CertificateIncidence:
    var root = root_handle_vertex(poly_name, status.same_box_name)
    var rays = ray_addr_set_vertex(ray_set_name)
    var box = box_vertex(status.same_box_name)
    var emitted = misiurewicz_point_vertex(poly_name, status.same_box_name, ray_set_name)
    return CertificateIncidence(status, root, rays, box, emitted)


fn demo_c_minus_2_certificate_incidence() -> CertificateIncidence:
    return build_certificate_incidence(demo_joint_c_minus_2(), "P_2_1", "theta_1_2")


fn demo_m41_certificate_incidence_placeholder() -> CertificateIncidence:
    return build_certificate_incidence(demo_joint_m41_placeholder(), "P_4_1", "theta_9_11_15_over_56")


fn accepted_certificate_emits_only_vertex_of_vertices() -> Bool:
    var ci = demo_c_minus_2_certificate_incidence()
    return ci.accepted() and ci.carrier_size() == 3


fn placeholder_certificate_does_not_emit_accepted_incidence() -> Bool:
    var ci = demo_m41_certificate_incidence_placeholder()
    return not ci.accepted() and ci.emitted.valid()
