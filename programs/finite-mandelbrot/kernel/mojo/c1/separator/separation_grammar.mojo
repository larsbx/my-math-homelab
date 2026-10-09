# separation_grammar.mojo
#
# Finite grammar for C1: rational-ray separation data and finite fiber nests.
# This is not a renderer and not a numerical engine. It is the formal bridge
# layer for the top conjecture.

from dynamics.vertex_incidence import Vertex, VertexSet, PointVertex
from dynamics.ray_address import RayAddr


struct LandingTag:
    var rational_ray_landing: Bool
    var source_id: String

    fn __init__(inout self, rational_ray_landing: Bool, source_id: String):
        self.rational_ray_landing = rational_ray_landing
        self.source_id = source_id

    fn accepted(self) -> Bool:
        return self.rational_ray_landing and self.source_id != ""


struct LandedRay:
    var addr: RayAddr
    var tag: LandingTag

    fn __init__(inout self, addr: RayAddr, tag: LandingTag):
        self.addr = addr
        self.tag = tag

    fn certified(self) -> Bool:
        return self.addr.valid() and self.tag.accepted()


struct SeparationLine:
    var name: String
    var ray_count: Int
    var has_landing_vertex: Bool
    var all_rays_certified: Bool
    var separates_complement_components: Bool

    fn __init__(inout self, name: String, ray_count: Int, has_landing_vertex: Bool, all_rays_certified: Bool, separates_complement_components: Bool):
        self.name = name
        self.ray_count = ray_count
        self.has_landing_vertex = has_landing_vertex
        self.all_rays_certified = all_rays_certified
        self.separates_complement_components = separates_complement_components

    fn valid(self) -> Bool:
        return (
            self.name != "" and
            self.ray_count >= 1 and
            self.has_landing_vertex and
            self.all_rays_certified and
            self.separates_complement_components
        )


struct SeparationCatalogue:
    var depth: Int
    var line_count: Int
    var all_lines_valid: Bool
    var contains_previous_depth: Bool

    fn __init__(inout self, depth: Int, line_count: Int, all_lines_valid: Bool, contains_previous_depth: Bool):
        self.depth = depth
        self.line_count = line_count
        self.all_lines_valid = all_lines_valid
        self.contains_previous_depth = contains_previous_depth

    fn valid(self) -> Bool:
        return self.depth >= 0 and self.line_count >= 0 and self.all_lines_valid

    fn refines_previous(self) -> Bool:
        return self.valid() and self.contains_previous_depth


struct SameFiberLevel:
    var depth: Int
    var witness_vertex_name: String
    var no_separation_found: Bool
    var catalogue_valid: Bool

    fn __init__(inout self, depth: Int, witness_vertex_name: String, no_separation_found: Bool, catalogue_valid: Bool):
        self.depth = depth
        self.witness_vertex_name = witness_vertex_name
        self.no_separation_found = no_separation_found
        self.catalogue_valid = catalogue_valid

    fn accepted(self) -> Bool:
        return self.depth >= 0 and self.witness_vertex_name != "" and self.no_separation_found and self.catalogue_valid


struct FiberNestStatus:
    var vertex_name: String
    var levels_checked: Int
    var monotone_refinement: Bool
    var exhausts_rational_separation_lines: Bool
    var claims_generic_singleton: Bool

    fn __init__(inout self, vertex_name: String, levels_checked: Int, monotone_refinement: Bool, exhausts_rational_separation_lines: Bool, claims_generic_singleton: Bool):
        self.vertex_name = vertex_name
        self.levels_checked = levels_checked
        self.monotone_refinement = monotone_refinement
        self.exhausts_rational_separation_lines = exhausts_rational_separation_lines
        self.claims_generic_singleton = claims_generic_singleton

    fn c1_bridge_ready(self) -> Bool:
        # Bridge-ready means the nest is correctly formed as a finite exhaustion.
        # It does not mean generic singleton stabilization is proven.
        return (
            self.vertex_name != "" and
            self.levels_checked >= 1 and
            self.monotone_refinement and
            self.exhausts_rational_separation_lines and
            not self.claims_generic_singleton
        )


fn demo_rational_landing_tag() -> LandingTag:
    return LandingTag(True, "Schleicher-RationalRayLanding")


fn demo_c_minus_2_separation_line() -> SeparationLine:
    return SeparationLine("sep_c_minus_2_theta_1_2", 1, True, True, True)


fn demo_m41_separation_line() -> SeparationLine:
    return SeparationLine("sep_m41_theta_9_11_15_over_56", 3, True, True, True)


fn demo_catalogue_depth_0() -> SeparationCatalogue:
    return SeparationCatalogue(0, 0, True, True)


fn demo_catalogue_depth_1() -> SeparationCatalogue:
    return SeparationCatalogue(1, 2, True, True)


fn demo_generic_fiber_nest_no_singleton_claim() -> FiberNestStatus:
    return FiberNestStatus("generic_boundary_PointVertex", 2, True, True, False)


fn must_reject_generic_singleton_claim() -> Bool:
    var bad = FiberNestStatus("generic_boundary_PointVertex", 2, True, True, True)
    return not bad.c1_bridge_ready()
