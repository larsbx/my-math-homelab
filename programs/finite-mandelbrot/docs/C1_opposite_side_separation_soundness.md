# C1 Opposite-Side Separation Soundness

Status: proof skeleton for the top conjecture C1.

This note isolates the local composition lemma needed after `WakeMembershipSoundness` and the other side-assignment soundness lemmas.

## Lemma name

```text
OppositeSideSeparationSoundness
```

## Intended statement

Let `S` be an admissible separator code with accepted landing/theorem tags. Let `WA` and `WB` be accepted finite side-assignment witnesses for incidence objects `A` and `B`.

If:

1. `WA.separator_id == S.separator_id`;
2. `WB.separator_id == S.separator_id`;
3. `WA.side` and `WB.side` are `Left` and `Right` in either order;
4. both side assignments are sound with respect to the classical separator represented by `S`;
5. neither assignment is `OnSeparator`;

then:

```text
ClassicallySeparated(A, B, S)
```

and therefore:

```text
Separated_k(A, B)
```

for any catalogue prefix `k` containing `S` and both finite side witnesses.

## What the lemma does not say

It does not say that failure to find opposite sides in a finite prefix proves same fiber. It does not say the catalogue is complete. It does not say generic boundary fibers are singleton. It only composes two already-sound side facts for one already-admissible separator.

## Required local inputs

- `SeparatorAdmissibilitySoundness`: the separator code denotes a classical rational-ray/component separator.
- `SideAssignmentSoundness`: each accepted side witness denotes the matching classical side.
- `SideDisjointness`: the two open sides of one separator are disjoint.
- `BoundaryCaseDiscipline`: `OnSeparator` is structural equality or boundary incidence, not separation.

## Proof sketch

1. Interpret `S` by its theorem tag as a classical separation line.
2. Interpret `WA` as `A` lying on one classical side of `S`.
3. Interpret `WB` as `B` lying on the other classical side of `S`.
4. Use side disjointness for a separation line: the two open sides are in different components after removing the separator.
5. Conclude that `S` separates `A` and `B`.

## Finite certificate consequence

The finite predicate `separated_by_opposite_sides` may be accepted only when all of the following are finite-record checks:

```text
same_separator_id
opposite_open_sides
both_side_assignments_accepted
separator_admissible
no_on_separator_case
```

The classical conclusion remains a theorem-tagged reading until the proof is written in the paper.

## Next blocker

After this lemma, the next C1 blocker is:

```text
FinitePrefixToExistentialSeparation
```

namely, prove that if a finite prefix contains one accepted opposite-side witness pair, then the existential finite separation predicate holds.