"""The enclosure-width lemma, against the interval step it bounds.

The proofs are in `docs/enclosure-width-lemma.md`; these cases check the
inequalities against what the arithmetic actually does, on boxes chosen to
include the awkward ones -- straddling zero, touching the confinement square,
and degenerate.
"""

from __future__ import annotations

import random
from fractions import Fraction as F

import pytest

from box_classifier import refine_until_decided, step
from enclosure_bound import (
    bounded_orbit_hypothesis,
    coarse_step_factor,
    iterated_radius_bound,
    orbit_gap_bound,
    quadrance_drift_bound,
    refinement_radius,
    step_radius_bound,
    sufficient_radius,
    sup_magnitude,
    sup_radius,
    within,
)
from gaussian_q import GQ
from closed_interval import ComplexBox
from julia_reference import step as point_step


def boxes_within(bound: F, count: int, seed: int) -> list[tuple[ComplexBox, ComplexBox]]:
    """Deterministic boxes inside the square, paired with a parameter in it."""
    rng = random.Random(seed)
    pairs = []
    while len(pairs) < count:
        def coordinate() -> tuple[F, F]:
            lo = F(rng.randint(-int(bound) * 8, int(bound) * 8), 8)
            return lo, min(lo + F(rng.randint(0, 16), 16), bound)
        re_lo, re_hi = coordinate()
        im_lo, im_hi = coordinate()
        box = ComplexBox.of(re_lo, re_hi, im_lo, im_hi)
        c = ComplexBox.singleton(F(rng.randint(-8, 8), 8), F(rng.randint(-8, 8), 8))
        if box.accepted() and within(box, bound):
            pairs.append((box, c))
    return pairs


@pytest.mark.parametrize("bound", [F(1), F(2), F(5), F(21, 2)])
def test_the_one_step_bound_holds(bound):
    for box, c in boxes_within(bound, 120, seed=int(bound * 2)):
        assert sup_radius(step(box, c)) <= step_radius_bound(bound, sup_radius(box))


@pytest.mark.parametrize("bound", [F(1), F(2), F(5)])
def test_the_coarse_factor_dominates_the_sharp_bound(bound):
    for box, _ in boxes_within(bound, 60, seed=7):
        radius = sup_radius(box)
        assert step_radius_bound(bound, radius) <= coarse_step_factor(bound) * radius


def test_a_degenerate_box_stays_degenerate():
    singleton = ComplexBox.singleton(F(1, 3), F(-2, 5))
    assert sup_radius(step(singleton, ComplexBox.singleton(F(1, 7)))) == 0


@pytest.mark.parametrize("bound,steps", [(F(2), 3), (F(3), 4), (F(5), 2)])
def test_the_iterated_bound_and_the_orbit_gap_hold(bound, steps):
    """While the iterates stay confined, the enclosure tracks the orbit of any
    point it contains, to the stated distance."""
    for box, c in boxes_within(bound, 40, seed=steps * 11):
        radius = sup_radius(box)
        image, point = box, GQ(box.re.midpoint(), box.im.midpoint())
        parameter = GQ(c.re.lo, c.im.lo)
        for n in range(1, steps + 1):
            if not within(image, bound):
                break
            image, point = step(image, c), point_step(point, parameter)
            assert sup_radius(image) <= iterated_radius_bound(bound, n, radius)
            assert image.re.lo <= point.re <= image.re.hi
            assert image.im.lo <= point.im <= image.im.hi
            gap = max(
                abs(image.re.lo - point.re), abs(image.re.hi - point.re),
                abs(image.im.lo - point.im), abs(image.im.hi - point.im),
            )
            assert gap <= orbit_gap_bound(bound, n, radius)


@pytest.mark.parametrize("bound,steps", [(F(4), 4), (F(2), 6)])
def test_the_confinement_induction_holds(bound, steps):
    """A box small enough for the hypothesis cannot leave the square before the
    step count runs out, provided the orbit it follows stays a unit inside."""
    radius = sufficient_radius(bound, steps, F(1))
    assert bounded_orbit_hypothesis(bound, steps, radius)
    centre = GQ(F(1, 4), F(1, 4))
    box = ComplexBox.of(centre.re - radius, centre.re + radius, centre.im - radius, centre.im + radius)
    parameter = GQ(F(-1), F(0))
    image, point = box, centre
    for _ in range(steps):
        image, point = step(image, ComplexBox.singleton(F(-1))), point_step(point, parameter)
        if max(abs(point.re), abs(point.im)) > bound - 1:
            break
        assert within(image, bound)


def test_sufficient_radius_meets_its_margin():
    for steps in range(0, 5):
        radius = sufficient_radius(F(3), steps, F(1, 10))
        assert orbit_gap_bound(F(3), steps, radius) <= F(1, 10)


@pytest.mark.parametrize("bad", [F(0), F(-1)])
def test_a_nonpositive_margin_is_refused(bad):
    with pytest.raises(ValueError):
        sufficient_radius(F(2), 3, bad)


def test_negative_step_counts_are_refused():
    with pytest.raises(ValueError):
        iterated_radius_bound(F(2), -1, F(1, 4))


C0 = ComplexBox.singleton(0)
TRAP = ComplexBox.of(F(-1, 4), F(1, 4), F(-1, 4), F(1, 4))
STRADDLING = ComplexBox.of(F(15, 16), F(17, 16), F(0), F(1, 16))


def test_refinement_decides_a_box_away_from_the_julia_set_at_once():
    outside = refine_until_decided(ComplexBox.of(F(3, 2), F(7, 4), F(3, 2), F(7, 4)), C0, TRAP, 1, max_depth=0)
    inside = refine_until_decided(ComplexBox.of(F(-1, 16), F(1, 16), F(-1, 16), F(1, 16)), C0, TRAP, 1, max_depth=0)
    assert outside.decided() and outside.out == 1
    assert inside.decided() and inside.inside == 1


def test_the_undecided_share_never_grows_with_depth():
    """Refinement is monotone: a decided leaf is never revisited."""
    previous = F(1)
    for depth in range(4):
        share = refine_until_decided(STRADDLING, C0, TRAP, 1, max_depth=depth).undecided_fraction
        assert share <= previous
        previous = share


def test_the_undecided_share_falls_on_a_boundary_box():
    """Behaviour, not evidence: the theorems are proved, and this only shows
    what they cost on one box."""
    shallow = refine_until_decided(STRADDLING, C0, TRAP, 1, max_depth=2)
    deep = refine_until_decided(STRADDLING, C0, TRAP, 1, max_depth=4)
    assert deep.undecided_fraction < shallow.undecided_fraction / 2
    assert deep.deepest == 4 and deep.leaves() > shallow.leaves()


@pytest.mark.parametrize("bound", [F(1), F(2), F(5)])
def test_quadrance_moves_by_at_most_the_drift_bound(bound):
    """Section 4(b), against pairs of points that stay inside the square."""
    rng = random.Random(int(bound) * 31)
    coordinate = lambda: F(rng.randint(-int(bound) * 8, int(bound) * 8), 8)
    checked = 0
    for _ in range(300):
        point = GQ(coordinate(), coordinate())
        distance = F(rng.randint(1, 8), 8)
        offset = lambda: F(rng.randint(-8, 8), 8) * distance
        shifted = GQ(point.re + offset(), point.im + offset())
        if max(abs(shifted.re), abs(shifted.im)) > bound:
            continue
        assert abs(shifted.quadrance() - point.quadrance()) <= quadrance_drift_bound(bound, distance)
        checked += 1
    assert checked > 100, "the sampling must exercise the bound, not skip it"


@pytest.mark.parametrize("bound,steps,margin", [
    (F(2), 2, F(1)), (F(4), 3, F(1, 3)), (F(1), 0, F(1, 10)),
])
def test_the_refinement_radius_is_what_the_theorem_asks_for(bound, steps, margin):
    """Section 5's `s`: small enough to confine the enclosure, and small
    enough that the drift over `steps` spends less than the margin."""
    s = refinement_radius(bound, steps, margin)
    assert s == margin / (12 * bound * coarse_step_factor(bound) ** steps)
    assert bounded_orbit_hypothesis(bound, steps, s)
    assert quadrance_drift_bound(bound, orbit_gap_bound(bound, steps, s)) <= margin


@pytest.mark.parametrize("bad", [F(0), F(-3), F(2)])
def test_a_margin_outside_the_unit_range_is_refused(bad):
    with pytest.raises(ValueError):
        refinement_radius(F(2), 3, bad)


@pytest.mark.parametrize("centre,steps", [
    (GQ(F(3, 2), F(0)), 1),
    (GQ(F(7, 4), F(1, 4)), 1),
    (GQ(F(-2), F(1, 3)), 0),
])
def test_the_theorem_puts_the_whole_enclosure_past_the_escape_bound(centre, steps):
    """Section 5(OUT) at `c = 0`, where the escape bound is `4`.

    The orbit of the centre clears the bound by `delta`; the theorem's radius
    is what makes the *enclosure* clear it too, which is the only thing the
    classifier can read.
    """
    c, parameter, escape = ComplexBox.singleton(F(0)), GQ(F(0), F(0)), F(4)
    point, reach = centre, max(abs(centre.re), abs(centre.im))
    for _ in range(steps):
        point = point_step(point, parameter)
        reach = max(reach, abs(point.re), abs(point.im))
    margin = min(F(1), point.quadrance() - escape)
    assert margin > 0, "the centre must escape for the theorem to say anything"

    bound = reach + 1
    radius = refinement_radius(bound, steps, margin)
    box = ComplexBox.of(centre.re - radius, centre.re + radius,
                        centre.im - radius, centre.im + radius)
    image = box
    for _ in range(steps):
        assert within(image, bound)
        image = step(image, c)
    assert image.quadrance().lo > escape


def test_a_rejected_box_has_no_radius():
    """A refused box is not a converged one.

    The local interval copies answered width `0` for a rejected interval and
    magnitude `0` for a rejected box, so a refusal measured as a point. Both
    sides now refuse: the vendored `finite_exact.enclosure_width` returns a
    rejected value, and these raise. Neither box lies within any bound.
    """
    with pytest.raises(ValueError):
        sup_radius(ComplexBox.refused())
    with pytest.raises(ValueError):
        sup_magnitude(ComplexBox.refused())
    assert not within(ComplexBox.refused(), 100)
