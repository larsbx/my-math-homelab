"""Independent finite cyclotomic polynomial research for finite-math-kernels.

Reconstructs Phi_n in Z[X] by exact monic division of X^n - 1 by the
product of all previously derived Phi_d, d | n, d < n. This is separate
from the source's cyclotomic germ generator and Mojo code.

Checks all 22 registered (q,p) primitive-power vectors for q <= 8,
including an independent polynomial reduction Phi_q(X^p) = 0 mod Phi_q.
This DOES NOT verify the source's parabolic reciprocal coefficients,
their byte encoding, or universal analytic/germ theorems.
"""
from __future__ import annotations

from hashlib import sha256
from math import gcd
import json


def require(ok, why):
    if not ok:
        raise ValueError(why)


def trim(p):
    p = list(p)
    while len(p) > 1 and p[-1] == 0:
        p.pop()
    return p


def multiply(a, b):
    c = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            c[i + j] += x * y
    return trim(c)


def exact_monic_division(numerator, denominator):
    """Z[X] quotient; reject any nonzero remainder or nonmonic divisor."""
    numerator = trim(numerator)
    denominator = trim(denominator)
    require(denominator[-1] == 1, "nonmonic divisor")
    if len(numerator) < len(denominator):
        raise ValueError("nonzero remainder")
    current = numerator[:]
    out = [0] * (len(numerator) - len(denominator) + 1)
    for k in range(len(out) - 1, -1, -1):
        q = current[k + len(denominator) - 1]
        out[k] = q
        for j, d in enumerate(denominator):
            current[k + j] -= q * d
    require(all(x == 0 for x in current), "nonzero integer polynomial remainder")
    return trim(out)


def remainder(a, monic):
    monic = trim(monic)
    require(monic[-1] == 1, "polynomial not monic")
    current = trim(a)
    for k in range(len(current)-len(monic),-1,-1):
        coeff = current[k+len(monic)-1]
        for j,d in enumerate(monic):
            current[k+j] -= coeff*d
    return trim(current)


def cyclotomic_table(limit):
    require(type(limit) is int and 1 <= limit <= 32, "unsupported research bound")
    output = {}
    for n in range(1,limit+1):
        dividend = [-1] + [0]*(n-1) + [1]
        factor = [1]
        for divisor in range(1,n):
            if n % divisor == 0:
                factor = multiply(factor, output[divisor])
        output[n] = exact_monic_division(dividend, factor)
    return output


def primitive_power_reduction(n, p, phi):
    """Independent exact vanishing of Phi_n(X^p) in Z[X]/(Phi_n)."""
    require(gcd(n,p) == 1, "nonprimitive power")
    sparse = [0]*(p*(len(phi)-1)+1)
    for i, coefficient in enumerate(phi):
        sparse[p*i] = coefficient
    return remainder(sparse, phi)


def verify_vectors(fixture, *, source_commit, source_sha256):
    require(fixture.get("schema") == "cyclotomic-germ/v1", "wrong source schema")
    require(fixture.get("authority") == "none", "fixture authority changed")
    require(isinstance(source_commit,str) and len(source_commit) == 40
            and all(c in "0123456789abcdef" for c in source_commit),
            "missing immutable source commit")
    require(isinstance(source_sha256,str) and len(source_sha256) == 64
            and all(c in "0123456789abcdef" for c in source_sha256),
            "missing source SHA-256")
    table = fixture["cyclotomic_polynomials"]
    require(set(table) == {str(n) for n in range(1,9)},
            "changed bounded finite research domain")
    calculated = cyclotomic_table(8)
    for n, polynomial in calculated.items():
        require(table[str(n)] == polynomial, f"Phi_{n} coefficient mismatch")
    seen = set()
    records = []
    for item in fixture["vectors"]:
        q, p = item["q"], item["p"]
        require(type(q) is int and type(p) is int
                and 1 <= q <= 8 and 1 <= p <= q and gcd(q,p) == 1,
                "nonprimitive q/p vector")
        require((q,p) not in seen, "duplicate primitive vector")
        seen.add((q,p))
        deg = len(calculated[q])-1
        require(len(item["parabolic_factor_constant"]) == deg
                and len(item["reciprocal_coefficient"]) == deg,
                "coefficient vector dimension mismatch")
        require(all(isinstance(s,str) for s in
                    item["parabolic_factor_constant"]+
                    item["reciprocal_coefficient"]),
                "noncanonical coefficient shape")
        require(primitive_power_reduction(q,p,calculated[q]) == [0],
                f"nonprimitive polynomial class: {q}/{p}")
        records.append({"q":q,"p":p,"degree":deg,"primitive_power_zero":True})
    expected = {(q,p) for q in range(1,9) for p in range(1,q+1)
                if gcd(q,p) == 1}
    require(seen == expected, "primitive cyclotomic vector coverage incomplete")
    return {
        "schema": "HOMELAB-FMK-CYCLOTOMIC-FINITE-EXACT-1",
        "source_commit":source_commit,
        "source_fixture_sha256":source_sha256,
        "bound_q":8,
        "polynomials_verified":len(calculated),
        "primitive_powers_verified":len(records),
        "reconstructed_degrees":{str(k):len(v)-1 for k,v in calculated.items()},
        "methods":["independent_Z_polynomial_exact_monic_division",
                   "independent_primitive_power_quotient_ring_vanishing"],
        "vectors":records,
        "parabolic_coefficients_checked":False,
        "byte_encoding_checked":False,
        "universal_mathematical_claim_accepted":False,
        "verdict":"finite_cyclotomic_polynomial_fixtures_verified",
        "next_research_obligation":
            "Independently derive and replay q<=8 parabolic germ coefficients "
            "and canonical rational byte encoding; extend exact cyclotomic field "
            "tests only with source-owned hypothesis and cap.",
    }
