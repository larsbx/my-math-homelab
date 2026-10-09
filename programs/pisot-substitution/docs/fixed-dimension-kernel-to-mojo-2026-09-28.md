# Moving the fixed-dimension kernel to Mojo, and what the numbers say — 2026-09-28

A review finding on PR #164 ("⚡ Bolt: Unroll small mathematical operations for
significant speedup"):

> This commit is explicitly a performance optimization, but every executable
> change implements and duplicates the optimized kernels under
> `reference/psc_research/`, with no corresponding canonical implementation under
> `kernel/` or documented blocker. That makes the secondary Python oracle the
> target of performance-sensitive research work; implement and benchmark the
> fixed-dimension kernel in Mojo first, retaining Python only as an independent
> cross-check.

The finding is correct, and the measurements below say it is worth acting on for
a stronger reason than the rule: the best the Python optimisation can achieve
still lands several times behind the *unoptimised* canonical kernel.

## What the kernel is

Four Python modules each carried a private copy of the same short-vector
arithmetic — `prefix_difference.py`, `prefix_ancestry.py`,
`orientation_spectrum.py` and `factorization_degree2.py`. Between them: four
`_matvec`, two `_add`, two `_sub`. The prefix-difference lift, the ancestry
step, the orientation gauge and the mid-area residual all reduce to `M x`,
`x + y` and `x - y` on dimension two or three. One kernel, four copies, and PR
#164 proposed to unroll the copies.

## The measurement

Identical workload on both sides: the 348 distinct incidence matrices of the
alphabet-3 PIP corpus, `300` passes, `104,400` matvec calls, seed `(1,2,3)`, and
a checksum depending on every value — `1418400` from every implementation, which
is also the differential. Same container, runs interleaved.

| implementation | mean | vs canonical |
| --- | --- | --- |
| Python generic (what is on `main`) | 186.9 ms | **14.4× slower** |
| Python unrolled (what PR #164 proposes) | 58.2 ms | **4.5× slower** |
| Mojo generic loop | 13.9 ms | 1.07× |
| **Mojo, dimension three unrolled** | **13.0 ms** | 1.00 |

Two things follow.

**PR #164's optimisation is real.** 3.2× in Python, which matches the "up to 3x"
PR #164's optimisation note claims. Nothing here disputes the measurement.

**It is spent in the wrong place.** After a 3.2× win the oracle is still 4.5×
slower than the canonical kernel, and 4.2× slower than the canonical kernel's
*naive loop* — the version with no optimisation in it at all. Performance work
on this kernel cannot reach the canonical implementation's starting line by
optimising the oracle.

**And the "3x" is a fact about Python, not about the kernel.** The same unroll,
in Mojo, is worth about a tenth as much, because a compiler already does most of
it. Measured over the same workload:

| Mojo path | generic | dimension-three unrolled | gain |
| --- | --- | --- | --- |
| `matvec` | 14.64 ms | 13.22 ms | **−9.7%** |
| `add` + `sub` | 19.58 ms | 17.14 ms | **−12.5%** |

Three paired runs each, every pair favouring the unroll. It is kept for that
reason and no other; `kernel/integer_vector_bench.mojo` is the measurement, and
`pixi run integer-vector-bench` re-runs it.

## What landed

`kernel/finite_linear_algebra/integer_vector.mojo` is the canonical kernel. Two contracts, both
inherited from the oracle and both fail-closed:

- a dimension that does not agree raises, never a truncated or zero-padded
  answer;
- every product and sum is checked, so an intermediate past the 64-bit range
  raises instead of wrapping.

The second is the one place the two implementations genuinely differ, because
Python's `int` is arbitrary precision and cannot overflow. That asymmetry is
asserted from both sides: `kernel/tests/test_integer_vector.mojo` pins each
overflow case as a *refusal*, and `tests/test_integer_vector_oracle.py` pins the
same cases as exact values. Neither side wraps, which is the property that
matters — the kernel declines to answer rather than answering wrongly.

`reference/psc_research/fixed_vector.py` is now the single oracle, and the four
private copies are gone. It stays in its generic, obvious form deliberately: an
oracle earns its keep by reading straight off the definition, and a
dimension-specialised branch there would add a second path taken by exactly the
dimensions the corpus uses — the worst place to put an unverified shortcut.

The specialised Mojo paths are checked against the general loop over a
`7^3 × 5` grid rather than by inspection, since "these two spellings of the same
sum agree" is the assumption an unroll exists to violate. Both languages also
derive the same two corpus checksums independently — `4728` and `1576` over the
348 distinct incidence matrices — so a divergence surfaces as a number.

`kernel/finite_exact/checked_int.mojo` now holds the checked integer primitives once.
`psc/perron_field3.mojo` had the only other copy and delegates to it; paired
alternating runs of the coincidence census put that at 42.44 s before and
41.96 s after, so the indirection is free.

## What this does *not* establish

- **The four Python modules are still Python-only.** What moved to Mojo is the
  fixed-dimension kernel they share, which is what the finding named. The
  research logic above it — the prefix lift, the ancestry path, the orientation
  gauge, the mid-area factorisation, about 970 lines — has no Mojo
  implementation, and porting it is a separate piece of work.
- **The benchmark is one shape of one workload**: dimension three, corpus
  incidence matrices, small entries. It says nothing about dimension two, about
  large coordinates, or about the cost inside the callers, which was never
  measured on either side.
- **Timings are from one session container** and are comparable to each other,
  never to CI.
- **`.jules/bolt.md` still records the "unroll is up to 3x" learning without the
  qualification that it is a fact about interpreted Python.** That file is the
  one that will drive the next such PR. It is left alone here only because
  PR #164 also edits it and a conflict would be worse than a note; correcting it
  is the obvious follow-up.

2026-10-06 cleanup resolution: the generic `.jules/bolt.md` advice was removed.
The workload, measured results and reproduction command remain in this note
and `kernel/integer_vector_bench.mojo`.
