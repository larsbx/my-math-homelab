#!/usr/bin/env python3
"""Jordan type of Delta(x, y) on every stratum (paper Theorem 3.26), sampled over F_ell.

With nu = N(x) N(y) != 0, c = xy - yx and tau = 2 - N(c)/nu, the theorem predicts the ranks of the
powers of A = Delta - I and of Delta + I from the stratum alone:

    stratum              condition                                    ranks A, A^2, A^3   (Delta + I), its square
    semisimple           N(c) != 0, tau != -2                         4, 4, 4             8, 8
    tau=-2 semisimple    tau = -2, xy + yx = 0                        4, 4, 4             4, 4
    tau=-2 split         tau = -2, xy + yx != 0                       4, 4, 4             6, 4
    dimQ<=2              dim Q <= 2                                   0, 0, 0             8, 8
    dimQ=3               dim Q = 3                                    2, 0, 0             8, 8
    unipotent-rank<r>    N(c) = 0, dim Q = 4, rank B|_Q = r in {1,2}  4, r, 0             8, 8

Pairs are drawn with a fixed seed, enriched for the rare strata (pure orthogonal pairs for tau = -2,
and x = t, y = n with t n = lambda n, N(n) = 0, for dim Q = 3), until each stratum has QUOTA pairs.

Usage: defect_jordan.py [--check]     writes or checks data/n2/defect-jordan-v1.json
"""
from __future__ import annotations

import json
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import defect_census as C  # noqa: E402
import rank_law as R  # noqa: E402

OUT = HERE.parents[1] / "data" / "n2" / "defect-jordan-v1.json"
ELLS, QUOTA, DRAWS, SEED = (3, 5, 7, 11), 150, 200000, 20261004
PREDICTED = {"semisimple": ((4, 4, 4), (8, 8)), "tau=-2 semisimple": ((4, 4, 4), (4, 4)),
             "tau=-2 split": ((4, 4, 4), (6, 4)), "dimQ<=2": ((0, 0, 0), (8, 8)), "dimQ=3": ((2, 0, 0), (8, 8)),
             "unipotent-rank1": ((4, 1, 0), (8, 8)), "unipotent-rank2": ((4, 2, 0), (8, 8))}


def admissible(ell: int, rng: random.Random) -> C.Vec:
    while True:
        v = tuple(rng.randrange(ell) for _ in range(C.DIM))
        if C.norm(v, ell):
            return v


def pure(a: C.Vec, ell: int) -> C.Vec:
    return (0,) + a[1:]


def shift(m: C.Mat, s: int, ell: int) -> list[list[int]]:
    """m - s I."""
    return [[(m[i][j] - s * (i == j)) % ell for j in range(C.DIM)] for i in range(C.DIM)]


def quadratic(m: C.Mat, tau: int, ell: int) -> list[list[int]]:
    """m^2 - tau m + I."""
    sq = C.matmul(m, m, ell)
    return [[(sq[i][j] - tau * m[i][j] + (i == j)) % ell for j in range(C.DIM)] for i in range(C.DIM)]


def tau(x: C.Vec, y: C.Vec, ell: int) -> int:
    c = tuple((s - t) % ell for s, t in zip(C.mul(x, y, ell), C.mul(y, x, ell)))
    return (2 - C.norm(c, ell) * pow(C.norm(x, ell) * C.norm(y, ell), -1, ell)) % ell


def stratum(x: C.Vec, y: C.Vec, ell: int) -> str:
    xy = C.mul(x, y, ell)
    q = (C.BASIS[0], x, y, xy)
    dim_q, t = C.rank(q, ell), tau(x, y, ell)
    if dim_q <= 3:
        return "dimQ<=2" if dim_q <= 2 else "dimQ=3"
    if t == 2:
        return f"unipotent-rank{C.rank([[R.bilinear(u, w, ell) for w in q] for u in q], ell)}"
    if t == ell - 2:
        anti = not any((s + r) % ell for s, r in zip(xy, C.mul(y, x, ell)))
        return "tau=-2 semisimple" if anti else "tau=-2 split"
    return "semisimple"


def observed(x: C.Vec, y: C.Vec, ell: int) -> tuple[tuple[int, ...], tuple[int, ...]]:
    def ranks(m, k):
        out, p = [], m
        for _ in range(k):
            out.append(C.rank(p, ell))
            p = C.matmul(p, m, ell)
        return tuple(out)
    d = C.defect(x, y, ell)[0]
    return ranks(shift(d, 1, ell), 3), ranks(shift(d, -1, ell), 2)


def enriched(ell: int, rng: random.Random) -> tuple[C.Vec, C.Vec]:
    """A pure orthogonal pair (tau = -2 semisimple) or a dim Q = 3 pair, when one is found."""
    x = pure(admissible(ell, rng), ell)
    if rng.random() < 0.5:
        y = pure(admissible(ell, rng), ell)
        k = R.bilinear(x, y, ell) * pow(2 * C.norm(x, ell), -1, ell) if C.norm(x, ell) else 0
        return x, tuple((s - k * t) % ell for s, t in zip(y, x))
    lam = next((v for v in range(1, ell) if (v * v + C.norm(x, ell)) % ell == 0), None)
    if lam is None:
        return x, x
    rows = [list(r) for r in shift(C.left(x, ell), lam, ell)] + [list(C.BASIS[0]), list(x)]
    basis = R.nullspace(rows, ell)
    n = tuple(sum(rng.randrange(ell) * b[i] for b in basis) % ell for i in range(C.DIM)) if basis else x
    return x, tuple((rng.randrange(ell) * (i == 0) + s) % ell for i, s in enumerate(n))


def census(ell: int) -> dict:
    rng = random.Random(SEED + ell)
    counts, violations = {k: 0 for k in PREDICTED}, 0
    for draw in range(DRAWS):
        x, y = enriched(ell, rng) if draw % 2 else (admissible(ell, rng), admissible(ell, rng))
        if not (C.norm(x, ell) and C.norm(y, ell)):
            continue
        s = stratum(x, y, ell)
        if counts[s] >= QUOTA:
            continue
        counts[s] += 1
        violations += observed(x, y, ell) != PREDICTED[s]
        if min(counts.values()) >= QUOTA:
            break
    return {"ell": ell, "checked": counts, "violations": violations}


def render() -> str:
    return json.dumps({"schema": "novelty-lab/n2-defect-jordan/v1", "model": "cayley-dickson/v1 (-1,-1,-1) mod ell",
                       "seed": SEED, "quota": QUOTA,
                       "predicted": {k: {"ranks_delta_minus_I": a, "ranks_delta_plus_I": b}
                                     for k, (a, b) in PREDICTED.items()},
                       "rows": [census(ell) for ell in ELLS]}, indent=1, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    text = render()
    if argv[1:] == ["--check"]:
        current = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("OK: defect Jordan census is current" if current else f"stale: {OUT}")
        return 0 if current else 1
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
