"""The seed-patch overlap graph of a two-parameter cone, for every member at once.

docs/p1b-symbolic-cone-2026-10-08.md. A *cone* is a family `sigma_s`,
`s = (s1, s2)` in a shifted orthant `{s1 >= n1, s2 >= n2}`, on three letters
whose images are `f_a y^(n_a(s)) l_a`: a first letter, a run of `y` whose length
is affine in `s`, and a last letter. A line (`psc.symbolic_line`) is the case
where one coordinate does not occur. This module computes the overlap graph
reachable from the swap seeds as a function of `s`: vertices `(a, b, w)` with
`w` a vector of polynomials in `Q[s1, s2]`, each child decided on the whole
region at once. Those polynomials are the line engine's `psc.param_poly`
`QX`, with `s1` its `b` and `s2` its `a`: `s1 + 2 s2` is
`qx_affine2(0, 2, 1)`, and a value at `s` is `qx_at(p, s2, s1)`.

Signs on the region. A polynomial `f(s)` is certified positive on the region
when `f(n1 + u, n2 + v)` has nonnegative coefficients and positive constant
term, possibly after multiplication by a power of `1 + u + v` (Polya's
multiplier; `1 + u` or `1 + v` when only one coordinate occurs). The sign is
guessed at one point of the region and then certified; an uncertified sign is
**not** a verdict and raises.

Signs at beta. In two parameters the Sturm--Tarski sequence of the line engine
has entries whose signs need not be constant on the region, so this module does
not use it. Instead the Perron root is **bracketed**: the caller supplies
rational functions `L(s) < U(s)` and the module certifies `chi(L) < 0 < chi(U)`
with `L > |det M|`. Together with the Jury conditions on the quotient
`chi(t) / (t - beta)` this proves that the family is PIP on the region and that
`beta` is the root of `chi` in `(L, U)`; where Rouche's dominant-coefficient
condition is certified on the region it replaces the Jury reads (`rouche_disc`).
An element `G` of `Q[s][t] / (chi)`,
reduced to degree at most 2, then has the sign at `beta` of `G(L)` and `G(U)`
when those agree and `G` is monotone on `[L, U]` (its derivative has one sign at
both ends) or bends away from zero (`sign(lc G) != sign G(L)`). Several brackets
may be supplied, tightest last; an undecided sign raises.

Run positions are fitted at three sample points as affine functions of `s` and
certified by sign queries, exactly as on a line; the concrete samples are
decided by the line engine's exact Sturm queries with constant coefficients.

What the closure means. If the run finishes, then for every integer point of
the region the exact seed-reachable overlap graph of `sigma_s`
(`psc.overlap_seed_patch`) is the symbolic graph with `s` substituted; the proof
is Lemma S of docs/p1b-symbolic-line-2026-10-07.md with the region in place of
`{q > q0}`.
"""

from std.collections import Dict
from finite_exact.rat_q import Q
from finite_linear_algebra.qpoly import sign_of
from finite_linear_algebra.scalar import q_int
from psc.param_poly import (
    QX,
    TPoly,
    qx_add,
    qx_affine2,
    qx_at,
    qx_const,
    qx_const_term,
    qx_deg,
    qx_key,
    qx_mul,
    qx_neg,
    qx_norm,
    qx_scale,
    qx_shift,
    qx_sub,
    tp_add,
    tp_at_q,
    tp_const,
    tp_deriv,
    tp_homog_at,
    tp_key,
    tp_mod_monic,
    tp_mul,
    tp_neg,
    tp_norm,
    tp_scale,
    tp_sub,
    tp_t,
    w_add,
    w_sub,
    w_unit,
    w_zero,
)
from psc.symbolic_line import LineField, least_integer_at, primitive_support, zero_descendants

comptime CONE_SAMPLE = 200
comptime CONE_VERTEX_CAP = 20000
comptime POLYA_MAX = 24


def _uses(p: QX) -> List[Bool]:
    """Which coordinates occur in `p`."""
    var f = qx_norm(p)
    var out = List[Bool](length=2, fill=False)
    if len(f) > 1:
        out[0] = True
    for i in range(len(f)):
        if len(f[i]) > 1:
            out[1] = True
    return out^


def _positive_coefficients(p: QX) -> Bool:
    """Every coefficient nonnegative and the constant term positive."""
    var f = qx_norm(p)
    if len(f) == 0 or len(f[0]) == 0 or not Q.zero().lt(f[0][0]):
        return False
    for i in range(len(f)):
        for j in range(len(f[i])):
            if f[i][j].lt(Q.zero()):
                return False
    return True


# ---------------------------------------------------------------------------
# Signs on the region.
# ---------------------------------------------------------------------------


struct Region(Copyable, Movable):
    """The integer points `s1 >= n1`, `s2 >= n2` (all of them, or a line of them
    when one coordinate does not occur)."""

    var n1: Int
    var n2: Int
    var queries: Int
    var polya: Int  # the largest Polya exponent a certificate used
    var memo: Dict[String, Int]

    def __init__(out self, n1: Int, n2: Int):
        self.n1 = n1
        self.n2 = n2
        self.queries = 0
        self.polya = 0
        self.memo = Dict[String, Int]()

    def positive(mut self, p: QX) -> Bool:
        """`p > 0` at every real point of the region, certified."""
        var h = qx_shift(p, self.n2, self.n1)
        var uses = _uses(h)
        var lift = qx_affine2(1, 1 if uses[1] else 0, 1 if uses[0] else 0)
        for k in range(POLYA_MAX + 1):
            if _positive_coefficients(h):
                if k > self.polya:
                    self.polya = k
                return True
            h = qx_mul(h, lift)
        return False

    def try_sign(mut self, p: QX) -> Int:
        """The constant sign of `p` on the region, or 2 when none is certified."""
        var f = qx_norm(p)
        if len(f) == 0:
            return 0
        var k = qx_key(f)
        var hit = self.memo.get(k)
        if hit:
            return hit.value()
        self.queries += 1
        var s = sign_of(qx_at(f, self.n2 + 13, self.n1 + 7))
        if s == 0:
            s = sign_of(qx_at(f, self.n2 + 5, self.n1 + 11))
        var out = 2
        if s != 0 and self.positive(f.copy() if s > 0 else qx_neg(f)):
            out = s
        self.memo[k] = out
        return out

    def sign(mut self, p: QX) raises -> Int:
        var s = self.try_sign(p)
        if s == 2:
            raise Error("a sign is not certified on the region (", self.n1, ", ", self.n2, "): ", qx_key(p))
        return s


# ---------------------------------------------------------------------------
# Rational functions and brackets of the Perron root.
# ---------------------------------------------------------------------------


struct Frac2(Copyable, Movable):
    """`num / den`; `den` is certified positive on the region before use."""

    var num: QX
    var den: QX

    def __init__(out self, var num: QX, var den: QX):
        self.num = num^
        self.den = den^


def r2_const(p: QX) -> Frac2:
    return Frac2(p.copy(), qx_const(1))


def r2_add(a: Frac2, b: Frac2) -> Frac2:
    return Frac2(qx_add(qx_mul(a.num, b.den), qx_mul(b.num, a.den)), qx_mul(a.den, b.den))


def r2_sub(a: Frac2, b: Frac2) -> Frac2:
    return Frac2(qx_sub(qx_mul(a.num, b.den), qx_mul(b.num, a.den)), qx_mul(a.den, b.den))


def r2_mul(a: Frac2, b: Frac2) -> Frac2:
    return Frac2(qx_mul(a.num, b.num), qx_mul(a.den, b.den))


def r2_div(a: Frac2, b: Frac2) -> Frac2:
    return Frac2(qx_mul(a.num, b.den), qx_mul(a.den, b.num))


struct Bracket(Copyable, Movable):
    var lo: Frac2
    var hi: Frac2

    def __init__(out self, var lo: Frac2, var hi: Frac2):
        self.lo = lo^
        self.hi = hi^


# ---------------------------------------------------------------------------
# The cone.
# ---------------------------------------------------------------------------


struct ConeVertex(Copyable, Movable):
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
            out += "|" + qx_key(self.w[i])
        return out^

    def is_zero_offset(self) -> Bool:
        for i in range(3):
            if len(qx_norm(self.w[i])) > 0:
                return False
        return True


struct Cone(Copyable, Movable):
    """Images `first[a] y^(run[a]) last[a]`, `run[a]` affine in `s`, with brackets of `beta`."""

    var first: List[Int]
    var last: List[Int]
    var run: List[QX]
    var y: Int
    var m: List[List[QX]]
    var chi: TPoly
    var ell: List[TPoly]
    var brackets: List[Bracket]

    def __init__(out self, first: List[Int], last: List[Int], run: List[QX], y: Int, var brackets: List[Bracket]) raises:
        self.first = first.copy()
        self.last = last.copy()
        self.run = run.copy()
        self.y = y
        self.brackets = brackets^
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
        var a = List[List[TPoly]]()  # t I - M
        for i in range(3):
            var row = List[TPoly]()
            for j in range(3):
                var e = tp_neg(tp_const(self.m[i][j]))
                if i == j:
                    e = tp_add(e, tp_t())
                row.append(e^)
            a.append(row^)
        self.chi = tp_sub(
            tp_add(
                tp_mul(a[0][0], tp_sub(tp_mul(a[1][1], a[2][2]), tp_mul(a[1][2], a[2][1]))),
                tp_mul(a[0][2], tp_sub(tp_mul(a[1][0], a[2][1]), tp_mul(a[1][1], a[2][0]))),
            ),
            tp_mul(a[0][1], tp_sub(tp_mul(a[1][0], a[2][2]), tp_mul(a[1][2], a[2][0]))),
        )
        # left null vector of M - t I: the cross product of its first two columns
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

    def t_of(self, w: List[QX]) -> TPoly:
        var s = TPoly()
        for i in range(3):
            s = tp_add(s, tp_scale(self.ell[i], w[i]))
        return s^

    def sign_at_beta(self, g: TPoly, mut region: Region) raises -> Int:
        """The sign of `g(beta)` on the region, decided on a bracket; raises when undecided."""
        var r = tp_mod_monic(g, self.chi)
        if len(r) == 0:
            return 0
        if len(r) == 1:
            return region.sign(r[0])
        var dr = tp_deriv(r)
        for i in range(len(self.brackets)):
            ref br = self.brackets[i]
            var sl = region.try_sign(tp_homog_at(r, br.lo.num, br.lo.den, 2))
            if sl != 1 and sl != -1:
                continue
            if region.try_sign(tp_homog_at(r, br.hi.num, br.hi.den, 2)) != sl:
                continue
            if len(r) == 2:
                return sl
            var lead = region.try_sign(r[2])
            if (lead == 1 or lead == -1) and lead != sl:
                return sl  # bends away from zero: the minimum of |g| is at an end
            var dl = region.try_sign(tp_homog_at(dr, br.lo.num, br.lo.den, 1))
            if (dl == 1 or dl == -1) and region.try_sign(tp_homog_at(dr, br.hi.num, br.hi.den, 1)) == dl:
                return sl  # monotone on the bracket
        raise Error("a sign at beta is not decided on any bracket: ", tp_key(r))


struct ConeCertificate(Copyable, Movable):
    var holds: Bool
    var ell_sign: Int
    var reason: String

    def __init__(out self, holds: Bool, ell_sign: Int, reason: String):
        self.holds = holds
        self.ell_sign = ell_sign
        self.reason = reason


def certify_cone(cone: Cone, mut region: Region) raises -> ConeCertificate:
    """PIP at every integer point of the region, and the root in each bracket is beta.

    Support fixed and primitive; `det M` a nonzero constant whose divisors are not
    roots of `chi`; for every bracket `|det M| < L`, `chi(L) < 0 < chi(U)` (a
    root in `(L, U)`); and the other two roots in the open unit disc, by Rouche
    (`rouche_disc`) where its three signs are certified, else by the Jury
    conditions `|v| < 1`, `|u| < 1 + v` on the quotient
    `t^2 + u t + v = chi / (t - beta)` (`u = c_2 + beta`, `v = det M / beta`). Then `chi` is
    irreducible, `beta` is its only root outside the disc and the root in every
    bracket. Also fixes the sign that makes the tile lengths positive."""
    var chi = cone.chi.copy()
    if len(chi) != 4 or qx_deg(qx_sub(chi[3], qx_const(1))) >= 0:
        raise Error("the characteristic polynomial is not a monic cubic")
    var det_p = qx_neg(chi[0])
    if qx_deg(det_p) > 0:
        raise Error("the cone's determinant is not constant")
    var det = qx_const_term(det_p)
    if det.eq(Q.zero()):
        return ConeCertificate(False, 0, "det M = 0")
    var support = List[Int]()
    for i in range(3):
        for j in range(3):
            var s = region.sign(cone.m[i][j])
            if s < 0:
                return ConeCertificate(False, 0, "a negative matrix entry")
            support.append(1 if s > 0 else 0)
    if not primitive_support(support):
        return ConeCertificate(False, 0, "support not primitive")
    var dabs = det.copy() if Q.zero().lt(det) else det.neg()
    var dn = 1
    while q_int(dn).le(dabs):
        if dabs.div(q_int(dn)).mul(q_int(dn)).eq(dabs):
            for sgn in range(2):
                var x = q_int(dn) if sgn == 0 else q_int(-dn)
                if region.sign(tp_homog_at(chi, qx_norm([[x.copy()]]), qx_const(1), 3)) == 0:
                    return ConeCertificate(False, 0, "a rational root")
        dn += 1
        if dn > 1000:
            raise Error("determinant too large for the rational-root screen")
    if len(cone.brackets) == 0:
        raise Error("a cone needs at least one bracket of its Perron root")
    for i in range(len(cone.brackets)):
        ref br = cone.brackets[i]
        if region.sign(br.lo.den) <= 0 or region.sign(br.hi.den) <= 0:
            return ConeCertificate(False, 0, "a bracket denominator is not positive")
        if region.sign(qx_sub(br.lo.num, qx_scale(br.lo.den, dabs))) <= 0:
            return ConeCertificate(False, 0, "a bracket does not lie above |det M|")
        if region.sign(tp_homog_at(chi, br.lo.num, br.lo.den, 3)) >= 0:
            return ConeCertificate(False, 0, "chi(L) is not negative")
        if region.sign(tp_homog_at(chi, br.hi.num, br.hi.den, 3)) <= 0:
            return ConeCertificate(False, 0, "chi(U) is not positive")
    if not rouche_disc(chi, region):
        var c2 = chi[2].copy()
        var dpoly = qx_norm([[det.copy()]])
        var jury_plus = tp_norm([dpoly.copy(), qx_add(c2, qx_const(1)), qx_const(1)])  # beta^2 + (c2 + 1) beta + det
        var jury_minus = tp_norm([dpoly.copy(), qx_sub(qx_const(1), c2), qx_const(-1)])  # -beta^2 + (1 - c2) beta + det
        if cone.sign_at_beta(jury_plus, region) <= 0 or cone.sign_at_beta(jury_minus, region) <= 0:
            return ConeCertificate(False, 0, "a Jury condition fails")
    var s = cone.sign_at_beta(cone.ell[cone.y], region)
    if s == 0:
        return ConeCertificate(False, 0, "a tile length vanishes")
    for i in range(3):
        if cone.sign_at_beta(cone.ell[i], region) != s:
            return ConeCertificate(False, 0, "tile lengths of mixed sign")
    return ConeCertificate(True, s, "")


def rouche_disc(chi: TPoly, mut region: Region) -> Bool:
    """`chi = t^3 + c2 t^2 + c1 t + c0` with `|c2| > 1 + |c1| + |c0|` on the
    region, certified by three plain region signs and none at beta. On
    `|t| = 1` the term `c2 t^2` then dominates the rest strictly, so (Rouche)
    `chi` has two roots in the open unit disc and none on the circle, as
    `c2 t^2` does. This is what the Jury conditions give, read without a bracket.
    `False` when a sign is not certified: the caller falls back to Jury."""
    var margin = qx_const(-1)
    for k in range(3):
        var sk = region.try_sign(chi[k])
        if sk == 2 or (k == 2 and sk == 0):
            return False
        margin = qx_add(margin, chi[k]) if (k == 2) == (sk > 0) else qx_sub(margin, chi[k])
    return region.try_sign(margin) == 1


struct ConeGraph(Copyable, Movable):
    var vertices: List[ConeVertex]
    var adj: List[List[Int]]
    var pip: Bool
    var reason: String
    var queries: Int
    var polya: Int

    def __init__(out self):
        self.vertices = List[ConeVertex]()
        self.adj = List[List[Int]]()
        self.pip = False
        self.reason = ""
        self.queries = 0
        self.polya = 0

    def size(self) -> Int:
        return len(self.vertices)


struct _ConeClosure:
    var cone: Cone
    var sign: Int  # orientation that makes ell positive at beta
    var region: Region
    var index: Dict[String, Int]
    var vertices: List[ConeVertex]
    var adj: List[List[Int]]
    var queue: List[Int]
    var memo: Dict[String, Int]

    def __init__(out self, var cone: Cone, sign: Int, var region: Region):
        self.cone = cone^
        self.sign = sign
        self.region = region^
        self.index = Dict[String, Int]()
        self.vertices = List[ConeVertex]()
        self.adj = List[List[Int]]()
        self.queue = List[Int]()
        self.memo = Dict[String, Int]()

    def positive(mut self, g: TPoly) raises -> Int:
        var h = tp_scale(g, qx_const(self.sign))
        var k = tp_key(h)
        var hit = self.memo.get(k)
        if hit:
            return hit.value()
        var s = self.cone.sign_at_beta(h, self.region)
        self.memo[k] = s
        return s

    def real(mut self, a: Int, b: Int, w: List[QX]) raises -> Bool:
        """`-ell_b < <ell, w> < ell_a`."""
        var t = self.cone.t_of(w)
        if self.positive(tp_add(self.cone.ell[b], t)) <= 0:
            return False
        return self.positive(tp_sub(self.cone.ell[a], t)) > 0

    def intern(mut self, var v: ConeVertex) raises -> Int:
        var k = v.key()
        var hit = self.index.get(k)
        if hit:
            return hit.value()
        if len(self.vertices) >= CONE_VERTEX_CAP:
            raise Error("symbolic cone closure exceeded its vertex cap")
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
            v = w_add(v, w_unit(self.cone.first[a], qx_const(1)))
        if seg >= 2:
            v = w_add(v, w_unit(self.cone.y, self.cone.run[a]))
        return v^

    def has_run(mut self, a: Int) raises -> Bool:
        var s = self.region.sign(self.cone.run[a])
        if s < 0:
            raise Error("a run length is negative on the region")
        return s > 0

    def letter(self, a: Int, seg: Int) -> Int:
        if seg == 0:
            return self.cone.first[a]
        if seg == 1:
            return self.cone.y
        return self.cone.last[a]

    def _least_at(self, h0: TPoly, h1: TPoly, s1: Int, s2: Int, strict: Bool) raises -> Int:
        var field = LineField(tp_at_q(self.cone.chi, s2, s1))
        var g0 = tp_at_q(tp_scale(h0, qx_const(self.sign)), s2, s1)
        var g1 = tp_at_q(tp_scale(h1, qx_const(self.sign)), s2, s1)
        return least_integer_at(field, g0, g1, strict)

    def least_m(mut self, h0: TPoly, h1: TPoly, strict: Bool) raises -> QX:
        """The least integer `m(s)` with `h0 + m h1 > 0` (`>= 0` if not `strict`) at
        beta (`h1 > 0`), affine in `s`, fitted at three sample points and certified."""
        var a1 = self.region.n1 + CONE_SAMPLE
        var a2 = self.region.n2 + CONE_SAMPLE
        var v0 = self._least_at(h0, h1, a1, a2, strict)
        var v1 = self._least_at(h0, h1, a1 + CONE_SAMPLE, a2, strict)
        var v2 = self._least_at(h0, h1, a1, a2 + CONE_SAMPLE, strict)
        var k1 = (v1 - v0) // CONE_SAMPLE
        var k2 = (v2 - v0) // CONE_SAMPLE
        if v1 - v0 != k1 * CONE_SAMPLE or v2 - v0 != k2 * CONE_SAMPLE:
            raise Error("a run-position bound is not affine in s at the samples")
        var mu = qx_affine2(v0 - k1 * a1 - k2 * a2, k2, k1)
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
        var mw = self.cone.mw(v.w)
        var ell = self.cone.ell.copy()
        var y = self.cone.y
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
                        var c = self.intern(ConeVertex(a2, b2, base^))
                        self.adj[i].append(c)
                    continue
                # offset base + m e_y, m = k_b - k_a in [rlo, rhi]; real iff lower(m) > 0 and upper(m) < 0
                var t = self.cone.t_of(base)
                var lower = tp_add(ell[b2], t)
                var upper = tp_sub(t, ell[a2])
                var rlo = qx_neg(qx_sub(self.cone.run[v.top], qx_const(1))) if sa == 1 else QX()
                var rhi = qx_sub(self.cone.run[v.bottom], qx_const(1)) if sb == 1 else QX()
                if self.positive(tp_add(lower, tp_scale(ell[y], rhi))) <= 0:
                    continue  # even the last run position is not real
                if self.positive(tp_add(upper, tp_scale(ell[y], rlo))) >= 0:
                    continue  # even the first run position is not real
                # a run end inside the real interval clips it; otherwise the interval's end is fitted
                var low = rlo.copy()
                if self.positive(tp_add(lower, tp_scale(ell[y], rlo))) <= 0:
                    low = self.least_m(lower, ell[y], True)
                var high = rhi.copy()
                if self.positive(tp_add(upper, tp_scale(ell[y], rhi))) >= 0:
                    high = qx_sub(self.least_m(upper, ell[y], False), qx_const(1))
                var gap = qx_sub(high, low)
                if qx_deg(gap) > 0:
                    if self.region.sign(gap) < 0:
                        continue
                    raise Error("a run-position range grows with s")
                var g0 = qx_const_term(gap)
                if g0.lt(Q.zero()):
                    continue
                var width = 0
                while q_int(width + 1).le(g0):
                    width += 1
                for d in range(width + 1):
                    var child = w_add(base, w_unit(y, qx_add(low, qx_const(d))))
                    var c = self.intern(ConeVertex(a2, b2, child^))
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
                            _ = self.intern(ConeVertex(tops[i], bots[j], w^))


def symbolic_cone_graph(var cone: Cone, var region: Region) raises -> ConeGraph:
    """The swap-seed overlap graph on every integer point of the region; see the module docstring."""
    var cert = certify_cone(cone, region)
    var out = ConeGraph()
    if not cert.holds:
        out.reason = cert.reason
        return out^
    var cl = _ConeClosure(cone^, cert.ell_sign, region^)
    cl.seeds()
    var done = 0
    while done < len(cl.queue):
        var i = cl.queue[done]
        done += 1
        cl.expand(i)
    out.pip = True
    out.queries = cl.region.queries
    out.polya = cl.region.polya
    out.vertices = cl.vertices.copy()
    out.adj = cl.adj.copy()
    return out^


def cone_offset_zero_reachable(g: ConeGraph) -> List[Bool]:
    """Whether each vertex has an offset-zero descendant (itself included)."""
    var zero = List[Bool]()
    for i in range(g.size()):
        zero.append(g.vertices[i].is_zero_offset())
    return zero_descendants(g.adj, zero)
