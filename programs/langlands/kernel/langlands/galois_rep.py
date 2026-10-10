"""Mod-ell Galois representations of elliptic curves as computed matrices, and the Weil pairing.

For E/F_p with good reduction and a prime ell != p, E[ell] ≅ (Z/ell)^2 is defined over the
splitting field F_{p^k} (k = order of rho_ell(Frob_p) in GL_2(F_ell)).  We find E[ell] there,
choose a basis, and write Frob_p in it: the matrix rho_ell(Frob_p) ∈ GL_2(F_ell) up to
conjugacy.  Eichler–Shimura mod ell says tr = a_p and det = p (mod ell); both are checked.

The Weil pairing e_ell : E[ell] × E[ell] → mu_ell is computed by Miller's algorithm as
f_P(D_Q) / f_Q(D_P): it is the commutator pairing of the Poincaré biextension, and its Galois
equivariance e(Frob P, Frob Q) = e(P, Q)^p is the statement det rho_ell = cyclotomic character.
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import gcd

from .ec import Curve, Point
from .gf import GF, Poly
from .velu import division_polynomial

Mat = tuple[int, int, int, int]  # ((a, b), (c, d)) row-major


# ------------------------------------------------------------ torsion --
def _torsion_x_polynomial(E: Curve, ell: int) -> tuple[Poly, ...]:
    F = E.F
    return (E.b, E.a, F.zero, F.one) if ell == 2 else division_polynomial(E, ell)


def torsion_points(E: Curve, ell: int, max_degree: int = 24) -> tuple[Curve, tuple[Point, ...]]:
    """(E over the splitting field F_{p^k}, the ell^2 - 1 nonzero points of E[ell]), smallest k."""
    p = E.F.p
    if E.F.k != 1:
        raise ValueError("base curve must be over the prime field")
    for k in range(1, max_degree + 1):
        K = GF.of_order(p, k)
        EK = E.base_change(K)
        xs = K.poly_roots(tuple(K.from_int(E.F.to_int(c)) for c in _torsion_x_polynomial(E, ell)))
        if sum(m for _, m in xs) != (ell * ell - 1) // (1 if ell == 2 else 2):
            continue
        pts = []
        for x, _ in xs:
            ys = [y for y, _ in K.poly_roots((K.neg(EK.rhs(x)), K.zero, K.one))]
            pts += [(x, y) for y in ys]
        if len(pts) == ell * ell - 1:
            return EK, tuple(pts)
    raise ValueError("splitting field degree exceeds max_degree")


def _basis(EK: Curve, ell: int, pts: tuple[Point, ...]) -> tuple[Point, Point]:
    P = pts[0]
    span = {EK.mul(i, P) for i in range(ell)}
    Q = next(R for R in pts if R not in span)
    return P, Q


def _coordinates(EK: Curve, ell: int, P: Point, Q: Point, R: Point) -> tuple[int, int]:
    for a, b in product(range(ell), repeat=2):
        if EK.add(EK.mul(a, P), EK.mul(b, Q)) == R:
            return a, b
    raise ValueError("not in the span")


@dataclass(frozen=True)
class FrobeniusMatrix:
    ell: int
    splitting_degree: int
    matrix: Mat  # columns are the images of the basis: Frob P = a P + c Q, Frob Q = b P + d Q

    @property
    def trace(self) -> int:
        return (self.matrix[0] + self.matrix[3]) % self.ell

    @property
    def det(self) -> int:
        a, b, c, d = self.matrix
        return (a * d - b * c) % self.ell


def frobenius_matrix(E: Curve, ell: int) -> FrobeniusMatrix:
    EK, pts = torsion_points(E, ell)
    P, Q = _basis(EK, ell, pts)
    a, c = _coordinates(EK, ell, P, Q, EK.frobenius(P))
    b, d = _coordinates(EK, ell, P, Q, EK.frobenius(Q))
    return FrobeniusMatrix(ell, EK.F.k, (a, b, c, d))


# ------------------------------------------------------- Weil pairing --
def _line(EK: Curve, P: Point, Q: Point, X: Point) -> Poly:
    """Value at X of the line through P and Q (tangent if P = Q; vertical if P = -Q), X affine."""
    F = EK.F
    x, y = X
    if P is None or Q is None:
        return F.one
    (x1, y1), (x2, y2) = P, Q
    if x1 == x2:
        if y1 != y2 or y1 == F.zero:
            return F.sub(x, x1)  # vertical line
        lam = F.div(F.add(F.scale(3, F.mul(x1, x1)), EK.a), F.scale(2, y1))
    else:
        lam = F.div(F.sub(y2, y1), F.sub(x2, x1))
    return F.sub(F.sub(y, y1), F.mul(lam, F.sub(x, x1)))


def _vertical(EK: Curve, P: Point, X: Point) -> Poly:
    return EK.F.one if P is None else EK.F.sub(X[0], P[0])


def miller(EK: Curve, n: int, P: Point, X: Point) -> Poly:
    """f_{n,P}(X) with div f_{n,P} = n(P) - (nP) - (n-1)(O), by Miller's loop (X must avoid the support)."""
    F = EK.F
    f, T = F.one, P
    for bit in bin(n)[3:]:
        f = F.mul(F.mul(f, f), F.div(_line(EK, T, T, X), _vertical(EK, EK.add(T, T), X)))
        T = EK.add(T, T)
        if bit == "1":
            f = F.mul(f, F.div(_line(EK, T, P, X), _vertical(EK, EK.add(T, P), X)))
            T = EK.add(T, P)
    return f


def _affine_points(EK: Curve):
    """Deterministic stream of affine points of E(K) without enumerating E(K): x runs over K in a
    fixed order and y is a root of y^2 = x^3 + a x + b found by the generic root finder."""
    F = EK.F
    x = F.gen
    while True:
        for y, _ in F.poly_roots((F.neg(EK.rhs(x)), F.zero, F.one)):
            yield (x, y)
        x = F.add(F.mul(x, F.gen), F.one)  # x -> g x + 1 walks through K


def weil_pairing(EK: Curve, n: int, P: Point, Q: Point) -> Poly:
    """e_n(P, Q) = f_P(D_Q) / f_Q(D_P) with D_Q = (Q + S) - (S), D_P = (P + R) - (R) for auxiliary R, S
    chosen away from the supports (the Miller functions then have no zero or pole at the evaluation points)."""
    F = EK.F
    if P is None or Q is None:
        return F.one
    support = {None, P, Q, EK.add(P, Q), EK.neg(P), EK.neg(Q), EK.sub(P, Q), EK.sub(Q, P)}
    stream = _affine_points(EK)
    candidates = [next(stream) for _ in range(12)]
    for R in candidates:
        for S in candidates:
            if R == S or R in support or S in support or EK.add(Q, S) in support or EK.add(P, R) in support:
                continue
            try:
                num = F.div(miller(EK, n, P, EK.add(Q, S)), miller(EK, n, P, S))
                den = F.div(miller(EK, n, Q, EK.add(P, R)), miller(EK, n, Q, R))
                return F.div(num, den)
            except ZeroDivisionError:
                continue
    raise ValueError("no admissible auxiliary points")
