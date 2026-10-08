# algebraic_parameter.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
#
# The Mojo check of the algebraic corpus (kernel/algebraic_corpus.mojo,
# generated from reference/algebraic_corpus.py). For every root handle it
# decides, over exact rational intervals:
#
# - the polynomial is an exact period-n Gleason factor: it divides f_c^n(0)
#   exactly (vendored finite_polynomial, monic division), and for each proper
#   divisor d of n a Bezout certificate a p + b f_c^d(0) = n, n != 0, checks by
#   multiplication alone;
# - the box isolates a root of the polynomial: the Krawczyk image lies strictly
#   inside the box (vendored root_isolation; the import is
#   KrawczykMooreUniqueness, docs/literature-gate-2026-09-20-krawczyk.md);
# - boxes on one polynomial are disjoint, so they name distinct roots;
# - the declared trap is a trap of the row's period at every parameter in the box.
#
# The identification of a box with a component is the ungated import
# ParameterRayLandingCorrespondence, here as in the reference; nothing checked
# here depends on it.

from finite_exact.closed_interval import ComplexIQ, IQ
from finite_exact.rat_q import Q
from root_isolation.boxes import centre, disjoint, exact_inverse
from root_isolation.krawczyk import krawczyk_image
from root_isolation.krawczyk_moore import strictly_inside
from box_classifier import is_trap
from algebraic_corpus import ALGEBRAIC_SIZE, AlgebraicRow, algebraic_row, bezout_certificate, certificate_count
from finite_polynomial.polynomial_z import PolyZ, poly_add, poly_div_exact_monic, poly_equal, poly_from_i64, poly_mul


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


def _poly(coefficients: List[Int]) -> PolyZ:
    var values = List[Int64]()
    for c in coefficients:
        values.append(Int64(c))
    return poly_from_i64(values)


def gleason(n: Int) -> PolyZ:
    """`f_c^n(0)` as an integer polynomial in `c`."""
    var c: List[Int64] = [0, 1]
    var variable = poly_from_i64(c)
    var g = variable.copy()
    for _ in range(n - 1):
        g = poly_add(poly_mul(g, g), variable)
    return g^


def exact_period(index: Int) -> Bool:
    """The row's polynomial is a monic factor of `f_c^n(0)` sharing no root with `f_c^d(0)` for every
    proper divisor `d` of `n`: exact division, then one Bezout certificate per divisor."""
    var row = algebraic_row(index)
    var p = _poly(row.coefficients)
    if not poly_div_exact_monic(gleason(row.period), p).accepted():
        return False
    var covered = 0
    for j in range(certificate_count(index)):
        var cert = bezout_certificate(index, j)
        if cert.n == 0 or cert.divisor < 1 or cert.divisor >= row.period or row.period % cert.divisor != 0:
            return False
        var lhs = poly_add(poly_mul(_poly(cert.a), p), poly_mul(_poly(cert.b), gleason(cert.divisor)))
        var constant: List[Int64] = [Int64(cert.n)]
        if not poly_equal(lhs, poly_from_i64(constant)):
            return False
        covered += 1
    var divisors = 0
    for d in range(1, row.period):
        if row.period % d == 0:
            divisors += 1
    return covered == divisors


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
        if not exact_period(i) or not isolates(row) or not is_trap(row.trap, row.box, row.period):
            return False
        for j in range(i + 1, ALGEBRAIC_SIZE):
            var other = algebraic_row(j)
            if _same_polynomial(row, other):
                var apart = disjoint(row.box, other.box)
                if apart.rejected or not apart.value:
                    return False
    # The cubic is not a factor of f_c^4(0): exact division refuses it.
    var period_three: List[Int] = [1, 1, 2, 1]
    if poly_div_exact_monic(gleason(4), _poly(period_three)).accepted():
        return False
    # A box with no root of the cubic is refused.
    var cubic: List[Int] = [1, 1, 2, 1]
    var away = ComplexIQ(IQ(Q(1, 1), Q(2, 1)), IQ(Q(1, 1), Q(2, 1)))
    var empty = AlgebraicRow("probe", cubic^, away, 3, away, "")
    return not isolates(empty)
