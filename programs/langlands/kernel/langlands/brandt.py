"""Brandt matrices as supersingular isogeny-graph adjacency (Pizer / Deuring / Eichler).

B(ell)_{ij} = #{cyclic C < E_i of order ell : E_i/C ≅ E_j}
            = multiplicity of j_j as a root of Phi_ell(j_i, Y)      (ell != p).

Row sums are ell + 1, and Aut-weighting makes B(ell) symmetrizable, so its
eigenvalues are real.  By Eichler / Jacquet–Langlands the eigenvalues of B(ell)
are ell + 1 (Eisenstein) together with the T_ell-eigenvalues a_ell(f) on
S_2(Gamma_0(p)).  Everything here is computed; that identification is what the
tests *check* against independent data, not something assumed.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cache, cached_property

import sympy as sp

from .gf import GF, Poly
from .modular_polynomial import MODULAR_POLYNOMIALS, phi_univariate
from .supersingular import automorphism_count, field_p2, supersingular_j_invariants
from .velu import VeluBrandt


@dataclass(frozen=True)
class SupersingularLocus:
    p: int
    F: GF
    j: tuple[Poly, ...]

    @staticmethod
    def of(p: int) -> "SupersingularLocus":
        F = field_p2(p)
        return SupersingularLocus(p, F, supersingular_j_invariants(p, F))

    @cached_property
    def index(self) -> dict[Poly, int]:
        return {j: i for i, j in enumerate(self.j)}

    @cached_property
    def aut_orders(self) -> tuple[int, ...]:
        return tuple(automorphism_count(self.F, j) for j in self.j)

    @cache
    def brandt_matrix(self, ell: int) -> sp.Matrix:
        """B(ell): via Phi_ell for ell in {2, 3}, via Vélu (velu.py) for any other odd prime ell != p."""
        if ell == self.p:
            raise ValueError("ell must differ from p")
        if ell not in MODULAR_POLYNOMIALS:
            return self.brandt_matrix_velu(ell)
        n = len(self.j)
        B = sp.zeros(n, n)
        for i, ji in enumerate(self.j):
            roots = self.F.poly_roots(phi_univariate(ell, ji, self.F))
            if sum(m for _, m in roots) != ell + 1:
                raise AssertionError(f"Phi_{ell}(j, Y) does not split in F_{self.p}^2 at j = {ji}")
            for r, mult in roots:
                if r not in self.index:
                    raise AssertionError("ell-isogenous curve is not supersingular")
                B[i, self.index[r]] += mult
        return B

    def brandt_matrix_velu(self, ell: int) -> sp.Matrix:
        """B(ell) for odd ell != p from ell-isogenies computed by Vélu's formulas (no modular polynomial)."""
        if ell == self.p or ell % 2 == 0 or not sp.isprime(ell):
            raise ValueError("ell must be an odd prime different from p")
        return sp.Matrix(VeluBrandt(self.p, self.F, self.j, ell).rows)

    def hecke_operator(self, n: int) -> sp.Matrix:
        """B(n) for n = prod ell^e via the Hecke relations
        B(ell^{e+1}) = B(ell) B(ell^e) - ell B(ell^{e-1}), B(mn) = B(m)B(n) for coprime m, n
        (weight 2, level p, p ∤ n)."""
        if n % self.p == 0:
            raise ValueError("n must be prime to p")
        result = sp.eye(len(self.j))
        for ell, e in sp.factorint(n).items():
            prev, cur = sp.eye(len(self.j)), self.brandt_matrix(ell)
            for _ in range(e - 1):
                prev, cur = cur, self.brandt_matrix(ell) * cur - ell * prev
            result = result * cur
        return result

    def hecke_polynomial(self, ell: int) -> sp.Poly:
        """charpoly(B(ell)) / (x - ell - 1): the characteristic polynomial of T_ell on S_2(Gamma_0(p))."""
        x = sp.Symbol("x")
        chi = self.brandt_matrix(ell).charpoly(x)
        quotient, rem = sp.div(sp.Poly(chi.as_expr(), x), sp.Poly(x - ell - 1, x))
        if not rem.is_zero:
            raise AssertionError("ell + 1 is not an eigenvalue")
        return quotient

    def common_eigenvector(self, eigenvalues: dict[int, int]) -> sp.Matrix | None:
        """A nonzero rational v with B(ell) v = a_ell v for all (ell, a_ell) given, or None."""
        n = len(self.j)
        stacked = sp.Matrix.vstack(*[self.brandt_matrix(ell) - a * sp.eye(n) for ell, a in eigenvalues.items()])
        ns = stacked.nullspace()
        return ns[0] if ns else None


def ramanujan_violations(hecke_poly: sp.Poly, ell: int) -> tuple[int, int]:
    """(number of non-real roots, number of roots with lambda^2 > 4 ell), exactly, by Sturm counts.
    Ramanujan–Petersson (Deligne) predicts (0, 0): the isogeny graph is Ramanujan."""
    x, y = sp.symbols("x y")
    if hecke_poly.degree() == 0:
        return 0, 0
    H = sp.Poly(sp.quo(hecke_poly, sp.gcd(hecke_poly, hecke_poly.diff(x))), x)  # squarefree part: Sturm counts distinct roots
    non_real = H.degree() - H.count_roots()
    G = sp.Poly(sp.resultant(H.as_expr(), y - x**2, x), y)  # roots are the lambda^2
    while G.eval(4 * ell) == 0:  # equality is allowed by the bound
        G = sp.Poly(sp.quo(G.as_expr(), y - 4 * ell, y), y)
    return non_real, G.count_roots(4 * ell, None)
