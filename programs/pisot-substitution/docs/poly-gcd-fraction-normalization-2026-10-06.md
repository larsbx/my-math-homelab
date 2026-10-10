# Python oracle gcd normalization: 2026-10-06

## Scope and semantic check

PR #221 was rebased from `839ccd329aa5276c670a3f737f0e5233f42f363c`
onto `main@c2bd9a09555a91c6ebf65e3b477121c9dc5a554b`. The only
algorithm change is the input normalization in
`reference/psc_research/pisot_screen.py::_poly_gcd`: reuse a coefficient
whose exact type is `Fraction`, and retain `Fraction(x)` for every other
input, including subclasses. Both input sequences still become new lists.
Exact `Fraction` values are immutable; polynomial arithmetic and monic
normalization are unchanged. Keeping the exact-type test preserves the
old canonicalization of subclasses and prevents their arithmetic overrides
from reaching the gcd.

The replay below checks that the two source files differ only by this
normalization. It compares 4,800 gcd pairs: all 40 low-degree-first
polynomial lists of length zero through three with coefficients in
`{-1, 0, 1}`, paired under integer, rational, and mixed encodings. Results,
exact output types, and input preservation agree. It also compares each
unit-circle and screen result on all 3,375 monic cubics with the other
coefficients in `[-7, 7]`. Both versions report 358 unit-circle hits and
screen counts `pisot=436`, `not-pisot=2870`, `refused=69`.

The deterministic regressions in [test_pisot_screen.py](../tests/test_pisot_screen.py)
guard these contracts with known gcds, zero/constant/trailing-zero cases,
and a subclass whose division raises if canonicalization is skipped.
`test_poly_gcd_does_not_reconstruct_exact_fraction_coefficients` profiles
zero-polynomial inputs to isolate normalization: it fails on the baseline
and passes on the optimized function, without a timing threshold.
All 18 tests in that file pass.

This change concerns the secondary Python oracle. The canonical Mojo
kernel, its classifications, and all claim statuses are unchanged.

## Benchmark evidence

Measured with CPython 3.12.14 (Clang 22.1.3), Linux x86-64 with glibc 2.39.
Each workload has seven paired elapsed-time samples, alternating baseline
and candidate order after a warm-up. Times are medians in seconds on a
shared container; the regression suite was also running. Small end-to-end
gains depend on the environment and are not CI thresholds.

| Workload | Work per sample | Baseline seconds | Optimized seconds | Elapsed reduction |
| --- | --- | ---: | ---: | ---: |
| Normalize 10 exact `Fraction` coefficients | 100,000 lists | 0.477466 | 0.031462 | 93.4% |
| Rational gcd with common factor `x - 1` | 20,000 calls | 0.416121 | 0.359655 | 13.6% |
| `has_root_on_unit_circle` on the cubic grid | 3,375 cubics | 0.089709 | 0.080047 | 10.8% |
| `screen` on the same cubic grid | 3,375 cubics | 0.148087 | 0.138660 | 6.4% |

The normalization-only speedup is not a whole-screen speedup. The
measured gcd and caller workloads retain a benefit while returning the
same exact results. No asymptotic complexity change is claimed.

SHA-256 of the measured source files:

- Baseline: `1a0f33d4594a4f768faff9cd2cd9cc3a9a18c0131f68bd3deb5767a06a5cf8e8`.
- Optimized: `82b13c5ac602923a8c1c9fd0cbecd13ca0e1d9d6794c562f4c36c746fca052e2`.

## Reproduce

Run from the repository root with Python 3.12 after fetching the named base
commit. The script has no third-party dependencies, reads the committed
baseline with `git show`, and prints source digests, correctness counts,
all fourteen raw timings per workload, and their medians. It measures the
existing Python oracle; it introduces no new mathematical implementation.

```sh
python3 - <<'PY'
import hashlib
import itertools
import json
import platform
import statistics
import subprocess
import sys
import time
import types
from collections import Counter
from fractions import Fraction
from pathlib import Path

BASE = "c2bd9a09555a91c6ebf65e3b477121c9dc5a554b"
SOURCE = "reference/psc_research/pisot_screen.py"
before_source = subprocess.check_output(["git", "show", f"{BASE}:{SOURCE}"], text=True)
after_source = Path(SOURCE).read_text()
before, after = types.ModuleType("before"), types.ModuleType("after")
exec(compile(before_source, "before", "exec"), before.__dict__)
exec(compile(after_source, "after", "exec"), after.__dict__)

# The baseline and candidate differ only in the input normalization of _poly_gcd.
normalization = "    a, b = [Fraction(x) for x in a], [Fraction(x) for x in b]\n"
replacement = (
    "    # Exact Fractions are immutable; canonicalize all other types, including subclasses.\n"
    "    a = [x if type(x) is Fraction else Fraction(x) for x in a]\n"
    "    b = [x if type(x) is Fraction else Fraction(x) for x in b]\n"
)
assert before_source.count(normalization) == 1
assert before_source.replace(normalization, replacement) == after_source

polys = [[]] + [list(c) for n in range(1, 4)
                for c in itertools.product((-1, 0, 1), repeat=n)]
encode = (
    lambda p: list(p),
    lambda p: [Fraction(c, i + 2) for i, c in enumerate(p)],
    lambda p: [Fraction(c) if i % 2 else c for i, c in enumerate(p)],
)
gcd_cases = 0
for convert in encode:
    for a, b in itertools.product(polys, repeat=2):
        a, b = convert(a), convert(b)
        snapshot = (list(a), list(b))
        expected, result = before._poly_gcd(a, b), after._poly_gcd(a, b)
        assert result == expected and all(type(c) is Fraction for c in result)
        assert (a, b) == snapshot
        gcd_cases += 1

cubics = [list(c) + [1] for c in itertools.product(range(-7, 8), repeat=3)]
unit_before = [before.has_root_on_unit_circle(p) for p in cubics]
unit_after = [after.has_root_on_unit_circle(p) for p in cubics]
screen_before = [before.screen(p) for p in cubics]
screen_after = [after.screen(p) for p in cubics]
assert unit_before == unit_after and screen_before == screen_after

def paired_times(old, new, number):
    assert old() == new()  # warm up both paths and compare the timed result
    samples = {"before": [], "after": []}
    for repeat in range(7):
        order = (("before", old), ("after", new))
        for label, fn in order if repeat % 2 == 0 else order[::-1]:
            start = time.perf_counter()
            for _ in range(number):
                fn()
            samples[label].append(time.perf_counter() - start)
    old_median, new_median = (statistics.median(samples[k]) for k in ("before", "after"))
    return {"iterations_per_sample": number, "seconds": samples,
            "median_before_seconds": old_median, "median_after_seconds": new_median,
            "speedup": old_median / new_median,
            "elapsed_reduction_percent": 100 * (1 - new_median / old_median)}

coeffs = [Fraction(i, i + 1) for i in range(1, 11)]
a = [Fraction(c, 6) for c in (3, -4, -1, 2)]
b = [Fraction(2 * c, 5) for c in (-2, 1, 1)]
report = {
    "base_sha": BASE, "python": sys.version, "platform": platform.platform(),
    "source_sha256": {"before": hashlib.sha256(before_source.encode()).hexdigest(),
                      "after": hashlib.sha256(after_source.encode()).hexdigest()},
    "gcd_pairs_checked": gcd_cases, "cubics_checked": len(cubics),
    "unit_circle_hits": sum(unit_after), "screen_counts": dict(Counter(screen_after)),
    "normalization": paired_times(lambda: [Fraction(x) for x in coeffs],
                                  lambda: [x if type(x) is Fraction else Fraction(x) for x in coeffs], 100_000),
    "gcd": paired_times(lambda: before._poly_gcd(a, b), lambda: after._poly_gcd(a, b), 20_000),
    "unit_circle": paired_times(lambda: sum(before.has_root_on_unit_circle(p) for p in cubics),
                                lambda: sum(after.has_root_on_unit_circle(p) for p in cubics), 1),
    "screen": paired_times(lambda: Counter(before.screen(p) for p in cubics),
                           lambda: Counter(after.screen(p) for p in cubics), 1),
}
print(json.dumps(report, indent=2))
PY
```
