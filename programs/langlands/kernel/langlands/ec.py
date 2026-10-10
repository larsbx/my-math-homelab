"""Elliptic curves y^2 = x^3 + a x + b over an exact finite field (p > 3).

Points are `None` (the origin O) or pairs (x, y) of field elements.  Group law,
exhaustive point enumeration, Frobenius, group structure with an explicit basis,
and discrete logarithms are all exact.
"""
from __future__ import annotations

from dataclasses import dataclass
from functools import cached_property
from itertools import product
from math import gcd

from .gf import GF, Poly

Point = tuple[Poly, Poly] | None


def short_weierstrass_from_a_invariants(a1: int, a2: int, a3: int, a4: int, a6: int) -> tuple[int, int]:
    """[a1,a2,a3,a4,a6] -> (A, B) with y^2 = x^3 + A x + B isomorphic over Z[1/6]:
    A = -27 c4, B = -54 c6."""
    b2 = a1 * a1 + 4 * a2
    b4 = 2 * a4 + a1 * a3
    b6 = a3 * a3 + 4 * a6
    c4 = b2 * b2 - 24 * b4
    c6 = -(b2**3) + 36 * b2 * b4 - 216 * b6
    return -27 * c4, -54 * c6


def discriminant_of_a_invariants(a1: int, a2: int, a3: int, a4: int, a6: int) -> int:
    b2 = a1 * a1 + 4 * a2
    b4 = 2 * a4 + a1 * a3
    b6 = a3 * a3 + 4 * a6
    b8 = a1 * a1 * a6 + 4 * a2 * a6 - a1 * a3 * a4 + a2 * a3 * a3 - a4 * a4
    return -(b2**2) * b8 - 8 * b4**3 - 27 * b6**2 + 9 * b2 * b4 * b6


@dataclass(frozen=True)
class Curve:
    F: GF
    a: Poly
    b: Poly

    @staticmethod
    def from_ints(F: GF, a: int, b: int) -> "Curve":
        return Curve(F, F.from_int(a), F.from_int(b))

    def __post_init__(self) -> None:
        F = self.F
        if F.p <= 3:
            raise ValueError("short Weierstrass form needs p > 3")
        disc = F.add(F.scale(4, F.pow(self.a, 3)), F.scale(27, F.mul(self.b, self.b)))
        if disc == F.zero:
            raise ValueError("singular curve")

    # ----------------------------------------------------------- invariants --
    @cached_property
    def j_invariant(self) -> Poly:
        F = self.F
        a3 = F.pow(self.a, 3)
        num = F.scale(1728 * 4, a3)
        den = F.add(F.scale(4, a3), F.scale(27, F.mul(self.b, self.b)))
        return F.div(num, den)

    def base_change(self, K: GF) -> "Curve":
        """Same equation over an extension K ⊇ F_p (coefficients must lie in F_p)."""
        F = self.F
        return Curve(K, K.from_int(F.to_int(self.a)), K.from_int(F.to_int(self.b)))

    # ------------------------------------------------------------ group law --
    def rhs(self, x: Poly) -> Poly:
        F = self.F
        return F.add(F.add(F.pow(x, 3), F.mul(self.a, x)), self.b)

    def contains(self, P: Point) -> bool:
        if P is None:
            return True
        x, y = P
        return self.F.mul(y, y) == self.rhs(x)

    def neg(self, P: Point) -> Point:
        return None if P is None else (P[0], self.F.neg(P[1]))

    def add(self, P: Point, Q: Point) -> Point:
        F = self.F
        if P is None:
            return Q
        if Q is None:
            return P
        (x1, y1), (x2, y2) = P, Q
        if x1 == x2:
            if y1 != y2 or y1 == F.zero:
                return None
            lam = F.div(F.add(F.scale(3, F.mul(x1, x1)), self.a), F.scale(2, y1))
        else:
            lam = F.div(F.sub(y2, y1), F.sub(x2, x1))
        x3 = F.sub(F.sub(F.mul(lam, lam), x1), x2)
        y3 = F.sub(F.mul(lam, F.sub(x1, x3)), y1)
        return (x3, y3)

    def sub(self, P: Point, Q: Point) -> Point:
        return self.add(P, self.neg(Q))

    def mul(self, n: int, P: Point) -> Point:
        if n < 0:
            return self.mul(-n, self.neg(P))
        R: Point = None
        while n:
            if n & 1:
                R = self.add(R, P)
            P, n = self.add(P, P), n >> 1
        return R

    def order_of(self, P: Point) -> int:
        n, Q = 1, P
        while Q is not None:
            Q, n = self.add(Q, P), n + 1
        return n

    def frobenius(self, P: Point, power: int = 1) -> Point:
        """(x, y) -> (x^{p^power}, y^{p^power}); the q-Frobenius of E/F_q is power = k."""
        return None if P is None else (self.F.frobenius(P[0], power), self.F.frobenius(P[1], power))

    # ----------------------------------------------------------- enumeration --
    @cached_property
    def points(self) -> tuple[Point, ...]:
        F = self.F
        affine = [(x, y) for x in F.elements() for y in F.sqrts(self.rhs(x))]
        return (None, *affine)

    @cached_property
    def order(self) -> int:
        return len(self.points)

    @cached_property
    def trace_of_frobenius(self) -> int:
        return self.F.order + 1 - self.order

    # ------------------------------------------------------ group structure --
    @cached_property
    def structure(self) -> "GroupStructure":
        """E(F_q) = <P1> x <P2> with ord P2 | ord P1 (P2 = O when cyclic)."""
        N = self.order
        pts = self.points
        orders = {P: self.order_of(P) for P in pts}
        P1 = max(pts, key=orders.get)
        n1 = orders[P1]
        if n1 == N:
            return GroupStructure(self, (P1, None), (n1, 1))
        cyclic = {self.mul(i, P1): i for i in range(n1)}
        n2 = N // n1
        for Q in pts:
            if Q in cyclic:
                continue
            # smallest j with jQ in <P1>; Q is a generator of E/<P1> iff j == n2
            j, R = 1, Q
            while R not in cyclic:
                R, j = self.add(R, Q), j + 1
            if j != n2:
                continue
            k = cyclic[R]  # jQ = kP1, and j | k (n1 is the exponent)
            if k % j:
                raise AssertionError("exponent argument violated")
            P2 = self.sub(Q, self.mul(k // j, P1))
            return GroupStructure(self, (P1, P2), (n1, n2))
        raise AssertionError("no complement found")  # unreachable for a group of rank <= 2

    def a_invariant_string(self) -> str:
        return f"y^2 = x^3 + {self.a}x + {self.b} over F_{self.F.order}"


@dataclass(frozen=True)
class GroupStructure:
    E: Curve
    basis: tuple[Point, Point]
    orders: tuple[int, int]

    @cached_property
    def log_table(self) -> dict[Point, tuple[int, int]]:
        E, (P1, P2), (n1, n2) = self.E, self.basis, self.orders
        table = {}
        for u, v in product(range(n1), range(n2)):
            table[E.add(E.mul(u, P1), E.mul(v, P2))] = (u, v)
        if len(table) != E.order:
            raise AssertionError("basis does not generate")
        return table

    def log(self, P: Point) -> tuple[int, int]:
        return self.log_table[P]

    @property
    def exponent(self) -> int:
        return self.orders[0]
