# vertex_incidence.mojo
#
# Finite incidence substrate for the finite-regime Mandelbrot project.
#
# Policy: analytic points are not primitive. A point may appear only as a
# PointVertex: a finite vertex whose payload is a finite collection of vertices.


struct Vertex:
    var tag: String
    var id: String

    fn __init__(inout self, tag: String, id: String):
        self.tag = tag
        self.id = id

    fn eq(self, other: Vertex) -> Bool:
        return self.tag == other.tag and self.id == other.id


struct VertexSet:
    var name: String
    var size: Int

    fn __init__(inout self, name: String, size: Int):
        self.name = name
        self.size = size

    fn finite(self) -> Bool:
        return self.size >= 0


struct PointVertex:
    var name: String
    var carrier: VertexSet
    var is_incidence_only: Bool

    fn __init__(inout self, name: String, carrier: VertexSet, is_incidence_only: Bool):
        self.name = name
        self.carrier = carrier
        self.is_incidence_only = is_incidence_only

    fn valid(self) -> Bool:
        return self.carrier.finite() and self.is_incidence_only


fn root_handle_vertex(poly_name: String, box_name: String) -> Vertex:
    return Vertex("RootHandle", poly_name + "@" + box_name)


fn ray_addr_set_vertex(name: String) -> Vertex:
    return Vertex("RayAddressSet", name)


fn box_vertex(box_name: String) -> Vertex:
    return Vertex("DyadicBox", box_name)


fn misiurewicz_point_vertex(poly_name: String, box_name: String, ray_set_name: String) -> PointVertex:
    # This is not an analytic singleton. It is an incidence package consisting
    # of a root handle, a ray-address set, and the isolating box.
    var carrier = VertexSet(poly_name + ":" + box_name + ":" + ray_set_name, 3)
    return PointVertex("MisPointVertex", carrier, True)


fn demo_c_minus_2_point_vertex() -> Bool:
    var pv = misiurewicz_point_vertex("P_2_1", "beta_c_minus_2", "theta_1_2")
    return pv.valid()


fn demo_m41_point_vertex() -> Bool:
    var pv = misiurewicz_point_vertex("P_4_1", "beta_m41_pending", "theta_9_11_15_over_56")
    return pv.valid()
