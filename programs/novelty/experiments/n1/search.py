#!/usr/bin/env python3
"""Non-authoritative certificate search for N1; every output must pass kernel/n1/certificate.py.

The search uses the first quaternion subalgebra (a_1, a_2) ⊂ A_n only:

1. a place v with (a_1, a_2)_v = -1 gives a ``division`` certificate when n = 2;
2. otherwise a bounded search for integers z^2 = a_1 x^2 + a_2 y^2, (x, y) ≠ 0,
   gives q = z + x i + y j of norm 0 and the zero divisor pair (q, conj q),
   embedded into A_n.

Neither failing is evidence of anything: the search returns None (inconclusive).
In particular nothing here decides division for n ≥ 3.
"""

from __future__ import annotations

import json
import sys
from fractions import Fraction
from itertools import product
from math import isqrt
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "kernel"))

from n1 import cayley_dickson as cd  # noqa: E402
from n1.certificate import CONVENTION, SCHEMA  # noqa: E402
from n1.hilbert import bad_places, hilbert  # noqa: E402


def certificate(params: cd.Params, verdict: str, witness: dict) -> dict:
    return {"schema": SCHEMA, "field": "Q", "convention": CONVENTION, "parameters": [str(p) for p in params],
            "verdict": verdict, "witness": witness}


def ramified_place(a: Fraction, b: Fraction) -> str | None:
    return next((v for v in bad_places(a, b) if hilbert(a, b, v) == -1), None)


def isotropic_vector(a: Fraction, b: Fraction, bound: int) -> tuple[int, int, int] | None:
    """Least-height integers (z, x, y), (x, y) ≠ 0, |x|, |y| ≤ bound, with z^2 = a x^2 + b y^2."""
    for x, y in sorted(product(range(-bound, bound + 1), repeat=2), key=lambda t: (max(map(abs, t)), t)):
        rhs = a * x * x + b * y * y
        if (x, y) != (0, 0) and rhs >= 0 and rhs.denominator == 1 and isqrt(rhs.numerator) ** 2 == rhs.numerator:
            return isqrt(rhs.numerator), x, y
    return None


def search(params: cd.Params, bound: int = 12) -> dict | None:
    if len(params) < 2:
        return None
    a, b = params[:2]
    place = ramified_place(a, b)
    if place is not None:
        return certificate(params, "division", {"place": place}) if len(params) == 2 else None
    found = isotropic_vector(a, b, bound)
    if found is None:
        return None
    z, x, y = found
    q = cd.embed(tuple(map(Fraction, (z, x, y, 0))), len(params))
    return certificate(params, "zero_divisor", {"x": [str(c) for c in q], "y": [str(c) for c in cd.conj(q)]})


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        print(f"usage: {argv[0]} A_1 A_2 [A_3 ...]", file=sys.stderr)
        return 2
    cert = search(tuple(map(Fraction, argv[1:])))
    print(json.dumps(cert, indent=2) if cert else "inconclusive")
    return 0 if cert else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
