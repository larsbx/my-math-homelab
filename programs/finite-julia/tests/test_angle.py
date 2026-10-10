"""Angle types on `Q/Z`, and the counting identity that meets the point side.

The statements are in `docs/angle-types-and-landing.md`. The closed forms are
checked against the orbit they describe rather than against examples, because
a formula that is wrong is wrong everywhere and a lucky example hides it.
"""

from __future__ import annotations

from fractions import Fraction as F

import pytest

from angle import (
    Angle,
    angles_of_type,
    double,
    has_type,
    orbit_term,
    period,
    preperiod,
    type_count,
)
from gaussian_q import GQ
from preperiodic import exact_multiplicity

SMALL = [(num, den) for den in range(1, 41) for num in range(den)]


@pytest.mark.parametrize("num,den", SMALL, ids=[f"{n}/{d}" for n, d in SMALL])
def test_the_closed_forms_are_the_orbit(num, den):
    """First repetition at exactly the stated preperiod, at exactly the
    stated period, and at no proper divisor of it."""
    t = Angle.of(num, den)
    l, k = preperiod(t), period(t)
    assert l >= 0 and k >= 1
    assert orbit_term(t, l + k).same(orbit_term(t, l))
    if l > 0:
        assert not orbit_term(t, l + k - 1).same(orbit_term(t, l - 1))
    for shorter in range(1, k):
        if k % shorter == 0:
            assert not orbit_term(t, l + shorter).same(orbit_term(t, l))


@pytest.mark.parametrize("l,k", [(0, 1), (0, 2), (1, 2), (2, 3), (3, 1)])
def test_the_count_is_the_number_of_angles(l, k):
    listed = angles_of_type(l, k)
    assert len(listed) == type_count(l, k)
    assert all(has_type(t, l, k) for t in listed)
    assert len({(t.num, t.den) for t in listed}) == len(listed)


def test_the_denominator_decides_the_type():
    """`t = p/q` with `q = 2^a m`: preperiod `a`, period `ord_m(2)`."""
    for num, den, expected in ((1, 3, (0, 2)), (1, 6, (1, 2)), (3, 8, (3, 1)), (1, 7, (0, 3)), (5, 12, (2, 2))):
        t = Angle.of(num, den)
        assert (preperiod(t), period(t)) == expected


def test_reduction_and_wrapping():
    assert Angle.of(5, 4).same(Angle.of(1, 4))
    assert Angle.of(-1, 4).same(Angle.of(3, 4))
    assert Angle.of(0, 7).same(Angle.of(0, 1))
    assert double(Angle.of(1, 2)).same(Angle.of(0, 1))


def test_refusals_are_values_and_do_not_agree():
    """Two refusals are not equal: agreeing to fail is not agreeing."""
    for bad in (Angle.of(1, 0), Angle.of(1, -3), Angle.of(1, (1 << 30) + 1)):
        assert not bad.accepted()
        assert bad.value() is None
        assert not bad.same(Angle.refused())
    assert preperiod(Angle.refused()) == -1
    assert period(Angle.refused()) == -1
    assert not has_type(Angle.refused(), 0, 1)
    assert type_count(0, 0) == -1 and type_count(-1, 1) == -1


# --- the counting identity -------------------------------------------------

CRITICAL = GQ(F(0), F(0))


@pytest.mark.parametrize("l,k", [(0, 1), (0, 2), (1, 1), (1, 2), (2, 2), (3, 1)])
def test_the_angle_count_and_the_critical_multiplicity_make_the_degree(l, k):
    """At `c = 0`: `2^l (2^k - 1) + mult_0 = 2^(l+k) = deg R^0_{l,k}`.

    The left summand is counted on the angle side and the right one on the
    point side, by Phase 2's exact recursion. Nothing here is imported: it is
    two finite counts that have to agree, and they do.
    """
    multiplicity = exact_multiplicity(CRITICAL, CRITICAL, l, k)
    assert multiplicity == 2 ** l
    assert type_count(l, k) + multiplicity == 2 ** (l + k)


def test_the_identity_is_arithmetic_and_holds_everywhere_it_is_stated():
    for l in range(0, 8):
        for k in range(1, 8):
            assert type_count(l, k) + 2 ** l == 2 ** (l + k)
