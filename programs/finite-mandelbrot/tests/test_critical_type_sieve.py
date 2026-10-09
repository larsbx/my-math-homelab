"""Exact-type counts over F_p against exact critical-relation polynomials.

`kernel/mojo/dynamics/critical_type_sieve.mojo` tallies N_p(ell, k) by
iterating the critical orbit. Here the same counts come from root counts of
the exact integer polynomials R_{ell,k} = Q_{ell+k} - Q_ell, inverted over the
order (mu, lambda) <= (ell, k) iff mu <= ell and lambda | k, so the oracle
shares no iteration with the Mojo code.
"""

from __future__ import annotations

import re
import sys
from functools import cache
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.polynomial.poly_reference import PolyZ, factor_product, return_poly  # noqa: E402

SRC = ROOT / "kernel/mojo/dynamics/critical_type_sieve.mojo"
GOLDEN = re.compile(r"GoldenCount\((\d+), (\d+), (\d+), (\d+)\)")


def roots_mod_p(ell: int, k: int, p: int) -> int:
    coeffs = [a % p for a in reversed(return_poly(ell, k).coeffs)]
    def value(c: int) -> int:
        acc = 0
        for a in coeffs:
            acc = (acc * c + a) % p
        return acc
    return sum(value(c) == 0 for c in range(p))


@cache
def exact_type_count(p: int, ell: int, k: int) -> int:
    below = [(mu, lam) for mu in range(ell + 1) for lam in range(1, k + 1)
             if k % lam == 0 and (mu, lam) != (ell, k)]
    return roots_mod_p(ell, k, p) - sum(exact_type_count(p, mu, lam) for mu, lam in below)


def golden() -> list[tuple[int, int, int, int]]:
    return [tuple(map(int, row)) for row in GOLDEN.findall(SRC.read_text(encoding="utf-8"))]


def test_every_golden_count_matches_exact_polynomials():
    rows = golden()
    assert len(rows) >= 10
    for p, ell, k, count in rows:
        assert exact_type_count(p, ell, k) == count, (p, ell, k)


def test_the_goldens_cover_gleason_misiurewicz_and_the_empty_preperiod():
    rows = golden()
    assert any(ell == 0 and k >= 3 for _, ell, k, _ in rows)
    assert any(ell >= 2 for _, ell, _, _ in rows)
    assert any(ell == 1 and count == 0 for _, ell, _, count in rows)


def test_squarefree_exact_type_factor_can_collide_with_a_lower_type_mod_p():
    """Own-discriminant good reduction alone does not preserve exact type."""
    c = PolyZ.c()
    e22 = PolyZ((1, 0, 1))
    e21 = PolyZ((2, 1))
    assert return_poly(2, 2) == factor_product([c, c, c, PolyZ((1, 1)), PolyZ((1, 1)), e21, e22])

    def value(poly: PolyZ, x: int) -> int:
        return sum(a * x**i for i, a in enumerate(poly.coeffs))

    roots = {x for x in range(5) if value(e22, x) % 5 == 0}
    assert roots == {2, 3}
    assert all(value(e22.derivative(), x) % 5 != 0 for x in roots)
    # For the monic linear factor C+2, the collision resultant is E22(-2).
    assert value(e22, -2) == 5
    assert value(e21, 3) % 5 == 0
    assert exact_type_count(5, 2, 1) == 1
    assert exact_type_count(5, 2, 2) == 1 < len(roots)
