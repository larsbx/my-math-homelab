"""Rational weight-2 newforms of prime level as elliptic curves over Q (Cremona labels).

a_ell(f) = ell + 1 - #E(F_ell) by *exhaustive point counting*: an oracle for the
automorphic side that is independent of any quaternionic computation.  The
identification f <-> E is modularity (imported); the test that a Brandt
eigenvector carries exactly these a_ell for all tested ell is Jacquet–Langlands
+ Eichler–Shimura *checked*, not assumed.
"""
from __future__ import annotations

from dataclasses import dataclass

from .ec import Curve, discriminant_of_a_invariants, short_weierstrass_from_a_invariants
from .gf import GF


@dataclass(frozen=True)
class RationalNewform:
    label: str
    conductor: int
    a_invariants: tuple[int, int, int, int, int]

    def __post_init__(self) -> None:
        disc = discriminant_of_a_invariants(*self.a_invariants)
        n = abs(disc)
        while n % self.conductor == 0:
            n //= self.conductor
        if n != 1:
            raise ValueError(f"{self.label}: discriminant {disc} is not a power of {self.conductor}")

    def reduction(self, p: int, k: int = 1) -> Curve:
        if p in (2, 3) or p == self.conductor:
            raise ValueError("good reduction with p > 3 required")
        A, B = short_weierstrass_from_a_invariants(*self.a_invariants)
        return Curve.from_ints(GF.of_order(p, k), A, B)

    def point_count(self, ell: int) -> int:
        """#E(F_ell) for the general Weierstrass model, by brute force over F_ell^2 (any prime ell of good reduction)."""
        if ell == self.conductor:
            raise ValueError("bad reduction")
        return point_count_general(self.a_invariants, ell)

    def a(self, ell: int) -> int:
        """a_ell = ell + 1 - #E(F_ell), by point count (any prime ell != conductor)."""
        return ell + 1 - self.point_count(ell)


def point_count_general(a_invariants: tuple[int, int, int, int, int], ell: int) -> int:
    """#E(F_ell) for a general Weierstrass model by brute force (any prime ell of good reduction)."""
    a1, a2, a3, a4, a6 = a_invariants
    affine = sum(
        1
        for x in range(ell)
        for y in range(ell)
        if (y * y + a1 * x * y + a3 * y - (x**3 + a2 * x * x + a4 * x + a6)) % ell == 0
    )
    return affine + 1


# Cremona's tables: minimal models of the rational newforms of prime level <= 101.
CREMONA_PRIME_LEVEL: tuple[RationalNewform, ...] = (
    RationalNewform("11a1", 11, (0, -1, 1, -10, -20)),
    RationalNewform("17a1", 17, (1, -1, 1, -1, -14)),
    RationalNewform("19a1", 19, (0, 1, 1, -9, -15)),
    RationalNewform("37a1", 37, (0, 0, 1, -1, 0)),
    RationalNewform("37b1", 37, (0, 1, 1, -23, -50)),
    RationalNewform("43a1", 43, (0, 1, 1, 0, 0)),
    RationalNewform("53a1", 53, (1, -1, 1, 0, 0)),
    RationalNewform("61a1", 61, (1, 0, 0, -2, 1)),
    RationalNewform("67a1", 67, (0, 1, 1, -12, -21)),
    RationalNewform("73a1", 73, (1, -1, 0, 4, -3)),
    RationalNewform("79a1", 79, (1, 1, 1, -2, 0)),
    RationalNewform("83a1", 83, (1, 1, 1, 1, 0)),
    RationalNewform("89a1", 89, (1, 1, 1, -1, 0)),
    RationalNewform("89b1", 89, (1, 1, 0, 4, 5)),
    RationalNewform("101a1", 101, (0, 1, 1, -1, -1)),
)


def newforms_of_level(p: int) -> tuple[RationalNewform, ...]:
    return tuple(f for f in CREMONA_PRIME_LEVEL if f.conductor == p)
