# ResidualClosureNoMissingLinks proof-object scaffold.
#
# This module records the final residual-closure rule required by the C1 proof
# criterion. A final proof object must not terminate in a missing-link exit.

struct FinalExitKind(ImplicitlyCopyable):
    var code: Int

    def __init__(out self, code: Int):
        self.code = code

    @staticmethod
    def finite_separation() -> Self:
        return Self(0)

    @staticmethod
    def boundary_equality() -> Self:
        return Self(1)

    @staticmethod
    def established_trivial_fiber() -> Self:
        return Self(2)

    @staticmethod
    def missing_theorem_catalogue_link() -> Self:
        return Self(3)

    @staticmethod
    def open_analytic_assumption() -> Self:
        return Self(4)

    @staticmethod
    def bounded_search_failure() -> Self:
        return Self(5)

    @staticmethod
    def label_equality_only() -> Self:
        return Self(6)


struct ResidualClosureProofObject(ImplicitlyCopyable):
    var residual_case_id: String
    var persistent_nonseparation_schema_present: Bool
    var separator_catalogue_adequacy_dependency: Bool
    var fiber_definition_adapter_dependency: Bool
    var exit_closure_certificate_present: Bool
    var no_open_missing_link_certificate: Bool
    var final_exit_kind: FinalExitKind
    var imported_theorem_assumption_payloads: Bool
    var boundary_equality_uses_content_not_label: Bool
    var derived_from_bounded_search_only: Bool
    var uses_rank2_locus_primitive: Bool

    def __init__(
        out self,
        residual_case_id: String,
        persistent_nonseparation_schema_present: Bool,
        separator_catalogue_adequacy_dependency: Bool,
        fiber_definition_adapter_dependency: Bool,
        exit_closure_certificate_present: Bool,
        no_open_missing_link_certificate: Bool,
        final_exit_kind: FinalExitKind,
        imported_theorem_assumption_payloads: Bool,
        boundary_equality_uses_content_not_label: Bool,
        derived_from_bounded_search_only: Bool,
        uses_rank2_locus_primitive: Bool,
    ):
        self.residual_case_id = residual_case_id
        self.persistent_nonseparation_schema_present = persistent_nonseparation_schema_present
        self.separator_catalogue_adequacy_dependency = separator_catalogue_adequacy_dependency
        self.fiber_definition_adapter_dependency = fiber_definition_adapter_dependency
        self.exit_closure_certificate_present = exit_closure_certificate_present
        self.no_open_missing_link_certificate = no_open_missing_link_certificate
        self.final_exit_kind = final_exit_kind
        self.imported_theorem_assumption_payloads = imported_theorem_assumption_payloads
        self.boundary_equality_uses_content_not_label = boundary_equality_uses_content_not_label
        self.derived_from_bounded_search_only = derived_from_bounded_search_only
        self.uses_rank2_locus_primitive = uses_rank2_locus_primitive


def accepted_final_exit(kind: FinalExitKind) -> Bool:
    return kind.code >= 0 and kind.code <= 2


def rejected_final_exit(kind: FinalExitKind) -> Bool:
    return kind.code >= 3 and kind.code <= 6


def residual_closure_dependencies_ready(obj: ResidualClosureProofObject) -> Bool:
    return (
        obj.persistent_nonseparation_schema_present
        and obj.separator_catalogue_adequacy_dependency
        and obj.fiber_definition_adapter_dependency
        and obj.exit_closure_certificate_present
        and obj.no_open_missing_link_certificate
    )


def residual_closure_no_missing_links_accepts(obj: ResidualClosureProofObject) -> Bool:
    if not residual_closure_dependencies_ready(obj):
        return False
    if rejected_final_exit(obj.final_exit_kind):
        return False
    if not accepted_final_exit(obj.final_exit_kind):
        return False
    if obj.final_exit_kind.code == FinalExitKind.established_trivial_fiber().code and not obj.imported_theorem_assumption_payloads:
        return False
    if obj.final_exit_kind.code == FinalExitKind.boundary_equality().code and not obj.boundary_equality_uses_content_not_label:
        return False
    if obj.derived_from_bounded_search_only:
        return False
    if obj.uses_rank2_locus_primitive:
        return False
    return True


def missing_link_exit_allowed_in_final_c1_proof() -> Bool:
    return False


def bounded_search_establishes_persistent_nonseparation() -> Bool:
    return False


def rank2_circle_disk_arc_locus_available() -> Bool:
    return False


def proves_c1_by_itself() -> Bool:
    return False


def current_priority_block() -> String:
    return "ResidualClosureNoMissingLinks"


def next_priority_block_after_residual_closure() -> String:
    return "C1FinalProofObjectSkeleton"
