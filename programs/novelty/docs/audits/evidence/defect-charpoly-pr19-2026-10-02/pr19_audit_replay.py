#!/usr/bin/env python3
"""Independent finite audit at novelty-lab PR #19's fixed head; no promotion.

Usage: python pr19_audit_replay.py /path/to/novelty-lab > pr19_audit_evidence.json
Requires Python 3.12 and SymPy 1.14.0. Uses SymPy's division-free exact
characteristic polynomial as an oracle and a separate Zorn algebra model.
"""
from collections import Counter
from itertools import product
from pathlib import Path
import hashlib
import json
import platform
import random
import subprocess
import sys

import sympy as sp

HEAD = "ce6e7c8c67d6892473e2365d91bac87afbcda842"
SEED = 20261002
ROOT = Path(sys.argv[1]).resolve()
assert subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip() == HEAD
sys.path.insert(0, str(ROOT / "tests"))
import test_defect_charpoly as T

C, R = T.C, T.R
Y = sp.Symbol("Y")


def cp(a, p):
    """Integer Berkowitz characteristic polynomial, then reduction mod p."""
    return tuple(int(t) % p for t in reversed(sp.Matrix(a).charpoly(Y).all_coeffs()))


def expected(nu, nc, p):
    return tuple(int(t) % p for t in reversed(sp.Poly(
        (Y - nu) ** 4 * (Y ** 2 - (2 * nu - nc) * Y + nu ** 2) ** 2, Y
    ).all_coeffs()))


def mm(a, b, p):
    return [[sum(s * t for s, t in zip(row, col)) % p for col in zip(*b)] for row in a]


def minus_identity(a, p):
    return [[(t - int(i == j)) % p for j, t in enumerate(row)] for i, row in enumerate(a)]


def mpow(a, n, p):
    out = [[int(i == j) for j in range(len(a))] for i in range(len(a))]
    for _ in range(n):
        out = mm(out, a, p)
    return out


def rk(a, p):
    """Independent modular rank, with full row reduction."""
    a = [[t % p for t in row] for row in a]
    n = len(a)
    width = len(a[0]) if n else 0
    r = 0
    for j in range(width):
        k = next((k for k in range(r, n) if a[k][j]), None)
        if k is None:
            continue
        a[r], a[k] = a[k], a[r]
        a[r] = [(t * pow(a[r][j], -1, p)) % p for t in a[r]]
        for k in range(n):
            if k != r:
                f = a[k][j]
                a[k] = [(s - f * t) % p for s, t in zip(a[k], a[r])]
        r += 1
    return r


def helper_checks():
    counts = Counter()
    for p in (2, 3, 5):
        for v in product(range(p), repeat=4):
            a = [list(v[:2]), list(v[2:])]
            assert C.charpoly(a, p) == cp(a, p)
            counts["exhaustive_2x2"] += 1
    for v in product(range(2), repeat=9):
        a = [list(v[3 * i:3 * i + 3]) for i in range(3)]
        assert C.charpoly(a, 2) == cp(a, 2)
        counts["exhaustive_3x3_F2"] += 1
    rng = random.Random(SEED)
    for p in (2, 3, 5, 7, 11, 13):
        for n in range(11):
            for _ in range(10):
                a = [[rng.randrange(-2 * p, 3 * p) for _ in range(n)] for _ in range(n)]
                assert C.charpoly(a, p) == cp(a, p)
                counts["random_dimensions_0_through_10"] += 1
            for kind in ("zero", "identity", "nilpotent_jordan", "triangular"):
                a = [[(int(i == j) if kind == "identity" else
                       int(j == i + 1) if kind == "nilpotent_jordan" else
                       (i + j + 1) if kind == "triangular" and i <= j else 0)
                      for j in range(n)] for i in range(n)]
                assert C.charpoly(a, p) == cp(a, p)
                counts["structured_dimensions_0_through_10"] += 1
    return dict(counts)


def repository_samples():
    results = []
    for p in (3, 5, 7, 11, 13):
        counts = Counter()
        for x, y in T.pairs(p, random.Random(100 + p), 250):
            xy, yx = C.mul(x, y, p), C.mul(y, x, p)
            nu = C.norm(x, p) * C.norm(y, p) % p
            nc = C.norm(T.sub(xy, yx, p), p)
            q = [C.BASIS[0], x, y, xy]
            dim = rk(q, p)
            gram = [[R.bilinear(u, v, p) for v in q] for u in q]
            assert int(sp.Matrix(gram).det()) % p == nc * nc % p
            m = mm(mm(C.left(x, p), C.left(y, p), p), C.left(C.conj(xy, p), p), p)
            assert cp(m, p) == expected(nu, nc, p) == C.charpoly(m, p)
            counts["pairs"] += 1
            counts[f"dim_Q_{dim}"] += 1
            counts["nu_zero" if not nu else "nu_nonzero"] += 1
            if not nu and nc:
                counts["nu_zero_nc_nonzero"] += 1
            if nu:
                d = [[t * pow(nu, -1, p) % p for t in row] for row in m]
                assert sum(d[i][i] for i in range(8)) % p == (8 - 2 * nc * pow(nu, -1, p)) % p
                nilpotent = not any(t for row in mpow(minus_identity(d, p), 8, p) for t in row)
                assert nilpotent == (nc == 0)
                if dim == 4 and not nc:
                    counts["admissible_degenerate_dim4"] += 1
                if nc and (2 - nc * pow(nu, -1, p)) % p == -2 % p:
                    g = tuple(t * pow(nu, -1, p) % p for t in C.mul(C.conj(xy, p), yx, p))
                    central = g == tuple(-int(i == 0) % p for i in range(8))
                    counts["tau_minus2_central" if central else "tau_minus2_noncentral"] += 1
        assert counts["nu_zero_nc_nonzero"] > 0 and counts["admissible_degenerate_dim4"] > 0
        results.append({"p": p, "seed": 100 + p, **dict(counts)})
    return results


def explicit_domain_checks():
    """Zero and scalar operands, including the forbidden normalization at nu=0."""
    results = []
    zero = (0,) * 8
    for p in (3, 5, 7, 11, 13):
        count = refused = 0
        for x, y in ((zero, zero), (zero, C.BASIS[1]), (C.BASIS[1], zero),
                     (C.BASIS[0], C.BASIS[0]), (C.BASIS[0], C.BASIS[1]),
                     (C.BASIS[1], C.BASIS[1])):
            xy, yx = C.mul(x, y, p), C.mul(y, x, p)
            nu = C.norm(x, p) * C.norm(y, p) % p
            nc = C.norm(T.sub(xy, yx, p), p)
            m = mm(mm(C.left(x, p), C.left(y, p), p), C.left(C.conj(xy, p), p), p)
            assert cp(m, p) == expected(nu, nc, p) == C.charpoly(m, p)
            if not nu:
                try:
                    C.defect(x, y, p)
                except ValueError:
                    refused += 1
                else:
                    raise AssertionError("Delta incorrectly defined at nu=0")
            count += 1
        assert refused == 3
        results.append({"p": p, "zero_or_scalar_pairs": count,
                        "undefined_delta_refused": refused})
    return results


def dot(a, b):
    return sum(s * t for s, t in zip(a, b))


def cross(a, b):
    return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def zorn_mul(x, y, p):
    """Coordinates (a,b,u1,u2,u3,v1,v2,v3), N=ab-u dot v.

    Separate vector-matrix implementation; no repository structure tensor,
    Cayley-Dickson multiplication, doubling decomposition or charpoly helper.
    """
    a, b, u, v = x[0], x[1], x[2:5], x[5:8]
    c, d, z, w = y[0], y[1], y[2:5], y[5:8]
    top = tuple(a * z[i] + d * u[i] - cross(v, w)[i] for i in range(3))
    bot = tuple(c * v[i] + b * w[i] + cross(u, z)[i] for i in range(3))
    return tuple(t % p for t in (a * c + dot(u, w), b * d + dot(v, z)) + top + bot)


def zorn_norm(x, p):
    return (x[0] * x[1] - dot(x[2:5], x[5:8])) % p


def zorn_conj(x, p):
    return tuple(t % p for t in (x[1], x[0]) + tuple(-t for t in x[2:]))


def zorn_checks():
    results = []
    basis = [tuple(int(i == j) for j in range(8)) for i in range(8)]
    one = (1, 1, 0, 0, 0, 0, 0, 0)
    for p in (3, 5, 7, 11, 13):
        rng, counts = random.Random(SEED + p), Counter()
        def left(x):
            return list(map(list, zip(*(zorn_mul(x, e, p) for e in basis))))
        def polar(x, y):
            return (zorn_norm(tuple(s + t for s, t in zip(x, y)), p) - zorn_norm(x, p) - zorn_norm(y, p)) % p
        for i in range(100):
            x, y = (tuple(rng.randrange(p) for _ in range(8)) for _ in range(2))
            if i % 5 == 0:
                a, b = rng.randrange(p), rng.randrange(p)
                y = tuple((a * s + b * t) % p for s, t in zip(one, x))
            xy, yx = zorn_mul(x, y, p), zorn_mul(y, x, p)
            assert zorn_mul(one, x, p) == x == zorn_mul(x, one, p)
            assert zorn_mul(x, zorn_conj(x, p), p) == tuple(zorn_norm(x, p) * t % p for t in one)
            nu = zorn_norm(x, p) * zorn_norm(y, p) % p
            assert zorn_norm(xy, p) == nu
            nc = zorn_norm(tuple(s - t for s, t in zip(xy, yx)), p)
            q = [one, x, y, xy]
            assert int(sp.Matrix([[polar(u, v) for v in q] for u in q]).det()) % p == nc * nc % p
            m = mm(mm(left(x), left(y), p), left(zorn_conj(xy, p)), p)
            assert cp(m, p) == expected(nu, nc, p)
            counts["pairs"] += 1
            if not nu:
                counts["nu_zero"] += 1
            if not nu and nc:
                counts["nu_zero_nc_nonzero"] += 1
            if nu:
                d = [[t * pow(nu, -1, p) % p for t in row] for row in m]
                nilpotent = not any(t for row in mpow(minus_identity(d, p), 8, p) for t in row)
                assert nilpotent == (nc == 0)
            if nu and not nc and rk(q, p) == 4:
                counts["admissible_degenerate_dim4"] += 1
        assert counts["nu_zero_nc_nonzero"] and counts["admissible_degenerate_dim4"]
        results.append({"p": p, "seed": SEED + p, **dict(counts)})
    return results


def witnesses():
    p = 3
    cases = [
        ("tau2_identity", C.BASIS[0], C.BASIS[0]),
        ("tau2_dim3", (0, 0, 0, 0, 2, 0, 2, 0), (0, 0, 1, 2, 0, 2, 2, 2)),
        ("tau2_dim4_degenerate", (0, 2, 0, 2, 0, 1, 2, 2), (0, 1, 0, 2, 1, 0, 2, 2)),
        ("tau_minus2_semisimple", C.BASIS[1], C.BASIS[2]),
        ("tau_minus2_nonsemisimple", (2, 0, 0, 1, 0, 0, 0, 0), (0, 0, 2, 2, 0, 0, 0, 0)),
    ]
    out = []
    for name, x, y in cases:
        xy, yx = C.mul(x, y, p), C.mul(y, x, p)
        nu = C.norm(x, p) * C.norm(y, p) % p
        nc = C.norm(T.sub(xy, yx, p), p)
        d, _ = C.defect(x, y, p)
        g = tuple(t * pow(nu, -1, p) % p for t in C.mul(C.conj(xy, p), yx, p))
        assert C.norm(g, p) == 1
        row = {"name": name, "p": p, "x": x, "y": y, "nu": nu, "N_c": nc,
               "g": g, "N_g": C.norm(g, p),
               "tau": (2 - nc * pow(nu, -1, p)) % p,
               "dim_Q": rk([C.BASIS[0], x, y, xy], p), "charpoly_low_to_high": cp(d, p),
               "rank_D_minus_I": rk(minus_identity(d, p), p),
               "rank_D_squared_minus_I": rk(minus_identity(mm(d, d, p), p), p)}
        out.append(row)
    assert [r["rank_D_minus_I"] for r in out[:3]] == [0, 2, 4]
    assert len({r["charpoly_low_to_high"] for r in out[:3]}) == 1
    assert out[3]["charpoly_low_to_high"] == out[4]["charpoly_low_to_high"]
    assert [r["rank_D_squared_minus_I"] for r in out[3:]] == [0, 2]
    return out


result = {
    "schema": "novelty-lab/pr19-independent-ai-audit/v1", "date": "2026-10-02",
    "head": HEAD, "python": platform.python_version(), "sympy": sp.__version__,
    "claim_status": "pending; AI audit does not supply required human review",
    "helper": helper_checks(), "repository_seeded_samples": repository_samples(),
    "explicit_domain_checks": explicit_domain_checks(),
    "independent_zorn_model": zorn_checks(), "conjugacy_counterexamples": witnesses(),
    "files_sha256": {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest() for p in
                     ("paper/associator-defects/main.tex", "tests/test_defect_charpoly.py",
                      "experiments/n2/defect_census.py", "research/ledger.json")},
}
print(json.dumps(result, indent=2, sort_keys=True))
