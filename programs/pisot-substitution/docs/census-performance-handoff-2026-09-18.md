# Where the census layer's time goes — measurement and handoff, 2026-09-18

A fine-toothed pass over the Mojo census and catalogue layer, to say what is
worth optimising next and what is not. Everything below is measured. Two of the
things measured contradict what reading the code suggested, and those are
recorded as prominently as the findings, because the point of the exercise is
to stop the next session from spending its time where this one nearly did.

## How this was measured

Three sources, not comparable with each other, each internally consistent:

1. **CI step durations**, read off workflow run `35276013007` (head `a156fa0`).
   These are the numbers that set CI wall clock.
2. **A local sweep** of every `pixi run <task>` on the session container, one
   run each. The container is slower than the runner on some jobs and faster on
   others; use these for *ratios between tasks*, never against CI.
3. **Attribution probes**: short drivers that do a prefix of a census's work
   over the full corpus, so the cost of each layer is the difference between
   consecutive probes. The recipe is at the end so it can be redone.

## CI: only two jobs matter

| step | duration |
| --- | --- |
| overlap-contracting-census | **7m 02s** |
| swap-overlap-census | **6m 13s** |
| pytest | 5m 11s |
| Mojo regression tests | 4m 19s |
| oa-failures-probe | 3m 35s |
| c4-census | 1m 52s |
| c3-census | 1m 51s |
| swap-discrepancy-census | 1m 31s |
| census.mojo (inside mojo-kernel) | 1m 15s |
| coincidence-formula-census | 55s |
| oa-type-inclusion-census | 49s |
| numeration-addition-census | 25s |
| numeration-conversion-census | 17s |
| automatic-route-census | 15s |

The workflow runs about 8m45s wall. Everything from `pytest` down finishes
inside the shadow of the top two, so **only `overlap-contracting-census` and
`swap-overlap-census` move CI wall clock.** Work on anything else buys runner
minutes and local iteration speed, which are worth having, but will not show up
as a shorter CI.

## Local sweep

| task | s | | task | s |
| --- | --- | --- | --- | --- |
| overlap-contracting-census | 502.8 | | oa-type-inclusion-census | 45.9 |
| swap-overlap-census | 473.2 | | numeration-addition-census | 14.9 |
| test (36 Mojo files) | 283.9 | | numeration-conversion-census | 12.3 |
| oa-failures-probe | 254.3 | | boundary-sync-sweep | 11.1 |
| c3-census | 111.7 | | verify | 8.6 |
| c4-census | 110.1 | | degree2-three-state-census | 7.4 |
| census | 106.0 | | automatic-route-census | 5.5 |
| defect-degree-census | 104.7 | | endpoint-core-catalog | 4.3 |
| degree3-catalog | 89.7 | | | |
| swap-discrepancy-census | 86.7 | | | |
| wedge-productivity-catalog | 83.3 | | | |

Seven drivers cluster at 83–112s, and they share one thing: each builds the
balanced-pair automaton `B_sigma` for every corpus specimen. There is an eighth
caller of `psc.bpa.build`, `degree2_three_state_census`, and it is the exception
that shows what the others are paying for: it screens on parity and on a trace
condition *before* building, so it reaches the build rarely and finishes in
7.4s.

## Attribution

### overlap-contracting-census, 502.8s

| layer | cumulative | this layer |
| --- | --- | --- |
| `pip_corpus()` alone | 4.9 | 4.9 |
| + seed-patch overlap graph | 9.4 | 4.5 |
| + productivity and left-aligned depths | 9.7 | 0.3 |
| + **contracting-bound construction** | 174.8 | **165.1** |
| + **`least_level` per vertex** (the whole census) | 502.8 | **328.0** |

**98% of the longest job in CI is contracting-bound work**, split roughly
two-to-one between evaluating the bound per vertex and constructing it.

### swap-overlap-census, 473.2s

| layer | cumulative | this layer |
| --- | --- | --- |
| `pip_corpus()` + overlap graph | 9.4 | — |
| + all four depth statistics | 9.9 | 0.5 |
| + `zero_shift_free_recurrent_sccs` | 10.2 | 0.3 |
| + `collapsing_seed_pair_count` | 10.0 | 0.0 |
| + **`separation_radius`** | 255.4 | **245.4** |
| the whole census (adds the **pump-lift survey**) | 473.2 | **217.8** |

The four depth statistics (`first_coincidence_depths`,
`first_left_aligned_depths`, and `strong_coincidence_depth_from` on both
orientations) cost half a second across the corpus. The zipper-SCC scan costs a
third of a second, over 6,986 SCCs found. The collapsing-seed-pair count is free
to measurement noise, and finds 120 collapsing specimens.

So this census is **two comparable costs, not one**: the separation radius at
245s and the pump-lift survey at 218s, with everything else at 10s. Optimising
either alone halves nothing.

## Two things that are *not* worth doing

Recorded so they are not rediscovered.

**The seed-patch overlap graph is not the cost.** Reading the code suggests it
should be: it is built once per specimen in both of the two longest jobs, it
rebuilds its sign cache per specimen although only 348 distinct incidence
matrices exist, and it computes `overlap_children_cached` twice per state (once
in the breadth-first pass, once to resolve edges). All true, and all irrelevant:
building every graph in the corpus costs **4.5s**. Prototypes of both fixes were
measured — hoisting the sign cache per incidence matrix, and keeping the
children from the first pass — and together they take the corpus-wide graph
build from 9.4s to 8.3s including the 4.9s corpus screen. About one second.
The earlier caching work (`PerronCache`, `ContractingBoundCache`) already took
this apart; there is nothing left in it.

**`pip_corpus()` is not a hidden fixed cost.** The seven-driver cluster at
83–112s looks like a shared constant, and the corpus screen is the obvious
suspect since every driver pays it. It is **4.9s**. `automatic-route-census`
builds the same corpus and finishes in 5.5s, which settles it. The cluster is
`B_sigma`, not the corpus.

## Ranked candidates

### 1. `ContractingBound.least_level` — 328s, 65% of the longest CI job

The per-vertex evaluation. `ContractingBoundCache` already memoises it by
(bound, shift), so the question is whether the memo is hitting and what a miss
costs. `least_level` scans `for m in range(1, max_level + 1)` and issues exact
cubic sign queries at each level until one succeeds, so a miss costs a linear
walk in the answer with Sturm–Tarski arithmetic at every step.

Worth measuring first, before changing anything: the hit rate of the level memo,
the distribution of the returned `m`, and how much of the cost is the sign
queries rather than the walk. If `m` is typically small the walk is not the
problem and the sign arithmetic is; if `m` is often large, the walk is, and the
predicate is monotone in `m`, so a doubling search would turn a linear walk into
a logarithmic one.

### 2. `ContractingBound` construction — 165s, 33% of the same job

1,617 distinct (cubic, digit set) pairs, so about 100ms each. Construction
isolates the real roots and fills the level tables `A`, `B`, `G` and
`beta_pow` up to `max_level`. If the levels actually reached are far below
`max_level` — which candidate 1's distribution would show — the tables can be
filled lazily and most of that work never done.

### 3. `separation_radius` (245s) and the pump-lift survey (218s) — together 98% of the second-longest CI job

Two costs of the same order, so the job needs both addressed or neither.

`separation_radius` runs per specimen at `COLLAR_RADIUS_CAP = 6`, searching for
the least radius at which every occurrence's one-step ancestry is determined by
its collar, and carries its own `max_states = 200000`. The census already
reports the distribution of its answers, which is worth more than a mean: 618
specimens resolve at radius 1, 2,664 at radius 2, 912 at 3, 216 at 4, 12 at 5,
12 at 6 — and **120 do not resolve at all**, because a collision survives the
cap and the function returns `-1`.

That sentinel is a trap for anyone summing the returned values: a naive total is
9,558, which is the resolved total of 9,678 with 120 sentinels subtracted as
`-1`. It is not a workload figure either way, and the unresolved specimens are
the *most* expensive, not the cheapest — each searches every radius up to the
cap and finds nothing.

So the common case is already cheap and the tail is not: about 60% of specimens
stop at radius 2, while 132 — the 12 at radius 6 plus the 120 survivors — pay
the full cap. If the cost of building collars grows with the radius, those 132
can dominate the other 4,422 despite being 3% of them. Measure that split first;
optimising the common case would then buy nothing.

The pump-lift survey runs **once per specimen that has any zipper SCC**, not
once per SCC — `pumps.absorb` sits inside `if len(zipper_sccs) > 0`. The census
reports 4,524 such specimens against 6,986 SCCs, so a per-call attribution
divides its 218s by 4,524. Its cost still needs attributing per call before
anything is changed, since a survey that is expensive because it runs often
needs different treatment from one that is expensive per call.

### 4. `B_sigma` with the children kept — measured −16.7%

`substitution_dynamics.automaton.build` computes `children(sigma, state)` once
in the breadth-first pass and again in the edge pass. A prototype that keeps
the first result and resolves edges from it takes the corpus-wide build from
**86.4s to 72.8s** (81.5s to 67.9s net of the corpus screen). The saving is real
but smaller than the double computation suggests, so the remaining five-sixths
is the breadth-first machinery itself: `Pair.key()` builds a fresh `String` per
state, per lookup, over words that reach tens of thousands of letters.

This is **vendored** from `larsbx/finite-math-kernels`. It touches eight CI
steps, none of them on the critical path, so it buys roughly 110s of runner time
per CI run and a noticeably faster local loop — not a shorter CI.

## Capability, not speed

These do not matter for wall clock and do matter for what can be run at all.

- **`psc/numeration_addition.mojo` scans its state list linearly** on every
  transition (`for i in range(len(keys))`), so its exploration is quadratic in
  the state count. The conversion and coincidence automata already use a `Dict`
  for exactly this. Worth fixing on its own terms, and then the consequence has
  to be faced: at `STATE_CAP = 3000` the addition census refuses 8 of 117
  attempted specimens, and those refusals may be an artefact of a cap that was
  set to what a quadratic search could afford. Re-measuring with a higher cap
  could turn some into built automata, which **changes a reported number** and
  needs its own explanation.
- **`psc/automata.mojo`'s `minimised` and `project` both scan a `List[String]`
  of keys linearly** (`_subset_index`, and the block-signature lookup inside the
  refinement loop). Quadratic in states. This is what bounds how large an
  assembled formula `psc.coincidence_elimination` can minimise, which is why the
  elimination cross-check in the coincidence census samples 16 specimens rather
  than running everywhere.
- **`psc/dumont_thomas.mojo`'s `digits` and `levels_to_cover` recompute
  `image_lengths` from scratch at every step**, making a single digit expansion
  quadratic in the level where one precomputed table would make it linear.
  Small in absolute terms — `automatic-route-census` is 5.5s — so this is tidiness,
  not throughput.
- **`run_tests.sh` runs 36 test files serially** (283.9s local, 4m19 in CI).
  The loop is trivially parallelisable: give each file its own receipt file and
  concatenate at the end. Not on the critical path.

## Traps

1. **Census output is pinned selectively, not exhaustively.** `ci.yml` greps
   each census's output with `grep -Fx`, line by line, and for most drivers
   that covers every verdict — but not all of them, and the gaps are where an
   optimisation can do damage quietly. Two found while writing this:
   `swap_overlap_census.mojo` prints
   `zero-shift-free recurrent overlap cycles: specimens: … sccs: … largest-scc: …`
   and no job greps it; `census.mojo` prints `largest |B_sigma|: 1502` and the
   `mojo-kernel` step pins three of its five lines. So a change **can** move a
   reported number while CI stays green.

   Before optimising a driver, list which of its lines are pinned and pin the
   ones the change could move. A moved count that a pin catches is a finding to
   explain, never a number to quietly update. A moved count that no pin catches
   is the worse case, because nothing will tell you it moved.
2. **Caps hide outcomes.** See the addition census above. Raising a cap is a
   change to the evidence, not only to the runtime.
3. **Vendored code is digest-checked.** `substitution_dynamics` and
   `finite_exact` come from `larsbx/finite-math-kernels` and are verified by
   `tools/vendoring/check_vendored_sync.py`. Editing them here fails CI; the route is a
   PR to FMK, then re-copy and re-pin.
4. **Governance.** A new module needs an entry in
   `docs/catalogues/mathematical_objects.toml` (regenerate with
   `tools/make_math_catalogue.py`) and a test reaching a
   `require_claim`/`require_contract` declaration, or the coverage check fails.
5. **An optimisation must not change a verdict.** Every census here reports
   mathematical evidence. The pins are the mechanism that enforces it, and trap
   1 says how far that mechanism reaches: where a line is unpinned, the guard is
   the reviewer and the diff, not CI. Treat a green CI after an optimisation as
   a claim about the pinned lines only.

## Reproducing the attribution

Each probe is a short driver run from outside the tree, so nothing untracked
sits in the working directory:

```
pixi run mojo run -I . /path/to/probe.mojo
```

with the repository's `kernel/` as the working directory. A probe does a prefix of
a census's per-specimen work over the full corpus and prints one aggregate, so
that consecutive probes differ by exactly one layer. The layers used above, in
order: `pip_corpus()` alone; plus `build_seed_overlap_graph_from_tables`; plus
`nonproductive_overlap_states` and `first_left_aligned_depths`; plus
`ContractingBoundCache.slot`; and the census itself for the last difference.
For the swap-overlap census: the same first two, plus the four depth
statistics, plus `zero_shift_free_recurrent_sccs`, plus
`collapsing_seed_pair_count`, plus `separation_radius` — the census itself then
supplies the pump-lift survey as the last difference.

A probe must print an aggregate that depends on every value it computes, or the
work can be optimised away and the layer will measure as free. Each of the
probes above sums or counts its results for exactly that reason.
