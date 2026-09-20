"""Preperiodic points of `f_c`, certified on boxes.

Specification: docs/rational-interval-arithmetic-spec.md.
Statements and what is imported: docs/preperiodic-certificates.md.

This is the Python side of a differential pair; the Mojo side is the vendored
`quadratic_orbit/preperiodic.mojo`, and the two are compared transcript for
transcript. Both evaluate

```text
R^c_{l,k}(z) = f_c^{l+k}(z) - f_c^l(z)
```

and its derivative along the orbit rather than forming the polynomial, so
there is no coefficient list, no degree, and no squarefree decomposition here.
Everything is exact rational arithmetic and every refusal is a value.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from fractions import Fraction

from box_classifier import step
from interval_box import ComplexBox

ONE = ComplexBox.singleton(1)
TWO = ComplexBox.singleton(2)


def orbit_term(z: ComplexBox, c: ComplexBox, steps: int) -> ComplexBox:
    """The `steps`-th term of the orbit of `z`, recomputed from the seed."""
    if steps < 0 or not (z.accepted() and c.accepted()):
        return ComplexBox.refused()
    for _ in range(steps):
        z = step(z, c)
    return z


def orbit_derivative(z: ComplexBox, c: ComplexBox, steps: int) -> ComplexBox:
    """`d/dz f_c^steps(z) = prod_{j < steps} 2 f_c^j(z)`, on the enclosure."""
    if steps < 0 or not (z.accepted() and c.accepted()):
        return ComplexBox.refused()
    product = ONE
    for _ in range(steps):
        product = product.mul(TWO.mul(z))
        z = step(z, c)
    return product


def residual(z: ComplexBox, c: ComplexBox, preperiod: int, period: int) -> ComplexBox:
    """`R^c_{l,k}(z)`, the difference of two orbit terms."""
    if preperiod < 0 or period < 1 or not (z.accepted() and c.accepted()):
        return ComplexBox.refused()
    return orbit_term(z, c, preperiod + period).sub(orbit_term(z, c, preperiod))


def residual_derivative(z: ComplexBox, c: ComplexBox, preperiod: int, period: int) -> ComplexBox:
    """`R'` by the chain rule, with no coefficients formed."""
    if preperiod < 0 or period < 1 or not (z.accepted() and c.accepted()):
        return ComplexBox.refused()
    return orbit_derivative(z, c, preperiod + period).sub(orbit_derivative(z, c, preperiod))


def excludes(z: ComplexBox, c: ComplexBox, preperiod: int, period: int) -> bool:
    """Does `z` provably contain no point of this preperiod and period?

    True is a proof about every point of the box; False is a statement about
    the enclosure and never about the points.
    """
    image = residual(z, c, preperiod, period)
    return image.accepted() and not (image.re.contains_zero() and image.im.contains_zero())


def midpoint(z: ComplexBox) -> ComplexBox:
    """The singleton at the centre of a box, exactly."""
    if not z.accepted():
        return ComplexBox.refused()
    return ComplexBox.singleton(z.re.midpoint(), z.im.midpoint())


def singleton_reciprocal(w: ComplexBox) -> ComplexBox:
    """`1/w` for a singleton `w`, exactly, or a refusal.

    The exact regime spends no width here. The operator below is usually
    written with an *approximate* inverse of the derivative at the centre,
    because in floating point there is no other kind; over `Q(i)` the inverse
    of a singleton is a singleton and the operator inherits no error from it.
    """
    if not w.accepted() or w.re.lo != w.re.hi or w.im.lo != w.im.hi:
        return ComplexBox.refused()
    a, b = w.re.lo, w.im.lo
    quadrance = a * a + b * b
    if quadrance == 0:
        return ComplexBox.refused()
    return ComplexBox.singleton(a / quadrance, -b / quadrance)


def krawczyk_image(z: ComplexBox, c: ComplexBox, preperiod: int, period: int) -> ComplexBox:
    """`K(Z) = m - Y R(m) + (1 - Y R'(Z))(Z - m)`, with `Y = 1/R'(m)`."""
    centre = midpoint(z)
    y = singleton_reciprocal(residual_derivative(centre, c, preperiod, period))
    if not y.accepted():
        return ComplexBox.refused()
    slope = ONE.sub(y.mul(residual_derivative(z, c, preperiod, period)))
    return centre.sub(y.mul(residual(centre, c, preperiod, period))).add(slope.mul(z.sub(centre)))


def isolates(z: ComplexBox, c: ComplexBox, preperiod: int, period: int) -> bool:
    """The Krawczyk-Moore hypothesis: `K(Z)` strictly inside `Z`.

    This is the hypothesis, not the conclusion. What the conclusion is, and
    which import supplies it, is `docs/preperiodic-certificates.md`.
    """
    if preperiod < 0 or period < 1 or not (z.accepted() and c.accepted()):
        return False
    image = krawczyk_image(z, c, preperiod, period)
    return image.accepted() and image.strict_subset_of(z)


class RootVerdict(Enum):
    ISOLATED = "ISOLATED"
    EXCLUDED = "EXCLUDED"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True, slots=True)
class RootCertificate:
    """What a box was shown to hold, and at which type."""

    verdict: RootVerdict
    preperiod: int
    period: int

    def decided(self) -> bool:
        return self.verdict is not RootVerdict.UNKNOWN


def certify(z: ComplexBox, c: ComplexBox, preperiod: int, period: int) -> RootCertificate:
    """Isolation first, then exclusion; neither, and the box is undecided.

    The two cannot both hold, and the order is not a preference: a box that
    isolates a root cannot exclude one.
    """
    if isolates(z, c, preperiod, period):
        return RootCertificate(RootVerdict.ISOLATED, preperiod, period)
    if excludes(z, c, preperiod, period):
        return RootCertificate(RootVerdict.EXCLUDED, preperiod, period)
    return RootCertificate(RootVerdict.UNKNOWN, preperiod, period)


def exact_type(z: ComplexBox, c: ComplexBox, preperiod: int, period: int) -> bool:
    """Is the isolated root of *exactly* this type, and no smaller one?

    Pointwise exact-type exclusion: a root of `R_{l,k}` is also a root of
    `R_{l',k'}` whenever `l' >= l` and `k` divides `k'`, so the type a box
    certifies is only exact once every strictly smaller type is excluded on
    that same box.
    """
    if not isolates(z, c, preperiod, period):
        return False
    smaller = [
        (l, k)
        for l in range(preperiod + 1)
        for k in range(1, period + 1)
        if (l, k) != (preperiod, period) and period % k == 0
    ]
    return all(excludes(z, c, l, k) for l, k in smaller)


def refine_until_certified(
    z: ComplexBox,
    c: ComplexBox,
    preperiod: int,
    period: int,
    max_depth: int = 6,
) -> tuple[ComplexBox, ...]:
    """Subdivide until every quarter is decided, or the depth budget runs out.

    Returns the boxes still undecided. An empty result means the whole of `z`
    was accounted for; a non-empty one is a budget that ran out, never a
    claim that something is there.
    """
    if certify(z, c, preperiod, period).decided():
        return ()
    if max_depth < 1:
        return (z,)
    return tuple(
        leaf
        for quarter in z.quarters()
        for leaf in refine_until_certified(quarter, c, preperiod, period, max_depth - 1)
    )
