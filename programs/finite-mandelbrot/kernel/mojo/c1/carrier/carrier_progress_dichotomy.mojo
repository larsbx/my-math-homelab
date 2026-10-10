# C1 carrier progress dichotomy scaffold.
#
# This module is intentionally small. It records the shape of the local
# proof obligation without claiming the global C1 conjecture.

struct CarrierProgressInput:
    var obstruction_id: String
    var accepted: Bool
    var has_incidence_carrier: Bool
    var has_governed_terms: Bool
    var rank2_circle_used: Bool

    fn __init__(inout self, obstruction_id: String, accepted: Bool, has_incidence_carrier: Bool, has_governed_terms: Bool, rank2_circle_used: Bool):
        self.obstruction_id = obstruction_id
        self.accepted = accepted
        self.has_incidence_carrier = has_incidence_carrier
        self.has_governed_terms = has_governed_terms
        self.rank2_circle_used = rank2_circle_used

struct CarrierDichotomyOutcome:
    var strict_refinement: Bool
    var missing_link: Bool
    var boundary_equality_refinement: Bool
    var opposite_side_separation_route: Bool
    var rejected: Bool
    var proves_c1: Bool
    var proves_singleton_fiber: Bool

    fn __init__(inout self, strict_refinement: Bool, missing_link: Bool, boundary_equality_refinement: Bool, opposite_side_separation_route: Bool, rejected: Bool):
        self.strict_refinement = strict_refinement
        self.missing_link = missing_link
        self.boundary_equality_refinement = boundary_equality_refinement
        self.opposite_side_separation_route = opposite_side_separation_route
        self.rejected = rejected
        self.proves_c1 = False
        self.proves_singleton_fiber = False

fn rank2_circle_primitive_available() -> Bool:
    return False

fn allowed_dichotomy_kind(kind: String) -> Bool:
    return (
        kind == "StrictCarrierRefinement" or
        kind == "MissingTheoremCatalogueLink" or
        kind == "BoundaryEqualityRefinement" or
        kind == "RefinesToOppositeSideSeparation"
    )

fn carrier_progress_dichotomy(input: CarrierProgressInput, kind: String) -> CarrierDichotomyOutcome:
    if not input.accepted:
        return CarrierDichotomyOutcome(False, False, False, False, True)
    if not input.has_incidence_carrier:
        return CarrierDichotomyOutcome(False, False, False, False, True)
    if not input.has_governed_terms:
        return CarrierDichotomyOutcome(False, False, False, False, True)
    if input.rank2_circle_used:
        return CarrierDichotomyOutcome(False, False, False, False, True)
    if not allowed_dichotomy_kind(kind):
        return CarrierDichotomyOutcome(False, False, False, False, True)
    if kind == "StrictCarrierRefinement":
        return CarrierDichotomyOutcome(True, False, False, False, False)
    if kind == "MissingTheoremCatalogueLink":
        return CarrierDichotomyOutcome(False, True, False, False, False)
    if kind == "BoundaryEqualityRefinement":
        return CarrierDichotomyOutcome(False, False, True, False, False)
    return CarrierDichotomyOutcome(False, False, False, True, False)

fn demo_valid_refinement_route() -> CarrierDichotomyOutcome:
    var input = CarrierProgressInput("obs-carrier-1", True, True, True, False)
    return carrier_progress_dichotomy(input, "StrictCarrierRefinement")

fn demo_missing_link_route() -> CarrierDichotomyOutcome:
    var input = CarrierProgressInput("obs-carrier-2", True, True, True, False)
    return carrier_progress_dichotomy(input, "MissingTheoremCatalogueLink")

fn demo_rank2_circle_rejection() -> CarrierDichotomyOutcome:
    var input = CarrierProgressInput("obs-bad-circle", True, True, True, True)
    return carrier_progress_dichotomy(input, "StrictCarrierRefinement")
