# C4 system-level Barge–Diamond good-edge bridge

**Status:** exact finite necessary-condition bridge from the endpoint-only hub phase to an actual strict derived system. It does **not** prove that a surviving candidate edge is eventually coincident, and it does **not** prove C4, C1, G1, or PSC.

## 1. Inputs already proved

For a strict alphabet-3 PIP component:

1. Barge–Diamond supplies at least one eventually-coincident unordered letter pair `G`.
2. Every strict right-boundary first pair avoids `G` and therefore lies in the complementary two-edge hub star.
3. PR #41 classifies the deterministic first-child selector for a fixed endpoint map `h=sigma_+` and fixed candidate `G`. If a strict first-pair orbit exists, all viable pairs have one common hub-residual phase `q_+(h,G)`.
4. PR #40 computes the actual hub residual of every child occurrence in the integer-indexed `DerivedSystem`.

The remaining bookkeeping question is whether one candidate `G` is compatible with **all actual states and actual first-child occurrences simultaneously**.

## 2. Candidate edge test

For each of the three unordered letter pairs `G`, `candidate_good_edge_phase` checks:

- the endpoint-only selector phase exists (`q_+` is 0 or 1);
- every normalized state first pair is viable under `h` while avoiding `G`;
- the first actual child occurrence exists;
- after choosing the hub complementary to `G`, the actual first-child hub residual from the derived factorization equals `q_+` for every state.

If any condition fails, `G` is rejected.

`candidate_good_edge_mask` packages the three results as a three-bit mask.

## 3. Necessary nonemptiness theorem

Suppose the supplied system really is a strict child-closed PIP component and `h` is its actual prefix endpoint map.

Let `G` be the Barge–Diamond eventually-coincident pair. Strictness implies that no state first pair can hit `G` or coalesce along its deterministic first-child orbit. Therefore every state passes the endpoint viability test for `G`.

The first actual child is exactly the first-child factor whose raw first letters are `(h(u_0),h(v_0))`. PR #40 identifies its orientation bit with the physical hub-side residual after the hub gauge. Hence the actual first-child residual agrees with the endpoint-only phase from PR #41.

Therefore the bit for the genuine Barge–Diamond pair survives:

> **Any strict alphabet-3 PIP component has `candidate_good_edge_mask != 0`.**

This is a one-way necessary condition. A surviving bit is only *compatible* with being the Barge–Diamond pair; the finite test does not prove eventual coincidence.

## 4. Forced hub

If the mask has exactly one bit, then the Barge–Diamond pair—and hence its complementary hub letter—is forced by the finite derived system.

`unique_candidate_hub` returns that hub. It returns `-1` for zero or multiple candidates so callers cannot mistake ambiguity for a theorem.

This is useful for the next C4 layer because a uniquely forced hub removes one external choice from the hub-side word/cocycle analysis.

## 5. Calibration

For the primitive non-Pisot strict calibration

```text
1 -> 2
2 -> 123
3 -> 2

A=(12,21), B=(23,32)
```

with zero-based prefix map

```text
h=[1,0,1],
```

only candidate edge `{0,2}` survives the finite compatibility test. Its selector phase is `1` and the complementary hub is `1`.

This does **not** assert that `{0,2}` is actually eventually coincident: the calibration is non-Pisot and Barge–Diamond is not being invoked. It merely pins the finite mechanics.

A second regression flips only the first raw-child orientation of `A`. Endpoint-only viability remains unchanged, but the actual first-child residual no longer matches the predicted phase, and the candidate mask drops to zero. This demonstrates that the bridge checks the actual derived factorization rather than merely re-running the endpoint classifier.

## 6. Remaining target

The prefix selector is now fully integrated with the actual strict derived system. The information still not controlled is the **ordered hub-residual word on interior children**.

The next load-bearing theorem must use balanced-factorization geometry, the finite hierarchy-offset state, or both, to constrain those interior residuals. It is not legitimate to extend the selector phase to all children by assumption.

The [October 6 ordered-word/offset diagnostic](c4-ordered-hub-offset-negative-2026-10-06.md)
mines all four retained real-secondary recurrent packet SCCs and both controls.
It preserves a PIP golden negative to hub-guarded physical-offset descent, with
actual ordered factors and repeating local hierarchy snapshots. Those PIP
supports have productive exits; the strict-component premise here is unchanged.
