# Internal theorem-tag import ledger for the priority conjecture.
#
# Mojo checks finite import records. It does not silently reprove imported
# analytic theorems; it verifies that named tags have the required payloads and
# do not smuggle global MLC-strength conclusions into premises.

struct ImportConclusionKind(ImplicitlyCopyable):
    var code: Int
    def __init__(out self, code: Int): self.code = code
    @staticmethod
    def rational_ray_landing() -> Self: return Self(0)
    @staticmethod
    def separator_interpretation() -> Self: return Self(1)
    @staticmethod
    def fiber_definition_equivalence() -> Self: return Self(2)
    @staticmethod
    def known_trivial_fiber_class() -> Self: return Self(3)
    @staticmethod
    def yoccoz_local_connectivity() -> Self: return Self(4)
    @staticmethod
    def renormalization_with_apriori_bounds() -> Self: return Self(5)
    @staticmethod
    def boundary_identification_soundness() -> Self: return Self(6)
    @staticmethod
    def tuning_kneading_substitution() -> Self: return Self(7)
    @staticmethod
    def harmonic_measure_fibre_triviality() -> Self: return Self(8)


struct ImportStrengthClass(ImplicitlyCopyable):
    var code: Int
    def __init__(out self, code: Int): self.code = code
    @staticmethod
    def finite_only() -> Self: return Self(0)
    @staticmethod
    def classical_local() -> Self: return Self(1)
    @staticmethod
    def classical_class_specific() -> Self: return Self(2)
    @staticmethod
    def global_mlc() -> Self: return Self(3)
    @staticmethod
    def forbidden_placeholder() -> Self: return Self(4)


struct ImportStatus(ImplicitlyCopyable):
    var code: Int
    def __init__(out self, code: Int): self.code = code
    @staticmethod
    def checked() -> Self: return Self(0)
    @staticmethod
    def scaffolded() -> Self: return Self(1)


struct TheoremTagRecord(ImplicitlyCopyable):
    var name: String
    var source_family_named: Bool
    var covered_class_explicit: Bool
    var conclusion_kind: ImportConclusionKind
    var assumption_payload_present: Bool
    var adapter_use_declared: Bool
    var strength_class: ImportStrengthClass
    var import_status: ImportStatus

    def __init__(
        out self,
        name: String,
        source_family_named: Bool,
        covered_class_explicit: Bool,
        conclusion_kind: ImportConclusionKind,
        assumption_payload_present: Bool,
        adapter_use_declared: Bool,
        strength_class: ImportStrengthClass,
        import_status: ImportStatus,
    ):
        self.name = name
        self.source_family_named = source_family_named
        self.covered_class_explicit = covered_class_explicit
        self.conclusion_kind = conclusion_kind
        self.assumption_payload_present = assumption_payload_present
        self.adapter_use_declared = adapter_use_declared
        self.strength_class = strength_class
        self.import_status = import_status


def allowed_conclusion_kind(kind: ImportConclusionKind) -> Bool:
    return kind.code >= 0 and kind.code <= 8


def allowed_strength_class(strength_class: ImportStrengthClass) -> Bool:
    return strength_class.code >= 0 and strength_class.code <= 2


def forbidden_strength_class(strength_class: ImportStrengthClass) -> Bool:
    return strength_class.code >= 3 and strength_class.code <= 4


def forbidden_import_name(name: String) -> Bool:
    return (
        name == "GenericMLC"
        or name == "AllFibersTrivial"
        or name == "EveryPersistentNonSeparationCollapses"
        or name == "ResidualClosureNoMissingLinks"
        or name == "BoundedSearchTermination"
        or name == "RendererEvidence"
        or name == "NumericalPictureShrinkage"
    )


def import_record_complete(record: TheoremTagRecord) -> Bool:
    return (
        record.source_family_named
        and record.covered_class_explicit
        and allowed_conclusion_kind(record.conclusion_kind)
        and record.assumption_payload_present
        and record.adapter_use_declared
        and record.import_status.code == ImportStatus.checked().code
    )


def theorem_tag_admissible_for_final(record: TheoremTagRecord) -> Bool:
    if forbidden_import_name(record.name):
        return False
    if forbidden_strength_class(record.strength_class):
        return False
    return import_record_complete(record) and allowed_strength_class(record.strength_class)


def rational_parameter_ray_landing_tag_ready() -> TheoremTagRecord:
    return TheoremTagRecord(
        "RationalParameterRayLanding",
        True,
        True,
        ImportConclusionKind.rational_ray_landing(),
        False,  # source-specific assumption payload still must be supplied per use
        True,
        ImportStrengthClass.classical_local(),
        ImportStatus.scaffolded(),
    )


def rational_parameter_ray_landing_c_minus_2_tag_checked() -> TheoremTagRecord:
    # Canonical source-specific import record for the c=-2 / address-1/2
    # payload. The consumer must still validate the concrete source payload and
    # proof-grade target association; this record alone does no mathematical
    # work.
    return TheoremTagRecord(
        "RationalParameterRayLanding",
        True,
        True,
        ImportConclusionKind.rational_ray_landing(),
        True,
        True,
        ImportStrengthClass.classical_local(),
        ImportStatus.checked(),
    )


def fiber_definition_equivalence_tag_ready() -> TheoremTagRecord:
    return TheoremTagRecord(
        "FiberDefinitionEquivalence",
        True,
        True,
        ImportConclusionKind.fiber_definition_equivalence(),
        False,
        True,
        ImportStrengthClass.classical_local(),
        ImportStatus.scaffolded(),
    )


def known_trivial_fiber_class_tag_ready() -> TheoremTagRecord:
    return TheoremTagRecord(
        "KnownTrivialFiberClass",
        True,
        True,
        ImportConclusionKind.known_trivial_fiber_class(),
        False,
        True,
        ImportStrengthClass.classical_class_specific(),
        ImportStatus.scaffolded(),
    )


def misiurewicz_c_minus_2_trivial_fiber_tag_checked() -> TheoremTagRecord:
    # Source-specific record for the exact c=-2, orbit-type (2,1) instance.
    # Consumers must independently validate class membership and source scope.
    return TheoremTagRecord(
        "KnownTrivialFiberClass",
        True,
        True,
        ImportConclusionKind.known_trivial_fiber_class(),
        True,
        True,
        ImportStrengthClass.classical_class_specific(),
        ImportStatus.checked(),
    )


def tuning_kneading_substitution_tag_ready() -> TheoremTagRecord:
    # docs/C1_residual_directive_carrier.md: the substitution form of tuning on
    # kneading sequences. Scaffolded: the payload is per-level and unchecked.
    return TheoremTagRecord(
        "TuningKneadingSubstitution",
        True,
        True,
        ImportConclusionKind.tuning_kneading_substitution(),
        False,
        True,
        ImportStrengthClass.classical_class_specific(),
        ImportStatus.scaffolded(),
    )


def harmonic_measure_fibre_triviality_tag_ready() -> TheoremTagRecord:
    # docs/C1_theorem_tag_import_ledger.md: triviality for harmonic-measure-almost
    # every boundary parameter. Scaffolded: the payload must name the measure and
    # show the parameter was not selected from the null exceptional set.
    return TheoremTagRecord(
        "HarmonicMeasureAlmostEveryFibreTrivial",
        True,
        True,
        ImportConclusionKind.harmonic_measure_fibre_triviality(),
        False,
        True,
        ImportStrengthClass.classical_class_specific(),
        ImportStatus.scaffolded(),
    )


def harmonic_measure_tag_discharges_a_named_pair() -> Bool:
    # A null exceptional set is not an empty one, and it contains the infinitely
    # renormalizable parameters of docs/C1_residual_directive_carrier.md.
    return False


def generic_mlc_import_admissible() -> Bool:
    return False


def theorem_tags_block_final_proof_until_checked() -> Bool:
    return True


def next_priority_after_theorem_tag_ledger() -> String:
    return "TheoremTagAssumptionPayloads"
