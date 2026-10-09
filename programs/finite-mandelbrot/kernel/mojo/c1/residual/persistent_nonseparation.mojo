# C1 persistent non-separation scaffold.
#
# This file records frontier proof-state objects only. It does not compute an
# infinite universal statement, and it does not prove same-fiber, singleton
# stabilization, MLC, or local connectivity.


struct IncidencePair:
    var left_id: String
    var right_id: String

    fn __init__(inout self, left_id: String, right_id: String):
        self.left_id = left_id
        self.right_id = right_id

    fn distinct(self) -> Bool:
        return self.left_id != self.right_id


struct PersistentNonSeparationClaim:
    var pair: IncidencePair
    var universal_over_prefixes: Bool
    var finite_bound_claimed: Bool
    var same_fiber_claimed: Bool
    var singleton_claimed: Bool
    var mlc_claimed: Bool

    fn __init__(
        inout self,
        pair: IncidencePair,
        universal_over_prefixes: Bool,
        finite_bound_claimed: Bool,
        same_fiber_claimed: Bool,
        singleton_claimed: Bool,
        mlc_claimed: Bool,
    ):
        self.pair = pair
        self.universal_over_prefixes = universal_over_prefixes
        self.finite_bound_claimed = finite_bound_claimed
        self.same_fiber_claimed = same_fiber_claimed
        self.singleton_claimed = singleton_claimed
        self.mlc_claimed = mlc_claimed

    fn accepted_as_frontier_hypothesis(self) -> Bool:
        if not self.pair.distinct():
            return False
        if not self.universal_over_prefixes:
            return False
        if self.finite_bound_claimed:
            return False
        if self.same_fiber_claimed:
            return False
        if self.singleton_claimed:
            return False
        if self.mlc_claimed:
            return False
        return True


struct ObstructionClassification:
    var persistent_wake_ambiguity: Bool
    var undeclared_boundary_carrier: Bool
    var nonshrinking_nested_carrier: Bool
    var missing_catalogue_extensionality: Bool

    fn __init__(
        inout self,
        persistent_wake_ambiguity: Bool,
        undeclared_boundary_carrier: Bool,
        nonshrinking_nested_carrier: Bool,
        missing_catalogue_extensionality: Bool,
    ):
        self.persistent_wake_ambiguity = persistent_wake_ambiguity
        self.undeclared_boundary_carrier = undeclared_boundary_carrier
        self.nonshrinking_nested_carrier = nonshrinking_nested_carrier
        self.missing_catalogue_extensionality = missing_catalogue_extensionality

    fn has_candidate(self) -> Bool:
        return (
            self.persistent_wake_ambiguity
            or self.undeclared_boundary_carrier
            or self.nonshrinking_nested_carrier
            or self.missing_catalogue_extensionality
        )


struct PersistentNonSeparationFrontierRecord:
    var claim: PersistentNonSeparationClaim
    var obstruction: ObstructionClassification
    var contradiction_proved: Bool

    fn __init__(
        inout self,
        claim: PersistentNonSeparationClaim,
        obstruction: ObstructionClassification,
        contradiction_proved: Bool,
    ):
        self.claim = claim
        self.obstruction = obstruction
        self.contradiction_proved = contradiction_proved

    fn accepted_for_F1_attack(self) -> Bool:
        if not self.claim.accepted_as_frontier_hypothesis():
            return False
        if not self.obstruction.has_candidate():
            return False
        # The frontier record is allowed before contradiction is proved.  A true
        # contradiction flag marks progress, but it is not required to record the
        # obstruction candidate.
        return True

    fn proves_C1(self) -> Bool:
        return False


fn demo_valid_persistent_nonseparation_frontier_record() -> Bool:
    var pair = IncidencePair("A", "B")
    var claim = PersistentNonSeparationClaim(pair, True, False, False, False, False)
    var obstruction = ObstructionClassification(True, False, False, False)
    var record = PersistentNonSeparationFrontierRecord(claim, obstruction, False)
    return record.accepted_for_F1_attack() and not record.proves_C1()


fn demo_rejects_bounded_same_fiber_shortcut() -> Bool:
    var pair = IncidencePair("A", "B")
    var claim = PersistentNonSeparationClaim(pair, True, True, True, False, False)
    var obstruction = ObstructionClassification(True, False, False, False)
    var record = PersistentNonSeparationFrontierRecord(claim, obstruction, False)
    return not record.accepted_for_F1_attack()
