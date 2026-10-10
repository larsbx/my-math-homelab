# C1 wake ambiguity frontier scaffold.
#
# This file names the finite/meta object used by the F1 obstruction
# extraction route.  It does not prove C1 and does not claim same fiber.

struct WakeAmbiguityRecord:
    var pair_id: String
    var cofinal_prefix_claim: Bool
    var unresolved_wake_side_family: Bool
    var declared_boundary_carriers: Bool
    var catalogue_extensionality_available: Bool
    var shrinking_nest_discipline_available: Bool
    var bounded_search_only: Bool
    var claims_same_fiber: Bool
    var claims_singleton_fiber: Bool
    var claims_C1: Bool

    fn __init__(
        inout self,
        pair_id: String,
        cofinal_prefix_claim: Bool,
        unresolved_wake_side_family: Bool,
        declared_boundary_carriers: Bool,
        catalogue_extensionality_available: Bool,
        shrinking_nest_discipline_available: Bool,
        bounded_search_only: Bool,
        claims_same_fiber: Bool,
        claims_singleton_fiber: Bool,
        claims_C1: Bool,
    ):
        self.pair_id = pair_id
        self.cofinal_prefix_claim = cofinal_prefix_claim
        self.unresolved_wake_side_family = unresolved_wake_side_family
        self.declared_boundary_carriers = declared_boundary_carriers
        self.catalogue_extensionality_available = catalogue_extensionality_available
        self.shrinking_nest_discipline_available = shrinking_nest_discipline_available
        self.bounded_search_only = bounded_search_only
        self.claims_same_fiber = claims_same_fiber
        self.claims_singleton_fiber = claims_singleton_fiber
        self.claims_C1 = claims_C1

    fn is_admissible_frontier_obstruction(self) -> Bool:
        if not self.cofinal_prefix_claim:
            return False
        if not self.unresolved_wake_side_family:
            return False
        if not self.declared_boundary_carriers:
            return False
        if not self.catalogue_extensionality_available:
            return False
        if not self.shrinking_nest_discipline_available:
            return False
        if self.bounded_search_only:
            return False
        if self.claims_same_fiber:
            return False
        if self.claims_singleton_fiber:
            return False
        if self.claims_C1:
            return False
        return True


struct ObstructionExtractionState:
    var persistent_nonseparation: Bool
    var wake_ambiguity: Bool
    var undeclared_boundary_carrier: Bool
    var nonshrinking_nested_carrier: Bool
    var missing_catalogue_extensionality: Bool

    fn __init__(
        inout self,
        persistent_nonseparation: Bool,
        wake_ambiguity: Bool,
        undeclared_boundary_carrier: Bool,
        nonshrinking_nested_carrier: Bool,
        missing_catalogue_extensionality: Bool,
    ):
        self.persistent_nonseparation = persistent_nonseparation
        self.wake_ambiguity = wake_ambiguity
        self.undeclared_boundary_carrier = undeclared_boundary_carrier
        self.nonshrinking_nested_carrier = nonshrinking_nested_carrier
        self.missing_catalogue_extensionality = missing_catalogue_extensionality

    fn explains_persistent_nonseparation(self) -> Bool:
        if not self.persistent_nonseparation:
            return False
        return (
            self.wake_ambiguity
            or self.undeclared_boundary_carrier
            or self.nonshrinking_nested_carrier
            or self.missing_catalogue_extensionality
        )

    fn isolates_wake_ambiguity(self) -> Bool:
        if not self.persistent_nonseparation:
            return False
        if not self.wake_ambiguity:
            return False
        if self.undeclared_boundary_carrier:
            return False
        if self.nonshrinking_nested_carrier:
            return False
        if self.missing_catalogue_extensionality:
            return False
        return True


fn demo_valid_wake_ambiguity() -> Bool:
    var record = WakeAmbiguityRecord(
        "A:B",
        True,
        True,
        True,
        True,
        True,
        False,
        False,
        False,
        False,
    )
    return record.is_admissible_frontier_obstruction()


fn demo_bounded_search_rejected() -> Bool:
    var record = WakeAmbiguityRecord(
        "A:B",
        True,
        True,
        True,
        True,
        True,
        True,
        False,
        False,
        False,
    )
    return not record.is_admissible_frontier_obstruction()


fn demo_same_fiber_claim_rejected() -> Bool:
    var record = WakeAmbiguityRecord(
        "A:B",
        True,
        True,
        True,
        True,
        True,
        False,
        True,
        False,
        False,
    )
    return not record.is_admissible_frontier_obstruction()
