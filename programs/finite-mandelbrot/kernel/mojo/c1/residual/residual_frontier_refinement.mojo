# C1 residual frontier refinement scaffold.
#
# This module records the serious proof route:
# persistent non-separation + no missing link + no boundary equality
# forces strict carrier refinement. It is a theorem-status scaffold, not a
# completed proof of C1.

struct ResidualFrontierHypotheses:
    var persistent_nonseparation: Bool
    var no_missing_theorem_catalogue_link: Bool
    var no_boundary_equality: Bool
    var canonical_carrier_content: Bool
    var catalogue_extensionality_local_route: Bool
    var side_soundness_route: Bool

    fn __init__(inout self,
                persistent_nonseparation: Bool,
                no_missing_theorem_catalogue_link: Bool,
                no_boundary_equality: Bool,
                canonical_carrier_content: Bool,
                catalogue_extensionality_local_route: Bool,
                side_soundness_route: Bool):
        self.persistent_nonseparation = persistent_nonseparation
        self.no_missing_theorem_catalogue_link = no_missing_theorem_catalogue_link
        self.no_boundary_equality = no_boundary_equality
        self.canonical_carrier_content = canonical_carrier_content
        self.catalogue_extensionality_local_route = catalogue_extensionality_local_route
        self.side_soundness_route = side_soundness_route


struct ResidualFrontierConclusion:
    var forces_strict_carrier_refinement: Bool
    var contradiction_if_refines_to_separation: Bool
    var proof_route_complete: Bool
    var proves_c1: Bool
    var proves_singleton_fiber: Bool

    fn __init__(inout self,
                forces_strict_carrier_refinement: Bool,
                contradiction_if_refines_to_separation: Bool,
                proof_route_complete: Bool,
                proves_c1: Bool,
                proves_singleton_fiber: Bool):
        self.forces_strict_carrier_refinement = forces_strict_carrier_refinement
        self.contradiction_if_refines_to_separation = contradiction_if_refines_to_separation
        self.proof_route_complete = proof_route_complete
        self.proves_c1 = proves_c1
        self.proves_singleton_fiber = proves_singleton_fiber


fn residual_hypotheses_ready(h: ResidualFrontierHypotheses) -> Bool:
    return h.persistent_nonseparation and h.no_missing_theorem_catalogue_link and h.no_boundary_equality and h.canonical_carrier_content and h.catalogue_extensionality_local_route and h.side_soundness_route


fn residual_frontier_refinement(h: ResidualFrontierHypotheses) -> ResidualFrontierConclusion:
    if not residual_hypotheses_ready(h):
        return ResidualFrontierConclusion(False, False, False, False, False)

    # The local route forces strict carrier refinement as the only surviving
    # case after missing-link, boundary-equality, and finite-separation routes
    # are eliminated. The proof is still pending on the named local lemmas.
    return ResidualFrontierConclusion(True, True, False, False, False)


fn active_remaining_route() -> String:
    return "PersistentNonSeparation + NoMissingLink + NoBoundaryEquality => StrictCarrierRefinement => finite descent"


fn rank2_circle_primitive_available() -> Bool:
    return False


fn bounded_search_proves_residual_frontier() -> Bool:
    return False


fn residual_route_claims_metric_diameter() -> Bool:
    return False
