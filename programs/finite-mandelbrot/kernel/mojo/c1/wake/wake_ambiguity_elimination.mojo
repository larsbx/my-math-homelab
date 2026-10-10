# C1_wake_ambiguity_elimination.mojo
#
# Frontier scaffold for eliminating persistent wake ambiguity.
#
# Rank-2 ontology invariant:
# - no circle primitive;
# - no unit-circle primitive;
# - no rank-2 locus primitive;
# - only finite address, incidence, theorem-tag, and carrier records.

struct WakeAmbiguitySubcase:
    var boundary_equality: Bool
    var conflicting_assignments: Bool
    var both_unresolved: Bool
    var missing_landing_tag: Bool

    fn __init__(inout self, boundary_equality: Bool, conflicting_assignments: Bool, both_unresolved: Bool, missing_landing_tag: Bool):
        self.boundary_equality = boundary_equality
        self.conflicting_assignments = conflicting_assignments
        self.both_unresolved = both_unresolved
        self.missing_landing_tag = missing_landing_tag

    fn has_named_subcase(self) -> Bool:
        return self.boundary_equality or self.conflicting_assignments or self.both_unresolved or self.missing_landing_tag

    fn exactly_one_subcase(self) -> Bool:
        var count = 0
        if self.boundary_equality:
            count += 1
        if self.conflicting_assignments:
            count += 1
        if self.both_unresolved:
            count += 1
        if self.missing_landing_tag:
            count += 1
        return count == 1


struct WakeEliminationOutcome:
    var contradiction: Bool
    var established_trivial_family: Bool
    var nonshrinking_carrier: Bool
    var missing_classical_input: Bool
    var proof_complete: Bool

    fn __init__(inout self, contradiction: Bool, established_trivial_family: Bool, nonshrinking_carrier: Bool, missing_classical_input: Bool, proof_complete: Bool):
        self.contradiction = contradiction
        self.established_trivial_family = established_trivial_family
        self.nonshrinking_carrier = nonshrinking_carrier
        self.missing_classical_input = missing_classical_input
        self.proof_complete = proof_complete

    fn is_valid_frontier_outcome(self) -> Bool:
        return self.contradiction or self.established_trivial_family or self.nonshrinking_carrier or self.missing_classical_input

    fn proves_c1(self) -> Bool:
        # This scaffold never proves C1 by itself.
        return False


fn boundary_equality_refinement_pending() -> Bool:
    return True

fn conflicting_wake_collapse_pending() -> Bool:
    return True

fn unresolved_wake_to_carrier_obstruction_pending() -> Bool:
    return True

fn missing_landing_tag_reroute_pending() -> Bool:
    return True

fn no_residual_wake_ambiguity_pending() -> Bool:
    return True

fn all_elimination_sublemmas_pending() -> Bool:
    return boundary_equality_refinement_pending() and conflicting_wake_collapse_pending() and unresolved_wake_to_carrier_obstruction_pending() and missing_landing_tag_reroute_pending() and no_residual_wake_ambiguity_pending()

fn classify_wake_ambiguity(subcase: WakeAmbiguitySubcase) -> WakeEliminationOutcome:
    if not subcase.has_named_subcase():
        return WakeEliminationOutcome(False, False, False, True, False)
    if not subcase.exactly_one_subcase():
        return WakeEliminationOutcome(False, False, False, True, False)
    if subcase.boundary_equality:
        return WakeEliminationOutcome(False, True, False, False, False)
    if subcase.conflicting_assignments:
        return WakeEliminationOutcome(True, False, False, False, False)
    if subcase.both_unresolved:
        return WakeEliminationOutcome(False, False, True, False, False)
    if subcase.missing_landing_tag:
        return WakeEliminationOutcome(False, False, False, True, False)
    return WakeEliminationOutcome(False, False, False, True, False)

fn strongest_elimination_available() -> Bool:
    # The strongest target would make persistent wake ambiguity impossible.
    # It is not yet available.
    return False

fn rank2_circle_primitive_available() -> Bool:
    return False
