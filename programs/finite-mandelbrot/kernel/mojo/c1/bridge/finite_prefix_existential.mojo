# C1_finite_prefix_existential.mojo
#
# FinitePrefixToExistentialSeparation scaffold.
#
# This layer introduces an existential finite-separation witness from a concrete
# catalogue prefix witness.  It does not prove fair enumeration, catalogue
# completeness, MLC, or generic fiber triviality.


struct PrefixSeparatorRecord:
    var prefix_level: Int
    var separator_id: String
    var separator_is_admissible: Bool
    var occurs_in_prefix: Bool

    fn __init__(inout self, prefix_level: Int, separator_id: String,
                separator_is_admissible: Bool, occurs_in_prefix: Bool):
        self.prefix_level = prefix_level
        self.separator_id = separator_id
        self.separator_is_admissible = separator_is_admissible
        self.occurs_in_prefix = occurs_in_prefix

    fn accepted(self) -> Bool:
        return self.prefix_level >= 0 and self.separator_is_admissible and self.occurs_in_prefix


struct PrefixSideWitness:
    var object_ref: String
    var separator_id: String
    var side_label: String
    var local_witness_accepted: Bool

    fn __init__(inout self, object_ref: String, separator_id: String,
                side_label: String, local_witness_accepted: Bool):
        self.object_ref = object_ref
        self.separator_id = separator_id
        self.side_label = side_label
        self.local_witness_accepted = local_witness_accepted

    fn is_open_side(self) -> Bool:
        return self.side_label == "Left" or self.side_label == "Right"

    fn accepted_for_separator(self, separator_id: String) -> Bool:
        return self.local_witness_accepted and self.separator_id == separator_id and self.is_open_side()


struct ExistentialSeparationWitness:
    var exists_finite_separation: Bool
    var witness_prefix_level: Int
    var separator_id: String
    var left_object_ref: String
    var right_object_ref: String
    var claims_catalogue_completeness: Bool
    var claims_global_same_fiber: Bool
    var claims_mlc: Bool

    fn __init__(inout self, exists_finite_separation: Bool, witness_prefix_level: Int,
                separator_id: String, left_object_ref: String, right_object_ref: String,
                claims_catalogue_completeness: Bool, claims_global_same_fiber: Bool,
                claims_mlc: Bool):
        self.exists_finite_separation = exists_finite_separation
        self.witness_prefix_level = witness_prefix_level
        self.separator_id = separator_id
        self.left_object_ref = left_object_ref
        self.right_object_ref = right_object_ref
        self.claims_catalogue_completeness = claims_catalogue_completeness
        self.claims_global_same_fiber = claims_global_same_fiber
        self.claims_mlc = claims_mlc

    fn is_local_only(self) -> Bool:
        return not self.claims_catalogue_completeness and not self.claims_global_same_fiber and not self.claims_mlc

    fn accepted(self) -> Bool:
        return self.exists_finite_separation and self.is_local_only()


fn opposite_open_sides(a: PrefixSideWitness, b: PrefixSideWitness) -> Bool:
    if not a.is_open_side() or not b.is_open_side():
        return False
    return a.side_label != b.side_label


fn prefix_to_existential_separation(prefix: PrefixSeparatorRecord,
                                    a: PrefixSideWitness,
                                    b: PrefixSideWitness) -> ExistentialSeparationWitness:
    let same_separator = a.separator_id == prefix.separator_id and b.separator_id == prefix.separator_id
    let distinct_objects = a.object_ref != b.object_ref
    let accepted_sides = a.accepted_for_separator(prefix.separator_id) and b.accepted_for_separator(prefix.separator_id)
    let ok = prefix.accepted() and same_separator and distinct_objects and accepted_sides and opposite_open_sides(a, b)

    return ExistentialSeparationWitness(
        ok,
        prefix.prefix_level,
        prefix.separator_id,
        a.object_ref,
        b.object_ref,
        False,
        False,
        False,
    )


fn demo_prefix_to_existential_accepts() -> Bool:
    let prefix = PrefixSeparatorRecord(7, "sep:1/3-2/3", True, True)
    let a = PrefixSideWitness("inc:A", "sep:1/3-2/3", "Left", True)
    let b = PrefixSideWitness("inc:B", "sep:1/3-2/3", "Right", True)
    return prefix_to_existential_separation(prefix, a, b).accepted()


fn demo_missing_prefix_rejects() -> Bool:
    let prefix = PrefixSeparatorRecord(7, "sep:1/3-2/3", True, False)
    let a = PrefixSideWitness("inc:A", "sep:1/3-2/3", "Left", True)
    let b = PrefixSideWitness("inc:B", "sep:1/3-2/3", "Right", True)
    return not prefix_to_existential_separation(prefix, a, b).accepted()


fn demo_on_separator_rejects_existential() -> Bool:
    let prefix = PrefixSeparatorRecord(7, "sep:1/3-2/3", True, True)
    let a = PrefixSideWitness("inc:A", "sep:1/3-2/3", "OnSeparator", True)
    let b = PrefixSideWitness("inc:B", "sep:1/3-2/3", "Right", True)
    return not prefix_to_existential_separation(prefix, a, b).accepted()


fn demo_same_side_rejects_existential() -> Bool:
    let prefix = PrefixSeparatorRecord(7, "sep:1/3-2/3", True, True)
    let a = PrefixSideWitness("inc:A", "sep:1/3-2/3", "Left", True)
    let b = PrefixSideWitness("inc:B", "sep:1/3-2/3", "Left", True)
    return not prefix_to_existential_separation(prefix, a, b).accepted()


fn generic_same_fiber_not_claimed() -> Bool:
    let prefix = PrefixSeparatorRecord(7, "sep:1/3-2/3", True, True)
    let a = PrefixSideWitness("inc:A", "sep:1/3-2/3", "Left", True)
    let b = PrefixSideWitness("inc:B", "sep:1/3-2/3", "Right", True)
    let w = prefix_to_existential_separation(prefix, a, b)
    return w.accepted() and not w.claims_global_same_fiber and not w.claims_mlc
