"""Supersingular j-invariants in characteristic p > 3, exactly, in F_{p^2}.

Deuring: the Legendre curve y^2 = x(x-1)(x-lambda) is supersingular iff
H_p(lambda) = sum_{i=0}^{m} C(m,i)^2 lambda^i = 0, m = (p-1)/2.  Every supersingular
j lies in F_{p^2}; we find the roots of H_p there exhaustively and push to j.
"""
from __future__ import annotations

from math import comb

from .gf import GF, Poly


def field_p2(p: int) -> GF:
    return GF.of_order(p, 2)


def hasse_polynomial(p: int, F: GF) -> tuple[Poly, ...]:
    m = (p - 1) // 2
    return tuple(F.from_int(comb(m, i) ** 2) for i in range(m + 1))


def legendre_to_j(F: GF, lam: Poly) -> Poly:
    l2 = F.mul(lam, lam)
    num = F.pow(F.add(F.sub(l2, lam), F.one), 3)
    den = F.mul(l2, F.pow(F.sub(lam, F.one), 2))
    return F.div(F.scale(256, num), den)


def supersingular_j_invariants(p: int, F: GF | None = None) -> tuple[Poly, ...]:
    """Sorted tuple of the supersingular j in F_{p^2} (each once)."""
    if p <= 3:
        raise ValueError("p > 3 required")
    F = F or field_p2(p)
    lam_roots = F.poly_roots(hasse_polynomial(p, F))
    return tuple(sorted({legendre_to_j(F, lam) for lam, _ in lam_roots}))


def automorphism_count(F: GF, j: Poly) -> int:
    """|Aut(E)| for j(E) = j, p > 3: 6 at j = 0, 4 at j = 1728, else 2."""
    if j == F.zero:
        return 6
    if j == F.from_int(1728):
        return 4
    return 2
