"""Pseudocharacters of finite groups and the search for a representation with a given trace.

A 2-dimensional pseudocharacter of a finite group G with values in F_p (p > 2) is T : G -> F_p with
T(1) = 2, T(xy) = T(yx) and the Frobenius-Procesi identity
    T(x)T(y)T(z) + T(xyz) + T(xzy) = T(xy)T(z) + T(xz)T(y) + T(yz)T(x).
Taylor: every such T is the trace of a semisimple 2-dimensional representation over F_p-bar (over F_p
itself for a finite group, finite fields having trivial Brauer group).  For a finite G this is a
finite search: det is determined by T (det g = (T(g)^2 - T(g^2))/2), the images of a generating
pair (g0, h0) range over the matrices with the prescribed (trace, det), and a candidate extends to
G along words in the generators iff the generator relations rho(x g) = rho(x) rho(g) hold on all of
G.  `find_representation` performs the search; the same search runs in the Lean kernel
(proof/langlands/LanglandsOracles/PseudocharSearch.lean).

`rouquier_representation` is the search-free construction PROVED for every group in
proof/langlands/LanglandsOracles/PseudocharRep.lean: from an element g whose characteristic polynomial
X^2 - T(g) X + det(g) has distinct roots lam, mu in F_p, put e = kappa (g - mu), f = -kappa (g - lam) in the
group ring (kappa = 1/(lam - mu)); then a(x) = tr(e x), B(x, y) = tr(e x f y), and
rho(x) = [[a(x), B(x, y0)], [B(x0, x) / B(x0, y0), T(x) - a(x)]] for any x0, y0 with B(x0, y0) != 0.
"""
from __future__ import annotations

from collections.abc import Callable, Sequence
from itertools import product

Mat = tuple[int, int, int, int]


def gl2(p: int) -> list[Mat]:
    return [m for m in product(range(p), repeat=4) if (m[0] * m[3] - m[1] * m[2]) % p]


def mat_mul(x: Mat, y: Mat, p: int) -> Mat:
    return ((x[0] * y[0] + x[1] * y[2]) % p, (x[0] * y[1] + x[1] * y[3]) % p,
            (x[2] * y[0] + x[3] * y[2]) % p, (x[2] * y[1] + x[3] * y[3]) % p)


def trace(m: Mat, p: int) -> int:
    return (m[0] + m[3]) % p


def det(m: Mat, p: int) -> int:
    return (m[0] * m[3] - m[1] * m[2]) % p


def is_pseudocharacter(T: Callable, G: Sequence, mul: Callable, one, p: int) -> bool:
    """T(1) = 2, centrality and the Procesi identity on all triples (exhaustive)."""
    if T(one) % p != 2 % p:
        return False
    if any((T(mul(x, y)) - T(mul(y, x))) % p for x in G for y in G):
        return False
    return all(
        (T(x) * T(y) * T(z) + T(mul(mul(x, y), z)) + T(mul(mul(x, z), y))
         - T(mul(x, y)) * T(z) - T(mul(x, z)) * T(y) - T(mul(y, z)) * T(x)) % p == 0
        for x in G for y in G for z in G)


def determinant_of_pseudocharacter(T: Callable, mul: Callable, p: int) -> Callable:
    """det g = (T(g)^2 - T(g^2)) / 2 (p odd)."""
    half = pow(2, -1, p)
    return lambda g: ((T(g) ** 2 - T(mul(g, g))) * half) % p


def _extend(gens_images: list[tuple], mul: Callable, one, p: int, G: Sequence) -> dict | None:
    """rho on <gens> by breadth-first words; None if the generator relations fail somewhere or <gens> != G."""
    rho = {one: (1, 0, 0, 1)}
    frontier = [one]
    while frontier:
        new = []
        for x in frontier:
            for g, img in gens_images:
                y = mul(x, g)
                if y not in rho:
                    rho[y] = mat_mul(rho[x], img, p)
                    new.append(y)
        frontier = new
    if len(rho) != len(G):
        return None
    ok = all(rho[mul(x, g)] == mat_mul(rho[x], img, p) for x in G for g, img in gens_images)
    return rho if ok else None


def find_representation(T: Callable, G: Sequence, mul: Callable, one, gens: Sequence, p: int) -> dict | None:
    """A representation rho : G -> GL_2(F_p) with tr rho = T, or None; gens must generate G."""
    D = determinant_of_pseudocharacter(T, mul, p)
    cands = [[m for m in gl2(p) if trace(m, p) == T(g) % p and det(m, p) == D(g)] for g in gens]
    for images in product(*cands):
        rho = _extend(list(zip(gens, images)), mul, one, p, G)
        if rho is not None and all(trace(rho[x], p) == T(x) % p for x in G):
            return rho
    return None


def find_all_representations(T: Callable, G: Sequence, mul: Callable, one, gens: Sequence, p: int) -> list[dict]:
    """Every generator assignment that extends to a representation with trace T."""
    D = determinant_of_pseudocharacter(T, mul, p)
    cands = [[m for m in gl2(p) if trace(m, p) == T(g) % p and det(m, p) == D(g)] for g in gens]
    found = []
    for images in product(*cands):
        rho = _extend(list(zip(gens, images)), mul, one, p, G)
        if rho is not None and all(trace(rho[x], p) == T(x) % p for x in G):
            found.append(rho)
    return found


def mat_inv(c: Mat, p: int) -> Mat:
    u = pow(det(c, p), -1, p)
    return tuple((u * e) % p for e in (c[3], -c[1], -c[2], c[0]))


def are_conjugate(rho1: dict, rho2: dict, G: Sequence, p: int) -> bool:
    """Some c in GL_2(F_p) with c rho1(g) c^-1 = rho2(g) for all g."""
    return any(all(mat_mul(mat_mul(c, rho1[g], p), mat_inv(c, p), p) == rho2[g] for g in G) for c in gl2(p))


def is_homomorphism(rho: dict, G: Sequence, mul: Callable, p: int) -> bool:
    return all(rho[mul(x, y)] == mat_mul(rho[x], rho[y], p) for x in G for y in G)


def rouquier_entries(T: Callable, mul: Callable, g, lam: int, mu: int, p: int):
    """a(x) = tr(e x) and B(x, y) = tr(e x f y), expanded in values of T (e = kappa(g - mu), f = -kappa(g - lam))."""
    kap = pow((lam - mu) % p, -1, p)
    a = lambda x: (kap * (T(mul(g, x)) - mu * T(x))) % p
    B = lambda x, y: (kap * kap * (-T(mul(mul(mul(g, x), g), y)) + lam * T(mul(mul(g, x), y))
                                   + mu * T(mul(mul(x, g), y)) - lam * mu * T(mul(x, y)))) % p
    return a, B


def rouquier_representation(T: Callable, mul: Callable, g, lam: int, mu: int, x0, y0, p: int) -> Callable | None:
    """rho built from T alone, or None when a hypothesis of `pseudochar_rep` fails: lam + mu = T(g),
    lam mu = det(g) (the pseudocharacter's), lam != mu, B(x0, y0) != 0; p odd."""
    D = determinant_of_pseudocharacter(T, mul, p)
    if (lam + mu - T(g)) % p or (lam * mu - D(g)) % p or (lam - mu) % p == 0:
        return None
    a, B = rouquier_entries(T, mul, g, lam, mu, p)
    u = B(x0, y0)
    if u == 0:
        return None
    uinv = pow(u, -1, p)
    return lambda x: (a(x), B(x, y0), (B(x0, x) * uinv) % p, (T(x) - a(x)) % p)


def rouquier_data(T: Callable, G: Sequence, mul: Callable, p: int):
    """Some (g, lam, mu, x0, y0) meeting the hypotheses of `rouquier_representation`, or None (absolutely
    reducible, or no element of G with distinct eigenvalues in F_p)."""
    D = determinant_of_pseudocharacter(T, mul, p)
    for g in G:
        roots = [r for r in range(p) if (r * r - T(g) * r + D(g)) % p == 0]
        if len(roots) == 2:
            lam, mu = roots
            _, B = rouquier_entries(T, mul, g, lam, mu, p)
            for x0 in G:
                for y0 in G:
                    if B(x0, y0):
                        return g, lam, mu, x0, y0
    return None
