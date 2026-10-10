#!/usr/bin/env python3
"""Exact-type polynomials of the critical orbit and their irreducibility certificates.

Non-authoritative reference for kernel/mojo/dynamics/exact_type_irreducibility.mojo.

E_{ell,k} in Z[C] is the monic polynomial whose roots are the parameters of exact
critical-orbit type (ell, k). It is computed exactly: R_{ell,k} = Q_{ell+k} - Q_ell
is divided by each lower E_{mu,lambda} (mu <= ell, lambda | k) as often as it
divides. That multiplicity is the true one once the lower E are irreducible,
so the certificates are checked in increasing type order.

A certificate is a list of primes p at which E mod p is squarefree, with the
factor degrees of E mod p. If E = G H over Q, then by Gauss's lemma G and H are
monic in Z[C], so deg G is a subset sum of the factor degrees at every prime.
E is irreducible when the subset sums common to the certificate are {0, deg E}.
"""

from __future__ import annotations

import sys
from functools import cache
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from reference.python.polynomial.poly_reference import return_poly  # noqa: E402

Poly = list[int]  # ascending powers of C
HORIZON = 10  # the kernel's CERTIFIED_HORIZON


def trim(a: Poly) -> Poly:
    a = list(a) or [0]
    while len(a) > 1 and a[-1] == 0:
        a.pop()
    return a


def divmod_monic(a: Poly, b: Poly, p: int | None = None) -> tuple[Poly, Poly]:
    """Quotient and remainder by monic b, over Z or (with p) over F_p."""
    red = (lambda x: x % p) if p else (lambda x: x)
    a = [red(x) for x in a]
    q = [0] * max(len(a) - len(b) + 1, 1)
    for i in range(len(a) - len(b), -1, -1):
        c = a[i + len(b) - 1]
        q[i] = c
        if c:
            for j, x in enumerate(b):
                a[i + j] = red(a[i + j] - c * x)
    return trim(q), trim(a[: len(b) - 1])


def types(horizon: int) -> list[tuple[int, int]]:
    """Exact types with ell + k <= horizon in increasing order; preperiod 1 is empty."""
    return [(h - k, k) for h in range(1, horizon + 1) for k in range(1, h + 1) if h - k != 1]


def below(t: tuple[int, int], u: tuple[int, int]) -> bool:
    return u != t and u[0] <= t[0] and t[1] % u[1] == 0


@cache
def exact_type(ell: int, k: int) -> tuple[tuple[int, ...], tuple[tuple[int, int, int], ...]]:
    """(E_{ell,k}, ((mu, lambda, multiplicity), ...)) with R = E * prod E_lower^m over Z."""
    rest = list(return_poly(ell, k).coeffs)
    multiplicities = []
    for u in types(ell + k):
        if below((ell, k), u):
            lower = list(exact_type(*u)[0])
            m = 0
            while True:
                q, r = divmod_monic(rest, lower)
                if r != [0]:
                    break
                rest, m = q, m + 1
            if m:
                multiplicities.append((*u, m))
    return tuple(rest), tuple(multiplicities)


def mul(a: Poly, b: Poly, p: int) -> Poly:
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                out[i + j] = (out[i + j] + x * y) % p
    return out


def gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = trim([x % p for x in a]), trim([x % p for x in b])
    while b != [0]:
        inv = pow(b[-1], p - 2, p)
        b = [x * inv % p for x in b]
        a, b = b, divmod_monic(a, b, p)[1]
    return a


def factor_degrees(f: Poly, p: int) -> list[int] | None:
    """Sorted factor degrees of monic f mod p by distinct-degree factorization; None if not squarefree."""
    f = [x % p for x in f]
    d = len(f) - 1
    if len(gcd(f, [(i * f[i]) % p for i in range(1, d + 1)], p)) != 1:
        return None
    xp, base, e = [1], divmod_monic([0, 1], f, p)[1], p
    while e:
        if e & 1:
            xp = divmod_monic(mul(xp, base, p), f, p)[1]
        base = divmod_monic(mul(base, base, p), f, p)[1]
        e >>= 1
    frobenius = [[1]]
    for _ in range(1, d):
        frobenius.append(divmod_monic(mul(frobenius[-1], xp, p), f, p)[1])

    def frob(v: Poly) -> Poly:
        out = [0] * d
        for j, c in enumerate(v):
            if c:
                for i, x in enumerate(frobenius[j]):
                    out[i] = (out[i] + c * x) % p
        return trim(out)

    degrees, g, h, i = [], f, [0, 1], 0
    while len(g) - 1 >= 2 * (i + 1):
        i += 1
        h = frob(h)
        diff = h + [0] * max(0, 2 - len(h))
        diff[1] = (diff[1] - 1) % p
        t = gcd(g, trim(diff), p)
        if len(t) > 1:
            degrees += [i] * ((len(t) - 1) // i)
            g = divmod_monic(g, [x * pow(t[-1], p - 2, p) % p for x in t], p)[0]
    if len(g) > 1:
        degrees.append(len(g) - 1)
    return sorted(degrees)


def subset_sums(degrees: list[int]) -> int:
    reachable = 1
    for x in degrees:
        reachable |= reachable << x
    return reachable


def certifies(degree: int, patterns: list[list[int]]) -> bool:
    common = (1 << (degree + 1)) - 1
    for degrees in patterns:
        assert sum(degrees) == degree
        common &= subset_sums(degrees)
    return common == 1 | (1 << degree)


def find_certificate(f: Poly, bound: int = 1000) -> list[tuple[int, list[int]]] | None:
    d = len(f) - 1
    if d == 1:
        return []
    chosen: list[tuple[int, list[int]]] = []
    common = (1 << (d + 1)) - 1
    for p in range(3, bound, 2):
        if any(p % q == 0 for q in range(3, int(p**0.5) + 1, 2)):
            continue
        degrees = factor_degrees(f, p)
        if degrees is None or common & subset_sums(degrees) == common:
            continue
        common &= subset_sums(degrees)
        chosen.append((p, degrees))
        if common == 1 | (1 << d):
            return chosen
    return None


def main() -> int:
    for ell, k in types(HORIZON):
        f, _ = exact_type(ell, k)
        certificate = find_certificate(list(f))
        if certificate is None:
            print(f"({ell},{k}) degree {len(f) - 1}: no certificate below the bound")
            return 1
        print(f"({ell},{k}) degree {len(f) - 1}: primes {[p for p, _ in certificate]}")
    print(f"OK: every exact-type polynomial with ell + k <= {HORIZON} is certified irreducible over Q")
    return 0


if __name__ == "__main__":
    sys.exit(main())
