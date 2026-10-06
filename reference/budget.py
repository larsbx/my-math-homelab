"""The coordinate budget, in one place.

Specification: docs/rational-interval-arithmetic-spec.md, section 1.

Exact iteration squares the coordinates, so their bit size doubles at every
step. A loop that iterates without watching it does not return a wrong
answer; it stops returning one. That has now happened three times in this
repository -- the critical orbit, the separator search, and the ray itinerary
-- so the guard lives here rather than being rewritten each time it is
remembered.
"""

from __future__ import annotations

from closed_interval import ComplexBox
from julia_reference import DEFAULT_BIT_BUDGET

__all__ = ["DEFAULT_BIT_BUDGET", "box_bits", "within_budget"]


def box_bits(box: ComplexBox) -> int:
    """The largest numerator or denominator bit length among the corners."""
    if not box.accepted():
        return 0
    parts = (box.re.lo, box.re.hi, box.im.lo, box.im.hi)
    return max(
        max(abs(part.numerator).bit_length(), part.denominator.bit_length())
        for part in parts
    )


def within_budget(bit_budget: int, *boxes: ComplexBox) -> bool:
    """Are all of these boxes still small enough to keep iterating?"""
    return max((box_bits(box) for box in boxes), default=0) <= bit_budget
