"""How far an enclosure can drift from the orbit it encloses.

Specification: docs/rational-interval-arithmetic-spec.md.
Statements and proofs: docs/enclosure-width-lemma.md.

The classifier's certificates fire on the *enclosure*, not on the points it
encloses, so soundness alone leaves open whether refining a box ever helps.
The bounds here close that: an enclosure inside `[-M, M]^2` grows by at most
`6M` per step, so for a fixed number of steps a small enough box stays as
close to the orbit of any of its points as one likes.

Everything is exact rational arithmetic. No bound below is a limit statement:
each is an inequality between two rationals that a caller can check.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Union

from interval_box import ComplexBox

Scalar = Union[int, Fraction]


def sup_radius(box: ComplexBox) -> Fraction:
    """Half the larger coordinate width: the radius in the sup norm."""
    return max(box.re.width(), box.im.width()) / 2


def sup_magnitude(box: ComplexBox) -> Fraction:
    """The largest coordinate magnitude the box reaches."""
    return max(abs(box.re.lo), abs(box.re.hi), abs(box.im.lo), abs(box.im.hi))


def within(box: ComplexBox, bound: Scalar) -> bool:
    """Does the box lie inside the square of half-side `bound`?"""
    return box.accepted() and sup_magnitude(box) <= Fraction(bound)


def step_radius_bound(bound: Scalar, radius: Scalar) -> Fraction:
    """`4 M r + 2 r^2`, the sharp form of the one-step bound."""
    bound, radius = Fraction(bound), Fraction(radius)
    return 4 * bound * radius + 2 * radius * radius


def coarse_step_factor(bound: Scalar) -> Fraction:
    """`6 M`: the one-step bound with `r <= M` folded in, so it composes."""
    return 6 * Fraction(bound)


def iterated_radius_bound(bound: Scalar, steps: int, radius: Scalar) -> Fraction:
    """`(6 M)^n r`, valid while every iterate stays inside the `M` square."""
    if steps < 0:
        raise ValueError("steps must not be negative")
    return coarse_step_factor(bound) ** steps * Fraction(radius)


def orbit_gap_bound(bound: Scalar, steps: int, radius: Scalar) -> Fraction:
    """`2 (6 M)^n r`: how far the enclosure can be from the orbit it contains.

    The enclosure contains `f^n(a)` for every `a` in the box, so a bound on
    its radius is also a bound on its distance from that point, doubled.
    """
    return 2 * iterated_radius_bound(bound, steps, radius)


def sufficient_radius(bound: Scalar, steps: int, margin: Scalar) -> Fraction:
    """The radius that keeps the enclosure within `margin` of the orbit.

    This is the `s` of both completeness theorems: refine below it and the
    certificate that holds for the points holds for the enclosure too.
    """
    margin = Fraction(margin)
    if margin <= 0:
        raise ValueError("margin must be positive")
    return margin / (2 * coarse_step_factor(bound) ** steps)


def bounded_orbit_hypothesis(bound: Scalar, steps: int, radius: Scalar) -> bool:
    """Is the box small enough that its enclosures cannot leave the square?

    The induction of the second lemma: while the enclosure stays within `1` of
    an orbit that stays within `M - 1`, it stays within `M`.
    """
    return orbit_gap_bound(bound, steps, radius) <= 1
