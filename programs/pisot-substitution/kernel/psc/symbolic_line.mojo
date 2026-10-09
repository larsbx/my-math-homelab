"""The seed-patch overlap graph of a one-parameter line, for every large q at once.

docs/p1b-symbolic-line-2026-10-07.md. A *line* is a family `sigma_q` on three
letters whose images are `f_a y^(n_a(q)) l_a`, a first letter, a run of the
letter `y` of length affine in `q`, and a last letter. This module computes the
overlap graph reachable from the swap seeds of `sigma_q` **as a function of q**:
vertices are `(a, b, w)` with `w` a vector of integer polynomials in `q`, and
every child is decided for all `q >= q0` at once, with `q0` certified.

Decisions. Every question the closure asks is the sign of an element
`G(q, beta)` of `Q[q][t] / (chi)` at the Perron root `beta = beta(q)`: whether a
child overlap is real (both open-interval conditions), and the integer range of
run positions a child can occupy. A sign is decided by a *parametric
Sturm--Tarski query*: the signed pseudo-remainder sequence of `(chi, chi' G)`
over `Q[q]`, read at `t = 1` and `t = +infinity`. Pseudo-division multiplies by
an even power of a leading coefficient, so every term is a positive multiple of
the classical one wherever those coefficients do not vanish. Each entry of the
sequence is then a polynomial in `q`, and its sign for every `q` above its
largest real root is the sign of its leading coefficient; that root is isolated
exactly (`largest_root_bracket`) and the maximum over all queries is the
threshold `q0`. Under the line's certified PIP property (one root of `chi` in
`(1, infinity)`), the query is the sign of `G(beta)`.

Run positions. A child inside a run sits at an integer offset `m` whose real
range is an open interval of bounded length. The integer endpoints are
**guessed** by exact evaluation at sample values of `q`, fitted as affine
functions of `q`, and then **certified** by two sign queries each. A guess that
fails certification raises: the search only proposes.

What the closure means. If every decision holds for `q >= q0`, then for every
such `q` the exact seed-reachable overlap graph of `sigma_q`
(`psc.overlap_seed_patch`) is the symbolic graph with `q` substituted: the seeds
agree, and each vertex has the same children. A run that meets a decision it
cannot certify, a range that grows with `q`, or the vertex cap, raises; nothing
here returns a partial graph as if it were complete.

Wedges (docs/p1b-boundary-hitting-progress-2026-10-08.md §4b). The same
closure runs over two parameters `a, b >= 0` when the runs are affine in both.
Three decisions change, and only for a wedge, so a line's run is unchanged.
A sign involving `b` is certified on a quadrant `a >= A, b >= B`, by one
coefficient sign after a shift and, if needed, a Polya multiplier. PIP is
certified by `chi(-1), chi(1), chi(2) < 0`, which is equivalent to Pisot when
`|det M| = 2` and involves no discriminant. A sign at beta is read from a
nonvanishing norm `det h(M)` and one exact sample point, which is sound
because beta is continuous on the connected certified region. Signs that
change across the quadrant still raise.
"""

from std.collections import Dict
from finite_exact.rat_q import Q
from finite_linear_algebra.qpoly import degree, evaluate, sign_of
from finite_linear_algebra.scalar import q_int, q_is_zero
from finite_linear_algebra.cauchy_bound import root_bound
from finite_linear_algebra.sturm_sequence import largest_root_bracket, sturm_chain, variation_difference
from psc.param_poly import (
    QX,
    TPoly,
    qx_add,
    qx_affine2,
    qx_const,
    qx_const_term,
    qx_is_const,
    qx_is_zero,
    qx_key,
    qx_mul,
    qx_neg,
    qx_norm,
    qx_of,
    qx_shift,
    qx_sub,
    tp_add,
    tp_at_q,
    tp_at_t,
    tp_coeff,
    tp_const,
    tp_deg,
    tp_deriv,
    tp_has_b,
    tp_key,
    tp_mul,
    tp_neg,
    tp_norm,
    tp_prem,
    tp_scale,
    tp_sub,
    tp_t,
    w_add,
    w_sub,
    w_unit,
    w_zero,
)

comptime SAMPLE_BASE = 200  # sample points for fitting run-position ranges: once and twice this
comptime SYMBOLIC_VERTEX_CAP = 20000
comptime ROOT_STEPS = 400
comptime QUADRANT_CAP = 4096  # largest corner tried by the quadrant sign certificate
comptime NORM_UNDECIDED = 2  # norm_sign could not settle the query
comptime POLYA_CAP = 40  # largest power of (1 + a + b) tried by the Polya certificate


# ---------------------------------------------------------------------------
# Eventual signs of parameter polynomials, with certified thresholds.
#
# A line has one parameter, `a` (the `q` or `n` of the notes); a wedge has two,
# `a` and `b`. The polynomials themselves are `psc.param_poly`.
# ---------------------------------------------------------------------------


def _uniform_sign(p: QX) -> Int:
    """`+1`/`-1` if every coefficient is `>= 0`/`<= 0` and the constant term is
    nonzero, so that `p` has that sign on the whole closed quadrant; else 0."""
    var c = qx_const_term(p)
    var s = sign_of(c)
    if s == 0:
        return 0
    for j in range(len(p)):
        for i in range(len(p[j])):
            if sign_of(p[j][i]) == -s:
                return 0
    return s


def _polya_sign(p: QX) -> Int:
    """`_uniform_sign` of `(1 + a + b)^N p` for the least `N <= POLYA_CAP` that
    has one. The multiplier is positive on the quadrant, so a uniform sign of
    the product is the sign of `p` there (Polya's certificate)."""
    var f = qx_norm(p)
    var s = _uniform_sign(f)
    if s != 0 or sign_of(qx_const_term(f)) == 0:
        return s
    var mult = qx_affine2(1, 1, 1)
    for _ in range(POLYA_CAP):
        f = qx_mul(f, mult)
        s = _uniform_sign(f)
        if s != 0:
            return s
    return 0


struct Eventual(Copyable, Movable):
    """Signs of parameter polynomials on a certified region.

    The region is every integer `a > threshold` with every integer `b >= b_floor`.
    A polynomial in `a` alone is read through its largest real root, which
    raises `threshold` past it (so the sign holds for every `b`). A polynomial
    involving `b` is read by the quadrant certificate: after substituting
    `a -> A + a'`, `b -> B + b'` with `A` the first integer above `threshold`
    and `B = b_floor`, every coefficient has one sign and the constant term is
    nonzero, so that sign holds for all real `a', b' >= 0` (after multiplying
    by a power of `1 + a' + b'` if needed, Polya's certificate); if not, the corner
    is moved out and the region shrinks. Earlier answers stay valid on the
    smaller region. `queries` counts the polynomials read."""

    var threshold: Q
    var b_floor: Int
    var queries: Int

    def __init__(out self):
        self.threshold = Q.zero()
        self.b_floor = 0
        self.queries = 0

    def sign(mut self, p: QX) raises -> Int:
        var g = qx_norm(p)
        self.queries += 1
        if len(g) == 0:
            return 0
        if len(g) > 1:
            return self._quadrant_sign(g)
        var f = g[0].copy()
        if degree(f) >= 1 and not self._no_root_above(f, self.threshold):
            var bracket = largest_root_bracket(f, Q.one(), ROOT_STEPS)
            var above = bracket.hi.copy() if bracket.found else root_bound(f)
            if self.threshold.lt(above):
                self.threshold = above^
        return sign_of(f[len(f) - 1])

    def _quadrant_sign(mut self, g: QX) raises -> Int:
        """Try the current corner, then moving only `b`, only `a`, or both,
        doubling each time: every corner left behind costs boundary lines."""
        var a0 = self.first_integer_above()
        var b0 = self.b_floor
        while a0 <= QUADRANT_CAP and b0 <= QUADRANT_CAP:
            for c in [(a0, b0), (a0, 2 * b0 + 1), (2 * a0 + 1, b0)]:
                var s = _polya_sign(qx_shift(g, c[0], c[1]))
                if s != 0:
                    if self.threshold.lt(q_int(c[0] - 1)):
                        self.threshold = q_int(c[0] - 1)
                    self.b_floor = c[1]
                    return s
            a0 = 2 * a0 + 1
            b0 = 2 * b0 + 1
        raise Error("no quadrant corner certifies the sign of " + qx_key(g))

    def _no_root_above(self, f: List[Q], x: Q) -> Bool:
        """No real root of `f` in `[x, infinity)`: one Sturm count, the common case
        once the threshold has grown past the roots that matter."""
        if q_is_zero(evaluate(f, x)):
            return False
        var chain = sturm_chain(f)
        return variation_difference(chain, x, root_bound(f)) == 0

    def first_integer_above(self) -> Int:
        """The least integer `a0` with `a0 > threshold`."""
        var n = 0
        while not self.threshold.lt(q_int(n)):
            n += 1
        return n


# ---------------------------------------------------------------------------
# Signs at the Perron root, for all large q.
# ---------------------------------------------------------------------------


struct LineField(Copyable, Movable):
    """`chi(q, t)` with a certified single root in `(1, infinity)` for `q > threshold`."""

    var chi: TPoly
    var dchi: TPoly

    def __init__(out self, chi: TPoly):
        self.chi = tp_norm(chi)
        self.dchi = tp_deriv(self.chi)

    def reduce(self, g: TPoly) raises -> TPoly:
        """`g` modulo `chi`, up to a positive factor (an even power of `lc(chi)`)."""
        return tp_prem(g, self.chi)

    def _variations(self, chain: List[TPoly], at_one: Bool, mut ev: Eventual) raises -> Int:
        var previous = 0
        var count = 0
        for i in range(len(chain)):
            var value = tp_at_t(chain[i], Q.one()) if at_one else tp_coeff(chain[i], len(chain[i]) - 1)
            var s = ev.sign(value)
            if s == 0:
                continue
            if previous != 0 and s != previous:
                count += 1
            previous = s
        return count

    def tarski_above_one(self, g: TPoly, mut ev: Eventual) raises -> Int:
        """`sum over roots x of chi in (1, infinity) of sign g(x)`, for every `q > ev.threshold`."""
        var chain = List[TPoly]()
        chain.append(self.chi.copy())
        var second = tp_prem(tp_mul(self.dchi, g), self.chi)
        if tp_deg(second) < 0:
            return 0
        chain.append(second^)
        while True:
            var nxt = tp_neg(tp_prem(chain[len(chain) - 2], chain[len(chain) - 1]))
            if tp_deg(nxt) < 0:
                break
            chain.append(nxt^)
        return self._variations(chain, True, ev) - self._variations(chain, False, ev)

    def sign_at_beta(self, g: TPoly, mut ev: Eventual) raises -> Int:
        if tp_deg(self.reduce(g)) < 0:
            return 0
        return self.tarski_above_one(g, ev)


# ---------------------------------------------------------------------------
# The line.
# ---------------------------------------------------------------------------


struct SymVertex(Copyable, Movable):
    var top: Int
    var bottom: Int
    var w: List[QX]

    def __init__(out self, top: Int, bottom: Int, var w: List[QX]):
        self.top = top
        self.bottom = bottom
        self.w = w^

    def key(self) -> String:
        var out = String(self.top) + "|" + String(self.bottom)
        for i in range(3):
            out += "|"
            out += qx_key(self.w[i])
        return out^

    def is_zero_offset(self) -> Bool:
        for i in range(3):
            if not qx_is_zero(self.w[i]):
                return False
        return True



def _mat_zero() -> List[List[QX]]:
    var out = List[List[QX]]()
    for _ in range(3):
        var row = List[QX]()
        for _ in range(3):
            row.append(QX())
        out.append(row^)
    return out^


def _mat_mul(x: List[List[QX]], y: List[List[QX]]) -> List[List[QX]]:
    var out = _mat_zero()
    for i in range(3):
        for j in range(3):
            for k in range(3):
                out[i][j] = qx_add(out[i][j], qx_mul(x[i][k], y[k][j]))
    return out^


def _mat_det(x: List[List[QX]]) -> QX:
    return qx_sub(
        qx_add(
            qx_mul(x[0][0], qx_sub(qx_mul(x[1][1], x[2][2]), qx_mul(x[1][2], x[2][1]))),
            qx_mul(x[0][2], qx_sub(qx_mul(x[1][0], x[2][1]), qx_mul(x[1][1], x[2][0]))),
        ),
        qx_mul(x[0][1], qx_sub(qx_mul(x[1][0], x[2][2]), qx_mul(x[1][2], x[2][0]))),
    )


struct Line(Copyable, Movable):
    """Images `first[a] y^(run[a]) last[a]`; `run[a]` an affine polynomial in `q`."""

    var first: List[Int]
    var last: List[Int]
    var run: List[QX]
    var y: Int
    var m: List[List[QX]]
    var field: LineField
    var ell: List[TPoly]
    var by_norm: Bool  # decide signs at beta by norm and PIP by chi(-1), chi(1), chi(2), as a wedge does

    def __init__(out self, first: List[Int], last: List[Int], run: List[QX], y: Int, by_norm: Bool = False) raises:
        self.first = first.copy()
        self.last = last.copy()
        self.run = run.copy()
        self.y = y
        self.by_norm = by_norm
        self.m = List[List[QX]]()
        for _ in range(3):
            var row = List[QX]()
            for _ in range(3):
                row.append(QX())
            self.m.append(row^)
        for b in range(3):
            self.m[first[b]][b] = qx_add(self.m[first[b]][b], qx_const(1))
            self.m[last[b]][b] = qx_add(self.m[last[b]][b], qx_const(1))
            self.m[y][b] = qx_add(self.m[y][b], run[b])
        # chi(t) = det(t I - M)
        var a = List[List[TPoly]]()
        for i in range(3):
            var row = List[TPoly]()
            for j in range(3):
                var e = tp_neg(tp_const(self.m[i][j]))
                if i == j:
                    e = tp_add(e, tp_t())
                row.append(e^)
            a.append(row^)
        var det = tp_sub(
            tp_add(
                tp_mul(a[0][0], tp_sub(tp_mul(a[1][1], a[2][2]), tp_mul(a[1][2], a[2][1]))),
                tp_mul(a[0][2], tp_sub(tp_mul(a[1][0], a[2][1]), tp_mul(a[1][1], a[2][0]))),
            ),
            tp_mul(a[0][1], tp_sub(tp_mul(a[1][0], a[2][2]), tp_mul(a[1][2], a[2][0]))),
        )
        self.field = LineField(det)
        # left null vector of (M - t I): orthogonal to its columns, a cross product of two of them
        var col = List[List[TPoly]]()
        for j in range(3):
            var c = List[TPoly]()
            for i in range(3):
                c.append(tp_neg(a[i][j]))
            col.append(c^)
        self.ell = List[TPoly]()
        self.ell.append(tp_sub(tp_mul(col[0][1], col[1][2]), tp_mul(col[0][2], col[1][1])))
        self.ell.append(tp_sub(tp_mul(col[0][2], col[1][0]), tp_mul(col[0][0], col[1][2])))
        self.ell.append(tp_sub(tp_mul(col[0][0], col[1][1]), tp_mul(col[0][1], col[1][0])))

    def mw(self, w: List[QX]) -> List[QX]:
        var out = List[QX]()
        for i in range(3):
            var s = QX()
            for j in range(3):
                s = qx_add(s, qx_mul(self.m[i][j], w[j]))
            out.append(s^)
        return out^

    def has_b(self) -> Bool:
        """Whether the family has a second parameter (a wedge, not a line)."""
        for i in range(3):
            if len(qx_norm(self.run[i])) > 1:
                return True
        return False

    def norm_mode(self) -> Bool:
        """Whether signs at beta are read by norm (`norm_sign`): always for a
        wedge, and for a line built with `by_norm`."""
        return self.by_norm or self.has_b()

    def norm(self, g: TPoly) -> QX:
        """`det g(M)`, the product of `g` over the three roots of `chi`."""
        var p = _mat_zero()
        var top = tp_norm(g)
        for index in range(len(top)):
            p = _mat_mul(p, self.m)
            var c = top[len(top) - 1 - index].copy()
            for i in range(3):
                p[i][i] = qx_add(p[i][i], c)
        return _mat_det(p)

    def t_of(self, w: List[QX]) -> TPoly:
        var s = TPoly()
        for i in range(3):
            s = tp_add(s, tp_scale(self.ell[i], w[i]))
        return s^


struct LineCertificate(Copyable, Movable):
    """The PIP property of the line for every `q > threshold`, and the sign of the tile lengths."""

    var holds: Bool
    var ell_sign: Int

    def __init__(out self, holds: Bool, ell_sign: Int):
        self.holds = holds
        self.ell_sign = ell_sign


def _sturm_chain(field: LineField) raises -> List[TPoly]:
    var chain = List[TPoly]()
    chain.append(field.chi.copy())
    chain.append(field.dchi.copy())
    while True:
        var nxt = tp_neg(tp_prem(chain[len(chain) - 2], chain[len(chain) - 1]))
        if tp_deg(nxt) < 0:
            break
        chain.append(nxt^)
    return chain^


def _variations_at(chain: List[TPoly], x: Q, mut ev: Eventual) raises -> Int:
    var previous = 0
    var count = 0
    for i in range(len(chain)):
        var s = ev.sign(tp_at_t(chain[i], x))
        if s == 0:
            continue
        if previous != 0 and s != previous:
            count += 1
        previous = s
    return count


def _variations_at_infinity(chain: List[TPoly], positive: Bool, mut ev: Eventual) raises -> Int:
    """Sign changes at `t = +infinity` (leading coefficients) or `-infinity`."""
    var previous = 0
    var count = 0
    for i in range(len(chain)):
        var d = tp_deg(chain[i])
        var s = ev.sign(tp_coeff(chain[i], d))
        if not positive and d % 2 == 1:
            s = -s
        if s == 0:
            continue
        if previous != 0 and s != previous:
            count += 1
        previous = s
    return count


def roots_above(field: LineField, a: Q, mut ev: Eventual) raises -> Int:
    """Sturm count of the real roots of `chi` in `(a, infinity)`, for `q > threshold`."""
    var chain = _sturm_chain(field)
    return _variations_at(chain, a, ev) - _variations_at_infinity(chain, True, ev)


def roots_below(field: LineField, a: Q, mut ev: Eventual) raises -> Int:
    """Sturm count of the real roots of `chi` in `(-infinity, a)`, for `q > threshold`."""
    var chain = _sturm_chain(field)
    return _variations_at_infinity(chain, False, ev) - _variations_at(chain, a, ev)


def certify_line(line: Line, mut ev: Eventual) raises -> LineCertificate:
    """PIP for every `q > threshold`: the support of `M` is eventually fixed and
    primitive; `chi` has no rational root (the determinant must be a constant,
    whose divisors are the only candidates); exactly one root lies in
    `(1, infinity)`, `chi(1) != 0`; and the other two lie in the open unit disc
    (two real roots in `(-1, 1)`, or a complex pair with `beta > |det M|`, since
    `|beta_2|^2 = |det M| / beta`). Also fixes the sign that makes the tile
    lengths positive at `beta`."""
    var chi = line.field.chi.copy()
    var det = qx_neg(tp_coeff(chi, 0))  # chi(0) = -det M
    if not qx_is_const(det):
        raise Error("the line's determinant is not constant")
    if qx_is_zero(det):
        return LineCertificate(False, 0)
    # support of M: every entry eventually positive or identically zero
    var support = List[Int]()
    for i in range(3):
        for j in range(3):
            var s = ev.sign(line.m[i][j])
            if s < 0:
                return LineCertificate(False, 0)
            support.append(1 if s > 0 else 0)
    if not primitive_support(support):
        return LineCertificate(False, 0)
    # rational roots divide the (constant) determinant
    var d = qx_const_term(det)
    var dn = 1
    while q_int(dn).le(d) or q_int(dn).le(d.neg()):
        if d.div(q_int(dn)).mul(q_int(dn)).eq(d):
            for sgn in range(2):
                var r = q_int(dn) if sgn == 0 else q_int(-dn)
                if ev.sign(tp_at_t(chi, r)) == 0:
                    return LineCertificate(False, 0)
        dn += 1
        if dn > 1000:
            raise Error("determinant too large for the rational-root screen")
    if ev.sign(tp_at_t(chi, Q.one())) == 0:
        return LineCertificate(False, 0)
    if roots_above(line.field, Q.one(), ev) != 1:
        return LineCertificate(False, 0)
    var inside = roots_above(line.field, Q(-1, 1), ev) - roots_above(line.field, Q.one(), ev)
    if inside != 2:
        if inside != 0:
            return LineCertificate(False, 0)
        var dd = d.copy() if Q.zero().lt(d) else d.neg()
        var over = tp_sub(tp_t(), tp_const(qx_of(dd)))
        if line.field.sign_at_beta(over, ev) <= 0:
            return LineCertificate(False, 0)
        # and the two non-Perron roots are not real outside the disc: no root below -1
        if roots_below(line.field, Q(-1, 1), ev) != 0:
            return LineCertificate(False, 0)
    var s = line.field.sign_at_beta(line.ell[line.y], ev)
    if s == 0:
        return LineCertificate(False, 0)
    for i in range(3):
        if line.field.sign_at_beta(line.ell[i], ev) != s:
            return LineCertificate(False, 0)
    return LineCertificate(True, s)


def primitive_support(s: List[Int]) -> Bool:
    """Some power of the 0/1 support matrix is positive (Wielandt: power 5 suffices)."""
    var p = s.copy()
    for _ in range(5):
        var all_pos = True
        for k in range(9):
            if p[k] == 0:
                all_pos = False
        if all_pos:
            return True
        var nxt = List[Int](length=9, fill=0)
        for i in range(3):
            for j in range(3):
                var v = 0
                for k in range(3):
                    if p[i * 3 + k] != 0 and s[k * 3 + j] != 0:
                        v = 1
                nxt[i * 3 + j] = v
        p = nxt^
    for k in range(9):
        if p[k] == 0:
            return False
    return True


def norm_sign(line: Line, h: TPoly, mut ev: Eventual) raises -> Int:
    """Sign of `h(beta)` on a wedge, or `NORM_UNDECIDED`.

    On the certified region (real, connected) beta is the unique root of `chi`
    above 1 and depends continuously on the parameters (`certify_wedge_pisot`),
    so `h(beta)` keeps one sign wherever it does not vanish. If the norm
    `det h(M)`, the product of `h` over the roots, has a certified nonzero sign
    on the region, `h(beta)` never vanishes there, and its sign is read exactly
    at one integer point of the region."""
    if tp_deg(line.field.reduce(h)) < 0:
        return 0
    var n = line.norm(h)
    var s: Int
    try:
        s = ev.sign(n)
    except:
        return NORM_UNDECIDED
    if s == 0:
        return NORM_UNDECIDED
    var a = ev.first_integer_above()
    var b = ev.b_floor
    var at = LineField(tp_at_q(line.field.chi, a, b))
    var concrete = Eventual()
    var out = at.sign_at_beta(tp_at_q(h, a, b), concrete)
    if out == 0:
        raise Error("a nonvanishing norm met h(beta) = 0 at a sample point")
    return out


def certify_wedge_pisot(line: Line, mut ev: Eventual) raises -> LineCertificate:
    """PIP on a two-parameter family with `|det M| = 2`, with no discriminant.

    For a real monic cubic with `|det M| = 2`: one root in `(2, infinity)` and
    the other two in the open unit disc  <=>  `chi(-1) < 0`, `chi(1) < 0` and
    `chi(2) < 0`. (Given a root `beta > 2`, the other two are the roots of
    `x^2 + u x + v = chi(x) / (x - beta)` with `|v| = 2 / beta < 1`, and Jury's
    test asks `chi(1) / (1 - beta) > 0` and `chi(-1) / (-1 - beta) > 0`;
    conversely `beta > 2` because the other two have product of modulus
    below 1.) It holds pointwise for real parameters, so on the region beta
    is the unique root above 1 and continuous. With `chi(-2) != 0` there is no
    rational root (they divide 2), so `chi` is irreducible. The support of `M`
    must be eventually fixed and primitive, and the tile lengths must have one
    sign at beta (read by `norm_sign`)."""
    var det = qx_neg(tp_coeff(line.field.chi, 0))
    if not qx_is_const(det):
        raise Error("the wedge's determinant is not constant")
    var d = qx_const_term(det)
    if not (d.eq(q_int(2)) or d.eq(q_int(-2))):
        raise Error("the wedge certificate needs |det M| = 2")
    var support = List[Int]()
    for i in range(3):
        for j in range(3):
            var s = ev.sign(line.m[i][j])
            if s < 0:
                return LineCertificate(False, 0)
            support.append(1 if s > 0 else 0)
    if not primitive_support(support):
        return LineCertificate(False, 0)
    for x in [-1, 1, 2]:
        if ev.sign(tp_at_t(line.field.chi, q_int(x))) >= 0:
            return LineCertificate(False, 0)
    if ev.sign(tp_at_t(line.field.chi, q_int(-2))) == 0:
        return LineCertificate(False, 0)
    var s = norm_sign(line, line.ell[line.y], ev)
    if s == 0 or s == NORM_UNDECIDED:
        return LineCertificate(False, 0)
    for i in range(3):
        if norm_sign(line, line.ell[i], ev) != s:
            return LineCertificate(False, 0)
    return LineCertificate(True, s)


struct SymbolicLineGraph(Copyable, Movable):
    var vertices: List[SymVertex]
    var adj: List[List[Int]]
    var threshold: Q
    var b_floor: Int
    var queries: Int
    var pip: Bool

    def __init__(out self):
        self.vertices = List[SymVertex]()
        self.adj = List[List[Int]]()
        self.threshold = Q.zero()
        self.b_floor = 0
        self.queries = 0
        self.pip = False

    def size(self) -> Int:
        return len(self.vertices)


struct _Closure:
    var line: Line
    var sign: Int  # +1 or -1: the orientation that makes ell positive at beta
    var ev: Eventual
    var index: Dict[String, Int]
    var vertices: List[SymVertex]
    var adj: List[List[Int]]
    var queue: List[Int]
    var memo: Dict[String, Int]
    var wedge: Bool

    def __init__(out self, var line: Line, sign: Int, var ev: Eventual):
        self.wedge = line.norm_mode()
        self.line = line^
        self.sign = sign
        self.ev = ev^
        self.index = Dict[String, Int]()
        self.vertices = List[SymVertex]()
        self.adj = List[List[Int]]()
        self.queue = List[Int]()
        self.memo = Dict[String, Int]()

    def positive(mut self, g: TPoly) raises -> Int:
        """Sign of `g(beta)` with the tile lengths oriented positive. A repeated
        query returns its first answer, whose region is already recorded. A
        wedge tries the norm certificate first (`_norm_sign`); a line, and a
        wedge query the norm cannot settle, use the Sturm--Tarski query."""
        var h = tp_scale(g, qx_const(self.sign))
        var k = tp_key(h)
        if k in self.memo:
            return self.memo[k]
        var s = norm_sign(self.line, h, self.ev) if self.wedge else NORM_UNDECIDED
        if s == NORM_UNDECIDED:
            s = self.line.field.sign_at_beta(h, self.ev)
        self.memo[k] = s
        return s

    def real(mut self, a: Int, b: Int, w: List[QX]) raises -> Bool:
        """`-ell_b < <ell, w> < ell_a`."""
        var t = self.line.t_of(w)
        if self.positive(tp_add(self.line.ell[b], t)) <= 0:
            return False
        return self.positive(tp_sub(self.line.ell[a], t)) > 0

    def intern(mut self, var v: SymVertex) raises -> Int:
        var k = v.key()
        if k in self.index:
            return self.index[k]
        if len(self.vertices) >= SYMBOLIC_VERTEX_CAP:
            raise Error("symbolic line closure exceeded its vertex cap")
        var i = len(self.vertices)
        self.index[k] = i
        self.vertices.append(v^)
        self.adj.append(List[Int]())
        self.queue.append(i)
        return i

    def prefix(self, a: Int, seg: Int) -> List[QX]:
        """Parikh vector of `sigma(a)` before segment `seg` (0 first letter, 1 run, 2 last letter)."""
        var v = w_zero()
        if seg >= 1:
            v = w_add(v, w_unit(self.line.first[a], qx_const(1)))
        if seg >= 2:
            v = w_add(v, w_unit(self.line.y, self.line.run[a]))
        return v^

    def has_run(mut self, a: Int) raises -> Bool:
        var s = self.ev.sign(self.line.run[a])
        if s < 0:
            raise Error("a run length is eventually negative")
        return s > 0

    def letter(self, a: Int, seg: Int) -> Int:
        if seg == 0:
            return self.line.first[a]
        if seg == 1:
            return self.line.y
        return self.line.last[a]

    def least_m(mut self, h0: TPoly, h1: TPoly, strict: Bool) raises -> QX:
        """The least integer `m(a, b)` with `h0 + m h1 > 0` (`>= 0` if not `strict`)
        at beta (`h1 > 0`), as an affine polynomial in the parameters, fitted at
        sample points and certified. A line's queries never involve `b`, so
        its fit reads only the two `a` samples."""
        var v1 = _least_at(self.line, self.sign, h0, h1, SAMPLE_BASE, SAMPLE_BASE, strict)
        var v2 = _least_at(self.line, self.sign, h0, h1, 2 * SAMPLE_BASE, SAMPLE_BASE, strict)
        var slope = (v2 - v1) // SAMPLE_BASE
        if v2 - v1 != slope * SAMPLE_BASE:
            raise Error("a run-position bound is not affine in q at the samples")
        var slope_b = 0
        if tp_has_b(h0) or tp_has_b(h1) or tp_has_b(self.line.field.chi):
            var v3 = _least_at(self.line, self.sign, h0, h1, SAMPLE_BASE, 2 * SAMPLE_BASE, strict)
            slope_b = (v3 - v1) // SAMPLE_BASE
            if v3 - v1 != slope_b * SAMPLE_BASE:
                raise Error("a run-position bound is not affine in b at the samples")
        var c0 = v1 - (slope + slope_b) * SAMPLE_BASE
        var mu = qx_affine2(c0, slope, slope_b)
        var floor_sign = 1 if strict else 0
        if self.positive(tp_add(h0, tp_scale(h1, mu))) < floor_sign:
            raise Error("a fitted run-position bound fails certification (low side)")
        if self.positive(tp_add(h0, tp_scale(h1, qx_sub(mu, qx_const(1))))) >= floor_sign:
            raise Error("a fitted run-position bound fails certification (high side)")
        return mu^

    def expand(mut self, i: Int) raises:
        var v = self.vertices[i].copy()
        if v.top == v.bottom and v.is_zero_offset():
            return
        var mw = self.line.mw(v.w)
        var ell = self.line.ell.copy()
        var y = self.line.y
        for sa in range(3):
            if sa == 1 and not self.has_run(v.top):
                continue
            for sb in range(3):
                if sb == 1 and not self.has_run(v.bottom):
                    continue
                var base = w_sub(w_add(mw, self.prefix(v.bottom, sb)), self.prefix(v.top, sa))
                var a2 = self.letter(v.top, sa)
                var b2 = self.letter(v.bottom, sb)
                if sa != 1 and sb != 1:
                    if self.real(a2, b2, base):
                        var c = self.intern(SymVertex(a2, b2, base^))
                        self.adj[i].append(c)
                    continue
                # offset base + m e_y; real iff ell_b2 + t + m ell_y > 0 and ell_a2 - t - m ell_y > 0
                var t = self.line.t_of(base)
                var lo = self.least_m(tp_add(ell[b2], t), ell[y], True)
                var hi_plus = self.least_m(tp_sub(t, ell[a2]), ell[y], False)  # least m with t + m ell_y >= ell_a2
                var hi = qx_sub(hi_plus, qx_const(1))
                # run positions: m = k_b - k_a with k in [0, run - 1]
                var rlo = qx_neg(qx_sub(self.line.run[v.top], qx_const(1))) if sa == 1 else QX()
                var rhi = qx_sub(self.line.run[v.bottom], qx_const(1)) if sb == 1 else QX()
                var low = lo.copy() if self.ev.sign(qx_sub(lo, rlo)) >= 0 else rlo.copy()
                var high = hi.copy() if self.ev.sign(qx_sub(rhi, hi)) >= 0 else rhi.copy()
                var gap = qx_sub(high, low)
                if not qx_is_const(gap):
                    if self.ev.sign(gap) < 0:
                        continue
                    raise Error("a run-position range grows with q")
                var width = 0
                var g0 = qx_const_term(gap)
                if g0.lt(Q.zero()):
                    continue
                while q_int(width + 1).le(g0):
                    width += 1
                for d in range(width + 1):
                    var mval = qx_add(low, qx_const(d))
                    var child = w_add(base, w_unit(y, mval))
                    var c = self.intern(SymVertex(a2, b2, child^))
                    self.adj[i].append(c)

    def seeds(mut self) raises:
        for a in range(3):
            for b in range(a + 1, 3):
                var tops = List[Int]([a, b])
                var bots = List[Int]([b, a])
                var top_pos = List[List[QX]]()
                top_pos.append(w_zero())
                top_pos.append(w_unit(a, qx_const(1)))
                var bot_pos = List[List[QX]]()
                bot_pos.append(w_zero())
                bot_pos.append(w_unit(b, qx_const(1)))
                for i in range(2):
                    for j in range(2):
                        var w = w_sub(bot_pos[j], top_pos[i])
                        if self.real(tops[i], bots[j], w):
                            _ = self.intern(SymVertex(tops[i], bots[j], w^))


def _h_pos(m: Int, field: LineField, g0: TPoly, g1: TPoly, floor_sign: Int, mut ev: Eventual) raises -> Bool:
    return field.sign_at_beta(tp_add(g0, tp_scale(g1, qx_const(m))), ev) >= floor_sign


def _least_at(line: Line, sign: Int, h0: TPoly, h1: TPoly, q: Int, qb: Int, strict: Bool) raises -> Int:
    """Exact least integer `m` with `h0 + m h1 > 0` (`>= 0` if not `strict`) at
    `beta` of the member at parameters `(q, qb)`."""
    var field = LineField(tp_at_q(line.field.chi, q, qb))
    return least_integer_at(field, tp_scale(tp_at_q(h0, q, qb), qx_const(sign)), tp_scale(tp_at_q(h1, q, qb), qx_const(sign)), strict)


def least_integer_at(field: LineField, g0: TPoly, g1: TPoly, strict: Bool) raises -> Int:
    """Exact least integer `m` with `g0 + m g1 > 0` (`>= 0` if not `strict`) at the
    root of `field.chi` in `(1, infinity)`, all coefficients constant."""
    var ev = Eventual()
    if field.sign_at_beta(g1, ev) <= 0:
        raise Error("the run-position step is not positive")
    var m = 0
    var step = 1

    # find an interval [lo, hi] with h(lo) <= 0 < h(hi)
    var fs = 1 if strict else 0

    if _h_pos(m, field, g0, g1, fs, ev):
        var hi = m
        var lo = m - step
        while _h_pos(lo, field, g0, g1, fs, ev):
            hi = lo
            step *= 2
            lo = hi - step
        while hi - lo > 1:
            var mid = (lo + hi) // 2
            if _h_pos(mid, field, g0, g1, fs, ev):
                hi = mid
            else:
                lo = mid
        return hi
    var lo = m
    var hi = m + step
    while not _h_pos(hi, field, g0, g1, fs, ev):
        lo = hi
        step *= 2
        hi = lo + step
    while hi - lo > 1:
        var mid = (lo + hi) // 2
        if _h_pos(mid, field, g0, g1, fs, ev):
            hi = mid
        else:
            lo = mid
    return hi


def symbolic_line_graph(var line: Line) raises -> SymbolicLineGraph:
    """The swap-seed overlap graph of the line for all `q > threshold`; see the module docstring."""
    var ev = Eventual()
    var cert = certify_wedge_pisot(line, ev) if line.norm_mode() else certify_line(line, ev)
    var out = SymbolicLineGraph()
    if not cert.holds:
        out.pip = False
        out.threshold = ev.threshold.copy()
        out.b_floor = ev.b_floor
        return out^
    var cl = _Closure(line^, cert.ell_sign, ev^)
    cl.seeds()
    var done = 0
    while done < len(cl.queue):
        var i = cl.queue[done]
        done += 1
        cl.expand(i)
    out.pip = True
    out.threshold = cl.ev.threshold.copy()
    out.b_floor = cl.ev.b_floor
    out.queries = cl.ev.queries
    out.vertices = cl.vertices.copy()
    out.adj = cl.adj.copy()
    return out^


def offset_zero_reachable(g: SymbolicLineGraph) -> List[Bool]:
    """Whether each vertex has an offset-zero descendant (itself included)."""
    var zero = List[Bool]()
    for i in range(g.size()):
        zero.append(g.vertices[i].is_zero_offset())
    return zero_descendants(g.adj, zero)


def zero_descendants(adj: List[List[Int]], zero: List[Bool]) -> List[Bool]:
    """Whether each vertex reaches a vertex flagged in `zero` (itself included)."""
    var n = len(adj)
    var good = List[Bool](length=n, fill=False)
    var rev = List[List[Int]]()
    for _ in range(n):
        rev.append(List[Int]())
    for i in range(n):
        for j in range(len(adj[i])):
            rev[adj[i][j]].append(i)
    var stack = List[Int]()
    for i in range(n):
        if zero[i]:
            good[i] = True
            stack.append(i)
    while len(stack) > 0:
        var v = stack.pop()
        for k in range(len(rev[v])):
            var u = rev[v][k]
            if not good[u]:
                good[u] = True
                stack.append(u)
    return good^
