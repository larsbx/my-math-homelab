from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/dynamics/vertex_incidence.mojo"
AUDIT = ROOT / "tools" / "audit_no_points.py"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_point_is_vertex_of_vertices_not_analytic_singleton():
    src = read(SRC)
    assert "struct Vertex" in src
    assert "struct VertexSet" in src
    assert "struct PointVertex" in src
    assert "carrier: VertexSet" in src
    assert "self.carrier.finite() and self.is_incidence_only" in src


def test_misiurewicz_point_vertex_uses_finite_carrier():
    src = read(SRC)
    assert "fn misiurewicz_point_vertex" in src
    assert "RootHandle" in src
    assert "RayAddressSet" in src
    assert "DyadicBox" in src
    assert "VertexSet(poly_name" in src


def test_audit_allows_point_vertex_only():
    audit = read(AUDIT)
    assert "Point(?!Vertex)" in audit
    assert "PointVertex finite incidence" in audit
    assert "analytic point API" in audit


def test_no_forbidden_runtime_shortcuts_in_vertex_incidence():
    src = read(SRC).lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan(", "radian", "degree"]
    for token in forbidden:
        assert token not in src
