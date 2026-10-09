#!/usr/bin/env python3
"""Deterministic descriptive statistics for a complete collision occupancy vector."""
from __future__ import annotations
import hashlib, json, math, sys
from pathlib import Path

def poisson_pmf(k: int, lam: float) -> float:
    if lam == 0.0:
        return 1.0 if k == 0 else 0.0
    return math.exp(-lam + k * math.log(lam) - math.lgamma(k + 1))

def analyze(payload: dict) -> dict:
    xs = payload.get("multiplicities")
    if not isinstance(xs, list) or not xs or any(type(x) is not int or x < 0 for x in xs):
        raise ValueError("multiplicities must be a nonempty list of nonnegative integers")
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    bins, total = len(xs), sum(xs)
    lam = total / bins
    variance = sum((x-lam)**2 for x in xs) / bins
    max_k = max(xs)
    observed = [xs.count(k) for k in range(max_k+1)]
    expected = [bins * poisson_pmf(k, lam) for k in range(max_k)]
    expected.append(bins - sum(expected))  # fold Poisson tail into final class
    tv = 0.5 * sum(abs(o/bins-e/bins) for o,e in zip(observed, expected))
    # Conservative adjacent pooling for a descriptive Pearson statistic.
    groups=[]; oo=ee=0.0
    for o,e in zip(observed,expected):
        oo += o; ee += e
        if ee >= 5.0:
            groups.append((oo,ee)); oo=ee=0.0
    if ee:
        if groups:
            a,b=groups.pop(); groups.append((a+oo,b+ee))
        else: groups.append((oo,ee))
    pearson = sum((o-e)**2/e for o,e in groups if e>0)
    return {
      "schema_version":1,"input_sha256":hashlib.sha256(canonical).hexdigest(),
      "bins":bins,"shell_size":total,"lambda":lam,"mean":lam,
      "variance":variance,"dispersion_index":None if lam==0 else variance/lam,
      "observed_histogram":observed,"poisson_expected_tail_folded":expected,
      "total_variation":tv,"pearson_pooled":pearson,
      "pearson_groups":len(groups),
      "claim_status":"experimental descriptive statistic; not a Poisson theorem"
    }

def main(argv: list[str]) -> int:
    if len(argv)!=2:
        print(f"usage: {argv[0]} INPUT.json", file=sys.stderr); return 2
    try:
        payload=json.loads(Path(argv[1]).read_text(encoding="utf-8"))
        print(json.dumps(analyze(payload),sort_keys=True,indent=2))
    except (OSError,json.JSONDecodeError,ValueError) as e:
        print(f"refused: {e}",file=sys.stderr); return 1
    return 0
if __name__=="__main__": raise SystemExit(main(sys.argv))
