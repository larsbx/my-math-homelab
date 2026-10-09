# C1_finite_separation.mojo
#
# Finite separation predicate for the C1 bridge.
#
# Scope: finite prefix separation only. This module does not claim generic
# stabilization, MLC, or analytic singleton membership.

from c1.separator.separator_codes import SeparatorCode, code_admissible, fair_enumeration_claims_stabilization
from c1.bridge.bridge import IncidenceObjectRef


alias LeftSide = "LeftSide"
alias RightSide = "RightSide"


struct SideAssignment:
    var object_ref: IncidenceObjectRef
    var separator: SeparatorCode
    var side: String
    var finite_witness_present: Bool

    fn __init__(inout self, object_ref: IncidenceObjectRef, separator: SeparatorCode, side: String, finite_witness_present: Bool):
        self.object_ref = object_ref
        self.separator = separator
        self.side = side
        self.finite_witness_present = finite_witness_present

    fn valid_side(self) -> Bool:
        return self.side == LeftSide or self.side == RightSide

    fn valid(self) -> Bool:
        return self.object_ref.valid() and code_admissible(self.separator) and self.valid_side() and self.finite_witness_present


struct SeparationWitness:
    var separator: SeparatorCode
    var left: SideAssignment
    var right: SideAssignment
    var in_catalogue_prefix: Bool

    fn __init__(inout self, separator: SeparatorCode, left: SideAssignment, right: SideAssignment, in_catalogue_prefix: Bool):
        self.separator = separator
        self.left = left
        self.right = right
        self.in_catalogue_prefix = in_catalogue_prefix

    fn sides_distinct(self) -> Bool:
        return self.left.side != self.right.side

    fn same_separator(self) -> Bool:
        return self.left.separator.tag == self.separator.tag and self.right.separator.tag == self.separator.tag

    fn separates(self) -> Bool:
        return (
            self.in_catalogue_prefix and
            code_admissible(self.separator) and
            self.left.valid() and
            self.right.valid() and
            self.same_separator() and
            self.sides_distinct()
        )


struct SameFiberPrefixStatus:
    var prefix_index: Int
    var separated: Bool
    var finite_prefix_only: Bool

    fn __init__(inout self, prefix_index: Int, separated: Bool, finite_prefix_only: Bool):
        self.prefix_index = prefix_index
        self.separated = separated
        self.finite_prefix_only = finite_prefix_only

    fn same_fiber_prefix(self) -> Bool:
        return self.finite_prefix_only and not self.separated

    fn claims_classical_same_fiber(self) -> Bool:
        return False


fn separated_k(witness: SeparationWitness) -> Bool:
    return witness.separates()


fn same_fiber_prefix_k(prefix_index: Int, witness: SeparationWitness) -> SameFiberPrefixStatus:
    return SameFiberPrefixStatus(prefix_index, not separated_k(witness), True)


fn finite_prefix_nonseparation_claims_stabilization() -> Bool:
    return False


fn demo_valid_two_side_separation() -> Bool:
    var a = IncidenceObjectRef("PointVertex", "A")
    var b = IncidenceObjectRef("PointVertex", "B")
    var s = SeparatorCode("RationalRayLanding", 1, 3, 2, 3)
    var left = SideAssignment(a, s, LeftSide, True)
    var right = SideAssignment(b, s, RightSide, True)
    var w = SeparationWitness(s, left, right, True)
    return separated_k(w)


fn demo_reject_same_side() -> Bool:
    var a = IncidenceObjectRef("PointVertex", "A")
    var b = IncidenceObjectRef("PointVertex", "B")
    var s = SeparatorCode("RationalRayLanding", 1, 3, 2, 3)
    var left = SideAssignment(a, s, LeftSide, True)
    var also_left = SideAssignment(b, s, LeftSide, True)
    var w = SeparationWitness(s, left, also_left, True)
    return not separated_k(w)


fn demo_reject_generic_separator() -> Bool:
    var a = IncidenceObjectRef("PointVertex", "A")
    var b = IncidenceObjectRef("PointVertex", "B")
    var s = SeparatorCode("GenericBoundaryLanding", 1, 3, 2, 3)
    var left = SideAssignment(a, s, LeftSide, True)
    var right = SideAssignment(b, s, RightSide, True)
    var w = SeparationWitness(s, left, right, True)
    return not separated_k(w)
