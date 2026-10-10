#!/usr/bin/env python3
"""Exact census for A,A,B,B gcd runs in nearest-integer E-sequences.

NON-AUTHORITATIVE. A missing witness is not a theorem.  The diagnostic records
maximal runs rather than suffixes, because long period-four-looking blocks can
be transient.
"""

from __future__ import annotations

import argparse
import json

from kernel.pv_exact import (
    defects,
    gcd_state,
    generate_e,
    period4_aabb_runs,
    transition_data,
)


def run_record(values: list[int], start: int, end: int) -> dict:
    states = gcd_state(values)
    cs = defects(values)
    transition_stop = min(start + 4, len(values) - 2)
    transitions = []
    for n in range(start, transition_stop):
        td = transition_data(*values[n : n + 3])
        transitions.append(
            {
                "n": n,
                "g_n": td.g_n,
                "g_next": td.g_next,
                "b_n": td.b_n,
                "d_n": td.d_n,
                "primitive_det": td.primitive_det,
            }
        )
    defect_stop = min(end - 1, start + 8, len(cs))
    relative = [
        {
            "n": n,
            "numerator": abs(cs[n]),
            "denominator": values[n],
        }
        for n in range(start, defect_stop)
    ]
    return {
        "start": start,
        "end": end,
        "state_count": end - start,
        "full_periods": (end - start) // 4,
        "phase": states[start : start + 4],
        "before": states[max(0, start - 3) : start],
        "after": states[end : end + 3],
        "relative_defects": relative,
        "first_period_transitions": transitions,
    }


def scan(seed_max: int, length: int, min_periods: int) -> dict:
    witnesses = []
    ties = []
    total = 0
    for a0 in range(2, seed_max + 1):
        for a1 in range(a0 + 1, 2 * seed_max + 1):
            total += 1
            try:
                values = generate_e(a0, a1, length)
            except ValueError as exc:
                ties.append({"seed": [a0, a1], "reason": str(exc)})
                continue
            states = gcd_state(values)
            runs = period4_aabb_runs(states, min_periods=min_periods)
            if not runs:
                continue
            longest = max(run.full_periods for run in runs)
            witnesses.append(
                {
                    "seed": [a0, a1],
                    "longest_full_periods": longest,
                    "patterns": sorted({run.pattern for run in runs}),
                    "runs": [
                        run_record(values, run.start, run.end)
                        for run in runs
                    ],
                }
            )
    witnesses.sort(
        key=lambda row: (-row["longest_full_periods"], row["seed"])
    )
    return {
        "parameters": {
            "seed_max": seed_max,
            "length": length,
            "min_periods": min_periods,
        },
        "seed_count": total,
        "tie_count": len(ties),
        "witness_count": len(witnesses),
        "witnesses": witnesses,
        "ties": ties[:50],
        "status": "COMPUTED finite census; absence of witnesses is inconclusive",
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed-max", type=int, default=40)
    parser.add_argument("--length", type=int, default=120)
    parser.add_argument("--min-periods", type=int, default=3)
    args = parser.parse_args()
    print(json.dumps(scan(args.seed_max, args.length, args.min_periods), indent=2))


if __name__ == "__main__":
    main()
