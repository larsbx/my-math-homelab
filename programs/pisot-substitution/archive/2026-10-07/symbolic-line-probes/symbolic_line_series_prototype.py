"""EXPLORATORY prototype: the seed-reachable overlap graph of a one-parameter line
of substitutions, computed symbolically for all large q.

A line is sigma_q with images  first-letter, y^(run(q)), last-letter, run affine in q.
Offsets w are vectors of integer polynomials in q.  Signs and floors of algebraic
functions of q are decided from Laurent expansions in e = 1/q of beta(q).  This is a
prototype for discovering structure; it is NOT a certificate (eventual signs carry no
threshold here).
"""
from fractions import Fraction as Fr
import sympy as sp, itertools, sys

N = 10  # series order (powers of e kept: e^-K .. e^N)

class L:
    """Truncated Laurent series in e: dict power->Fraction, powers <= N kept."""
    __slots__ = ('c',)
    def __init__(self, c=None): self.c = {k: v for k, v in (c or {}).items() if v != 0 and k <= N}
    @staticmethod
    def const(x): return L({0: Fr(x)})
    def __add__(s, o):
        o = o if isinstance(o, L) else L.const(o); d = dict(s.c)
        for k, v in o.c.items(): d[k] = d.get(k, 0) + v
        return L(d)
    __radd__ = __add__
    def __neg__(s): return L({k: -v for k, v in s.c.items()})
    def __sub__(s, o): return s + (-(o if isinstance(o, L) else L.const(o)))
    def __rsub__(s, o): return (-s) + o
    def __mul__(s, o):
        o = o if isinstance(o, L) else L.const(o); d = {}
        for a, x in s.c.items():
            for b, y in o.c.items():
                if a + b <= N: d[a + b] = d.get(a + b, 0) + x * y
        return L(d)
    __rmul__ = __mul__
    def low(s): return min(s.c) if s.c else None
    def inv(s):
        k0 = s.low(); a0 = s.c[k0]
        # s = a0 e^k0 (1 + u), u has positive powers
        u = L({k - k0: v / a0 for k, v in s.c.items() if k != k0})
        r = L.const(1); term = L.const(1)
        for _ in range(N + 2 + abs(k0)):
            term = term * (-u); r = r + term
        return L({k - k0: v / a0 for k, v in r.c.items()})
    def __truediv__(s, o): return s * (o if isinstance(o, L) else L.const(o)).inv()
    def sign(s):
        if not s.c: return 0
        return 1 if s.c[s.low()] > 0 else -1

Qs = L({-1: Fr(1)})  # q = 1/e

def poly_to_L(coeffs):
    """integer polynomial in q as list [c0, c1, ...] -> Laurent series."""
    r = L(); qp = L.const(1)
    for c in coeffs:
        r = r + qp * c; qp = qp * Qs
    return r

# ---- polynomials in q: tuples of ints (c0, c1, ...) ----
def padd(a, b):
    n = max(len(a), len(b)); return tuple((a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0) for i in range(n))
def pscale(a, k): return tuple(k * x for x in a)
def pmul(a, b):
    r = [0] * (len(a) + len(b) - 1) if a and b else []
    for i, x in enumerate(a):
        for j, y in enumerate(b): r[i + j] += x * y
    return tuple(r)
def pnorm(a):
    a = list(a)
    while a and a[-1] == 0: a.pop()
    return tuple(a)
def vadd(u, v): return tuple(pnorm(padd(a, b)) for a, b in zip(u, v))
def vsub(u, v): return vadd(u, tuple(pscale(b, -1) for b in v))
E = [tuple((1,) if i == j else () for j in range(3)) for i in range(3)]
def vscale_poly(v, p): return tuple(pnorm(pmul(a, p)) for a in v)

class Line:
    def __init__(self, first, runs, last, seed_q):
        """first[a], last[a] letters; runs[a] = (c0, c1) run length c0 + c1 q."""
        self.first, self.runs, self.last = first, runs, last
        # incidence M[a][b] = count of a in sigma(b), entries polynomials in q
        M = [[() for _ in range(3)] for _ in range(3)]
        for b in range(3):
            for a in (first[b], last[b]): M[a][b] = padd(M[a][b], (1,))
            M[2][b] = padd(M[2][b], runs[b])
        self.M = [[pnorm(x) for x in row] for row in M]
        self._series(seed_q)
    def Mw(self, w):
        return tuple(pnorm(padd(padd(pmul(self.M[i][0], w[0]), pmul(self.M[i][1], w[1])), pmul(self.M[i][2], w[2]))) for i in range(3))
    def _series(self, seed_q):
        q, t = sp.symbols('q t')
        Ms = sp.Matrix(3, 3, lambda i, j: sum(c * q**k for k, c in enumerate(self.M[i][j])))
        chi = sp.expand((t * sp.eye(3) - Ms).det())
        self.chi = chi
        # beta ~ a q^d: find by numeric root at seed_q
        import numpy as np
        Mn = np.array([[float(sum(c * seed_q**k for k, c in enumerate(self.M[i][j]))) for j in range(3)] for i in range(3)])
        b_num = max(np.linalg.eigvals(Mn).real)
        # assume beta = q + s(e), s power series in e (verify degree)
        e = sp.symbols('e')
        cs = sp.symbols('c0:%d' % (N + 1))
        s = sum(cs[i] * e**i for i in range(N + 1))
        expr = sp.expand(chi.subs({t: 1 / e + s, q: 1 / e}) * e**3)
        ser = sp.series(expr, e, 0, N + 1).removeO()
        sol = {}
        for i in range(N + 1):
            eq = sp.expand(ser.coeff(e, i).subs(sol))
            unknowns = [c for c in cs if c in eq.free_symbols]
            if not unknowns: continue
            c = unknowns[0]
            roots = sp.solve(eq, c)
            if len(roots) > 1:  # pick the one matching numerics
                approx = b_num - seed_q
                roots.sort(key=lambda r: abs(float(r) - approx))
            sol[c] = roots[0]
        self.beta = L({-1: Fr(1)}) + L({i: Fr(str(sp.nsimplify(sol[cs[i]]))) for i in range(N + 1) if cs[i] in sol})
        # left eigenvector ell with ell_y = 1: solve ell (M - beta I) = 0
        lx, lc = sp.symbols('lx lc')
        eqs = [sum([lx, lc, 1][i] * Ms[i, j] for i in range(3)) - t * [lx, lc, 1][j] for j in range(3)]
        sol2 = sp.solve(eqs[:2], [lx, lc], dict=True)[0]
        self.ell_expr = (sp.simplify(sol2[lx]), sp.simplify(sol2[lc]), sp.Integer(1))
        self.ell = [self._eval(ex) for ex in self.ell_expr]
    def _eval(self, ex):
        """sympy rational expression in q, t -> Laurent series at t = beta."""
        q, t = sp.symbols('q t')
        num, den = sp.fraction(sp.together(ex))
        return self._poly_eval(sp.Poly(num, q, t)) / self._poly_eval(sp.Poly(den, q, t))
    def _poly_eval(self, P):
        r = L()
        for (i, j), c in P.terms():
            term = L.const(Fr(int(c)))
            for _ in range(i): term = term * Qs
            for _ in range(j): term = term * self.beta
            r = r + term
        return r
    def t_of(self, w):
        return sum((poly_to_L(w[i]) * self.ell[i] for i in range(3)), L())
    def prefix(self, a, seg, k=None):
        """Parikh vector of the prefix of sigma(a) before segment seg (0 first, 1 run, 2 last),
        plus k letters y inside the run."""
        v = ((), (), ())
        if seg >= 1: v = vadd(v, E[self.first[a]])
        if seg >= 2: v = vadd(v, vscale_poly(E[2], self.runs[a]))
        return v
    def segs(self, a):
        return [(0, self.first[a]), (1, 2), (2, self.last[a])]

def floor_affine(F):
    """F a Laurent series ~ alpha q + gamma + o(1); floor(F) as (gamma_floor, alpha) poly, or None."""
    lo = F.low()
    if lo is not None and lo < -1: return None
    alpha = F.c.get(-1, Fr(0)); gamma = F.c.get(0, Fr(0))
    if alpha.denominator != 1: return None
    rest = L({k: v for k, v in F.c.items() if k > 0})
    g = gamma.numerator // gamma.denominator
    if gamma.denominator == 1 and rest.sign() < 0: g -= 1
    return (g, int(alpha))
def exact_int(F):
    """F identically alpha q + gamma integral (to series order)?"""
    rest = L({k: v for k, v in F.c.items() if k > 0})
    return rest.sign() == 0 and F.c.get(0, Fr(0)).denominator == 1 and F.c.get(-1, Fr(0)).denominator == 1 and (F.low() is None or F.low() >= -1)

def children(Ln, v):
    a, b, w = v
    out = set()
    Mw = Ln.Mw(w)
    ell = Ln.ell
    for sa, A in Ln.segs(a):
        for sb, B in Ln.segs(b):
            base = vsub(vadd(Mw, Ln.prefix(b, sb)), Ln.prefix(a, sa))
            Z = Ln.t_of(base)
            ra, rb = sa == 1, sb == 1
            if not ra and not rb:
                if (Z + ell[B]).sign() > 0 and (ell[A] - Z).sign() > 0: out.add((A, B, base))
                continue
            # m = (k' if rb else 0) - (k if ra else 0); child offset base + m e_y; real iff -l_B < Z + m < l_A
            lo_F = -ell[B] - Z  # m > lo_F
            hi_F = ell[A] - Z   # m < hi_F
            flo, fhi = floor_affine(lo_F), floor_affine(hi_F)
            if flo is None or fhi is None: raise RuntimeError('non-affine floor')
            mlo = (flo[0] + 1, flo[1])                      # smallest integer > lo_F
            mhi = (fhi[0] - (1 if exact_int(hi_F) else 0), fhi[1])  # largest integer < hi_F
            # range of m from run positions: k in [0, run_a - 1], k' in [0, run_b - 1]
            rlo = pnorm(pscale(padd(Ln.runs[a], (-1,)), -1)) if ra else ()
            rhi = pnorm(padd(Ln.runs[b], (-1,))) if rb else ()
            def cmp_aff(x, y):  # x, y as (const, slope): sign of x - y eventually
                d = (x[1] - y[1], x[0] - y[0]); return (d[0] > 0) - (d[0] < 0) if d[0] else (d[1] > 0) - (d[1] < 0)
            def as_aff(p): p = tuple(p) + (0, 0); return (p[0], p[1]) if len(pnorm(p)) <= 2 else None
            lo = mlo if cmp_aff(mlo, as_aff(rlo)) >= 0 else as_aff(rlo)
            hi = mhi if cmp_aff(mhi, as_aff(rhi)) <= 0 else as_aff(rhi)
            if lo[1] != hi[1]:
                if cmp_aff(lo, hi) > 0: continue
                raise RuntimeError('m-range grows with q: %s %s' % (lo, hi))
            for m in range(lo[0], hi[0] + 1):
                mp = pnorm((m, lo[1]))
                out.add((A, B, vadd(base, vscale_poly(E[2], mp))))
    return out

def seeds(Ln, a, b):
    tops = [(a, ()), (b, Ln_ell_pos(Ln, [a]))]
    return tops
def seed_overlaps(Ln, a, b):
    out = set()
    top = [(a, ((), (), ())), (b, E[a])]
    bot = [(b, ((), (), ())), (a, E[b])]
    for A, P in top:
        for B, R in bot:
            w = vsub(R, P)
            t = Ln.t_of(w)
            if (t + Ln.ell[B]).sign() > 0 and (Ln.ell[A] - t).sign() > 0: out.add((A, B, w))
    return out

def closure(Ln, starts, cap=200000):
    seen = set(starts); stack = list(starts); adj = {}
    while stack:
        v = stack.pop()
        if v[0] == v[1] and all(not c for c in v[2]): adj[v] = set(); continue
        ch = children(Ln, v); adj[v] = ch
        for c in ch:
            if c not in seen:
                seen.add(c); stack.append(c)
                if len(seen) > cap: raise RuntimeError('cap')
    return adj

def hits(adj):
    zero = {v for v in adj if all(not c for c in v[2])}
    rev = {}
    for v, ch in adj.items():
        for c in ch: rev.setdefault(c, set()).add(v)
    good = set(zero); fr = list(zero)
    while fr:
        nf = []
        for v in fr:
            for u in rev.get(v, ()):
                if u not in good: good.add(u); nf.append(u)
        fr = nf
    return good

if __name__ == '__main__':
    X, C, Y = 0, 1, 2
    # class B line: sigma(x) = x y^(2q+2) x, sigma(c) = c y^q x, sigma(y) = c y^(q+1) x
    Ln = Line(first=[X, C, C], runs=[(2, 2), (0, 1), (1, 1)], last=[X, X, X], seed_q=50)
    print('beta =', {k: str(v) for k, v in sorted(Ln.beta.c.items())[:5]})
    print('ell  =', [{k: str(v) for k, v in sorted(l.c.items())[:4]} for l in Ln.ell])
    for (a, b) in [(X, C), (X, Y), (C, Y)]:
        st = seed_overlaps(Ln, a, b)
        adj = closure(Ln, st)
        good = hits(adj)
        bad = [v for v in adj if v not in good]
        print('seed', (a, b), 'vertices', len(adj), 'without offset-zero descendant', len(bad))
        maxdeg = max(max(len(c) for c in v[2]) for v in adj)
        print('   max polynomial length of offsets', maxdeg)
