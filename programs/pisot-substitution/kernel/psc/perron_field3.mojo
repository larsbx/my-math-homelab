"""Exact cubic Perron-field arithmetic for the standing alphabet-three PIP regime.

Elements are stored in the integral power basis ``1, beta, beta^2`` modulo the
monic characteristic polynomial of the incidence matrix. Order at the Perron
embedding is decided by a specialized Sturm--Tarski signed-remainder query with
checked fixed-width integer arithmetic. No floating point, rational bisection,
or Euclidean stable-space lattice is used.

The implementation is an executable finite-research kernel over Mojo ``Int``.
Every theorem-facing arithmetic operation used by the overlap diagnostic checks
for overflow and raises on an unsafe intermediate rather than wrapping. A
successful finite run is exact; failure is inconclusive, not mathematical
evidence.
"""

from finite_linear_algebra.mat3 import Mat3
from finite_exact.checked_int import (
    checked_abs as _checked_abs,
    checked_add as _checked_add,
    checked_mul as _checked_mul,
    checked_neg as _checked_neg,
    checked_sub as _checked_sub,
)
from psc.perron_root_sign import perron_sign_by_enclosure
from psc.pisot import is_pip, is_pisot_charpoly, is_primitive
from psc.pisot_screen import has_rational_root


struct CubicElt(ImplicitlyCopyable, Copyable, Movable, Equatable, Hashable, Writable):
    var a0: Int
    var a1: Int
    var a2: Int

    def __init__(out self, a0: Int = 0, a1: Int = 0, a2: Int = 0):
        self.a0 = a0
        self.a1 = a1
        self.a2 = a2

    def __eq__(self, other: CubicElt) -> Bool:
        return self.a0 == other.a0 and self.a1 == other.a1 and self.a2 == other.a2

    def __ne__(self, other: CubicElt) -> Bool:
        return not (self == other)

    def __add__(self, other: CubicElt) -> CubicElt:
        return CubicElt(self.a0 + other.a0, self.a1 + other.a1, self.a2 + other.a2)

    def __sub__(self, other: CubicElt) -> CubicElt:
        return CubicElt(self.a0 - other.a0, self.a1 - other.a1, self.a2 - other.a2)

    def __neg__(self) -> CubicElt:
        return CubicElt(-self.a0, -self.a1, -self.a2)

    def scale(self, n: Int) -> CubicElt:
        return CubicElt(n * self.a0, n * self.a1, n * self.a2)

    def is_zero(self) -> Bool:
        return self.a0 == 0 and self.a1 == 0 and self.a2 == 0

    def write_to[W: Writer](self, mut w: W):
        w.write("(", self.a0, ",", self.a1, ",", self.a2, ")")


struct PerronField3(ImplicitlyCopyable, Copyable, Movable):
    """One irreducible cubic field with a distinguished Pisot Perron root."""

    var chi0: Int
    var chi1: Int
    var chi2: Int

    def __init__(out self, chi0: Int, chi1: Int, chi2: Int):
        self.chi0 = chi0
        self.chi1 = chi1
        self.chi2 = chi2

    def charpoly(self) -> List[Int]:
        return [self.chi0, self.chi1, self.chi2, 1]


struct TileLengths3(ImplicitlyCopyable, Copyable, Movable):
    """Positive left-Perron tile lengths, up to one common positive scale."""

    var l0: CubicElt
    var l1: CubicElt
    var l2: CubicElt

    def __init__(out self, l0: CubicElt, l1: CubicElt, l2: CubicElt):
        self.l0 = l0
        self.l1 = l1
        self.l2 = l2

    def at(self, letter: Int) raises -> CubicElt:
        if letter == 0:
            return self.l0
        if letter == 1:
            return self.l1
        if letter == 2:
            return self.l2
        raise Error("tile-length letter lies outside 0..2")


def _mul3(a: Int, b: Int, c: Int) raises -> Int:
    return _checked_mul(_checked_mul(a, b), c)


def _mul4(a: Int, b: Int, c: Int, d: Int) raises -> Int:
    return _checked_mul(_mul3(a, b, c), d)


def _mul5(a: Int, b: Int, c: Int, d: Int, e: Int) raises -> Int:
    return _checked_mul(_mul4(a, b, c, d), e)


def _sign_int(x: Int) -> Int:
    if x > 0:
        return 1
    if x < 0:
        return -1
    return 0


def cubic_add_checked(x: CubicElt, y: CubicElt) raises -> CubicElt:
    return CubicElt(
        _checked_add(x.a0, y.a0),
        _checked_add(x.a1, y.a1),
        _checked_add(x.a2, y.a2),
    )


def cubic_sub_checked(x: CubicElt, y: CubicElt) raises -> CubicElt:
    return CubicElt(
        _checked_sub(x.a0, y.a0),
        _checked_sub(x.a1, y.a1),
        _checked_sub(x.a2, y.a2),
    )


def cubic_scale_checked(x: CubicElt, n: Int) raises -> CubicElt:
    return CubicElt(
        _checked_mul(n, x.a0),
        _checked_mul(n, x.a1),
        _checked_mul(n, x.a2),
    )


# Widest incidence column sum (longest image) the legacy predicates are
# certified on; see `_validate_bounded_incidence_domain`.
comptime MAX_CERTIFIED_COLUMN_SUM = 6


def _validate_bounded_incidence_domain(m: Mat3) raises:
    """Restrict the legacy PIP predicate to its audited finite input domain.

    The predicate's fixed-width steps are the primitivity test, which forms
    powers up to `M^6`, the characteristic polynomial, and the rational-root
    test; the Pisot test runs over unbounded rationals. With every column sum
    of the non-negative `M` at most `C`, every column sum of `M^k` is at most
    `C^k`, so the entries of `M^6` are at most `C^6`; the cubic's coefficients
    are at most `3C`, `3C^2` and `C^3` in absolute value (the determinant is
    bounded by the permanent, hence by the product of the column sums); and
    the rational-root test evaluates the cubic at divisors `r` of the constant
    term, `|r| <= C^3`, whose largest term is `|r|^3 <= C^9`. At
    `C = MAX_CERTIFIED_COLUMN_SUM = 6`, `C^9 = 10077696` and every intermediate
    is a small multiple of it, far inside `Int`. The repository corpora
    (`psc.corpus`) are non-erasing three-letter substitutions with images of
    length at most six, so they lie inside this domain; inputs outside it must not reach the unchecked predicates through
    this exact overlap kernel.
    """
    if len(m.e) != 9:
        raise Error("cubic Perron field requires a 3x3 incidence matrix")
    for col in range(3):
        var column_sum = 0
        for row in range(3):
            var entry = m.at(row, col)
            if entry < 0 or entry > MAX_CERTIFIED_COLUMN_SUM:
                raise Error(
                    "cubic Perron PIP validation is certified only for image lengths at most "
                    + String(MAX_CERTIFIED_COLUMN_SUM)
                )
            column_sum += entry
        if column_sum <= 0 or column_sum > MAX_CERTIFIED_COLUMN_SUM:
            raise Error(
                "cubic Perron PIP validation is certified only for non-erasing image lengths at most "
                + String(MAX_CERTIFIED_COLUMN_SUM)
            )


# Entry bound of the coefficient-screened field below: wide enough for any
# power of a three-letter substitution and for the parametric lines of the
# catch-up-free class (docs/p1b-symbolic-line-2026-10-07.md), narrow enough that
# the characteristic polynomial's intermediates stay small: each coefficient is
# a sum of at most six products of three entries, so at most 6 * 4096^3 < 2^39,
# far inside Int. Everything downstream of the field is checked arithmetic.
comptime SCREENED_ENTRY_BOUND = 4096


def screened_perron_field3(m: Mat3, entry_bound: Int = SCREENED_ENTRY_BOUND) raises -> PerronField3:
    """The cubic Perron field of `m`, screened on its characteristic polynomial.

    `build_perron_field3` is certified only on its audited domain (column sums
    at most `MAX_CERTIFIED_COLUMN_SUM`), because it runs the matrix-level PIP
    predicate. What the field needs is the characteristic polynomial, so this
    entry point screens that polynomial with the exact coefficient tests the
    corpus screen uses -- irreducibility by rational roots, the Pisot property
    by Sturm counting, both over unbounded rationals -- and decides
    primitivity on Boolean support powers, which cannot overflow. Entries beyond `entry_bound` (at most
    `SCREENED_ENTRY_BOUND`; a caller may state a narrower domain of its own) are refused.
    Everything downstream of the field is checked arithmetic and raises on
    overflow rather than wrapping."""
    if entry_bound > SCREENED_ENTRY_BOUND:
        raise Error("an entry bound above SCREENED_ENTRY_BOUND is outside the audited arithmetic")
    for row in range(3):
        for col in range(3):
            var entry = m.at(row, col)
            if entry < 0 or entry > entry_bound:
                raise Error("incidence entry outside the screened-field bound")
    if not is_primitive(m):
        raise Error("the screened field needs a primitive matrix")
    var chi = m.charpoly()
    if has_rational_root(chi):  # exact over Q, unlike the fixed-width matrix-level test
        raise Error("the characteristic polynomial is reducible")
    if not is_pisot_charpoly(chi):
        raise Error("the characteristic polynomial is not Pisot")
    return PerronField3(chi[0], chi[1], chi[2])


def build_perron_field3(m: Mat3) raises -> PerronField3:
    _validate_bounded_incidence_domain(m)
    if not is_pip(m):
        raise Error("cubic Perron field requires a primitive irreducible Pisot matrix")
    var chi = m.charpoly()
    return PerronField3(chi[0], chi[1], chi[2])


def cubic_mul_beta(field: PerronField3, x: CubicElt) raises -> CubicElt:
    """Multiply by beta using beta^3 = -chi2 beta^2 - chi1 beta - chi0."""
    var c0 = _checked_neg(_checked_mul(field.chi0, x.a2))
    var c1 = _checked_sub(x.a0, _checked_mul(field.chi1, x.a2))
    var c2 = _checked_sub(x.a1, _checked_mul(field.chi2, x.a2))
    return CubicElt(c0, c1, c2)


def cubic_mul(field: PerronField3, x: CubicElt, y: CubicElt) raises -> CubicElt:
    var v0 = _checked_mul(x.a0, y.a0)
    var v1 = _checked_add(_checked_mul(x.a0, y.a1), _checked_mul(x.a1, y.a0))
    var v2 = _checked_add(
        _checked_add(_checked_mul(x.a0, y.a2), _checked_mul(x.a1, y.a1)),
        _checked_mul(x.a2, y.a0),
    )
    var v3 = _checked_add(_checked_mul(x.a1, y.a2), _checked_mul(x.a2, y.a1))
    var v4 = _checked_mul(x.a2, y.a2)
    var v: List[Int] = [v0, v1, v2, v3, v4]

    for degree in range(4, 2, -1):
        var coefficient = v[degree]
        if coefficient == 0:
            continue
        v[degree - 1] = _checked_sub(
            v[degree - 1], _checked_mul(coefficient, field.chi2)
        )
        v[degree - 2] = _checked_sub(
            v[degree - 2], _checked_mul(coefficient, field.chi1)
        )
        v[degree - 3] = _checked_sub(
            v[degree - 3], _checked_mul(coefficient, field.chi0)
        )
        v[degree] = 0
    return CubicElt(v[0], v[1], v[2])


def _eval_monic_cubic(field: PerronField3, z: Int) raises -> Int:
    var value = _checked_add(z, field.chi2)
    value = _checked_add(_checked_mul(value, z), field.chi1)
    value = _checked_add(_checked_mul(value, z), field.chi0)
    return value


def _eval_quadratic(a: Int, b: Int, c: Int, z: Int) raises -> Int:
    return _checked_add(_checked_mul(_checked_add(_checked_mul(a, z), b), z), c)


def _eval_linear(a: Int, b: Int, z: Int) raises -> Int:
    return _checked_add(_checked_mul(a, z), b)


def _variations(signs: List[Int]) -> Int:
    var previous = 0
    var count = 0
    for i in range(len(signs)):
        var current = signs[i]
        if current == 0:
            continue
        if previous != 0 and current != previous:
            count += 1
        previous = current
    return count


def _sequence_variations_at(
    field: PerronField3,
    a: Int,
    b: Int,
    c: Int,
    d: Int,
    e: Int,
    terminal_sign: Int,
    z: Int,
) raises -> Int:
    var signs = List[Int]()
    signs.append(_sign_int(_eval_monic_cubic(field, z)))
    signs.append(_sign_int(_eval_quadratic(a, b, c, z)))
    if a != 0:
        signs.append(_sign_int(_eval_linear(d, e, z)))
        if d != 0:
            signs.append(terminal_sign)
    elif b != 0:
        signs.append(terminal_sign)
    return _variations(signs)


def _perron_integer_bound(field: PerronField3) raises -> Int:
    var m = _checked_abs(field.chi0)
    var t = _checked_abs(field.chi1)
    if t > m:
        m = t
    t = _checked_abs(field.chi2)
    if t > m:
        m = t
    return _checked_add(m, 1)


def _signed_remainder_coefficients(
    field: PerronField3, x: CubicElt
) raises -> Tuple[Int, Int, Int]:
    # S1 = rem(P' * Q, P), where P is the monic characteristic cubic and
    # Q = x.a2 X^2 + x.a1 X + x.a0.
    var a = field.chi2
    var b = field.chi1
    var c = field.chi0
    var u = x.a2
    var v = x.a1
    var w = x.a0

    var A = _checked_mul(_checked_mul(a, a), u)
    A = _checked_sub(A, _checked_mul(a, v))
    A = _checked_sub(A, _checked_mul(2, _checked_mul(b, u)))
    A = _checked_add(A, _checked_mul(3, w))

    var B = _checked_mul(_checked_mul(a, b), u)
    B = _checked_add(B, _checked_mul(2, _checked_mul(a, w)))
    B = _checked_sub(B, _checked_mul(2, _checked_mul(b, v)))
    B = _checked_sub(B, _checked_mul(3, _checked_mul(c, u)))

    var C = _checked_mul(_checked_mul(a, c), u)
    C = _checked_add(C, _checked_mul(b, w))
    C = _checked_sub(C, _checked_mul(3, _checked_mul(c, v)))
    return (A, B, C)


def _quadratic_terminal_sign(
    field: PerronField3,
    A: Int,
    B: Int,
    C: Int,
) raises -> Tuple[Int, Int, Int]:
    # For A != 0, S2 has the sign of D X + E. If D != 0, the final constant
    # S3 has sign -sign(R), where R is the resultant-like factor below. All
    # omitted pseudo-division scales are positive, so signs are unchanged.
    var a = field.chi2
    var b = field.chi1
    var c = field.chi0
    var A2 = _checked_mul(A, A)
    var B2 = _checked_mul(B, B)

    var D = _checked_neg(_checked_mul(A2, b))
    D = _checked_add(D, _mul3(A, B, a))
    D = _checked_add(D, _checked_mul(A, C))
    D = _checked_sub(D, B2)

    var E = _checked_neg(_checked_mul(A2, c))
    E = _checked_add(E, _mul3(A, C, a))
    E = _checked_sub(E, _checked_mul(B, C))

    if D == 0:
        if E == 0:
            raise Error("Sturm-Tarski sequence lost coprimality")
        return (D, E, _sign_int(E))

    var R = _mul5(A, A, A, c, c)
    R = _checked_sub(R, _mul5(A, A, B, b, c))
    R = _checked_sub(R, _checked_mul(2, _mul5(A, A, C, a, c)))
    R = _checked_add(R, _mul5(A, A, C, b, b))
    R = _checked_add(R, _mul5(A, B, B, a, c))
    R = _checked_sub(R, _mul5(A, B, C, a, b))
    R = _checked_add(R, _checked_mul(3, _mul4(A, B, C, c)))
    R = _checked_add(R, _mul5(A, C, C, a, a))
    R = _checked_sub(R, _checked_mul(2, _mul4(A, C, C, b)))
    R = _checked_sub(R, _mul4(B, B, B, c))
    R = _checked_add(R, _mul4(B, B, C, b))
    R = _checked_sub(R, _mul4(B, C, C, a))
    R = _checked_add(R, _mul3(C, C, C))
    if R == 0:
        raise Error("Sturm-Tarski terminal resultant unexpectedly vanished")
    return (D, E, -_sign_int(R))


def _linear_terminal_sign(field: PerronField3, B: Int, C: Int) raises -> Int:
    # For S1 = B X + C, S2 = -P(-C/B). Its sign is
    # -sign(N)*sign(B), with N = B^3 P(-C/B).
    var a = field.chi2
    var b = field.chi1
    var c = field.chi0
    var N = _checked_neg(_mul3(C, C, C))
    N = _checked_add(N, _mul4(a, C, C, B))
    N = _checked_sub(N, _mul4(b, C, B, B))
    N = _checked_add(N, _mul4(c, B, B, B))
    if N == 0:
        raise Error("Sturm-Tarski linear resultant unexpectedly vanished")
    return -_sign_int(N) * _sign_int(B)


def _sign_without_remainders(field: PerronField3, x: CubicElt) raises -> Int:
    """Decide ``sign(Q(beta))`` when no signed-remainder chain is needed.

    Two exact shortcuts, in cost order. Both are one-sided: a ``0`` return
    means *undecided here*, never *zero*, so the caller still runs the full
    Sturm--Tarski query. Neither can narrow the decidable domain: the
    coefficient-sign test does no arithmetic at all, and every operation in
    the bracket is guarded, with an overflow reported as "undecided" and left
    for the authoritative path to raise on if it must.

    1. Coefficients of one sign. ``beta > 1 > 0``, so a nonzero ``Q`` with all
       coefficients ``>= 0`` has ``Q(beta) > 0``, and dually.
    2. A bracket over the integer enclosure ``1 < beta <= B`` of the Perron
       root. A quadratic attains its extremes on a closed interval at an
       endpoint or at its vertex, so when the vertex lies outside ``(1, B)``
       the two endpoint values bound ``Q`` over the whole interval; a bound
       that excludes zero proves the sign.
    """
    if x.a0 >= 0 and x.a1 >= 0 and x.a2 >= 0:
        return 1
    if x.a0 <= 0 and x.a1 <= 0 and x.a2 <= 0:
        return -1

    # Everything from here on is arithmetic that can overflow. It is all
    # guarded, and every failure returns "undecided" rather than raising, so
    # the bracket can only ever add an answer, never take one away.
    try:
        var hi = _perron_integer_bound(field)
        if hi <= 1:
            return 0
        if x.a2 != 0:
            # vertex at -a1 / (2 a2), placed against 1 and hi without dividing
            var numerator = _checked_neg(x.a1)
            var denominator = _checked_mul(2, x.a2)
            if denominator < 0:
                numerator = _checked_neg(numerator)
                denominator = _checked_neg(denominator)
            if numerator > denominator and numerator < _checked_mul(denominator, hi):
                return 0
        var at_one = _eval_quadratic(x.a2, x.a1, x.a0, 1)
        var at_hi = _eval_quadratic(x.a2, x.a1, x.a0, hi)
        if at_one > 0 and at_hi > 0:
            return 1
        if at_one < 0 and at_hi < 0:
            return -1
        return 0
    except:
        return 0


def _remainder_chain_fits(field: PerronField3, x: CubicElt) -> Bool:
    """Whether the signed-remainder chain is certain to stay inside ``Int``.

    With ``C = max(|chi_i|, 1)`` and ``H = max |a_i|``, the first remainder's
    coefficients are bounded by ``K = H (C^2 + 7C + 3)``, and the largest
    intermediate anywhere in the chain is the terminal resultant -- a cubic
    form in those coefficients with chi-quadratic weights, so it is under
    ``32 K^3 C^2``. When that fits, no operation in the chain can overflow;
    when it does not, or when the bound itself cannot be formed, the answer is
    ``False`` and the caller asks the unbounded oracle instead.

    This is deliberately a *static* test rather than catching the chain's own
    overflow: the chain also raises on a malformed field or a lost coprimality,
    and those are defects that must stay audible rather than be quietly
    rerouted. The price is that a band of coefficients the chain would in fact
    have settled is sent to the enclosure, which is exact and merely slower.
    """
    try:
        var c = 1
        for coefficient in [field.chi0, field.chi1, field.chi2]:
            var m = _checked_abs(coefficient)
            if m > c:
                c = m
        var h = 0
        for coefficient in [x.a0, x.a1, x.a2]:
            var m = _checked_abs(coefficient)
            if m > h:
                h = m
        var weight = _checked_add(
            _checked_add(_checked_mul(c, c), _checked_mul(7, c)), 3
        )
        var k = _checked_mul(h, weight)
        _ = _checked_mul(_checked_mul(32, _mul3(k, k, k)), _checked_mul(c, c))
        return True
    except:
        return False


def sign_at_perron(field: PerronField3, x: CubicElt) raises -> Int:
    """Return the exact sign of ``x(beta)``.

    Three rungs, cheapest first, and every one of them exact.

    1. ``_sign_without_remainders``: the coefficient signs, then a bracket over
       the integer enclosure of beta. Settles three calls in five.
    2. The Sturm--Tarski query for the Cauchy index of ``P' Q / P`` on
       ``(1,B]``. Because P has exactly one root there, the variation
       difference is precisely ``sign(Q(beta))``. The signed remainder sequence
       is specialized symbolically to degree 3/2, so every operation is checked
       fixed-width integer arithmetic -- fast, and bounded in coefficient size.
    3. ``psc.perron_root_sign``: the same sign from a rational enclosure of
       beta over unbounded arithmetic, when rung 2's bound would be exceeded.

    The coefficient bound of rung 2 is therefore not a bound on this function:
    it decides every nonzero element of ``Z[beta]`` whose coordinates fit in
    ``Int``, or raises on a defect. Nothing is ever guessed at any rung.
    """
    if x.is_zero():
        return 0

    var cheap = _sign_without_remainders(field, x)
    if cheap != 0:
        return cheap

    if not _remainder_chain_fits(field, x):
        return perron_sign_by_enclosure(
            field.chi0, field.chi1, field.chi2, x.a0, x.a1, x.a2
        )

    var coeffs = _signed_remainder_coefficients(field, x)
    var A = coeffs[0]
    var B = coeffs[1]
    var C = coeffs[2]
    if A == 0 and B == 0 and C == 0:
        raise Error("Sturm-Tarski first remainder unexpectedly vanished")

    var D = 0
    var E = 0
    var terminal_sign = 0
    if A != 0:
        var tail = _quadratic_terminal_sign(field, A, B, C)
        D = tail[0]
        E = tail[1]
        terminal_sign = tail[2]
    elif B != 0:
        terminal_sign = _linear_terminal_sign(field, B, C)

    var hi = _perron_integer_bound(field)
    if hi <= 1:
        raise Error("invalid Perron root bound")
    var lower = _sequence_variations_at(field, A, B, C, D, E, terminal_sign, 1)
    var upper = _sequence_variations_at(field, A, B, C, D, E, terminal_sign, hi)
    var answer = lower - upper
    if answer != 1 and answer != -1:
        raise Error("Sturm-Tarski Perron sign query did not isolate one signed root")
    return answer


def _row_entry(m: Mat3, row: Int, col: Int) -> CubicElt:
    # Row of M^T - beta I.
    return CubicElt(m.at(col, row), -1 if row == col else 0, 0)


def _cross(
    field: PerronField3,
    a0: CubicElt,
    a1: CubicElt,
    a2: CubicElt,
    b0: CubicElt,
    b1: CubicElt,
    b2: CubicElt,
) raises -> TileLengths3:
    return TileLengths3(
        cubic_sub_checked(cubic_mul(field, a1, b2), cubic_mul(field, a2, b1)),
        cubic_sub_checked(cubic_mul(field, a2, b0), cubic_mul(field, a0, b2)),
        cubic_sub_checked(cubic_mul(field, a0, b1), cubic_mul(field, a1, b0)),
    )


def _all_zero(lengths: TileLengths3) -> Bool:
    return lengths.l0.is_zero() and lengths.l1.is_zero() and lengths.l2.is_zero()


def _negate_lengths(lengths: TileLengths3) raises -> TileLengths3:
    return TileLengths3(
        CubicElt(_checked_neg(lengths.l0.a0), _checked_neg(lengths.l0.a1), _checked_neg(lengths.l0.a2)),
        CubicElt(_checked_neg(lengths.l1.a0), _checked_neg(lengths.l1.a1), _checked_neg(lengths.l1.a2)),
        CubicElt(_checked_neg(lengths.l2.a0), _checked_neg(lengths.l2.a1), _checked_neg(lengths.l2.a2)),
    )


def left_perron_tile_lengths(m: Mat3) raises -> TileLengths3:
    """Construct and verify a positive left Perron eigenvector exactly."""
    return perron_tile_lengths_in(build_perron_field3(m), m)


def perron_tile_lengths_in(field: PerronField3, m: Mat3) raises -> TileLengths3:
    """The same construction, inside a field a caller has already built.

    Split out of `left_perron_tile_lengths` because a caller that legitimately
    works outside `build_perron_field3`'s certified domain -- a substitution
    raised to a power, whose images outrun the audited bound that entry point
    states -- needs this eigenvector too, and a second copy of an exact
    construction is a second thing to keep right.

    The field is checked against the matrix rather than trusted: a field for a
    different characteristic polynomial would make every sign query below
    answer about the wrong number, and the eigenvector would come back verified
    and wrong."""
    var mine = field.charpoly()
    var theirs = m.charpoly()
    for i in range(len(theirs)):
        if mine[i] != theirs[i]:
            raise Error("the field does not belong to this incidence matrix")
    var lengths = TileLengths3(CubicElt(), CubicElt(), CubicElt())
    var found = False
    for r in range(3):
        for s in range(r + 1, 3):
            var candidate = _cross(
                field,
                _row_entry(m, r, 0),
                _row_entry(m, r, 1),
                _row_entry(m, r, 2),
                _row_entry(m, s, 0),
                _row_entry(m, s, 1),
                _row_entry(m, s, 2),
            )
            if not _all_zero(candidate):
                lengths = candidate
                found = True
                break
        if found:
            break
    if not found:
        raise Error("failed to construct a nonzero left Perron eigenvector")

    var s0 = sign_at_perron(field, lengths.l0)
    var s1 = sign_at_perron(field, lengths.l1)
    var s2 = sign_at_perron(field, lengths.l2)
    if s0 < 0 and s1 < 0 and s2 < 0:
        lengths = _negate_lengths(lengths)
        s0 = -s0
        s1 = -s1
        s2 = -s2
    if s0 <= 0 or s1 <= 0 or s2 <= 0:
        raise Error("constructed Perron tile lengths are not strictly positive")

    for parent in range(3):
        var total = CubicElt()
        for child in range(3):
            total = cubic_add_checked(
                total,
                cubic_scale_checked(lengths.at(child), m.at(child, parent)),
            )
        var expected = cubic_mul_beta(field, lengths.at(parent))
        if total != expected:
            raise Error("left Perron tile-length scaling identity failed")
    return lengths
