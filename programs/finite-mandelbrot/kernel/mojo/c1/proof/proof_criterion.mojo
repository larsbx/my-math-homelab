# C1 proof criterion and priority status.
#
# This module makes docs/C1_proof_definition_and_priority.md visible to the
# Mojo theorem-kernel layer. It is intentionally finite and explicit.

struct C1RequiredBlock:
    var name: String
    var required: Bool
    var discharged: Bool
    var open_frontier: Bool

    fn __init__(inout self, name: String, required: Bool, discharged: Bool, open_frontier: Bool):
        self.name = name
        self.required = required
        self.discharged = discharged
        self.open_frontier = open_frontier


struct C1ProofCriterionStatus:
    var priority: String
    var c1_proved: Bool
    var missing_link_exit_allowed_in_final_proof: Bool
    var mojo_theorem_kernel_required: Bool
    var theorem_tag_import_validation_required: Bool
    var bounded_search_sufficient: Bool

    fn __init__(inout self, priority: String, c1_proved: Bool, missing_link_exit_allowed_in_final_proof: Bool, mojo_theorem_kernel_required: Bool, theorem_tag_import_validation_required: Bool, bounded_search_sufficient: Bool):
        self.priority = priority
        self.c1_proved = c1_proved
        self.missing_link_exit_allowed_in_final_proof = missing_link_exit_allowed_in_final_proof
        self.mojo_theorem_kernel_required = mojo_theorem_kernel_required
        self.theorem_tag_import_validation_required = theorem_tag_import_validation_required
        self.bounded_search_sufficient = bounded_search_sufficient


fn c1_priority() -> String:
    return "PRIORITY_ZERO"


fn c1_target_statement() -> String:
    return "A != B => exists k. Separated_k(A,B)"


fn c1_dual_statement() -> String:
    return "forall k. not Separated_k(A,B) => BoundaryEquality(A,B)"


fn separator_catalogue_soundness_block() -> C1RequiredBlock:
    return C1RequiredBlock("SeparatorCatalogueSoundness", True, False, False)


fn separator_catalogue_completeness_block() -> C1RequiredBlock:
    return C1RequiredBlock("SeparatorCatalogueCompleteness", True, False, False)


fn separator_catalogue_adequacy_block() -> C1RequiredBlock:
    return C1RequiredBlock("SeparatorCatalogueAdequacy", True, False, False)


fn fiber_definition_adapter_block() -> C1RequiredBlock:
    return C1RequiredBlock("FiberDefinitionAdapter", True, False, False)


fn residual_closure_no_missing_links_block() -> C1RequiredBlock:
    return C1RequiredBlock("ResidualClosureNoMissingLinks", True, False, True)


fn exit_closure_for_c1_block() -> C1RequiredBlock:
    return C1RequiredBlock("ExitClosureForC1", True, False, False)


fn c1_final_proof_object_block() -> C1RequiredBlock:
    return C1RequiredBlock("C1FinalProofObject", True, False, False)


fn c1_status() -> C1ProofCriterionStatus:
    return C1ProofCriterionStatus(
        c1_priority(),
        False,  # C1 is not proved yet.
        False,  # final proof may not leave MissingTheoremCatalogueLink open.
        True,   # final certificate must be Mojo theorem-kernel checked.
        True,   # theorem-tag imports require assumption validation.
        False,  # bounded search is never sufficient.
    )


fn highest_priority_open_block() -> String:
    return "ResidualClosureNoMissingLinks"


fn second_priority_open_block() -> String:
    return "SeparatorCatalogueAdequacyProofObjects"


fn third_priority_open_block() -> String:
    return "FiberDefinitionAdapterProofObject"


fn final_priority_open_block() -> String:
    return "C1FinalProofObject"


fn c1_completion_requires_all_blocks() -> Bool:
    return True


fn c1_completion_allows_missing_link_exit() -> Bool:
    return False


fn mojo_kernel_must_check_final_proof_object() -> Bool:
    return True


fn rank2_circle_primitive_available_for_c1() -> Bool:
    return False
