#!/usr/bin/env python3
"""Word defects W = L_a1 ... L_an L_v^{-1}, v the left-comb value ((a1 a2) ...) an, over F_ell.

A word's classical data is the orbit of its letters under the stabilizer of 1 in O(C, N), and so in
particular the Gram matrix of (1, a1, ..., an). For each length n this records how often a random
rotation h of 1-perp (a product of two reflections in pure anisotropic vectors) changes the
characteristic polynomial of W when applied to every letter. For n <= 3 it never does (paper
Corollary 3.22 for n = 2, Proposition 3.26 for n = 3); for n >= 4 it does, and CERTIFICATE is an
explicit instance over F_3.

Usage: word_defects.py [--check]     writes or checks data/n2/word-defects-v1.json
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

OUT = HERE.parents[1] / "data" / "n2" / "word-defects-v1.json"
ELLS, LENGTHS, SAMPLES, SEED = (3, 5, 7), (2, 3, 4, 5), 120, 20261003
IDENTITY = tuple(tuple(int(i == j) for j in range(C.DIM)) for i in range(C.DIM))

# Letters e1, e2, e3, 1 + e4 and h = s_e1 s_(e1 + e4), which fixes 1 and has determinant 1.
CERTIFICATE = {"ell": 3, "letters": [[0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0],
                                     [0, 0, 0, 1, 0, 0, 0, 0], [1, 0, 0, 0, 1, 0, 0, 0]],
               "reflections": [[0, 1, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 1, 0, 0, 0]]}


def reflection(a: C.Vec, ell: int) -> C.Mat:
    """s_a(z) = z - B(z, a)/N(a) a."""
    inv = pow(C.norm(a, ell), -1, ell)
    return C.transpose([tuple((s - R.bilinear(e, a, ell) * inv * t) % ell for s, t in zip(e, a)) for e in C.BASIS])


def word_defect(letters, ell: int) -> C.Mat:
    """L_a1 ... L_an L_v^{-1} with v = ((a1 a2) a3) ... an and L_v^{-1} = N(v)^{-1} L_conj(v)."""
    m, v = IDENTITY, letters[0]
    for a in letters:
        m = C.matmul(m, C.left(a, ell), ell)
    for a in letters[1:]:
        v = C.mul(v, a, ell)
    inv = pow(C.norm(v, ell), -1, ell)
    return C.matmul(m, tuple(tuple(t * inv % ell for t in r) for r in C.left(C.conj(v, ell), ell)), ell)


def moved(letters, reflections, ell: int):
    h = C.matmul(reflection(reflections[0], ell), reflection(reflections[1], ell), ell)
    return [C.apply(h, a, ell) for a in letters]


def certificate() -> dict:
    ell, letters = CERTIFICATE["ell"], [tuple(a) for a in CERTIFICATE["letters"]]
    reflections = [tuple(u) for u in CERTIFICATE["reflections"]]
    before = C.charpoly(word_defect(letters, ell), ell)
    after = C.charpoly(word_defect(moved(letters, reflections, ell), ell), ell)
    return {**CERTIFICATE, "charpoly": list(before), "charpoly_moved": list(after), "differ": before != after}


def census(ell: int) -> list[dict]:
    rng = random.Random(SEED + ell)
    pure = lambda: (0,) + tuple(rng.randrange(ell) for _ in range(C.DIM - 1))
    rows = []
    for n in LENGTHS:
        changed = done = 0
        while done < SAMPLES:
            letters = [tuple(rng.randrange(ell) for _ in range(C.DIM)) for _ in range(n)]
            reflections = [pure(), pure()]
            if not all(C.norm(a, ell) for a in letters + reflections):
                continue
            done += 1
            before = C.charpoly(word_defect(letters, ell), ell)
            changed += before != C.charpoly(word_defect(moved(letters, reflections, ell), ell), ell)
        rows.append({"length": n, "samples": done, "charpoly_changed": changed})
    return rows


def render() -> str:
    return json.dumps({"schema": "novelty-lab/n2-word-defects/v1", "model": "cayley-dickson/v1 (-1,-1,-1) mod ell",
                       "statement": "count of words whose defect charpoly changes when every letter is moved by "
                                    "the same rotation of 1-perp",
                       "seed": SEED, "certificate": certificate(),
                       "rows": [{"ell": ell, "lengths": census(ell)} for ell in ELLS]}, indent=1, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    text = render()
    if argv[1:] == ["--check"]:
        current = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("OK: word-defect census is current" if current else f"stale: {OUT}")
        return 0 if current else 1
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
