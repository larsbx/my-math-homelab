# MAX-parallel PSC census slice — 2026-09-22

**Status:** engineering/performance slice; no mathematical claim changes.

## Boundary

The baseline `kernel/census.mojo` has one naturally independent unit of work:
one member of the canonical 4,554-specimen PIP corpus. This slice parallelizes
that outer boundary only. BPA construction, SCC/productivity logic, state caps,
and every exact predicate remain unchanged and sequential inside one specimen.

The execution primitive is `parallel_fold.parallel_map_fold`, vendored
byte-for-byte from `larsbx/finite-math-kernels`. It uses
`max.algorithm.parallelize` from MAX and folds worker chunks back in index
order. PSC therefore keeps canonical specimen order even when scheduling
changes.

## Failure semantics

Workers perform no I/O and share no mutable census accumulator. Each returns a
finite record containing counters, maximum BPA size, ordered nonproductive
specimen indices, and an optional failure index.

An exception is not converted into a census verdict. The fold keeps the least
failing corpus index, and the driver replays that specimen sequentially so the
underlying kernel raises. Capped automata retain their existing third outcome:
inconclusive, never productive or nonproductive evidence.

## Running

The historical behavior remains the default:

```bash
cd kernel
pixi run census
```

Set the worker count explicitly to activate MAX parallelism:

```bash
PSC_CENSUS_WORKERS=8 pixi run census
```

The worker count must be at least one. No CPU-count guess is made by the
mathematical driver.

## Regression gate

`kernel/tests/test_parallel_census.mojo` evaluates the same canonical corpus
prefix with 1, 2, 3, and 7 workers and requires identical counters, maximum,
failure state, and diagnostic specimen order. It also checks that zero workers
is rejected.

This is the promotion gate for moving further PSC drivers onto MAX. The next
targets are the BPA-heavy C3/C4/defect catalogues, followed by the cache-aware
`overlap-contracting-census` and the collar/pump stages of
`swap-overlap-census`.

## Non-goals

This slice does not:

- parallelize one BPA graph internally;
- change `STATE_CAP` or any search radius;
- add GPU execution;
- change a theorem, proof status, or certificate predicate;
- make absence under a finite cap into nonexistence.
