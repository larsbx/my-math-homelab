"""Scaled boxes: a separated exponent, outward rounding, and what it lifts.

The statements are in `docs/scaled-boxes.md`. The cases that matter are the
agreement with the exact method wherever both decide, and the sampled points,
because a backend that rounds is a backend that can round the wrong way.
"""

from __future__ import annotations

import random
from fractions import Fraction as F

import pytest

import scaled
from gaussian_q import GQ
from closed_interval import ComplexBox
from julia_reference import step as point_step
from ray import itinerary as exact_itinerary
from separator import NEGATIVE, POSITIVE, UNDECIDED

C0 = ComplexBox.singleton(0)
CENTRE_RE, CENTRE_IM = F(-1), F(17320508, 10000000)


def around(radius: F) -> ComplexBox:
    return ComplexBox.of(CENTRE_RE - radius, CENTRE_RE + radius, CENTRE_IM - radius, CENTRE_IM + radius)


def depth(method, box, *args) -> int:
    found = 0
    for steps in range(1, 60):
        if method(box, C0, steps, *args) is None:
            break
        found = steps + 1
    return found


def test_shifting_is_exact_in_both_directions():
    box = ComplexBox.of(F(3), F(5), F(-1), F(1))
    value = scaled.of(box)
    there = scaled.shift(value, 4)
    assert there.exponent == 4 and there.mantissa.re.lo == F(3, 16)
    back = scaled.shift(there, -4)
    assert back.exponent == 0 and back.mantissa.re.lo == F(3) and back.mantissa.re.hi == F(5)


def test_rounding_only_ever_widens():
    box = ComplexBox.of(F(1, 3), F(2, 3), F(-1, 7), F(1, 7))
    rounded = scaled.round_outward(scaled.of(box), 8).mantissa
    assert rounded.re.lo <= box.re.lo and box.re.hi <= rounded.re.hi
    assert rounded.im.lo <= box.im.lo and box.im.hi <= rounded.im.hi


def test_the_digit_is_scale_invariant():
    """`2^exponent` is positive, so it cannot move a point across the axis."""
    upper = scaled.ScaledBox(ComplexBox.of(F(1), F(2), F(1, 8), F(1, 4)), 40)
    lower = scaled.ScaledBox(ComplexBox.of(F(1), F(2), F(-1, 4), F(-1, 8)), -40)
    straddling = scaled.ScaledBox(ComplexBox.of(F(1), F(2), F(-1, 8), F(1, 8)), 0)
    assert upper.side_of_real_axis() == POSITIVE
    assert lower.side_of_real_axis() == NEGATIVE
    assert straddling.side_of_real_axis() == UNDECIDED
    assert scaled.refused().side_of_real_axis() == UNDECIDED


@pytest.mark.parametrize("radius", [F(1, 10 ** 3), F(1, 10 ** 6), F(1, 10 ** 9)])
def test_it_agrees_with_the_exact_method_wherever_both_decide(radius):
    box = around(radius)
    for steps in range(1, 12):
        exact, approximate = exact_itinerary(box, C0, steps), scaled.itinerary(box, C0, steps)
        if exact is not None and approximate is not None:
            assert exact == approximate


def test_sampled_points_are_on_the_reported_sides():
    rng = random.Random(3)
    checked = 0
    for _ in range(40):
        c = GQ(F(rng.randint(-8, 4), 8), F(rng.randint(-4, 4), 8))
        centre_re, centre_im = F(rng.randint(-24, 24), 8), F(rng.randint(-24, 24), 8)
        radius = F(1, rng.choice([64, 1024]))
        word = scaled.itinerary(
            ComplexBox.of(centre_re - radius, centre_re + radius, centre_im - radius, centre_im + radius),
            ComplexBox.singleton(c.re, c.im), 6,
        )
        if word is None:
            continue
        for _ in range(5):
            z = GQ(centre_re + F(rng.randint(-8, 8), 8) * radius, centre_im + F(rng.randint(-8, 8), 8) * radius)
            for digit in word:
                assert (z.im > 0) if digit == POSITIVE else (z.im < 0)
                z = point_step(z, c)
                checked += 1
    assert checked > 200


def test_the_exact_method_gets_worse_with_a_narrower_box_and_the_scaled_one_better():
    """The sign of the relationship is the finding: a certificate should do
    better with more input, and the budget had it doing worse."""
    assert depth(exact_itinerary, around(F(1, 10 ** 24))) < depth(exact_itinerary, around(F(1, 10 ** 6)))
    assert depth(scaled.itinerary, around(F(1, 10 ** 24)), 200) > depth(scaled.itinerary, around(F(1, 10 ** 6)), 200)


def test_the_separated_exponent_lifts_the_ceiling():
    """Section 3. The exact method stops where the value needs more bits than
    the budget allows; the scaled one stops where the box runs out of
    information, which is the constraint a certificate should have."""
    assert depth(scaled.itinerary, around(F(1, 10 ** 12))) > 2 * depth(exact_itinerary, around(F(1, 10 ** 12)))
    assert depth(scaled.itinerary, around(F(1, 10 ** 12))) > depth(scaled.itinerary, around(F(1, 10 ** 6)))


def test_precision_is_a_dial_once_the_exponent_stops_binding():
    """At a radius where the box's own width binds first, precision changes
    nothing; at a narrower one it does. An earlier draft of the note claimed
    only the first half, measured at the radius where it happens to hold."""
    assert depth(scaled.itinerary, around(F(1, 10 ** 12)), 53) == depth(scaled.itinerary, around(F(1, 10 ** 12)), 200)
    assert depth(scaled.itinerary, around(F(1, 10 ** 48)), 200) > depth(scaled.itinerary, around(F(1, 10 ** 48)), 53)


def test_the_parameter_term_is_not_built_where_it_underflows():
    """Section 3.1: the comparison is on bit lengths, so no large power is
    constructed to decide it."""
    tiny = scaled.parameter_at(ComplexBox.singleton(-1), 4096, 53)
    assert tiny.re.lo == -tiny.re.hi and tiny.re.hi.denominator.bit_length() <= 56
    exact = scaled.parameter_at(ComplexBox.singleton(-1), 8, 53)
    assert exact.re.lo == exact.re.hi == F(-1, 256)


def test_refusals_are_values():
    assert not scaled.refused().accepted()
    assert not scaled.shift(scaled.refused(), 3).accepted()
    assert not scaled.normalise(scaled.refused()).accepted()
    assert not scaled.step(scaled.refused(), C0).accepted()
    assert scaled.itinerary(around(F(1, 8)), C0, -1) is None
    assert scaled.itinerary(ComplexBox.refused(), C0, 3) is None
