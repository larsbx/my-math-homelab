from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/certificates/canonical_serialization.mojo"
DOC = ROOT / "docs" / "canonical-serialization.md"
BIGZ = ROOT / "vendor/mojo/finite_exact/bigint_z.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_serialization_schema_exists():
    src = read(SRC)
    assert "struct SerializationSchema" in src
    assert "struct SerializationGate" in src
    assert "fn misiurewicz_certificate_schema" in src
    assert "return SerializationSchema(\"NLAPJT\", 1, 10, True)" in src


def test_required_record_schemas_exist():
    src = read(SRC)
    for name in [
        "coord2_schema",
        "box2_schema",
        "vertex_schema",
        "point_vertex_schema",
    ]:
        assert f"fn {name}" in src


def test_debug_allowed_but_proof_digest_blocked():
    src = read(SRC)
    assert "fn debug_serialization_ready" in src
    assert "fn proof_grade_digest_ready" in src
    assert "SerializationGate(False, False, True, True, True, False)" in src
    assert "self.hash_suite_selected" in src
    assert "self.bigint_backend_ready" in src
    assert "self.rational_normalization_ready" in src


def test_certificate_field_order_documented():
    doc = read(DOC)
    assert "A Misiurewicz certificate serializes as ordered fields" in doc
    assert "1. certificate schema id" in doc
    assert "10. incidence carrier" in doc
    assert "Map/dictionary iteration order is forbidden" in doc


def test_bigz_integer_encoding_is_concrete_and_canonical():
    src = read(BIGZ)
    doc = read(DOC)
    assert "def bigz_is_canonical" in src
    assert "def bigz_canonical_bytes" in src
    assert "unsigned 64-bit big-endian" in src
    assert "minimal big-endian magnitude" in doc
    assert "-1000000001 -> 02 0000000000000004 3b9aca01" in doc


def test_no_forbidden_serialization_shortcuts():
    src = read(SRC).lower()
    forbidden = ["float64", "json", "pickle", "object dump", "math.", "cmath", "numpy", "atan(", "radian", "degree"]
    for token in forbidden:
        assert token not in src
