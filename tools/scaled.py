"""A box with a separated binary exponent, and outward rounding.

Specification: docs/rational-interval-arithmetic-spec.md, section 2.1.
Statements and the measurement: docs/scaled-boxes.md.

An escaping orbit reaches magnitude `2^(2^n)` after `n` steps, so writing the
value down exactly costs `2^n` bits however the arithmetic is arranged. That
is a property of the orbit and not of the method: no enclosure scheme beats
it while storing the value in one piece.

This stores it in two. A scaled box is a mantissa box together with an
integer exponent, standing for `box * 2^exponent`, and after each step the
mantissa is renormalised to `O(1)` and rounded **outward** to a bounded
precision. The exponent then carries the magnitude at `log` cost, and the
mantissa stays the same size forever.

Multiplying a box by a power of two is exact, so renormalisation loses
nothing; rounding is where the width is paid, and it is paid outward, so an
enclosure stays an enclosure.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction

from dyadic import DEFAULT_PRECISION, round_down, round_up
from interval_box import ComplexBox
from separator import NEGATIVE, POSITIVE, UNDECIDED

TWO = Fraction(2)


@dataclass(frozen=True, slots=True)
class ScaledBox:
    """`mantissa * 2^exponent`, an enclosure of everything that product is."""

    mantissa: ComplexBox
    exponent: int

    def accepted(self) -> bool:
        return self.mantissa.accepted()

    def reach(self) -> Fraction:
        """The largest coordinate magnitude of the mantissa."""
        if not self.accepted():
            return Fraction(0)
        return max(abs(self.mantissa.re.lo), abs(self.mantissa.re.hi),
                   abs(self.mantissa.im.lo), abs(self.mantissa.im.hi))

    def side_of_real_axis(self) -> int:
        """Which side of the real axis, if the enclosure decides it.

        Scale invariant: `2^exponent` is positive, so it cannot move a point
        across the axis, and the sign of the mantissa's imaginary part is the
        sign of the value's.
        """
        if not self.accepted():
            return UNDECIDED
        if self.mantissa.im.lo > 0:
            return POSITIVE
        if self.mantissa.im.hi < 0:
            return NEGATIVE
        return UNDECIDED


def refused() -> ScaledBox:
    return ScaledBox(ComplexBox.refused(), 0)


def of(box: ComplexBox) -> ScaledBox:
    return ScaledBox(box, 0)


def shift(value: ScaledBox, places: int) -> ScaledBox:
    """Move `places` powers of two from the mantissa into the exponent.

    Exact in both directions: scaling a box by a power of two moves its
    endpoints and nothing else.
    """
    if not value.accepted():
        return refused()
    factor = TWO ** (-places)
    mantissa = ComplexBox.of(
        value.mantissa.re.lo * factor, value.mantissa.re.hi * factor,
        value.mantissa.im.lo * factor, value.mantissa.im.hi * factor,
    )
    return ScaledBox(mantissa, value.exponent + places)


def round_outward(value: ScaledBox, precision: int) -> ScaledBox:
    """Widen the mantissa to endpoints of bounded precision."""
    if not value.accepted() or precision < 1:
        return value
    box = value.mantissa
    return ScaledBox(
        ComplexBox.of(
            round_down(box.re.lo, precision), round_up(box.re.hi, precision),
            round_down(box.im.lo, precision), round_up(box.im.hi, precision),
        ),
        value.exponent,
    )


def normalise(value: ScaledBox, precision: int = DEFAULT_PRECISION) -> ScaledBox:
    """Bring the mantissa to `O(1)` and round it outward.

    A mantissa containing the origin cannot be normalised by magnitude, and
    is left where it is: it is already small, and shifting it would be
    guessing at a scale it does not have.
    """
    if not value.accepted():
        return refused()
    reach = value.reach()
    places = 0 if reach == 0 else (abs(reach.numerator).bit_length() - abs(reach.denominator).bit_length())
    return round_outward(shift(value, places), precision)


def step(value: ScaledBox, c: ComplexBox, precision: int = DEFAULT_PRECISION) -> ScaledBox:
    """`z^2 + c` on a scaled box.

    `(m 2^e)^2 + c = (m^2 + c 2^(-2e)) 2^(2e)`, so the parameter is brought
    into the mantissa's scale rather than the value being brought out of it.
    Where the exponent is large that term is tiny and the outward rounding
    absorbs it, which is the whole point: the orbit's magnitude stops being
    something that has to be written down.
    """
    if not (value.accepted() and c.accepted()):
        return refused()
    doubled = 2 * value.exponent
    return normalise(ScaledBox(value.mantissa.square().add(parameter_at(c, doubled, precision)), doubled), precision)


def magnitude_exponent(x: Fraction) -> int:
    """A cheap integer bound: `2^k >= |x|` for the `k` this returns."""
    return 0 if x == 0 else abs(x.numerator).bit_length() - abs(x.denominator).bit_length() + 1


def parameter_at(c: ComplexBox, doubled: int, precision: int) -> ComplexBox:
    """`c * 2^(-doubled)`, or a symmetric box when that underflows.

    Computing the power is what the exponent was separated to avoid: by step
    twenty-eight it is a sixty-seven megabyte integer, and it is multiplied by
    a parameter that stopped mattering twenty steps earlier. Where the term
    is smaller than the mantissa's last bit, a symmetric box around zero
    encloses it and costs nothing.

    The test is on bit lengths, so nothing large is built to decide it.
    """
    reach = max(abs(c.re.lo), abs(c.re.hi), abs(c.im.lo), abs(c.im.hi))
    if magnitude_exponent(reach) - doubled < -(precision + 2):
        tiny = Fraction(1, 2 ** (precision + 1))
        return ComplexBox.of(-tiny, tiny, -tiny, tiny)
    factor = TWO ** (-doubled)
    return ComplexBox.of(c.re.lo * factor, c.re.hi * factor, c.im.lo * factor, c.im.hi * factor)


def itinerary(
    box: ComplexBox,
    c: ComplexBox,
    steps: int,
    precision: int = DEFAULT_PRECISION,
) -> tuple[int, ...] | None:
    """The real-axis itinerary, computed with a separated exponent.

    `None` as soon as a step is undecided, exactly as `tools/ray.py`. What is
    gone is the budget: the mantissa is bounded by construction, so the depth
    is set by how long the enclosure stays on one side rather than by how many
    bits the orbit needs.
    """
    if steps < 0 or not (box.accepted() and c.accepted()):
        return None
    value, word = normalise(of(box), precision), []
    for _ in range(steps + 1):
        where = value.side_of_real_axis()
        if where == UNDECIDED:
            return None
        word.append(where)
        value = step(value, c, precision)
    return tuple(word)
