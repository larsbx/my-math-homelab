"""Exact contraction-rate depth laws: `K_V <= a + c / log(1/mu)`.

`mu^2 = max_k |sigma_k(beta)|^2` is enclosed exactly -- `|det M| / beta` for a
complex contracting pair, the larger squared real conjugate otherwise -- in a
rational bracket from isolating intervals of the characteristic polynomial,
refined by bisection with exact sign evaluation. When `K_V > a` the law is
`(mu^2)^(K_V - a) >= (e^(-c))^2`; with a rational bracket `[E_lo, E_hi]` of
`e^(-c)` a specimen *holds* when `mu2_lo^n >= E_hi^2`, *violates* when
`mu2_hi^n < E_lo^2`, and is refined otherwise; after `MAX_ROUNDS` bisections it
is counted *undecided*, never as a verdict. No floating value decides anything.
See docs/p1b-vertex-coincidence-box-2026-10-02.md §5.5a.
"""

from finite_exact.rat_q import Q
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.exact import eval_q_poly_at_q, q_int, q_poly, q_sign, require_q
from psc.field3 import cauchy_bound, discriminant
from psc.overlap_seed_patch import build_seed_overlap_tables
from psc.real_root_sign import isolate_real_roots

comptime MAX_ROUNDS = 80


struct Law(Copyable, Movable):
    var name: String
    var a: Int
    var e_lo: Q
    var e_hi: Q
    var holds: Int
    var violates: Int
    var undecided: Int

    def __init__(out self, name: String, a: Int, e_lo: Q, e_hi: Q):
        self.name = name
        self.a = a
        self.e_lo = e_lo.copy()
        self.e_hi = e_hi.copy()
        self.holds = 0
        self.violates = 0
        self.undecided = 0


def _qpow(x: Q, n: Int) raises -> Q:
    var out = Q.one()
    for _ in range(n):
        out = require_q(out.mul(x), "power")
    return out^


def _bisect(chi: List[Q], mut lo: Q, mut hi: Q) raises:
    """Halve an isolating bracket of a simple root of `chi`."""
    var mid = require_q(lo.add(hi).div(q_int(2)), "midpoint")
    var s_lo = q_sign(eval_q_poly_at_q(chi, lo))
    var s_mid = q_sign(eval_q_poly_at_q(chi, mid))
    if s_mid == 0:
        lo = mid.copy()
        hi = mid.copy()
    elif s_mid == s_lo:
        lo = mid^
    else:
        hi = mid^


def _abs_bracket(lo: Q, hi: Q) raises -> List[Q]:
    """`[min |x|, max |x|]` over `x` in `[lo, hi]`."""
    var alo = lo.neg() if q_sign(lo) < 0 else lo.copy()
    var ahi = hi.neg() if q_sign(hi) < 0 else hi.copy()
    var top = ahi.copy() if alo.lt(ahi) else alo.copy()
    if q_sign(lo) <= 0 and q_sign(hi) >= 0:
        return [Q.zero(), top^]
    var bottom = alo.copy() if alo.lt(ahi) else ahi.copy()
    return [bottom^, top^]


struct MuSquared(Copyable, Movable):
    """A refinable exact bracket of `mu^2`."""

    var chi: List[Q]
    var is_complex: Bool
    var det: Q
    var lo: List[Q]  # root brackets: index 0 the Perron root, 1-2 real conjugates
    var hi: List[Q]

    def __init__(out self, sigma: List[List[Int]]) raises:
        var tables = build_seed_overlap_tables(sigma)
        var field = tables.field
        self.chi = q_poly(field.charpoly())
        self.is_complex = discriminant(field) < 0
        var m = Mat3(substitution_incidence(sigma))
        self.det = q_int(abs(m.det()))
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

    def refine(mut self) raises:
        for r in range(len(self.lo)):
            _bisect(self.chi, self.lo[r], self.hi[r])

    def bracket(self) raises -> List[Q]:
        if self.is_complex:
            # mu^2 = |det M| / beta, decreasing in beta
            return [
                require_q(self.det.div(self.hi[0]), "mu2 lo"),
                require_q(self.det.div(self.lo[0]), "mu2 hi"),
            ]
        var b1 = _abs_bracket(self.lo[1], self.hi[1])
        var b2 = _abs_bracket(self.lo[2], self.hi[2])
        var lo = b1[0].copy() if b2[0].lt(b1[0]) else b2[0].copy()
        var hi = b1[1].copy() if b2[1].lt(b1[1]) else b2[1].copy()
        return [require_q(lo.square(), "mu2 lo"), require_q(hi.square(), "mu2 hi")]


def judge(mut law: Law, mut mu: MuSquared, k_v: Int) raises:
    var n = k_v - law.a
    if n <= 0:
        law.holds += 1
        return
    var need_hi = require_q(law.e_hi.square(), "E_hi^2")
    var need_lo = require_q(law.e_lo.square(), "E_lo^2")
    for _ in range(MAX_ROUNDS):
        var b = mu.bracket()
        if not _qpow(b[0], n).lt(need_hi):
            law.holds += 1
            return
        if _qpow(b[1], n).lt(need_lo):
            law.violates += 1
            return
        mu.refine()
    law.undecided += 1


def standard_laws() -> List[Law]:
    """The three laws of §5.5a, with rational brackets of `e^(-c)`:
    `e^-3.2 = 0.04076220397...`, `e^-4 = 0.01831563888...`, `e^-1 = 0.36787944117...`."""
    var laws = List[Law]()
    laws.append(Law("K_V <= 3.2/log(1/mu)", 0, Q(407622039, 10000000000), Q(407622040, 10000000000)))
    laws.append(Law("K_V <= 4/log(1/mu)", 0, Q(183156388, 10000000000), Q(183156389, 10000000000)))
    laws.append(Law("K_V <= 7 + 1/log(1/mu)", 7, Q(3678794411, 10000000000), Q(3678794412, 10000000000)))
    return laws^
