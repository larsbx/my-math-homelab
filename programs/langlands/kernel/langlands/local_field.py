"""K_oo = F_p((pi)), pi = 1/t: exact Laurent polynomials and truncated division.

An element is a dict {exponent: coefficient mod p} with nonzero coefficients only
(immutable use: functions return new dicts; callers never mutate).  A polynomial
f(t) = sum f_i t^i is the Laurent polynomial sum f_i pi^{-i}.
"""
from __future__ import annotations

from typing import Mapping

Laurent = Mapping[int, int]


def from_poly(f: tuple[int, ...], p: int) -> dict[int, int]:
    """f(t) (coefficients low -> high in t) as a Laurent polynomial in pi = 1/t."""
    return {-i: c % p for i, c in enumerate(f) if c % p}


def valuation(a: Laurent) -> int | None:
    return min(a) if a else None


def add(a: Laurent, b: Laurent, p: int) -> dict[int, int]:
    out = dict(a)
    for e, c in b.items():
        v = (out.get(e, 0) + c) % p
        if v:
            out[e] = v
        else:
            out.pop(e, None)
    return out


def neg(a: Laurent, p: int) -> dict[int, int]:
    return {e: (-c) % p for e, c in a.items()}


def mul(a: Laurent, b: Laurent, p: int) -> dict[int, int]:
    out: dict[int, int] = {}
    for e1, c1 in a.items():
        for e2, c2 in b.items():
            out[e1 + e2] = (out.get(e1 + e2, 0) + c1 * c2) % p
    return {e: c for e, c in out.items() if c}


def scale(c: int, a: Laurent, p: int) -> dict[int, int]:
    return {e: (c * x) % p for e, x in a.items() if (c * x) % p}


def truncate(a: Laurent, below: int) -> dict[int, int]:
    """Keep exponents < below (the class of a in K_oo / pi^below O_oo)."""
    return {e: c for e, c in a.items() if e < below}


def div(a: Laurent, b: Laurent, p: int, precision: int) -> dict[int, int]:
    """a / b as a Laurent series, exact modulo pi^precision (b != 0)."""
    vb = valuation(b)
    if vb is None:
        raise ZeroDivisionError
    lead_inv = pow(b[vb], -1, p)
    rem = dict(a)
    out: dict[int, int] = {}
    while rem:
        vr = min(rem)
        e = vr - vb
        if e >= precision:
            break
        c = rem[vr] * lead_inv % p
        out[e] = c
        rem = add(rem, neg(mul({e: c}, b, p), p), p)
    return out


def polynomial_part(a: Laurent) -> dict[int, int]:
    """Exponents <= 0: the part in A = F_p[t]."""
    return {e: c for e, c in a.items() if e <= 0}


def to_poly(a: Laurent, p: int) -> tuple[int, ...]:
    """A Laurent polynomial with exponents <= 0, as a polynomial in t (low -> high)."""
    if any(e > 0 for e in a):
        raise ValueError("not a polynomial in t")
    if not a:
        return ()
    deg = -min(a)
    return tuple(a.get(-i, 0) for i in range(deg + 1))
