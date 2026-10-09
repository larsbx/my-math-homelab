"""The Bruhat–Tits tree of PGL_2(F_q((1/t))), GL_2(F_q[t]) reduction, and Gamma_0(n)\\T.

Vertices: (k, u) with k in Z and u in K_oo / pi^k O_oo, the class of the lattice with basis
(pi^k, 0), (u, 1); the standard vertices v_n = (-n, 0) = [O + pi^n O] (n >= 0).
Neighbours: up (k-1, u mod pi^{k-1}) and down (k+1, u + a pi^k), a in F_q: (q+1)-regular.
GL_2(K_oo) acts by g -> gamma g followed by the Iwasawa normal form.

Reduction (Euclid): translate away the polynomial part of u, then apply w = [[0,1],[1,0]]
(which inverts u and lowers k by 2 v(u)); this terminates at some (k, 0) ~ v_|k|.  It exhibits
Serre's theorem GL_2(A)\\T = the half-line v_0 - v_1 - v_2 - ... with
   Stab(v_0) = GL_2(F_q),   Stab(v_n) = {[[a, b], [0, d]] : a, d in F_q^x, deg b <= n} (n >= 1),
the automorphism groups of O + O and O + O(n) on P^1 (Weil's dictionary).

Level: Gamma_0(n)\\Gamma = P^1(A/n) via the bottom row, so vertices of Gamma_0(n)\\T over v_m
are the Stab(v_m)-orbits on P^1(A/n); an oriented tree edge is labelled by reducing its
origin.  Harmonic cochains, cusp forms and Hecke operators T_p are then finite linear algebra.
"""
from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from functools import cache, cached_property
from itertools import product

from . import local_field as lf
from .ec_function_field import _ppow
from .gf import poly_divmod, poly_mod, poly_mul, poly_sub, poly_add, _trim

Vertex = tuple[int, tuple[tuple[int, int], ...]]  # (k, sorted nonzero (exponent, coeff) with exponent < k)
Mat = tuple[tuple[dict, dict], tuple[dict, dict]]  # 2x2 over K_oo (Laurent dicts)
APoly = tuple[int, ...]


def vertex(k: int, u: lf.Laurent) -> Vertex:
    return (k, tuple(sorted((e, c) for e, c in u.items() if e < k and c)))


def u_of(v: Vertex) -> dict[int, int]:
    return dict(v[1])


def standard_vertex(n: int) -> Vertex:
    return (-n, ())


@dataclass(frozen=True)
class Tree:
    q: int  # prime

    def neighbours(self, v: Vertex) -> tuple[Vertex, ...]:
        k, u = v[0], u_of(v)
        up = vertex(k - 1, u)
        downs = tuple(vertex(k + 1, lf.add(u, {k: a}, self.q) if a else u) for a in range(self.q))
        return (up, *downs)

    # ---------------------------------------------------------------- action --
    def vertex_of_matrix(self, M: Mat) -> Vertex:
        """Class of M in GL_2(K_oo) / K_oo^x GL_2(O_oo) as (k, u)."""
        (a, b), (c, d) = M
        det = lf.add(lf.mul(a, d, self.q), lf.neg(lf.mul(b, c, self.q), self.q), self.q)
        vdet = lf.valuation(det)
        vc, vd = lf.valuation(c), lf.valuation(d)
        if vc is None or (vd is not None and vc >= vd):  # column 2 has the smaller valuation in the bottom row
            k = vdet - 2 * vd
            u = lf.div(b, d, self.q, k)
        else:
            k = vdet - 2 * vc
            u = lf.div(a, c, self.q, k)
        return vertex(k, u)

    def matrix_of_vertex(self, v: Vertex) -> Mat:
        k, u = v[0], u_of(v)
        return (({k: 1}, u), ({}, {0: 1}))

    def act(self, gamma: Mat, v: Vertex) -> Vertex:
        return self.vertex_of_matrix(mat_mul(gamma, self.matrix_of_vertex(v), self.q))

    # ------------------------------------------------------------- reduction --
    def reduce(self, v: Vertex) -> tuple[int, Mat]:
        """(n, gamma) with gamma in GL_2(A) and gamma v = v_n, by the continued-fraction loop."""
        q = self.q
        k, u = v[0], u_of(v)
        gamma = identity()
        while True:
            poly = lf.polynomial_part(u)
            if poly:
                tau = (({0: 1}, lf.neg(poly, q)), ({}, {0: 1}))
                gamma, u = mat_mul(tau, gamma, q), lf.truncate(lf.add(u, lf.neg(poly, q), q), k)
            if not u:
                if k > 0:  # (k, 0) ~ (-k, 0) via w
                    gamma = mat_mul(W, gamma, q)
                    k = -k
                n = -k
                if self.act(gamma, v) != standard_vertex(n):
                    raise AssertionError("reduction produced a wrong matrix")
                return n, gamma
            m = lf.valuation(u)  # 1 <= m < k
            gamma = mat_mul(W, gamma, q)
            k, u = k - 2 * m, lf.truncate(lf.div({0: 1}, u, q, k - 2 * m), k - 2 * m)

    def stabilizer_elements(self, n: int, modulus: APoly | None = None) -> tuple[Mat, ...]:
        """Stab(v_n) in GL_2(A) (for n >= 1 with deg b <= n; reduce b modulo `modulus` when given,
        since only b mod n matters for the action on P^1(A/n))."""
        q = self.q
        units = range(1, q)
        const = lambda x: {0: x} if x else {}  # noqa: E731
        if n == 0:
            return tuple(
                ((const(a), const(b)), (const(c), const(d)))
                for a, b, c, d in product(range(q), repeat=4)
                if (a * d - b * c) % q
            )
        deg = n if modulus is None else min(n, len(modulus) - 2)
        bs = {tuple(x) for x in product(range(q), repeat=deg + 1)}
        return tuple(
            (({0: a}, lf.from_poly(b, q)), ({}, {0: d}))
            for a in units for d in units for b in sorted(bs)
        )


W: Mat = (({}, {0: 1}), ({0: 1}, {}))


def identity() -> Mat:
    return (({0: 1}, {}), ({}, {0: 1}))


def mat_mul(A: Mat, B: Mat, p: int) -> Mat:
    (a, b), (c, d) = A
    (e, f), (g, h) = B
    m = lambda x, y: lf.mul(x, y, p)  # noqa: E731
    s = lambda x, y: lf.add(x, y, p)  # noqa: E731
    return ((s(m(a, e), m(b, g)), s(m(a, f), m(b, h))), (s(m(c, e), m(d, g)), s(m(c, f), m(d, h))))


def mat_from_polys(a: APoly, b: APoly, c: APoly, d: APoly, p: int) -> Mat:
    return ((lf.from_poly(a, p), lf.from_poly(b, p)), (lf.from_poly(c, p), lf.from_poly(d, p)))


def bottom_row_polys(M: Mat, p: int) -> tuple[APoly, APoly]:
    return lf.to_poly(M[1][0], p), lf.to_poly(M[1][1], p)


def inverse_bottom_row(M: Mat, p: int) -> tuple[APoly, APoly]:
    """Bottom row of M^{-1} up to the unit det: (-c, a)."""
    (a, _), (c, _) = M
    return lf.to_poly(lf.neg(c, p), p), lf.to_poly(a, p)


# ------------------------------------------------------------ P^1(A / n) ----
@dataclass(frozen=True)
class ProjectiveLine:
    """P^1(A/n) with canonical representatives, and the right action of 2x2 matrices over A."""

    p: int
    modulus: APoly  # monic

    @cached_property
    def residues(self) -> tuple[APoly, ...]:
        d = len(self.modulus) - 1
        return tuple(_trim(tuple(x)) for x in product(range(self.p), repeat=d))

    def _units(self) -> tuple[APoly, ...]:
        return tuple(r for r in self.residues if len(poly_gcd_(r, self.modulus, self.p)) == 1)

    @cache
    def canonical(self, c: APoly, d: APoly) -> tuple[APoly, APoly]:
        """Canonical representative of (c : d) mod n: (1 : d/c) if c is a unit, else (c/d : 1) if d is,
        else (composite n only) the lexicographically least unit scaling."""
        p, m = self.p, self.modulus
        c, d = poly_mod(c, m, p), poly_mod(d, m, p)
        for first, second, swap in ((c, d, False), (d, c, True)):
            g, x, _ = poly_xgcd(first, m, p)
            if len(g) == 1:  # x * first = 1 mod m
                other = poly_mod(poly_mul(x, second, p), m, p)
                return ((1,), other) if not swap else (other, (1,))
        best = None
        for s in self.units:
            cs, ds = poly_mod(poly_mul(s, c, self.p), self.modulus, self.p), poly_mod(poly_mul(s, d, self.p), self.modulus, self.p)
            cand = (cs, ds)
            if best is None or cand < best:
                best = cand
        return best

    @cached_property
    def units(self) -> tuple[APoly, ...]:
        return self._units()

    @cached_property
    def points(self) -> tuple[tuple[APoly, APoly], ...]:
        pts = set()
        for c in self.residues:
            for d in self.residues:
                if len(poly_gcd_(poly_gcd_(c, d, self.p), self.modulus, self.p)) == 1:
                    pts.add(self.canonical(c, d))
        return tuple(sorted(pts))

    def act_right(self, point: tuple[APoly, APoly], M: Mat) -> tuple[APoly, APoly]:
        """(c : d) . M = bottom row of [[*, *], [c, d]] . M."""
        (a, b), (c2, d2) = M
        c, d = point
        p = self.p
        A, B, C, D = (lf.to_poly(x, p) for x in (a, b, c2, d2))
        return self.canonical(poly_add(poly_mul(c, A, p), poly_mul(d, C, p), p), poly_add(poly_mul(c, B, p), poly_mul(d, D, p), p))


def poly_gcd_(a: APoly, b: APoly, p: int) -> APoly:
    from .gf import poly_gcd
    g = poly_gcd(a, b, p)
    return g if g else ()


# ------------------------------------------------------------ Gamma_0(n) ----
def poly_xgcd(a: APoly, b: APoly, p: int) -> tuple[APoly, APoly, APoly]:
    """(g, x, y) with x a + y b = g monic = gcd(a, b)."""
    r0, r1 = _trim(a), _trim(b)
    x0, x1, y0, y1 = (1,), (), (), (1,)
    while r1:
        qt, r = poly_divmod(r0, r1, p)
        r0, r1 = r1, r
        x0, x1 = x1, poly_sub(x0, poly_mul(qt, x1, p), p)
        y0, y1 = y1, poly_sub(y0, poly_mul(qt, y1, p), p)
    if not r0:
        return (), x0, y0
    inv = pow(r0[-1], -1, p)
    sc = lambda f: _trim(tuple(c * inv % p for c in f))  # noqa: E731
    return sc(r0), sc(x0), sc(y0)


def _polys_of_degree_below(p: int, d: int):
    return (_trim(tuple(x)) for x in product(range(p), repeat=d))


def hecke_representatives(q: int, prime: APoly, power: int = 1) -> tuple[Mat, ...]:
    """Coset representatives of T(p^power): [[p^a, b], [0, p^(power-a)]] for 0 <= a <= power, b mod p^(power-a)
    (every ad = p^power, non-primitive ones included).  For power = 1: [[1, b], [0, p]] and [[p, 0], [0, 1]]."""
    d = len(prime) - 1
    pw = lambda e: _ppow(prime, e, q)  # noqa: E731
    return tuple(
        mat_from_polys(pw(a), b, (), pw(power - a), q)
        for a in range(power + 1) for b in _polys_of_degree_below(q, d * (power - a))
    )


@dataclass(frozen=True)
class Gamma0Quotient:
    """Gamma_0(n)\\T truncated at `depth` (cusp rays beyond), with harmonic cochains and Hecke operators."""

    q: int
    modulus: APoly
    depth: int

    @cached_property
    def tree(self) -> Tree:
        return Tree(self.q)

    @cached_property
    def line(self) -> ProjectiveLine:
        return ProjectiveLine(self.q, self.modulus)

    # -- orbits of P^1(A/n) under vertex / edge stabilizers --
    @cache
    def _orbit_canon(self, n: int, edge: bool) -> dict:
        group = self.tree.stabilizer_elements(n, self.modulus)
        if edge and n == 0:  # Stab(e_0) = B(F_q)
            group = tuple(g for g in group if not g[1][0])
        canon = {}
        for pt in self.line.points:
            if pt in canon:
                continue
            orbit = {self.line.act_right(pt, g) for g in group}
            rep = min(orbit)
            for x in orbit:
                canon[x] = rep
        return canon

    def vertex_label(self, v: Vertex):
        n, gamma = self.tree.reduce(v)
        pt = self.line.canonical(*inverse_bottom_row(gamma, self.q))
        return (n, self._orbit_canon(n, False)[pt])

    @cache
    def _gl2_fixing_v0_sending(self, a: int) -> Mat:
        """h in GL_2(F_q) with h (1, a) = v_1 (and h v_0 = v_0)."""
        target, source = standard_vertex(1), vertex(1, {0: a} if a else {})
        for g in self.tree.stabilizer_elements(0):
            if self.tree.act(g, source) == target:
                return g
        raise AssertionError("GL_2(F_q) is transitive on the neighbours of v_0")

    def edge_label(self, x: Vertex, y: Vertex):
        """Label (n, sign, orbit point) of the oriented edge x -> y: sign + for v_n -> v_{n+1}."""
        n, gamma = self.tree.reduce(x)
        y2 = self.tree.act(gamma, y)
        if y2 == standard_vertex(n + 1):
            pt = self.line.canonical(*inverse_bottom_row(gamma, self.q))
            return (n, 1, self._orbit_canon(n, True)[pt])
        if n == 0:
            h = self._gl2_fixing_v0_sending(u_of(y2).get(0, 0))
            gamma2 = mat_mul(h, gamma, self.q)
            if self.tree.act(gamma2, y) != standard_vertex(1):
                raise AssertionError
            pt = self.line.canonical(*inverse_bottom_row(gamma2, self.q))
            return (0, 1, self._orbit_canon(0, True)[pt])  # every neighbour of v_0 is ~ v_1: the edge is v_0 -> v_1
        a = u_of(y2).get(-n, 0)
        tau = (({0: 1}, lf.from_poly((0,) * n + ((-a) % self.q,), self.q)), ({}, {0: 1}))
        gamma2 = mat_mul(tau, gamma, self.q)
        if self.tree.act(gamma2, y) != standard_vertex(n - 1):
            raise AssertionError
        pt = self.line.canonical(*inverse_bottom_row(gamma2, self.q))
        return (n - 1, -1, self._orbit_canon(n - 1, True)[pt])

    # -- representatives --
    def representative(self, n: int, pt: tuple[APoly, APoly]) -> Vertex:
        """A tree vertex x = M v_n with M in GL_2(A) whose bottom row is a coprime lift of pt."""
        p, m = self.q, self.modulus
        c, d = pt
        for s in _polys_of_degree_below(p, len(m)):
            d2 = poly_add(d, poly_mul(m, s, p), p)
            c2 = c if c else m
            g, x, y = poly_xgcd(c2, d2, p)
            if len(g) == 1:  # x c2 + y d2 = 1  ->  a = y, b = -x
                M = mat_from_polys(y, tuple((-v) % p for v in x), c2, d2, p)
                v = self.tree.act(M, standard_vertex(n))
                if self.vertex_label(v) != (n, self._orbit_canon(n, False)[self.line.canonical(c, d)]):
                    raise AssertionError("representative has the wrong label")
                return v
        raise AssertionError("no coprime lift found")

    @cached_property
    def vertices(self) -> tuple:
        return tuple((n, pt) for n in range(self.depth + 1) for pt in sorted(set(self._orbit_canon(n, False).values())))

    @cached_property
    def stars(self) -> dict:
        """quotient vertex -> list of oriented edge labels of the q+1 tree edges at a representative."""
        out = {}
        for n, pt in self.vertices:
            x = self.representative(n, pt)
            out[(n, pt)] = [self.edge_label(x, y) for y in self.tree.neighbours(x)]
        return out

    @cached_property
    def edge_variables(self) -> tuple:
        """Positive-oriented quotient edges (n, +, pt) with n < depth; the unknowns of a cochain."""
        return tuple(sorted({(n, pt) for star in self.stars.values() for (n, s, pt) in star if n < self.depth}))

    def _coordinate(self, label) -> tuple[int, int] | None:
        n, s, pt = label
        if n >= self.depth:
            return None  # beyond the truncation: cusp forms vanish there
        return self.edge_variables.index((n, pt)), s

    @cached_property
    def harmonicity_matrix(self):
        import sympy as sp
        rows = []
        for v, star in self.stars.items():
            row = [0] * len(self.edge_variables)
            for label in star:
                co = self._coordinate(label)
                if co is not None:
                    row[co[0]] += co[1]
            rows.append(row)
        return sp.Matrix(rows)

    @cached_property
    def cusp_forms(self):
        """Basis of finitely supported Gamma_0(n)-invariant harmonic cochains (columns)."""
        import sympy as sp
        ns = self.harmonicity_matrix.nullspace()
        return sp.Matrix.hstack(*ns) if ns else sp.zeros(len(self.edge_variables), 0)

    @property
    def genus(self) -> int:
        return self.cusp_forms.cols

    # -- Hecke --
    def hecke_representatives(self, prime: APoly, power: int = 1) -> tuple[Mat, ...]:
        return hecke_representatives(self.q, prime, power)

    def _evaluate(self, F, label) -> Fraction:
        co = self._coordinate(label)
        return 0 if co is None else co[1] * F[co[0]]

    def hecke_matrix(self, prime: APoly, power: int = 1):
        """T(p^power) on the cusp-form space (matrix in the basis `cusp_forms`); asserts stability."""
        import sympy as sp
        reps = self.hecke_representatives(prime, power)
        basis = self.cusp_forms
        images = []
        rep_edges = {}
        for n, pt in self.edge_variables:  # a tree edge representing (n, +, pt)
            x = self.representative(n, pt)
            for y in self.tree.neighbours(x):
                if self.edge_label(x, y) == (n, 1, pt):
                    rep_edges[(n, pt)] = (x, y)
                    break
            else:
                raise AssertionError("representative star does not contain the edge")
        for j in range(basis.cols):
            F = basis.col(j)
            TF = []
            for key in self.edge_variables:
                x, y = rep_edges[key]
                TF.append(sum(self._evaluate(F, self.edge_label(self.tree.act(d, x), self.tree.act(d, y))) for d in reps))
            images.append(sp.Matrix(TF))
        TF_mat = sp.Matrix.hstack(*images) if images else sp.zeros(len(self.edge_variables), 0)
        # solve basis * C = TF_mat
        C = basis.solve_least_squares(TF_mat) if basis.cols else sp.zeros(0, 0)
        if basis.cols and basis * C != TF_mat:
            raise AssertionError("T_p does not preserve the cusp forms")
        return C


def common_eigenvector(matrices: dict, eigenvalues: dict):
    """A nonzero vector v with M_k v = lambda_k v for all k in `eigenvalues`, or None (sympy, exact)."""
    import sympy as sp
    n = next(iter(matrices.values())).rows
    stacked = sp.Matrix.vstack(*[matrices[k] - eigenvalues[k] * sp.eye(n) for k in eigenvalues])
    ns = stacked.nullspace()
    return ns[0] if ns else None
