# Mojo optimization contract for finite-mandlebrot-research finite computations and proof objects.
#
# Policy values are stored in explicit data and validated by the smoke kernel.

struct KernelDiscipline(ImplicitlyCopyable):
    var name: String
    var uses_value_structs: Bool
    var separates_debug_from_proof_grade: Bool
    var avoids_heap_pressure: Bool
    var batchable: Bool
    var backend_boundary_explicit: Bool

    def __init__(out self, name: String, uses_value_structs: Bool, separates_debug_from_proof_grade: Bool, avoids_heap_pressure: Bool, batchable: Bool, backend_boundary_explicit: Bool):
        self.name = name
        self.uses_value_structs = uses_value_structs
        self.separates_debug_from_proof_grade = separates_debug_from_proof_grade
        self.avoids_heap_pressure = avoids_heap_pressure
        self.batchable = batchable
        self.backend_boundary_explicit = backend_boundary_explicit


struct OptimizationPolicy(ImplicitlyCopyable):
    var computation_language: String
    var theorem_kernel_language: String
    var python_reference_allowed: Bool
    var python_primary_certificate: Bool
    var python_primary_theorem_kernel: Bool
    var horner_required: Bool
    var batchable_catalogue_required: Bool
    var deterministic_replay_required: Bool
    var theorem_tag_boundary_explicit: Bool
    var debug_proof_grade: Bool

    def __init__(out self, computation_language: String, theorem_kernel_language: String, python_reference_allowed: Bool, python_primary_certificate: Bool, python_primary_theorem_kernel: Bool, horner_required: Bool, batchable_catalogue_required: Bool, deterministic_replay_required: Bool, theorem_tag_boundary_explicit: Bool, debug_proof_grade: Bool):
        self.computation_language = computation_language
        self.theorem_kernel_language = theorem_kernel_language
        self.python_reference_allowed = python_reference_allowed
        self.python_primary_certificate = python_primary_certificate
        self.python_primary_theorem_kernel = python_primary_theorem_kernel
        self.horner_required = horner_required
        self.batchable_catalogue_required = batchable_catalogue_required
        self.deterministic_replay_required = deterministic_replay_required
        self.theorem_tag_boundary_explicit = theorem_tag_boundary_explicit
        self.debug_proof_grade = debug_proof_grade


def canonical_optimization_policy() -> OptimizationPolicy:
    return OptimizationPolicy("Mojo", "Mojo", True, False, False, True, True, True, True, False)


def optimization_policy_valid(policy: OptimizationPolicy) -> Bool:
    return (
        policy.computation_language == "Mojo" and
        policy.theorem_kernel_language == "Mojo" and
        policy.python_reference_allowed and
        not policy.python_primary_certificate and
        not policy.python_primary_theorem_kernel and
        policy.horner_required and policy.batchable_catalogue_required and
        policy.deterministic_replay_required and
        policy.theorem_tag_boundary_explicit and not policy.debug_proof_grade
    )


def polynomial_kernel_discipline() -> KernelDiscipline:
    return KernelDiscipline(
        "polynomial_horner_kernel",
        True,  # explicit value structs / arrays
        True,  # debug paths never proof-grade by default
        True,  # allocation-light target
        True,  # batchable over coefficient arrays / boxes
        True,  # arbitrary-precision backend boundary remains explicit
    )


def separator_catalogue_kernel_discipline() -> KernelDiscipline:
    return KernelDiscipline(
        "separator_catalogue_scan",
        True,
        True,
        True,
        True,
        True,
    )


def interval_kernel_discipline() -> KernelDiscipline:
    return KernelDiscipline(
        "interval_certificate_kernel",
        True,
        True,
        True,
        True,
        True,
    )


def theorem_kernel_discipline() -> KernelDiscipline:
    return KernelDiscipline(
        "finite_proof_object_kernel",
        True,  # proof objects and rule applications are explicit records
        True,  # debug derivations are never proof-grade by default
        True,  # deterministic replay should avoid ambient heap-heavy state
        True,  # batchable proof replay over ordered rule applications
        True,  # theorem-tag imports are an explicit trust boundary
    )


def default_computation_language(policy: OptimizationPolicy) -> String:
    return policy.computation_language


def default_theorem_kernel_language(policy: OptimizationPolicy) -> String:
    return policy.theorem_kernel_language


def python_reference_oracle_allowed(policy: OptimizationPolicy) -> Bool:
    return policy.python_reference_allowed


def python_primary_certificate_engine_allowed_after_mojo_port(policy: OptimizationPolicy) -> Bool:
    return policy.python_primary_certificate


def python_primary_theorem_kernel_allowed_after_mojo_port(policy: OptimizationPolicy) -> Bool:
    return policy.python_primary_theorem_kernel


def horner_polynomial_evaluation_required(policy: OptimizationPolicy) -> Bool:
    return policy.horner_required


def batchable_catalogue_scans_required(policy: OptimizationPolicy) -> Bool:
    return policy.batchable_catalogue_required


def deterministic_proof_replay_required(policy: OptimizationPolicy) -> Bool:
    return policy.deterministic_replay_required


def theorem_tag_import_boundary_explicit(policy: OptimizationPolicy) -> Bool:
    return policy.theorem_tag_boundary_explicit


def debug_path_is_proof_grade(policy: OptimizationPolicy) -> Bool:
    return policy.debug_proof_grade
