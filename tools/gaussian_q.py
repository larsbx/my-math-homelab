"""Exact Gaussian-rational arithmetic for the reference oracle.

`GQ` is a rank-2 coordinate record over `fractions.Fraction`: a pair of exact
rational coordinates with polynomial operations and a quadrance scalar. It is
not an analytic complex number, and it carries no circle, disk, arc, or polar
angle; see `docs/terminology-registry.md`.

This module is the Python side of a differential pair. The proof-grade
arithmetic is the Mojo `finite_exact` stack; this exists so the parameter
corpus can be checked without a Mojo toolchain, and so a disagreement between
the two is a test failure rather than a silent divergence.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Union

Scalar = Union[int, Fraction]


@dataclass(frozen=True, slots=True)
class GQ:
    """A Gaussian-rational coordinate record `re + i * im`."""

    re: Fraction
    im: Fraction = Fraction(0)

    @staticmethod
    def of(re: Scalar, im: Scalar = 0) -> "GQ":
        return GQ(Fraction(re), Fraction(im))

    def __add__(self, other: "GQ") -> "GQ":
        return GQ(self.re + other.re, self.im + other.im)

    def __sub__(self, other: "GQ") -> "GQ":
        return GQ(self.re - other.re, self.im - other.im)

    def __mul__(self, other: "GQ") -> "GQ":
        return GQ(
            self.re * other.re - self.im * other.im,
            self.re * other.im + self.im * other.re,
        )

    def __neg__(self) -> "GQ":
        return GQ(-self.re, -self.im)

    def scale(self, k: Scalar) -> "GQ":
        factor = Fraction(k)
        return GQ(self.re * factor, self.im * factor)

    def square(self) -> "GQ":
        return self * self

    def quadrance(self) -> Fraction:
        """`N(z) = re^2 + im^2`, the rank-2 quadrance. No square root is taken."""
        return self.re * self.re + self.im * self.im

    def is_zero(self) -> bool:
        return self.re == 0 and self.im == 0

    def __str__(self) -> str:
        if self.im == 0:
            return str(self.re)
        if self.re == 0:
            if self.im == 1:
                return "i"
            return "-i" if self.im == -1 else f"{self.im}i"
        sign = "+" if self.im > 0 else "-"
        magnitude = abs(self.im)
        unit = "i" if magnitude == 1 else f"{magnitude}i"
        return f"{self.re} {sign} {unit}"


ZERO = GQ.of(0)
ONE = GQ.of(1)
I = GQ.of(0, 1)

#: The roots of unity of `Q(i)`. By the rational multiplier dichotomy
#: (`docs/julia-program-design-analysis-2026-09-19.md`, section 6) an element
#: of `Q(i)` of quadrance 1 is a root of unity exactly when it lies here.
ROOTS_OF_UNITY = (ONE, -ONE, I, -I)


def is_root_of_unity(value: GQ) -> bool:
    return value in ROOTS_OF_UNITY
