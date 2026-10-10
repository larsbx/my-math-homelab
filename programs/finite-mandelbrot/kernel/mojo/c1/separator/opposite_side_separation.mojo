# C1_opposite_side_separation.mojo
#
# Finite scaffold for OppositeSideSeparationSoundness.
# This module composes accepted side-assignment witnesses for one admissible
# separator. It does not prove catalogue completeness, MLC, or generic
# stabilization.

struct OppositeSideInput:
    var separator_id: String
    var left_object_id: String
    var right_object_id: String
    var first_side: String
    var second_side: String
    var first_assignment_accepted: Bool
    var second_assignment_accepted: Bool
    var separator_admissible: Bool
    var theorem_tag_bound: Bool

    fn __init__(inout self, separator_id: String, left_object_id: String, right_object_id: String, first_side: String, second_side: String, first_assignment_accepted: Bool, second_assignment_accepted: Bool, separator_admissible: Bool, theorem_tag_bound: Bool):
        self.separator_id = separator_id
        self.left_object_id = left_object_id
        self.right_object_id = right_object_id
        self.first_side = first_side
        self.second_side = second_side
        self.first_assignment_accepted = first_assignment_accepted
        self.second_assignment_accepted = second_assignment_accepted
        self.separator_admissible = separator_admissible
        self.theorem_tag_bound = theorem_tag_bound

fn is_open_side(side: String) -> Bool:
    return side == "Left" or side == "Right"

fn opposite_open_sides(a: String, b: String) -> Bool:
    if a == "Left" and b == "Right":
        return True
    if a == "Right" and b == "Left":
        return True
    return False

fn on_separator_case(a: String, b: String) -> Bool:
    return a == "OnSeparator" or b == "OnSeparator"

fn opposite_side_checks_accept(input: OppositeSideInput) -> Bool:
    if input.separator_id == "":
        return False
    if input.left_object_id == "" or input.right_object_id == "":
        return False
    if input.left_object_id == input.right_object_id:
        return False
    if not input.first_assignment_accepted:
        return False
    if not input.second_assignment_accepted:
        return False
    if not input.separator_admissible:
        return False
    if not input.theorem_tag_bound:
        return False
    if on_separator_case(input.first_side, input.second_side):
        return False
    if not is_open_side(input.first_side):
        return False
    if not is_open_side(input.second_side):
        return False
    return opposite_open_sides(input.first_side, input.second_side)

struct OppositeSideSoundnessStatus:
    var finite_checks_accept: Bool
    var classical_conclusion_available: Bool
    var needs_side_assignment_soundness: Bool
    var needs_separator_admissibility_soundness: Bool
    var claims_generic_stabilization: Bool

    fn __init__(inout self, finite_checks_accept: Bool, classical_conclusion_available: Bool, needs_side_assignment_soundness: Bool, needs_separator_admissibility_soundness: Bool, claims_generic_stabilization: Bool):
        self.finite_checks_accept = finite_checks_accept
        self.classical_conclusion_available = classical_conclusion_available
        self.needs_side_assignment_soundness = needs_side_assignment_soundness
        self.needs_separator_admissibility_soundness = needs_separator_admissibility_soundness
        self.claims_generic_stabilization = claims_generic_stabilization

fn status_for_opposite_side_input(input: OppositeSideInput) -> OppositeSideSoundnessStatus:
    let accepts = opposite_side_checks_accept(input)
    return OppositeSideSoundnessStatus(
        accepts,
        False,
        True,
        True,
        False,
    )

fn demo_valid_opposite_sides_pending_soundness() -> Bool:
    let input = OppositeSideInput("sep:rays:1/3:2/3", "inc:A", "inc:B", "Left", "Right", True, True, True, True)
    let status = status_for_opposite_side_input(input)
    return status.finite_checks_accept and not status.classical_conclusion_available and status.needs_side_assignment_soundness and not status.claims_generic_stabilization

fn demo_same_side_rejected() -> Bool:
    let input = OppositeSideInput("sep:rays:1/3:2/3", "inc:A", "inc:B", "Left", "Left", True, True, True, True)
    return not opposite_side_checks_accept(input)

fn demo_on_separator_rejected() -> Bool:
    let input = OppositeSideInput("sep:rays:1/3:2/3", "inc:A", "inc:B", "OnSeparator", "Right", True, True, True, True)
    return not opposite_side_checks_accept(input)
