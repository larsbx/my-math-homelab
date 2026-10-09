#!/usr/bin/env python3
"""H3 pilot: collisions of length-4 navigation words over F_ell, stratified by word-defect class.

Convention (pilot, no integral lift): generators are m elements of norm 1 in C = A_3 of
cayley-dickson/v1 (-1, -1, -1) over F_ell, drawn with a fixed seed, together with their conjugates
(their inverses). Words are the reduced words of length 4 (no letter next to its inverse), evaluated
as left combs ((a1 a2) a3) a4. Every pair of words with the same value is a collision, split into

* operator collisions: the products L_a1 L_a2 L_a3 L_a4 are equal, so the word defects are equal;
* value-only collisions: the values agree but the operator products do not.

For value-only collisions the record keeps how many share the class of their word defect
(its characteristic polynomial) and the share expected for two random words (the null). Descriptive
only: no significance claim, and the shell is not an integral one.

Usage: h3_pilot.py [--check]     writes or checks data/n2/h3-pilot-v1.json
"""
from __future__ import annotations

import json
import random
import sys
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import defect_census as C  # noqa: E402
import word_defects as WD  # noqa: E402

OUT = HERE.parents[1] / "data" / "n2" / "h3-pilot-v1.json"
CONFIGS = ((5, 5), (7, 5), (7, 6))      # (ell, number of generators before adding conjugates)


def generators(ell: int, m: int) -> list[C.Vec]:
    rng, base = random.Random(100 * ell + m), []
    while len(base) < m:
        x = tuple(rng.randrange(ell) for _ in range(C.DIM))
        if C.norm(x, ell) == 1 and x not in base:
            base.append(x)
    return base + [C.conj(x, ell) for x in base]


def words(ell: int, m: int):
    """(value, operator product, defect class) for every reduced word of length 4."""
    gens, k = generators(ell, m), 2 * m
    for i in range(k ** 4):
        idx = [(i // k ** j) % k for j in range(4)]
        if any(idx[j + 1] == (idx[j] + m) % k for j in range(3)):
            continue
        letters = [gens[j] for j in idx]
        value, product = letters[0], C.left(letters[0], ell)
        for a in letters[1:]:
            value, product = C.mul(value, a, ell), C.matmul(product, C.left(a, ell), ell)
        yield value, product, C.charpoly(WD.word_defect(letters, ell), ell)


def row(ell: int, m: int) -> dict:
    rows = list(words(ell, m))
    by_value = defaultdict(list)
    for r in rows:
        by_value[r[0]].append(r)
    operator = value_only = same_class = 0
    for group in by_value.values():
        for i, a in enumerate(group):
            for b in group[i + 1:]:
                if a[1] == b[1]:
                    operator += 1
                else:
                    value_only += 1
                    same_class += a[2] == b[2]
    n, classes = len(rows), Counter(r[2] for r in rows)
    sphere = ell ** 7 - ell ** 3                     # elements of norm 1 in the split octonions over F_ell
    return {"ell": ell, "generators": 2 * m, "reduced_words": n, "distinct_values": len(by_value),
            "defect_classes": len(classes), "operator_collisions": operator, "value_only_collisions": value_only,
            "value_only_same_class": same_class,
            "random_target_expectation": f"{n * (n - 1) / 2 / sphere:.1f}",
            "null_same_class_share": f"{sum(c * (c - 1) for c in classes.values()) / (n * (n - 1)):.3f}"}


def render() -> str:
    return json.dumps({"schema": "novelty-lab/n2-h3-pilot/v1", "model": "cayley-dickson/v1 (-1,-1,-1) mod ell",
                       "words": "reduced words of length 4, left comb, norm-1 generators and their inverses",
                       "rows": [row(ell, m) for ell, m in CONFIGS]}, indent=1, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    text = render()
    if argv[1:] == ["--check"]:
        current = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("OK: H3 pilot is current" if current else f"stale: {OUT}")
        return 0 if current else 1
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
