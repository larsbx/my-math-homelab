"""Bounded-precision dyadic rationals with directed rounding.

Specification: docs/rational-interval-arithmetic-spec.md, section 2.1.

Section 2.1 admits an endpoint set `E = F` with directed rounding -- lower
endpoints toward minus infinity, upper toward plus infinity -- and says it
needs rounding-mode control on the hardware. It does not: a dyadic rational
`m / 2^s` with a bounded numerator is the same idea done exactly, and the
rounding direction is a floor or a ceiling over `Z`, decided rather than
configured.

That matters here because the exact backend has no rounding at all, so
coefficients grow without bound: every step squares them. Directed rounding
is what lets a Taylor model give width back to the remainder in exchange for
a coefficient that stays small (`docs/taylor-models.md`, section 6).

Nothing here loses soundness. Rounding a coefficient changes the polynomial,
and the exact difference is returned so the caller can put it where it
belongs.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Union

Scalar = Union[int, Fraction]

#: Enough to hold the corpus's exact constants without rounding at all.
DEFAULT_PRECISION = 53


def significant_bits(x: Scalar) -> int:
    """The bit length of the numerator of `x` in lowest terms, or `0`."""
    x = Fraction(x)
    return 0 if x == 0 else abs(x.numerator).bit_length()


def scale_for(x: Fraction, precision: int) -> int:
    """The exponent `s` making `x * 2^s` an integer of about `precision` bits."""
    exponent = abs(x.numerator).bit_length() - abs(x.denominator).bit_length()
    return precision - 1 - exponent


def round_down(x: Scalar, precision: int = DEFAULT_PRECISION) -> Fraction:
    """The largest dyadic at that precision which is at most `x`."""
    x = Fraction(x)
    if x == 0 or precision < 1:
        return Fraction(0) if x == 0 else x
    scale = scale_for(x, precision)
    shifted = x * Fraction(2) ** scale
    return Fraction(shifted.numerator // shifted.denominator) / Fraction(2) ** scale


def round_up(x: Scalar, precision: int = DEFAULT_PRECISION) -> Fraction:
    """The smallest dyadic at that precision which is at least `x`."""
    return -round_down(-Fraction(x), precision)


def round_outward(lo: Scalar, hi: Scalar, precision: int = DEFAULT_PRECISION) -> tuple[Fraction, Fraction]:
    """An interval at that precision containing `[lo, hi]`.

    Outward, always: the result is never narrower than what went in, so an
    enclosure stays an enclosure.
    """
    return round_down(lo, precision), round_up(hi, precision)
