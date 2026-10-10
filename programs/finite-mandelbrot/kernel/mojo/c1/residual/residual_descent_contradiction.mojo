# C1 residual descent contradiction scaffold.
#
# This file tracks the theorem route only. It does not prove C1, does not use
# bounded search as a proof, and does not introduce rank-2 locus primitives.

struct ResidualDescentHypotheses:
    var persistent_nonseparation: Bool
    var no_missing_link: Bool
    var no_boundary_equality: Bool
    var canonical_carrier_content: Bool
    var residual_frontier_refinement: Bool
    var strict_refinement_wellfounded: Bool

    fn __init__(inout self, persistent_nonseparation: Bool, no_missing_link: Bool, no_boundary_equality: Bool, canonical_carrier_content: Bool, residual_frontier_refinement: Bool, strict_refinement_wellfounded: Bool):
        self.persistent_nonseparation = persistent_nonseparation
        self.no_missing_link = no_missing_link
        self.no_boundary_equality = no_boundary_equality
        self.canonical_carrier_content = canonical_carrier_content
        self.residual_frontier_refinement = residual_frontier_refinement
        self.strict_refinement_wellfounded = strict_refinement_wellfounded


struct ResidualExit:
    var finite_separation: Bool
    var boundary_equality_refinement: Bool
    var missing_theorem_catalogue_link: Bool
    var established_trivial_fiber_tag: Bool

    fn __init__(inout self, finite_separation: Bool, boundary_equality_refinement: Bool, missing_theorem_catalogue_link: Bool, established_trivial_fiber_tag: Bool):
        self.finite_separation = finite_separation
        self.boundary_equality_refinement = boundary_equality_refinement
        self.missing_theorem_catalogue_link = missing_theorem_catalogue_link
        self.established_trivial_fiber_tag = established_trivial_fiber_tag


struct ResidualDescentConclusion:
    var contradiction_to_infinite_residual: Bool
    var exits_residual_case: Bool
    var proves_c1: Bool
    var proves_singleton_fiber: Bool

    fn __init__(inout self, contradiction_to_infinite_residual: Bool, exits_residual_case: Bool, proves_c1: Bool, proves_singleton_fiber: Bool):
        self.contradiction_to_infinite_residual = contradiction_to_infinite_residual
        self.exits_residual_case = exits_residual_case
        self.proves_c1 = proves_c1
        self.proves_singleton_fiber = proves_singleton_fiber


fn residual_descent_ready(h: ResidualDescentHypotheses) -> Bool:
    return (
        h.persistent_nonseparation and
        h.no_missing_link and
        h.no_boundary_equality and
        h.canonical_carrier_content and
        h.residual_frontier_refinement and
        h.strict_refinement_wellfounded
    )


fn has_allowed_exit(exit: ResidualExit) -> Bool:
    return (
        exit.finite_separation or
        exit.boundary_equality_refinement or
        exit.missing_theorem_catalogue_link or
        exit.established_trivial_fiber_tag
    )


fn residual_descent_contradiction(h: ResidualDescentHypotheses) -> ResidualDescentConclusion:
    if residual_descent_ready(h):
        return ResidualDescentConclusion(True, True, False, False)
    return ResidualDescentConclusion(False, False, False, False)


fn bounded_search_proves_residual_contradiction() -> Bool:
    return False


fn rank2_circle_primitive_available() -> Bool:
    return False
