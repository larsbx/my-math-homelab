# Lookups that replace recomputation in the Mojo census layer — 2026-09-17

**Scope.** An engineering change. No mathematical claim changes and no verdict
changes: every cache here is a memo over an exact decision procedure, asked
once per distinct question instead of once per asking. Every census prints the
lines it printed before, and the CI greps that pinned them still pin them.

## 1. Method

The question asked was "which computations could be avoided by a lookup
table", and it was answered by measurement rather than by reading the code for
things that look repetitive. For each candidate: how long does one evaluation
take, how many times does the census evaluate it, and how many *distinct*
inputs does it see. A cache pays only when the third number is much smaller
than the second and the first is not already negligible.

Most candidates failed that test and were left alone:

| Candidate | Why not |
| --- | --- |
| `endpoint_type` over the 27 three-letter maps | the whole classification is 1 ms; a table saves nothing measurable |
| `sync_after` in the carrier profile | 1 ms of the 147 ms census |
| `permutations3` | 0.39 µs per call |
| `classify_maps` | called once per driver run |
| the Möbius count identity, the Misiurewicz catalogue enumeration | already the cheap half; the enumeration they check is the cost |

Three passed, and all three are in the exact-arithmetic layer, where a single
evaluation isolates real roots or runs Sturm sequences over unbounded
rationals.

## 2. The three caches

### `CubicScreen` (`psc/pisot.mojo`)

`is_pip(m)` is primitivity, irreducibility of the characteristic cubic, and
the Pisot property of its Perron root. The first is a property of the matrix;
the last two are functions of the characteristic polynomial *alone*, and they
are the expensive pair. Screening the corpus evaluates them on 33,318
primitive candidates carrying only 177 distinct cubics.

`CubicScreen` keeps primitivity per matrix and memoizes the cubic verdict.
`pip_corpus()` builds the same 4,554 specimens in the same order.

### `PerronCache` (`psc/overlap_seed_patch.mojo`)

`build_seed_overlap_tables` reads the Perron field and the left-Perron tile
lengths off the incidence matrix — about 628 µs of a 632 µs build — and the
prefix positions off the images *in order*. The corpus's 4,554 specimens carry
348 distinct incidence matrices.

So the cache is keyed on the incidence matrix and holds only the field and the
lengths. The prefix positions are still computed per substitution, because
they must be: `0->1, 1->2, 2->01` and `0->1, 1->2, 2->10` share an incidence
matrix and do not share positions. Caching whole tables by the matrix would be
wrong for exactly that pair, which is the pair the regression uses.

### `ContractingBoundCache` (`psc/overlap_contracting.mojo`)

A `ContractingBound` is built from the cubic field *and* from `digit_set`, the
single-inflation offset increments whose extremal element fixes `c*`. The
digit set is read off the images and the prefix positions, so the key is the
pair (cubic, digit set) — 1,617 distinct pairs over 4,554 specimens.

The cubic alone is not a key. An earlier reading of this code claimed it was,
on a grep that missed `digit_set(tables)` taking `tables` bare; keying on the
cubic returned a bound built for a different increment set, and a probe over
the corpus found 6,576 disagreements against freshly built bounds. With the
digit set in the key there are none. `least_level` is memoized beside the
bound it came from, so a shift met again under the same key is not recomputed
even when it is first met under a different substitution — and the key is
never the shift alone, since a coefficient triple denotes different numbers
over different fields.

## 3. Measured

| | Before | After |
| --- | --- | --- |
| `pip_corpus()` | 3,290 ms | 99 ms |
| seed-overlap tables, 4,554 specimens | 2,883 ms | 217 ms |
| `overlap-contracting-census` end to end | 20m30s | 6m28s |

The census gains more than the 23% the bound-sharing alone accounts for,
because specimens sharing a slot also share its computed levels.

## 4. Verification

- `pip_corpus()` agrees with the unmemoized screen on all 59,319 candidates: 0 disagreements;
- cached tables agree with freshly built tables on all 4,554 specimens: 0 mismatches;
- cached bounds and levels agree with freshly built bounds on every reachable shift of every specimen: 0 mismatches;
- `overlap-contracting-census` reproduces its output line for line, and all ten CI greps pass;
- seven regressions carry the contracts: `test_census_library.mojo` (the memoized screen against `is_pip` on a stride through the candidate space, and the pinned corpus), `test_overlap_seed_patch.mojo` (a cached build is the build; validation is not skipped on a second sighting), `test_overlap_contracting.mojo` (cached levels equal fresh levels on every reachable shift; a shared cubic with different digit sets does not share a bound; a capped graph is still refused, before the memo rather than after it).

## 5. What this does not do

It proves nothing new, and it removes no exact step. A memo is sound here only
because each cached answer is a function of its key: cubic verdicts of the
cubic, fields and lengths of the incidence matrix, bounds of the cubic and the
digit set. Where that is false — prefix positions of a substitution rather
than its matrix — nothing is shared, and the tests pin the difference.
