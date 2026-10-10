# C1 carrier refinement progress scaffold.
#
# This is a finite/meta proof scaffold. It does not prove C1, MLC, local
# connectivity, or singleton-fiber convergence.

struct CarrierObstructionInput:
    var carrier_id: String
    var obstruction_kind: String
    var has_wake_evidence: Bool
    var has_theorem_tag_binding: Bool

    fn __init__(inout self, carrier_id: String, obstruction_kind: String, has_wake_evidence: Bool, has_theorem_tag_binding: Bool):
        self.carrier_id = carrier_id
        self.obstruction_kind = obstruction_kind
        self.has_wake_evidence = has_wake_evidence
        self.has_theorem_tag_binding = has_theorem_tag_binding


struct CarrierProgressOutcome:
    var kind: String
    var is_productive: Bool
    var proves_c1: Bool
    var proves_singleton_fiber: Bool

    fn __init__(inout self, kind: String, is_productive: Bool, proves_c1: Bool, proves_singleton_fiber: Bool):
        self.kind = kind
        self.is_productive = is_productive
        self.proves_c1 = proves_c1
        self.proves_singleton_fiber = proves_singleton_fiber


fn allowed_progress_kind(kind: String) -> Bool:
    return (
        kind == "StrictCarrierRefinement" or
        kind == "MissingTheoremCatalogueLink" or
        kind == "BoundaryEqualityRefinement" or
        kind == "RefinesToOppositeSideSeparation"
    )


fn classify_carrier_progress(input: CarrierObstructionInput) -> CarrierProgressOutcome:
    if not input.has_wake_evidence:
        return CarrierProgressOutcome("MissingTheoremCatalogueLink", True, False, False)

    if input.obstruction_kind == "CarrierTooCoarse":
        return CarrierProgressOutcome("StrictCarrierRefinement", True, False, False)
    if input.obstruction_kind == "LandingTagMissing":
        return CarrierProgressOutcome("MissingTheoremCatalogueLink", True, False, False)
    if input.obstruction_kind == "CatalogueLinkMissing":
        return CarrierProgressOutcome("MissingTheoremCatalogueLink", True, False, False)
    if input.obstruction_kind == "WakeOrderUnderdetermined":
        return CarrierProgressOutcome("StrictCarrierRefinement", True, False, False)
    if input.obstruction_kind == "BoundaryEqualityCandidate":
        return CarrierProgressOutcome("BoundaryEqualityRefinement", True, False, False)

    return CarrierProgressOutcome("MissingTheoremCatalogueLink", True, False, False)


fn carrier_progress_dichotomy_pending() -> Bool:
    # The proof route is named, but the mathematical lemma is not discharged.
    return True


fn rank2_circle_primitive_available() -> Bool:
    return False
