"""Branch 1, ramified: geometric class field theory of F_q(E) with modulus m = 2 P_0.

Rosenlicht–Serre: characters of Cl_m = Div_m / {div f : f = 1 mod m} are the Hecke characters of
conductor dividing m; Cl^0_m = J_m(F_q) is the generalized Jacobian, an extension
        0 -> (1 + u F_q[[u]]) / (1 + u^2 ...) = F_q  ->  J_m(F_q)  ->  E(F_q)  ->  0,
so the new characters are Artin–Schreier type, wildly ramified at P_0 with conductor exponent 2.
Their L-functions L(chi, T) = prod_{x != P_0} (1 - chi(x) T^{deg x})^{-1} are polynomials of degree
2g - 2 + deg m = 2 with roots of absolute value q^{-1/2} (Weil).

Everything is computed: the class map D -> (S, a) (S = sum of D in E(F_q), a = the u-coefficient of
the function realising D - R(S), normalised at P_0), the group law through its 2-cocycle, the
characters through a basis, and the Euler products in Z[Z/N][[T]].
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cached_property
from itertools import product

from . import cyclotomic as cyc
from .abelian import abelian_structure
from .ec import Curve, Point
from .gf import GF, Poly
from .gl1 import ClosedPoint, closed_points, descend_point, extension_curve, is_rational, lift_point
from .laurent import Laurent, LocalExpansion, XYPoly, local_expansion


# --------------------------------------------------------------- lines --
def line_polys(EK: Curve, A: Point, Q: Point) -> tuple[XYPoly | None, XYPoly | None]:
    """(l_{A,Q}, v_{A+Q}) as polynomials in x, y with div l - div v = (A) + (Q) - (A + Q) - (O).
    None stands for the constant 1 (when A or Q or A + Q is O)."""
    F = EK.F
    if A is None or Q is None:
        return None, None
    (x1, y1), (x2, y2) = A, Q
    if x1 == x2 and (y1 != y2 or y1 == F.zero):  # A = -Q: vertical line, A + Q = O
        return {(1, 0): F.one, (0, 0): F.neg(x1)}, None
    if x1 == x2:  # tangent
        lam = F.div(F.add(F.scale(3, F.mul(x1, x1)), EK.a), F.scale(2, y1))
    else:
        lam = F.div(F.sub(y2, y1), F.sub(x2, x1))
    line = {(0, 1): F.one, (1, 0): F.neg(lam), (0, 0): F.sub(F.mul(lam, x1), y1)}
    R = EK.add(A, Q)
    return line, {(1, 0): F.one, (0, 0): F.neg(R[0])}


def principal_function(EK: Curve, divisor: dict) -> list[tuple[XYPoly, int]]:
    """Factors (polynomial, exponent) of a function f with div f = the given principal divisor
    {point: multiplicity} (O allowed; the divisor must have degree 0 and sum O in E).
    Miller accumulation on the positive and negative parts separately, then the quotient."""
    def accumulate(points: list[Point]) -> tuple[list[tuple[XYPoly, int]], Point]:
        factors: list[tuple[XYPoly, int]] = []
        A: Point = None
        first = True
        for Q in points:
            if first:
                A, first = Q, False
                continue
            line, vert = line_polys(EK, A, Q)
            if line is not None:
                factors.append((line, 1))
            if vert is not None:
                factors.append((vert, -1))
            A = EK.add(A, Q)
        return factors, A

    pos = [P for P, m in divisor.items() if P is not None and m > 0 for _ in range(m)]
    neg = [P for P, m in divisor.items() if P is not None and m < 0 for _ in range(-m)]
    f_pos, A_pos = accumulate(pos)
    f_neg, A_neg = accumulate(neg)
    if A_pos != A_neg or sum(divisor.values()) != 0:
        raise ValueError("divisor is not principal")
    return f_pos + [(g, -e) for g, e in f_neg]


def expansion_of_product(EK: Curve, factors: list[tuple[XYPoly, int]], P: Point, prec: int = 8) -> Laurent:
    loc = local_expansion(EK, P, prec)
    total = Laurent(EK.F, 0, (EK.F.one,), 10**6)
    for poly, e in factors:
        s = loc.evaluate(poly)
        total = total * (s if e == 1 else s.inverse())
    return total


# ---------------------------------------------------- the ray class group --
@dataclass(frozen=True)
class RayClassGroup:
    """Cl^0_m for m = 2 P_0 on E/F_p, as pairs (S, a): S in E(F_p), a in F_p."""

    E: Curve
    P0: Point
    T: Point  # auxiliary rational point, T != O, P0, -P0

    def R(self, S: Point) -> dict:
        """Canonical representative of the class S: (S) - (O), or (P0 + T) - (T) when S = P0."""
        if S is None:
            return {}
        if S == self.P0:
            return {self.E.add(self.P0, self.T): 1, self.T: -1}
        return {S: 1, None: -1}

    def u_coefficient(self, EK: Curve, divisor: dict) -> int:
        """For a principal divisor prime to P0 (over K ⊇ F_p): f/f(P0) = 1 + a u + ..., return a in F_p."""
        factors = principal_function(EK, divisor)
        s = expansion_of_product(EK, factors, lift_point(EK, self.P0))
        if s.v != 0 or s.prec < 2:
            raise AssertionError("function is not a unit at P0 or precision too low")
        a = EK.F.div(s.coeff(1), s.coeff(0))
        if not EK.F.is_prime_field_element(a):
            raise AssertionError("u-coefficient not rational")
        return EK.F.to_int(a)

    @cached_property
    def cocycle(self) -> dict:
        """c(S1, S2): the u-coefficient of the function with divisor R(S1) + R(S2) - R(S1 + S2)."""
        E = self.E
        table = {}
        for S1 in E.points:
            for S2 in E.points:
                div: dict = {}
                for D, sign in ((self.R(S1), 1), (self.R(S2), 1), (self.R(E.add(S1, S2)), -1)):
                    for P, m in D.items():
                        div[P] = div.get(P, 0) + sign * m
                div = {P: m for P, m in div.items() if m}
                table[(S1, S2)] = self.u_coefficient(E, div) if div else 0
        return table

    def add(self, g1, g2):
        S1, a1 = g1
        S2, a2 = g2
        return (self.E.add(S1, S2), (a1 + a2 + self.cocycle[(S1, S2)]) % self.E.F.p)

    @cached_property
    def elements(self) -> tuple:
        return tuple((S, a) for S in self.E.points for a in range(self.E.F.p))

    @property
    def zero(self):
        return (None, 0)

    def mul(self, n: int, g):
        out = self.zero
        for _ in range(n):
            out = self.add(out, g)
        return out

    def order_of(self, g) -> int:
        n, h = 1, g
        while h != self.zero:
            h, n = self.add(h, g), n + 1
        return n

    @cached_property
    def structure(self) -> tuple[list, list[int]]:
        """Basis and invariant factors (n_1 = exponent, each later order dividing the previous one)."""
        return abelian_structure(self.elements, self.add, self.zero)

    @cached_property
    def log_table(self) -> dict:
        basis, orders = self.structure
        table = {}
        for coeffs in product(*[range(n) for n in orders]):
            g = self.zero
            for c, b in zip(coeffs, basis):
                g = self.add(g, self.mul(c, b))
            table[g] = coeffs
        assert len(table) == len(self.elements)
        return table

    # ------------------------------------------------------ class map --
    def class_of_closed_point(self, x: ClosedPoint):
        """Class of (x) - deg(x) (O) in Cl^0_m: (N(x), a)."""
        E = self.E
        S = x.norm
        Ed = extension_curve(E, x.degree)
        orbit, P = [], x.representative
        for _ in range(x.degree):
            orbit.append(P)
            P = Ed.frobenius(P)
        div: dict = {}
        for Q in orbit:
            div[Q] = div.get(Q, 0) + 1
        div[None] = div.get(None, 0) - x.degree
        for Q, m in self.R(S).items():
            Ql = lift_point(Ed, Q)
            div[Ql] = div.get(Ql, 0) - m
        div = {Q: m for Q, m in div.items() if m}
        a = self.u_coefficient(Ed, div) if div else 0
        return (S, a)


@dataclass(frozen=True)
class RayClassCharacter:
    G: RayClassGroup
    exponents: tuple[int, ...]  # chi(b_i) = zeta_N^{e_i * N / n_i}

    @property
    def N(self) -> int:
        return max(self.G.structure[1])

    def exponent(self, g) -> int:
        coeffs = self.G.log_table[g]
        return sum(e * c * (self.N // n) for e, c, n in zip(self.exponents, coeffs, self.G.structure[1])) % self.N

    @property
    def is_ramified(self) -> bool:
        """Nontrivial on the subgroup {(O, a)} = F_p (the inertia at P0 mod m)."""
        return any(self.exponent((None, a)) for a in range(1, self.G.E.F.p))

    @property
    def is_trivial(self) -> bool:
        return all(self.exponent(g) == 0 for g in self.G.elements)


def all_characters(G: RayClassGroup) -> tuple[RayClassCharacter, ...]:
    _, orders = G.structure
    return tuple(RayClassCharacter(G, e) for e in product(*[range(n) for n in orders]))


def l_series(G: RayClassGroup, chi: RayClassCharacter, order: int, pts: tuple[ClosedPoint, ...]) -> tuple[cyc.Vec, ...]:
    """L(chi, T) = prod_{x != P0, deg x <= order} (1 - chi(x) T^{deg x})^{-1} in Z[Z/N][[T]]."""
    N = chi.N
    P0 = G.P0
    series = [cyc.unit(N, 0)] + [cyc.zero(N)] * order
    for x in pts:
        if x.degree > order or (x.degree == 1 and descend_point(extension_curve(G.E, 1), x.representative) == P0):
            continue
        r = chi.exponent(G.class_of_closed_point(x))
        for n in range(x.degree, order + 1):
            series[n] = cyc.add(series[n], cyc.mul(cyc.unit(N, r), series[n - x.degree]))
    return tuple(series)


def conjugate(v: cyc.Vec) -> cyc.Vec:
    """Complex conjugation zeta -> zeta^{-1} on Z[Z/N]."""
    N = len(v)
    return tuple(v[(-r) % N] for r in range(N))
