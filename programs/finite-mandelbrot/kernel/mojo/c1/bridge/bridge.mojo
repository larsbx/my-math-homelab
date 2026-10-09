# C1_bridge.mojo
#
# Focused bridge scaffolding for the top conjecture only:
# finite rational-ray nest stabilization <-> fiber triviality <-> MLC.
#
# This file deliberately avoids bigint, rendering, hash roots, and Krawczyk work.
# It also avoids analytic point primitives. Objects are finite incidence records,
# vertex carriers, ray-address data, catalogues, and theorem tags.

from c1.separator.separation_grammar import SeparationLine, SeparationCatalogue, SameFiberLevel, FiberNestStatus


struct IncidenceObjectRef:
    var vertex_name: String
    var is_point_vertex: Bool

    fn __init__(inout self, vertex_name: String, is_point_vertex: Bool):
        self.vertex_name = vertex_name
        self.is_point_vertex = is_point_vertex

    fn valid(self) -> Bool:
        return self.is_point_vertex and len(self.vertex_name) > 0


struct CatalogueSeparationClaim:
    var left: IncidenceObjectRef
    var right: IncidenceObjectRef
    var catalogue_depth: Int
    var has_certified_separator: Bool

    fn __init__(inout self, left: IncidenceObjectRef, right: IncidenceObjectRef, catalogue_depth: Int, has_certified_separator: Bool):
        self.left = left
        self.right = right
        self.catalogue_depth = catalogue_depth
        self.has_certified_separator = has_certified_separator

    fn valid_finite_claim(self) -> Bool:
        return self.left.valid() and self.right.valid() and self.catalogue_depth >= 0

    fn separated_at_depth(self) -> Bool:
        return self.valid_finite_claim() and self.has_certified_separator

    fn same_fiber_level(self) -> SameFiberLevel:
        return SameFiberLevel(self.catalogue_depth, not self.has_certified_separator)


struct SameFiberStreamClaim:
    var left: IncidenceObjectRef
    var right: IncidenceObjectRef
    var all_checked_depths_unseparated: Bool
    var checked_depth: Int

    fn __init__(inout self, left: IncidenceObjectRef, right: IncidenceObjectRef, all_checked_depths_unseparated: Bool, checked_depth: Int):
        self.left = left
        self.right = right
        self.all_checked_depths_unseparated = all_checked_depths_unseparated
        self.checked_depth = checked_depth

    fn finite_prefix_valid(self) -> Bool:
        return self.left.valid() and self.right.valid() and self.checked_depth >= 0

    fn finite_prefix_unseparated(self) -> Bool:
        return self.finite_prefix_valid() and self.all_checked_depths_unseparated

    fn claims_generic_stabilization(self) -> Bool:
        # A finite prefix is never a generic stabilization proof.
        return False


struct FiberBridgeTag:
    var catalogue_extensionality: Bool
    var fiber_triviality_equiv_mlc: Bool
    var generic_case_open: Bool

    fn __init__(inout self, catalogue_extensionality: Bool, fiber_triviality_equiv_mlc: Bool, generic_case_open: Bool):
        self.catalogue_extensionality = catalogue_extensionality
        self.fiber_triviality_equiv_mlc = fiber_triviality_equiv_mlc
        self.generic_case_open = generic_case_open

    fn accepted_bridge_boundary(self) -> Bool:
        return self.catalogue_extensionality and self.fiber_triviality_equiv_mlc and self.generic_case_open


fn default_c1_bridge_tag() -> FiberBridgeTag:
    # catalogue_extensionality is project-owned proof work and remains false
    # until the finite grammar adequacy theorem is written.
    # fiber_triviality_equiv_mlc is the literature bridge tag.
    # generic_case_open must remain true.
    return FiberBridgeTag(False, True, True)


fn demo_separated_claim() -> Bool:
    var a = IncidenceObjectRef("MisPointVertex:P_2_1", True)
    var b = IncidenceObjectRef("MisPointVertex:P_4_1", True)
    var claim = CatalogueSeparationClaim(a, b, 3, True)
    return claim.separated_at_depth()


fn demo_finite_prefix_not_stabilization() -> Bool:
    var a = IncidenceObjectRef("GenericFiberVertex:A", True)
    var b = IncidenceObjectRef("GenericFiberVertex:B", True)
    var claim = SameFiberStreamClaim(a, b, True, 12)
    return claim.finite_prefix_unseparated() and not claim.claims_generic_stabilization()


fn c1_ready_for_public_claim() -> Bool:
    # Must remain false until catalogue_extensionality is proved.
    return default_c1_bridge_tag().accepted_bridge_boundary()
