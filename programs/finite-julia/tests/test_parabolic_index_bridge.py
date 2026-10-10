"""Cross-repo low-q parabolic fixtures, recomputed exactly over Q(i)."""

from fractions import Fraction as F

import pytest

from gaussian_q import GQ, I, ONE
from jet import residual, vanishing_order
from parabolic_index import (
    LOW_Q_FIXTURES,
    fixed_point,
    mandelbrot_parameter,
    parabolic_index,
)


@pytest.mark.parametrize("lam,q,expected", LOW_Q_FIXTURES)
def test_parabolic_index_low_q_exact(lam, q, expected):
    assert parabolic_index(lam, q) == expected


def test_q4_translation_is_exactly_representable():
    lam = I
    assert fixed_point(lam) == GQ(F(0), F(1, 2))
    assert mandelbrot_parameter(lam) == GQ(F(1, 4), F(1, 2))


def test_q4_parabolic_residual_has_order_q_plus_one():
    lam = I
    z0 = fixed_point(lam)
    c = mandelbrot_parameter(lam)
    assert vanishing_order(residual(z0, c, 0, 4, 9)) == 5


def test_conjugate_q4_fixture_conjugates_the_index():
    forward = parabolic_index(I, 4)
    backward = parabolic_index(-I, 4)
    assert backward.re == forward.re
    assert backward.im == -forward.im


def test_non_root_of_unity_is_rejected():
    with pytest.raises(ValueError):
        parabolic_index(GQ.of(F(1, 2)), 4)
