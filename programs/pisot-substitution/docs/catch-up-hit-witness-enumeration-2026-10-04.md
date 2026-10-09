# Exact catch-up hit witnesses and replay — 2026-10-04

**Result:** the universal one-tile reduction Q1 fails on the standing finite
domain. This was already established by #199–#202, which merged after #198.
This follow-up adds occurrence-level certificates, stable specimen/vertex
labels and committed results, rather than repeating that discovery. It
depends on the [stop/go check](catch-up-hit-witness-gate-2026-10-04.md).

## Complete decision, then witness selection

`kernel/psc/hit_witness.mojo` uses the complete Proposition V box graph built by
`psc.vertex_coincidence`. Each child **occurrence** retains its top and bottom
indices, even when several occurrences have the same child type. The shift
convention is the canonical bottom-start minus top-start convention:

```text
t_child = beta t_parent + prefix_bottom(j) - prefix_top(i).
```

For a left endpoint, a hit has `t_child = 0`. Child index 0 inherits its
parent's left boundary. If both indices are 0, the common vertex is inherited
and is not a new hit. If exactly one is 0, it is catch-up. If neither is 0,
it is a new simultaneous birth. For a right endpoint, use
`t_child = ell_top - ell_bottom` and last-child indices instead.

Every parent with a catch-up edge is a target of reverse BFS; target **edges**
have distance 1. All edges are traversed, including paths through previously
aligned different-letter vertices. A negative distance therefore means no
catch-up at any depth, rather than none on a chosen first path or none before
a cutoff. The same pass finds the least depth of a new boundary hit. Prefix
corrections are precomputed per substitution, and the four searches share
one reverse graph. The decision pass costs `O(E + V L^2)` time and `O(V + E)`
space, with `L` the maximum image length; it builds one box graph, whereas
the older two-sided check also builds a mirror graph.

The canonical graph absorbs equal-letter coincidences. Their subdivisions
agree at every later level, so they cannot introduce a catch-up. They can
introduce more simultaneous boundaries; those redundant hits are not
enumerated after absorption. The existence of a new hit and the birth paths
reported for the nonzero recurrent vertices below are determined before
that pruning loses any needed target. Recurrent offset-zero vertices already
satisfy the vertex-sharing target at the source level; reporting uses the
existing Q1 convention of recurrent **nonzero-offset** vertices. The searches
themselves process all nonabsorbing states, including offset-zero ones.

Only after this all-path decision does `witness_path` choose one shortest
occurrence path for export. Birth levels are replayed from the addresses:
for a left boundary, the last nonzero index is the level where it was born;
for a right boundary, use the last index that was not last-child. A reported
birth 0 means the boundary was already present at the source level, and may
have been born earlier. New hits have at least one positive birth, so this
convention does not change the equality/inequality test.

For a simultaneous-only source, `simultaneous_closure` reconstructs its full
forward closure, checks every child occurrence against the graph (including
multiplicity), and refuses any catch-up edge at either endpoint. A missing
edge is an error: it could conceal a later witness. A capped graph yields
no vertex verdict and is counted separately by the driver. Arithmetic
refusals terminate the run rather than supplying a negative verdict.

## Recorded finite domains

Base main: `3344a6b7d449ad17a2630307acffde55b64de31f`. Toolchain:
Mojo `1.1.0.dev2026090805 (34562fa1)`, pinned by `kernel/pixi.lock`.
State cap: 4,000,000 per graph. Deterministic four-worker fold.

| Domain | Evaluated | Recurrent nonzero vertices | Catch-up at either endpoint | Simultaneous-only | Failing specimens | Total-failure specimens | Caps |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Standing, images of length ≤ 3 | 4,554 / 4,554 | 1,154,040 | 1,056,816 | 97,224 | 360 | 210 | 0 |
| Total image length ≤ 8, canonical indices `[0,1000)` | 1,000 / 24,486 | 352,664 | 331,274 | 21,390 | 64 | 29 | 0 |
| Images of length ≤ 4, canonical indices `[0,1000)` | 1,000 / 135,990 | 291,686 | 259,918 | 31,768 | 47 | 29 | 0 |

Left, right and either catch-up counts agree in each row. Every reported
vertex has a new hit, including the simultaneous-only vertices. Maximum
endpoint-specific catch-up depths are respectively 17, 21 and 24. These
measure catch-up witnesses, not the PPVC first-hit quantity `K_V`.

Elapsed times in the local concurrent run were 6m43s, 3m33s and 3m46s. These
are execution records, not isolated performance benchmarks. The wider rows
are **prefix slices**, not full censuses and not statistically representative
samples. They overlap each other and the standing domain; do not add their
counts as distinct specimens. No claim is made about their unvisited members.

The [evidence directory](../evidence/catch-up-hits-2026-10-04/) contains summaries,
a manifest with compressed and uncompressed SHA-256 digests, and every failed
specimen/vertex label in deterministic gzip JSONL. `schema: 1` records use
`i,j,k` from `corpus.image_words_up_to(MAX_LEN)` and
`vertex: [top,bottom,c0,c1,c2]` for `t=c0+c1 beta+c2 beta^2` in the canonical
Perron-length normalization. They never depend on graph IDs. Positive-depth
fields give least witness depth; `-1` means no such witness at any depth on
the complete graph. `new_left/new_right` exclude inherited endpoints.

```bash
cd mojo
mkdir -p build
pixi run hit-witness-census standing 0 4554 failures > build/hit-standing.txt
pixi run hit-witness-census total8 0 1000 failures > build/hit-total8.txt
pixi run hit-witness-census len4 0 1000 failures > build/hit-len4.txt
python ../tools/check_hit_witness_evidence.py --live-output build/hit-standing.txt
```

`records` in place of `failures` emits **every** recurrent nonzero vertex,
including successful ones. The standing CI job now reruns the direct decision
and compares all 97,224 failure records with the committed export; the wider
prefix slices remain recorded runs. The provenance checker validates export
integrity; the Mojo run supplies the mathematical computation.

## Counterexamples and counter-calibrations

The exact replay commands below rebuild the graph, check recurrence of the
named source, emit the actual child indices and replay birth levels. Negative
replay also emits every edge of the checked closed set. Committed transcripts
are under the evidence directory.

| Specimen | Source vertex | What is pinned |
| --- | --- | --- |
| `1/12/022` (label `1 8 20`) | `[2,1,0,-2,1]` | No catch-up at either endpoint; simultaneous hit at depth 1; closure contains exactly this fixed vertex and the absorbing `[2,2,0,0,0]`. This specimen is not catch-up-free globally. |
| `1/012/010` (label `1 17 15`) | `[2,1,2,-6,2]` | No catch-up at either endpoint; simultaneous hits at depth 11; checked closure has 736 vertices. All 694 recurrent nonzero vertices of the specimen fail Q1, while PPVC holds with `K_V=14` in the existing regression. |
| `1/2/022` (label `1 2 20`) | `[2,2,-1,0,0]` | A selected first left hit has births `(2,2)`, but another shortest path has births `(2,1)`. Both occur at depth 2. |
| `1/2/012` (label `1 2 17`) | `[1,2,-1,0,0]` | First new hits at both endpoints have births `(2,2)`; catch-up first appears at depth 3, with births `(0,3)`. An earlier opposite-endpoint hit cannot rescue a depth-2 cutoff. |

```bash
pixi run hit-witness-census replay 3 1 8 20 2 1 0 -2 1
pixi run hit-witness-census replay 3 1 17 15 2 1 2 -6 2
pixi run hit-witness-census replay 3 1 2 20 2 2 -1 0 0
pixi run hit-witness-census replay 3 1 2 17 1 2 -1 0 0
```

`tests/test_hit_witness.mojo` compares the direct left result with CU and the
direct right result with the per-vertex mirror check on five specimens. An
independent finite-word oracle computes boundary sets at levels 0 through 4,
rescales them to one level, and intersects them by exact coordinates with
their earliest birth levels. It uses no overlap graph or child hit predicate.
The regression also checks occurrence replay, both simultaneous-only fixed
vertices of `1/12/022`, the alternative/later controls, inherited boundaries,
the absorbing-coincidence justification, corrupt paths, omitted edges and caps.

## What the result reduces

Validation: all 55 Mojo test files passed, as did the ten checks in
`verify.mojo`, all six claim-governance checks and receipt-based coverage.
The full `verify_all.sh` wrapper passed its ten executed checks, including
the 404-test Python suite; it reported three skipped toolchain layers. The
Mojo layer was run separately with the exact compiler and MAX packages from
`pixi.lock` (verified package SHA-256s), because provisioning the full Pixi
environment failed on a conda-forge dependency download. The TLA+ JAR and
Lean's `lake` were unavailable; those formal sources were not changed.

The branch was then integrated with `main@64a3665` (#204's additive
Proposition C work). Graph construction and reachability were unchanged.
The updated `test_one_tile` and `test_hit_witness` both passed again, and
their successful-run receipts were refreshed before rechecking governance.
An additional final-source standing slice `[0,300)` reproduced all 3,076
committed negative labels in that slice exactly. Export integrity checks
matched all three recorded runs and refused a truncated live export and
an unchecked Python `-O` execution.

For a particular vertex with a catch-up witness, the endpoint-boundary event
can be viewed as the one-tile eventual-subdivision-boundary problem. The
finite decision and replay make that conditional reduction inspectable.

There is no such witness for every recurrent vertex: simultaneous-only
counterexamples persist even after all paths, all depths and both endpoints
are considered. The general cross-letter rigidity problem therefore does
not reduce entirely to the one-tile problem through Q1. This rejects that
sufficient reduction, not other possible approaches to PPVC.

The arithmetic obstruction and short-periodic observations of §5.6b remain
their existing results; these runs do not promote the proposed trichotomy or
prove its missing implication. No proof obligation for #139, UH, G1, general
PPVC or PSC is discharged, and all stay open. The ledger, manuscript and
formal proof sources are unchanged.
