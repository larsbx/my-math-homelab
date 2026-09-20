"""A finite separator: exact rational cuts, pulled back by the dynamics.

Specification: docs/rational-interval-arithmetic-spec.md, section 2.4.
Statements and what is given up: docs/finite-separator.md.

Phase 3's separator was to be built from landed ray pairs. A ray is a curve,
and a curve is not available in this layer, so `Separated_k^c` could not be
written down. This is the restatement: a **cut** is an exact rational linear
form, deciding which side of it a box lies on is the three-valued interval
sign of specification section 2.4, and the dynamics does the rest by pullback.

Soundness never depends on where a cut is drawn. Any line separates what it
separates, so a badly chosen cut is uninformative and never wrong. What is
given up is the identification of the resulting relation with the classical
fiber relation; `docs/finite-separator.md` section 5 says exactly what that
costs.

This is the Python side of a differential pair; `src/separator.mojo` is the
Mojo side.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Union

from box_classifier import step
from interval_box import IQ, ComplexBox

Scalar = Union[int, Fraction]

#: The three sides a box can be on. `0` is "the cut passes through the box",
#: which is the undecided answer and never a claim that the box is on the cut.
POSITIVE, NEGATIVE, UNDECIDED = 1, -1, 0


@dataclass(frozen=True, slots=True)
class Cut:
    """The rational linear form `a x + b y - e`, or a refusal.

    A cut is a declared witness, like a trap or a cycle. Unlike those it needs
    no verification beyond being well formed: the certificate below is sound
    for every line, so a cut can only be uninformative.
    """

    a: Fraction
    b: Fraction
    e: Fraction
    rejected: bool = False

    @staticmethod
    def of(a: Scalar, b: Scalar, e: Scalar = 0) -> "Cut":
        a, b, e = Fraction(a), Fraction(b), Fraction(e)
        return Cut(a, b, e, a == 0 and b == 0)

    @staticmethod
    def refused() -> "Cut":
        return Cut(Fraction(0), Fraction(0), Fraction(0), True)

    def accepted(self) -> bool:
        return not self.rejected

    def form(self, box: ComplexBox) -> IQ:
        """`a X + b Y - e` as an enclosure over the box."""
        if self.rejected or not box.accepted():
            return IQ.refused()
        scaled = box.re.mul(IQ.singleton(self.a)).add(box.im.mul(IQ.singleton(self.b)))
        return scaled.sub(IQ.singleton(self.e))


def side(cut: Cut, box: ComplexBox) -> int:
    """Which side of the cut the whole box is on, three-valued.

    `UNDECIDED` means the enclosure met the line, which is a statement about
    the enclosure and never about the points: a wide box meets a line whether
    or not any of its points is near it.
    """
    value = cut.form(box)
    if not value.accepted():
        return UNDECIDED
    if value.lo > 0:
        return POSITIVE
    if value.hi < 0:
        return NEGATIVE
    return UNDECIDED


def opposite(first: int, second: int) -> bool:
    """Are these two decided sides, and different?"""
    return first != UNDECIDED and second != UNDECIDED and first != second


def separated_at(
    left: ComplexBox,
    right: ComplexBox,
    c: ComplexBox,
    cuts: tuple[Cut, ...],
    level: int,
) -> tuple[int, Cut] | None:
    """The first `(step, cut)` that puts the two boxes on opposite sides.

    Returns `None` when the catalogue does not separate them through `level`,
    which is a statement about the catalogue and the level, never a claim that
    the boxes hold the same anything.
    """
    if level < 0 or not (left.accepted() and right.accepted() and c.accepted()):
        return None
    here, there = left, right
    for index in range(level + 1):
        for cut in cuts:
            if opposite(side(cut, here), side(cut, there)):
                return index, cut
        here, there = step(here, c), step(there, c)
    return None


def separated(left: ComplexBox, right: ComplexBox, c: ComplexBox, cuts: tuple[Cut, ...], level: int) -> bool:
    """Does the catalogue separate the two boxes within `level` steps?"""
    return separated_at(left, right, c, cuts, level) is not None


def not_separated_through(
    left: ComplexBox,
    right: ComplexBox,
    c: ComplexBox,
    cuts: tuple[Cut, ...],
    level: int,
) -> bool:
    """The level-`k` non-separation predicate.

    Reflexive and symmetric, and **not** transitive: see section 4 of
    `docs/finite-separator.md`. It is a tolerance relation, so calling a class
    of it a fiber would be a leak, and nothing here does.
    """
    return not separated(left, right, c, cuts, level)


def separating_level(
    left: ComplexBox,
    right: ComplexBox,
    c: ComplexBox,
    cuts: tuple[Cut, ...],
    level: int,
) -> int | None:
    """The least step at which the catalogue separates, or `None`."""
    found = separated_at(left, right, c, cuts, level)
    return None if found is None else found[0]


def cut_through(box: ComplexBox, a: Scalar, b: Scalar) -> Cut:
    """The cut with normal `(a, b)` through the centre of a box.

    The natural way to turn a certified point into a cut: Phase 2 hands back
    a box holding exactly one preperiodic point, and this draws a line through
    where that point is known to be. The direction is the caller's, because
    nothing in this layer prefers one.
    """
    if not box.accepted():
        return Cut.refused()
    a, b = Fraction(a), Fraction(b)
    return Cut.of(a, b, a * box.re.midpoint() + b * box.im.midpoint())


def coordinate_cut_between(left: ComplexBox, right: ComplexBox) -> Cut:
    """A cut separating two boxes that are disjoint in some coordinate.

    Boxes are axis aligned, so two that miss each other miss in a coordinate,
    and the line halfway between them in that coordinate has rational
    coefficients. This is what makes the adequacy statement of
    `docs/finite-separator.md` section 4 constructive rather than an appeal:
    the separating cut is written down, not asserted to exist.
    """
    if not (left.accepted() and right.accepted()):
        return Cut.refused()
    for normal, here, there in ((1, left.re, right.re), (0, left.im, right.im)):
        for first, second, orientation in ((here, there, 1), (there, here, -1)):
            if first.hi < second.lo:
                offset = (first.hi + second.lo) / 2
                return Cut.of(orientation * normal, orientation * (1 - normal), orientation * offset)
    return Cut.refused()
