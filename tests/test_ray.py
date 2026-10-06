"""Ray certificates on the real axis.

The statements are in `docs/ray-certificates.md`. What these cases pin is the
growth witness against the orbit it describes, the invariance of the real
segment, the refusal where there is no real fixed point, and the itinerary's
insistence on a decided word.
"""

from __future__ import annotations

from fractions import Fraction as F

import pytest

from closed_interval import ComplexBox
from julia_reference import step as point_step
from gaussian_q import GQ
from parameter_corpus import BY_KEY, REAL_RAYS
from chart import chart_step, contracts_to_infinity, to_chart_at_infinity
from ray import REAL_AXIS, advances_by, certify_real_rays, itineraries_differ, itinerary
from separator import NEGATIVE, POSITIVE, side

WITNESSES = [(key, *pair) for key, pair in REAL_RAYS.items()]


@pytest.mark.parametrize("key,outer,segment", WITNESSES, ids=[w[0] for w in WITNESSES])
def test_every_declared_witness_certifies(key, outer, segment):
    c = BY_KEY[key].c
    assert c.im == 0, "a real-axis witness needs a real parameter"
    assert certify_real_rays(c.re, outer, segment) is not None


@pytest.mark.parametrize("key,outer,segment", WITNESSES, ids=[w[0] for w in WITNESSES])
def test_the_growth_witness_is_a_lower_bound_on_the_advance(key, outer, segment):
    """`f(x) - x >= growth` everywhere on the half-line, so `n` steps move the
    point by at least `n * growth` and the orbit is unbounded without a limit."""
    c = BY_KEY[key].c.re
    witness = certify_real_rays(c, outer, segment)
    for offset in (F(0), F(1, 8), F(1), F(7), F(100)):
        for sign in (1, -1):
            x = sign * (witness.outer + offset)
            assert advances_by(witness, x) >= witness.growth
    point = GQ(witness.outer, F(0))
    for expected in range(1, 5):
        point = point_step(point, GQ(c, F(0)))
        assert point.re >= witness.outer + expected * witness.growth


@pytest.mark.parametrize("key,outer,segment", WITNESSES, ids=[w[0] for w in WITNESSES])
def test_the_real_segment_is_forward_invariant(key, outer, segment):
    c = BY_KEY[key].c.re
    for numerator in range(-16, 17):
        x = segment * F(numerator, 16)
        assert abs(x * x + c) <= segment


def test_a_point_inside_the_half_line_is_refused_by_the_advance():
    witness = certify_real_rays(F(-1), F(2), F(1))
    assert advances_by(witness, F(1)) is None
    assert advances_by(witness, F(-1)) is None


def test_the_parameter_with_no_real_fixed_point_is_refused():
    """At `c = 1` there is no real solution of `x^2 + 1 = x`, so the real axis
    carries no invariant segment and the certificate declines."""
    assert "escaping" not in REAL_RAYS
    assert BY_KEY["escaping"].c == GQ(F(1), F(0))
    for outer in (F(1), F(2), F(4)):
        for segment in (F(1, 4), F(1), F(2), F(8)):
            assert certify_real_rays(F(1), outer, segment) is None


@pytest.mark.parametrize("bad", [(F(1, 2), F(1)), (F(2), F(4)), (F(2), F(-1))])
def test_malformed_constants_are_refused(bad):
    outer, segment = bad
    assert certify_real_rays(F(-1), outer, segment) is None


def test_the_itinerary_is_a_word_or_nothing():
    """Conjugate boxes at a real parameter get mirrored words, and a box that
    straddles the axis gets none."""
    c = ComplexBox.singleton(-1)
    upper = ComplexBox.of(F(9, 8), F(5, 4), F(1, 8), F(1, 4))
    lower = ComplexBox.of(F(9, 8), F(5, 4), F(-1, 4), F(-1, 8))
    word = itinerary(upper, c, 3)
    mirrored = itinerary(lower, c, 3)
    assert word is not None and mirrored is not None
    assert word[0] == POSITIVE and mirrored[0] == NEGATIVE
    assert mirrored == tuple(-digit for digit in word)
    assert itineraries_differ(word, mirrored)

    straddling = ComplexBox.of(F(9, 8), F(5, 4), F(-1, 8), F(1, 8))
    assert side(REAL_AXIS, straddling) == 0
    assert itinerary(straddling, c, 3) is None
    assert not itineraries_differ(word, None)


def test_a_negative_step_count_is_refused():
    assert itinerary(ComplexBox.of(F(9, 8), F(5, 4), F(1, 8), F(1, 4)), ComplexBox.singleton(-1), -1) is None


# --- the chart at infinity, and a ray whose direction is not representable --


def test_the_chart_at_infinity_has_a_domain_and_enforces_it():
    """A chart is a division. A box straddling the origin has no reciprocal
    and gets a refusal rather than a caller contract."""
    assert not to_chart_at_infinity(ComplexBox.of(F(-1), F(1), F(-1), F(1))).accepted()
    assert to_chart_at_infinity(ComplexBox.of(F(2), F(3), F(0), F(0))).accepted()
    assert not chart_step(ComplexBox.refused(), ComplexBox.singleton(0)).accepted()


@pytest.mark.parametrize("c", [F(0), F(-1), F(1, 4)])
def test_infinity_is_a_superattracting_fixed_point_in_that_chart(c):
    """`u = 0` is fixed and the step contracts a box around it strictly, which
    is the `OUT` certificate in the shape the `IN` certificate already has."""
    around = ComplexBox.of(F(-1, 4), F(1, 4), F(-1, 4), F(1, 4))
    assert contracts_to_infinity(around, ComplexBox.singleton(c))
    fixed = chart_step(ComplexBox.singleton(0), ComplexBox.singleton(c))
    assert fixed.re.lo == fixed.re.hi == 0 and fixed.im.lo == fixed.im.hi == 0


def test_a_ray_whose_direction_is_not_a_coordinate_record_is_still_certified():
    """Angle `1/3` at `c = 0`. Its direction is `e^(2 pi i / 3)`, which rank 2
    cannot write down, and the certificate does not need it: the itinerary is
    `0.010101...` in binary, which is `1/3`."""
    c = ComplexBox.singleton(0)
    centre_re, centre_im = F(-1), F(17320508, 10000000)
    radius = F(1, 10 ** 6)
    box = ComplexBox.of(centre_re - radius, centre_re + radius, centre_im - radius, centre_im + radius)
    word = itinerary(box, c, 11)
    assert word == tuple(POSITIVE if index % 2 == 0 else NEGATIVE for index in range(12))


def test_the_budget_and_not_the_box_width_sets_the_depth():
    """Narrowing the box past a point buys no further digits, because exact
    iteration squares the coordinates and the budget runs out first. That is
    the wrapping effect setting the price."""
    c = ComplexBox.singleton(0)
    centre_re, centre_im = F(-1), F(17320508, 10000000)

    def depth(radius: F) -> int:
        box = ComplexBox.of(centre_re - radius, centre_re + radius, centre_im - radius, centre_im + radius)
        found = 0
        for steps in range(1, 16):
            if itinerary(box, c, steps) is None:
                break
            found = steps + 1
        return found

    assert depth(F(1, 10 ** 3)) < depth(F(1, 10 ** 6))
    assert depth(F(1, 10 ** 6)) == depth(F(1, 10 ** 9))


def test_a_spent_budget_yields_no_word_rather_than_a_short_one():
    c = ComplexBox.singleton(0)
    box = ComplexBox.of(F(-11, 10), F(-9, 10), F(17, 10), F(7, 4))
    assert itinerary(box, c, 3, bit_budget=1) is None
