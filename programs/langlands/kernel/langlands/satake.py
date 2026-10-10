"""Satake for PGL_2 on the Bruhat–Tits tree: the lattice-model side of `Satake.lean`.

Lean proves, for every q, the algebra of the Satake transform once the tree is described from an
end (`sphere` = the walk up the ray, then down) and the Hecke relation A_1 A_n = A_{n+1} + q A_{n-1}
is granted.  Here both inputs are computed on the tree of PGL_2(F_q((1/t))) (`bruhat_tits.Tree`),
whose Iwasawa coordinate k is the horocycle index of the end k -> -oo along the ray (k, 0) (the
unique neighbour with smaller k is the one toward that end; pi = 1/t), and the arithmetic
consequence is checked on Drinfeld eigenforms at a finite place p (residue field of size |p|): the T(p^n)-eigenvalues are h_n(alpha, beta) of the Satake parameter, and
alpha^n + beta^n = h_n - q h_{n-2} is the Frobenius trace that point counts over F_{q^n} measure.

Degree-n elements of Z[q][X^{+-1}] are tuples c with c[j] = coefficient of X^{n-2j}, as in Lean.
"""
from __future__ import annotations

from collections import Counter
from itertools import product

from .bruhat_tits import Tree, Vertex, standard_vertex
from .ec_function_field import FunctionFieldCurve, ReducedCurve
from .gf import GF

ORIGIN: Vertex = standard_vertex(0)


# ------------------------------------------------------------ closed forms --
def sat(q: int, n: int) -> tuple[int, ...]:
    """S(A_n) = X^n + sum_{0<j<n} (q-1) q^(j-1) X^(n-2j) + q^n X^(-n)."""
    return tuple(1 if j == 0 else (q - 1) * q ** (j - 1) if j < n else q**n for j in range(n + 1))


def chi(q: int, n: int) -> tuple[int, ...]:
    """chi_n = sum_j q^j X^(n-2j) = q^(n/2) tr Sym^n of SL_2 at diag(q^(-1/2) X, q^(1/2) X^(-1))."""
    return tuple(q**j for j in range(n + 1))


def h(alpha: int, beta: int, n: int) -> int:
    """h_n(alpha, beta) = sum_{i+j=n} alpha^i beta^j (h_{-1} = 0)."""
    return sum(alpha ** (n - j) * beta**j for j in range(n + 1)) if n >= 0 else 0


def hecke_eigenvalues(a: int, q: int, n_max: int) -> tuple[int, ...]:
    """T(p^n)-eigenvalues from T(p) = a: e_{n+1} = a e_n - q e_{n-1} (the q-twisted Clebsch–Gordan)."""
    e = [1, a]
    while len(e) <= n_max:
        e.append(a * e[-1] - q * e[-2])
    return tuple(e[: n_max + 1])


# ----------------------------------------------------------------- the tree --
def sphere(tree: Tree, v: Vertex, n: int) -> frozenset[Vertex]:
    """Vertices at distance exactly n from v (non-backtracking walk)."""
    frontier = {(None, v)}
    for _ in range(n):
        frontier = {(cur, w) for prev, cur in frontier for w in tree.neighbours(cur) if w != prev}
    return frozenset(cur for _, cur in frontier)


def horocycle_profile(q: int, n: int) -> tuple[int, ...]:
    """#{v : d(o, v) = n, height(v) = n - 2j} for j = 0..n; height = -k in the Iwasawa chart."""
    counts = Counter((n + v[0]) // 2 for v in sphere(Tree(q), ORIGIN, n))
    return tuple(counts[j] for j in range(n + 1))


def hecke_structure_constants(q: int, n: int) -> dict[int, set[int]]:
    """For A_1 A_n: distance d(o, u) -> the set of values #{w ~ o : d(w, u) = n} over u in the ball."""
    tree = Tree(q)
    spheres_n = {w: sphere(tree, w, n) for w in tree.neighbours(ORIGIN)}
    out: dict[int, set[int]] = {}
    for r in range(n + 2):
        for u in sphere(tree, ORIGIN, r):
            out.setdefault(r, set()).add(sum(u in s for s in spheres_n.values()))
    return out


def local_hecke_image(q: int, n: int) -> Counter:
    """{g v_0 : g in K diag(pi^a, pi^(n-a)) K / K, 0 <= a <= n} with pi = 1/t, K = GL_2(O_oo): the
    representatives [[pi^a, b], [0, pi^(n-a)]], b in O_oo / pi^a (column Hermite form), as a multiset."""
    tree = Tree(q)
    pi = lambda e: {e: 1}  # noqa: E731  (Laurent dicts are keyed by exponents of pi = 1/t)
    return Counter(
        tree.vertex_of_matrix(((pi(a), {i: c for i, c in enumerate(bs) if c}), ({}, pi(n - a))))
        for a in range(n + 1) for bs in product(range(q), repeat=a)
    )


# ----------------------------------------------------------- Frobenius side --
def frobenius_power_trace(E: FunctionFieldCurve, prime: tuple[int, ...], n: int) -> int:
    """alpha^n + beta^n = |F|^n + 1 - #E(F_n), F = A/p and F_n its degree-n extension (point count)."""
    d = len(prime) - 1
    K = GF.of_order(E.p, d * n)
    theta = K.poly_roots(tuple(K.from_int(c) for c in prime))[0][0]  # A/p embedded in F_n
    coeffs = tuple(K.eval_poly(tuple(K.from_int(c) for c in ai), theta) for ai in E.a)
    return K.order + 1 - ReducedCurve(K, coeffs).point_count()
