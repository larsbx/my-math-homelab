# A finite witness that a catalogue never separates a pair

**Status:** derivation, dated 2026-09-20. Phase 4 asks for a finite witness
that the catalogue *permanently* fails to separate a named pair.
`docs/finite-separator.md` section 5 established that the question only has
content against a **declared** catalogue, because an unrestricted one
separates every distinguishable pair. This is the witness for a declared one,
and it is this repository's own: nothing below is imported.

## 1. The difficulty

`separated` searches steps `0` to `k`. Its failure is a statement about `k`:
the catalogue has not separated the pair *yet*. Turning that into "never"
means quantifying over infinitely many steps, and a search cannot.

The budget makes it worse, not better. Exact iteration squares the
coordinates, so a search asked for level thirty on these witnesses caps at
step fourteen: the levels a trapped orbit needs are ones no search will ever
reach.

What closes it is that a trapped orbit stops producing new information. Once
both boxes are inside a trap, every later step puts them inside the same box
of the trap's cycle, and a cut that decides that box decides them together,
forever. The infinite tail becomes one finite check on `p` boxes.

## 2. The theorem

**Let `C` be a finite catalogue of cuts and `T` a verified trap of period `p`
at `c` (`docs/three-valued-classifier.md` section 2). Suppose**

1. **each of `T, F(T), ..., F^(p-1)(T)` is on a decided side of every cut of
   `C` -- decided, not necessarily the same side;**
2. **there is a common step `m` with `F^m(A) ⊆ T` and `F^m(B) ⊆ T`;**
3. **no cut of `C` separates `A` from `B` at any step `n < m`.**

**Then `C` does not separate `A` from `B` at any level.**

*Proof.* For `n < m` this is hypothesis 3. For `n = m + j` with `j >= 0`,
inclusion monotonicity gives `F^n(A) = F^j(F^m(A)) ⊆ F^j(T)`, and iterating
`F^p(T) ⊆ T` gives `F^(j+p)(T) ⊆ F^j(T)`, hence `F^j(T) ⊆ F^(j mod p)(T)`.
The same holds for `B`, so both enclosures lie in the *one* box
`F^(j mod p)(T)`, which by hypothesis 1 is on a single decided side of each
cut. A linear form's enclosure over a sub-box is contained in its enclosure
over the box, so both are on that same side, and no cut puts them on opposite
sides. []

Every hypothesis is finite: one trap verification, `p` boxes against `|C|`
cuts, `m` steps of direct checking, and two inclusions.

Hypothesis 2 asks for a **common** entry step, and the proof needs it: the
argument works because both boxes are in the same image box at the same step.
Two boxes that enter the trap at different steps are not covered, and the
certificate refuses them rather than stretching.

## 3. What it says, and what it does not

It says **this catalogue cannot tell these two boxes apart**. That is a
statement about the catalogue.

It does not say the two boxes hold the same point; they do not, in the
witnesses below. It does not say they are in the same fiber, or the same
anything -- level-`k` non-separation is not transitive and has no classes
(`docs/finite-separator.md` section 6), and permanence does not repair that.
And it says nothing about any other catalogue.

**Corollary (inadequacy is always repairable).** If `A` and `B` are disjoint,
adding `coordinate_cut_between(A, B)` to `C` separates them at level `0`.

*Proof.* Section 5 of `docs/finite-separator.md`. []

So a permanent failure is never a fact about the parameter, and never a
finite obstruction in the sense Phase 4's original phrasing suggested: it is
the exact price of having fixed the catalogue in advance. Reading one of
these witnesses as evidence about local connectivity would be reading it as a
statement about `c`, which it is not.

## 4. The witnesses

`reference/parameter_corpus.py` declares two, and `kernel/separator.mojo` replays
them.

At `c = 0`, catalogue `{x = 1/2}`, trap `[-1/4, 1/4]^2` of period one: the
boxes around `5/8` and `11/16` are on the positive side at step `0`, the
negative side at step `1`, and inside the trap from step `3`. Both halves of
the theorem do work -- three steps checked directly, the rest by the trap.

At `c = -1`, catalogue `{x = -1/2}`, trap `[-1/8, 1/8]^2` of **period two**:
the trap's two images straddle the cut, one on each side. That is the case
hypothesis 1 is phrased for. The boxes around `~9/32` and `~-9/32` enter at
step four.

Neither pair holds the same point, and in both the enclosures are disjoint,
so by the corollary one extra cut would separate either pair at once. The
witnesses are exhibits of a catalogue's limit, and they are labelled as such.

## 5. What this does not claim

It does not claim any catalogue is inadequate for a purpose, because no
purpose is fixed here. It does not claim a pair is permanently unseparated by
the *classical* separator, and there is no bridge to that claim: the one that
was named for the job, `CutCatalogueRayEquivalence`, is **rejected** in
`docs/literature-gate-2026-09-20-cut-equivalence.md`, because a ray pair
cannot separate two interior points of `K_c` and a cut can. It does not discharge any block of
`docs/J1_proof_definition.md`, and it closes no regime of
`docs/J1_regime_ledger.md`.
