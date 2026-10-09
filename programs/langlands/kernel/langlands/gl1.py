"""Branch 1 — unramified geometric class field theory for GL_1 over an elliptic curve E/F_p,
executed on the function side with an exact oracle.

Galois side.  The Lang isogeny  L: E -> E, P -> Frob(P) - P  is a finite étale Galois cover
with group E(F_p); rank-1 local systems on E (with F_p-structure) are the isotypic pieces
L_chi = (L_* Qbar_l)[chi] for characters chi of E(F_p).  On the fiber over a rational point x,
Frobenius acts by translation by x, so tr(Frob_x | L_chi) = chi(x); over a closed point of
degree d, tr(Frob_x | L_chi) = chi(N x) with N x = sum of the d conjugates, a point of E(F_p).

Automorphic side.  Unramified Hecke characters of F = F_p(E) are characters of the divisor
class group Pic(E)(F_p) = Z x E(F_p): chi(D) = alpha^{deg D} chi(sum n_x N x); the character
sheaf A_chi on Pic has trace function chi, and the Hecke eigenproperty
Hecke_x(A) = L_x ⊠ A reads chi(D + x) = chi(N x) chi(D).

What is computed here (nothing about sheaves is assumed):
  * Lang fibers, with Frobenius acting as translation, from the actual points over F_{p^n};
  * the character chi(N ·) on E(F_{p^k}) = Pic^0(F_{p^k}) and that it is a character;
  * Abel: chi vanishes on principal divisors of lines (descent along Abel–Jacobi);
  * Weil reciprocity  prod_P (f, g)_P = 1  with tame symbols from Laurent expansions,
    including the sign (-1)^{v(f) v(g)};
  * L(chi, T) = prod_x (1 - chi(N x) T^{deg x})^{-1} in Z[zeta][[T]] to a given order:
    it equals 1 for chi nontrivial on E(F_p) (dim H^1(Ebar, L_chi) = 2g - 2 = 0) and
    Z(E, T) = (1 - a_p T + p T^2)/((1 - T)(1 - pT)) for chi trivial.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cache, cached_property
from itertools import product

from . import cyclotomic as cyc
from .ec import Curve, GroupStructure, Point
from .gf import GF, Poly
from .laurent import XYPoly, tame_symbol, valuation


# ----------------------------------------------------------- base change ----
def extension_curve(E: Curve, k: int) -> Curve:
    return E.base_change(GF.of_order(E.F.p, k))


def is_rational(E: Curve, P: Point) -> bool:
    return P is None or all(E.F.is_prime_field_element(c) for c in P)


def descend_point(E: Curve, P: Point) -> Point:
    """A point of E(F_{p^k}) with coordinates in F_p, as a point of E(F_p)."""
    if P is None:
        return None
    K, F = E.F, GF.of_order(E.F.p, 1)
    return (F.from_int(K.to_int(P[0])), F.from_int(K.to_int(P[1])))


def lift_point(Ek: Curve, P: Point) -> Point:
    """A point of E(F_p) as a point of E(F_{p^k})."""
    return None if P is None else (Ek.F.from_int(P[0][0]), Ek.F.from_int(P[1][0]))


def norm_point(Ek: Curve, P: Point) -> Point:
    """N(P) = sum_{i < k} Frob^i(P), computed in E(F_{p^k}); lands in E(F_p)."""
    total, Q = None, P
    for _ in range(Ek.F.k):
        total, Q = Ek.add(total, Q), Ek.frobenius(Q)
    if Q != P:
        raise AssertionError("Frob^k is not the identity on E(F_{p^k})")
    return total


# ------------------------------------------------------------ characters ----
@dataclass(frozen=True)
class Character:
    """chi_{a,b}(u P1 + v P2) = zeta_N^{a u + b v (N/n2)}, N = exponent = ord P1, n2 = ord P2."""

    structure: GroupStructure
    a: int
    b: int

    @property
    def N(self) -> int:
        return self.structure.orders[0]

    @property
    def is_trivial(self) -> bool:
        n1, n2 = self.structure.orders
        return self.a % n1 == 0 and self.b % n2 == 0

    def exponent(self, P: Point) -> int:
        n1, n2 = self.structure.orders
        u, v = self.structure.log(P)
        return (self.a * u + self.b * v * (n1 // n2)) % n1

    def value(self, P: Point) -> cyc.Vec:
        return cyc.unit(self.N, self.exponent(P))


def all_characters(structure: GroupStructure) -> tuple[Character, ...]:
    n1, n2 = structure.orders
    return tuple(Character(structure, a, b) for a, b in product(range(n1), range(n2)))


# ---------------------------------------------------------- closed points ----
@dataclass(frozen=True)
class ClosedPoint:
    degree: int
    representative: Point  # a point of E(F_{p^degree})
    norm: Point  # in E(F_p)


def closed_points(E: Curve, max_degree: int) -> tuple[ClosedPoint, ...]:
    """All closed points of E of degree <= max_degree, as Frobenius orbits of E(F_{p^d})."""
    out = []
    for d in range(1, max_degree + 1):
        Ed = extension_curve(E, d)
        seen: set[Point] = set()
        for P in Ed.points:
            if P in seen:
                continue
            orbit = [P]
            while (Q := Ed.frobenius(orbit[-1])) != P:
                orbit.append(Q)
            seen.update(orbit)
            if len(orbit) == d:
                out.append(ClosedPoint(d, P, descend_point(Ed, norm_point(Ed, P))))
    return tuple(out)


# ----------------------------------------------------------- Lang fibers ----
@dataclass(frozen=True)
class LangFiber:
    base: Point  # x in E(F_p)
    points: tuple[Point, ...]  # {P in E(F_{p^n}) : Frob P - P = x}


def lang_fibers(E: Curve, n: int) -> dict[Point, LangFiber]:
    """Fibers of the Lang map L(P) = Frob(P) - P over E(F_p), among P in E(F_{p^n}).
    Frob^n P = P + n x, so the fiber over x lies in E(F_{p^n}) iff n x = O: the keys are E(F_p)[n]."""
    En = extension_curve(E, n)
    buckets: dict[Point, list[Point]] = {}
    for P in En.points:
        x = En.sub(En.frobenius(P), P)
        if is_rational(En, x):
            buckets.setdefault(descend_point(En, x), []).append(P)
    return {x: LangFiber(x, tuple(pts)) for x, pts in buckets.items()}


def frobenius_is_translation(E: Curve, n: int, fiber: LangFiber) -> bool:
    En = extension_curve(E, n)
    x_up = lift_point(En, fiber.base)
    return all(En.frobenius(P) == En.add(P, x_up) for P in fiber.points)


def isotypic_frobenius_exponent(E: Curve, n: int, fiber: LangFiber, chi: Character) -> int | None:
    """Frob acts on the chi-isotypic line of Qbar_l[fiber] by a root of unity; return its exponent
    (mod N) if the line is an eigenline, else None.  v_chi(P) = chi(P - P0)^{-1}; (Frob v)(P) = v(Frob^{-1} P)."""
    En = extension_curve(E, n)
    P0 = fiber.points[0]
    inv_frob = {En.frobenius(P): P for P in fiber.points}
    log = lambda P: chi.exponent(descend_point(En, En.sub(P, P0)))  # noqa: E731
    exps = {(log(P) - log(inv_frob[P])) % chi.N for P in fiber.points}
    return exps.pop() if len(exps) == 1 else None


# ------------------------------------------------- character sheaf traces ----
def character_sheaf_trace(E: Curve, chi: Character, k: int) -> dict[Point, int]:
    """tr(Frob_{p^k} | A_chi at P) for P in Pic^0(F_{p^k}) = E(F_{p^k}): exponent of chi(N P)."""
    Ek = extension_curve(E, k)
    return {P: chi.exponent(descend_point(Ek, norm_point(Ek, P))) for P in Ek.points}


def is_character(Ek: Curve, trace: dict[Point, int], N: int) -> bool:
    """f: E(F_{p^k}) -> Z/N is a homomorphism iff f(P + g) = f(P) + f(g) for all P and generators g."""
    gens = [g for g in Ek.structure.basis if g is not None]
    return all((trace[P] + trace[g] - trace[Ek.add(P, g)]) % N == 0 for P in Ek.points for g in gens)


# ---------------------------------------------------------- L-functions ----
def l_series(E: Curve, chi: Character, order: int, points: tuple[ClosedPoint, ...] | None = None) -> tuple[cyc.Vec, ...]:
    """Coefficients c_0..c_order of L(chi, T) = prod_x (1 - chi(N x) T^{deg x})^{-1} in Z[Z/N][[T]]."""
    N = chi.N
    pts = points if points is not None else closed_points(E, order)
    series = [cyc.unit(N, 0)] + [cyc.zero(N)] * order
    for x in pts:
        if x.degree > order:
            continue
        r = chi.exponent(x.norm)
        # multiply by (1 - zeta^r T^d)^{-1} = sum_m zeta^{rm} T^{dm}
        for n in range(x.degree, order + 1):  # in place, ascending: series[n] += zeta^r * series[n - d]
            series[n] = cyc.add(series[n], cyc.mul(cyc.unit(N, r), series[n - x.degree]))
    return tuple(series)


def zeta_coefficients(E: Curve, order: int) -> tuple[int, ...]:
    """Coefficients of Z(E, T) = (1 - a T + p T^2)/((1 - T)(1 - pT)): # effective divisors of degree n."""
    a, p = E.trace_of_frobenius, E.F.order
    num = [1, -a, p] + [0] * (order - 2) if order >= 2 else [1, -a][: order + 1]
    # divide by (1 - T)(1 - pT) = 1 - (p+1) T + p T^2
    out = []
    for n in range(order + 1):
        c = (num[n] if n < len(num) else 0) + (p + 1) * (out[n - 1] if n >= 1 else 0) - p * (out[n - 2] if n >= 2 else 0)
        out.append(c)
    return tuple(out)


# ----------------------------------------------------- principal divisors ----
@dataclass(frozen=True)
class Line:
    """y - lam x - mu = 0 (non-vertical) or x - c = 0 (vertical, lam = None)."""

    lam: Poly | None
    mu: Poly

    def as_xy(self, K: GF) -> XYPoly:
        lift = lambda c: K.from_int(c[0])  # noqa: E731  (coefficients in F_p)
        if self.lam is None:
            return {(1, 0): K.one, (0, 0): K.neg(lift(self.mu))}
        return {(0, 1): K.one, (1, 0): K.neg(lift(self.lam)), (0, 0): K.neg(lift(self.mu))}

    def pole_order_at_O(self) -> int:
        return 2 if self.lam is None else 3


@cache
def line_zeros(E: Curve, line: Line, K: GF) -> tuple[Point, ...]:
    """The zeros of the line on E over K (with multiplicity), as points of E(K).
    K must contain them (F_{p^6} always does for lines: x-degrees divide 6)."""
    EK = E.base_change(K)
    lift = lambda c: K.from_int(c[0])  # noqa: E731
    if line.lam is None:
        c = lift(line.mu)
        r = EK.rhs(c)
        if r == K.zero:  # tangent at the 2-torsion point (c, 0): a double zero
            return ((c, K.zero), (c, K.zero))
        return tuple((c, y) for y in K.sqrts(r))
    lam, mu = lift(line.lam), lift(line.mu)
    # x^3 + a x + b - (lam x + mu)^2
    poly = (
        K.sub(EK.b, K.mul(mu, mu)),
        K.sub(EK.a, K.scale(2, K.mul(lam, mu))),
        K.neg(K.mul(lam, lam)),
        K.one,
    )
    roots = K.poly_roots(poly)
    if sum(m for _, m in roots) != 3:
        raise ValueError("K does not contain all intersection points")
    return tuple((x, K.add(K.mul(lam, x), mu)) for x, m in roots for _ in range(m))


def abel_sum(E: Curve, line: Line, K: GF) -> Point:
    """sum of the zeros of the line in E(K), descended to E(F_p) (Abel: it must be O)."""
    EK = E.base_change(K)
    total = None
    for P in line_zeros(E, line, K):
        total = EK.add(total, P)
    return descend_point(EK, total)


def weil_reciprocity_product(E: Curve, f: Line, g: Line, K: GF, prec: int = 14) -> tuple[Poly, Poly]:
    """(product of tame symbols (f, g)_P over all finite P in supp f ∪ supp g, the symbol at O)."""
    EK = E.base_change(K)
    fx, gx = f.as_xy(K), g.as_xy(K)
    support = set(line_zeros(E, f, K)) | set(line_zeros(E, g, K))
    finite = K.one
    for P in support:
        finite = K.mul(finite, tame_symbol(EK, fx, gx, P, prec))
    return finite, tame_symbol(EK, fx, gx, None, prec)


def divisor_valuations(E: Curve, f: Line, K: GF, prec: int = 14) -> dict[Point, int]:
    EK = E.base_change(K)
    fx = f.as_xy(K)
    vals = {P: valuation(EK, fx, P, prec) for P in set(line_zeros(E, f, K))}
    vals[None] = valuation(EK, fx, None, prec)
    return vals
