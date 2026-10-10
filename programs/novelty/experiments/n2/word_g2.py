#!/usr/bin/env python3
"""Which G2 data the characteristic polynomial of a word defect sees (paper Section 3, words).

W(a1, ..., an) is equivariant under automorphisms g of C: W(g a) = g W(a) g^{-1}. So its
characteristic polynomial is an invariant of the letters under G2 = Aut(C), which fixes 1 and
preserves, on the pure parts p_i of the letters, the inner products, the three-form
phi(p, q, r) = B(pq, r) and the four-form psi(p, q, r, s) = B([p, q, r], s). A rotation h of
1-perp preserves the inner products but in general neither form.

For random words and random rotations h (products of 2 or 4 reflections in pure anisotropic
vectors, letters actually moved), this tallies whether h preserves every phi value, every psi
value, and the characteristic polynomial of W. The claim under test (`WordDefectG2Data`) is
that preserving both forms preserves the characteristic polynomial; the tallies also show that
neither form alone suffices, with an explicit certificate for each.

Usage: word_g2.py [--check]     writes or checks data/n2/word-g2-v1.json
"""
from __future__ import annotations

import json
import random
import sys
from collections import Counter
from itertools import combinations
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import defect_census as C  # noqa: E402
import rank_law as R  # noqa: E402
import word_defects as WD  # noqa: E402

OUT = HERE.parents[1] / "data" / "n2" / "word-g2-v1.json"
CONFIGS = ((3, 4, 40000), (3, 5, 20000), (5, 4, 60000), (7, 4, 60000))     # (ell, word length, trials)
SEED, PSI_ONLY_CAP = 20261005, 60        # rotations preserving psi but not phi are common: compare this many


def pure(a: C.Vec) -> C.Vec:
    return (0,) + a[1:]


def phi(p: C.Vec, q: C.Vec, r: C.Vec, ell: int) -> int:
    return R.bilinear(C.mul(p, q, ell), r, ell)


def psi(p: C.Vec, q: C.Vec, r: C.Vec, s: C.Vec, ell: int) -> int:
    assoc = tuple((u - w) % ell for u, w in zip(C.mul(p, C.mul(q, r, ell), ell), C.mul(C.mul(p, q, ell), r, ell)))
    return R.bilinear(assoc, s, ell)


def forms_agree(ps, qs, ell: int) -> tuple[bool, bool]:
    """(phi agrees on every triple, psi agrees on every quadruple) for two lists of pure parts."""
    def agree(form, k):
        return all(form(*[ps[i] for i in t], ell) == form(*[qs[i] for i in t], ell)
                   for t in combinations(range(len(ps)), k))
    return agree(phi, 3), agree(psi, 4)


def rotate(reflections, a: C.Vec, ell: int) -> C.Vec:
    """h(a) for h = s_u1 s_u2 ... s_ur, applied right to left without forming the matrix."""
    for u in reversed(reflections):
        k = R.bilinear(a, u, ell) * pow(C.norm(u, ell), -1, ell)
        a = tuple((s - k * t) % ell for s, t in zip(a, u))
    return a


def compare(letters, reflections, ell: int, psi_only: bool = True) -> tuple[bool, bool, bool | None]:
    """(phi preserved, psi preserved, characteristic polynomial preserved) under the rotation; the last
    entry is None, not computed, when neither form is preserved, or only psi is and psi_only is false."""
    moved = [rotate(reflections, a, ell) for a in letters]
    f, s = forms_agree([pure(a) for a in letters], [pure(a) for a in moved], ell)
    if not (f or s and psi_only):
        return f, s, None
    cp = lambda word: C.charpoly(WD.word_defect(word, ell), ell)
    return f, s, cp(letters) == cp(moved)


def census(ell: int, n: int, trials: int) -> tuple[dict, dict]:
    rng = random.Random(SEED + 10 * ell + n)

    def anisotropic(pure_only: bool) -> C.Vec:
        while True:
            v = ((0,) if pure_only else (rng.randrange(ell),)) + tuple(rng.randrange(ell) for _ in range(C.DIM - 1))
            if C.norm(v, ell):
                return v
    tally, certificates = Counter(), {}
    for _ in range(trials):
        letters = [anisotropic(False) for _ in range(n)]
        reflections = [anisotropic(True) for _ in range(rng.choice((2, 4)))]
        if all(rotate(reflections, a, ell) == a for a in letters):
            continue
        f, s, same = compare(letters, reflections, ell, tally["psi_only_same"] + tally["psi_only_changed"] < PSI_ONLY_CAP)
        key = {(True, True): "both", (True, False): "phi_only", (False, True): "psi_only", (False, False): "neither"}[(f, s)]
        if same is None:
            tally[key] += 1
            continue
        tally[f"{key}_{'same' if same else 'changed'}"] += 1
        if not same and key != "both" and key not in certificates:
            certificates[key] = {"letters": [list(a) for a in letters], "reflections": [list(u) for u in reflections]}
    return {"ell": ell, "length": n, "trials": trials, **{k: tally[k] for k in sorted(tally)}}, certificates


def render() -> str:
    rows, certificates = [], {}
    for ell, n, trials in CONFIGS:
        row, found = census(ell, n, trials)
        rows.append(row)
        for key, cert in found.items():
            certificates.setdefault(key, {"ell": ell, **cert})
    return json.dumps({"schema": "novelty-lab/n2-word-g2/v1", "model": "cayley-dickson/v1 (-1,-1,-1) mod ell",
                       "seed": SEED, "certificates": certificates, "rows": rows}, indent=1, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    text = render()
    if argv[1:] == ["--check"]:
        current = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("OK: word G2 census is current" if current else f"stale: {OUT}")
        return 0 if current else 1
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
