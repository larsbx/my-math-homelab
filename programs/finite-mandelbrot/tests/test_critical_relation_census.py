"""The census-backed simple-residue-root verifier against exact polynomials.

`kernel/mojo/dynamics/critical_type_census.mojo` certifies simple residue
roots of R_{ell,k} = Q_{ell+k} - Q_ell past the Int-coefficient bounds of
`verify_simple_residue_root`. Its golden vectors are recomputed here from the
exact integer coefficients of Q_n and Q_n' (Python integers, no reduction
before evaluation) and from the exact integer critical orbit, so the oracle
shares neither the mod-p recurrence nor the census with the Mojo code.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.polynomial.poly_reference import q_polys, return_poly  # noqa: E402

SRC = ROOT / "kernel/mojo/dynamics/critical_type_census.mojo"
BRIDGE = ROOT / "kernel/mojo/dynamics/critical_relation_bridge.mojo"
GOLDEN = re.compile(r"Golden\((-?\d+), (\d+), (\d+), (\d+), (True|False), (True|False), (True|False)\)")


def evaluate(coeffs: list[int], c: int, p: int) -> int:
    return sum(a * pow(c, i, p) for i, a in enumerate(coeffs)) % p


def certificate(c: int, ell: int, k: int, p: int) -> tuple[bool, bool, bool]:
    relation = list(return_poly(ell, k).coeffs)
    derivative = list(return_poly(ell, k).derivative().coeffs)
    orbit = [0]
    for _ in range(ell + k):
        orbit.append(orbit[-1] ** 2 + c)
    residues = [z % p for z in orbit]
    pairs = [(i, j) for i in range(ell + k + 1) for j in range(i + 1, ell + k + 1)]
    exclusions = all((residues[i] == residues[j]) == ((i, j) == (ell, ell + k)) for i, j in pairs)
    return evaluate(relation, c, p) == 0, exclusions, evaluate(derivative, c, p) != 0


def golden() -> list[tuple[int, int, int, int, tuple[bool, bool, bool]]]:
    rows = GOLDEN.findall(SRC.read_text(encoding="utf-8"))
    return [(int(c), int(ell), int(k), int(p), tuple(flag == "True" for flag in flags))
            for c, ell, k, p, *flags in rows]


def is_prime(n: int) -> bool:
    return n > 1 and all(n % d for d in range(2, int(n**0.5) + 1))


def test_every_golden_certificate_matches_exact_polynomials():
    rows = golden()
    assert len(rows) >= 10
    for c, ell, k, p, expected in rows:
        assert is_prime(p) and p < 2**32
        assert certificate(c, ell, k, p) == expected, (c, ell, k, p)


def test_the_golden_vectors_lie_past_both_polynomial_bounds():
    rows = golden()
    assert any(ell + k > 8 and p > 2**20 and all(flags) for _, ell, k, p, flags in rows)
    assert any(p > 2**24 and all(flags) for _, _, _, p, flags in rows)
    assert any(p > 2**31 and all(flags) for _, _, _, p, flags in rows)
    assert {flags for *_, flags in rows} >= {(True, True, True), (True, False, False), (False, False, True)}


def test_the_polynomial_horizon_is_where_int_coefficients_end():
    qs = q_polys(8)
    bits = {n: max(abs(a) for a in qs[n].coeffs).bit_length() for n in (7, 8)}
    derivative_bits = max(abs(a) for a in qs[7].derivative().coeffs).bit_length()
    assert bits[7] <= 62 and derivative_bits <= 62 and bits[8] > 63
    assert "comptime MAX_BRIDGE_HORIZON = 7" in BRIDGE.read_text(encoding="utf-8")
