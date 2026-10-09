"""Independent Fraction oracle for polynomial evaluation and division."""
from fractions import Fraction as F
from psc_research.pip_screen import _eval, _rem


def horner(p, x):
    acc = F(0)
    for coefficient in reversed(p):
        acc = acc * x + coefficient
    return acc


def test_evaluation_equivalence():
    for n in range(9):
        p = [F((i * 7) % 11 - 5, i + 1) for i in range(n)]
        for numerator in range(-4, 5):
            x = F(numerator, 3)
            assert _eval(p, x) == horner(p, x)


def test_repeated_degree_descent():
    a = list(map(F, [3, 0, 2, 0, 2, 0, 2, 0, 0]))
    b = list(map(F, [0, 0, 2, 0]))
    assert _rem(a, b) == [F(3)] + [F(0)] * 8
