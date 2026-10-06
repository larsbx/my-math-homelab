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

This is the Python side of a differential pair; `kernel/separator.mojo` is the
Mojo side.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from fractions import Fraction
from typing import Union

from box_classifier import is_trap, step
from closed_interval import IQ, ComplexBox
from budget import DEFAULT_BIT_BUDGET, box_bits, within_budget

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


class SeparationVerdict(Enum):
    SEPARATED = "SEPARATED"
    UNSEPARATED = "UNSEPARATED"
    CAPPED = "CAPPED"


@dataclass(frozen=True, slots=True)
class Separation:
    """What a search found: separated, not separated through the level, or
    out of budget. The third is not the second, and reading it as the second
    is the one mistake this type exists to prevent."""

    verdict: SeparationVerdict
    step: int | None = None
    cut: Cut | None = None

    def decided(self) -> bool:
        return self.verdict is SeparationVerdict.SEPARATED


def search(
    left: ComplexBox,
    right: ComplexBox,
    c: ComplexBox,
    cuts: tuple[Cut, ...],
    level: int,
    bit_budget: int = DEFAULT_BIT_BUDGET,
) -> Separation:
    """Look for a cut and a step putting the two boxes on opposite sides.

    Three-valued and fail-closed, like every other search here. `CAPPED` means
    the coordinates outgrew the budget before the level ran out, and it is
    never evidence of non-separation.
    """
    if level < 0 or not (left.accepted() and right.accepted() and c.accepted()):
        return Separation(SeparationVerdict.CAPPED)
    here, there = left, right
    for index in range(level + 1):
        if not within_budget(bit_budget, here, there):
            return Separation(SeparationVerdict.CAPPED, index)
        for cut in cuts:
            if opposite(side(cut, here), side(cut, there)):
                return Separation(SeparationVerdict.SEPARATED, index, cut)
        here, there = step(here, c), step(there, c)
    return Separation(SeparationVerdict.UNSEPARATED, level)


def separated(left: ComplexBox, right: ComplexBox, c: ComplexBox, cuts: tuple[Cut, ...], level: int) -> bool:
    """Does the catalogue separate the two boxes within `level` steps?"""
    return search(left, right, c, cuts, level).decided()


def not_separated_through(
    left: ComplexBox,
    right: ComplexBox,
    c: ComplexBox,
    cuts: tuple[Cut, ...],
    level: int,
) -> bool:
    """The level-`k` non-separation predicate.

    True only on a completed search. A capped search is not non-separation,
    and this returns false for it rather than promoting an exhausted budget
    into a finding.

    Reflexive and symmetric, and **not** transitive: see section 5 of
    `docs/finite-separator.md`. It is a tolerance relation, so calling a class
    of it a fiber would be a leak, and nothing here does.
    """
    return search(left, right, c, cuts, level).verdict is SeparationVerdict.UNSEPARATED


def separating_level(
    left: ComplexBox,
    right: ComplexBox,
    c: ComplexBox,
    cuts: tuple[Cut, ...],
    level: int,
) -> int | None:
    """The least step at which the catalogue separates, or `None`."""
    found = search(left, right, c, cuts, level)
    return found.step if found.decided() else None


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


# --- permanent failure -----------------------------------------------------


def trap_images(trap: ComplexBox, c: ComplexBox, period: int) -> tuple[ComplexBox, ...]:
    """`T, F(T), ..., F^(p-1)(T)`: the boxes a trapped orbit cycles through."""
    if period < 1 or not (trap.accepted() and c.accepted()):
        return ()
    images, image = [], trap
    for _ in range(period):
        images.append(image)
        image = step(image, c)
    return tuple(images)


def side_compatible(cuts: tuple[Cut, ...], trap: ComplexBox, c: ComplexBox, period: int) -> bool:
    """Is every image of the trap on a decided side of every cut?

    Not the *same* side for different images, and not the same side for
    different cuts: only decided. That is all the theorem needs, because two
    orbits inside the same image box at the same step are on the same side of
    everything, whatever that side is.
    """
    images = trap_images(trap, c, period)
    if not images:
        return False
    return all(side(cut, image) != UNDECIDED for cut in cuts for image in images)


def iterate(box: ComplexBox, c: ComplexBox, steps: int) -> ComplexBox:
    """`F^steps(box)`, recomputed from the box."""
    for _ in range(steps):
        box = step(box, c)
    return box


def permanently_unseparated(
    left: ComplexBox,
    right: ComplexBox,
    c: ComplexBox,
    cuts: tuple[Cut, ...],
    trap: ComplexBox,
    period: int,
    entry: int,
) -> bool:
    """A finite witness that the catalogue never separates the two boxes.

    Never at any level, not merely up to one. The hypotheses are all finite:
    the trap is verified, its cycle of images is on decided sides of every
    cut, both boxes are inside the trap at the same step `entry`, and no cut
    separates them at any earlier step.

    The conclusion is about the **catalogue**, not about the points. It says
    this finite set of cuts cannot tell these two boxes apart, which is
    exactly what `docs/finite-separator.md` section 4 says is the only form
    the question can take.

    This is also where the budget stops mattering. A search cannot reach the
    levels a trapped orbit needs -- the coordinates outgrow it long before --
    and the theorem replaces that infinite tail with `p` box comparisons.
    """
    if entry < 0 or period < 1 or not (left.accepted() and right.accepted() and c.accepted()):
        return False
    if not is_trap(trap, c, period):
        return False
    if not side_compatible(cuts, trap, c, period):
        return False
    if entry > 0 and not not_separated_through(left, right, c, cuts, entry - 1):
        return False
    return iterate(left, c, entry).subset_of(trap) and iterate(right, c, entry).subset_of(trap)
