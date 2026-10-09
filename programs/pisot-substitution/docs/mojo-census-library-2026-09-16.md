# The Mojo census library and the retirement of the Python drivers — 2026-09-16

**Scope.** An engineering change to how censuses, catalogues and taxonomies are
written. No mathematical claim changes: every census prints the same lines it
printed before, and every line CI pinned it still pins. Two exploratory
computations that existed only in Python are now canonical Mojo and reproduce
their published figures exactly.

## 1. Why

Ten census and catalogue drivers each carried their own copy of the corpus
enumeration (a 39-word `image_words`, a triple loop over `39^3` substitutions, a
re-screening with `is_pip`), their own `contains_index` linear scan for
component membership, their own histogram array with a hand-written range
check, and their own rendering of a histogram line. A taxonomy of the degree-3
catalogue existed only as a Python script that CI piped the Mojo output into.
Three further computations — the endpoint-map conjugacy classification, a
boundary-synchronization sweep, and the Sirvent–Solomyak overlap-type
exploration — had no Mojo implementation at all.

That is the opposite of the stated policy: the corpus, the taxonomy of the
objects in it, and the classification of their carriers are the subject matter
of this research programme, not incidental scaffolding.

## 2. What the library is

| Module | Provides |
| --- | --- |
| `kernel/psc/corpus.mojo` | `Specimen` (indices, images, incidence), the deterministic `image_words` order, `pip_corpus()`, the shared `STATE_CAP`, `arithmetic_regime` |
| `kernel/psc/histogram.mojo` | a bounded exact histogram; a key outside its capacity raises rather than truncating a statistic |
| `kernel/psc/carrier.mojo` | `profile_component` (the two edge facts: a coincidence child, a noncoincident exit), `is_sink`, `is_closed_nonproductive`, per-state `carrier_flags`, `state_sync`, `emit_countermodel` |
| `kernel/psc/symmetry.mojo` | permutations of any alphabet, relabelling and reversal of words, pairs and substitutions, canonical representatives, substitution keys |
| `kernel/psc/defect_degree.mojo` | streaming `N4` in `O(n)` and the first scattered-subword defect degree |
| `kernel/psc/degree2_sieve.mojo` | the mod-2 parity sieve and the Newton trace recurrences in `(T, U, D)` |
| `kernel/psc/degree3_taxonomy.mojo` | the degree-3 catalogue rows and their `DEGREE3_*` summary |
| `kernel/finite_linear_algebra/integer_matrix.mojo` | primitivity of a non-negative integer matrix on any alphabet (Wielandt's bound) |
| `kernel/psc/prng.mojo` | SplitMix64: a reproducible source for exploratory searches only |
| `kernel/psc/bounded_bpa.mojo` | `B_sigma` under a state-count *and* a state-length budget, reporting which was exhausted |
| `kernel/psc/oa_overlap_types.mojo` | level-zero overlap types of `(u, S^k u)`, the exact enumeration window, and inclusion reports against the seed patch |

`kernel/psc/overlap_seed_patch.mojo` gained `build_overlap_graph_from_seeds`, so
the seed-patch graph and the Sirvent–Solomyak graph are two seedings of one
exact inflation kernel; comparing their vertices is then meaningful rather than
a comparison of two implementations.

A driver is now a survey over `pip_corpus()` that folds per-specimen facts into
histograms and counters. `census.mojo` is 40 lines; `c4_census.mojo` lost its
49-entry hand-built count arrays and its private endpoint-pair indexing.

## 3. Ports

| Was | Is | Reproduces |
| --- | --- | --- |
| `tools/analyze_degree3_catalog.py` | `kernel/psc/degree3_taxonomy.mojo`, printed by `degree3_catalog.mojo` | all 22 `DEGREE3_*` lines CI pinned, including the four state classes and two substitution classes |
| `tools/classify_endpoint_cores.py` | `kernel/endpoint_core_catalog.mojo` | the seven three-letter classes, their sizes `3,6,6,1,3,6,2`, the two globally synchronizing classes, every recurrent core |
| `tools/sweep_boundary_sync.py` | `kernel/boundary_sync_sweep.mojo` | a seeded sweep; 500 trials, 312 primitive, 60 components, no productive component missed |
| `tools/oa_type_inclusion_explore.py` | `kernel/oa_type_inclusion_census.mojo` | the least-`k` table of `overlap-finiteness-and-coincidence-density-2026-09-13.md` exactly: `1:256 2:109 3:41 4:8 5:12 6:6 7:1 8:1`, 22 failures |
| `tools/oa_failures_probe.py` | `kernel/oa_failures_probe.mojo` | the addendum exactly: 9 of 22 resolved, union types 58–132 against 15–48, 43–85 outside, 0–15 unmet, all productive, and all nine least witnesses |

The five scripts are deleted. They were the only implementation of those
computations, so keeping them would leave two sources of truth for a taxonomy;
the Python modules under `reference/psc_research/` that carry pytest coverage remain
as independent oracles, which the policy sanctions.

`endpoint_type`, the fast A..G classifier the C4 census calls per specimen, is
no longer a parallel definition: `test_endpoint_core.mojo` checks on all 27
maps that it names exactly the class `classify_maps(3)` derives.

## 4. Exploratory hygiene

Randomised search now has a stated contract. `psc/prng.mojo` fixes the
generator so a sweep replays from its seed. `psc/bounded_bpa.mojo` stops on a
state-count *or* a state-length budget and reports which: most randomly drawn
substitutions are not Pisot, their balanced-pair graphs are infinite, and an
exhausted budget must read as inconclusive rather than as a verdict. In the
500-trial sweep 262 of 312 primitive specimens are inconclusive for exactly
that reason, and they contribute to no count.

## 5. Verification

- every census prints byte-identical summary lines, checked against the greps in all three workflow files;
- `overlap_contracting_census.mojo` was timed against the pre-refactor driver on an equal 300-specimen slice: identical output, 1m32.7s versus 1m32.9s;
- four new test files carrying 33 tests (`test_census_library.mojo`, `test_endpoint_core.mojo`, `test_boundary_sync.mojo`, `test_oa_overlap_types.mojo`), and the loop runs every test file in `kernel/tests/` with no list to maintain;
- `kernel/run_tests.sh` replaces the two hand-maintained 20-item chains in `pixi.toml` (audit 2026-09-15, finding F6) with one loop over `tests/test_*.mojo`, and reports every failure in one run;
- new CI jobs pin the endpoint classification, the sweep, and both overlap-type explorations.

## 6. What this does not do

It proves nothing new. Every number here is finite evidence over a stated
domain, and the two overlap-type drivers remain exploratory: their level-zero
types are read off a finite prefix of a fixed point, an uncertified factor set.
