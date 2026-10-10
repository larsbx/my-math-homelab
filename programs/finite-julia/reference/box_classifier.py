"""The three-valued classifier over dyadic boxes.

Specification: docs/rational-interval-arithmetic-spec.md.
Certificates and their soundness: docs/three-valued-classifier.md.

    G(box) -> OUT | IN | UNKNOWN

`OUT` carries an escape certificate, `IN` carries a trap the orbit falls into,
and `UNKNOWN` carries nothing and claims nothing. Every routine is a checker:
a trap is supplied and verified, never searched for, except by
`trap_candidate`, which is a search tool and is not part of any certificate.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from fractions import Fraction

from escape_certificate import EscapeCertificate, escape_certificate
from closed_interval import ComplexBox


def step(box: ComplexBox, c: ComplexBox) -> ComplexBox:
    """`f_c(box) = box^2 + c`, as an enclosure of the image set."""
    return box.square().add(c)


def escape_bound_quadrance(c: ComplexBox) -> Fraction:
    """`max(4, N(c))`, taking the largest quadrance the parameter box allows."""
    return max(Fraction(4), c.quadrance().hi)


def escapes(box: ComplexBox, c: ComplexBox) -> bool:
    """Is the whole box past the escape bound?

    The test is on the *lower* endpoint of the box's quadrance, so it holds for
    every point the box encloses, not merely for some of them.
    """
    if not (box.accepted() and c.accepted()):
        return False
    return box.quadrance().lo > escape_bound_quadrance(c)


def is_trap(trap: ComplexBox, c: ComplexBox, period: int) -> bool:
    """Does `f_c^period` map the trap into itself?

    That is the whole `IN` certificate, and inclusion is all of it. By
    inclusion monotonicity `f^p(T) ⊆ F^p(T) ⊆ T`, so by induction every
    `f^(pn)(z)` is in `T` and every intermediate iterate is in one of the
    `p` boxes `F^j(T)`. A finite union of boxes is bounded, so `T ⊆ K_c`. No
    attracting cycle is named and none is needed.

    Inclusion here is **not** strict. It used to be, which cost the parabolic
    case: a parabolic fixed point sits on the boundary of its own basin, so
    every invariant box touches it and none is strictly invariant. Strictness
    would buy an attracting periodic point inside `T`, which this certificate
    neither claims nor needs. See `docs/three-valued-classifier.md` section 5.
    """
    if period < 1 or not (trap.accepted() and c.accepted()):
        return False
    image = trap
    for _ in range(period):
        image = step(image, c)
    return image.subset_of(trap)


class BoxVerdict(Enum):
    OUT = "OUT"
    IN = "IN"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True, slots=True)
class Classification:
    """What the classifier decided, and the witness it decided on."""

    verdict: BoxVerdict
    steps: int | None = None
    certificate: EscapeCertificate | None = None
    trap: ComplexBox | None = None

    def decided(self) -> bool:
        return self.verdict is not BoxVerdict.UNKNOWN


def classify(
    box: ComplexBox,
    c: ComplexBox,
    trap: ComplexBox | None = None,
    period: int = 1,
    horizon: int = 12,
) -> Classification:
    """Iterate the box until a certificate fires, or the horizon runs out.

    A supplied trap is verified before it is trusted; an unverified trap is
    ignored rather than believed, so a wrong witness costs an `UNKNOWN` and
    never an `IN`.
    """
    if horizon < 1 or not (box.accepted() and c.accepted()):
        return Classification(BoxVerdict.UNKNOWN)
    verified_trap = trap if (trap is not None and is_trap(trap, c, period)) else None
    image = box
    for n in range(horizon + 1):
        if escapes(image, c):
            return Classification(
                BoxVerdict.OUT,
                steps=n,
                certificate=escape_certificate(image.quadrance().lo, c.quadrance().hi),
            )
        if verified_trap is not None and image.subset_of(verified_trap):
            return Classification(BoxVerdict.IN, steps=n, trap=verified_trap)
        image = step(image, c)
        if not image.accepted():
            return Classification(BoxVerdict.UNKNOWN, steps=n)
    return Classification(BoxVerdict.UNKNOWN, steps=horizon)


@dataclass(frozen=True, slots=True)
class Census:
    """How a grid of boxes at one resolution came out."""

    resolution: int
    out: int
    inside: int
    unknown: int

    def total(self) -> int:
        return self.out + self.inside + self.unknown


def grid(radius: Fraction, resolution: int) -> list[ComplexBox]:
    """The `2^resolution` squared boxes tiling `[-radius, radius]^2`."""
    side = 2 ** resolution
    width = 2 * radius / side
    return [
        ComplexBox.of(-radius + i * width, -radius + (i + 1) * width,
                      -radius + j * width, -radius + (j + 1) * width)
        for i in range(side)
        for j in range(side)
    ]


def census(
    c: ComplexBox,
    resolution: int,
    trap: ComplexBox | None = None,
    period: int = 1,
    radius: Fraction = Fraction(2),
    horizon: int = 12,
) -> Census:
    """Classify a whole grid, and count the verdicts.

    The unresolved count is the interesting one: it is the residual the
    programme reports rather than shrinks, and it is expected to concentrate
    on the Julia set as the resolution rises.
    """
    counts = {BoxVerdict.OUT: 0, BoxVerdict.IN: 0, BoxVerdict.UNKNOWN: 0}
    for box in grid(radius, resolution):
        counts[classify(box, c, trap, period, horizon).verdict] += 1
    return Census(resolution, counts[BoxVerdict.OUT], counts[BoxVerdict.IN], counts[BoxVerdict.UNKNOWN])


@dataclass(frozen=True, slots=True)
class Refinement:
    """What adaptive subdivision of one box came to.

    `undecided` counts the leaves still unresolved at the depth limit, and
    `undecided_fraction` is the share of the original box they cover. Those
    leaves are the only thing the refinement claims: they are boxes the
    classifier refused, not boxes known to meet the Julia set. The share
    shrinking with depth is what the completeness theorems predict; it is not
    evidence for them.
    """

    out: int
    inside: int
    undecided: int
    deepest: int
    undecided_fraction: Fraction = Fraction(0)

    def leaves(self) -> int:
        return self.out + self.inside + self.undecided

    def decided(self) -> bool:
        return self.undecided == 0


def refine_until_decided(
    box: ComplexBox,
    c: ComplexBox,
    trap: ComplexBox | None = None,
    period: int = 1,
    max_depth: int = 4,
    horizon: int = 12,
) -> Refinement:
    """Subdivide the undecided part, to a depth limit.

    This is the constructive side of `docs/enclosure-width-lemma.md`: the
    theorems there say a small enough box is decided, and this is what
    "small enough" costs on a given box. The limit is a budget, and a leaf
    that reaches it is reported rather than guessed at.
    """
    verdict = classify(box, c, trap, period, horizon).verdict
    if verdict is BoxVerdict.OUT:
        return Refinement(1, 0, 0, 0, Fraction(0))
    if verdict is BoxVerdict.IN:
        return Refinement(0, 1, 0, 0, Fraction(0))
    if max_depth <= 0:
        return Refinement(0, 0, 1, 0, Fraction(1))
    out = inside = undecided = deepest = 0
    share = Fraction(0)
    for quarter in box.quarters():
        child = refine_until_decided(quarter, c, trap, period, max_depth - 1, horizon)
        out += child.out
        inside += child.inside
        undecided += child.undecided
        deepest = max(deepest, child.deepest + 1)
        share += child.undecided_fraction / 4
    return Refinement(out, inside, undecided, deepest, share)


def trap_candidate(c: ComplexBox, period: int, seed: ComplexBox, refinements: int = 12) -> ComplexBox | None:
    """Search for a trap by shrinking a seed box; not part of any certificate.

    A search is not a witness. Whatever this returns must still pass
    `is_trap`, which is what the classifier checks, and a caller that pins a
    trap should pin the box rather than the search that found it.
    """
    box = seed
    for _ in range(refinements):
        if is_trap(box, c, period):
            return box
        re_mid, im_mid = box.re.midpoint(), box.im.midpoint()
        re_half, im_half = box.re.width() / 4, box.im.width() / 4
        box = ComplexBox.of(re_mid - re_half, re_mid + re_half, im_mid - im_half, im_mid + im_half)
    return box if is_trap(box, c, period) else None
