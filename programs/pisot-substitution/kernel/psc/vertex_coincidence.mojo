"""Per-substitution decision of PeriodicPairVertexCoincidence for every r at once.

PeriodicPairVertexCoincidence (docs/p1b-strict-zipper-periodic-pair-2026-10-02.md,
Corollary B'): for every r >= 1 and every pair of interior occurrences
sigma^r(i) = P i U, sigma^r(j) = Q j V with integral centre offset w0, the
Phi^r-fixed tilings T(i, P) and T(j, Q) + <l, w0> share a vertex.

docs/p1b-vertex-coincidence-box-2026-10-02.md, Proposition V, reduces this to
one finite graph per substitution. Every vertex (i, j, t) on a cycle of the
overlap graph has |sigma_k(t)| <= C_k / (1 - |beta_k|) for each contracting
conjugate (C_k = max over the inflation increments c of |sigma_k(c)|), and
|t| < l_max. Writing w_m = Tr(theta_m t) with theta the trace-dual basis of
the tile lengths, this bounds every integer coordinate of the offset. Let
B be the overlaps whose offset coordinates obey those bounds, closed under
inflation. The statement holds for sigma, for all r, exactly when every
vertex of B has an offset-zero descendant: one direction by Theorem B(2),(3)
of the note, the other by Lemma C and the converse of Theorem B.

Exactness. Every bound is a rational upper bound of a real algebraic number,
certified by exact sign tests at isolated roots of the characteristic
polynomial (Sturm--Tarski, `psc.real_root_sign`): |sigma_k(x)| < q at a real
root, and |varsigma(x)|^2 = N(x)/x < q^2 for a complex pair. A bound is
allowed to be loose; the start set only has to contain every cycle vertex,
and a superset changes no verdict (any closed offset-zero-free set it
reaches contains a cycle, which is a genuine counterexample). The slab
|t| < l_max is scanned by exact monotone sign tests; no floating value is
used. A capped closure is reported as capped, never as a verdict.

The same automaton decides formal productivity (Theorem Omega of
docs/pds-certificate-from-the-box-automaton-2026-10-07.md): every potential
overlap reaches a coincidence exactly when every vertex of B does. One
direction is trivial; for the other, a nonproductive potential overlap has
finitely many descendants, so a nonproductive path from it repeats a vertex,
and that cycle vertex lies in B by step 1 of Proposition V alone. Neither
direction uses Theorem B, Lemma C, Proposition F or Theorem R.
"""

from finite_exact.rat_q import Q
from finite_linear_algebra.mat3 import Mat3
from psc.exact import q_int, q_poly, q_sign, require_q
from psc.field3 import cauchy_bound, discriminant, lift, qf_add, qf_mul, qf_norm, qf_scale, qf_sub
from psc.overlap_contracting import digit_set
from psc.overlap_obstruction import recurrent_sccs
from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapAutomaton,
    SeedOverlapTables,
    build_overlap_graph_from_seeds,
    build_seed_overlap_tables,
    build_seed_overlap_tables_screened,
    cached_sign,
    first_coincidence_depths,
    first_left_aligned_depths,
    interior_overlap_cached,
)
from psc.perron_field3 import CubicElt, cubic_add_checked, cubic_scale_checked, cubic_sub_checked
from psc.real_root_sign import isolate_real_roots, sign_at_isolated_root

comptime REFINE_STEPS = 10
comptime MAX_REFINE_STEPS = 80
comptime VERTEX_COINCIDENCE_STATE_CAP = 4000000


struct ConjugateRoots(Copyable, Movable):
    """Isolating brackets of the roots of the characteristic polynomial: index 0
    the Perron root; 1, 2 the real conjugates, or index 1 a complex pair."""

    var chi: List[Q]
    var is_complex: Bool
    var lo: List[Q]
    var hi: List[Q]

    def __init__(out self, tables: SeedOverlapTables) raises:
        var field = tables.field
        self.chi = q_poly(field.charpoly())
        self.is_complex = discriminant(field) < 0
        self.lo = List[Q]()
        self.hi = List[Q]()
        var perron = isolate_real_roots(self.chi, q_int(1), q_int(cauchy_bound(field)), 1)
        self.lo.append(perron[0][0].copy())
        self.hi.append(perron[0][1].copy())
        if not self.is_complex:
            var boxes = isolate_real_roots(self.chi, q_int(-1), q_int(1), 2)
            for r in range(2):
                self.lo.append(boxes[r][0].copy())
                self.hi.append(boxes[r][1].copy())

    def contracting(self) -> List[Int]:
        if self.is_complex:
            return [1]
        return [1, 2]

    def sign_at(self, k: Int, x: List[Q]) raises -> Int:
        return sign_at_isolated_root(self.chi, x, self.lo[k], self.hi[k])

    def exceeds(self, k: Int, x: List[Q], q: Q) raises -> Bool:
        """`q > |sigma_k(x)|`, decided exactly (`k = 1` is the complex pair)."""
        if self.is_complex and k == 1:
            # q^2 > N(x)/x at beta  <=>  sign(q^2 x - N(x)) == sign(x)
            var sx = self.sign_at(0, x)
            if sx == 0:
                return q_sign(q) > 0
            var diff = qf_sub(qf_scale(x, require_q(q.square(), "q^2")), _constant(qf_norm(self.chi, x)))
            return self.sign_at(0, diff) == sx
        var qq = _constant(q)
        return self.sign_at(k, qf_sub(qq, x)) > 0 and self.sign_at(k, qf_add(qq, x)) > 0

    def upper(self, k: Int, x: List[Q], steps: Int = REFINE_STEPS) raises -> Q:
        """A rational `q > |sigma_k(x)|`, within a factor `1 + 2^-steps` of it
        when `|sigma_k(x)| >= 1`, else within `2^-steps`."""
        var hi = q_int(1)
        while not self.exceeds(k, x, hi):
            hi = require_q(hi.mul(q_int(2)), "upper doubling")
        var lo = require_q(hi.div(q_int(2)), "upper half") if q_int(1).lt(hi) else q_int(0)
        for _ in range(steps):
            var mid = require_q(lo.add(hi).div(q_int(2)), "upper midpoint")
            if self.exceeds(k, x, mid):
                hi = mid^
            else:
                lo = mid^
        return hi^

    def contraction(self, k: Int) raises -> Q:
        """A rational upper bound `< 1` of `|beta_k|`, refined until it is `< 1`."""
        var beta = q_poly([0, 1])
        var steps = REFINE_STEPS
        while steps <= MAX_REFINE_STEPS:
            var u = self.upper(k, beta, steps)
            if u.lt(q_int(1)):
                return u^
            steps += 10
        raise Error("vertex coincidence: a contracting conjugate is not certified below 1")


def _constant(c: Q) -> List[Q]:
    var out = List[Q]()
    out.append(c.copy())
    return out^


def _trace(chi: List[Q], x: List[Q]) raises -> Q:
    """Tr_{Q(beta)/Q}(x) on the basis 1, beta, beta^2 (power sums by Newton)."""
    var e1 = chi[2].neg()
    var p1 = e1.copy()
    var p2 = require_q(e1.square().sub(chi[1].mul(q_int(2))), "power sum")
    var powers: List[Q] = [q_int(3), p1^, p2^]
    var out = q_int(0)
    for i in range(len(x)):
        out = require_q(out.add(x[i].mul(powers[i])), "trace")
    return out^


def _inverse3(m: List[List[Q]]) raises -> List[List[Q]]:
    var det = require_q(
        m[0][0].mul(m[1][1].mul(m[2][2]).sub(m[1][2].mul(m[2][1])))
        .sub(m[0][1].mul(m[1][0].mul(m[2][2]).sub(m[1][2].mul(m[2][0]))))
        .add(m[0][2].mul(m[1][0].mul(m[2][1]).sub(m[1][1].mul(m[2][0])))),
        "det",
    )
    if q_sign(det) == 0:
        raise Error("vertex coincidence: singular trace form")
    var inv = List[List[Q]]()
    for i in range(3):
        var row = List[Q]()
        for j in range(3):
            # inv[i][j] = cofactor(j, i) / det
            var rows: List[Int] = []
            var cols: List[Int] = []
            for a in range(3):
                if a != j:
                    rows.append(a)
                if a != i:
                    cols.append(a)
            var minor = m[rows[0]][cols[0]].mul(m[rows[1]][cols[1]]).sub(m[rows[0]][cols[1]].mul(m[rows[1]][cols[0]]))
            if (i + j) % 2 == 1:
                minor = minor.neg()
            row.append(require_q(minor.div(det), "inverse entry"))
        inv.append(row^)
    return inv^


def box_radii(tables: SeedOverlapTables) raises -> List[Int]:
    """Integer radii `R_m` with `|w_m| <= R_m` for the offset `w` of every overlap
    lying on a cycle of the overlap graph (Proposition V, step 1)."""
    var roots = ConjugateRoots(tables)
    var chi = roots.chi.copy()
    var lengths = List[List[Q]]()
    for a in range(3):
        lengths.append(lift(tables.lengths.at(a)))
    var lmax = roots.upper(0, lengths[0])
    for a in range(1, 3):
        var u = roots.upper(0, lengths[a])
        if lmax.lt(u):
            lmax = u^
    var digits = digit_set(tables)
    if len(digits) == 0:
        raise Error("vertex coincidence: empty increment set")
    var ks = roots.contracting()
    var bounds = List[Q]()
    for k in ks:
        var lam = roots.contraction(k)
        var c = roots.upper(k, lift(digits[0]))
        for d in range(1, len(digits)):
            var u = roots.upper(k, lift(digits[d]))
            if c.lt(u):
                c = u^
        bounds.append(require_q(c.div(q_int(1).sub(lam)), "contracting bound"))
    var mult = q_int(2) if roots.is_complex else q_int(1)
    var gram = List[List[Q]]()
    for a in range(3):
        var row = List[Q]()
        for b in range(3):
            row.append(_trace(chi, qf_mul(chi, lengths[a], lengths[b])))
        gram.append(row^)
    var inv = _inverse3(gram)
    var radii = List[Int]()
    for m in range(3):
        var theta = q_poly([0])
        for b in range(3):
            theta = qf_add(theta, qf_scale(lengths[b], inv[m][b]))
        var radius = require_q(roots.upper(0, theta).mul(lmax), "expanding term")
        for idx in range(len(ks)):
            var term = require_q(roots.upper(ks[idx], theta).mul(bounds[idx]).mul(mult), "contracting term")
            radius = require_q(radius.add(term), "radius")
        var n = 0
        while q_int(n).lt(radius):
            n += 1
        radii.append(n)
    return radii^


def offset_of(lengths: List[CubicElt], w: List[Int]) raises -> CubicElt:
    """`t = <ell, w>`; `offset_vector` is its inverse."""
    var x = CubicElt()
    for a in range(3):
        x = cubic_add_checked(x, cubic_scale_checked(lengths[a], w[a]))
    return x


def length_matrix(tables: SeedOverlapTables) raises -> Mat3:
    """Columns are the tile lengths in the basis `1, beta, beta^2`."""
    var e = List[Int]()
    for r in range(3):
        for a in range(3):
            var l = tables.lengths.at(a)
            e.append(l.a0 if r == 0 else (l.a1 if r == 1 else l.a2))
    return Mat3(e^)


def offset_vector(lengths: Mat3, t: CubicElt) raises -> List[Int]:
    """The integral `w` with `t = <ell, w>`; raises if `t` is not in `<ell, Z^3>`."""
    var d = lengths.det()
    if d == 0:
        raise Error("tile lengths are linearly dependent")
    var u = lengths.adjugate().apply([t.a0, t.a1, t.a2])
    var w = List[Int]()
    for k in range(3):
        if u[k] % d != 0:
            raise Error("offset is not an integral combination of tile lengths")
        w.append(u[k] // d)
    return w^


def box_start_states(
    tables: SeedOverlapTables, radii: List[Int], mut cache: Dict[CubicElt, Int]
) raises -> List[OverlapState]:
    """Every interior overlap `(i, j, <l, w>)` with `|w_m| <= R_m` on the two
    looped coordinates and `|t| < l_max` (a superset of the cycle vertices).

    The coordinate with the largest radius is solved for: `t` increases with
    it, so the slab `-l_max < t < l_max` is an integer interval found by exact
    monotone scans from the previous row's start."""
    var lengths = List[CubicElt]()
    for a in range(3):
        lengths.append(tables.lengths.at(a))
    var longest = lengths[0]
    for a in range(1, 3):
        if cached_sign(tables, cache, cubic_sub_checked(lengths[a], longest)) > 0:
            longest = lengths[a]
    var z = 0
    for m in range(1, 3):
        if radii[m] > radii[z]:
            z = m
    var x = 1 if z == 0 else 0
    var y = 2 if z != 2 else 1
    var out = List[OverlapState]()
    var starts = List[Int]()
    for _ in range(2 * radii[y] + 1):
        starts.append(0)
    for wx in range(-radii[x], radii[x] + 1):
        for iy in range(2 * radii[y] + 1):
            var w: List[Int] = [0, 0, 0]
            w[x] = wx
            w[y] = iy - radii[y]
            var s = starts[iy]
            w[z] = s
            # least s with t > -l_max
            if cached_sign(tables, cache, cubic_add_checked(offset_of(lengths, w), longest)) <= 0:
                while cached_sign(tables, cache, cubic_add_checked(offset_of(lengths, w), longest)) <= 0:
                    w[z] += 1
            else:
                while True:
                    w[z] -= 1
                    if cached_sign(tables, cache, cubic_add_checked(offset_of(lengths, w), longest)) <= 0:
                        w[z] += 1
                        break
            starts[iy] = w[z]
            while True:
                var t = offset_of(lengths, w)
                if cached_sign(tables, cache, cubic_sub_checked(t, longest)) >= 0:
                    break
                for i in range(3):
                    for j in range(3):
                        var state = OverlapState(i, j, t)
                        if interior_overlap_cached(tables, cache, state):
                            out.append(state)
                w[z] += 1
    return out^


struct VertexCoincidenceVerdict(Copyable, Movable, Writable):
    var holds: Bool
    var capped: Bool
    var radii: List[Int]
    var starts: Int
    var states: Int
    var recurrent: Int
    var deepest: Int
    var witness: OverlapState
    # Theorem Omega: every box vertex reaches a coincidence (formal productivity)
    var productive: Bool
    # largest first-coincidence depth over all box vertices (D of the box)
    var coincidence_depth: Int
    # largest first-coincidence depth over the six aligned pairs (i, j, 0): S(sigma)
    var aligned_depth: Int
    var nonproductive_witness: OverlapState

    def __init__(out self):
        self.holds = False
        self.capped = False
        self.radii = List[Int]()
        self.starts = 0
        self.states = 0
        self.recurrent = 0
        self.deepest = -1
        self.witness = OverlapState(0, 0, CubicElt())
        self.productive = False
        self.coincidence_depth = -1
        self.aligned_depth = -1
        self.nonproductive_witness = OverlapState(0, 0, CubicElt())

    def write_to[W: Writer](self, mut w: W):
        w.write(
            "holds=", self.holds, " capped=", self.capped, " radii=", self.radii[0], ",", self.radii[1], ",",
            self.radii[2], " starts=", self.starts, " states=", self.states, " recurrent=", self.recurrent,
            " deepest=", self.deepest, " productive=", self.productive, " D=", self.coincidence_depth,
            " S=", self.aligned_depth,
        )


def decide_vertex_coincidence_from(
    tables: SeedOverlapTables, max_states: Int = VERTEX_COINCIDENCE_STATE_CAP
) raises -> VertexCoincidenceVerdict:
    """Decide PeriodicPairVertexCoincidence for one substitution, for all r.

    `holds` is True exactly when every vertex of the box graph has an
    offset-zero descendant. `recurrent` counts the non-coincidence vertices on
    a cycle of the graph (independent of the start superset), and `deepest` is
    the largest first left-aligned depth among them. When `holds` is False,
    `witness` is a vertex with no offset-zero descendant: by Lemma C and
    Theorem B it yields a pair of tilings with no common vertex."""
    var v = VertexCoincidenceVerdict()
    var cache = Dict[CubicElt, Int]()
    v.radii = box_radii(tables)
    var starts = box_start_states(tables, v.radii, cache)
    v.starts = len(starts)
    var a = build_overlap_graph_from_seeds(tables, starts, cache, max_states)
    return _verdict_on(a, v^)


def build_box_graph(
    tables: SeedOverlapTables, max_states: Int = VERTEX_COINCIDENCE_STATE_CAP
) raises -> SeedOverlapAutomaton:
    """The box graph itself: the closure of `box_start_states` under inflation."""
    var cache = Dict[CubicElt, Int]()
    return build_overlap_graph_from_seeds(tables, box_start_states(tables, box_radii(tables), cache), cache, max_states)


def _verdict_on(a: SeedOverlapAutomaton, var v: VertexCoincidenceVerdict) raises -> VertexCoincidenceVerdict:
    if a.capped:
        v.capped = True
        return v^
    v.states = a.size()
    var depths = first_left_aligned_depths(a)
    v.holds = True
    for i in range(a.size()):
        if depths[i] < 0:
            v.holds = False
            v.witness = a.states[i]
            break
    var coin = first_coincidence_depths(a)
    v.productive = True
    for i in range(a.size()):
        if coin[i] < 0:
            if v.productive:
                v.nonproductive_witness = a.states[i]
            v.productive = False
            continue
        v.coincidence_depth = max(v.coincidence_depth, coin[i])
        if a.states[i].shift.is_zero() and not a.states[i].is_coincidence():
            v.aligned_depth = max(v.aligned_depth, coin[i])
    var comps = recurrent_sccs(a)
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            var i = comps[c][k]
            v.recurrent += 1
            if depths[i] > v.deepest:
                v.deepest = depths[i]
    return v^


def decide_vertex_coincidence(
    sigma: List[List[Int]], max_states: Int = VERTEX_COINCIDENCE_STATE_CAP
) raises -> VertexCoincidenceVerdict:
    return decide_vertex_coincidence_from(build_seed_overlap_tables(sigma), max_states)


def decide_vertex_coincidence_screened(
    sigma: List[List[Int]], max_states: Int = VERTEX_COINCIDENCE_STATE_CAP
) raises -> VertexCoincidenceVerdict:
    """`decide_vertex_coincidence` outside the audited image-length domain, on
    the coefficient-screened field (`build_seed_overlap_tables_screened`)."""
    return decide_vertex_coincidence_from(build_seed_overlap_tables_screened(sigma), max_states)
