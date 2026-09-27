"""Truncated Taylor jets over `Q(i)`.

The statements are in `docs/preperiodic-certificates.md` section 4. These
cases check the jet against derivatives computed another way, because a jet
that is wrong is wrong quietly: every coefficient is a plausible rational.
"""

from __future__ import annotations

from fractions import Fraction as F

import pytest

from gaussian_q import GQ
from jet import add, constant, mul, orbit, residual, seed, step, sub, vanishing_order
from preperiodic import exact_residual, exact_residual_derivative

C0, CI = GQ(F(0), F(0)), GQ(F(0), F(1))


def test_the_seed_is_the_variable_and_a_constant_does_not_vary():
    point = GQ(F(3), F(-2))
    assert seed(point, 3) == (point, GQ.of(1), GQ.of(0), GQ.of(0))
    assert constant(point, 2) == (point, GQ.of(0), GQ.of(0))
    assert seed(point, 0) == (point,)


def test_truncated_multiplication_drops_and_does_not_round():
    """`(1 + e)^2 = 1 + 2e + e^2`, and at order one the square term is not
    part of the object rather than being computed wrongly."""
    one_plus = (GQ.of(1), GQ.of(1), GQ.of(0))
    assert mul(one_plus, one_plus) == (GQ.of(1), GQ.of(2), GQ.of(1))
    assert mul(one_plus[:2], one_plus[:2]) == (GQ.of(1), GQ.of(2))
    assert add(one_plus, one_plus) == (GQ.of(2), GQ.of(2), GQ.of(0))
    assert sub(one_plus, one_plus) == (GQ.of(0), GQ.of(0), GQ.of(0))


@pytest.mark.parametrize("point", [GQ(F(1, 3), F(0)), GQ(F(0), F(1)), GQ(F(-2), F(5, 7))])
@pytest.mark.parametrize("steps", [0, 1, 2, 3])
def test_the_jets_first_two_coefficients_are_the_value_and_the_derivative(point, steps):
    """Order zero is `f^n(z)` and order one is `(f^n)'(z)`, which the chain
    rule computes separately in `reference/preperiodic.py`."""
    state = orbit(point, CI, steps, 2)
    value = point
    for _ in range(steps):
        value = value * value + CI
    assert state[0] == value
    derivative, running = GQ.of(1), point
    for _ in range(steps):
        derivative = derivative * running.scale(2)
        running = running * running + CI
    assert state[1] == derivative


@pytest.mark.parametrize("l,k", [(0, 1), (1, 1), (0, 2), (2, 2)])
def test_the_residual_jet_agrees_with_the_point_evaluations(l, k):
    point = GQ(F(1, 2), F(1, 3))
    state = residual(point, CI, l, k, 2)
    assert state[0] == exact_residual(point, CI, l, k)
    assert state[1] == exact_residual_derivative(point, CI, l, k)


def test_a_step_is_the_square_plus_the_parameter():
    point = GQ(F(1, 5), F(2, 5))
    assert step(seed(point, 2), CI) == orbit(point, CI, 1, 2)


def test_the_vanishing_order_is_the_first_nonzero_coefficient():
    assert vanishing_order((GQ.of(0), GQ.of(0), GQ.of(3))) == 2
    assert vanishing_order((GQ.of(7), GQ.of(0))) == 0
    assert vanishing_order((GQ.of(0), GQ.of(0))) is None
    assert vanishing_order(None) is None


@pytest.mark.parametrize("bad", [(-1, 1, 2), (0, 0, 2), (0, 1, -1)])
def test_a_malformed_request_is_refused_as_a_value(bad):
    l, k, order = bad
    assert residual(GQ(F(0), F(0)), C0, l, k, order) is None
    assert orbit(GQ(F(0), F(0)), C0, -1, 2) is None
