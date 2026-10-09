"""Exact integer identities used by the PV research ledger.

Execution here is finite COMPUTED evidence. General identities are proved in
the mathematical claim surfaces.
"""

from math import gcd


def defect(a0: int, a1: int, a2: int) -> int:
    return a0 * a2 - a1 * a1


def hankel3(a0: int, a1: int, a2: int, a3: int, a4: int) -> int:
    return (
        a0 * a2 * a4
        - a0 * a3 * a3
        - a1 * a1 * a4
        + 2 * a1 * a2 * a3
        - a2 * a2 * a2
    )


def dodgson_h3_sides(a0: int, a1: int, a2: int, a3: int, a4: int) -> tuple[int, int]:
    c0 = defect(a0, a1, a2)
    c1 = defect(a1, a2, a3)
    c2 = defect(a2, a3, a4)
    return a2 * hankel3(a0, a1, a2, a3, a4), c0 * c2 - c1 * c1


def transport_residue(a0: int, a1: int, a2: int, a3: int) -> int:
    if a1 == 0:
        raise ValueError("a1 must be nonzero")
    c0 = defect(a0, a1, a2)
    c1 = defect(a1, a2, a3)
    return (a0 * a0 * c1 + c0 * c0) % abs(a1)


def gcd_product_divides_defect(a0: int, a1: int, a2: int) -> bool:
    g0 = gcd(a0, a1)
    g1 = gcd(a1, a2)
    return defect(a0, a1, a2) % (g0 * g1) == 0


def two_step_return_shape(a0: int, a1: int, a2: int, g: int) -> tuple[int, int, int, int]:
    if g <= 0 or any(x % g for x in (a0, a1, a2)):
        raise ValueError("g must divide all displayed terms")
    u, v, w = a0 // g, a1 // g, a2 // g
    c = defect(a0, a1, a2)
    if c % (g * g):
        raise AssertionError("scaled defect must be divisible by g^2")
    e = c // (g * g)
    assert u * w - v * v == e
    return u, v, w, e
