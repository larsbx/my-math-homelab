"""Irreducibility certificates of the exact-type polynomials, against the exact reference.

`kernel/mojo/dynamics/exact_type_irreducibility.mojo` replays factor patterns
of E_{ell,k} mod p from a multiplicity table. Here the table is recomputed by
exact division over Z, the identity R = E * prod E_lower^m is rebuilt over Z,
and every pattern is recomputed with the reference's own factorization.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.polynomial.exact_type_irreducibility import (  # noqa: E402
    HORIZON, certifies, exact_type, factor_degrees, types,
)
from reference.python.polynomial.poly_reference import return_poly  # noqa: E402

SRC = ROOT / "kernel/mojo/dynamics/exact_type_irreducibility.mojo"
MULTIPLICITY = re.compile(r"Multiplicity\((\d+), (\d+), (\d+), (\d+), (\d+)\)")
PATTERN = re.compile(r'FactorPattern\((\d+), (\d+), (\d+), "([\d ]+)"\)')


def source() -> str:
    return SRC.read_text(encoding="utf-8")


def times(a: list[int], b: list[int]) -> list[int]:
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            out[i + j] += x * y
    return out


def test_the_multiplicity_table_is_exact_division_over_z():
    table = {tuple(map(int, row)) for row in MULTIPLICITY.findall(source())}
    expected = {(ell, k, *row) for ell, k in types(HORIZON) for row in exact_type(ell, k)[1]}
    assert table == expected


def test_each_relation_factors_as_its_exact_type_times_the_lower_types():
    for ell, k in types(HORIZON):
        e, rows = exact_type(ell, k)
        product = list(e)
        for mu, lam, m in rows:
            for _ in range(m):
                product = times(product, list(exact_type(mu, lam)[0]))
        assert product == list(return_poly(ell, k).coeffs), (ell, k)
        assert e[-1] == 1


def test_every_pattern_is_the_factorization_mod_p_and_every_type_is_certified():
    patterns: dict[tuple[int, int], list[list[int]]] = {}
    for ell, k, p, degrees in PATTERN.findall(source()):
        ell, k, p = int(ell), int(k), int(p)
        claimed = list(map(int, degrees.split()))
        assert factor_degrees(list(exact_type(ell, k)[0]), p) == claimed, (ell, k, p)
        patterns.setdefault((ell, k), []).append(claimed)
    for ell, k in types(HORIZON):
        degree = len(exact_type(ell, k)[0]) - 1
        assert degree == 1 or certifies(degree, patterns[(ell, k)]), (ell, k)


def test_the_reference_horizon_is_the_kernels():
    assert f"comptime CERTIFIED_HORIZON = {HORIZON}" in source()


def test_a_product_of_exact_types_never_certifies():
    product = times(list(exact_type(0, 3)[0]), list(exact_type(3, 1)[0]))
    patterns = [d for p in (3, 5, 7, 11, 13, 17, 19, 23) if (d := factor_degrees(product, p))]
    assert len(patterns) >= 3 and not certifies(6, patterns)
