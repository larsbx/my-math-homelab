"""The finite separator: cuts, sides, the pullback, and the tolerance warning.

The statements are in `docs/finite-separator.md`. What these cases pin is the
soundness direction, the monotone nest, the constructive adequacy cut, and
the failure of transitivity -- the last because a relation people will want to
call a fiber relation is not one, and nothing should let that slip.
"""

from __future__ import annotations

from fractions import Fraction as F

import pytest

from box_classifier import step
from gaussian_q import GQ
from interval_box import ComplexBox
from julia_reference import step as point_step
from separator import (
    NEGATIVE,
    POSITIVE,
    UNDECIDED,
    Cut,
    coordinate_cut_between,
    cut_through,
    not_separated_through,
    opposite,
    separated,
    separated_at,
    separating_level,
    side,
)

C0 = ComplexBox.singleton(0)
VERTICAL = Cut.of(1, 0, 0)
RIGHT = ComplexBox.of(F(7, 16), F(9, 16), F(-1, 16), F(1, 16))
LEFT = ComplexBox.of(F(-9, 16), F(-7, 16), F(-1, 16), F(1, 16))
MIDDLE = ComplexBox.of(F(-1, 16), F(1, 16), F(-1, 16), F(1, 16))
UPWARD = ComplexBox.of(F(-1, 16), F(1, 16), F(7, 16), F(9, 16))


def test_the_three_sides():
    assert side(VERTICAL, RIGHT) == POSITIVE
    assert side(VERTICAL, LEFT) == NEGATIVE
    assert side(VERTICAL, MIDDLE) == UNDECIDED
    assert not opposite(POSITIVE, UNDECIDED) and opposite(POSITIVE, NEGATIVE)


def test_a_degenerate_or_malformed_cut_is_refused_as_a_value():
    for bad in (Cut.of(0, 0, 1), Cut.refused(), cut_through(ComplexBox.refused(), 1, 0)):
        assert not bad.accepted()
        assert side(bad, RIGHT) == UNDECIDED
        assert not separated(RIGHT, LEFT, C0, (bad,), 4)


def test_separation_is_a_statement_about_every_point_of_both_boxes():
    """Soundness: sampled points really do land on opposite sides."""
    found = separated_at(RIGHT, UPWARD, C0, (VERTICAL,), 4)
    assert found is not None
    steps, cut = found
    assert steps == 1, "the pullback is what decides this pair, not step zero"
    for here, there in ((GQ(F(1, 2), F(0)), GQ(F(0), F(1, 2))), (GQ(F(9, 16), F(1, 16)), GQ(F(-1, 16), F(7, 16)))):
        for _ in range(steps):
            here, there = point_step(here, GQ(F(0), F(0))), point_step(there, GQ(F(0), F(0)))
        assert (cut.a * here.re + cut.b * here.im - cut.e) > 0
        assert (cut.a * there.re + cut.b * there.im - cut.e) < 0


@pytest.mark.parametrize("level", range(0, 6))
def test_the_nest_is_monotone(level):
    """Separated at a level means separated at every level above it."""
    earliest = separating_level(RIGHT, UPWARD, C0, (VERTICAL,), 5)
    assert earliest is not None
    assert separated(RIGHT, UPWARD, C0, (VERTICAL,), level) == (level >= earliest)


def test_non_separation_is_reflexive_and_symmetric():
    for box in (RIGHT, LEFT, MIDDLE):
        assert not_separated_through(box, box, C0, (VERTICAL,), 6)
    assert separated(RIGHT, LEFT, C0, (VERTICAL,), 3) == separated(LEFT, RIGHT, C0, (VERTICAL,), 3)


@pytest.mark.parametrize("level", [0, 2, 5, 9])
def test_non_separation_is_not_transitive(level):
    """The triple of `docs/finite-separator.md` section 5. The middle box is a
    trap at the origin, so it straddles the cut forever and is never
    separated from either side, while the outer two separate at once."""
    assert not_separated_through(RIGHT, MIDDLE, C0, (VERTICAL,), level)
    assert not_separated_through(MIDDLE, LEFT, C0, (VERTICAL,), level)
    assert not not_separated_through(RIGHT, LEFT, C0, (VERTICAL,), level)


def test_the_adequacy_cut_is_constructed_not_asserted():
    """Disjoint boxes are disjoint in a coordinate, and the cut is written."""
    for left, right in ((RIGHT, LEFT), (RIGHT, UPWARD), (UPWARD, LEFT)):
        cut = coordinate_cut_between(left, right)
        assert cut.accepted()
        assert separated(left, right, C0, (cut,), 0)
    assert not coordinate_cut_between(RIGHT, ComplexBox.of(F(0), F(1), F(0), F(1))).accepted()


def test_a_cut_through_a_certified_point_separates_it_from_a_far_box():
    """The intended use: Phase 2 hands back a box holding one root, and a cut
    is drawn through where that root is known to be."""
    root = ComplexBox.of(F(7, 8), F(9, 8), F(-1, 8), F(1, 8))
    cut = cut_through(root, 1, 0)
    assert side(cut, root) == UNDECIDED, "the cut passes through its own box"
    assert side(cut, ComplexBox.of(F(2), F(3), F(0), F(0))) == POSITIVE
    assert separated(ComplexBox.of(F(2), F(3), F(0), F(0)), LEFT, C0, (cut,), 0)


def test_a_catalogue_separates_what_any_of_its_cuts_separates():
    horizontal = Cut.of(0, 1, 0)
    assert not separated(RIGHT, UPWARD, C0, (horizontal,), 0)
    assert separated(RIGHT, UPWARD, C0, (horizontal, VERTICAL), 1)
    assert separating_level(RIGHT, UPWARD, C0, (horizontal, VERTICAL), 4) == 1


def test_a_negative_level_is_refused():
    assert not separated(RIGHT, LEFT, C0, (VERTICAL,), -1)
    assert separating_level(RIGHT, LEFT, C0, (VERTICAL,), -1) is None
