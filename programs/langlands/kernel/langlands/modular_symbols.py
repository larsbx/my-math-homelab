"""Manin symbols for Gamma_0(N), weight 2 (Cremona, Algorithms for Modular Elliptic Curves, ch. 2).

Generators (c : d) ∈ P^1(Z/N), the modular symbol {b/d, a/c} for [[a, b], [c, d]] ∈ SL_2(Z);
relations x + xS = 0 and x + xT + xT^2 = 0; the quotient is H_1(X_0(N), cusps; Q).  Hecke
operators act through Merel's Heilbronn matrices {[[a, b], [c, d]] : ad - bc = n, a > b >= 0,
d > c >= 0}; the cuspidal subspace is the kernel of the boundary map to the cusps
(Gamma_0(N)-classes of P^1(Q), Cremona Prop. 2.2.3).  All linear algebra is exact over Q.

This is the number-field twin of bruhat_tits.py: the same P^1(A/n) bookkeeping, with the
tree replaced by the upper half-plane.  It is an automorphic oracle independent of the Brandt
matrices, so at prime level the two must agree.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cache, cached_property
from math import gcd

import sympy as sp


def _phi(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def _prime_factors(n: int) -> list[int]:
    out, d = [], 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1
    return out + ([n] if n > 1 else [])


def _kron(a: int, p: int) -> int:
    if p == 2:
        return 0 if a % 2 == 0 else (1 if a % 8 in (1, 7) else -1)
    r = pow(a % p, (p - 1) // 2, p)
    return 0 if r == 0 else (1 if r == 1 else -1)


def genus_X0(N: int) -> int:
    ps = _prime_factors(N)
    mu = N
    for p in ps:
        mu = mu * (p + 1) // p
    nu2 = 0 if N % 4 == 0 else _prod(1 + (0 if p == 2 else _kron(-1, p)) for p in ps)  # Kronecker (-4/p)
    nu3 = 0 if N % 9 == 0 else _prod(1 + _kron(-3, p) for p in ps)
    c = sum(_phi(gcd(d, N // d)) for d in range(1, N + 1) if N % d == 0)
    g12 = 12 + mu - 3 * nu2 - 4 * nu3 - 6 * c
    assert g12 % 12 == 0
    return g12 // 12


def _prod(it):
    out = 1
    for x in it:
        out *= x
    return out


def cusp_count(N: int) -> int:
    return sum(_phi(gcd(d, N // d)) for d in range(1, N + 1) if N % d == 0)


# ------------------------------------------------------------------ cusps --
def cusps_equivalent(N: int, c1: tuple[int, int], c2: tuple[int, int]) -> bool:
    """p1/q1 ~ p2/q2 under Gamma_0(N) iff s1 q2 = s2 q1 (mod gcd(q1 q2, N)), p_i s_i = 1 (mod q_i)."""
    (p1, q1), (p2, q2) = c1, c2
    s1 = pow(p1, -1, q1) if q1 > 1 else 0
    s2 = pow(p2, -1, q2) if q2 > 1 else 0
    m = gcd(q1 * q2, N)
    return (s1 * q2 - s2 * q1) % m == 0


def normalize_cusp(p: int, q: int) -> tuple[int, int]:
    if q == 0:
        return (1, 0)
    g = gcd(p, q)
    p, q = p // g, q // g
    if q < 0:
        p, q = -p, -q
    return (p % q if q > 1 else 0, q)


# --------------------------------------------------------- Manin symbols --
@dataclass(frozen=True)
class ManinSymbols:
    N: int

    @cached_property
    def points(self) -> tuple[tuple[int, int], ...]:
        pts = set()
        for c in range(self.N):
            for d in range(self.N):
                if gcd(gcd(c, d), self.N) == 1:
                    pts.add(self.canonical(c, d))
        return tuple(sorted(pts))

    @cache
    def canonical(self, c: int, d: int) -> tuple[int, int]:
        N = self.N
        if N == 1:
            return (0, 0)
        c, d = c % N, d % N
        best = None
        for u in range(1, N):
            if gcd(u, N) != 1:
                continue
            cand = (u * c % N, u * d % N)
            if best is None or cand < best:
                best = cand
        return best

    @cached_property
    def index(self) -> dict:
        return {x: i for i, x in enumerate(self.points)}

    def act(self, x: tuple[int, int], g: tuple[int, int, int, int]) -> tuple[int, int] | None:
        """(c : d) . g, or None when the image is not in P^1(Z/N) (only for det g not prime to N;
        such terms are dropped from the Hecke action, as in Merel / Cremona)."""
        a, b, c2, d2 = g
        c, d = x
        u, v = (c * a + d * c2) % self.N, (c * b + d * d2) % self.N
        if gcd(gcd(u, v), self.N) != 1:
            return None
        return self.canonical(u, v)

    @cached_property
    def relations(self) -> sp.Matrix:
        n = len(self.points)
        rows = []
        S, T, T2 = (0, -1, 1, 0), (0, -1, 1, -1), (-1, 1, -1, 0)
        for x in self.points:
            r = [0] * n
            r[self.index[x]] += 1
            r[self.index[self.act(x, S)]] += 1
            rows.append(r)
            r = [0] * n
            r[self.index[x]] += 1
            r[self.index[self.act(x, T)]] += 1
            r[self.index[self.act(x, T2)]] += 1
            rows.append(r)
        return sp.Matrix(rows)

    @cached_property
    def _rref(self):
        R, pivots = self.relations.rref()
        free = [j for j in range(R.cols) if j not in pivots]
        return R, pivots, free

    def reduce(self, v: sp.Matrix) -> sp.Matrix:
        """Coordinates of v (a row vector over the generators) in the quotient basis (free columns)."""
        R, pivots, free = self._rref
        v = v.copy()
        for i, j in enumerate(pivots):
            if v[j] != 0:
                v = v - v[j] * R.row(i)
        return sp.Matrix([v[j] for j in free])

    @property
    def dimension(self) -> int:
        return len(self._rref[2])

    def _unit_vector(self, x) -> sp.Matrix:
        v = sp.zeros(1, len(self.points))
        v[self.index[x]] = 1
        return v

    # ---------------------------------------------------------- boundary --
    @cached_property
    def cusps(self) -> list[tuple[int, int]]:
        reps: list[tuple[int, int]] = []
        for c, d in self.points:
            for cusp in self._boundary_cusps(c, d):
                if not any(cusps_equivalent(self.N, cusp, r) for r in reps):
                    reps.append(cusp)
        assert len(reps) == cusp_count(self.N)
        return reps

    def _lift(self, c: int, d: int) -> tuple[int, int, int, int]:
        """[[a, b], [c', d']] in SL_2(Z) with (c', d') = (c, d) mod N."""
        N = self.N
        for k in range(N + 1):
            d2 = d + k * N
            c2 = c if c else N
            if gcd(c2, d2) == 1:
                g, x, y = _xgcd(d2, c2)  # x d2 + y c2 = 1  ->  a = x, b = -y
                return (x, -y, c2, d2)
        raise AssertionError("no coprime lift")

    def _boundary_cusps(self, c: int, d: int) -> tuple[tuple[int, int], tuple[int, int]]:
        a, b, c2, d2 = self._lift(c, d)
        return normalize_cusp(a, c2), normalize_cusp(b, d2)  # {b/d, a/c}: boundary = [a/c] - [b/d]

    def _cusp_index(self, cusp) -> int:
        return next(i for i, r in enumerate(self.cusps) if cusps_equivalent(self.N, cusp, r))

    @cached_property
    def boundary_matrix(self) -> sp.Matrix:
        """delta on the quotient basis: rows = cusps, columns = free generators."""
        _, _, free = self._rref
        M = sp.zeros(len(self.cusps), len(free))
        for j, gi in enumerate(free):
            c, d = self.points[gi]
            top, bottom = self._boundary_cusps(c, d)
            M[self._cusp_index(top), j] += 1
            M[self._cusp_index(bottom), j] -= 1
        return M

    @cached_property
    def cuspidal_basis(self) -> sp.Matrix:
        ns = self.boundary_matrix.nullspace()
        return sp.Matrix.hstack(*ns) if ns else sp.zeros(self.dimension, 0)

    # ------------------------------------------------------------- Hecke --
    @staticmethod
    def heilbronn(n: int) -> tuple[tuple[int, int, int, int], ...]:
        """Merel's set: ad - bc = n, a > b >= 0, d > c >= 0."""
        out = []
        for a in range(1, n + 1):
            for d in range(1, n + 1):
                for b in range(a):
                    for c in range(d):
                        if a * d - b * c == n:
                            out.append((a, b, c, d))
        return tuple(out)

    @cache
    def hecke_matrix(self, n: int) -> sp.Matrix:
        """T_n on the quotient (columns = images of the basis vectors)."""
        _, _, free = self._rref
        H = self.heilbronn(n)
        cols = []
        for gi in free:
            x = self.points[gi]
            v = sp.zeros(1, len(self.points))
            for h in H:
                y = self.act(x, h)
                if y is not None:
                    v[self.index[y]] += 1
            cols.append(self.reduce(v))
        return sp.Matrix.hstack(*cols)

    def cuspidal_hecke_matrix(self, n: int) -> sp.Matrix:
        B = self.cuspidal_basis
        if B.cols == 0:
            return sp.zeros(0, 0)
        TB = self.hecke_matrix(n) * B
        C = B.solve_least_squares(TB)
        if B * C != TB:
            raise AssertionError("T_n does not preserve the cuspidal subspace")
        return C

    def cuspidal_hecke_polynomial(self, n: int) -> sp.Poly:
        x = sp.Symbol("x")
        return sp.Poly(self.cuspidal_hecke_matrix(n).charpoly(x).as_expr(), x)


def _xgcd(a: int, b: int) -> tuple[int, int, int]:
    if b == 0:
        return (a, 1, 0) if a >= 0 else (-a, -1, 0)
    g, x, y = _xgcd(b, a % b)
    return g, y, x - (a // b) * y


# ------------------------------------------------------------- weight k --
def dim_S_k(N: int, k: int) -> int:
    """dim S_k(Gamma_0(N)) for even k >= 4 (Shimura 2.23): (k-1)(g-1) + [k/4] nu2 + [k/3] nu3 + (k/2 - 1) c."""
    if k == 2:
        return genus_X0(N)
    ps = _prime_factors(N)
    nu2 = 0 if N % 4 == 0 else _prod(1 + (0 if p == 2 else _kron(-1, p)) for p in ps)
    nu3 = 0 if N % 9 == 0 else _prod(1 + _kron(-3, p) for p in ps)
    c = cusp_count(N)
    return (k - 1) * (genus_X0(N) - 1) + (k // 4) * nu2 + (k // 3) * nu3 + (k // 2 - 1) * c


def _poly_act(P: tuple, g: tuple[int, int, int, int]) -> tuple:
    """(P|g)(X, Y) = P(aX + bY, cX + dY) for P = sum P[i] X^i Y^{m-i} (degree m = len(P) - 1)."""
    a, b, c, d = g
    m = len(P) - 1
    # powers of the two linear forms as coefficient tuples in X^j Y^{deg-j}
    def lin_pow(u, v, e):
        out = [1]
        for _ in range(e):
            nxt = [0] * (len(out) + 1)
            for j, x in enumerate(out):
                nxt[j + 1] += x * u  # times uX
                nxt[j] += x * v      # times vY
            out = nxt
        return out
    result = [0] * (m + 1)
    for i, coeff in enumerate(P):
        if coeff == 0:
            continue
        A = lin_pow(a, b, i)
        B = lin_pow(c, d, m - i)
        for j, x in enumerate(A):
            for l, y in enumerate(B):
                result[j + l] += coeff * x * y
    return tuple(result)


@dataclass(frozen=True)
class ManinSymbolsK:
    """Weight-k Manin symbols [X^i Y^{k-2-i}, (c : d)] for Gamma_0(N) (Stein, Modular Forms: A
    Computational Approach, ch. 8): relations [P, x] + [P|S, xS] = 0 and [P, x] + [P|T, xT] + [P|T^2, xT^2]
    = 0; T_n [P, x] = sum_{h in H_n} [P|h, x h] over Merel's Heilbronn matrices.  The cuspidal part is
    the kernel of the weight-k boundary map (below).  Note: taking the complement of the single
    Eisenstein eigenvalue sigma_{k-1}(ell) is wrong at non-squarefree N, where Eisenstein series with a
    character pair (chi, chi-bar) have eigenvalue chi(ell) + chi-bar(ell) ell^{k-1}."""

    N: int
    k: int

    @cached_property
    def base(self) -> ManinSymbols:
        return ManinSymbols(self.N)

    @cached_property
    def generators(self) -> tuple:
        return tuple((i, x) for x in self.base.points for i in range(self.k - 1))

    @cached_property
    def index(self) -> dict:
        return {g: j for j, g in enumerate(self.generators)}

    def _symbol_vector(self, P: tuple, x, v) -> None:
        """Add [P, x] to the row vector v in place (v indexed by generators)."""
        for i, coeff in enumerate(P):
            if coeff:
                v[self.index[(i, x)]] += coeff

    @cached_property
    def relations(self) -> sp.Matrix:
        n = len(self.generators)
        S, T, T2 = (0, -1, 1, 0), (0, -1, 1, -1), (-1, 1, -1, 0)
        rows = []
        for i, x in self.generators:
            P = tuple(1 if j == i else 0 for j in range(self.k - 1))
            r = [0] * n
            self._symbol_vector(P, x, r)
            self._symbol_vector(_poly_act(P, S), self.base.act(x, S), r)
            rows.append(r)
            r = [0] * n
            self._symbol_vector(P, x, r)
            self._symbol_vector(_poly_act(P, T), self.base.act(x, T), r)
            self._symbol_vector(_poly_act(P, T2), self.base.act(x, T2), r)
            rows.append(r)
        return sp.Matrix(rows)

    @cached_property
    def _rref(self):
        R, pivots = self.relations.rref()
        free = [j for j in range(R.cols) if j not in pivots]
        return R, pivots, free

    def reduce(self, v: sp.Matrix) -> sp.Matrix:
        R, pivots, free = self._rref
        v = v.copy()
        for i, j in enumerate(pivots):
            if v[j] != 0:
                v = v - v[j] * R.row(i)
        return sp.Matrix([v[j] for j in free])

    @property
    def dimension(self) -> int:
        return len(self._rref[2])

    @cache
    def hecke_matrix(self, n: int) -> sp.Matrix:
        _, _, free = self._rref
        H = ManinSymbols.heilbronn(n)
        cols = []
        for gi in free:
            i, x = self.generators[gi]
            P = tuple(1 if j == i else 0 for j in range(self.k - 1))
            v = sp.zeros(1, len(self.generators))
            for h in H:
                y = self.base.act(x, h)
                if y is not None:
                    self._symbol_vector(_poly_act(P, h), y, v)
            cols.append(self.reduce(v))
        return sp.Matrix.hstack(*cols)

    @cached_property
    def boundary_matrix(self) -> sp.Matrix:
        """Weight-k boundary map (Stein, Modular Forms: A Computational Approach, §8.6).  The Manin symbol
        [X^i Y^{k-2-i}, (c : d)] is g(X^i Y^{k-2-i}{0, oo}) for a lift g = [[a, b], [c, d]]; transporting
        the polynomial with g and evaluating at the cusps g(oo) = (1 : 0) and g(0) = (0 : 1) in the
        transported coordinates leaves [g oo] with coefficient [i = k-2] and [g 0] with [i = 0].
        (Chosen among the candidate conventions as the one whose kernel has dimension 2 dim S_k and is
        Hecke-stable at every level tested, squarefree or not.)"""
        _, _, free = self._rref
        cusps = self.base.cusps
        M = sp.zeros(len(cusps), len(free))
        for j, gi in enumerate(free):
            i, x = self.generators[gi]
            a, b, c, d = self.base._lift(*x)
            if i == self.k - 2:
                M[self.base._cusp_index(normalize_cusp(a, c)), j] += 1
            if i == 0:
                M[self.base._cusp_index(normalize_cusp(b, d)), j] -= 1
        return M

    @cached_property
    def cuspidal_basis(self) -> sp.Matrix:
        """Kernel of the boundary map: finitely supported (cuspidal) weight-k modular symbols."""
        ns = self.boundary_matrix.nullspace()
        return sp.Matrix.hstack(*ns) if ns else sp.zeros(self.dimension, 0)

    def cuspidal_hecke_matrix(self, n: int) -> sp.Matrix:
        B = self.cuspidal_basis
        if B.cols == 0:
            return sp.zeros(0, 0)
        TB = self.hecke_matrix(n) * B
        C = B.solve_least_squares(TB)
        if B * C != TB:
            raise AssertionError("T_n does not preserve the cuspidal subspace")
        return C
