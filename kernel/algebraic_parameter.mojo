# algebraic_parameter.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
#
# The Mojo check of the algebraic corpus (kernel/algebraic_corpus.mojo,
# generated from reference/algebraic_corpus.py). For every root handle it
# decides, over exact rational intervals:
#
# - the box isolates a root of the polynomial: the Krawczyk image lies strictly
#   inside the box (vendored root_isolation; the import is
#   KrawczykMooreUniqueness, docs/literature-gate-2026-09-20-krawczyk.md);
# - boxes on one polynomial are disjoint, so they name distinct roots;
# - the declared trap is a trap of the row's period at every parameter in the box.
#
# That the polynomial is an exact-period Gleason factor is integer algebra the
# Python reference decides; the identification of a box with a component is
# the import RationalRayLanding, here as there.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q
from root_isolation.boxes import centre, disjoint, exact_inverse
from root_isolation.krawczyk import krawczyk_image
from root_isolation.krawczyk_moore import strictly_inside
from box_classifier import is_trap
from algebraic_corpus import ALGEBRAIC_SIZE, AlgebraicRow, algebraic_row


def horner(coefficients: List[Int], z: ComplexIQ) -> ComplexIQ:
    """An enclosure of `p(z)` over the box `z`, constant term first."""
    var acc = ComplexIQ.singleton(Q.zero(), Q.zero())
    for i in range(len(coefficients) - 1, -1, -1):
        acc = acc.mul(z).add(ComplexIQ.singleton(Q(Int64(coefficients[i]), 1), Q.zero()))
    return acc^


def derivative(coefficients: List[Int]) -> List[Int]:
    var out = List[Int]()
    for i in range(1, len(coefficients)):
        out.append(i * coefficients[i])
    return out^


def isolates(row: AlgebraicRow) -> Bool:
    """The Krawczyk image of the row's box lies strictly inside it."""
    var slope = derivative(row.coefficients)
    var m = centre(row.box)
    var image = krawczyk_image(row.box, m, exact_inverse(horner(slope, m)), horner(row.coefficients, m), horner(slope, row.box))
    var inside = strictly_inside(image, row.box)
    return inside.value and not inside.rejected


def _same_polynomial(a: AlgebraicRow, b: AlgebraicRow) -> Bool:
    if len(a.coefficients) != len(b.coefficients):
        return False
    for i in range(len(a.coefficients)):
        if a.coefficients[i] != b.coefficients[i]:
            return False
    return True


def algebraic_corpus_smoke() -> Bool:
    for i in range(ALGEBRAIC_SIZE):
        var row = algebraic_row(i)
        if not isolates(row) or not is_trap(row.trap, row.box, row.period):
            return False
        for j in range(i + 1, ALGEBRAIC_SIZE):
            var other = algebraic_row(j)
            if _same_polynomial(row, other):
                var apart = disjoint(row.box, other.box)
                if apart.rejected or not apart.value:
                    return False
    # A box with no root of the cubic is refused.
    var cubic: List[Int] = [1, 1, 2, 1]
    var away = ComplexIQ(IQ(Q(1, 1), Q(2, 1)), IQ(Q(1, 1), Q(2, 1)))
    var empty = AlgebraicRow("probe", cubic^, away, 3, away, "")
    return not isolates(empty)
