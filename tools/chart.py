"""The affine charts of the projective line, and the map in each.

Specification: docs/rational-interval-arithmetic-spec.md.
Design: docs/projective-completion-and-escape.md.
Statements: docs/ray-certificates.md.

This is the Python side of a differential pair; the Mojo side is the vendored
`projective/chart.mojo`.

A chart is a division, so each function has a domain, and the domain is
enforced by the arithmetic: a box whose quadrance interval contains zero
leaves the chart rather than being evaluated. In the chart at infinity the
point at infinity has coordinate zero, is fixed, and is superattracting of
order two -- which is why a ray's tail is an ordinary bounded box here and an
unbounded one in the other chart.
"""

from __future__ import annotations

from interval_box import ComplexBox

ONE = ComplexBox.singleton(1)


def to_chart_at_infinity(z: ComplexBox) -> ComplexBox:
    """`u = 1/z`: the coordinate of a box in the chart centred on infinity."""
    return z.reciprocal()


def from_chart_at_infinity(u: ComplexBox) -> ComplexBox:
    """`z = 1/u`, back to the affine chart. Zero has no image here, which is
    infinity having no affine value -- the refusal is the geometry."""
    return u.reciprocal()


def chart_step(u: ComplexBox, c: ComplexBox) -> ComplexBox:
    """`u -> u^2 / (1 + c u^2)`, the quadratic map in the chart at infinity.

    Zero is fixed with derivative zero. The denominator is the second domain
    condition: where `1 + c u^2` could vanish, the step refuses.
    """
    if not (u.accepted() and c.accepted()):
        return ComplexBox.refused()
    squared = u.square()
    denominator = ONE.add(c.mul(squared))
    inverse = denominator.reciprocal()
    if not inverse.accepted():
        return ComplexBox.refused()
    return squared.mul(inverse)


def contracts_to_infinity(u: ComplexBox, c: ComplexBox) -> bool:
    """Does the chart step map this box strictly inside itself?

    The `OUT` certificate of `docs/projective-completion-and-escape.md`
    section 4, in the shape the `IN` certificate already has: a box around the
    superattracting fixed point that the map sends into itself. Strictly, so
    that the box is a genuine contraction neighbourhood rather than merely
    invariant.
    """
    image = chart_step(u, c)
    return image.accepted() and image.strict_subset_of(u)
