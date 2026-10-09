"""Hilbert symbols (a, b)_v for nonzero rationals at a place v of Q.

Places are ``"inf"`` or a prime written in decimal. The p-adic formulas are
Serre, *A Course in Arithmetic*, Ch. III, Theorem 1 — an imported theorem
recorded as `HilbertSymbolFormula` in research/ledger.json, not proved here.
A rational r and the integer r·den(r)^2 = num·den lie in one square class,
so every symbol is computed on integers.
"""

from __future__ import annotations

from fractions import Fraction

INF = "inf"


def square_class_integer(r: Fraction) -> int:
    if r == 0:
        raise ValueError("Hilbert symbols are defined on nonzero rationals")
    return r.numerator * r.denominator


def prime_factors(n: int) -> tuple[int, ...]:
    n, p, found = abs(n), 2, []
    while p * p <= n:
        if n % p == 0:
            found.append(p)
            while n % p == 0:
                n //= p
        p += 1
    return tuple(found + ([n] if n > 1 else []))


def is_prime(n: int) -> bool:
    return n > 1 and prime_factors(n) == (n,)


def _split(n: int, p: int) -> tuple[int, int]:
    """(valuation, unit part) of the nonzero integer n at p."""
    v = 0
    while n % p == 0:
        n, v = n // p, v + 1
    return v, n


def _legendre(u: int, p: int) -> int:
    return 1 if pow(u % p, (p - 1) // 2, p) == 1 else -1


def hilbert(a: Fraction, b: Fraction, place: str) -> int:
    """(a, b)_place ∈ {1, -1}."""
    a, b = square_class_integer(a), square_class_integer(b)
    if place == INF:
        return -1 if a < 0 and b < 0 else 1
    p = int(place)
    if str(p) != place or not is_prime(p):
        raise ValueError(f"not a place of Q: {place!r}")
    (alpha, u), (beta, v) = _split(a, p), _split(b, p)
    if p != 2:
        sign = -1 if alpha * beta * ((p - 1) // 2) % 2 else 1
        return sign * _legendre(u, p) ** beta * _legendre(v, p) ** alpha
    eps = lambda w: (w - 1) // 2 % 2  # noqa: E731
    omega = lambda w: (w * w - 1) // 8 % 2  # noqa: E731
    return -1 if (eps(u) * eps(v) + alpha * omega(v) + beta * omega(u)) % 2 else 1


def bad_places(a: Fraction, b: Fraction) -> tuple[str, ...]:
    """∞ and the primes dividing 2ab: the only places where (a, b)_v can be -1."""
    primes = prime_factors(2 * square_class_integer(a) * square_class_integer(b))
    return (INF,) + tuple(str(p) for p in primes)
