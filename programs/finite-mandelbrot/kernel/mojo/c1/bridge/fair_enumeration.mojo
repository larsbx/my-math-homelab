# C1_fair_enumeration.mojo
#
# Finite scaffold for the FairEnumerationLemma in C1.
#
# Goal: every finite admissible rational-ray separation-line code appears in
# some finite catalogue prefix Cat_k. This is representation/exhaustion only.
# It does not prove MLC, generic singleton fibers, or geometric shrinking.

from c1.bridge.bridge import IncidenceObjectRef


struct SeparationLineCode:
    var code_id: String
    var rational_ray_code: Bool
    var landing_tags_present: Bool
    var side_predicate_code_present: Bool
    var incidence_refs_present: Bool

    fn __init__(inout self, code_id: String, rational_ray_code: Bool, landing_tags_present: Bool, side_predicate_code_present: Bool, incidence_refs_present: Bool):
        self.code_id = code_id
        self.rational_ray_code = rational_ray_code
        self.landing_tags_present = landing_tags_present
        self.side_predicate_code_present = side_predicate_code_present
        self.incidence_refs_present = incidence_refs_present

    fn admissible(self) -> Bool:
        return (
            self.rational_ray_code and
            self.landing_tags_present and
            self.side_predicate_code_present and
            self.incidence_refs_present
        )


struct CataloguePrefix:
    var depth: Int
    var enumeration_is_fair_prefix: Bool
    var contains_target_code: Bool

    fn __init__(inout self, depth: Int, enumeration_is_fair_prefix: Bool, contains_target_code: Bool):
        self.depth = depth
        self.enumeration_is_fair_prefix = enumeration_is_fair_prefix
        self.contains_target_code = contains_target_code

    fn witnesses_target(self) -> Bool:
        return self.depth >= 0 and self.enumeration_is_fair_prefix and self.contains_target_code


struct FairEnumerationWitness:
    var target: SeparationLineCode
    var prefix: CataloguePrefix
    var claims_only_enumeration: Bool
    var claims_no_generic_stabilization: Bool

    fn __init__(inout self, target: SeparationLineCode, prefix: CataloguePrefix, claims_only_enumeration: Bool, claims_no_generic_stabilization: Bool):
        self.target = target
        self.prefix = prefix
        self.claims_only_enumeration = claims_only_enumeration
        self.claims_no_generic_stabilization = claims_no_generic_stabilization

    fn accepted(self) -> Bool:
        return (
            self.target.admissible() and
            self.prefix.witnesses_target() and
            self.claims_only_enumeration and
            self.claims_no_generic_stabilization
        )


fn demo_admissible_separator_code() -> SeparationLineCode:
    return SeparationLineCode("sep_line_qray_pair_demo", True, True, True, True)


fn demo_fair_prefix_contains_separator() -> CataloguePrefix:
    return CataloguePrefix(12, True, True)


fn demo_fair_enumeration_witness() -> FairEnumerationWitness:
    return FairEnumerationWitness(
        demo_admissible_separator_code(),
        demo_fair_prefix_contains_separator(),
        True,
        True,
    )


fn must_reject_non_admissible_code() -> Bool:
    var bad = SeparationLineCode("bad_missing_landing_tag", True, False, True, True)
    var prefix = demo_fair_prefix_contains_separator()
    var witness = FairEnumerationWitness(bad, prefix, True, True)
    return not witness.accepted()


fn must_reject_generic_stabilization_claim() -> Bool:
    var witness = FairEnumerationWitness(
        demo_admissible_separator_code(),
        demo_fair_prefix_contains_separator(),
        True,
        False,
    )
    return not witness.accepted()
