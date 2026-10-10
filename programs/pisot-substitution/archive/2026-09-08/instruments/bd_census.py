"""bd_census.py — exact-convention G0^ER census over the exhaustive k=3 PIP corpus.

Per specimen: b1 (asymptotic-cycle count), components (MUST be 1: irreducible-Pisot
invariant, asserted), permutation cycle type, det.  Output: per-row jsonl + summary.
Supersedes the 2026-06-12 proxy census (150 specimens, transcript-only script).
"""
from __future__ import annotations

import json
import sys
from collections import Counter

sys.path.insert(0, "/mnt/project")
sys.path.insert(0, "/home/claude")

from census import enum_k3, is_pip  # noqa: E402
from psc_core import incidence_matrix, int_det  # noqa: E402
from bd_exact import bd_profile, _gate  # noqa: E402

_gate()  # gate every run

rows = []
viol_connect = 0
with open("/home/claude/bd_rows.jsonl", "w") as f:
    for idx, s in enumerate(enum_k3()):
        ok, det, beta = is_pip(s)
        if not ok:
            continue
        p = bd_profile(s)
        if p["components"] != 1:
            viol_connect += 1  # would falsify implementation or BBJS reading
        row = {"idx": idx, "images": [list(w) for w in s.images],
               "det": int(int_det(incidence_matrix(s))), **p,
               "perm_cycles": list(p["perm_cycles"])}
        rows.append(row)
        f.write(json.dumps(row) + "\n")

n = len(rows)
b1s = Counter(r["b1"] for r in rows)
uni = [r for r in rows if abs(r["det"]) == 1]
uni_b1 = Counter(r["b1"] for r in uni)
girths = Counter(max(r["perm_cycles"]) for r in rows)

print(f"PIP specimens: {n} (expect 4554)")
print(f"connectivity violations (must be 0): {viol_connect}")
print(f"b1 distribution: {dict(sorted(b1s.items()))}")
print(f"  homological Pisot (b1=0): {b1s[0]} = {100*b1s[0]/n:.1f}%")
print(f"unimodular subfamily: {len(uni)}; b1 distribution: {dict(sorted(uni_b1.items()))}")
print(f"  unimodular & b1=0 (unconditional cr>=3 triple import): {uni_b1[0]}")
print(f"max ER-permutation cycle length distribution: {dict(sorted(girths.items()))}")
print(f"max b1 specimen: {max(rows, key=lambda r: r['b1'])}")
