# Internal final proof-object skeleton for the priority conjecture.
#
# This module is deliberately finite and syntactic. It records which checked
# blocks must be present before the final theorem status may be accepted.

struct C1FinalProofObject(ImplicitlyCopyable):
    var separator_catalogue_soundness_checked: Bool
    var separator_catalogue_completeness_checked: Bool
    var fiber_definition_adapter_checked: Bool
    var residual_closure_no_missing_links_checked: Bool
    var exit_closure_checked: Bool
    var boundary_equality_soundness_checked: Bool
    var theorem_tag_import_soundness_checked: Bool
    var covered_domain_declared: Bool
    var missing_link_exit_absent: Bool
    var imported_theorem_tags_checked: Bool
    var no_bounded_search_shortcut_used: Bool
    var no_rank2_locus_primitive_used: Bool
    var no_label_only_equality_used: Bool

    def __init__(
        out self,
        separator_catalogue_soundness_checked: Bool,
        separator_catalogue_completeness_checked: Bool,
        fiber_definition_adapter_checked: Bool,
        residual_closure_no_missing_links_checked: Bool,
        exit_closure_checked: Bool,
        boundary_equality_soundness_checked: Bool,
        theorem_tag_import_soundness_checked: Bool,
        covered_domain_declared: Bool,
        missing_link_exit_absent: Bool,
        imported_theorem_tags_checked: Bool,
        no_bounded_search_shortcut_used: Bool,
        no_rank2_locus_primitive_used: Bool,
        no_label_only_equality_used: Bool,
    ):
        self.separator_catalogue_soundness_checked = separator_catalogue_soundness_checked
        self.separator_catalogue_completeness_checked = separator_catalogue_completeness_checked
        self.fiber_definition_adapter_checked = fiber_definition_adapter_checked
        self.residual_closure_no_missing_links_checked = residual_closure_no_missing_links_checked
        self.exit_closure_checked = exit_closure_checked
        self.boundary_equality_soundness_checked = boundary_equality_soundness_checked
        self.theorem_tag_import_soundness_checked = theorem_tag_import_soundness_checked
        self.covered_domain_declared = covered_domain_declared
        self.missing_link_exit_absent = missing_link_exit_absent
        self.imported_theorem_tags_checked = imported_theorem_tags_checked
        self.no_bounded_search_shortcut_used = no_bounded_search_shortcut_used
        self.no_rank2_locus_primitive_used = no_rank2_locus_primitive_used
        self.no_label_only_equality_used = no_label_only_equality_used


struct FinalProofAcceptancePolicy(ImplicitlyCopyable):
    var rejects_missing_link_exit: Bool
    var requires_covered_domain: Bool
    var rejects_bounded_search_shortcut: Bool
    var rejects_rank2_locus_primitive: Bool
    var rejects_label_only_equality: Bool
    var reproves_imported_analytic_theorems: Bool
    var skeleton_alone_proves_c1: Bool

    def __init__(out self, rejects_missing_link_exit: Bool, requires_covered_domain: Bool, rejects_bounded_search_shortcut: Bool, rejects_rank2_locus_primitive: Bool, rejects_label_only_equality: Bool, reproves_imported_analytic_theorems: Bool, skeleton_alone_proves_c1: Bool):
        self.rejects_missing_link_exit = rejects_missing_link_exit
        self.requires_covered_domain = requires_covered_domain
        self.rejects_bounded_search_shortcut = rejects_bounded_search_shortcut
        self.rejects_rank2_locus_primitive = rejects_rank2_locus_primitive
        self.rejects_label_only_equality = rejects_label_only_equality
        self.reproves_imported_analytic_theorems = reproves_imported_analytic_theorems
        self.skeleton_alone_proves_c1 = skeleton_alone_proves_c1


def canonical_final_proof_acceptance_policy() -> FinalProofAcceptancePolicy:
    return FinalProofAcceptancePolicy(True, True, True, True, True, False, False)


def final_proof_acceptance_policy_valid(policy: FinalProofAcceptancePolicy) -> Bool:
    return (
        policy.rejects_missing_link_exit and policy.requires_covered_domain and
        policy.rejects_bounded_search_shortcut and
        policy.rejects_rank2_locus_primitive and
        policy.rejects_label_only_equality and
        not policy.reproves_imported_analytic_theorems and
        not policy.skeleton_alone_proves_c1
    )


def all_required_blocks_checked(proof: C1FinalProofObject) -> Bool:
    return (
        proof.separator_catalogue_soundness_checked and
        proof.separator_catalogue_completeness_checked and
        proof.fiber_definition_adapter_checked and
        proof.residual_closure_no_missing_links_checked and
        proof.exit_closure_checked and
        proof.boundary_equality_soundness_checked and
        proof.theorem_tag_import_soundness_checked
    )


def all_final_guards_checked(proof: C1FinalProofObject) -> Bool:
    return (
        proof.covered_domain_declared and
        proof.missing_link_exit_absent and
        proof.imported_theorem_tags_checked and
        proof.no_bounded_search_shortcut_used and
        proof.no_rank2_locus_primitive_used and
        proof.no_label_only_equality_used
    )


def accepts_c1_final_proof_object(proof: C1FinalProofObject) -> Bool:
    return all_required_blocks_checked(proof) and all_final_guards_checked(proof)


def rejects_missing_link_final_exit(policy: FinalProofAcceptancePolicy) -> Bool:
    return policy.rejects_missing_link_exit


def final_proof_requires_covered_domain(policy: FinalProofAcceptancePolicy) -> Bool:
    return policy.requires_covered_domain


def final_proof_rejects_bounded_search_shortcut(policy: FinalProofAcceptancePolicy) -> Bool:
    return policy.rejects_bounded_search_shortcut


def final_proof_rejects_rank2_locus_primitive(policy: FinalProofAcceptancePolicy) -> Bool:
    return policy.rejects_rank2_locus_primitive


def final_proof_rejects_label_only_equality(policy: FinalProofAcceptancePolicy) -> Bool:
    return policy.rejects_label_only_equality


def final_proof_reproves_imported_analytic_theorems(policy: FinalProofAcceptancePolicy) -> Bool:
    return policy.reproves_imported_analytic_theorems


def skeleton_alone_proves_c1(policy: FinalProofAcceptancePolicy) -> Bool:
    return policy.skeleton_alone_proves_c1


def next_priority_target() -> String:
    return "FinalProofBlockLedger"
