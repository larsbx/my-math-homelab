# Mojo theorem kernel scaffold for finite proof objects.
#
# Scope: project-internal finite derivations only. External analytic results
# enter as theorem tags with declared assumptions and leak notes.

struct KernelStatement:
    var name: String
    var layer: String
    var finite_only: Bool
    var uses_rank2_circle: Bool
    var claims_global_mlc: Bool

    fn __init__(inout self, name: String, layer: String, finite_only: Bool, uses_rank2_circle: Bool, claims_global_mlc: Bool):
        self.name = name
        self.layer = layer
        self.finite_only = finite_only
        self.uses_rank2_circle = uses_rank2_circle
        self.claims_global_mlc = claims_global_mlc


struct TheoremTagImport:
    var tag_id: String
    var source_family: String
    var hypotheses_declared: Bool
    var conclusion_declared: Bool
    var leak_note_declared: Bool
    var internal_proof_claimed: Bool

    fn __init__(inout self, tag_id: String, source_family: String, hypotheses_declared: Bool, conclusion_declared: Bool, leak_note_declared: Bool, internal_proof_claimed: Bool):
        self.tag_id = tag_id
        self.source_family = source_family
        self.hypotheses_declared = hypotheses_declared
        self.conclusion_declared = conclusion_declared
        self.leak_note_declared = leak_note_declared
        self.internal_proof_claimed = internal_proof_claimed


struct RuleApplication:
    var rule_name: String
    var premises_checked: Bool
    var conclusion_finite: Bool
    var consumes_theorem_tag: Bool
    var produces_global_frontier_claim: Bool

    fn __init__(inout self, rule_name: String, premises_checked: Bool, conclusion_finite: Bool, consumes_theorem_tag: Bool, produces_global_frontier_claim: Bool):
        self.rule_name = rule_name
        self.premises_checked = premises_checked
        self.conclusion_finite = conclusion_finite
        self.consumes_theorem_tag = consumes_theorem_tag
        self.produces_global_frontier_claim = produces_global_frontier_claim


struct ProofObject:
    var statement: KernelStatement
    var local_rule_count: Int
    var imported_tag_count: Int
    var all_rules_checked: Bool
    var all_imports_validated: Bool

    fn __init__(inout self, statement: KernelStatement, local_rule_count: Int, imported_tag_count: Int, all_rules_checked: Bool, all_imports_validated: Bool):
        self.statement = statement
        self.local_rule_count = local_rule_count
        self.imported_tag_count = imported_tag_count
        self.all_rules_checked = all_rules_checked
        self.all_imports_validated = all_imports_validated


struct CheckedTheoremStatus:
    var accepted: Bool
    var finite_kernel_theorem: Bool
    var external_tags_used: Bool
    var open_frontier: Bool
    var rejection_reason: String

    fn __init__(inout self, accepted: Bool, finite_kernel_theorem: Bool, external_tags_used: Bool, open_frontier: Bool, rejection_reason: String):
        self.accepted = accepted
        self.finite_kernel_theorem = finite_kernel_theorem
        self.external_tags_used = external_tags_used
        self.open_frontier = open_frontier
        self.rejection_reason = rejection_reason


fn theorem_tag_import_valid(tag: TheoremTagImport) -> Bool:
    if tag.internal_proof_claimed:
        return False
    return tag.hypotheses_declared and tag.conclusion_declared and tag.leak_note_declared


fn rule_application_valid(rule: RuleApplication) -> Bool:
    if not rule.premises_checked:
        return False
    if rule.produces_global_frontier_claim:
        return False
    return rule.conclusion_finite or rule.consumes_theorem_tag


fn check_proof_object(proof: ProofObject) -> CheckedTheoremStatus:
    if proof.statement.uses_rank2_circle:
        return CheckedTheoremStatus(False, False, False, False, "rank-2 circle primitive rejected")
    if proof.statement.claims_global_mlc:
        return CheckedTheoremStatus(False, False, False, True, "global MLC-strength claim is open frontier")
    if not proof.statement.finite_only and proof.imported_tag_count == 0:
        return CheckedTheoremStatus(False, False, False, False, "non-finite statement requires theorem-tag import")
    if not proof.all_rules_checked:
        return CheckedTheoremStatus(False, False, False, False, "unchecked local rule")
    if proof.imported_tag_count > 0 and not proof.all_imports_validated:
        return CheckedTheoremStatus(False, False, True, False, "unvalidated theorem tag import")
    return CheckedTheoremStatus(True, proof.imported_tag_count == 0, proof.imported_tag_count > 0, False, "")


fn mojo_is_finite_theorem_kernel() -> Bool:
    return True


fn mojo_reproves_external_analytic_theorems() -> Bool:
    return False


fn theorem_tags_are_axiom_import_boundary() -> Bool:
    return True


fn rank2_circle_primitive_available_in_kernel() -> Bool:
    return False


fn demo_finite_separator_theorem() -> CheckedTheoremStatus:
    var stmt = KernelStatement("FinitePrefixToExistentialSeparation", "C1", True, False, False)
    var proof = ProofObject(stmt, 3, 0, True, True)
    return check_proof_object(proof)


fn demo_reject_mlc_claim() -> CheckedTheoremStatus:
    var stmt = KernelStatement("GlobalMLC", "C1", False, False, True)
    var proof = ProofObject(stmt, 1, 0, True, True)
    return check_proof_object(proof)
