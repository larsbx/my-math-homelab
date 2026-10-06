"""Ray certificates: what the finite layer can say about a dynamical ray.

Specification: docs/rational-interval-arithmetic-spec.md.
Statements and what is imported: docs/ray-certificates.md.

A dynamical ray is a curve, and `docs/literature-gate-2026-09-20-cut-equivalence.md`
rejected the idea that a straight cut can stand in for one. This is the other
direction: not standing in for a ray, but certifying the parts of one that are
exactly representable.

For a **real** rational parameter the real axis carries both pieces. Beyond a
rational `outer` the half-line is the angle-zero ray, and the certificate is a
rational growth witness; around the origin a rational `segment` is forward
invariant and lies in `K_c`. So the cut `y = 0` of `reference/separator.py` is not
an arbitrary line at such a parameter: it runs along genuine rays outside and
along trapped real dynamics inside.

What is *not* here is the angle. The itinerary of an escaping orbit relative
to that cut is a finite sound invariant; reading its digits as the binary
expansion of an external angle is an import, named and gated.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Union

from box_classifier import step
from budget import DEFAULT_BIT_BUDGET, within_budget
from closed_interval import ComplexBox
from separator import NEGATIVE, POSITIVE, UNDECIDED, Cut, side

Scalar = Union[int, Fraction]

#: The cut the real axis makes. Declared here rather than passed in, because
#: the certificate below is about this line and no other.
REAL_AXIS = Cut.of(0, 1, 0)


@dataclass(frozen=True, slots=True)
class RealRayWitness:
    """What a real parameter's real axis was shown to carry."""

    c: Fraction
    outer: Fraction
    segment: Fraction
    growth: Fraction

    def escaping_half_lines(self) -> tuple[tuple[Fraction, str], tuple[Fraction, str]]:
        """The two half-lines the witness covers, as `(bound, side)` pairs."""
        return ((self.outer, "x >= outer"), (-self.outer, "x <= -outer"))


def certify_real_rays(c: Scalar, outer: Scalar, segment: Scalar) -> RealRayWitness | None:
    """Certify the real axis of a real parameter, or refuse.

    Three rational inequalities, checked exactly:

    - `outer >= 1` and `outer^2 + c - outer > 0`, so every real `x >= outer`
      advances by at least that amount and the half-line escapes;
    - `segment > 0`, `segment^2 + c <= segment` and `c >= -segment`, so
      `[-segment, segment]` is forward invariant and therefore inside `K_c`;
    - `outer > segment`, so the two regions do not overlap.

    The stretch between `segment` and `outer` is covered by neither, and the
    witness does not pretend otherwise: it names what it certifies.
    """
    c, outer, segment = Fraction(c), Fraction(outer), Fraction(segment)
    growth = outer * outer + c - outer
    if outer < 1 or growth <= 0:
        return None
    if segment <= 0 or segment * segment + c > segment or c < -segment:
        return None
    if outer <= segment:
        return None
    return RealRayWitness(c, outer, segment, growth)


def advances_by(witness: RealRayWitness, x: Scalar) -> Fraction | None:
    """`f(x) - x` for a real point on the certified half-line, or `None`.

    The point of the witness is that this is at least `growth` everywhere on
    the half-line, which is what makes the orbit unbounded without a limit
    argument: `n` steps move it at least `n * growth`.
    """
    x = Fraction(x)
    if abs(x) < witness.outer:
        return None
    return x * x + witness.c - abs(x)


def itinerary(
    box: ComplexBox,
    c: ComplexBox,
    steps: int,
    bit_budget: int = DEFAULT_BIT_BUDGET,
) -> tuple[int, ...] | None:
    """Which side of the real axis each iterate of the box is on.

    `None` as soon as a step is undecided or the coordinates outgrow the
    budget, because a word with a gap in it is not a word and a word that
    stopped for want of room is not a shorter word. Each entry is `POSITIVE`
    or `NEGATIVE` from `reference/separator.py`, and the whole of it is a
    statement about the enclosure: every point of the box has its iterates on
    those sides.
    """
    if steps < 0 or not (box.accepted() and c.accepted()):
        return None
    word: list[int] = []
    for _ in range(steps + 1):
        if not within_budget(bit_budget, box):
            return None
        where = side(REAL_AXIS, box)
        if where == UNDECIDED:
            return None
        word.append(where)
        box = step(box, c)
    return tuple(word)


def itineraries_differ(left: tuple[int, ...] | None, right: tuple[int, ...] | None) -> bool:
    """Do two decided itineraries disagree at some step?

    False when either is missing, which is the fail-closed reading: an absent
    word is not a different word.
    """
    if left is None or right is None:
        return False
    return any(a != b for a, b in zip(left, right))
