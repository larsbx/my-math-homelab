"""Rational angles on `Q/Z` under `t -> 2t`.

Specification: docs/rational-interval-arithmetic-spec.md, section 1.
Statements and what is imported: docs/angle-types-and-landing.md.

This is the Python side of a differential pair; the Mojo side is the vendored
`angle_doubling/angle.mojo`. Both read an angle's type off its denominator
rather than searching for it, and the proof that they may is section 1 of the
note above.

Nothing here is geometry. No angle is derived from a locus, no locus from an
angle, and the module does not know what a ray is.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import gcd

#: Past this a doubling step would leave the checked range of the Mojo side.
#: The Python side has no such bound, and refuses in step with it anyway:
#: a differential pair that refuses on different inputs is not a pair.
DENOMINATOR_LIMIT = 1 << 30

#: The largest period the search for a multiplicative order will reach.
ORDER_LIMIT = 64


@dataclass(frozen=True, slots=True)
class Angle:
    """`num / den` in lowest terms with `0 <= num < den`, or a refusal."""

    num: int
    den: int
    rejected: bool = False

    @staticmethod
    def of(num: int, den: int) -> "Angle":
        if den <= 0 or den > DENOMINATOR_LIMIT:
            return Angle.refused()
        residue = num % den
        divisor = gcd(residue, den) or 1
        return Angle(residue // divisor, den // divisor)

    @staticmethod
    def refused() -> "Angle":
        return Angle(0, 1, True)

    def accepted(self) -> bool:
        return not self.rejected

    def value(self) -> Fraction | None:
        return None if self.rejected else Fraction(self.num, self.den)

    def same(self, other: "Angle") -> bool:
        """Two refusals are not equal: agreeing to fail is not agreeing."""
        if self.rejected or other.rejected:
            return False
        return (self.num, self.den) == (other.num, other.den)


def double(t: Angle) -> Angle:
    """`2t` modulo one."""
    return Angle.refused() if t.rejected else Angle.of(2 * t.num, t.den)


def orbit_term(t: Angle, steps: int) -> Angle:
    """The `steps`-th term of the doubling orbit, recomputed from the seed."""
    if steps < 0 or t.rejected:
        return Angle.refused()
    for _ in range(steps):
        t = double(t)
    return t


def preperiod(t: Angle) -> int:
    """`v_2(den)`: the exact number of steps before the orbit is periodic."""
    if t.rejected:
        return -1
    den, count = t.den, 0
    while den % 2 == 0:
        den //= 2
        count += 1
    return count


def period(t: Angle) -> int:
    """`ord_m(2)` for `m` the odd part of the denominator, or `-1` refused."""
    if t.rejected:
        return -1
    odd = t.den
    while odd % 2 == 0:
        odd //= 2
    if odd == 1:
        return 1
    power, order = 2 % odd, 1
    while power != 1:
        if order >= ORDER_LIMIT:
            return -1
        power, order = (power * 2) % odd, order + 1
    return order


def has_type(t: Angle, preperiod_bound: int, period_bound: int) -> bool:
    """Does `2^(l+k) t = 2^l t`?

    True exactly when `l` is at least the preperiod and the period divides
    `k`, which section 1 of the note proves is the same condition.
    """
    if t.rejected or preperiod_bound < 0 or period_bound < 1:
        return False
    exact = period(t)
    if exact < 1:
        return False
    return preperiod_bound >= preperiod(t) and period_bound % exact == 0


def type_count(preperiod_bound: int, period_bound: int) -> int:
    """`2^l (2^k - 1)`, the number of angles with `2^(l+k) t = 2^l t`."""
    if preperiod_bound < 0 or period_bound < 1 or preperiod_bound + period_bound > 60:
        return -1
    return (1 << preperiod_bound) * ((1 << period_bound) - 1)


def angles_of_type(preperiod_bound: int, period_bound: int) -> tuple[Angle, ...]:
    """Every angle with `2^(l+k) t = 2^l t`, in increasing order.

    They are the `j / (2^l (2^k - 1))`, which is the same set the closed form
    counts; enumerating them is how the count is checked rather than trusted.
    """
    total = type_count(preperiod_bound, period_bound)
    if total < 0:
        return ()
    return tuple(Angle.of(j, total) for j in range(total))
