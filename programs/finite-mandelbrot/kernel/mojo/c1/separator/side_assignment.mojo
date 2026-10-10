# C1_side_assignment.mojo
#
# Finite side-assignment witness scaffold for C1.
#
# A side assignment is not analytic region membership. It is finite evidence that
# an incidence object is assigned to one side of an admissible rational-ray
# separator code.

from c1.separator.separator_codes import SeparatorCode, accepted_two_ray_separator, rejected_generic_separator


struct IncidenceRefLite:
    var tag: String
    var id: String

    fn __init__(inout self, tag: String, id: String):
        self.tag = tag
        self.id = id

    fn valid(self) -> Bool:
        return self.tag != "" and self.id != ""


struct SideLabel:
    var name: String

    fn __init__(inout self, name: String):
        self.name = name

    fn is_left(self) -> Bool:
        return self.name == "Left"

    fn is_right(self) -> Bool:
        return self.name == "Right"

    fn is_on_separator(self) -> Bool:
        return self.name == "OnSeparator"

    fn separation_side(self) -> Bool:
        return self.is_left() or self.is_right()


struct SideEvidence:
    var kind: String
    var uses_only_finite_addresses: Bool
    var theorem_tag_allowed: Bool

    fn __init__(inout self, kind: String, uses_only_finite_addresses: Bool, theorem_tag_allowed: Bool):
        self.kind = kind
        self.uses_only_finite_addresses = uses_only_finite_addresses
        self.theorem_tag_allowed = theorem_tag_allowed

    fn valid(self) -> Bool:
        return (
            (self.kind == "RayOrder" or self.kind == "WakeMembership" or self.kind == "ComponentBoundaryTag") and
            self.uses_only_finite_addresses and
            self.theorem_tag_allowed
        )


struct SideAssignmentWitness:
    var object_ref: IncidenceRefLite
    var separator: SeparatorCode
    var side: SideLabel
    var evidence: SideEvidence

    fn __init__(inout self, object_ref: IncidenceRefLite, separator: SeparatorCode, side: SideLabel, evidence: SideEvidence):
        self.object_ref = object_ref
        self.separator = separator
        self.side = side
        self.evidence = evidence

    fn valid_for_separation(self) -> Bool:
        return (
            self.object_ref.valid() and
            self.separator.admissible() and
            self.side.separation_side() and
            self.evidence.valid()
        )

    fn structural_on_separator(self) -> Bool:
        return (
            self.object_ref.valid() and
            self.separator.admissible() and
            self.side.is_on_separator() and
            self.evidence.valid()
        )


fn opposite_separation_sides(a: SideAssignmentWitness, b: SideAssignmentWitness) -> Bool:
    return (a.side.is_left() and b.side.is_right()) or (a.side.is_right() and b.side.is_left())


fn same_separator(a: SideAssignmentWitness, b: SideAssignmentWitness) -> Bool:
    return a.separator.code_id == b.separator.code_id


fn separated_by_side_assignments(a: SideAssignmentWitness, b: SideAssignmentWitness) -> Bool:
    return (
        a.valid_for_separation() and
        b.valid_for_separation() and
        same_separator(a, b) and
        opposite_separation_sides(a, b)
    )


fn demo_ray_order_evidence() -> SideEvidence:
    return SideEvidence("RayOrder", True, True)


fn demo_left_assignment() -> SideAssignmentWitness:
    return SideAssignmentWitness(
        IncidenceRefLite("PointVertex", "A"),
        accepted_two_ray_separator(),
        SideLabel("Left"),
        demo_ray_order_evidence(),
    )


fn demo_right_assignment() -> SideAssignmentWitness:
    return SideAssignmentWitness(
        IncidenceRefLite("PointVertex", "B"),
        accepted_two_ray_separator(),
        SideLabel("Right"),
        demo_ray_order_evidence(),
    )


fn demo_on_separator_rejected_for_separation() -> Bool:
    var a = SideAssignmentWitness(
        IncidenceRefLite("PointVertex", "A"),
        accepted_two_ray_separator(),
        SideLabel("OnSeparator"),
        demo_ray_order_evidence(),
    )
    var b = demo_right_assignment()
    return not separated_by_side_assignments(a, b)


fn demo_generic_separator_rejected_for_side_assignment() -> Bool:
    var a = SideAssignmentWitness(
        IncidenceRefLite("PointVertex", "A"),
        rejected_generic_separator(),
        SideLabel("Left"),
        demo_ray_order_evidence(),
    )
    return not a.valid_for_separation()


fn demo_valid_opposite_side_separation() -> Bool:
    return separated_by_side_assignments(demo_left_assignment(), demo_right_assignment())
