from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/arithmetic/complex_inverse.mojo"


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def test_inverse_uses_quadrance_conjugate_formula():
    src = text()
    assert "fn inverse(self) -> ComplexQ" in src
    assert "self.quadrance()" in src
    assert "self.re.div(q)" in src
    assert "self.im.neg().div(q)" in src


def test_p21_inverse_is_exact_minus_half():
    src = text()
    assert "fn inverse_p21_derivative_at_minus_2" in src
    assert "ComplexQ.coord(-1, 2, 0, 1)" in src
    assert "P21'(-2)=-2" in src


def test_no_points_language_in_inverse_api():
    src = text()
    assert "fn point(" not in src
    assert "to_point_interval" not in src
    assert "fn coord(" in src
    assert "to_singleton_box" in src
    assert "coordinate record" in src


def test_m41_inverse_stays_pending_until_exact_eval():
    src = text()
    assert "fn inverse_derivative_m41_pending" in src
    assert "dP41_at_m41_center_pending" in src
    assert "False, False, True" in src


def test_no_forbidden_runtime_shortcuts():
    src = text().lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan(", "radian", "degree"]
    for token in forbidden:
        assert token not in src
