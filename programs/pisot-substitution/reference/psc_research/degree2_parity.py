"""Mod-2 characteristic-polynomial sieve for degree-2 strict SCCs.

For a strict closed nonproductive SCC whose first nonzero scattered-subword
defect is K2, the existing intertwiners give

    chi_M       | chi_N,
    chi_Lambda2 | chi_S,

with integer matrices N=A+B and S=A-B.  Since N == S (mod 2), their
characteristic polynomials are equal over F_2.  Hence that common polynomial
must be divisible by both reduced cubics, giving a lower bound on the SCC size
from their least common multiple.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class ParitySieveResult:
    trace_parity: int
    second_parity: int
    det_parity: int
    characteristic_mod2: int
    exterior_characteristic_mod2: int
    gcd_mod2: int
    lcm_degree: int


def _degree(poly: int) -> int:
    if poly <= 0:
        raise ValueError("polynomial bitmask must be nonzero")
    return poly.bit_length() - 1


def _remainder(a: int, b: int) -> int:
    """Remainder of `a` modulo `b` in `F_2[t]`, on nonnegative coefficient bitmasks.

    Each degree is taken once per iteration and the divisor's once in total, but
    always through `_degree`, which stays the single validation point.  A negative
    bitmask is an impossible exact-arithmetic state, so a caller reaching this
    helper without passing through `gcd_mod2` still fails closed: substituting a
    raw `bit_length()` would make `_remainder(-1, 1)` oscillate between `-1` and
    `-2` forever and let a negative divisor return a meaningless remainder.
    """
    if b == 0:
        raise ZeroDivisionError("polynomial division by zero")
    if a == 0:
        return 0
    deg_b = _degree(b)
    deg_a = _degree(a)
    while deg_a >= deg_b:
        a ^= b << (deg_a - deg_b)
        if a == 0:
            return 0
        deg_a = _degree(a)
    return a


def gcd_mod2(a: int, b: int) -> int:
    """Monic gcd in F_2[t], with polynomials stored as coefficient bitmasks."""
    if a <= 0 or b <= 0:
        raise ValueError("polynomial bitmasks must be nonzero")
    while b:
        a, b = b, _remainder(a, b)
    return a


def characteristic_cubic_mod2(trace: int, second: int, det: int) -> int:
    """Bitmask for t^3 + T t^2 + U t + d over F_2.

    The integral characteristic polynomial is
        t^3 - T t^2 + U t - d.
    Signs disappear modulo two.
    """
    t = trace & 1
    u = second & 1
    d = det & 1
    return (1 << 3) | (t << 2) | (u << 1) | d


def exterior_characteristic_cubic_mod2(trace: int, second: int, det: int) -> int:
    """Bitmask for chi_{Lambda^2 M} modulo two.

    If chi_M(t)=t^3-T t^2+U t-d, then
        chi_{Lambda^2 M}(t)=t^3-U t^2+d T t-d^2.
    """
    t = trace & 1
    u = second & 1
    d = det & 1
    return (1 << 3) | (u << 2) | ((d * t) << 1) | d


def parity_sieve(trace: int, second: int, det: int) -> ParitySieveResult:
    p = characteristic_cubic_mod2(trace, second, det)
    q = exterior_characteristic_cubic_mod2(trace, second, det)
    g = gcd_mod2(p, q)
    lcm_degree = _degree(p) + _degree(q) - _degree(g)
    return ParitySieveResult(
        trace_parity=trace & 1,
        second_parity=second & 1,
        det_parity=det & 1,
        characteristic_mod2=p,
        exterior_characteristic_mod2=q,
        gcd_mod2=g,
        lcm_degree=lcm_degree,
    )


def minimum_degree2_scc_size_from_parity(trace: int, second: int, det: int) -> int:
    """Necessary SCC-size lower bound supplied by the mod-2 quotient sieve."""
    return parity_sieve(trace, second, det).lcm_degree
