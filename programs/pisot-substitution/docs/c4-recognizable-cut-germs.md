# C4 recognizable cut germs and legal-context extraction

**Status:** uniform structural reduction for a given finite strict component. This note does **not** prove C4, C1, G1, or PSC.

## 1. Why one more finite state is useful

PR #29 proves that a finite strict child-closed component has zero-return cuts at uniformly bounded output gaps through every substitution depth. PR #30 proves that, for a PIP substitution, every multi-level cut ancestry has its Parikh-defect coordinate in one finite set independent of depth.

The remaining data needed to discuss recognizability are local and finite already. Fix a context radius `R`. For one ancestry transition record

- the source Parikh defect `x`;
- the local correction digit `c` in `x' = Mx + c`;
- the two within-image offsets `(r,s)`;
- the radius-`R` word context around the top cut;
- the radius-`R` word context around the bottom cut.

Call this tuple a **decorated cut germ**.

For fixed `sigma`, fixed finite ancestry-defect alphabet `A`, and fixed `R`, there are only finitely many such germs. A coarse bound is

```text
|A| * |C_sigma| * L_max^2 * (|alphabet|+1)^(4R),
```

where `0` is used only as an exterior sentinel in finite-word contexts.

Thus arbitrarily deep zero-return ancestries contain repeated decorated germs. This is the exact finite-pigeon object on which a recognizability argument may act.

`reference/psc_research/cut_germ.py` constructs these germs and detects exact repeats.

## 2. Repetition is not itself a contradiction

Two negative controls are pinned.

### PIP but productive

For Tribonacci

```text
1 -> 12
2 -> 13
3 -> 1
```

and the legal seed `(12,21)`, the depth-6 zero return at output cut `51` has the same complete radius-1 germ at ancestry levels 1 and 4:

```text
source defect:      (1,-1,0)
correction:         (0,0,0)
offsets:            (0,0)
top context:        2 | 1
bottom context:     3 | 1
```

So

```text
PIP + repeated finite cut germ
```

is not enough. Strict nonproductivity/nonsynchronization must enter.

### Strict but non-Pisot

For the primitive non-Pisot strict component used elsewhere in the repository,

```text
1 -> 2
2 -> 123
3 -> 2,
```

the depth-7 zero return at cut `10` repeats a nonzero, doubly misaligned radius-1 germ at levels 5 and 7:

```text
source defect:      (1,0,0)
correction:         (0,-1,0)
offsets:            (1,2)
top context:        1 | 2
bottom context:     2 | 3.
```

Thus strict closure plus germ recurrence is also insufficient without the Pisot input.

These controls prevent the finite-pigeon statement from being promoted into a false alignment theorem.

## 3. A legality problem for recognizability

The repository BPA starts from every swap `(ab,ba)`. Such finite words need not themselves be legal factors of the substitution language. For example, Tribonacci has legal bigrams

```text
11, 12, 13, 21, 31,
```

but not `23` or `32`. Hence the repository seed `(23,32)` is an algebraically valid balanced seed but not a pair of legal language words.

Mossé recognizability is a statement about points of the substitution hull. It therefore cannot be invoked blindly on the complete finite context of an arbitrary all-seed BPA state.

This is a real hypothesis issue, not notation.

## 4. Legal-context extraction lemma

The legality problem disappears locally at sufficiently large depth.

Let `T=(u,v)` belong to a finite strict child-closed component and let

```text
B = max{|w| : (w,w') in C}.
```

PR #29 gives zero returns in `sigma^n(T)` with gaps at most `B`. Therefore if

```text
L_n = |sigma^n(u)|,
```

the number of zero-return positions is at least

```text
ceil(L_n/B)+1.
```

Now fix a radius `R`. View `sigma^n(u)` as the concatenation

```text
sigma^n(u_1) sigma^n(u_2) ... sigma^n(u_m),
```

and similarly on the bottom side. There are only `m+1` original source-letter boundaries on each side, independent of `n`. A cut whose radius-`R` context crosses one of these boundaries lies in a set of at most

```text
(len(u)+len(v)+2) * (2R+1)
```

integer positions. This is a safe overcount independent of `n`.

Because a primitive PIP substitution has `L_n -> infinity`, eventually the zero-return lower bound exceeds this fixed bad-position bound. Hence:

> **Legal-context extraction lemma.** For every fixed radius `R`, every state of a finite strict child-closed PIP component has, at all sufficiently large depths, an interior zero-return cut whose top radius-`R` context is contained entirely in one level-`n` letter supertile and whose bottom radius-`R` context is likewise contained entirely in one level-`n` letter supertile.

For a primitive substitution, every finite factor of `sigma^n(a)` is a legal language factor. Therefore both local contexts of the selected cut are genuine hull contexts even if the original BPA state word was not globally legal.

`reference/psc_research/legal_cut_context.py` implements the exact finite containment and the counting criterion.

### Calibration on an illegal seed

For Tribonacci, `(23,32)` is not a legal bigram pair, but at depth 3 the zero return at cut `2` has radius-2 contexts lying entirely inside one level-3 letter supertile on each side. Thus local legality can be recovered without pretending the parent seed itself is legal.

## 5. What Mossé recognizability can now say safely

Let `R_M` be a recognizability radius. Apply the legal-context extraction lemma with `R >= R_M`. At the selected deep zero return, each side is a legitimate local hull context, so its local word content determines whether that cut is a level-1 substitution boundary on that side.

This gives a clean interface:

```text
finite Pisot ancestry state
+ finite radius-R_M local context
+ source-boundary flag
```

is a legitimate finite recognizability state.

It does **not** yet couple the two sides strongly enough to force the flags to agree. In a strict nonsynchronizing boundary regime the adjacent top/bottom letters are typically distinct, so equality of the two local contexts cannot simply be assumed.

## 6. Relation to return-word machinery

Durand's return-word construction provides a useful model for what a completed argument would look like: return words to a prefix form a code, and the induced return substitution is uniquely characterized by an intertwining equation with the original primitive substitution. Our gauge-trivial strict SCC also produces intertwining word morphisms

```text
sigma U = U tau_C,
sigma V = V tau_C,
```

but the balanced-child words have **not** been proved to form a return-word code or a return-word partition. That missing hypothesis is substantive.

So the next step should not cite return-substitution uniqueness as if it already applied. Instead it should try to prove a comparable alignment/code property from the recurrent legal cut germs.

## 7. Next open statement

After PRs #29 and #30 and the two lemmas above, a hypothetical strict PIP counterexample supplies:

1. bounded-gap zero returns at arbitrary depth;
2. a finite Pisot ancestry-defect alphabet;
3. for any fixed recognizability radius, deep zero returns with legal contexts on both sides;
4. repeated decorated ancestry germs;
5. persistent endpoint nonsynchronization at every genuine balanced child boundary.

The next load-bearing implication is therefore narrower than the earlier informal recognizability proposal:

```text
recurrent legal decorated cut germ
+ strict nonproductivity
+ endpoint nonsynchronization
    => aligned inherited cut or synchronizing boundary.
```

This implication remains open.

The immediate research task is to determine which extra finite datum makes it true. Candidates are:

- the oriented child-state label and its position in the derived substitution word;
- endpoint synchronization-quotient phase;
- a return-word/code marker on one side;
- or a bounded pair of supertile-address digits from the unique hierarchy.

Any false version must be preserved as a counterexample before the state is enlarged.
