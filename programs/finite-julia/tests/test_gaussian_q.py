"""Laws the rank-2 coordinate record must satisfy, and the multiplier dichotomy."""

from fractions import Fraction as F
from itertools import product

import pytest

from gaussian_q import GQ, I, ONE, ZERO, is_root_of_unity

SAMPLE = [
    GQ.of(0),
    GQ.of(1),
    GQ.of(-1),
    GQ.of(0, 1),
    GQ.of(F(1, 2), F(-3, 4)),
    GQ.of(F(-7, 3), F(5, 11)),
    GQ.of(F(37, 100), F(4, 25)),
]

PAIRS = list(product(SAMPLE, SAMPLE))


@pytest.mark.parametrize("a,b", PAIRS)
def test_addition_and_multiplication_commute(a, b):
    assert a + b == b + a
    assert a * b == b * a


@pytest.mark.parametrize("a,b", PAIRS)
def test_quadrance_is_multiplicative(a, b):
    assert (a * b).quadrance() == a.quadrance() * b.quadrance()


@pytest.mark.parametrize("a", SAMPLE)
def test_ring_identities(a):
    assert a + ZERO == a
    assert a * ONE == a
    assert a - a == ZERO
    assert a.square() == a * a
    assert -(-a) == a


def test_distributivity():
    for a, b in PAIRS:
        for c in SAMPLE:
            assert a * (b + c) == a * b + a * c


@pytest.mark.parametrize("a", SAMPLE)
def test_quadrance_is_nonnegative_and_zero_only_at_zero(a):
    assert a.quadrance() >= 0
    assert (a.quadrance() == 0) == a.is_zero()


def unit_quadrance_from_triple(m: int, n: int) -> GQ:
    """`lam = ((m^2 - n^2) + 2mn i) / (m^2 + n^2)`, of quadrance exactly 1."""
    hypotenuse = m * m + n * n
    return GQ.of(F(m * m - n * n, hypotenuse), F(2 * m * n, hypotenuse))


TRIPLES = [(2, 1), (3, 2), (4, 1), (5, 2), (7, 3), (8, 5)]


@pytest.mark.parametrize("m,n", TRIPLES)
def test_pythagorean_multipliers_have_unit_quadrance(m, n):
    assert unit_quadrance_from_triple(m, n).quadrance() == 1


@pytest.mark.parametrize("m,n", TRIPLES)
def test_multiplier_dichotomy_corroborated(m, n):
    """Section 6 of the design analysis: a unit-quadrance element of Q(i) is a
    root of unity exactly when it is one of the four fourth roots of unity.

    A test cannot prove the lemma. It can check that no sampled non-member has
    a small power equal to one, which is what would break if the lemma were
    false in the direction the corpus relies on.
    """
    lam = unit_quadrance_from_triple(m, n)
    assert not is_root_of_unity(lam)
    power = ONE
    for _ in range(64):
        power = power * lam
        assert power != ONE


@pytest.mark.parametrize("root", [ONE, -ONE, I, -I])
def test_the_four_roots_of_unity_are_recognized(root):
    assert is_root_of_unity(root)
    assert root.quadrance() == 1
