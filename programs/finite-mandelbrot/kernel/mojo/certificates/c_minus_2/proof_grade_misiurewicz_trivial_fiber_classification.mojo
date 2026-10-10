# Proof-grade class-specific trivial-fiber classification for c=-2.
#
# This module checks that the exact target already established by the landing
# proof stack is the Misiurewicz parameter c=-2 of exact orbit type (2,1), then
# attaches the published class-specific trivial-fiber theorem.  It does not
# internalize the analytic theorem and does not generalize beyond this instance.

from c1.theorem_tags.theorem_tag_import_ledger import ImportConclusionKind, ImportStrengthClass, TheoremTagRecord, misiurewicz_c_minus_2_trivial_fiber_tag_checked, theorem_tag_admissible_for_final
from c1.theorem_tags.theorem_tag_assumption_payloads import AssumptionPayloadKind, PayloadConclusionKind, PayloadStrengthClass, TheoremTagPayload, misiurewicz_trivial_fiber_payload_scaffold, theorem_tag_payload_admissible
from certificates.c_minus_2.proof_grade_landing_target_association import ProofGradeLandingTargetAssociation, verify_proof_grade_c_minus_2_landing_target_association


struct MisiurewiczTrivialFiberTheoremImportWitness(ImplicitlyCopyable):
    var record: TheoremTagRecord
    var payload: TheoremTagPayload
    var citation_key: String
    var source_title: String
    var covered_class: String
    var theorem_covers_all_misiurewicz_parameters: Bool
    var adapter_domain_matches_parameter_plane_fiber: Bool

    def __init__(
        out self,
        record: TheoremTagRecord,
        payload: TheoremTagPayload,
        citation_key: String,
        source_title: String,
        covered_class: String,
        theorem_covers_all_misiurewicz_parameters: Bool,
        adapter_domain_matches_parameter_plane_fiber: Bool,
    ):
        self.record = record
        self.payload = payload
        self.citation_key = citation_key
        self.source_title = source_title
        self.covered_class = covered_class
        self.theorem_covers_all_misiurewicz_parameters = theorem_covers_all_misiurewicz_parameters
        self.adapter_domain_matches_parameter_plane_fiber = adapter_domain_matches_parameter_plane_fiber

    def accepted(self) -> Bool:
        return (
            self.citation_key == "SchleicherFibersLC" and
            self.source_title == "On Fibers and Local Connectivity of Mandelbrot and Multibrot Sets" and
            self.covered_class == "Misiurewicz parameters" and
            self.record.name == "KnownTrivialFiberClass" and
            self.record.conclusion_kind.code == ImportConclusionKind.known_trivial_fiber_class().code and
            self.record.strength_class.code == ImportStrengthClass.classical_class_specific().code and
            self.payload.tag_name == self.record.name and
            self.payload.payload_kind.code == AssumptionPayloadKind.known_trivial_fiber().code and
            self.payload.conclusion_kind.code == PayloadConclusionKind.class_specific_trivial_fiber().code and
            self.payload.strength_class.code == PayloadStrengthClass.class_specific_fiber_triviality().code and
            self.theorem_covers_all_misiurewicz_parameters and
            self.adapter_domain_matches_parameter_plane_fiber and
            theorem_tag_admissible_for_final(self.record) and
            theorem_tag_payload_admissible(self.payload)
        )


def checked_misiurewicz_trivial_fiber_theorem_import() -> MisiurewiczTrivialFiberTheoremImportWitness:
    return MisiurewiczTrivialFiberTheoremImportWitness(
        misiurewicz_c_minus_2_trivial_fiber_tag_checked(),
        misiurewicz_trivial_fiber_payload_scaffold(),
        "SchleicherFibersLC",
        "On Fibers and Local Connectivity of Mandelbrot and Multibrot Sets",
        "Misiurewicz parameters",
        True,
        True,
    )


struct ProofGradeMisiurewiczTrivialFiberClassification(ImplicitlyCopyable):
    var theorem_import: MisiurewiczTrivialFiberTheoremImportWitness
    var landing_target: ProofGradeLandingTargetAssociation
    var target_num: Int64
    var target_den: Int64
    var ell: Int
    var period: Int
    var exact_class_membership_checked: Bool

    def __init__(
        out self,
        theorem_import: MisiurewiczTrivialFiberTheoremImportWitness,
        landing_target: ProofGradeLandingTargetAssociation,
        target_num: Int64,
        target_den: Int64,
        ell: Int,
        period: Int,
        exact_class_membership_checked: Bool,
    ):
        self.theorem_import = theorem_import
        self.landing_target = landing_target
        self.target_num = target_num
        self.target_den = target_den
        self.ell = ell
        self.period = period
        self.exact_class_membership_checked = exact_class_membership_checked

    def class_specific_trivial_fiber_accepted(self) -> Bool:
        return (
            self.theorem_import.accepted() and
            self.landing_target.proof_grade_associated() and
            self.target_num == -2 and self.target_den == 1 and
            self.ell == 2 and self.period == 1 and
            self.target_num == self.landing_target.target_num and
            self.target_den == self.landing_target.target_den and
            self.ell == self.landing_target.ell and
            self.period == self.landing_target.period and
            self.exact_class_membership_checked
        )

    def proves_generic_mlc(self) -> Bool: return False
    def proves_all_fibers_trivial(self) -> Bool: return False
    def proves_residual_closure_no_missing_links(self) -> Bool: return False
    def proves_c1(self) -> Bool: return False


def verify_c_minus_2_misiurewicz_trivial_fiber_classification() -> ProofGradeMisiurewiczTrivialFiberClassification:
    var landing = verify_proof_grade_c_minus_2_landing_target_association()
    return ProofGradeMisiurewiczTrivialFiberClassification(
        checked_misiurewicz_trivial_fiber_theorem_import(),
        landing,
        -2,
        1,
        2,
        1,
        landing.target_exact_type_verified,
    )


def proof_grade_misiurewicz_trivial_fiber_classification_smoke() -> Bool:
    var accepted = verify_c_minus_2_misiurewicz_trivial_fiber_classification()
    var wrong_target = ProofGradeMisiurewiczTrivialFiberClassification(
        accepted.theorem_import, accepted.landing_target, -1, 1, 2, 1, True,
    )
    var wrong_type = ProofGradeMisiurewiczTrivialFiberClassification(
        accepted.theorem_import, accepted.landing_target, -2, 1, 3, 1, True,
    )
    var wrong_source_import = MisiurewiczTrivialFiberTheoremImportWitness(
        accepted.theorem_import.record,
        accepted.theorem_import.payload,
        "WrongSource",
        accepted.theorem_import.source_title,
        accepted.theorem_import.covered_class,
        True,
        True,
    )
    var wrong_source = ProofGradeMisiurewiczTrivialFiberClassification(
        wrong_source_import, accepted.landing_target, -2, 1, 2, 1, True,
    )
    var wrong_payload = TheoremTagPayload(
        "KnownTrivialFiberClass",
        AssumptionPayloadKind.rational_ray_landing(),
        PayloadConclusionKind.class_specific_trivial_fiber(),
        PayloadStrengthClass.class_specific_fiber_triviality(),
        True, True, True, True, True, False, False,
    )
    var wrong_payload_import = MisiurewiczTrivialFiberTheoremImportWitness(
        accepted.theorem_import.record,
        wrong_payload,
        accepted.theorem_import.citation_key,
        accepted.theorem_import.source_title,
        accepted.theorem_import.covered_class,
        True,
        True,
    )
    var wrong_payload_kind = ProofGradeMisiurewiczTrivialFiberClassification(
        wrong_payload_import, accepted.landing_target, -2, 1, 2, 1, True,
    )
    return (
        accepted.class_specific_trivial_fiber_accepted() and
        not wrong_target.class_specific_trivial_fiber_accepted() and
        not wrong_type.class_specific_trivial_fiber_accepted() and
        not wrong_source.class_specific_trivial_fiber_accepted() and
        not wrong_payload_kind.class_specific_trivial_fiber_accepted() and
        not accepted.proves_generic_mlc() and
        not accepted.proves_all_fibers_trivial() and
        not accepted.proves_residual_closure_no_missing_links() and
        not accepted.proves_c1()
    )
