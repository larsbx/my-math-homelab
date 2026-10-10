from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/polynomial/poly_interval_eval.mojo"


def read() -> str:
    return SRC.read_text(encoding="utf-8")


def conv(a, b):
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            out[i + j] += x * y
    return out


def test_general_horner_api_exists():
    src = read()
    assert "def eval_poly_ascending_horner_ciq" in src
    assert "def derivative_coeffs_ascending" in src
    assert "coefficient_order_ascending" in src
    assert "backend_certificate_ready: Bool" in src


def test_p21_coefficients_preserved():
    src = read()
    assert "return [0, 2, 1]" in src
    assert "P_{2,1}=C(C+2)=C^2+2C" in src


def test_p41_expanded_coefficients_match_factors():
    # C(C+2)(C^3+2C^2+2C+2)F7, ascending order.
    c = [0, 1]
    c_plus_2 = [2, 1]
    f3 = [2, 2, 2, 1]
    f7 = [2, 2, 4, 6, 6, 6, 4, 1]
    expected = conv(conv(conv(c, c_plus_2), f3), f7)
    assert expected == [0, 8, 20, 40, 68, 94, 114, 116, 94, 60, 28, 8, 1]
    assert "return [0, 8, 20, 40, 68, 94, 114, 116, 94, 60, 28, 8, 1]" in read()


def test_derivative_path_is_generated_not_hand_copied():
    src = read()
    assert "def p41_derivative_coeffs_ascending" in src
    assert "return derivative_coeffs_ascending(p41_coeffs_ascending())" in src
    assert "def eval_p41_derivative" in src


def test_no_forbidden_shortcuts_in_poly_interval_eval():
    src = read().lower()
    for token in ["float64", "math.", "cmath", "numpy", "atan", "radian"]:
        assert token not in src
