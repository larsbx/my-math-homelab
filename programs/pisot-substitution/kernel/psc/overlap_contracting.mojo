"""Contracting lower bound on the first boundary-coincidence depth (canonical).

Manuscript Proposition 5.42.  An overlap `(i, j, t)` with a level-`m`
descendant of offset zero has `t = -sum_{s<m} beta^{-(s+1)} c_s` with each
increment `c_s` in the finite digit set `F` of one inflation, so for every
contracting embedding `sigma_k` of Q(beta):
    |sigma_k(t)| <= C_k * sum_{s=1}^{m} |sigma_k(beta)|^{-s},  C_k = max_{F \\ {0}} |sigma_k(c)|.
`least_level(t)` is `0` for `t = 0` and otherwise the least `m >= 1` allowed
by every contracting embedding.

Complex contracting pair (`D > 0`): `|sigma(t)|^2 = N(t)/t`,
`|sigma(beta)|^{-2} = rho := beta/D`, `K := max_{F \\ {0}} N(c)/c = C^2`
(attained at `c*`), and with `r = rho^{1/2}`:
`(sum_{s=1}^m r^s)^2 = A_m + r B_m`, `A_m = sum_j n_{2j} rho^j`,
`B_m = sum_j n_{2j+1} rho^j`, `n_k = min(k-1, 2m+1-k)`.  The defining
inequality squared is `N(t)/t <= K (A_m + r B_m)`, which holds iff
`N(t)/t <= K A_m` or `(N(t)/t - K A_m)^2 <= K^2 rho B_m^2`: two exact sign
tests at the Perron root, no relaxation.  Two real contracting conjugates:
the defining comparison at each isolated conjugate root.

All field arithmetic is in `Q[x]/(chi)` over unbounded rationals and every
sign is a Sturm--Tarski query (`real_root_sign`) at an isolated real root of
`chi`, the Perron root included: the fixed-width oracle of `perron_field3`
fails closed on the coefficient growth of the level tests, this one does
not.  A capped automaton is never accepted."""

from finite_exact.rat_q import Q, q_abs
from psc.exact import q_int, q_poly, q_sign, require_q
from psc.overlap_seed_patch import SeedOverlapAutomaton, SeedOverlapTables
from psc.perron_field3 import CubicElt, PerronField3, _checked_add, _checked_mul, _checked_sub, cubic_sub_checked
from psc.field3 import cauchy_bound, discriminant, lift, qf_add, qf_mul, qf_neg, qf_norm, qf_scale, qf_sub
from psc.real_root_sign import isolate_real_roots, sign_at_isolated_root


def digit_set(tables: SeedOverlapTables) raises -> List[CubicElt]:
    """Nonzero single-inflation offset increments q - p over all letter pairs."""
    var out = List[CubicElt]()
    var seen = Dict[CubicElt, Bool]()
    for a in range(3):
        for b in range(3):
            for k in range(len(tables.sigma[a])):
                for m in range(len(tables.sigma[b])):
                    var c = cubic_sub_checked(tables.prefix(b, m), tables.prefix(a, k))
                    if c.is_zero() or c in seen:
                        continue
                    seen[c] = True
                    out.append(c)
    return out^


struct ContractingBound(Copyable, Movable):
    var chi: List[Q]
    var is_complex: Bool
    var max_level: Int
    # isolating brackets: index 0 is the Perron root; 1, 2 the real conjugates (real case)
    var root_lo: List[Q]
    var root_hi: List[Q]
    # complex pair: rho = beta/D, the level tables A_m, B_m (index m, entry 0 unused),
    # c* maximising |N(c)|/|c| on F \ {0}, and |N(c*)|
    var rho: List[Q]
    var A: List[List[Q]]
    var B: List[List[Q]]
    var cstar: List[Q]
    var cstar_norm: Q
    # two real conjugates (index r = 0, 1): C_r and the level table G_r[m] = sum_{s<m} |beta_r|^s
    var cmax: List[List[Q]]
    var G: List[List[List[Q]]]
    # beta^m (index m), used by the real branch
    var beta_pow: List[List[Q]]

    def __init__(out self, tables: SeedOverlapTables, max_level: Int = 64) raises:
        var field = tables.field
        self.chi = q_poly(field.charpoly())
        self.max_level = max_level
        self.is_complex = discriminant(field) < 0
        self.root_lo = List[Q]()
        self.root_hi = List[Q]()
        self.rho = List[Q]()
        self.A = List[List[Q]]()
        self.B = List[List[Q]]()
        self.cstar = List[Q]()
        self.cstar_norm = Q.zero()
        self.cmax = List[List[Q]]()
        self.G = List[List[List[Q]]]()
        self.beta_pow = List[List[Q]]()
        var digits = digit_set(tables)
        if len(digits) == 0:
            raise Error("empty increment set")
        var perron = isolate_real_roots(self.chi, q_int(1), q_int(cauchy_bound(field)), 1)
        self.root_lo.append(perron[0][0].copy())
        self.root_hi.append(perron[0][1].copy())
        var beta = q_poly([0, 1])
        if self.is_complex:
            var D = q_int(-field.chi0)
            if q_sign(D) <= 0:
                raise Error("complex contracting pair requires D > 0")
            self.rho = qf_scale(beta, require_q(Q.one().div(D), "1/D"))
            var rho_pow = List[List[Q]]()
            rho_pow.append(q_poly([1]))
            for _ in range(max_level):
                rho_pow.append(qf_mul(self.chi, rho_pow[len(rho_pow) - 1], self.rho))
            # (sum_{s=1}^m r^s)^2 = A_m + r B_m with r^2 = rho, n_k = min(k-1, 2m+1-k)
            self.A.append(List[Q]())
            self.B.append(List[Q]())
            for m in range(1, max_level + 1):
                var Am = List[Q]()
                var Bm = List[Q]()
                for k in range(2, 2 * m + 1):
                    var n = k - 1 if k - 1 < 2 * m + 1 - k else 2 * m + 1 - k
                    var term = qf_scale(rho_pow[k // 2], q_int(n))
                    if k % 2 == 0:
                        Am = qf_add(Am, term)
                    else:
                        Bm = qf_add(Bm, term)
                self.A.append(Am^)
                self.B.append(Bm^)
            var best = self._abs_at(0, lift(digits[0]))
            var best_norm = q_abs(self._norm(lift(digits[0])))
            for i in range(1, len(digits)):
                var ac = self._abs_at(0, lift(digits[i]))
                var nc = q_abs(self._norm(lift(digits[i])))
                # nc/|c| > best_norm/|best|  <=>  nc*|best| - best_norm*|c| > 0
                if self._sign_at(0, qf_sub(qf_scale(best, nc), qf_scale(ac, best_norm))) > 0:
                    best = ac^
                    best_norm = nc^
            self.cstar = best^
            self.cstar_norm = best_norm^
        else:
            self.beta_pow.append(q_poly([1]))
            for _ in range(max_level):
                self.beta_pow.append(qf_mul(self.chi, self.beta_pow[len(self.beta_pow) - 1], beta))
            var boxes = isolate_real_roots(self.chi, q_int(-1), q_int(1), 2)
            for r in range(2):
                self.root_lo.append(boxes[r][0].copy())
                self.root_hi.append(boxes[r][1].copy())
                var eb = self._abs_at(r + 1, beta)
                var cm = self._abs_at(r + 1, lift(digits[0]))
                for i in range(1, len(digits)):
                    var c = self._abs_at(r + 1, lift(digits[i]))
                    if self._sign_at(r + 1, qf_sub(c, cm)) > 0:
                        cm = c^
                self.cmax.append(cm^)
                # G_r[m] = sum_{s<m} |beta_r|^s
                var Gr = List[List[Q]]()
                Gr.append(List[Q]())
                var pw = q_poly([1])
                for _ in range(max_level):
                    Gr.append(qf_add(Gr[len(Gr) - 1], pw))
                    pw = qf_mul(self.chi, pw, eb)
                self.G.append(Gr^)

    def _sign_at(self, r: Int, x: List[Q]) raises -> Int:
        return sign_at_isolated_root(self.chi, x, self.root_lo[r], self.root_hi[r])

    def _abs_at(self, r: Int, x: List[Q]) raises -> List[Q]:
        if self._sign_at(r, x) < 0:
            return qf_neg(x)
        return x.copy()

    def _norm(self, x: List[Q]) raises -> Q:
        return qf_norm(self.chi, x)

    def least_level(self, a: SeedOverlapAutomaton, t: CubicElt) raises -> Int:
        if a.capped:
            raise Error("contracting bound is undefined for a capped partial graph")
        if t.is_zero():
            return 0
        var x = lift(t)
        if self.is_complex:
            var at = self._abs_at(0, x)
            var lhs = qf_scale(self.cstar, q_abs(self._norm(x)))          # |N(t)| |c*|
            var at2 = qf_scale(qf_mul(self.chi, at, at), require_q(self.cstar_norm.square(), "K^2"))  # |N(c*)|^2 |t|^2
            for m in range(1, self.max_level + 1):
                # X <= K (A_m + r B_m), X = |N(t)|/|t|, K = |N(c*)|/|c*|; times |t| |c*|:
                var E = qf_sub(lhs, qf_scale(qf_mul(self.chi, self.A[m], at), self.cstar_norm))
                if self._sign_at(0, E) <= 0:
                    return m
                # E > 0: E <= |N(c*)| r B_m |t|  <=>  E^2 <= |N(c*)|^2 rho B_m^2 |t|^2
                var rhs = qf_mul(self.chi, qf_mul(self.chi, at2, self.rho), qf_mul(self.chi, self.B[m], self.B[m]))
                if self._sign_at(0, qf_sub(rhs, qf_mul(self.chi, E, E))) >= 0:
                    return m
            raise Error("contracting bound exceeded the level cap")
        var worst = 0
        for r in range(1, 3):
            var found = False
            for m in range(1, self.max_level + 1):
                var tb = self._abs_at(r, qf_mul(self.chi, x, self.beta_pow[m]))
                if self._sign_at(r, qf_sub(qf_mul(self.chi, self.cmax[r - 1], self.G[r - 1][m]), tb)) >= 0:
                    if m > worst:
                        worst = m
                    found = True
                    break
            if not found:
                raise Error("contracting bound exceeded the level cap")
        return worst


def bound_key(tables: SeedOverlapTables) raises -> String:
    """What a `ContractingBound` actually depends on: the cubic and the digit set.

    The bound is built from the cubic field and from `digit_set(tables)`, the
    single-inflation offset increments, whose extremal element fixes `c*`. The
    digit set is read off the substitution's images and prefix positions, so
    two specimens share a bound exactly when they share both. The cubic alone
    is not enough, and keying on it would return a bound built for a different
    increment set."""
    var chi = tables.field.charpoly()
    var digits = digit_set(tables)
    var parts = List[String]()
    for d in range(len(digits)):
        parts.append(
            String(digits[d].a0) + ":" + String(digits[d].a1) + ":" + String(digits[d].a2)
        )
    sort(parts)
    var key = String(chi[0]) + "," + String(chi[1]) + "," + String(chi[2]) + "|"
    for i in range(len(parts)):
        key += parts[i] + ";"
    return key^


struct ContractingBoundCache(Copyable, Movable):
    """One `ContractingBound` per distinct cubic and digit set, with its levels.

    Building a bound isolates the real roots, fills the level tables and picks
    the extremal increment, which costs far more than one evaluation of the
    bound. Over the standing corpus 4,554 specimens carry only 1,617 distinct
    (cubic, digit set) pairs, so most of that work is repeated on inputs that
    have already been seen.

    `least_level` reads the overlap graph only to refuse a capped one, and is
    otherwise a function of the bound and the shift, so computed levels are
    kept beside the bound they came from. A shift met again under the same key
    is not recomputed, even when it is first met under a different
    substitution.

    The key is never the shift alone, and never the cubic alone. A shift is a
    coefficient triple over a basis the cubic defines, so the same triple
    denotes different numbers in different fields; and two specimens can share
    a cubic while their increment sets differ, which gives different bounds.
    `test_census_library.mojo` pins agreement with a freshly built bound.
    """

    var index: Dict[String, Int]
    var bounds: List[ContractingBound]
    var levels: List[Dict[CubicElt, Int]]

    def __init__(out self):
        self.index = Dict[String, Int]()
        self.bounds = List[ContractingBound]()
        self.levels = List[Dict[CubicElt, Int]]()

    def slot(mut self, tables: SeedOverlapTables) raises -> Int:
        """The slot holding this specimen's bound, building it on first sight."""
        var key = bound_key(tables)
        if key in self.index:
            return self.index[key]
        var slot = len(self.bounds)
        self.bounds.append(ContractingBound(tables))
        self.levels.append(Dict[CubicElt, Int]())
        self.index[key] = slot
        return slot

    def is_complex(self, slot: Int) -> Bool:
        return self.bounds[slot].is_complex

    def least_level(
        mut self, slot: Int, a: SeedOverlapAutomaton, t: CubicElt
    ) raises -> Int:
        """`ContractingBound.least_level`, computed once per bound and shift.

        The capped refusal comes first, before the memo: a level already
        computed for this shift is no reason to answer a query about a partial
        graph, and a memo that answers one would be fail-open."""
        if a.capped:
            raise Error("contracting bound is undefined for a capped partial graph")
        if t in self.levels[slot]:
            return self.levels[slot][t]
        var level = self.bounds[slot].least_level(a, t)
        self.levels[slot][t] = level
        return level

    def distinct_bounds(self) -> Int:
        return len(self.bounds)

    def distinct_levels(self) -> Int:
        var n = 0
        for slot in range(len(self.levels)):
            n += len(self.levels[slot])
        return n
