# C3 locality reduction: higher newborn cuts are one-step block-local

**Status:** proved combinatorial reduction; does **not** prove C3, C1, G1, or PSC.

This note isolates a structural fact behind the Newborn Synchronizing Boundary
program. It removes the apparent need to follow exponentially growing whole
pairs through many inflations.

## 1. Zero-return cuts and inherited cuts

Let `P = (u,v)` be a balanced pair. Write

`0 = b_0 < b_1 < ... < b_r = |u| = |v|`

for all zero-return cuts, i.e. positions where the two prefix Parikh vectors
agree. The consecutive blocks

`T_j = (u[b_j:b_{j+1}], v[b_j:b_{j+1}])`

are the irreducible balanced blocks of `P`.

For a substitution `sigma`, let

`L_u(k) = |sigma(u[:k])|`, `L_v(k) = |sigma(v[:k])|`.

If `b_j` is a zero-return cut, the two prefixes have equal Parikh vectors, so
`L_u(b_j) = L_v(b_j)`. Denote this common value by `B_j`. The positions `B_j`
in `sigma(P)` are the **inherited** zero-return cuts. Every other zero-return
cut of `sigma(P)` is **newborn**.

## 2. Locality lemma

### Lemma (newborn-cut localization)

Let `k` be a newborn zero-return cut of `sigma(P)`. Then there is a unique
irreducible block `T_j` of `P` and an interior zero-return cut `r` of
`sigma(T_j)` such that

`k = B_j + r`, with `0 < r < |sigma(T_j.u)|`.

Moreover, the left and right adjacent letter pairs at `k` in `sigma(P)` are
exactly the adjacent letter pairs at `r` in `sigma(T_j)`. Therefore endpoint-map
synchronization at the cut is preserved by this localization.

### Proof

The inherited positions `B_0 < ... < B_r` partition `sigma(P)` into the
inflated blocks `sigma(T_j)`. Because `k` is not inherited, it lies strictly
between a unique consecutive pair `B_j < k < B_{j+1}`. Put `r = k-B_j`.

The Parikh-prefix difference of `sigma(P)` is zero at `B_j`, because `B_j` is
inherited, and zero at `k`, because `k` is a zero-return cut. Subtracting these
two prefix equalities shows that the two prefixes of `sigma(T_j)` of length
`r` have equal Parikh vectors. Hence `r` is a zero-return cut of
`sigma(T_j)`. It is interior because `k` lies strictly between `B_j` and
`B_{j+1}`.

Since the two words of `sigma(T_j)` occur literally as the corresponding
intervals of the two words of `sigma(P)`, the letters immediately to the left
and right of the cut are unchanged by translating the coordinate by `B_j`.
Thus membership of the adjacent pair in `Sync_+` or `Sync_-` is unchanged.
QED.

## 3. Iterated corollary

### Corollary (higher escape becomes one-step escape)

If a newborn synchronizing cut occurs in `sigma^n(S)` for `n >= 1`, then some
irreducible balanced block `T` in the decomposition of `sigma^{n-1}(S)` has a
**one-step** newborn synchronizing cut in `sigma(T)`.

So searching arbitrary inflation horizons is unnecessary once all irreducible
blocks that can occur are represented as BPA states.

## 4. Counterexample-SCC corollary

Suppose `C` is a closed recurrent noncoincident SCC of the balanced-pair
automaton and suppose it is nonproductive. Starting from a state of `C`, every
irreducible block produced under inflation remains noncoincident and remains in
`C`: a coincidence block would be productivity, and a noncoincident block
outside `C` would violate closure.

Therefore:

> If any higher inflation from `C` creates a newborn synchronizing boundary,
> then some state `T in C` already creates a newborn synchronizing boundary in
> **one inflation**.

Equivalently, to rule out a closed nonproductive nonsynchronizing trap it is
enough to prove the following local existence statement:

### C3-local

For every closed nonproductive recurrent noncoincident SCC `C` arising from a
primitive irreducible Pisot substitution, there exists `T in C` such that
`sigma(T)` contains an interior zero-return cut whose right adjacent pair is in
`Sync_+` or whose left adjacent pair is in `Sync_-`.

For an irreducible state `T`, its only inherited cuts are the two endpoints, so
an interior cut of `sigma(T)` is automatically newborn.

## 5. What this does and does not solve

The reduction removes the **horizon problem** from C3. The remaining difficulty
is an **existence problem**: why must at least one state in a hypothetical PIP
counterexample SCC create such an interior synchronizing cut?

It does not derive that existence from primitivity or the Pisot property. That
is the load-bearing open step, now sharpened into a finite local form. A useful
next route is C4: assume every one-step interior zero-return cut remains in the
finite nonsynchronizing endpoint cores, use recurrence/pigeonhole on the SCC,
and seek a contradiction with primitivity/Pisot contraction.

## 6. Executable correspondence

The reference implementations use exactly these definitions:

- Python: `inherited_boundary_positions`, `newborn_boundary_positions`,
  `newborn_boundary_sync_hits`.
- Mojo: `inherited_boundary_positions`, `newborn_boundary_positions`,
  `newborn_sync_positions`.
- `kernel/c3_census.mojo` scans the one-step local property over every state of
  every recurrent noncoincident SCC in the exact 4554-substitution PIP corpus.

The Smith-type regression state is a calibration example: its inherited cuts
stay nonsynchronizing at the tested step while interior newborn cuts synchronize.
This is a witness to the mechanism, not a proof of the universal statement.
