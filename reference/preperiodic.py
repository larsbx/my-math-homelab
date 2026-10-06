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

from box_classifier import escape_bound_quadrance, step
from gaussian_q import GQ
from closed_interval import ComplexBox
from jet import residual as jet_residual, vanishing_order
from julia_reference import step as point_step

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


# --- exactly representable roots -------------------------------------------
#
# A box is only needed where the root cannot be named. The critical point can:
# it is `0`, and every iterate of it is a Gaussian rational. For such a point
# the residual is decided by exact identity, with no enclosure and no import.


def exact_residual(z: GQ, c: GQ, preperiod: int, period: int) -> GQ | None:
    """`R^c_{l,k}(z)` at an exactly representable point, exactly."""
    if preperiod < 0 or period < 1:
        return None
    late, early = z, z
    for _ in range(preperiod + period):
        late = point_step(late, c)
    for _ in range(preperiod):
        early = point_step(early, c)
    return late - early


def exact_residual_derivative(z: GQ, c: GQ, preperiod: int, period: int) -> GQ | None:
    """`R'` at an exactly representable point, by the chain rule, exactly."""
    if preperiod < 0 or period < 1:
        return None

    def derivative(steps: int) -> GQ:
        product, point = GQ.of(1), z
        for _ in range(steps):
            product = product * point.scale(2)
            point = point_step(point, c)
        return product

    return derivative(preperiod + period) - derivative(preperiod)


def is_exact_root(z: GQ, c: GQ, preperiod: int, period: int) -> bool:
    """Does this exactly representable point have that preperiod and period?

    An identity over `Q(i)`, not an enclosure: no interval, no contraction,
    and no import. Where a root can be named this is the whole certificate.
    """
    residue = exact_residual(z, c, preperiod, period)
    return residue is not None and residue.is_zero()


def branching_multiplicity(z: GQ, c: GQ, preperiod: int, period: int) -> int | None:
    """The multiplicity of a root by the branching recursion, or `None`.

    `R_{l,k} = R_{l-1,k} . f` for `l >= 1`, because `f^n(z)` depends on `z`
    only through `f(z)` once `n >= 1`. So the multiplicity at `z` is the
    multiplicity at `f(z)` of the shorter residual, doubled exactly when `z`
    is the critical point, where `f` is two-to-one. That doubling is the whole
    reason a Misiurewicz critical point is a multiple root of its own
    residual, and it is why no amount of refinement isolates it.

    This is the *account*, not the computation. It stops at a degenerate base
    -- `R'_{0,k}(z) = 0` means the cycle has multiplier one, a parabolic
    parameter -- and returns `None` there. `exact_multiplicity` answers that
    case too, by a different route, and `tests/test_preperiodic.py` checks the
    two agree wherever both are defined.
    """
    if not is_exact_root(z, c, preperiod, period):
        return None
    if preperiod == 0:
        slope = exact_residual_derivative(z, c, 0, period)
        return 1 if slope is not None and not slope.is_zero() else None
    inner = branching_multiplicity(point_step(z, c), c, preperiod - 1, period)
    if inner is None:
        return None
    return inner * (2 if z.is_zero() else 1)


def exact_multiplicity(z: GQ, c: GQ, preperiod: int, period: int, order: int = 8) -> int | None:
    """The multiplicity of an exactly representable root, or `None`.

    The order of vanishing of the residual's jet at the point, which needs no
    coefficients and no case analysis: `reference/jet.py` pushes the seed jet
    through the iteration and the first nonzero coefficient is the answer.
    It covers the parabolic case that `branching_multiplicity` refuses, where
    the cycle has multiplier one and the root is degenerate for a reason the
    branching recursion cannot see.

    `None` where the point is not a root, or where the jet is flat to the
    order computed -- the second is a budget that ran out and says only that
    the multiplicity is above `order`.
    """
    if not is_exact_root(z, c, preperiod, period):
        return None
    return vanishing_order(jet_residual(z, c, preperiod, period, order))


# --- enumeration, and when it is complete ----------------------------------


def search_radius(c: ComplexBox) -> Fraction:
    """The smallest integer `r` with `r^2` at or above the escape bound.

    Every preperiodic point has a bounded orbit, so by `docs/escape-criterion.md`
    its quadrance never passes the bound, and both coordinates are at most `r`.
    The search box is therefore not a guess about where the roots are: it is
    the region outside which there are none.
    """
    bound = escape_bound_quadrance(c)
    radius = 1
    while radius * radius < bound:
        radius += 1
    return Fraction(radius)


def search_box(c: ComplexBox) -> ComplexBox:
    radius = search_radius(c)
    return ComplexBox.of(-radius, radius, -radius, radius)


@dataclass(frozen=True, slots=True)
class Enumeration:
    """What a search found, and what it leaves unaccounted for."""

    preperiod: int
    period: int
    isolated: tuple[ComplexBox, ...]
    undecided: tuple[ComplexBox, ...]

    def degree(self) -> int:
        """`deg R^c_{l,k} = 2^(l+k)`: the leading terms cannot cancel, because
        the two iterates have different degrees."""
        return 2 ** (self.preperiod + self.period)


def cluster(boxes: tuple[ComplexBox, ...]) -> tuple[tuple[ComplexBox, ...], ...]:
    """Group boxes into connected components, two boxes joined when they meet.

    The subdivision grid is dyadic and so are many of the roots, so a root
    lands on a cut line as often as not and every cell around it has it on a
    boundary, where no contraction is possible. Clustering repairs that
    without knowing where the root is: the cells that stay undecided are the
    ones near a root, and their component's bounding box is centred on it.
    """
    groups: list[list[ComplexBox]] = []
    for box in boxes:
        touching = [group for group in groups if any(overlap(box, other) is not None for other in group)]
        merged = [box] + [other for group in touching for other in group]
        groups = [group for group in groups if group not in touching] + [merged]
    return tuple(tuple(group) for group in groups)


def bounding(boxes: tuple[ComplexBox, ...]) -> ComplexBox:
    """The smallest box holding all of them."""
    return ComplexBox.of(
        min(box.re.lo for box in boxes), max(box.re.hi for box in boxes),
        min(box.im.lo for box in boxes), max(box.im.hi for box in boxes),
    )


def enumerate_roots(c: ComplexBox, preperiod: int, period: int, max_depth: int = 9) -> Enumeration:
    """Subdivide the search box, then certify each cluster of what is left.

    A search is not a witness. Every box this returns still has to pass
    `certify`, which is what both implementations check; what the search adds
    is the claim that it looked everywhere, and `certifies_all_roots` is where
    that claim is made good.
    """
    isolated: list[ComplexBox] = []
    residue: list[ComplexBox] = []

    def visit(box: ComplexBox, depth: int) -> None:
        verdict = certify(box, c, preperiod, period).verdict
        if verdict is RootVerdict.EXCLUDED:
            return
        if verdict is RootVerdict.ISOLATED:
            isolated.append(box)
            return
        if depth == 0:
            residue.append(box)
            return
        for quarter in box.quarters():
            visit(quarter, depth - 1)

    visit(search_box(c), max_depth)
    undecided: list[ComplexBox] = []
    for group in cluster(tuple(residue)):
        box = bounding(group)
        if certify(box, c, preperiod, period).verdict is RootVerdict.ISOLATED:
            isolated.append(box)
        else:
            undecided.append(box)
    return Enumeration(preperiod, period, tuple(isolated), tuple(undecided))


def overlap(a: ComplexBox, b: ComplexBox) -> ComplexBox | None:
    """The shared box of two boxes, or `None` when they are disjoint."""
    re_lo, re_hi = max(a.re.lo, b.re.lo), min(a.re.hi, b.re.hi)
    im_lo, im_hi = max(a.im.lo, b.im.lo), min(a.im.hi, b.im.hi)
    if re_lo > re_hi or im_lo > im_hi:
        return None
    return ComplexBox.of(re_lo, re_hi, im_lo, im_hi)


def holds(box: ComplexBox, z: GQ) -> bool:
    """Is the exactly representable point inside the closed box?"""
    return box.re.lo <= z.re <= box.re.hi and box.im.lo <= z.im <= box.im.hi


def certifies_all_roots(
    found: Enumeration,
    c: ComplexBox,
    exact_roots: tuple[GQ, ...] = (),
) -> bool:
    """Is every root of `R^c_{l,k}` accounted for, with multiplicity?

    The count is the certificate. `R` has exactly `2^(l+k)` roots counted with
    multiplicity, so once the isolated simple roots and the exactly named ones
    add up to that, there is no room left for another. The undecided boxes
    need no explaining under that identity: a root hiding in one would push
    the total past the degree.

    What does need checking, and is:

    - `c` is a single parameter, because the exact arithmetic needs one;
    - each named point really is a root, and its multiplicity is computed
      here rather than taken on trust;
    - the named points are distinct from each other;
    - no isolated box holds a named point, so nothing is counted twice;
    - no two isolated boxes hold the same root. Boxes from a subdivision
      share edges, so disjointness is the wrong test: two are distinct when
      their shared region excludes a root, which is exclusion again.
    """
    if c.re.lo != c.re.hi or c.im.lo != c.im.hi:
        return False
    parameter = GQ(c.re.lo, c.im.lo)
    preperiod, period = found.preperiod, found.period

    if len({(root.re, root.im) for root in exact_roots}) != len(exact_roots):
        return False
    multiplicities = [exact_multiplicity(root, parameter, preperiod, period) for root in exact_roots]
    if any(multiplicity is None for multiplicity in multiplicities):
        return False

    for index, box in enumerate(found.isolated):
        if any(holds(box, root) for root in exact_roots):
            return False
        for other in found.isolated[index + 1:]:
            shared = overlap(box, other)
            if shared is not None and not excludes(shared, c, preperiod, period):
                return False

    return len(found.isolated) + sum(multiplicities) == found.degree()
