# canonical_serialization.mojo
#
# Canonical serialization scaffolding for finite-regime certificate records.
#
# This module does not choose a hash suite and does not make cryptographic
# claims. It defines deterministic schema tags, field order, and readiness gates
# for finite records only.


struct SerializationSchema:
    var domain_tag: String
    var version: Int
    var field_count: Int
    var canonical_order_required: Bool

    fn __init__(inout self, domain_tag: String, version: Int, field_count: Int, canonical_order_required: Bool):
        self.domain_tag = domain_tag
        self.version = version
        self.field_count = field_count
        self.canonical_order_required = canonical_order_required

    fn valid(self) -> Bool:
        return self.domain_tag == "NLAPJT" and self.version >= 1 and self.field_count > 0 and self.canonical_order_required


struct SerializationGate:
    var bigint_backend_ready: Bool
    var rational_normalization_ready: Bool
    var canonical_field_order: Bool
    var theorem_tags_stable: Bool
    var same_box_references: Bool
    var hash_suite_selected: Bool

    fn __init__(inout self, bigint_backend_ready: Bool, rational_normalization_ready: Bool, canonical_field_order: Bool, theorem_tags_stable: Bool, same_box_references: Bool, hash_suite_selected: Bool):
        self.bigint_backend_ready = bigint_backend_ready
        self.rational_normalization_ready = rational_normalization_ready
        self.canonical_field_order = canonical_field_order
        self.theorem_tags_stable = theorem_tags_stable
        self.same_box_references = same_box_references
        self.hash_suite_selected = hash_suite_selected

    fn debug_serialization_allowed(self) -> Bool:
        return self.canonical_field_order and self.theorem_tags_stable and self.same_box_references

    fn proof_grade_digest_allowed(self) -> Bool:
        return (
            self.bigint_backend_ready and
            self.rational_normalization_ready and
            self.canonical_field_order and
            self.theorem_tags_stable and
            self.same_box_references and
            self.hash_suite_selected
        )


fn misiurewicz_certificate_schema() -> SerializationSchema:
    # Ordered fields:
    # 1 schema id
    # 2 backend manifest placeholder
    # 3 critical orbit type
    # 4 squarefree polynomial coefficients
    # 5 dyadic box
    # 6 Krawczyk witness
    # 7 exact-type exclusions
    # 8 ray-address datum
    # 9 theorem tags
    # 10 incidence carrier
    return SerializationSchema("NLAPJT", 1, 10, True)


fn coord2_schema() -> SerializationSchema:
    # Coord2(x: Q, y: Q), rank-2 coordinate record only.
    return SerializationSchema("NLAPJT", 1, 2, True)


fn box2_schema() -> SerializationSchema:
    # Box2(x_lo, x_hi, y_lo, y_hi), ordered rational endpoints.
    return SerializationSchema("NLAPJT", 1, 4, True)


fn vertex_schema() -> SerializationSchema:
    # Vertex(tag, id), both length-prefixed in the eventual byte encoding.
    return SerializationSchema("NLAPJT", 1, 2, True)


fn point_vertex_schema() -> SerializationSchema:
    # PointVertex(name, finite carrier). This is an incidence object.
    return SerializationSchema("NLAPJT", 1, 2, True)


fn demo_serialization_gate() -> SerializationGate:
    # Current repository state: debug serialization can be specified, but
    # proof-grade digests remain blocked until bigint and hash suite selection.
    return SerializationGate(False, False, True, True, True, False)


fn debug_serialization_ready() -> Bool:
    return demo_serialization_gate().debug_serialization_allowed()


fn proof_grade_digest_ready() -> Bool:
    return demo_serialization_gate().proof_grade_digest_allowed()
