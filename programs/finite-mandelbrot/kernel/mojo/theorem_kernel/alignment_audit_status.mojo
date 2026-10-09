# Alignment-audit status and Mojo theorem-kernel trust boundary.
# Terminology used here is governed by docs/terminology-registry.md.
#
# This module records repository status semantics. Mojo is the first-class
# execution language and the finite proof-object theorem kernel. It still does
# not re-prove imported analytic complex-dynamics theorems.

struct TheoremStatus(ImplicitlyCopyable):
    var name: String
    var proof_skeleton_present: Bool
    var local_obligations_disclosed: Bool
    var local_obligations_proved: Bool
    var open_frontier: Bool
    var mlc_strength_candidate: Bool
    var theorem_proved: Bool

    def __init__(out self, name: String, proof_skeleton_present: Bool, local_obligations_disclosed: Bool, local_obligations_proved: Bool, open_frontier: Bool, mlc_strength_candidate: Bool, theorem_proved: Bool):
        self.name = name
        self.proof_skeleton_present = proof_skeleton_present
        self.local_obligations_disclosed = local_obligations_disclosed
        self.local_obligations_proved = local_obligations_proved
        self.open_frontier = open_frontier
        self.mlc_strength_candidate = mlc_strength_candidate
        self.theorem_proved = theorem_proved


struct AlignmentPolicy(ImplicitlyCopyable):
    var mojo_first_class: Bool
    var mojo_finite_kernel: Bool
    var mojo_reproves_imports: Bool
    var theorem_tags_validated: Bool
    var bounded_search_global: Bool
    var finite_state_well_founded: Bool
    var rank2_circle_primitive: Bool
    var higher_layer_adapter_required: Bool
    var legacy_name_retired: Bool

    def __init__(out self, mojo_first_class: Bool, mojo_finite_kernel: Bool, mojo_reproves_imports: Bool, theorem_tags_validated: Bool, bounded_search_global: Bool, finite_state_well_founded: Bool, rank2_circle_primitive: Bool, higher_layer_adapter_required: Bool, legacy_name_retired: Bool):
        self.mojo_first_class = mojo_first_class
        self.mojo_finite_kernel = mojo_finite_kernel
        self.mojo_reproves_imports = mojo_reproves_imports
        self.theorem_tags_validated = theorem_tags_validated
        self.bounded_search_global = bounded_search_global
        self.finite_state_well_founded = finite_state_well_founded
        self.rank2_circle_primitive = rank2_circle_primitive
        self.higher_layer_adapter_required = higher_layer_adapter_required
        self.legacy_name_retired = legacy_name_retired


def canonical_alignment_policy() -> AlignmentPolicy:
    return AlignmentPolicy(True, True, False, True, False, False, False, True, True)


def alignment_policy_valid(policy: AlignmentPolicy) -> Bool:
    return (
        policy.mojo_first_class and policy.mojo_finite_kernel and
        not policy.mojo_reproves_imports and policy.theorem_tags_validated and
        not policy.bounded_search_global and not policy.finite_state_well_founded and
        not policy.rank2_circle_primitive and policy.higher_layer_adapter_required and
        policy.legacy_name_retired
    )


def c1_separator_catalogue_adequacy_status() -> TheoremStatus:
    return TheoremStatus(
        "SeparatorCatalogueAdequacy",
        True,   # proof skeleton exists
        True,   # local obligations are listed
        False,  # local obligations are not yet proved
        False,  # adequacy itself is bridge work, not the residual frontier
        False,
        False,
    )


def c1_residual_frontier_status() -> TheoremStatus:
    return TheoremStatus(
        "ResidualFrontierRefinement",
        True,
        True,
        False,
        True,
        True,
        False,
    )


def mojo_is_first_class_execution_language(policy: AlignmentPolicy) -> Bool:
    return policy.mojo_first_class


def mojo_is_finite_theorem_kernel(policy: AlignmentPolicy) -> Bool:
    return policy.mojo_finite_kernel


def mojo_reproves_imported_analytic_theorems(policy: AlignmentPolicy) -> Bool:
    return policy.mojo_reproves_imports


def theorem_tags_require_import_validation(policy: AlignmentPolicy) -> Bool:
    return policy.theorem_tags_validated


def bounded_search_proves_global_termination(policy: AlignmentPolicy) -> Bool:
    return policy.bounded_search_global


def finite_state_alone_proves_well_foundedness(policy: AlignmentPolicy) -> Bool:
    return policy.finite_state_well_founded


def rank2_circle_primitive_available(policy: AlignmentPolicy) -> Bool:
    return policy.rank2_circle_primitive


def rank2_higher_layer_adapter_required(policy: AlignmentPolicy) -> Bool:
    return policy.higher_layer_adapter_required


def legacy_catalogue_extensionality_name_retired_for_new_work(policy: AlignmentPolicy) -> Bool:
    return policy.legacy_name_retired
