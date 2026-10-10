#!/usr/bin/env python3
"""Exact occupancy vector of the Hurwitz norm-n shell reduced modulo an odd prime ell.

Convention ``hurwitz-mod-ell/v1`` (docs/candidates/N3.md, "Data generator"):

* H = Z<1, i, j, (1+i+j+k)/2> with i^2 = j^2 = -1; an element is stored as its
  doubled coordinates 2x ∈ Z^4, all of one parity. Norm N(x) = |2x|^2 / 4.
* Shell S_n = {x ∈ H : N(x) = n}.
* For odd ell, H/ell·H ≅ F_ell^4 via x ↦ (2x)·2^{-1} mod ell (2 is a unit, so
  H ⊗ Z_ell is the Lipschitz order there).
* Target T = {v ∈ F_ell^4 : v_0^2 + v_1^2 + v_2^2 + v_3^2 = n mod ell}, every bin
  listed, zeros included. ell ∤ n is required: then every element of T is a
  unit of H/ell·H ≅ M_2(F_ell) and both unit actions below are free.
* ``unit_action``: ``none`` keeps S_n and T; ``left`` replaces both by their
  orbits under left multiplication by the 24 units of H, whose reduction is
  injective for ell ≥ 3. Reduction is equivariant, so orbits map to orbits.

Bins are ordered lexicographically by their least coordinate vector. Output is
a JSON payload whose ``multiplicities`` field feeds analyze_collisions.py.
"""

from __future__ import annotations

import json
import sys
from collections import Counter
from functools import cache
from itertools import product
from math import isqrt

SCHEMA = "novelty-lab/n3-occupancy/v1"
CONVENTION = "hurwitz-mod-ell/v1"
ACTIONS = ("none", "left")
Doubled = tuple[int, int, int, int]
Residue = tuple[int, int, int, int]


def shell(n: int) -> tuple[Doubled, ...]:
    """All doubled coordinates X with |X|^2 = 4n and X ≡ (c, c, c, c) mod 2, sorted."""
    if n < 1:
        raise ValueError("n must be positive")
    r, out = isqrt(4 * n), []
    for a, b, c in product(range(-r, r + 1), repeat=3):
        rest = 4 * n - a * a - b * b - c * c
        d = isqrt(rest) if rest >= 0 else -1
        if d >= 0 and d * d == rest and a % 2 == b % 2 == c % 2 == d % 2:
            out += [(a, b, c, d)] + ([(a, b, c, -d)] if d else [])
    return tuple(sorted(out))


def hamilton(x: tuple[int, ...], y: tuple[int, ...]) -> tuple[int, int, int, int]:
    """Hamilton product with i^2 = j^2 = -1, ij = k, on integer coordinates."""
    a1, b1, c1, d1 = x
    a2, b2, c2, d2 = y
    return (a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2, a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2,
            a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2, a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2)


def hmul(x: Doubled, y: Doubled) -> Doubled:
    """Product on doubled coordinates: 2(xy) = (2x)(2y)/2, exact on H."""
    p = hamilton(x, y)
    if any(t % 2 for t in p):
        raise ValueError("operands are not doubled Hurwitz coordinates")
    return tuple(t // 2 for t in p)


UNITS = shell(1)


def reduce_mod(x: Doubled, ell: int) -> Residue:
    half = pow(2, -1, ell)
    return tuple(t * half % ell for t in x)


def rmul(u: Residue, v: Residue, ell: int) -> Residue:
    """Hamilton product in H/ell·H ≅ F_ell^4."""
    return tuple(t % ell for t in hamilton(u, v))


@cache
def target(n: int, ell: int) -> tuple[Residue, ...]:
    m = n % ell
    return tuple(v for v in product(range(ell), repeat=4) if sum(t * t for t in v) % ell == m)


def occupancy(n: int, ell: int, unit_action: str = "none") -> dict:
    if ell < 3 or any(ell % p == 0 for p in range(2, isqrt(ell) + 1)):
        raise ValueError("ell must be an odd prime")
    if n % ell == 0:
        raise ValueError("ell must not divide n")
    if unit_action not in ACTIONS:
        raise ValueError(f"unit_action must be one of {ACTIONS}")
    units = tuple(reduce_mod(u, ell) for u in UNITS)
    canon = (lambda v: min(rmul(u, v, ell) for u in units)) if unit_action == "left" else (lambda v: v)
    bins = sorted({canon(v) for v in target(n, ell)})
    samples = shell(n) if unit_action == "none" else sorted({min(hmul(u, x) for u in UNITS) for x in shell(n)})
    counts = Counter(canon(reduce_mod(x, ell)) for x in samples)
    if not counts.keys() <= set(bins):
        raise AssertionError("a shell element reduced outside the target")
    return {"schema": SCHEMA, "convention": CONVENTION, "n": n, "ell": ell, "unit_action": unit_action,
            "shell_size": len(samples), "multiplicities": [counts[b] for b in bins]}


def main(argv: list[str]) -> int:
    if len(argv) not in (3, 4):
        print(f"usage: {argv[0]} N ELL [{'|'.join(ACTIONS)}]", file=sys.stderr)
        return 2
    try:
        print(json.dumps(occupancy(int(argv[1]), int(argv[2]), *argv[3:]), sort_keys=True))
    except ValueError as exc:
        print(f"refused: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
