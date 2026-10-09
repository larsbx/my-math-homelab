"""An exact decision procedure for the standing PIP regime.

A substitution sigma on `{1,2,3}` is *primitive irreducible Pisot* when its
incidence matrix `M` is a primitive non-negative integer matrix whose
characteristic polynomial is irreducible over Q and whose Perron root beta > 1
is Pisot (all other conjugates in the open unit disc).

Every test here is exact: rational-root enumeration for irreducibility, Sturm
sequences over Q for real-root location, and an exact determinant identity for
the complex-conjugate case. No floating point is used anywhere; rationals are
the unbounded `finite_exact` values, so no coefficient growth can overflow.

The polynomial layer is the vendored `finite_linear_algebra.qpoly` wherever it
computes the same thing at no material cost: the derivative, the negation in
the Sturm chain, and the Cauchy root bound `1 + max |p_k| / |p_n|`. Four
helpers stay local, each for a stated reason:

- `poly_eval` is an unrolled Horner for the short polynomials of this regime
  and evaluating the Sturm chain is the hot loop of the Pisot screen; the
  vendored `qpoly.evaluate` is the pre-optimisation algorithm
  (`tests/polynomial_reference.mojo`) and measurably slower there, so
  `_sign_changes` stays on it rather than on `qpoly.sign_variations`.
- `poly_degree` scans in place; `qpoly.degree` copies the list to normalize it.
- `poly_rem` keeps the dividend's length and returns the dividend unchanged for
  a zero divisor, where `qpoly.remainder` normalizes and aborts;
  `tests/test_pisot_polynomials.mojo` pins that contract.
- `sturm_chain` is the chain of `p` itself. `qpoly.sturm_chain` first passes to
  the squarefree part, a second Euclidean pass that is redundant on the
  irreducible cubics this screen decides. On a squarefree `p` the two chains
  are the same polynomials.
"""

from std.os import abort

from finite_exact.rat_q import Q
from finite_linear_algebra import integer_matrix, qpoly
from psc.exact import q_int, q_is_zero, q_poly, q_sign
from finite_linear_algebra.mat3 import Mat3, has_rational_root


def poly_eval(p: List[Q], x: Q) -> Q:
    """Horner evaluation; `p` is low-degree-first."""
    var n = len(p)
    # Horner propagates a rejected argument even for a constant polynomial.
    if n > 0 and x.rejected:
        return x.copy()
    if n == 4:
        return p[3].mul(x).add(p[2]).mul(x).add(p[1]).mul(x).add(p[0])
    if n == 3:
        return p[2].mul(x).add(p[1]).mul(x).add(p[0])
    if n == 2:
        return p[1].mul(x).add(p[0])
    if n == 1:
        return p[0].copy()
    var acc = Q.zero()
    while n > 0:
        n -= 1
        acc = acc.mul(x).add(p[n])
    return acc^


def poly_degree(p: List[Q]) -> Int:
    var n = len(p)
    while n > 0:
        n -= 1
        if not q_is_zero(p[n]):
            return n
    return -1


def poly_rem(a: List[Q], b: List[Q]) -> List[Q]:
    """Remainder of `a` on division by `b` over Q."""
    var r = a.copy()
    var db = poly_degree(b)
    if db < 0:
        return r^
    var dr = poly_degree(r)
    if dr < db:
        return r^
    var inv = Q.one().div(b[db])
    while dr >= db:
        var f = r[dr].mul(inv)
        for i in range(db + 1):
            r[dr - db + i] = r[dr - db + i].sub(f.mul(b[i]))
        r[dr] = Q.zero()
        while dr >= 0:
            if not q_is_zero(r[dr]):
                break
            dr -= 1
    return r^


def sturm_chain(p: List[Q]) -> List[List[Q]]:
    """`p_0 = p`, `p_1 = p'`, `p_{k+1} = -rem(p_{k-1}, p_k)`.

    The chain of `p` itself, not of its squarefree part (see the module
    docstring); every entry after the first is normalized."""
    var chain = List[List[Q]]()
    chain.append(p.copy())
    chain.append(qpoly.derivative(p))
    while poly_degree(chain[len(chain) - 1]) > 0:
        var neg = qpoly.neg(poly_rem(chain[len(chain) - 2], chain[len(chain) - 1]))
        if len(neg) == 0:
            break
        chain.append(neg^)
    return chain^


def _sign_changes(chain: List[List[Q]], x: Q) -> Int:
    var last = 0
    var count = 0
    for i in range(len(chain)):
        var s = q_sign(poly_eval(chain[i], x))
        if s == 0:
            continue
        if last != 0 and s != last:
            count += 1
        last = s
    return count


def _count_in(chain: List[List[Q]], a: Q, b: Q) -> Int:
    return _sign_changes(chain, a) - _sign_changes(chain, b)


def count_roots_in(p: List[Q], a: Q, b: Q) -> Int:
    """Number of distinct real roots of `p` in the half-open interval `(a, b]`.

    Sturm's theorem, which requires that `p` vanish at neither endpoint when
    `p` is not squarefree."""
    return _count_in(sturm_chain(p), a, b)


def is_irreducible_cubic(coeffs: List[Int]) -> Bool:
    """A monic integer cubic is irreducible over Q iff it has no rational root."""
    return not has_rational_root(coeffs)


def is_nonnegative(m: Mat3) -> Bool:
    return integer_matrix.is_nonnegative(m.e)


def is_primitive(m: Mat3) -> Bool:
    """Some power of `m` is strictly positive (Wielandt: `k <= n^2 - 2n + 2 = 5`).

    The `Mat3` view of the vendored `integer_matrix.is_primitive`, which decides
    on Boolean support powers and so cannot overflow. It raises only on a
    dimension mismatch, which a `Mat3` (nine entries, size three) cannot have:
    reaching that refusal is an impossible state, so it aborts."""
    try:
        return integer_matrix.is_primitive(m.e, 3)
    except e:
        abort(String("Mat3 primitivity refused: ", e))


def is_pisot_charpoly(coeffs: List[Int]) -> Bool:
    """Exactly one root of the monic integer cubic lies outside the closed unit disc,
    and it is real and greater than 1.

    Case A (three real roots): decided entirely by Sturm counting.
    Case B (one real root, one conjugate pair): `beta * |beta_2|^2 = det`, so
    `|beta_2| < 1` iff `det < beta`, and since `beta` is the only real root that
    is equivalent to `chi(det) < 0`.
    """
    var p = q_poly(coeffs)
    var b = qpoly.root_bound(p)
    var one = Q.one()
    var minus_one = one.neg()
    # One chain serves the three counts.
    var chain = sturm_chain(p)
    var nreal = _count_in(chain, b.neg(), b)
    var above_one = _count_in(chain, one, b)
    if above_one != 1:
        return False
    if nreal == 3:
        return _count_in(chain, minus_one, one) == 2
    if nreal != 1:
        return False
    # det = -coeffs[0] for a monic cubic chi(t) = t^3 + c2 t^2 + c1 t + c0
    var det = -coeffs[0]
    if det <= 0:
        return False
    return q_sign(poly_eval(p, q_int(det))) < 0


struct CubicKey(ImplicitlyCopyable, Copyable, Movable, Equatable, Hashable):
    """A monic integer cubic `c0 + c1 x + c2 x^2 + x^3` as a dictionary key."""

    var c0: Int
    var c1: Int
    var c2: Int

    def __init__(out self, coeffs: List[Int]):
        self.c0 = coeffs[0]
        self.c1 = coeffs[1]
        self.c2 = coeffs[2]

    def __eq__(self, other: CubicKey) -> Bool:
        return self.c0 == other.c0 and self.c1 == other.c1 and self.c2 == other.c2

    def __ne__(self, other: CubicKey) -> Bool:
        return not (self == other)


struct CubicScreen(Copyable, Movable):
    """`is_pip` with the two characteristic-polynomial tests memoized.

    Primitivity is a property of the matrix, but irreducibility and the Pisot
    property are functions of the characteristic polynomial alone. Those two
    are the expensive half: rational-root enumeration and Sturm sequences over
    unbounded rationals. Screening the standing corpus evaluates them on
    33,318 primitive candidates that carry only 177 distinct cubics, so the
    verdict is decided once per cubic and reused.

    This changes no verdict. It is the same exact decision procedure, asked
    once per distinct question instead of once per candidate, so a memoized
    screen and a bare `is_pip` accept exactly the same matrices; the
    regression in `test_census_library.mojo` pins that.
    """

    var verdicts: Dict[CubicKey, Bool]

    def __init__(out self):
        self.verdicts = Dict[CubicKey, Bool]()

    def accepts_cubic(mut self, coeffs: List[Int]) raises -> Bool:
        """Whether the cubic is irreducible with a Pisot Perron root."""
        var key = CubicKey(coeffs)
        if key in self.verdicts:
            return self.verdicts[key]
        var verdict = is_irreducible_cubic(coeffs) and is_pisot_charpoly(coeffs)
        self.verdicts[key] = verdict
        return verdict

    def is_pip(mut self, m: Mat3) raises -> Bool:
        """Primitivity first, as in the free function: it is the cheap test and
        it rejects most candidates before any cubic work."""
        if not is_primitive(m):
            return False
        return self.accepts_cubic(m.charpoly())

    def distinct_cubics(self) -> Int:
        return len(self.verdicts)


def is_pip(m: Mat3) -> Bool:
    """Primitive, irreducible characteristic cubic, Pisot Perron root."""
    var chi = m.charpoly()
    return is_primitive(m) and is_irreducible_cubic(chi) and is_pisot_charpoly(chi)


def has_equal_row_sums(m: Mat3) -> Bool:
    var s0 = m.at(0, 0) + m.at(0, 1) + m.at(0, 2)
    for i in range(1, 3):
        if m.at(i, 0) + m.at(i, 1) + m.at(i, 2) != s0:
            return False
    return True
