# P1 overlap productivity — seed-relative occurrence growth bridge

**Status:** repository-proved path–occurrence multiplicity lemma plus exact
finite calibration. This does **not** prove Open Problem 5.35 or exclude a
closed nonproductive component.

Primary target: issue #84. This is step 4 of the reviewed program in
`p1-overlap-affine-pump-literature-gate-2026-09-15.md`; no new theorem-facing
route is introduced here.

## 1. Contract

Let `G_ab` be the overlap graph reached from the actual overlaps in one period
of the top patch `(ab)^Z` and bottom patch `(ba)^Z`, over all unordered seed
pairs. Its adjacency is a **multiple-edge** adjacency: two child overlaps with
the same state but different pairs of prefix positions are two edges.
Coincidence vertices are terminal, so the counts below concern the residual
noncoincident occurrences.

Let `c_n(v)` be the number of residual overlap occurrences of type `v` in the
level-`n` patches, counted per inherited seed period. The level-zero vector
counts the actual seed occurrences, with multiplicity. Define

```
c_(n+1)(u) = sum_v c_n(v) * #{ occurrence edges v -> u }.
```

The explicit count cap in the executable is an exactness budget. Exceeding it
raises and gives no result.

## 2. Path–occurrence multiplicity lemma

**Lemma (repository-proved).** For every `n >= 0`, `c_n(v)` is exactly the
number of length-`n` occurrence-labelled paths from the level-zero seed
occurrences to `v`. Equivalently, it is the number of residual occurrences of
type `v` obtained by inflating the two periodic swap patches `n` times, per
inherited seed period.

**Proof.** At level zero this is the definition of the seed multiplicity
vector. Suppose it holds at level `n`. Each occurrence of type `v` subdivides
into the overlapping pairs of children indexed by their top and bottom prefix
positions. `ordered_child_occurrences` and the seed graph construction retain
each such pair as one adjacency entry, including repeated child types.
Conversely, every child occurrence has its parent occurrence and its two child
indices, so it contributes to exactly one occurrence edge. Summing over parent
occurrences gives the displayed update and proves the claim by induction. A
coincidence has no outgoing edge by the residual-graph contract, so it is not
silently counted at later levels. ∎

The argument does not require unique desubstitution. If an iterated seed patch
is a proper power, its different parsings may give the same bi-infinite
context, but occurrences per inherited seed period still have their parent
occurrence and prefix-position pair. Thus periodic collapse changes ancestry
uniqueness, not the forward multiplicity update.

## 3. Executable support

Canonical Mojo:

```
kernel/psc/overlap_growth_bridge.mojo
kernel/tests/test_overlap_growth_bridge.mojo
```

Independent Python oracle:

```
reference/psc_research/overlap_growth_bridge.py
tests/test_overlap_growth_bridge.py
```

On the determinant-two calibration, the exact total residual occurrence
counts at levels zero through three are `9, 21, 34, 67`. The Python test also
replays direct child inflation from the state occurrences without consulting
the stored adjacency and obtains the same statewise vectors.

## 4. What remains open

This closes the accounting part of the seed-relative growth bridge, not the
rigidity step. The next question is now precise: if `S` is the closed
irreducible nonproductive component from the issue #84 normal form, compare
the growth of paths that stay in `S` with the realized seed-period occurrence
counts, while retaining the ordered zipper/collar data. Generic Perron growth
cannot supply a contradiction: a residual real-overlap component may carry
the full expansion spectral radius. The missing input must force a boundary
hit or otherwise rule out full-growth, child-closed, nonproductive realized
occurrences. No legality-of-seed, unique-decoding, FI, unimodularity, or
finite-collar completeness hypothesis is introduced here.
