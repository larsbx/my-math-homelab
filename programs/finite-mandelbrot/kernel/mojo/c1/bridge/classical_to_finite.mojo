# C1_classical_to_finite.mojo
#
# Scaffold for the hard catalogue-extensionality direction:
#   classical rational-ray separation => finite existential separation witness.
#
# This module is intentionally finite and conservative. It records which local
# obligations are discharged before the direction may be accepted. It does not
# prove MLC, fiber triviality, or finite-prefix stabilization.

struct ClassicalSeparatorInput:
    var separator_id: String
    var admissible_for_fiber_definition: Bool
    var has_rational_code: Bool
    var landing_tag_allowed: Bool
    var side_witnesses_extractable: Bool
    var finite_catalogue_occurrence_known: Bool
    var claims_generic_boundary: Bool
    var claims_mlc: Bool

    fn __init__(inout self, separator_id: String, admissible_for_fiber_definition: Bool, has_rational_code: Bool, landing_tag_allowed: Bool, side_witnesses_extractable: Bool, finite_catalogue_occurrence_known: Bool, claims_generic_boundary: Bool, claims_mlc: Bool):
        self.separator_id = separator_id
        self.admissible_for_fiber_definition = admissible_for_fiber_definition
        self.has_rational_code = has_rational_code
        self.landing_tag_allowed = landing_tag_allowed
        self.side_witnesses_extractable = side_witnesses_extractable
        self.finite_catalogue_occurrence_known = finite_catalogue_occurrence_known
        self.claims_generic_boundary = claims_generic_boundary
        self.claims_mlc = claims_mlc

struct ClassicalToFiniteStatus:
    var rational_separator_coding_complete: Bool
    var landing_tag_complete: Bool
    var side_witness_extraction_complete: Bool
    var fair_enumeration_complete: Bool

    fn __init__(inout self, rational_separator_coding_complete: Bool, landing_tag_complete: Bool, side_witness_extraction_complete: Bool, fair_enumeration_complete: Bool):
        self.rational_separator_coding_complete = rational_separator_coding_complete
        self.landing_tag_complete = landing_tag_complete
        self.side_witness_extraction_complete = side_witness_extraction_complete
        self.fair_enumeration_complete = fair_enumeration_complete

    fn all_complete(self) -> Bool:
        return self.rational_separator_coding_complete and self.landing_tag_complete and self.side_witness_extraction_complete and self.fair_enumeration_complete

struct FiniteExistentialWitnessClaim:
    var accepted: Bool
    var reason: String
    var separator_id: String
    var claims_stabilization: Bool
    var claims_mlc: Bool

    fn __init__(inout self, accepted: Bool, reason: String, separator_id: String, claims_stabilization: Bool, claims_mlc: Bool):
        self.accepted = accepted
        self.reason = reason
        self.separator_id = separator_id
        self.claims_stabilization = claims_stabilization
        self.claims_mlc = claims_mlc

fn classical_to_finite_witness(input: ClassicalSeparatorInput, status: ClassicalToFiniteStatus) -> FiniteExistentialWitnessClaim:
    if input.claims_generic_boundary:
        return FiniteExistentialWitnessClaim(False, "generic boundary separator is not an admissible finite code", input.separator_id, False, False)
    if input.claims_mlc or status.all_complete() == False:
        if input.claims_mlc:
            return FiniteExistentialWitnessClaim(False, "MLC claim is outside local classical-to-finite witness", input.separator_id, False, False)
    if not input.admissible_for_fiber_definition:
        return FiniteExistentialWitnessClaim(False, "classical separator is not in the fiber-definition separator class", input.separator_id, False, False)
    if not input.has_rational_code:
        return FiniteExistentialWitnessClaim(False, "missing rational finite separator code", input.separator_id, False, False)
    if not input.landing_tag_allowed:
        return FiniteExistentialWitnessClaim(False, "landing tag is not allowed", input.separator_id, False, False)
    if not input.side_witnesses_extractable:
        return FiniteExistentialWitnessClaim(False, "side witnesses not extractable", input.separator_id, False, False)
    if not input.finite_catalogue_occurrence_known:
        return FiniteExistentialWitnessClaim(False, "finite catalogue occurrence not known", input.separator_id, False, False)
    if not status.all_complete():
        return FiniteExistentialWitnessClaim(False, "local completeness obligations are still pending", input.separator_id, False, False)
    return FiniteExistentialWitnessClaim(True, "finite existential separation witness introduced", input.separator_id, False, False)

fn demo_pending_classical_to_finite() -> FiniteExistentialWitnessClaim:
    var input = ClassicalSeparatorInput("sep:ray:1/3:2/3", True, True, True, True, True, False, False)
    var status = ClassicalToFiniteStatus(False, False, False, False)
    return classical_to_finite_witness(input, status)

fn demo_complete_classical_to_finite() -> FiniteExistentialWitnessClaim:
    var input = ClassicalSeparatorInput("sep:ray:1/3:2/3", True, True, True, True, True, False, False)
    var status = ClassicalToFiniteStatus(True, True, True, True)
    return classical_to_finite_witness(input, status)

fn demo_reject_generic_boundary() -> FiniteExistentialWitnessClaim:
    var input = ClassicalSeparatorInput("sep:generic-boundary", True, True, False, True, True, True, False)
    var status = ClassicalToFiniteStatus(True, True, True, True)
    return classical_to_finite_witness(input, status)
