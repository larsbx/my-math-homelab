"""Replay the Python oracle remainder optimization; no theorem authority.

Run from any directory with Python >= 3.10 and git, after fetching the pinned
baseline commit. The JSON report includes exact equivalence checks, paired
timings, operation counts and source digests. Timings are never CI thresholds.
"""

from __future__ import annotations

import ast
import hashlib
import itertools
import json
import os
import platform
import statistics
import subprocess
import sys
import time
import types
from collections import Counter
from cProfile import Profile
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = "cb9db58c9e25209c2a54ccd6955b509af88e8356"
SOURCE = "reference/psc_research/pisot_screen.py"


def load_module(source, name):
    module = types.ModuleType(name)
    exec(compile(source, name, "exec"), module.__dict__)
    return module


def paired_times(old, new, number):
    assert old() == new()  # exact result check and warm-up
    samples = {"before": [], "after": []}
    cpu_samples = {"before": [], "after": []}
    for repeat in range(7):
        order = (("before", old), ("after", new))
        elapsed = {"before": 0.0, "after": 0.0}
        cpu_elapsed = {"before": 0.0, "after": 0.0}
        # Interleave individual calls so slow changes in CPU frequency/load
        # affect each side together rather than an entire before/after batch.
        for iteration in range(number):
            for label, fn in order if (repeat + iteration) % 2 == 0 else order[::-1]:
                start = time.perf_counter()
                cpu_start = time.process_time()
                fn()
                cpu_elapsed[label] += time.process_time() - cpu_start
                elapsed[label] += time.perf_counter() - start
        for label in ("before", "after"):
            cpu_samples[label].append(cpu_elapsed[label])
            samples[label].append(elapsed[label])
    before, after = (statistics.median(samples[k]) for k in ("before", "after"))
    cpu_before, cpu_after = (statistics.median(cpu_samples[k]) for k in ("before", "after"))
    return {"iterations_per_sample": number, "seconds": samples,
            "median_before_seconds": before, "median_after_seconds": after,
            "speedup": before / after,
            "elapsed_reduction_percent": 100 * (1 - after / before),
            "process_seconds": cpu_samples,
            "median_before_process_seconds": cpu_before,
            "median_after_process_seconds": cpu_after,
            "process_speedup": cpu_before / cpu_after}


def arithmetic_calls(fn):
    with Profile() as profile:
        fn()
    calls = {entry.code: entry.callcount for entry in profile.getstats()}
    return {name: calls.get(getattr(Fraction, name).__code__, 0)
            for name in ("_div", "_mul", "_sub")}


def main():
    # Avoid migrations between cores on Linux; process CPU time additionally
    # separates computation from descheduling on a shared host.
    affinity = None
    if hasattr(os, "sched_getaffinity"):
        affinity = min(os.sched_getaffinity(0))
        os.sched_setaffinity(0, {affinity})
    before_source = subprocess.check_output(
        ["git", "show", f"{BASE}:{SOURCE}"], cwd=ROOT, text=True)
    after_source = (ROOT / SOURCE).read_text(encoding="utf-8")
    before_ast, after_ast = (ast.parse(s) for s in (before_source, after_source))
    # Refuse to attribute unrelated changes in the oracle to this optimization.
    for tree in (before_ast, after_ast):
        tree.body = [node for node in tree.body
                     if not isinstance(node, ast.FunctionDef) or node.name != "_poly_rem"]
    assert ast.dump(before_ast) == ast.dump(after_ast), "unrelated oracle change"
    before = load_module(before_source, "before")
    after = load_module(after_source, "after")

    polys = [[]] + [list(c) for n in range(1, 4)
                    for c in itertools.product((-1, 0, 1), repeat=n)]
    encodings = (
        lambda p: [Fraction(c) for c in p],
        lambda p: [Fraction(c, i + 2) for i, c in enumerate(p)],
        lambda p: [value for i, c in enumerate(p)
                   for value in (Fraction(c, i + 2), Fraction(0), Fraction(0))][:-2],
    )
    rem_pairs = sparse_pairs = 0
    for encode in encodings:
        for a, b in itertools.product(polys, repeat=2):
            a, b = encode(a), encode(b)
            snapshot = (list(a), list(b))
            expected, result = before._poly_rem(a, b), after._poly_rem(a, b)
            assert result == expected and [type(c) for c in result] == [type(c) for c in expected]
            assert (a, b) == snapshot
            rem_pairs += 1
            sparse_pairs += after.degree(a) >= after.degree(b) >= 4

    cubics = [list(c) + [1] for c in itertools.product(range(-7, 8), repeat=3)]
    units = [after.has_root_on_unit_circle(p) for p in cubics]
    verdicts = [after.screen(p) for p in cubics]
    assert units == [before.has_root_on_unit_circle(p) for p in cubics]
    assert verdicts == [before.screen(p) for p in cubics]

    specs = []
    for degree_b, degree_a, number in ((12, 48, 3000), (32, 96, 1000)):
        a = [Fraction((-1) ** i * (i + 1), i % 5 + 2)
             for i in range(degree_a + 1)]
        b = [Fraction(-2, 3), Fraction(-3, 5)] + [Fraction(0)] * (degree_b - 2) + [Fraction(5, 7)]
        specs.append((f"sparse_degree_{degree_b}", a, b, number))
    specs.append(("dense_degree_3",
                  [Fraction((-1) ** i * (i + 1), i + 2) for i in range(7)],
                  [Fraction(2, 3), Fraction(-3, 5), Fraction(4, 7), Fraction(-5, 9)],
                  30000))

    workloads = {}
    for name, a, b, number in specs:
        old, new = (lambda: before._poly_rem(a, b)), (lambda: after._poly_rem(a, b))
        measurement = paired_times(old, new, number)
        measurement.update({"dividend": [str(c) for c in a],
                            "divisor": [str(c) for c in b],
                            "arithmetic_calls_per_invocation": {
                                "before": arithmetic_calls(old), "after": arithmetic_calls(new)}})
        workloads[name] = measurement
    workloads["unit_circle_cubic_grid"] = paired_times(
        lambda: [before.has_root_on_unit_circle(p) for p in cubics],
        lambda: [after.has_root_on_unit_circle(p) for p in cubics], 5)
    workloads["screen_cubic_grid"] = paired_times(
        lambda: [before.screen(p) for p in cubics],
        lambda: [after.screen(p) for p in cubics], 5)

    report = {
        "baseline_commit": BASE, "python": sys.version,
        "platform": platform.platform(), "affinity_cpu": affinity, "source_path": SOURCE,
        "source_sha256": {"before": hashlib.sha256(before_source.encode()).hexdigest(),
                          "after": hashlib.sha256(after_source.encode()).hexdigest()},
        "replay_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "equivalence": {"remainder_pairs": rem_pairs, "cached_path_pairs": sparse_pairs,
                        "cubics": len(cubics),
                        "unit_circle_hits": sum(units), "screen_counts": dict(Counter(verdicts))},
        "timing_protocol": "seven paired samples; interleave calls; alternate order; warm up; perf_counter and process_time",
        "workloads": workloads,
    }
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
