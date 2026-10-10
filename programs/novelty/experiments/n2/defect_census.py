#!/usr/bin/env python3
"""Finite census of the square-root-free associator defect over F_ell (records DefectCensus, N2-T03).

Model: the octonion algebra C = A_3 of convention ``cayley-dickson/v1`` with
parameters (-1, -1, -1), reduced mod an odd prime ell. Its norm is the sum of
eight squares, which is isotropic over F_ell, so C is the split octonion
algebra. For N(x)N(y) != 0,

    Delta(x, y) = L_x L_y L_xy^{-1},   L_z^{-1} = N(z)^{-1} L_conj(z),

so no square root is ever taken. Per sampled pair the census checks:

* ``inverse``      Delta L_xy = L_x L_y            (the inverse formula above)
* ``isometry``     Delta^T Delta = I               (N2-T03.1)
* ``fixes_xy``     Delta(xy) = xy                  (N2-T03.2)
* ``kernel``       Delta = I  <=>  [x, y, z] = 0 for all z   (N2-T03.3)
* ``det_one``      det Delta = 1                   (beyond N2-T03: SO, not O)
* ``fixes_Q``      Delta z = z for z in Q = span{1, x, y, xy}  (Artin)
* ``rank_law``     rank(Delta - I) = RANK_LAW[dim Q]

and tallies the strata (dim Q, rank(Delta - I), tr Delta). Finite evidence
only; the general statements are pending records in research/ledger.json.

Usage: defect_census.py [--check]     writes or checks data/n2/defect-census-v1.json
"""

from __future__ import annotations

import json
import random
import sys
from collections import Counter
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "kernel"))

from n1 import cayley_dickson as cd  # noqa: E402

OUT = ROOT / "data" / "n2" / "defect-census-v1.json"
ELLS, PAIRS, SEED = (3, 5, 7, 11), 400, 20261001
RANK_LAW = {1: 0, 2: 0, 3: 2, 4: 4}
DIM = 8
Vec = tuple[int, ...]
Mat = tuple[Vec, ...]

BASIS: tuple[Vec, ...] = tuple(tuple(int(i == k) for k in range(DIM)) for i in range(DIM))
IDENTITY: Mat = BASIS


def _structure() -> dict[tuple[int, int], tuple[int, int]]:
    """e_i e_j = sign · e_k, read off the exact kernel product over Q."""
    params, table = (Fraction(-1),) * 3, {}
    for i in range(DIM):
        for j in range(DIM):
            v = cd.mul(tuple(map(Fraction, BASIS[i])), tuple(map(Fraction, BASIS[j])), params)
            k = next(t for t in range(DIM) if v[t])
            table[i, j] = (k, int(v[k]))
    return table


STRUCTURE = _structure()


def mul(x: Vec, y: Vec, ell: int) -> Vec:
    out = [0] * DIM
    for (i, j), (k, s) in STRUCTURE.items():
        out[k] += s * x[i] * y[j]
    return tuple(t % ell for t in out)


def conj(x: Vec, ell: int) -> Vec:
    return (x[0],) + tuple(-t % ell for t in x[1:])


def norm(x: Vec, ell: int) -> int:
    return sum(t * t for t in x) % ell


def left(x: Vec, ell: int) -> Mat:
    cols = [mul(x, e, ell) for e in BASIS]
    return tuple(tuple(c[i] for c in cols) for i in range(DIM))


def matmul(a: Mat, b: Mat, ell: int) -> Mat:
    return tuple(tuple(sum(a[i][k] * b[k][j] for k in range(DIM)) % ell for j in range(DIM)) for i in range(DIM))


def apply(a: Mat, v: Vec, ell: int) -> Vec:
    return tuple(sum(r[k] * v[k] for k in range(DIM)) % ell for r in a)


def transpose(a: Mat) -> Mat:
    return tuple(zip(*a))


def echelon(rows: list[list[int]], ell: int) -> tuple[int, int]:
    """(rank, determinant if square else 0) by Gaussian elimination mod ell."""
    rows, rank, det = [list(r) for r in rows], 0, 1
    for c in range(len(rows[0])):
        p = next((i for i in range(rank, len(rows)) if rows[i][c] % ell), None)
        if p is None:
            det = 0
            continue
        if p != rank:
            rows[rank], rows[p], det = rows[p], rows[rank], -det
        det = det * rows[rank][c] % ell
        inv = pow(rows[rank][c], -1, ell)
        for i in range(rank + 1, len(rows)):
            f = rows[i][c] * inv % ell
            rows[i] = [(a - f * b) % ell for a, b in zip(rows[i], rows[rank])]
        rank += 1
    return rank, det % ell if len(rows) == len(rows[0]) else 0


def rank(rows, ell: int) -> int:
    return echelon(rows, ell)[0]


def charpoly(a, ell: int) -> tuple[int, ...]:
    """det(Y I - a) mod ell, coefficients low -> high: similarity to upper Hessenberg form, then the
    standard recurrence on leading principal minors. Exact over every F_ell."""
    n, h = len(a), [[t % ell for t in r] for r in a]
    for c in range(n - 2):
        p = next((i for i in range(c + 1, n) if h[i][c]), None)
        if p is None:
            continue
        h[c + 1], h[p] = h[p], h[c + 1]
        for r in h:
            r[c + 1], r[p] = r[p], r[c + 1]
        inv = pow(h[c + 1][c], -1, ell)
        for i in range(c + 2, n):
            f = h[i][c] * inv % ell
            if f:
                h[i] = [(s - f * t) % ell for s, t in zip(h[i], h[c + 1])]
                for r in h:
                    r[c + 1] = (r[c + 1] + f * r[i]) % ell
    minors = [(1,)]
    for m in range(1, n + 1):
        cur = [(s - h[m - 1][m - 1] * t) % ell for s, t in zip((0,) + minors[m - 1], minors[m - 1] + (0,))]
        sub = 1
        for i in range(m - 1, 0, -1):
            sub = sub * h[i][i - 1] % ell
            coef = sub * h[i - 1][m - 1] % ell
            cur = [(s - coef * t) % ell for s, t in zip(cur, minors[i - 1] + (0,) * (m - i + 1))]
        minors.append(tuple(cur))
    return minors[n]


def defect(x: Vec, y: Vec, ell: int) -> tuple[Mat, Vec]:
    xy = mul(x, y, ell)
    scale = pow(norm(xy, ell), -1, ell)
    raw = matmul(matmul(left(x, ell), left(y, ell), ell), left(conj(xy, ell), ell), ell)
    return tuple(tuple(t * scale % ell for t in r) for r in raw), xy


def checks(x: Vec, y: Vec, ell: int) -> tuple[dict[str, bool], tuple[int, int, int]]:
    """Every per-pair property, and the stratum (dim Q, rank(Delta - I), tr Delta)."""
    delta, xy = defect(x, y, ell)
    q = (BASIS[0], x, y, xy)
    associates = all(mul(x, mul(y, e, ell), ell) == mul(xy, e, ell) for e in BASIS)
    dim_q = rank(q, ell)
    moved = rank([[(delta[i][j] - IDENTITY[i][j]) % ell for j in range(DIM)] for i in range(DIM)], ell)
    props = {
        "inverse": matmul(delta, left(xy, ell), ell) == matmul(left(x, ell), left(y, ell), ell),
        "isometry": matmul(transpose(delta), delta, ell) == IDENTITY,
        "fixes_xy": apply(delta, xy, ell) == xy,
        "kernel": (delta == IDENTITY) == associates,
        "det_one": echelon(delta, ell)[1] == 1,
        "fixes_Q": all(apply(delta, z, ell) == z for z in q),
        "rank_law": moved == RANK_LAW[dim_q],
    }
    return props, (dim_q, moved, sum(delta[i][i] for i in range(DIM)) % ell)


def samples(ell: int, rng: random.Random) -> list[tuple[Vec, Vec]]:
    """Random admissible pairs, plus degenerate ones with y in span{1, x}."""
    def admissible() -> Vec:
        while True:
            v = tuple(rng.randrange(ell) for _ in range(DIM))
            if norm(v, ell):
                return v
    pairs = [(admissible(), admissible()) for _ in range(PAIRS)]
    for x, _ in pairs[: PAIRS // 4]:
        a, b = rng.randrange(ell), rng.randrange(1, ell)
        y = tuple((b * t + (a if k == 0 else 0)) % ell for k, t in enumerate(x))
        if norm(y, ell):
            pairs.append((x, y))
    return pairs


def census(ell: int) -> dict:
    rng = random.Random(SEED + ell)
    violations, strata, n = Counter(), Counter(), 0
    for x, y in samples(ell, rng):
        props, stratum = checks(x, y, ell)
        violations.update(k for k, ok in props.items() if not ok)
        strata[stratum] += 1
        n += 1
    return {"ell": ell, "pairs": n, "violations": {k: violations[k] for k in sorted(props)},
            "strata": [{"dim_Q": d, "rank_moved": r, "trace": t, "count": c} for (d, r, t), c in sorted(strata.items())]}


def render() -> str:
    return json.dumps({"schema": "novelty-lab/n2-defect-census/v1", "model": "cayley-dickson/v1 (-1,-1,-1) mod ell",
                       "seed": SEED, "rank_law": RANK_LAW,
                       "claim_status": "bounded experiment; finite evidence, not a theorem",
                       "rows": [census(ell) for ell in ELLS]}, indent=1, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    text = render()
    if argv[1:] == ["--check"]:
        current = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("OK: defect census is current" if current else f"stale: {OUT}")
        return 0 if current else 1
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
