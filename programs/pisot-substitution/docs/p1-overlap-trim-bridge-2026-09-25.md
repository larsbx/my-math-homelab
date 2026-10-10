# Bridge from recurrent trim growth to seedwise overlap productivity — 2026-09-25

**Status:** research bridge note for issues #84 and #139. No theorem is promoted by this note.

## 1. Live target

The shortest current route to PDS uses the finite seed-patch overlap graph and has one open premise:

> one swap seed has only productive reachable overlaps (#84 / Open Problem 5.35).

A bad case has a finite child-closed irreducible nonproductive overlap SCC and splits into:

- an aligned branch (#138), or
- a strict-zipper branch (#139).

This route deliberately does **not** assume finite BPA / G1.

## 2. New input from the parallel Level-3 program

The parallel balanced-pair program has isolated the candidate Lyapunov quantity

[
L(T)=g(T)
]

for an irreducible balanced-pair defect block, with

[
L(T')=\beta L(T)-\tau(T\to T').
]

If the recurrent trim inequality

[
\tau<(\beta-1)L
]

holds on recurrent nc edges, then (L(T')>L(T)), excluding cycles in a finite recurrent balanced-pair carrier.

This is not yet a #84 theorem because a reachable balanced-pair state is an **ordered chain of overlaps**, and the seed-patch overlap graph can be finite while such chains have unbounded length.

## 3. Existing overlap mass law

The live overlap route already has geometric mass balance.

For an overlap (O), let (lambda(O)) be the intersection length. Its geometric children partition the inflated intersection, so

[
\sum_{O'\text{ child of }O}\lambda(O')=\beta\lambda(O).
]

Thus a closed nonproductive overlap SCC can carry the full Perron mass by splitting it among several children. Mass balance alone gives no contradiction.

The balanced-pair trim theorem is stronger because it tracks one **ordered irreducible defect block after cutting**, rather than total mass over all overlap children.

## 4. Exact bridge question

The high-value theorem is:

> **Ordered defect-chain bridge.**  
> Does every closed nonproductive seed-patch overlap SCC support a recurrent or uniformly bounded ordered irreducible defect chain to which the recurrent trim inequality applies?

Equivalently, can a bad overlap SCC support unbounded irreducible chain length while every recurrent irreducible block has strict geometric growth?

There are two possible outcomes.

### Outcome A — bounded/recurrent defect chain

Prove that a bad closed SCC forces a periodic or uniformly bounded ordered defect chain. Then the trim Lyapunov theorem can contradict recurrence and may attack #84 directly.

### Outcome B — genuine unbounded-chain countermodel

Construct a realized bad-style overlap cycle whose ordered irreducible defect-chain length grows without recurrence despite the local trim inequality. Then the trim route belongs strictly to the finite-BPA program and should not be used to claim progress on #84.

Both outcomes clarify the proof architecture.

## 5. Interaction with #138

The aligned branch exposes a non-eventually-coincident letter pair. Strict growth of balanced defect blocks does not by itself eliminate this branch: without a bounded-chain theorem, the blocks may grow indefinitely without state recurrence.

Therefore no claim is made that recurrent trim growth closes #138.

## 6. Interaction with #139

The strict-zipper branch is the more promising interface.

A strict-zipper SCC already carries:

- a finite periodic overlap cycle;
- ordered top/bottom child occurrences;
- a purely periodic affine offset address;
- no offset-zero boundary hit.

The proposed bridge should retain enough ordered occurrence information to assemble these overlap cells into an irreducible defect chain. If periodic overlap return forces bounded combinatorial defect-chain return, strict trim growth would contradict the cycle.

However the repository's affine-pump and collar countermodels are mandatory negative controls: equality of an affine overlap state, even with bounded context, does not automatically imply equality of the whole ordered defect block.

## 7. Proposed finite diagnostics

Before attempting a theorem, add a canonical Mojo diagnostic that, for a realized overlap-cycle occurrence, records:

1. the ordered overlap cells across one inherited seed period;
2. the zero-return / irreducible balanced-block decomposition induced by that ordered chain;
3. the geometric block masses (L);
4. the trim values (\tau);
5. whether return of the overlap cycle returns the same defect-chain type, a longer chain, or a collapsed/coincident chain.

Run it first on:

- the known six-edge zero-shift-free affine pump;
- the bounded-collar collision examples from #139;
- the four Level-3 specimen substitutions used by the trim study.

A counterexample must be retained as a replayable fixture.

## 8. Acceptance boundary

This bridge may be promoted into the #84 route only if it proves, without G1:

[
\text{closed nonproductive overlap SCC}
Longrightarrow
\text{bounded/recurrent ordered defect chain}
]

or derives a direct chain-level Lyapunov contradiction.

No fixed-depth census, collar bound, finite specimen sweep, or unimodular-only argument is sufficient.

## 9. Recommended issue linkage

- #84: parent completion gate; this bridge is a possible direct strengthening.
- #139: primary stress-test branch because it already retains ordered zipper data.
- #138: currently unaffected unless a separate bounded-chain consequence is proved for aligned bad pairs.
