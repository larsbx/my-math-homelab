#!/usr/bin/env python3
"""H3 on an integral shell: value collisions of length-4 words in Z^8, with operator collisions removed.

In cayley-dickson/v1 (-1, -1, -1) the structure constants are +-1, so Z^8 is a subring and
N = sum x_i^2 is positive definite. The shell S_p = {x in Z^8 : N(x) = p} has 16(p^3 + 1)
elements for an odd prime p. A configuration (p, m, seed) draws m generators from S_p and adds
their conjugates; words are the reduced words of length 4, evaluated as left combs.

Arithmetic is exact: products are computed modulo the prime P = 2^61 - 1 and every value
coordinate lifts to an integer of absolute value below 2^40 (checked). A pair of words with the
same value is an operator collision when the products L_a1 ... L_a4 agree as integer matrices,
and value-only otherwise. For value-only pairs the record counts how many share the
characteristic polynomial of their word defect, computed modulo P (different modulo P implies
different over Q). Two exact nulls, over all pairs: pairs of words, and pairs of words with
different values and equal trace (the classical invariant of a value of fixed norm).

By paper Corollary 3.33 single defects are classical over this definite algebra, so only words
can carry non-classical data here.

Usage: h3_integral.py [--check]     writes or checks data/n2/h3-integral-v1.json
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

OUT = HERE.parents[1] / "data" / "n2" / "h3-integral-v1.json"
P = (1 << 61) - 1
CONFIGS = ((3, 6, 1), (3, 6, 2), (3, 6, 3), (3, 7, 1), (5, 6, 1))     # (p, generators before conjugates, seed)
# A value-only collision of length 3 in configuration (3, 6, 1): equal values, different operators.
CERTIFICATE = {"left": [[1, 0, 0, 0, 0, 1, 0, 1], [1, 0, 1, 0, 0, 1, 0, 0], [-1, 0, 0, 0, -1, 0, 0, -1]],
               "right": [[1, 0, 0, 1, 0, 0, -1, 0], [-1, 0, -1, 0, 0, 0, -1, 0], [1, 0, 1, 0, 0, 1, 0, 0]]}


def shell(n: int, dim: int = C.DIM) -> list[tuple[int, ...]]:
    """Integer vectors of length dim with sum of squares n, in lexicographic order."""
    if dim == 0:
        return [()] if n == 0 else []
    r = int(n ** 0.5)
    return [(t,) + rest for t in range(-r, r + 1) for rest in shell(n - t * t, dim - 1)]


def lift(v) -> tuple[int, ...]:
    out = tuple(t if t <= P // 2 else t - P for t in v)
    assert all(abs(t) < 1 << 40 for t in out), "value outside the exact range"
    return out


def evaluate(letters) -> tuple[tuple[int, ...], C.Mat]:
    """(left-comb value, L_a1 ... L_an), exactly."""
    v, prod = letters[0], C.left(letters[0], P)
    for a in letters[1:]:
        v, prod = C.mul(v, a, P), C.matmul(prod, C.left(a, P), P)
    return lift(v), prod


def words(p: int, m: int, seed: int):
    rng = random.Random(seed)
    base = [tuple(t % P for t in x) for x in rng.sample(shell(p), m)]
    gens, k = base + [C.conj(x, P) for x in base], 2 * m
    for i in range(k ** 4):
        idx = tuple((i // k ** j) % k for j in range(4))
        if not any(idx[j + 1] == (idx[j] + m) % k for j in range(3)):
            letters = [gens[j] for j in idx]
            yield (*evaluate(letters), letters)


def pairs(n: int) -> int:
    return n * (n - 1) // 2


def same_class_pairs(classes) -> int:
    """Pairs of words in the same class, from an iterable of class labels."""
    return sum(pairs(n) for n in Counter(classes).values())


def row(p: int, m: int, seed: int) -> dict:
    rows = [(v, op, C.charpoly(WD.word_defect(letters, P), P)) for v, op, letters in words(p, m, seed)]
    by_value, by_trace = defaultdict(list), defaultdict(list)
    for r in rows:
        by_value[r[0]].append(r)
        by_trace[r[0][0]].append(r)
    operator = value_only = same = 0
    for group in by_value.values():
        for i, a in enumerate(group):
            for b in group[i + 1:]:
                if a[1] == b[1]:
                    operator += 1
                else:
                    value_only += 1
                    same += a[2] == b[2]
    # Exact nulls over all pairs. Equal trace, different values: pairs within a trace minus pairs
    # within a value, both for all pairs and for same-class pairs.
    trace_all = sum(pairs(len(g)) for g in by_trace.values()) - sum(pairs(len(g)) for g in by_value.values())
    trace_same = sum(same_class_pairs(r[2] for r in g) for g in by_trace.values()) - \
        sum(same_class_pairs(r[2] for r in g) for g in by_value.values())
    return {"p": p, "generators": 2 * m, "seed": seed, "reduced_words": len(rows), "distinct_values": len(by_value),
            "defect_classes": len({r[2] for r in rows}),
            "operator_collisions": operator, "value_only_collisions": value_only, "value_only_same_class": same,
            "null_equal_trace_same_class": f"{trace_same}/{trace_all}",
            "null_random_same_class": f"{same_class_pairs(r[2] for r in rows)}/{pairs(len(rows))}"}


def certificate() -> dict:
    (v, a), (w, b) = (evaluate([tuple(t % P for t in x) for x in CERTIFICATE[s]]) for s in ("left", "right"))
    return {**CERTIFICATE, "value": list(v), "values_equal": v == w, "operators_equal": a == b}


def render() -> str:
    return json.dumps({"schema": "novelty-lab/n2-h3-integral/v1", "model": "cayley-dickson/v1 (-1,-1,-1) over Z",
                       "words": "reduced words of length 4, left comb, m shell generators and their conjugates",
                       "certificate": certificate(),
                       "rows": [row(*c) for c in CONFIGS]}, indent=1, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    text = render()
    if argv[1:] == ["--check"]:
        current = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("OK: H3 integral pilot is current" if current else f"stale: {OUT}")
        return 0 if current else 1
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
