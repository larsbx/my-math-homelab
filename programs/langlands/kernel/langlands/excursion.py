"""Third act, Python side: pseudocharacter identities and excursion evaluations of mod-ell parameters.

* `procesi_identity_holds(ell)`: Σ_{σ ∈ S_3} sgn(σ) T_σ = 0 for the trace on all triples of GL_2(F_ell)
  (the 2-dimensional pseudocharacter relation, Taylor / Procesi).
* `mod_ell_excursion_check(E, p, ell)` for ell ∈ {2, 3}: the Galois side seen through a class function of
  the mod-ell parameter (the factorisation of the ell-division polynomial over F_p, i.e. whether
  ρ̄_ell(Frob_p) has an eigenvector in E[ell] with eigenvalue ±1) against the automorphic side
  (whether x² − a_p x + p has a root ±1 mod ell).  For ell = 2 the class of Frob_p in GL_2(F_2) = S_3 is
  fully determined by the number of roots of the 2-division cubic, and its trace is a_p mod 2.
* `ExcursionData.of_hom` on finite groups with the relations (E1)–(E3) checked exhaustively for |I| ≤ 2
  (the finite shadow of `proof/langlands/LanglandsOracles/Excursion.lean`).
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable

from .ec import Curve
from .gf import GF
from .velu import division_polynomial

Mat = tuple[int, int, int, int]


def gl2(ell: int) -> tuple[Mat, ...]:
    return tuple(m for m in product(range(ell), repeat=4) if (m[0] * m[3] - m[1] * m[2]) % ell)


def mat_mul(x: Mat, y: Mat, ell: int) -> Mat:
    a, b, c, d = x
    e, f, g, h = y
    return ((a * e + b * g) % ell, (a * f + b * h) % ell, (c * e + d * g) % ell, (c * f + d * h) % ell)


def trace(x: Mat, ell: int) -> int:
    return (x[0] + x[3]) % ell


def procesi(g1: Mat, g2: Mat, g3: Mat, ell: int) -> int:
    T = lambda m: trace(m, ell)  # noqa: E731
    M = lambda x, y: mat_mul(x, y, ell)  # noqa: E731
    return (T(g1) * T(g2) * T(g3) - T(M(g1, g2)) * T(g3) - T(M(g1, g3)) * T(g2) - T(M(g2, g3)) * T(g1)
            + T(M(M(g1, g2), g3)) + T(M(M(g1, g3), g2))) % ell


def procesi_identity_holds(ell: int) -> bool:
    G = gl2(ell)
    return all(procesi(g1, g2, g3, ell) == 0 for g1 in G for g2 in G for g3 in G)


# ------------------------------------------------- mod-ell excursion checks --
def division_polynomial_root_count(E: Curve, ell: int) -> int:
    """Number of F_p-roots of the ell-division polynomial in x (ell odd), or of x³ + ax + b (ell = 2)."""
    F = E.F
    poly = (E.b, E.a, F.zero, F.one) if ell == 2 else division_polynomial(E, ell)
    return sum(m for _, m in F.poly_roots(poly))


def charpoly_has_root_pm1(a_p: int, p: int, ell: int) -> bool:
    return any((e * e - a_p * e + p) % ell == 0 for e in (1, -1))


def mod_ell_excursion_check(E: Curve, ell: int) -> tuple[bool, bool]:
    """(Galois side: ψ_ell has an F_p-root, automorphic side: x² − a_p x + p has a root ±1 mod ell)."""
    p = E.F.p
    galois = division_polynomial_root_count(E, ell) > 0
    automorphic = charpoly_has_root_pm1(E.trace_of_frobenius, p, ell)
    return galois, automorphic


def frobenius_class_in_S3(E: Curve) -> str:
    """Conjugacy class of Frob_p in Gal(2-division field) ⊆ GL_2(F_2) = S_3 from the cubic's factorisation."""
    return {0: "3-cycle", 1: "transposition", 3: "identity"}[division_polynomial_root_count(E, 2)]


S3_TRACE_MOD_2 = {"3-cycle": 1, "transposition": 0, "identity": 0}


# ------------------------------------------------- finite excursion data --
@dataclass(frozen=True)
class FiniteGroup:
    elements: tuple
    mul: Callable
    one: object
    inv: Callable


@dataclass(frozen=True)
class ExcursionData:
    """Θ_I(f)(γ) = f(ρ ∘ γ) for a homomorphism ρ: Γ → Ĝ of finite groups; Θ takes f: Ĝ^I → k and γ ∈ Γ^I."""

    Gamma: FiniteGroup
    Ghat: FiniteGroup
    rho: Callable

    def theta(self, f: Callable, gamma: tuple):
        return f(tuple(self.rho(g) for g in gamma))

    def is_lr_invariant(self, f: Callable, arity: int) -> bool:
        G = self.Ghat
        return all(
            f(tuple(G.mul(G.mul(h, x), h2) for x in xs)) == f(xs)
            for h in G.elements for h2 in G.elements for xs in product(G.elements, repeat=arity)
        )

    def relations_hold(self, f: Callable, arity: int) -> bool:
        """(E1) for every map ζ: I → I, (E2) for f·f and for constants, (E3) composition, over all γ, γ' ∈ Γ^I."""
        Gm, G = self.Gamma, self.Ghat
        tuples = list(product(Gm.elements, repeat=arity))
        # E1
        for zeta in product(range(arity), repeat=arity):
            pulled = lambda x, z=zeta: f(tuple(x[z[i]] for i in range(arity)))  # noqa: E731
            for gamma in tuples:
                if self.theta(pulled, gamma) != self.theta(f, tuple(gamma[zeta[i]] for i in range(arity))):
                    return False
        # E2, including unitality: constants map to constants
        ff = lambda x: f(x) * f(x)  # noqa: E731
        if any(self.theta(ff, gamma) != self.theta(f, gamma) ** 2 for gamma in tuples):
            return False
        if any(self.theta(lambda _x, c=c: c, gamma) != c for c in (0, 1, 7) for gamma in tuples):
            return False
        # E3: f̃(x ⊔ x' ⊔ x'') = f(x_i x''_i^{-1} x'_i) at (γ, γ', 1)
        tilde = lambda x: f(tuple(G.mul(G.mul(x[i], G.inv(x[2 * arity + i])), x[arity + i]) for i in range(arity)))  # noqa: E731
        for gamma in tuples:
            for gamma2 in tuples:
                prod_ = tuple(Gm.mul(a, b) for a, b in zip(gamma, gamma2))
                if self.theta(f, prod_) != self.theta(tilde, gamma + gamma2 + (Gm.one,) * arity):
                    return False
        return True


def gl2_group(ell: int) -> FiniteGroup:
    G = gl2(ell)
    def inv(x):
        return next(y for y in G if mat_mul(x, y, ell) == (1, 0, 0, 1))
    return FiniteGroup(G, lambda x, y: mat_mul(x, y, ell), (1, 0, 0, 1), inv)
