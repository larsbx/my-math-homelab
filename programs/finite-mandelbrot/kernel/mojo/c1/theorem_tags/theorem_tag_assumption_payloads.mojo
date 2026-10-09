# Theorem-tag assumption payload checker.
#
# Internal C1 proof infrastructure. This module makes theorem-tag imports depend
# on finite assumption payloads rather than names alone.

struct AssumptionPayloadKind(ImplicitlyCopyable):
    var code: Int

    def __init__(out self, code: Int): self.code = code

    @staticmethod
    def rational_ray_landing() -> Self: return Self(0)
    @staticmethod
    def fiber_definition() -> Self: return Self(1)
    @staticmethod
    def known_trivial_fiber() -> Self: return Self(2)
    @staticmethod
    def yoccoz_puzzle() -> Self: return Self(3)
    @staticmethod
    def apriori_bounds() -> Self: return Self(4)


struct PayloadConclusionKind(ImplicitlyCopyable):
    var code: Int

    def __init__(out self, code: Int): self.code = code

    @staticmethod
    def ray_landing() -> Self: return Self(0)
    @staticmethod
    def separator_interpretation() -> Self: return Self(1)
    @staticmethod
    def fiber_definition_adapter() -> Self: return Self(2)
    @staticmethod
    def class_specific_trivial_fiber() -> Self: return Self(3)
    @staticmethod
    def boundary_equality_adapter() -> Self: return Self(4)


struct PayloadStrengthClass(ImplicitlyCopyable):
    var code: Int

    def __init__(out self, code: Int): self.code = code

    @staticmethod
    def adapter_only() -> Self: return Self(0)
    @staticmethod
    def local_landing() -> Self: return Self(1)
    @staticmethod
    def class_specific_fiber_triviality() -> Self: return Self(2)
    @staticmethod
    def class_specific_local_connectivity() -> Self: return Self(3)


struct TheoremTagPayload(ImplicitlyCopyable):
    var tag_name: String
    var payload_kind: AssumptionPayloadKind
    var conclusion_kind: PayloadConclusionKind
    var strength_class: PayloadStrengthClass
    var has_finite_witness_payload: Bool
    var has_adapter_payload: Bool
    var has_source_family: Bool
    var excludes_generic_boundary_assertion: Bool
    var excludes_residual_closure_claim: Bool
    var uses_generic_mlc: Bool
    var uses_bounded_search_only: Bool

    def __init__(
        out self,
        tag_name: String,
        payload_kind: AssumptionPayloadKind,
        conclusion_kind: PayloadConclusionKind,
        strength_class: PayloadStrengthClass,
        has_finite_witness_payload: Bool,
        has_adapter_payload: Bool,
        has_source_family: Bool,
        excludes_generic_boundary_assertion: Bool,
        excludes_residual_closure_claim: Bool,
        uses_generic_mlc: Bool,
        uses_bounded_search_only: Bool,
    ):
        self.tag_name = tag_name
        self.payload_kind = payload_kind
        self.conclusion_kind = conclusion_kind
        self.strength_class = strength_class
        self.has_finite_witness_payload = has_finite_witness_payload
        self.has_adapter_payload = has_adapter_payload
        self.has_source_family = has_source_family
        self.excludes_generic_boundary_assertion = excludes_generic_boundary_assertion
        self.excludes_residual_closure_claim = excludes_residual_closure_claim
        self.uses_generic_mlc = uses_generic_mlc
        self.uses_bounded_search_only = uses_bounded_search_only


def allowed_payload_kind(kind: AssumptionPayloadKind) -> Bool:
    return kind.code >= 0 and kind.code <= 4


def allowed_payload_conclusion(kind: PayloadConclusionKind) -> Bool:
    return kind.code >= 0 and kind.code <= 4


def allowed_payload_strength(strength: PayloadStrengthClass) -> Bool:
    return strength.code >= 0 and strength.code <= 3


def forbidden_payload_tag(name: String) -> Bool:
    return (
        name == "GenericMLC" or
        name == "AllFibersTrivial" or
        name == "ResidualClosureNoMissingLinks" or
        name == "EveryPersistentNonSeparationCollapses" or
        name == "BoundedSearchTermination"
    )


def payload_has_required_core_fields(payload: TheoremTagPayload) -> Bool:
    return (
        payload.has_finite_witness_payload and
        payload.has_adapter_payload and
        payload.has_source_family and
        payload.excludes_generic_boundary_assertion and
        payload.excludes_residual_closure_claim
    )


def theorem_tag_payload_admissible(payload: TheoremTagPayload) -> Bool:
    if forbidden_payload_tag(payload.tag_name):
        return False
    if not allowed_payload_kind(payload.payload_kind):
        return False
    if not allowed_payload_conclusion(payload.conclusion_kind):
        return False
    if not allowed_payload_strength(payload.strength_class):
        return False
    if payload.uses_generic_mlc:
        return False
    if payload.uses_bounded_search_only:
        return False
    return payload_has_required_core_fields(payload)


def rational_parameter_ray_landing_payload_scaffold() -> TheoremTagPayload:
    return TheoremTagPayload(
        "RationalParameterRayLanding",
        AssumptionPayloadKind.rational_ray_landing(),
        PayloadConclusionKind.ray_landing(),
        PayloadStrengthClass.local_landing(),
        True,
        True,
        True,
        True,
        True,
        False,
        False,
    )


def fiber_definition_payload_scaffold() -> TheoremTagPayload:
    return TheoremTagPayload(
        "FiberDefinitionEquivalence",
        AssumptionPayloadKind.fiber_definition(),
        PayloadConclusionKind.fiber_definition_adapter(),
        PayloadStrengthClass.adapter_only(),
        True,
        True,
        True,
        True,
        True,
        False,
        False,
    )


def misiurewicz_trivial_fiber_payload_scaffold() -> TheoremTagPayload:
    return TheoremTagPayload(
        "KnownTrivialFiberClass",
        AssumptionPayloadKind.known_trivial_fiber(),
        PayloadConclusionKind.class_specific_trivial_fiber(),
        PayloadStrengthClass.class_specific_fiber_triviality(),
        True,
        True,
        True,
        True,
        True,
        False,
        False,
    )


def generic_mlc_payload_rejected() -> Bool:
    var payload = TheoremTagPayload(
        "GenericMLC",
        AssumptionPayloadKind.known_trivial_fiber(),
        PayloadConclusionKind.class_specific_trivial_fiber(),
        PayloadStrengthClass.class_specific_fiber_triviality(),
        True,
        True,
        True,
        True,
        True,
        True,
        False,
    )
    return not theorem_tag_payload_admissible(payload)


def bounded_search_payload_rejected() -> Bool:
    var payload = TheoremTagPayload(
        "BoundedSearchTermination",
        AssumptionPayloadKind.known_trivial_fiber(),
        PayloadConclusionKind.class_specific_trivial_fiber(),
        PayloadStrengthClass.class_specific_fiber_triviality(),
        True,
        True,
        True,
        True,
        True,
        False,
        True,
    )
    return not theorem_tag_payload_admissible(payload)


def next_priority_block() -> String:
    return "TheoremTagPayloadInstances"
