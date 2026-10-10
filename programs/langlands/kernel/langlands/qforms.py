"""Class numbers of imaginary quadratic orders by exhaustive reduced-form count.

h(d) = number of SL_2(Z)-classes of primitive positive-definite binary quadratic
forms of discriminant d < 0 = class number of the order O_d.  w(d) = |O_d^x|.
H(N) is the Hurwitz class number (weights 1/2 at d=-4, 1/3 at d=-3, H(0)=-1/12).
"""
from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from math import gcd, isqrt


def is_discriminant(d: int) -> bool:
    return d < 0 and d % 4 in (0, 1)


@lru_cache(maxsize=None)
def reduced_forms(d: int) -> tuple[tuple[int, int, int], ...]:
    """Primitive reduced forms (a, b, c), b^2 - 4ac = d, |b| <= a <= c,
    with b >= 0 when |b| = a or a = c."""
    if not is_discriminant(d):
        raise ValueError(f"{d} is not a negative discriminant")
    forms = []
    a_max = isqrt(-d // 3)
    for a in range(1, a_max + 1):
        for b in range(-a, a + 1):
            if (b * b - d) % (4 * a):
                continue
            c = (b * b - d) // (4 * a)
            if c < a or gcd(gcd(a, abs(b)), c) != 1:
                continue
            if b < 0 and (abs(b) == a or a == c):
                continue
            forms.append((a, b, c))
    return tuple(forms)


def class_number(d: int) -> int:
    return len(reduced_forms(d))


def unit_count(d: int) -> int:
    return {-3: 6, -4: 4}.get(d, 2)


def kronecker(d: int, p: int) -> int:
    """(d/p) for an odd prime p: Legendre symbol of d mod p (0 when p | d)."""
    r = pow(d % p, (p - 1) // 2, p)
    return 0 if r == 0 else (1 if r == 1 else -1)


def square_divisors_of_discriminant(D: int):
    """Yield (f, d) with f^2 | D, d = D / f^2 a discriminant (all orders containing Z[alpha])."""
    f = 1
    while f * f <= -D:
        if D % (f * f) == 0 and is_discriminant(D // (f * f)):
            yield f, D // (f * f)
        f += 1


def hurwitz(N: int) -> Fraction:
    """H(N) = sum over d f^2 = -N of h(d)/(w(d)/2), with H(0) = -1/12."""
    if N == 0:
        return Fraction(-1, 12)
    if N < 0 or N % 4 in (1, 2):
        return Fraction(0)
    return sum((Fraction(2 * class_number(d), unit_count(d)) for _, d in square_divisors_of_discriminant(-N)), Fraction(0))
