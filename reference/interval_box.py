"""Exact rational interval boxes, mirroring the vendored `finite_exact` layer.

Specification: docs/rational-interval-arithmetic-spec.md.

`IQ` and `ComplexBox` here are the Python side of the differential pair whose
Mojo side is `vendor/mojo/finite_exact/closed_q.mojo`: the same enclosure semantics,
the same fail-closed rejection, and the same refusal to promote an unknown
containment to equality. They exist so the classifier can be checked without a
Mojo toolchain, not to be a second authority.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Union

Scalar = Union[int, Fraction]


@dataclass(frozen=True, slots=True)
class IQ:
    """A closed interval with exact rational endpoints, or a rejected result."""

    lo: Fraction
    hi: Fraction
    rejected: bool = False

    @staticmethod
    def of(lo: Scalar, hi: Scalar) -> "IQ":
        lo, hi = Fraction(lo), Fraction(hi)
        return IQ(lo, hi, lo > hi)

    @staticmethod
    def singleton(x: Scalar) -> "IQ":
        return IQ.of(x, x)

    @staticmethod
    def refused() -> "IQ":
        return IQ(Fraction(1), Fraction(0), True)

    def accepted(self) -> bool:
        return not self.rejected

    def add(self, other: "IQ") -> "IQ":
        if self.rejected or other.rejected:
            return IQ.refused()
        return IQ.of(self.lo + other.lo, self.hi + other.hi)

    def sub(self, other: "IQ") -> "IQ":
        if self.rejected or other.rejected:
            return IQ.refused()
        return IQ.of(self.lo - other.hi, self.hi - other.lo)

    def neg(self) -> "IQ":
        return IQ.refused() if self.rejected else IQ.of(-self.hi, -self.lo)

    def mul(self, other: "IQ") -> "IQ":
        if self.rejected or other.rejected:
            return IQ.refused()
        corners = [self.lo * other.lo, self.lo * other.hi, self.hi * other.lo, self.hi * other.hi]
        return IQ.of(min(corners), max(corners))

    def square(self) -> "IQ":
        """Tighter than `mul(self)`: a square is never negative."""
        if self.rejected:
            return IQ.refused()
        if self.lo >= 0:
            return IQ.of(self.lo * self.lo, self.hi * self.hi)
        if self.hi <= 0:
            return IQ.of(self.hi * self.hi, self.lo * self.lo)
        return IQ.of(Fraction(0), max(self.lo * self.lo, self.hi * self.hi))

    def contains_zero(self) -> bool:
        return self.accepted() and self.lo <= 0 <= self.hi

    def reciprocal(self) -> "IQ":
        """`1/X`, refusing where the interval meets zero.

        Mirrors `IQ.reciprocal` of the vendored `finite_exact` layer: the
        domain of a division is enforced by the arithmetic, not by a caller
        contract.
        """
        if not self.accepted() or self.contains_zero():
            return IQ.refused()
        return IQ.of(1 / self.hi, 1 / self.lo)

    def subset_of(self, other: "IQ") -> bool:
        if self.rejected or other.rejected:
            return False
        return other.lo <= self.lo and self.hi <= other.hi

    def strict_subset_of(self, other: "IQ") -> bool:
        if self.rejected or other.rejected:
            return False
        return other.lo < self.lo and self.hi < other.hi

    def midpoint(self) -> Fraction:
        return (self.lo + self.hi) / 2

    def width(self) -> Fraction:
        return self.hi - self.lo if self.accepted() else Fraction(0)


@dataclass(frozen=True, slots=True)
class ComplexBox:
    """A rank-2 box: two exact rational intervals, one per coordinate."""

    re: IQ
    im: IQ

    @staticmethod
    def of(re_lo: Scalar, re_hi: Scalar, im_lo: Scalar, im_hi: Scalar) -> "ComplexBox":
        return ComplexBox(IQ.of(re_lo, re_hi), IQ.of(im_lo, im_hi))

    @staticmethod
    def singleton(re: Scalar, im: Scalar = 0) -> "ComplexBox":
        return ComplexBox(IQ.singleton(re), IQ.singleton(im))

    @staticmethod
    def refused() -> "ComplexBox":
        return ComplexBox(IQ.refused(), IQ.refused())

    def accepted(self) -> bool:
        return self.re.accepted() and self.im.accepted()

    def add(self, other: "ComplexBox") -> "ComplexBox":
        return ComplexBox(self.re.add(other.re), self.im.add(other.im))

    def sub(self, other: "ComplexBox") -> "ComplexBox":
        return ComplexBox(self.re.sub(other.re), self.im.sub(other.im))

    def mul(self, other: "ComplexBox") -> "ComplexBox":
        return ComplexBox(
            self.re.mul(other.re).sub(self.im.mul(other.im)),
            self.re.mul(other.im).add(self.im.mul(other.re)),
        )

    def square(self) -> "ComplexBox":
        """`(x + iy)^2 = (x^2 - y^2) + i(2xy)`, using the tighter real square."""
        if not self.accepted():
            return ComplexBox.refused()
        real = self.re.square().sub(self.im.square())
        cross = self.re.mul(self.im)
        return ComplexBox(real, cross.add(cross))

    def quadrance(self) -> IQ:
        return self.re.square().add(self.im.square())

    def reciprocal(self) -> "ComplexBox":
        """`1/z` as conjugate over quadrance, refusing on the chart's edge.

        A chart is a division, so it has a domain, and the domain is enforced
        by the arithmetic rather than by a caller contract: a box whose
        quadrance interval contains zero has no reciprocal here and gets a
        refusal. The enclosure is valid but not tight -- the numerator and
        the reciprocal are enclosed separately.
        """
        if not self.accepted():
            return ComplexBox.refused()
        inverse = self.quadrance().reciprocal()
        if not inverse.accepted():
            return ComplexBox.refused()
        return ComplexBox(self.re.mul(inverse), self.im.neg().mul(inverse))

    def subset_of(self, other: "ComplexBox") -> bool:
        return self.re.subset_of(other.re) and self.im.subset_of(other.im)

    def strict_subset_of(self, other: "ComplexBox") -> bool:
        return self.re.strict_subset_of(other.re) and self.im.strict_subset_of(other.im)

    def quarters(self) -> tuple["ComplexBox", ...]:
        """The four boxes of one bisection in each coordinate.

        Their union is this box, so a classification that covers the quarters
        covers the whole; they overlap on the cut lines, which is sound for
        enclosures and is why refinement never loses a point.
        """
        if not self.accepted():
            return ()
        re_mid, im_mid = self.re.midpoint(), self.im.midpoint()
        re_halves = (IQ.of(self.re.lo, re_mid), IQ.of(re_mid, self.re.hi))
        im_halves = (IQ.of(self.im.lo, im_mid), IQ.of(im_mid, self.im.hi))
        return tuple(ComplexBox(r, i) for r in re_halves for i in im_halves)

    def width(self) -> Fraction:
        return max(self.re.width(), self.im.width())
