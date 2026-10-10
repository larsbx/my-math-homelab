# C4 arbitrarily long legal ancestry towers

**Status:** uniform legality-extraction theorem for deep zero-return ancestry. It does **not** prove C4, C1, G1, or PSC.

## 1. The legality problem left by a single deep cut

PR #31 proves that, even when a repository BPA state is not itself a legal language factor, sufficiently deep bounded-gap zero returns can be chosen with a fixed-radius context contained in one original-letter supertile on each side. That is enough to apply Mossé recognizability at the selected top cut.

For a pumping argument we need more: after desubstituting the selected cut several times, the resulting asynchronous source cuts must also carry legal contexts. The present theorem supplies exactly that strengthening.

## 2. Margin propagation under one desubstitution

Let

```text
L = max_a |sigma(a)|.
```

Consider a cut in `sigma(w)` with canonical source decomposition

```text
(source index i, within-image offset r).
```

If `i<m`, then the output cut lies before the end of the first `m` source-letter images, hence at distance less than `m L` from the left boundary. The analogous statement holds from the right.

Therefore, contrapositively, sufficiently large output margin forces source-index margin. We use the deliberately conservative recurrence

```text
m_0 = R,
m_(j+1) = (m_j+1) L.
```

If a top cut lies `m_q` symbols inside an original-letter level-`n` supertile, then its first `q` desubstituted source cuts remain at least radius `R` from the ends of the corresponding original-letter supertiles.

The executable helper is

```text
descent_margin(R,q,L).
```

The extra `+1` is only slack for the possible proper image-prefix offset; sharper letter-specific bounds are unnecessary for the theorem.

## 3. Legal ancestry tower theorem

Let `T=(u,v)` be a balanced pair and let `x` be a zero-return cut in `sigma^n(T)`.

> **Protected legal ancestry theorem.** Fix radius `R` and descent height `q<=n`. If `x` lies at least `m_q` symbols from every original-source-letter supertile boundary on both the top and bottom sides, then the top zero return and each of its first `q` desubstituted source cuts have radius-`R` contexts contained in one image of a single original source letter on each side.

For a primitive substitution, every such context is a legal language factor. Thus Mossé recognizability may be applied at every level of the protected tower.

`verify_legal_ancestry_tower` checks the conclusion directly against the exact multi-level ancestry from PR #30.

## 4. Existence in a finite strict component

Now let `C` be a finite strict child-closed component and

```text
B_C=max{|T|:T in C}.
```

PR #29 gives zero-return gaps at most `B_C` in every `sigma^n(T)`.

For a fixed base state `T=(u,v)`, the top and bottom decompositions into images of the **original** letters of `u` and `v` have only

```text
len(u)+len(v)+2
```

boundary positions counted with multiplicity. This number does not grow with `n`.

For a fixed protected margin `m_q`, the number of integer cut positions lying within that margin of one of these finitely many barriers is therefore bounded independently of depth.

By contrast, the total length of `sigma^n(T)` tends to infinity in the expanding substitution regime. The bounded-gap return theorem forces the number of zero returns to grow at least linearly with that length. Eventually there are more zero returns than bad positions, so at least one zero return lies outside every forbidden boundary neighborhood.

Hence:

> **Arbitrarily long legal ancestry towers.** For every fixed recognizability radius `R` and every finite descent height `q`, sufficiently deep iterates of a state in a finite strict component contain a zero return whose top context and first `q` desubstituted contexts are legal on both sides.

The helper `tower_count_forces_existence` is the finite pigeonhole inequality behind this statement.

## 5. Calibrations

For Tribonacci

```text
1 -> 12
2 -> 13
3 -> 1
```

with the legal swap seed `(12,21)`, `L=2`. For radius `R=1` and two protected descents,

```text
m_0=1,
m_1=4,
m_2=10.
```

At depth 5, the zero return at cut 10 has the required top margin. Its first two source cuts are at positions 5 and 2, and the regression verifies radius-1 legality on both sides at each level.

The primitive non-Pisot strict component

```text
1 -> 2
2 -> 123
3 -> 2
```

also has arbitrarily long legal towers. With `R=1`, two protected descents and `L=3`, the required top margin is 21; at depth 6 the zero return at 22 is a concrete witness.

This negative control matters: **legal towers plus strict closure still do not prove C4 without the Pisot/recognizability interaction.**

## 6. Why this materially strengthens the recognizability route

After PRs #30, #31, #32, and #33, a hypothetical strict PIP component already gives:

- finite Parikh-defect ancestry;
- bounded-gap zero returns;
- finite decorated cut germs;
- canonical derived-substitution addresses;
- recognizable derived cyclic-class hierarchy.

The present theorem removes the remaining local-language loophole along an arbitrarily long finite ancestry segment: the selected top zero return can be chosen so that every context needed for a finite pumping argument is genuinely legal for `sigma`.

Thus the next finite-state object can safely combine, for as many ancestry levels as needed,

```text
sigma-side:
  legal local context,
  ancestry defect,
  within-image offset;

derived-side:
  derived state context,
  cyclic phase,
  birth-event/address data.
```

## 7. Remaining target

The next proof obligation is no longer "obtain legal contexts". It is the actual hierarchy interaction:

> Can a finite recurrent ancestry/address state carry a nonzero top-vs-bottom hierarchy offset through arbitrarily long **legal** towers while every newborn birth event remains endpoint-nonsynchronizing?

If repetition of such a state pumps two incompatible `sigma`-hierarchy decompositions of the same legal local limit, Mossé recognizability gives the desired contradiction. If not, the counterexample must exhibit the additional datum missing from the current state and that datum should be added explicitly.
