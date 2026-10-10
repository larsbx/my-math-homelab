"""Kneading data from the critical cut, and the tuning prefix it yields.

Specification: docs/rational-interval-arithmetic-spec.md, section 2.4.
Statements and the identification: docs/kneading-and-tuning.md.

The word is the side of `x = 0` that each iterate of the critical point is
on. It is a fact about enclosures, three-valued and fail-closed: an undecided
step returns no word rather than a shorter one, because the undecided step is
the critical point itself and a word with a gap is not a word.

This is the Python side of a differential pair; `kernel/kneading.mojo` is the
Mojo side, and it is the one that hands the word to the kernels' tuning
layer.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Union

from box_classifier import step
from budget import DEFAULT_BIT_BUDGET, within_budget
from gaussian_q import GQ
from closed_interval import ComplexBox
from julia_reference import OrbitVerdict, critical_orbit
from separator import NEGATIVE, POSITIVE, UNDECIDED, Cut, side

Scalar = Union[int, Fraction]

#: The line `x = 0`, through the critical point. Not the real axis: section 1
#: of the note says why the ray certificates' cut decides nothing here.
CRITICAL_CUT = Cut.of(1, 0, 0)

#: The left side is `1`, because `f'(x) = 2x` is negative there and the twist
#: the kernels compute is the parity of the orientation-reversing steps
#: (note, section 2). Counting `1`s has to count reversals.
LETTER = {NEGATIVE: 1, POSITIVE: 0}


def critical_itinerary(
    c: Scalar,
    steps: int,
    bit_budget: int = DEFAULT_BIT_BUDGET,
) -> tuple[int, ...] | None:
    """The first `steps` letters of the critical itinerary, or a refusal."""
    if steps < 0:
        return None
    parameter = ComplexBox.singleton(Fraction(c))
    box, word = ComplexBox.singleton(0), []
    for _ in range(steps):
        box = step(box, parameter)
        if not (box.accepted() and within_budget(bit_budget, box)):
            return None
        where = side(CRITICAL_CUT, box)
        if where == UNDECIDED:
            return None
        word.append(LETTER[where])
    return tuple(word)


def superattracting_period(c: Scalar, horizon: int = 16) -> int | None:
    """The period of a superattracting cycle at `c`, or `None`.

    Superattracting is preperiod zero: the critical point is *on* the cycle,
    which is exactly the case that has a return to the cut.
    """
    verdict = critical_orbit(GQ(Fraction(c), Fraction(0)), horizon=horizon)
    if verdict.verdict is not OrbitVerdict.PREPERIODIC or verdict.preperiod != 0:
        return None
    return verdict.period


def tuning_prefix(c: Scalar, horizon: int = 16) -> tuple[int, ...] | None:
    """The word `A'` of the note's section 3, or a refusal.

    `None` for every parameter that is not superattracting, because nothing
    else returns to the critical point. The empty tuple at `c = 0`, where the
    period is one: an empty prefix is not a tuning pattern, and refusing to
    build one from it is upstream's boundary, not this function's.
    """
    period = superattracting_period(c, horizon)
    return None if period is None else critical_itinerary(c, period - 1)


def parity_twist(prefix: tuple[int, ...]) -> bool:
    """The parity convention of the real line: an odd number of reversals.

    An independent one-line restatement of the kernels' `dgp_twist`, here
    because an oracle that imports the thing it checks is not an oracle.
    """
    return sum(prefix) % 2 == 1


def tuning_substitution(prefix: tuple[int, ...]) -> tuple[tuple[int, ...], ...] | None:
    """`tau(s) = A' . (s xor eps)` as a pair of images, or `None` for an
    empty prefix.

    The oracle's copy of the kernels' `TuningPattern.substitution()`, for the
    same reason `parity_twist` is here.
    """
    if not prefix:
        return None
    twist = parity_twist(prefix)
    return tuple(prefix + (letter ^ twist,) for letter in (0, 1))
