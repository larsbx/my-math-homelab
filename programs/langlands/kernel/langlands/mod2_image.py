"""The image of the mod-2 representation of a rational elliptic curve, exactly.

E[2] \\ {O} = {(e, y_e)} with e a root of the 2-division polynomial
    psi_2(x) = 4x^3 + b2 x^2 + 2 b4 x + b6,
and Gal(Q-bar/Q) acts on E[2] through the permutation of the three roots: the image of
rho_2 : Gal -> GL_2(F_2) = S_3 is the Galois group of the cubic.  It is S_3 or C_3 (psi_2
irreducible, discriminant a non-square resp. a square), C_2 (exactly one rational root) or
trivial (three rational roots).  Frobenius classes: Frob_p acts on the roots mod p with cycle
type read from the factorisation of psi_2 mod p (Dedekind), i.e. rho_2(Frob_p) has order 3, 2
or 1 according as psi_2 mod p has 0, 1 or 3 roots.
"""
from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction

from .galois_rep import frobenius_matrix
from .newforms import RationalNewform

Mat = tuple[int, int, int, int]
CLASSES: dict[tuple[int, int, bool], str] = {(1, 1, False): "ord3", (0, 1, False): "ord2", (0, 1, True): "id"}


def psi2_coefficients(a_invariants: tuple[int, int, int, int, int]) -> tuple[int, int, int, int]:
    """(4, b2, 2 b4, b6): psi_2 = 4x^3 + b2 x^2 + 2 b4 x + b6."""
    a1, a2, a3, a4, a6 = a_invariants
    b2, b4, b6 = a1 * a1 + 4 * a2, 2 * a4 + a1 * a3, a3 * a3 + 4 * a6
    return 4, b2, 2 * b4, b6


def _divisors(n: int) -> tuple[int, ...]:
    n = abs(n)
    return tuple(d for d in range(1, n + 1) if n % d == 0)


def rational_roots_of_cubic(c: tuple[int, int, int, int]) -> tuple[Fraction, ...]:
    """All rational roots of c3 x^3 + c2 x^2 + c1 x + c0 (rational root theorem; c3 != 0)."""
    c3, c2, c1, c0 = c
    if c0 == 0:
        return (Fraction(0),) + tuple(r for r in rational_roots_of_quadratic_or_less(c3, c2, c1) if r != 0)
    cands = {Fraction(s * p, q) for p in _divisors(c0) for q in _divisors(c3) for s in (1, -1)}
    return tuple(sorted(x for x in cands if c3 * x**3 + c2 * x**2 + c1 * x + c0 == 0))


def rational_roots_of_quadratic_or_less(c2: int, c1: int, c0: int) -> tuple[Fraction, ...]:
    if c0 == 0:
        return (Fraction(0),) if c2 == 0 or c1 == 0 else tuple(sorted({Fraction(0), Fraction(-c1, c2)}))
    cands = {Fraction(s * p, q) for p in _divisors(c0) for q in _divisors(c2 or 1) for s in (1, -1)}
    return tuple(sorted(x for x in cands if c2 * x**2 + c1 * x + c0 == 0))


def cubic_discriminant(c: tuple[int, int, int, int]) -> int:
    c3, c2, c1, c0 = c
    return c2 * c2 * c1 * c1 - 4 * c3 * c1**3 - 4 * c2**3 * c0 - 27 * c3 * c3 * c0 * c0 + 18 * c3 * c2 * c1 * c0


def is_square(n: int) -> bool:
    if n < 0:
        return False
    r = int(n**0.5)
    while r * r > n:
        r -= 1
    while (r + 1) * (r + 1) <= n:
        r += 1
    return r * r == n


def root_count_mod_p(c: tuple[int, int, int, int], p: int) -> int:
    c3, c2, c1, c0 = c
    return sum(1 for x in range(p) if (c3 * x**3 + c2 * x * x + c1 * x + c0) % p == 0)


@dataclass(frozen=True)
class Mod2Image:
    label: str
    group: str  # "S3", "C3", "C2", "1"
    rational_roots: tuple[Fraction, ...]
    witnesses: dict[str, tuple[int, Mat]]  # class -> (p, rho_2(Frob_p) on a computed basis)


def frobenius_class(M: Mat) -> str:
    a, b, c, d = M
    return CLASSES[((a + d) % 2, (a * d - b * c) % 2, M == (1, 0, 0, 1))]


def mod2_image(f: RationalNewform, primes: tuple[int, ...] = (5, 7, 11, 13, 17, 19, 23, 29, 31)) -> Mod2Image:
    c = psi2_coefficients(f.a_invariants)
    roots = rational_roots_of_cubic(c)
    group = {0: "S3" if not is_square(cubic_discriminant(c)) else "C3", 1: "C2", 3: "1"}[len(roots)]
    witnesses: dict[str, tuple[int, Mat]] = {}
    for p in primes:
        if p == f.conductor:
            continue
        M = frobenius_matrix(f.reduction(p), 2).matrix
        witnesses.setdefault(frobenius_class(M), (p, M))
    return Mod2Image(f.label, group, roots, witnesses)
