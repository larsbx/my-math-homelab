#!/usr/bin/env python3
"""The committed N3 baseline grid: descriptive statistics over (n, ell, unit_action).

For each odd prime ell in ELLS, the first COUNT primes n ≥ (ell^3 - ell)/24 with
ell ∤ n (the left-orbit collision regime λ ≈ 1), under both unit actions.
Deterministic across Python versions (floats pass through `stable`);
`--check` compares with the committed output byte for byte.

Usage: grid.py [--check]     writes or checks data/n3/grid-v1.json
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from analyze_collisions import analyze  # noqa: E402
from hurwitz_shell import ACTIONS, CONVENTION, occupancy  # noqa: E402

OUT = HERE.parents[1] / "data" / "n3" / "grid-v1.json"
ELLS, COUNT = (5, 7, 11, 13), 4
FIELDS = ("bins", "shell_size", "lambda", "dispersion_index", "total_variation", "pearson_pooled", "pearson_groups",
          "observed_histogram", "input_sha256")


def stable(value):
    """Floats to 10 decimal places and 12 significant digits. Float sums differ in
    the last bits across Python versions (3.12 compensates them), and a statistic
    that is exactly 0 can come out as 0.0 or as 1e-31 noise."""
    if isinstance(value, float):
        return float(f"{round(value, 10):.12g}") + 0.0
    return [stable(v) for v in value] if isinstance(value, list) else value


def primes_from(start: int, ell: int):
    n = max(start, 2)
    while True:
        if n % ell and all(n % p for p in range(2, int(n ** 0.5) + 1)):
            yield n
        n += 1


def rows() -> list[dict]:
    out = []
    for ell in ELLS:
        gen = primes_from((ell ** 3 - ell) // 24, ell)
        for n in [next(gen) for _ in range(COUNT)]:
            for action in ACTIONS:
                stats = analyze(occupancy(n, ell, action))
                out.append({"n": n, "ell": ell, "unit_action": action, **{k: stable(stats[k]) for k in FIELDS}})
    return out


def render() -> str:
    return json.dumps({"schema": "novelty-lab/n3-grid/v1", "convention": CONVENTION,
                       "claim_status": "experimental descriptive statistic; not a Poisson theorem",
                       "rows": rows()}, indent=1, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    text = render()
    if argv[1:] == ["--check"]:
        current = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("OK: grid is current" if current else f"stale: {OUT}")
        return 0 if current else 1
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
