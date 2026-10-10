# C1 exit closure scaffold for the Mojo theorem kernel.
#
# This module records the finite shape of residual exit certificates.  It does
# not prove C1.  It checks that an accepted exit is typed and carries the local
# finite evidence required by the C1 proof route.

struct ResidualExitCertificate:
    var kind: String
    var source_rule: String
    var finite_payload_present: Bool
    var theorem_tag_checked: Bool
    var adapter_checked: Bool
    var missing_link_recorded: Bool
    var boundary_identification_checked: Bool

    fn __init__(inout self, kind: String, source_rule: String, finite_payload_present: Bool, theorem_tag_checked: Bool, adapter_checked: Bool, missing_link_recorded: Bool, boundary_identification_checked: Bool):
        self.kind = kind
        self.source_rule = source_rule
        self.finite_payload_present = finite_payload_present
        self.theorem_tag_checked = theorem_tag_checked
        self.adapter_checked = adapter_checked
        self.missing_link_recorded = missing_link_recorded
        self.boundary_identification_checked = boundary_identification_checked


struct ExitClosureResult:
    var accepted: Bool
    var closed_kind: String
    var remaining_obligation: String
    var contributes_to_c1_route: Bool

    fn __init__(inout self, accepted: Bool, closed_kind: String, remaining_obligation: String, contributes_to_c1_route: Bool):
        self.accepted = accepted
        self.closed_kind = closed_kind
        self.remaining_obligation = remaining_obligation
        self.contributes_to_c1_route = contributes_to_c1_route


fn accepted_exit_kind(kind: String) -> Bool:
    return kind == "FiniteSeparation" or kind == "BoundaryEqualityRefinement" or kind == "MissingTheoremCatalogueLink" or kind == "EstablishedTrivialFiberTag"


fn accepted_source_rule(source_rule: String) -> Bool:
    return source_rule == "ResidualDescentContradiction" or source_rule == "TheoremTagImport" or source_rule == "FiniteSeparatorWitness"


fn finite_separation_closed(cert: ResidualExitCertificate) -> Bool:
    return cert.kind == "FiniteSeparation" and cert.finite_payload_present and cert.adapter_checked


fn boundary_equality_closed(cert: ResidualExitCertificate) -> Bool:
    return cert.kind == "BoundaryEqualityRefinement" and cert.finite_payload_present and cert.boundary_identification_checked


fn missing_link_closed(cert: ResidualExitCertificate) -> Bool:
    return cert.kind == "MissingTheoremCatalogueLink" and cert.finite_payload_present and cert.missing_link_recorded


fn theorem_tag_closed(cert: ResidualExitCertificate) -> Bool:
    return cert.kind == "EstablishedTrivialFiberTag" and cert.finite_payload_present and cert.theorem_tag_checked and cert.adapter_checked


fn exit_payload_closed(cert: ResidualExitCertificate) -> Bool:
    if not accepted_exit_kind(cert.kind):
        return False
    if not accepted_source_rule(cert.source_rule):
        return False
    return finite_separation_closed(cert) or boundary_equality_closed(cert) or missing_link_closed(cert) or theorem_tag_closed(cert)


fn close_residual_exit(cert: ResidualExitCertificate) -> ExitClosureResult:
    if not exit_payload_closed(cert):
        return ExitClosureResult(False, "Rejected", "supply typed finite payload and checked adapter or missing-link record", False)
    if cert.kind == "FiniteSeparation":
        return ExitClosureResult(True, "SeparatedPrefix", "none", True)
    if cert.kind == "BoundaryEqualityRefinement":
        return ExitClosureResult(True, "BoundaryIdentification", "none", True)
    if cert.kind == "MissingTheoremCatalogueLink":
        return ExitClosureResult(True, "FiniteMissingLinkObligation", "prove adapter or import theorem tag", True)
    if cert.kind == "EstablishedTrivialFiberTag":
        return ExitClosureResult(True, "CheckedTrivialFiberImport", "none", True)
    return ExitClosureResult(False, "Rejected", "unknown exit kind", False)


fn c1_proved_by_exit_closure_alone() -> Bool:
    return False


fn imported_analytic_theorem_reproved_in_mojo() -> Bool:
    return False


fn theorem_tags_require_assumption_checks() -> Bool:
    return True


fn rank2_circle_primitive_available() -> Bool:
    return False


fn bounded_search_is_exit_certificate() -> Bool:
    return False
