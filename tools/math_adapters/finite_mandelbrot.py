"""Exact finite-field critical-relation certificate replay, not an MLC proof.

Reads current source's *textual Golden fixtures* from its Mojo critical-type
census without importing or executing any source repository code.

Method A: evaluate critical orbit and its formal parameter derivative by
dual-number recurrence in F_p; identify every pairwise orbit collision.
Method B: independently construct the integer-polynomial recurrence
Q_0=0, Q_(n+1)=Q_n^2+C, reduced coefficient-wise modulo p; evaluate
R_(ell,k) and its formal polynomial derivative by Horner. Both methods
must independently reproduce every declared Golden relation, exclusion,
and simple-root flag.

This proves only the displayed finite examples. It does not establish
parameter-space geometry, global dynamics, MLC, or mathematical novelty.
"""
from __future__ import annotations

from functools import lru_cache
from math import isqrt
import re


GOLDEN = re.compile(
    r"Golden\((-?\d+), (\d+), (\d+), (\d+), (True|False), "
    r"(True|False), (True|False)\)"
)


def require(condition, reason):
    if not condition:
        raise ValueError(reason)


def is_prime(n):
    if type(n) is not int or n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    return all(n % d for d in range(3, isqrt(n)+1, 2))


def parse_golden(source):
    require(isinstance(source, str), "source must be UTF-8 text")
    rows = []
    for m in GOLDEN.finditer(source):
        c, ell, k, p = map(int, m.group(1,2,3,4))
        values = tuple(m.group(i) == "True" for i in (5,6,7))
        require(0 <= ell and 1 <= k and ell+k <= 12, "horizon cap changed")
        require(2 < p < 2**32 and is_prime(p), "prime field invalid")
        rows.append((c,ell,k,p,values))
    require(len(rows) == 11, "finite Golden vector domain changed")
    require(len({row[:4] for row in rows}) == 11, "duplicate Golden case")
    require(any(ell+k > 8 and p > 2**20 and all(flags)
                for _,ell,k,p,flags in rows),
            "missing large-horizon positive control")
    require({flags for *_,flags in rows} >= {
        (True,True,True), (True,False,False), (False,False,True)
    }, "missing negative controls")
    return rows


def dual_critical_relation(c, ell, k, p):
    """A: directly iterate formal tangent and critical orbit modulo p."""
    horizon = ell+k
    orbit = [0]
    tangent = [0]
    for _ in range(horizon):
        value, derivative = orbit[-1], tangent[-1]
        orbit.append((value*value+c) % p)
        tangent.append((2*value*derivative+1) % p)
    collisions = [(i,j) for j in range(1,horizon+1)
                  for i in range(j) if orbit[i] == orbit[j]]
    return (
        orbit[ell] == orbit[horizon],
        collisions == [(ell,horizon)],
        (tangent[horizon]-tangent[ell]) % p != 0,
    )


def poly_product_mod(a,b,p):
    """B: independent exact coefficient convolution in F_p[C]."""
    out = [0]*(len(a)+len(b)-1)
    for i,x in enumerate(a):
        if not x:
            continue
        for j,y in enumerate(b):
            if y:
                out[i+j] = (out[i+j]+x*y) % p
    return tuple(out)


@lru_cache(maxsize=12)
def critical_polynomials(p, horizon):
    require(2 < p < 2**32 and is_prime(p), "prime field invalid")
    require(type(horizon) is int and 1 <= horizon <= 12,
            "finite horizon outside declared cap")
    q=[(0,)]
    for _ in range(horizon):
        square=list(poly_product_mod(q[-1],q[-1],p))
        if len(square) < 2:
            square.append(0)
        square[1] = (square[1]+1) % p
        q.append(tuple(square))
    return q


def horner(coeff,c,p):
    v=0
    for a in reversed(coeff):
        v=(v*c+a)%p
    return v


def derivative_horner(coeff,c,p):
    v=0
    for i in range(len(coeff)-1,0,-1):
        v=(v*c+i*coeff[i])%p
    return v


def polynomial_relation(c,ell,k,p):
    """B: independent polynomial equality and simple-root tests."""
    polys=critical_polynomials(p,ell+k)
    a,b=polys[ell],polys[ell+k]
    relation=[(b[i] if i<len(b) else 0) -
              (a[i] if i<len(a) else 0) for i in range(len(b))]
    root = horner(relation,c,p) == 0
    simple = derivative_horner(relation,c,p) != 0
    # Pairwise exclusion checked using independently evaluated Q_i(C),
    # not the tangent-orbit computation.
    values=[horner(polynomial,c,p) for polynomial in polys]
    collisions=[(i,j) for j in range(1,ell+k+1)
                for i in range(j) if values[i] == values[j]]
    return root, collisions == [(ell,ell+k)], simple


def verify_golden(source, *, source_commit, source_sha256):
    require(isinstance(source_commit,str) and re.fullmatch("[0-9a-f]{40}",source_commit),
            "source revision not immutable SHA")
    require(isinstance(source_sha256,str) and re.fullmatch("[0-9a-f]{64}",source_sha256),
            "source fixture SHA256 missing")
    rows=parse_golden(source)
    certificates=[]
    for c,ell,k,p,expected in rows:
        a=dual_critical_relation(c,ell,k,p)
        b=polynomial_relation(c,ell,k,p)
        require(a == b, f"independent formal derivative mismatch at {c}/{p}")
        require(a == expected, f"Golden finite fixture mismatch at {c}/{p}")
        certificates.append({
            "parameter_c":c,"ell":ell,"k":k,"modulus":p,
            "relation_root":a[0],
            "unique_collision":a[1],
            "simple_residue_root":a[2],
        })
    return {
        "schema":"HOMELAB-FM-FINITE-CRITICAL-RELATION-1",
        "source_commit":source_commit,
        "source_fixture_sha256":source_sha256,
        "finite_vectors_checked":len(rows),
        "methods":[
            "independent_Fp_dual_number_critical_orbit",
            "independent_Fp_polynomial_convolution_formal_derivative",
        ],
        "certificates":certificates,
        "verdict":"finite_critical_relation_golden_vectors_verified",
        "proves_mlc":False,
        "universal_claim_accepted":False,
        "next_research_obligation":
            "Independently reproduce exact integer Q_n coefficients past the native "
            "Int horizon and audited polynomial squarefree certificates; never "
            "treat finite critical-parameter examples as global MLC.",
    }
