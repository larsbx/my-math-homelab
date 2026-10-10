# Python oracle sparse rational remainder: 2026-10-08

## Scope and exact semantics

PR #228 was rebased from `3a2d89fea7adcd9757ab127f2b31b544b7b8bb77`
onto `main@cb9db58c9e25209c2a54ccd6955b509af88e8356`. This repairs the
secondary Python oracle's `_poly_rem` optimization. The canonical Mojo
implementation and mathematical claim statuses are unchanged.

For a divisor of degree at least four, when division is needed, the function
caches its leading coefficient's exact reciprocal and the ordered nonzero
coefficients. Each cancellation multiplies by that reciprocal and subtracts
only nonzero terms. Over the rationals these are precisely the same
operations as ordinary dense long division: multiplying by the reciprocal
equals division, and a skipped term would subtract zero. The leading term
is still cleared explicitly, and the cached degree still descends across
all consecutive zero coefficients.

Divisors of degree zero through three retain the existing dense loop.
Initial measurements of the unconditional cached path exposed setup
overhead on small divisors; degree four is a conservative dispatch boundary,
not a claimed optimal cutoff for every workload. A dividend already below
the divisor's degree avoids the setup. Neither input is modified. Remainders
keep the existing list length rather than trimming low-order zeros, and
the legacy empty result for a zero or constant divisor is preserved.

The private remainder contract uses exact `Fraction` coefficients. Public
gcd callers continue to canonicalize integer, mixed and subclass inputs to
exact `Fraction` values before division, as covered by the existing gcd
regressions. No floating approximation enters polynomial arithmetic.

## Deterministic correctness and work regression

[test_pisot_screen.py](../tests/test_pisot_screen.py) supplies an independent
dense reference: first solve the quotient coefficients from their triangular
system using ordinary division, then subtract the dense convolution `q*b`
from the original dividend. It does not use the production degree helper,
cached reciprocal, sparse coefficient list or mutable remainder loop.

The fixed sparse rational case constructs `a = q*b + r` with a negative,
non-unit leading coefficient, three nonzero divisor terms, interior zeros
and a trailing zero beyond the true degree. It checks the known remainder,
the independent reference, exact output types and input preservation.
A deterministic grid checks 4,800 ordered pairs under three rational
encodings, including zero, constant and trailing-zero polynomials. The
gapped encoding exercises the cached path on 324 pairs.

A separate non-timing regression profiles nine cancellation steps with a
degree-four two-term divisor. It requires zero repeated rational divisions
and exactly 18 subtractions, where the baseline performs 9 divisions and
45 subtractions. This regression was also run with the baseline function
substituted and fails as expected. All 21 Pisot-screen tests pass.

The benchmark additionally compares the entire `has_root_on_unit_circle`
and `screen` outputs on all 3,375 monic cubics with other coefficients in
`[-7, 7]`: both implementations report 358 unit-circle hits and verdict
counts `pisot=436`, `not-pisot=2870`, `refused=69`.

## Benchmark evidence

The [replay script](../oracles/python/poly_rem_benchmark.py) reads the pinned
baseline with `git show` and refuses to attribute unrelated changes in the
oracle module to this optimization. Its
[recorded JSON](../evidence/poly-rem-sparse-2026-10-08/benchmark.json)
contains source and replay digests, all raw timing samples, exact input
coefficients, equivalence counts and arithmetic operation counts. The
record is pinned by
[SHA256SUMS](../evidence/poly-rem-sparse-2026-10-08/SHA256SUMS).

Measured on CPython 3.12.14 (Clang 22.1.3), Linux x86-64 with glibc 2.39,
on a shared host. On Linux the replay pins itself to one allowed CPU.
Seven paired samples follow a warm-up; calls are interleaved and their
before/after order alternates. Both elapsed time and process CPU time are
recorded to make scheduling noise visible. Timing is not a CI threshold.

| Workload | Work per sample | Baseline elapsed s | Candidate elapsed s | Elapsed speedup | CPU speedup |
| --- | --- | ---: | ---: | ---: | ---: |
| Sparse divisor degree 12, dividend degree 48 | 3,000 calls | 1.987176 | 0.622821 | 3.19× | 3.17× |
| Sparse divisor degree 32, dividend degree 96 | 1,000 calls | 2.348424 | 0.316269 | 7.43× | 7.46× |
| Dense divisor degree 3, dividend degree 6 | 30,000 calls | 0.714805 | 0.718018 | 1.00× | 1.00× |
| Unit-circle test, cubic grid | 5 × 3,375 cubics | 0.454351 | 0.487027 | 0.93× | 0.93× |
| Full screen, cubic grid | 5 × 3,375 cubics | 0.932175 | 0.852225 | 1.09× | 1.10× |

For the degree-12 sparse divisor the number of subtraction calls falls from
481 to 111 per invocation; for degree 32, from 2,145 to 195. The corresponding
division counts fall from 37 and 65 to zero. Reciprocal multiplication adds
one multiplication per cancellation. The dense cubic control retains the
same arithmetic counts on each side.

Writing `d` for divisor degree, `s` for its nonzero coefficient count and
`L` for the number of cancellations, the dense loop performs
`L*(d+1)` coefficient multiplications and subtractions plus `L` divisions.
The cached path scans `d+1` coefficients once, performs `L*s` coefficient
multiplications and subtractions, and adds `L` factor multiplications.
These are operation counts, not a bit-complexity bound: rational coefficient
sizes affect each operation's cost. Dense divisors have no asymptotic saving.

The supported performance result is the saving on these specified larger
sparse divisions. No uniform dense-polynomial or whole-screen speedup is
claimed. The original unrecorded "14s to 8s" figure is withdrawn. The
incorrectly dated `2024-05-18` record introduced by this PR in
`.jules/bolt.md` is removed; the optimization finding is recorded in the
canonical append-only side-notes ledger with this October 2026 locator.

SHA-256 of the measured files:

- Baseline oracle: `82b13c5ac602923a8c1c9fd0cbecd13ca0e1d9d6794c562f4c36c746fca052e2`.
- Candidate oracle: `a77323006371c665da610e58c826318b5bac50709e6c3d02b8902a78c56152ca`.
- Replay script: `7de580f0ee054aeb9a7c136b4503a41d2e0fb6ce1b95f9a8300689f33867b4a5`.

## Reproduce and validate

From the repository root, with the pinned baseline commit available locally:

```sh
python3 oracles/python/poly_rem_benchmark.py > /tmp/poly-rem-benchmark.json
sha256sum -c evidence/poly-rem-sparse-2026-10-08/SHA256SUMS
python3 -m pytest tests/test_pisot_screen.py
python3 -m pytest
./tools/verify_all.sh provenance
python3 tools/corpus_refinement.py --check
```

Replay the recorded candidate by checking out the repair commit first; later
changes to unrelated oracle functions deliberately fail the script's scope
check. Raw timing samples depend on the machine and load, whereas the exact
equivalence and arithmetic counts are deterministic.

The Markdown-link guard reads tracked paths from Git's index. When removing
the unmerged `.jules/bolt.md` record, stage its deletion before running the
guard so it does not try to open the removed file.
