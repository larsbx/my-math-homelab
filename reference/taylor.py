"""Taylor models: an exact polynomial part with a rigorous remainder.

Specification: docs/rational-interval-arithmetic-spec.md, section 2.5.
Statements: docs/taylor-models.md.

A plain enclosure treats every occurrence of a variable as independent, so
`X - X` is not zero and widths inflate through iterated maps. A Taylor model
carries the correlation instead: a jet in the local variable, exact over
`Q(i)`, plus an interval remainder that absorbs what the jet drops.

    for every z = centre + e with e in domain,   g(z) in p(e) + remainder

`reference/jet.py` supplies the polynomial part; this adds the remainder and the
guarantee. Nothing here is an approximation: the remainder is an enclosure,
and every operation below is proved to preserve the guarantee.

This is the Python side of a differential pair; `kernel/taylor.mojo` is the Mojo
side.
"""

from __future__ import annotations

from dataclasses import dataclass

import jet
from dyadic import DEFAULT_PRECISION, round_down, round_up
from gaussian_q import GQ
from interval_box import ComplexBox

ZERO_BOX = ComplexBox.singleton(0)


def singleton(value: GQ) -> ComplexBox:
    return ComplexBox.singleton(value.re, value.im)


def power(box: ComplexBox, exponent: int) -> ComplexBox:
    """`box^exponent` by repeated squaring.

    The sharp square, not `box * box`. A product treats its two arguments as
    independent, so `X * X` is wider than `X^2` whenever the box straddles an
    axis -- specification section 2.5 again, one level down.
    """
    if exponent < 0 or not box.accepted():
        return ComplexBox.refused()
    result, base = ComplexBox.singleton(1), box
    while exponent:
        if exponent & 1:
            result = result.mul(base)
        exponent >>= 1
        if exponent:
            base = base.square()
    return result


def evaluate(coefficients: jet.Jet, domain: ComplexBox) -> ComplexBox:
    """Enclose `{p(e) : e in domain}` term by term, with sharp powers.

    **Not** Horner. Horner is the tighter form for a polynomial in a variable
    that occurs once, which is why section 2.5 of the specification requires
    it there; here the variable occurs in every term and Horner's nesting
    multiplies the same box by itself repeatedly, losing more to the
    dependency problem than the nesting saves. Term by term, with each power
    taken by repeated squaring, is tighter for a box centred at zero -- which
    is the only kind of domain a Taylor model has.
    """
    if not domain.accepted():
        return ComplexBox.refused()
    total = singleton(coefficients[0])
    for degree, coefficient in enumerate(coefficients[1:], start=1):
        if coefficient.is_zero():
            continue
        total = total.add(singleton(coefficient).mul(power(domain, degree)))
    return total


@dataclass(frozen=True, slots=True)
class TaylorModel:
    """`p` in the local variable, plus a remainder, over a domain."""

    centre: GQ
    domain: ComplexBox
    polynomial: jet.Jet
    remainder: ComplexBox

    def order(self) -> int:
        return len(self.polynomial) - 1

    def accepted(self) -> bool:
        return self.domain.accepted() and self.remainder.accepted()

    def enclosure(self) -> ComplexBox:
        """`Enc(p) + remainder`: what a plain interval step would have given,
        except that the correlation was kept until this moment."""
        if not self.accepted():
            return ComplexBox.refused()
        return evaluate(self.polynomial, self.domain).add(self.remainder)


def refused(centre: GQ, domain: ComplexBox, order: int) -> TaylorModel:
    return TaylorModel(centre, ComplexBox.refused(), jet.constant(GQ.of(0), order), ComplexBox.refused())


def variable(centre: GQ, radius, order: int) -> TaylorModel:
    """The identity on the box of that radius around the centre.

    Exact: `z = centre + e` is its own first-order jet, so the remainder is
    zero and stays zero until a multiplication truncates something.
    """
    domain = ComplexBox.of(-radius, radius, -radius, radius)
    return TaylorModel(centre, domain, jet.seed(centre, order), ZERO_BOX)


def constant(value: GQ, model: TaylorModel) -> TaylorModel:
    """A constant over the same domain and order."""
    return TaylorModel(model.centre, model.domain, jet.constant(value, model.order()), ZERO_BOX)


def add(left: TaylorModel, right: TaylorModel) -> TaylorModel:
    """Componentwise, which is why the guarantee survives untouched."""
    if not (left.accepted() and right.accepted()):
        return refused(left.centre, left.domain, left.order())
    return TaylorModel(
        left.centre, left.domain,
        jet.add(left.polynomial, right.polynomial),
        left.remainder.add(right.remainder),
    )


def mul(left: TaylorModel, right: TaylorModel) -> TaylorModel:
    """`(p + I)(q + J) = pq_low + [pq_high + p J + I q + I J]`.

    The bracket is the new remainder, and every term of it is enclosed rather
    than dropped: the tail the truncation discards is *added back* as an
    interval, which is the whole difference between a jet and a model.
    """
    if not (left.accepted() and right.accepted()):
        return refused(left.centre, left.domain, left.order())
    order = left.order()
    product = jet.convolve(left.polynomial, right.polynomial)
    low, high = product[:order + 1], product[order + 1:]
    domain = left.domain

    tail = ZERO_BOX
    if high:
        # The tail starts at degree order+1, so that power factors out.
        tail = evaluate(high, domain).mul(power(domain, order + 1))

    cross = (
        evaluate(left.polynomial, domain).mul(right.remainder)
        .add(left.remainder.mul(evaluate(right.polynomial, domain)))
        .add(left.remainder.mul(right.remainder))
    )
    return TaylorModel(left.centre, domain, low, tail.add(cross))


def step(model: TaylorModel, c: GQ) -> TaylorModel:
    """`z^2 + c` on a Taylor model."""
    return add(mul(model, model), constant(c, model))


def orbit(model: TaylorModel, c: GQ, steps: int) -> TaylorModel:
    if steps < 0:
        return refused(model.centre, model.domain, model.order())
    for _ in range(steps):
        model = step(model, c)
    return model


def round_coefficient(value: GQ, precision: int) -> tuple[GQ, ComplexBox]:
    """A rounded coefficient, and an enclosure of what rounding lost.

    The error is returned rather than bounded: it is the exact difference
    between the coefficient and its rounding, so the caller can put it where
    soundness requires.
    """
    rounded = GQ(round_down(value.re, precision), round_down(value.im, precision))
    difference = value - rounded
    return rounded, ComplexBox.of(
        round_down(difference.re, precision), round_up(difference.re, precision),
        round_down(difference.im, precision), round_up(difference.im, precision),
    )


def round_model(model: TaylorModel, precision: int = DEFAULT_PRECISION) -> TaylorModel:
    """Round every coefficient, moving what rounding loses into the remainder.

    This is the exchange a Taylor model exists to make. An exact backend has
    no rounding, so coefficients grow without bound -- every step squares
    them -- and the model becomes unaffordable long before the enclosure
    becomes useless. Giving a little width back to the remainder buys a
    coefficient that stays small.

    Soundness is unchanged: for every `e` in the domain,
    `p(e) = p_rounded(e) + sum_j (a_j - rounded_j) e^j`, and the sum is
    enclosed and added. Nothing is dropped.
    """
    if not model.accepted() or precision < 1:
        return model
    coefficients: list[GQ] = []
    lost = ZERO_BOX
    for degree, value in enumerate(model.polynomial):
        rounded, error = round_coefficient(value, precision)
        coefficients.append(rounded)
        if not error.re.lo == error.re.hi == error.im.lo == error.im.hi == 0:
            lost = lost.add(error.mul(power(model.domain, degree)))
    return TaylorModel(model.centre, model.domain, tuple(coefficients), model.remainder.add(lost))
