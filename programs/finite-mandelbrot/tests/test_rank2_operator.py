from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/arithmetic/rank2_operator.mojo"
DOC = ROOT / "docs" / "rank2-coordinate-substrate.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_rank2_substrate_doc_exists():
    doc = read(DOC)
    assert "Rank-2 Coordinate Substrate" in doc
    assert "coordinate record or vertex-data object" in doc
    assert "All of this is expressible with polynomial arithmetic only" in doc


def test_star_and_matrix_action_are_explicit():
    src = read(SRC)
    assert "struct Coord2" in src
    assert "fn star(self, other: Coord2) -> Coord2" in src
    assert "fn operator_matrix" in src
    assert "Matrix2Special(u.x, u.y.neg(), u.y, u.x)" in src
    assert "fn star_matches_matrix" in src


def test_quadrance_scaling_and_rotor_predicate():
    src = read(SRC)
    assert "fn quadrance_scaling_law" in src
    assert "v.star(u).quadrance()" in src
    assert "v.quadrance().mul(u.quadrance())" in src
    assert "fn is_rotor" in src
    assert "u.quadrance().eq(Q.one())" in src
    assert "demo_rotor_rational_3_4_5" in src


def test_mandelbrot_squaring_law_present():
    src = read(SRC)
    assert "fn mandelbrot_square" in src
    assert "fn mandelbrot_step" in src
    assert "fn square_quadrance_law" in src
    assert "z.quadrance().square()" in src


def test_no_analytic_geometry_or_point_primitive_language():
    src = read(SRC).lower()
    forbidden = [
        "float64",
        "math.",
        "cmath",
        "numpy",
        "atan(",
        "radian",
        "degree",
        "cos(",
        "sin(",
        "tan(",
        "struct point",
        "fn point",
        "point_eval",
    ]
    for token in forbidden:
        assert token not in src
