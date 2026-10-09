# C1 unresolved wake to carrier obstruction scaffold.
# This file is terminology-governed by docs/C1_unresolved_wake_to_carrier_obstruction.md.
# It uses finite incidence records only. Rank-2 circle/locus primitives are unavailable.

struct UnresolvedWakeEvidence:
    var object_ref: String
    var separator_code: String
    var prefix_index: Int
    var attempted_side_data: String
    var failure_kind: String

    fn __init__(inout self, object_ref: String, separator_code: String, prefix_index: Int, attempted_side_data: String, failure_kind: String):
        self.object_ref = object_ref
        self.separator_code = separator_code
        self.prefix_index = prefix_index
        self.attempted_side_data = attempted_side_data
        self.failure_kind = failure_kind


fn allowed_failure_kind(kind: String) -> Bool:
    return (
        kind == "BoundaryEqualityCandidate" or
        kind == "CarrierTooCoarse" or
        kind == "LandingTagMissing" or
        kind == "CatalogueLinkMissing" or
        kind == "WakeOrderUnderdetermined"
    )


fn accepts_unresolved_wake_evidence(evidence: UnresolvedWakeEvidence) -> Bool:
    if evidence.object_ref == "":
        return False
    if evidence.separator_code == "":
        return False
    if evidence.prefix_index < 0:
        return False
    if evidence.attempted_side_data == "":
        return False
    return allowed_failure_kind(evidence.failure_kind)


struct CarrierObstructionRoute:
    var boundary_equality_refinement: Bool
    var carrier_obstruction: Bool
    var missing_catalogue_extensionality: Bool
    var refines_to_opposite_side_separation: Bool
    var proves_c1: Bool
    var proves_same_fiber: Bool

    fn __init__(inout self, boundary_equality_refinement: Bool, carrier_obstruction: Bool, missing_catalogue_extensionality: Bool, refines_to_opposite_side_separation: Bool):
        self.boundary_equality_refinement = boundary_equality_refinement
        self.carrier_obstruction = carrier_obstruction
        self.missing_catalogue_extensionality = missing_catalogue_extensionality
        self.refines_to_opposite_side_separation = refines_to_opposite_side_separation
        self.proves_c1 = False
        self.proves_same_fiber = False


fn route_unresolved_wake_evidence(evidence: UnresolvedWakeEvidence) -> CarrierObstructionRoute:
    if not accepts_unresolved_wake_evidence(evidence):
        return CarrierObstructionRoute(False, False, False, False)
    if evidence.failure_kind == "BoundaryEqualityCandidate":
        return CarrierObstructionRoute(True, False, False, False)
    if evidence.failure_kind == "CarrierTooCoarse" or evidence.failure_kind == "WakeOrderUnderdetermined":
        return CarrierObstructionRoute(False, True, False, False)
    if evidence.failure_kind == "LandingTagMissing" or evidence.failure_kind == "CatalogueLinkMissing":
        return CarrierObstructionRoute(False, False, True, False)
    return CarrierObstructionRoute(False, False, False, False)


fn bounded_search_failure_is_persistent() -> Bool:
    return False


fn rank2_circle_or_locus_available() -> Bool:
    return False


fn demo_carrier_too_coarse_route() -> CarrierObstructionRoute:
    var evidence = UnresolvedWakeEvidence(
        "PointVertex:demo-A",
        "TwoRaySeparator:1/3:2/3",
        7,
        "strict-cyclic-order-undecided",
        "CarrierTooCoarse",
    )
    return route_unresolved_wake_evidence(evidence)
