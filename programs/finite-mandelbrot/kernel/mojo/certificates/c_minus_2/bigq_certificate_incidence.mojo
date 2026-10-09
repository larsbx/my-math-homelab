# Finite incidence packaging for the BigZ/Q c=-2 certificate replay.
#
# There is no analytic point primitive here. A PointVertex is only a finite
# vertex whose carrier explicitly contains three other finite vertices.
# Packaging finite incidence does not emit or accept a certificate.

from certificates.c_minus_2.bigq_finite_certificate_gate import BigQFiniteCertificateStatus, bigq_c_minus_2_finite_certificate


struct FiniteVertex(Copyable):
    var role: String
    var identifier: String

    def __init__(out self, role: String, identifier: String):
        self.role = role
        self.identifier = identifier

    def valid(self) -> Bool:
        return self.role.byte_length() > 0 and self.identifier.byte_length() > 0

    def eq(self, other: FiniteVertex) -> Bool:
        return self.role == other.role and self.identifier == other.identifier


struct FiniteVertexCarrier3(Copyable):
    var root_handle: FiniteVertex
    var ray_address_set: FiniteVertex
    var rational_box: FiniteVertex

    def __init__(out self, root_handle: FiniteVertex, ray_address_set: FiniteVertex, rational_box: FiniteVertex):
        self.root_handle = root_handle.copy()
        self.ray_address_set = ray_address_set.copy()
        self.rational_box = rational_box.copy()

    def finite(self) -> Bool:
        return True

    def size(self) -> Int:
        return 3

    def roles_valid(self) -> Bool:
        return (
            self.root_handle.role == "RootHandle" and
            self.ray_address_set.role == "RayAddressSet" and
            self.rational_box.role == "RationalBox"
        )

    def members_valid_and_distinct(self) -> Bool:
        return (
            self.root_handle.valid() and self.ray_address_set.valid() and self.rational_box.valid() and
            not self.root_handle.eq(self.ray_address_set) and
            not self.root_handle.eq(self.rational_box) and
            not self.ray_address_set.eq(self.rational_box)
        )

    def valid(self) -> Bool:
        return self.finite() and self.size() == 3 and self.roles_valid() and self.members_valid_and_distinct()


struct PointVertex(Copyable):
    # Finite-regime incidence term: a vertex carrying vertices, never an
    # analytic singleton or an element of a rank-2 locus.
    var identifier: String
    var carrier: FiniteVertexCarrier3
    var incidence_only: Bool

    def __init__(out self, identifier: String, carrier: FiniteVertexCarrier3, incidence_only: Bool):
        self.identifier = identifier
        self.carrier = carrier.copy()
        self.incidence_only = incidence_only

    def valid(self) -> Bool:
        return self.identifier.byte_length() > 0 and self.carrier.valid() and self.incidence_only


struct BigQCertificateIncidence(Copyable):
    var status: BigQFiniteCertificateStatus
    var packaged_vertex: PointVertex

    def __init__(out self, status: BigQFiniteCertificateStatus, packaged_vertex: PointVertex):
        self.status = status.copy()
        self.packaged_vertex = packaged_vertex.copy()

    def finite_incidence_packaged(self) -> Bool:
        return self.status.finite_inputs_accepted() and self.packaged_vertex.valid()

    def certificate_emitted(self) -> Bool:
        return self.finite_incidence_packaged() and self.status.certificate_accepted()

    def proves_c1(self) -> Bool:
        return False

    def proves_residual_closure_no_missing_links(self) -> Bool:
        return False


def make_c_minus_2_point_vertex(box_name: String) -> PointVertex:
    var root = FiniteVertex("RootHandle", "P_2_1@" + box_name)
    var rays = FiniteVertex("RayAddressSet", "address_1_over_2")
    var box = FiniteVertex("RationalBox", box_name)
    return PointVertex(
        "MisiurewiczPointVertex:P_2_1@" + box_name,
        FiniteVertexCarrier3(root, rays, box),
        True,
    )


def bigq_c_minus_2_certificate_incidence(half_width_den_power: Int) -> BigQCertificateIncidence:
    var status = bigq_c_minus_2_finite_certificate(half_width_den_power)
    return BigQCertificateIncidence(status, make_c_minus_2_point_vertex(status.association.box_name))


def bigq_certificate_incidence_smoke() -> Bool:
    var packaged = bigq_c_minus_2_certificate_incidence(8)
    var narrow = bigq_c_minus_2_certificate_incidence(80)
    var ambiguous = bigq_c_minus_2_certificate_incidence(0)
    var root = FiniteVertex("RootHandle", "duplicate")
    var malformed = PointVertex(
        "malformed",
        FiniteVertexCarrier3(root, root, FiniteVertex("RationalBox", "beta_c_minus_2")),
        True,
    )
    return (
        packaged.finite_incidence_packaged() and packaged.packaged_vertex.carrier.size() == 3 and
        narrow.finite_incidence_packaged() and not ambiguous.finite_incidence_packaged() and
        not malformed.valid() and not packaged.certificate_emitted() and
        not packaged.proves_c1() and not packaged.proves_residual_closure_no_missing_links()
    )
