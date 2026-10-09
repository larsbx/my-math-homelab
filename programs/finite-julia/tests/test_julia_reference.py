"""The checker's verdicts, and the budgets it refuses to exceed."""

from fractions import Fraction as F

import pytest

from gaussian_q import GQ, I, ONE
from julia_reference import (
    CapReason,
    DEFAULT_BIT_BUDGET,
    MultiplierClass,
    OrbitVerdict,
    classify_multiplier,
    critical_orbit,
    escape_bound_quadrance,
    escapes_at,
    indifferent_fixed_parameter,
    is_cycle,
    multiplier,
    step,
)


def test_escape_bound_is_the_larger_of_four_and_the_parameter_quadrance():
    assert escape_bound_quadrance(GQ.of(0)) == 4
    assert escape_bound_quadrance(GQ.of(F(1, 4))) == 4
    assert escape_bound_quadrance(GQ.of(-3)) == 9
    assert escape_bound_quadrance(GQ.of(3, 4)) == 25


def test_escape_is_absorbing_on_the_sampled_horizon():
    """Past the bound the quadrance grows; a certified OUT never comes back."""
    c = GQ.of(1)
    z = GQ.of(0)
    for _ in range(3):
        z = step(z, c)
    assert escapes_at(z, c)
    previous = z.quadrance()
    for _ in range(6):
        z = step(z, c)
        assert escapes_at(z, c)
        assert z.quadrance() > previous
        previous = z.quadrance()


def test_preperiodic_verdict_is_exact():
    orbit = critical_orbit(I)
    assert orbit.verdict is OrbitVerdict.PREPERIODIC
    assert (orbit.preperiod, orbit.period) == (2, 2)
    assert orbit.decided()


def test_escaping_verdict_names_the_first_index():
    orbit = critical_orbit(GQ.of(1))
    assert orbit.verdict is OrbitVerdict.ESCAPES
    assert orbit.escape_index == 3
    assert orbit.decided()


def test_an_exhausted_budget_is_not_a_verdict():
    orbit = critical_orbit(GQ.of(F(1, 4)))
    assert orbit.verdict is OrbitVerdict.CAPPED
    assert not orbit.decided()
    assert orbit.cap_reason is CapReason.BIT_BUDGET


def test_a_short_horizon_caps_rather_than_deciding():
    orbit = critical_orbit(GQ.of(F(1, 4)), horizon=3, bit_budget=DEFAULT_BIT_BUDGET)
    assert orbit.verdict is OrbitVerdict.CAPPED
    assert orbit.cap_reason is CapReason.HORIZON
    assert orbit.steps_taken == 3


def test_a_tight_bit_budget_caps_earlier_than_the_horizon():
    orbit = critical_orbit(GQ.of(F(1, 4)), horizon=64, bit_budget=32)
    assert orbit.cap_reason is CapReason.BIT_BUDGET
    assert orbit.steps_taken is not None and orbit.steps_taken < 64


@pytest.mark.parametrize("bad", [dict(horizon=0), dict(bit_budget=0)])
def test_invalid_budgets_are_rejected(bad):
    with pytest.raises(ValueError):
        critical_orbit(GQ.of(0), **bad)


def test_a_capped_budget_never_reports_a_period():
    orbit = critical_orbit(GQ.of(F(-3, 4)), horizon=5, bit_budget=DEFAULT_BIT_BUDGET)
    assert orbit.period is None and orbit.preperiod is None and orbit.escape_index is None


def test_is_cycle_rejects_a_repeated_element():
    assert not is_cycle(GQ.of(-1), (GQ.of(0), GQ.of(0)))


def test_is_cycle_rejects_a_non_orbit():
    assert not is_cycle(GQ.of(-1), (GQ.of(0), GQ.of(1)))


def test_is_cycle_accepts_the_basilica_cycle():
    assert is_cycle(GQ.of(-1), (GQ.of(0), GQ.of(-1)))


def test_multiplier_of_a_superattracting_cycle_is_zero():
    assert multiplier((GQ.of(0), GQ.of(-1))).is_zero()


@pytest.mark.parametrize(
    "lam,expected",
    [
        (GQ.of(0), MultiplierClass.SUPERATTRACTING),
        (GQ.of(F(1, 2)), MultiplierClass.ATTRACTING),
        (GQ.of(F(3, 5), F(4, 5)), MultiplierClass.IRRATIONALLY_INDIFFERENT),
        (ONE, MultiplierClass.PARABOLIC),
        (-ONE, MultiplierClass.PARABOLIC),
        (I, MultiplierClass.PARABOLIC),
        (-I, MultiplierClass.PARABOLIC),
        (GQ.of(2), MultiplierClass.REPELLING),
        (GQ.of(4, 4), MultiplierClass.REPELLING),
    ],
)
def test_multiplier_classification(lam, expected):
    assert classify_multiplier(lam) is expected


@pytest.mark.parametrize("lam", [ONE, -ONE, I, -I, GQ.of(F(3, 5), F(4, 5)), GQ.of(F(-3, 5), F(4, 5))])
def test_cardioid_parameterization_produces_the_declared_multiplier(lam):
    """`c = lam (2 - lam) / 4` has the fixed point `lam / 2` with multiplier `lam`."""
    c = indifferent_fixed_parameter(lam)
    fixed = lam.scale(F(1, 2))
    assert step(fixed, c) == fixed
    assert multiplier((fixed,)) == lam
