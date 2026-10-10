"""Brandt matrices without modular polynomials: ell-isogenies by Vélu on a scalar-Frobenius model.

Every supersingular j has a model E over F_{p^2} with #E(F_{p^2}) = (p ∓ 1)^2, i.e. Frobenius
pi = ±p (a scalar), so every cyclic subgroup of E[ell] is F_{p^2}-rational.  The x-coordinates
of E[ell] are the roots of the division polynomial f_ell, found in K = F_{p^{2k}} with
(±p)^k ≡ ±1 (mod ell); they are grouped into the ell + 1 subgroups by the x-only multiplication
formulas, and Vélu's formulas give each codomain's j in K, compared with the embedded
supersingular j's.  Everything is x-only, so no square roots in the large field are needed.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cached_property

from .ec import Curve
from .gf import GF, Poly


# --------------------------------------------------------- field embedding ----
@dataclass(frozen=True)
class Embedding:
    """F_{p^2} -> K, t -> theta with theta a root of F_{p^2}'s modulus in K."""

    small: GF
    big: GF
    theta: Poly

    @staticmethod
    def of(small: GF, big: GF) -> "Embedding":
        if big.k % small.k:
            raise ValueError("no embedding: degree does not divide")
        modulus = tuple(big.from_int(c) for c in small.modulus)
        theta = next(r for r, _ in big.poly_roots(modulus))
        return Embedding(small, big, theta)

    def __call__(self, a: Poly) -> Poly:
        return self.big.eval_poly(tuple(self.big.from_int(c) for c in a), self.theta)


# --------------------------------------------------- division polynomials ----
def division_polynomial_values(E: Curve, x: Poly, n_max: int) -> tuple[Poly, ...]:
    """f_0..f_{n_max} at x, where psi_n = f_n * (2y)^{[n even]} on y^2 = x^3 + a x + b."""
    F, a, b = E.F, E.a, E.b
    x2 = F.mul(x, x)
    x3 = F.mul(x2, x)
    Fx = F.add(F.add(x3, F.mul(a, x)), b)
    four_F = F.scale(4, Fx)
    f = [F.zero, F.one, F.one]
    f3 = F.add(F.add(F.scale(3, F.mul(x2, x2)), F.scale(6, F.mul(a, x2))), F.sub(F.scale(12, F.mul(b, x)), F.mul(a, a)))
    f.append(f3)
    x4, x6 = F.mul(x2, x2), F.mul(x3, x3)
    inner = F.add(x6, F.scale(5, F.mul(a, x4)))
    inner = F.add(inner, F.scale(20, F.mul(b, x3)))
    inner = F.sub(inner, F.scale(5, F.mul(F.mul(a, a), x2)))
    inner = F.sub(inner, F.scale(4, F.mul(F.mul(a, b), x)))
    inner = F.sub(inner, F.scale(8, F.mul(b, b)))
    inner = F.sub(inner, F.pow(a, 3))
    f.append(F.scale(2, inner))
    for n in range(5, n_max + 1):
        m = n // 2
        if n % 2:
            t1 = F.mul(f[m + 2], F.pow(f[m], 3))
            t2 = F.mul(f[m - 1], F.pow(f[m + 1], 3))
            sixteen_F2 = F.mul(four_F, four_F)
            f.append(F.sub(F.mul(sixteen_F2, t1), t2) if m % 2 == 0 else F.sub(t1, F.mul(sixteen_F2, t2)))
        else:
            t1 = F.mul(f[m + 2], F.mul(f[m - 1], f[m - 1]))
            t2 = F.mul(f[m - 2], F.mul(f[m + 1], f[m + 1]))
            f.append(F.mul(f[m], F.sub(t1, t2)))
    return tuple(f)


def division_polynomial(E: Curve, n: int) -> tuple[Poly, ...]:
    """f_n as a polynomial in x over E.F (coefficients low -> high), by the same recursion."""
    F, a, b = E.F, E.a, E.b
    X = (F.zero, F.one)
    Fx = (b, a, F.zero, F.one)
    four_F = tuple(F.scale(4, c) for c in Fx)
    P = lambda *ints: tuple(F.from_int(i) for i in ints)  # noqa: E731
    f: list[tuple[Poly, ...]] = [(), (F.one,), (F.one,)]
    f3 = (F.neg(F.mul(a, a)), F.scale(12, b), F.scale(6, a), F.zero, F.from_int(3))
    f.append(F.ptrim(f3))
    a2, ab, b2, a3 = F.mul(a, a), F.mul(a, b), F.mul(b, b), F.pow(a, 3)
    f4 = (F.neg(F.add(F.scale(8, b2), a3)), F.neg(F.scale(4, ab)), F.neg(F.scale(5, a2)), F.scale(20, b), F.scale(5, a), F.zero, F.one)
    f.append(F.ptrim(tuple(F.scale(2, c) for c in f4)))
    del X, P
    for k in range(5, n + 1):
        m = k // 2
        if k % 2:
            t1 = F.pmul(f[m + 2], F.pmul(f[m], F.pmul(f[m], f[m])))
            t2 = F.pmul(f[m - 1], F.pmul(f[m + 1], F.pmul(f[m + 1], f[m + 1])))
            sixteen_F2 = F.pmul(four_F, four_F)
            f.append(F.psub(F.pmul(sixteen_F2, t1), t2) if m % 2 == 0 else F.psub(t1, F.pmul(sixteen_F2, t2)))
        else:
            t1 = F.pmul(f[m + 2], F.pmul(f[m - 1], f[m - 1]))
            t2 = F.pmul(f[m - 2], F.pmul(f[m + 1], f[m + 1]))
            f.append(F.pmul(f[m], F.psub(t1, t2)))
    return f[n]


def x_multiple(E: Curve, x: Poly, m: int) -> Poly:
    """x(mP) from x(P) only:  x - psi_{m-1} psi_{m+1} / psi_m^2."""
    F = E.F
    f = division_polynomial_values(E, x, m + 1)
    Fx = E.rhs(x)
    num = F.mul(f[m - 1], f[m + 1])
    den = F.mul(f[m], f[m])
    if m % 2:
        num = F.mul(F.scale(4, Fx), num)
    else:
        den = F.mul(F.scale(4, Fx), den)
    return F.sub(x, F.div(num, den))


# ------------------------------------------------------------------ Vélu ----
def velu_codomain(E: Curve, kernel_x: tuple[Poly, ...]) -> Curve:
    """Codomain of the isogeny with odd cyclic kernel whose nonzero points have the given
    x-coordinates (one representative per ±pair):  a' = a - 5v, b' = b - 7w."""
    F, a, b = E.F, E.a, E.b
    v, w = F.zero, F.zero
    for xq in kernel_x:
        gx = F.add(F.scale(3, F.mul(xq, xq)), a)
        vq = F.scale(2, gx)
        uq = F.scale(4, E.rhs(xq))
        v = F.add(v, vq)
        w = F.add(w, F.add(uq, F.mul(xq, vq)))
    return Curve(F, F.sub(a, F.scale(5, v)), F.sub(b, F.scale(7, w)))


# ---------------------------------------------- scalar-Frobenius models ----
def curve_with_j(F: GF, j: Poly) -> Curve:
    """A curve over F with the given j: y^2 = x^3 + 3j(1728-j) x + 2j(1728-j)^2, or the j = 0, 1728 forms."""
    if j == F.zero:
        return Curve(F, F.zero, F.one)
    if j == F.from_int(1728):
        return Curve(F, F.one, F.zero)
    d = F.sub(F.from_int(1728), j)
    return Curve(F, F.scale(3, F.mul(j, d)), F.scale(2, F.mul(j, F.mul(d, d))))


def twists(E: Curve) -> tuple[Curve, ...]:
    """All twists over E.F: (a d^2, b d^3) for d in F^x / (F^x)^n, n = 2 (generic), 4 (j=1728), 6 (j=0)."""
    F = E.F
    g = next(x for x in F.elements() if x != F.zero and F.multiplicative_order(x) == F.order - 1)
    n = 6 if E.j_invariant == F.zero else 4 if E.j_invariant == F.from_int(1728) else 2
    return tuple(Curve(F, F.mul(E.a, F.pow(g, 2 * i)), F.mul(E.b, F.pow(g, 3 * i))) for i in range(n))


def scalar_frobenius_model(F2: GF, j: Poly) -> tuple[Curve, int]:
    """(E, eps) with j(E) = j over F_{p^2} and #E(F_{p^2}) = (p - eps)^2, i.e. Frobenius = eps * p."""
    p = F2.p
    for E in twists(curve_with_j(F2, j)):
        for eps in (1, -1):
            if E.order == (p - eps) ** 2:
                return E, eps
    raise AssertionError("no scalar-Frobenius twist found (is j supersingular?)")


# ---------------------------------------------------------- Brandt by Vélu --
def torsion_x_subgroups(EK: Curve, ell: int, f_ell_roots: tuple[Poly, ...]) -> tuple[tuple[Poly, ...], ...]:
    """Partition the x-coordinates of E[ell] \\ O into the ell + 1 cyclic subgroups (x-only)."""
    half = (ell - 1) // 2
    groups: dict[frozenset, tuple[Poly, ...]] = {}
    for x in f_ell_roots:
        orbit = tuple(x_multiple(EK, x, m) for m in range(1, half + 1))
        groups.setdefault(frozenset(orbit), orbit)
    if len(groups) != ell + 1 or any(len(o) != half for o in groups.values()):
        raise AssertionError("ell-torsion did not split into ell + 1 cyclic subgroups")
    return tuple(groups.values())


def _torsion_field_degree(eps_p: int, ell: int) -> int:
    """Least k with (eps p)^k ≡ ±1 (mod ell): x(E[ell]) ⊂ F_{p^{2k}}."""
    k, x = 1, eps_p % ell
    while x not in (1, ell - 1):
        x, k = x * eps_p % ell, k + 1
    return k


@dataclass(frozen=True)
class VeluBrandt:
    """Brandt matrix rows via Vélu for one odd prime ell != p on a supersingular locus."""

    p: int
    F2: GF
    j: tuple[Poly, ...]
    ell: int

    @cached_property
    def rows(self) -> tuple[tuple[int, ...], ...]:
        index = {j: i for i, j in enumerate(self.j)}
        rows = []
        for j in self.j:
            E, eps = scalar_frobenius_model(self.F2, j)
            k = _torsion_field_degree(eps * self.p, self.ell)
            K = self.F2 if k == 1 else GF.of_order(self.p, 2 * k)
            emb = (lambda a: a) if k == 1 else Embedding.of(self.F2, K)
            EK = Curve(K, emb(E.a), emb(E.b))
            # Frobenius (= eps p on E[ell]) has orbits of length exactly k on x(E[ell] \ O), so f_ell
            # factors over F_{p^2} into irreducibles of degree k; find those with table arithmetic,
            # then each one's k roots in K.
            f_ell = division_polynomial(E, self.ell)
            factors = self.F2.equal_degree_factors(f_ell, k)
            roots = [r for h in factors for r, _ in K.poly_roots(tuple(emb(c) for c in h))]
            if len(roots) != (self.ell**2 - 1) // 2 or len(set(roots)) != len(roots):
                raise AssertionError("division polynomial did not split simply in K")
            embedded = {emb(jj): i for jj, i in index.items()}
            row = [0] * len(self.j)
            for kernel in torsion_x_subgroups(EK, self.ell, tuple(roots)):
                j_out = velu_codomain(EK, kernel).j_invariant
                if j_out not in embedded:
                    raise AssertionError("codomain is not supersingular")
                row[embedded[j_out]] += 1
            rows.append(tuple(row))
        return tuple(rows)
