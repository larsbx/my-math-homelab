# Adversarial audit: `lem:redproj`, and discharge of queue item 1 (2026-06-13, cont.)

## Outcome

- **Queue item 1 (type-mixed alternating cycles / ×β fiber-monodromy lever) is DISCHARGED**, and *without* the lever. `thm:decomp` already makes G₀^ER(Σ_C) = G_I ⊔ G_J **vertex-disjoint**, so mixed cycles cannot exist; every cycle is type-pure. `lem:redproj` + `thm:inherit` then close type-pure cycles over loop-free bases. The monodromy lever was the contingency for mixed cycles, which the decomposition forbids. Item 1 retired.
- **`lem:redproj` is correct as written**; one adversarial pass found two candidate gaps, both dissolved, and surfaced a wrong intermediate argument of my own that the final proof does *not* use. The v8 proof of `lem:redproj` has been rewritten to route the conclusion through π₁ non-triviality rather than through the homology class of the projected loop.

## The two candidate gaps and their resolution

**F1 — length-zero projection.** Could a type-I simple cycle project to a single base vertex (all cells share one i-letter), collapsing to a point? No. By the unit-step lemma a type-I cut is where the i-tile ends: `δ₂ − δ₁ = −e_{i₁}`, the i-letter changes across every type-I edge. So `π_i` advances the i-coordinate by exactly one I-tile per edge; the projected walk has positive length. (Note the convention: type-I = i-grid cut = j-letter *unchanged*, i-letter changes; projecting a type-I cycle by the i-coordinate is therefore the coordinate that moves.)

**F2 — non-local backtracking.** Could the projection backtrack (traverse base edge {u,v} then later {v,u}), making it null-homotopic despite local non-backtracking? This was the genuine concern. Resolution: free-group reducedness is a **local, consecutive-pair** property. In the alternating chain v_{s₁t₁}, v_{s₂t₁}, v_{s₂t₂}, … every consecutive edge-pair shares an in- or out-vertex. Unit-step i-determinacy (a type-I predecessor/successor of a given cell is fixed by its i-letter) forces distinct chain neighbors to carry distinct i-letters, so there is **no consecutive backtrack**. A closed walk with no consecutive backtrack and positive length is reduced, hence a nontrivial element of π₁(G₀^ER(σ)); a graph with nontrivial π₁ is not a tree, so b₁ ≥ 1. Non-consecutive coincidences of projected vertices never affect free-group reduction and are irrelevant. F2 dissolved.

## A wrong intermediate argument (logged so it is not reused)

I first tried to prove F2-freeness via **orientation**: "G₀ is directed bipartite (out_i → in_j), the projected walk uses only forward edges, so no inverse letters appear, so its H₁ class is a nonzero nonnegative edge-combination." This is **WRONG**, caught by brute force: the pure v-edge bipartite graph out_i → in_j has **no directed cycles at all** (you cannot leave an `in` vertex forward). G₀^ER cycles are therefore **undirected** cycles that necessarily alternate orientation; "all forward, no inverses" is false, and the H₁-class-nonvanishing route fails. The correct conclusion routes through **π₁ non-triviality** (existence of any reduced nontrivial closed walk ⟹ not a tree ⟹ b₁ ≥ 1), independent of the projected loop's own H₁ class — which may indeed vanish.

## v8 edit

`lem:redproj` proof rewritten (lines ~944–965): explicit consecutive-pair reducedness, positive length from unit-step, conclusion via π₁(G₀^ER(σ)) ≠ 1 ⟹ b₁ ≥ 1, with a parenthetical noting the projected loop may be H₁-trivial and that this does not matter. Recompiled clean: 15 pp, 0 unresolved refs.

## Net state of Q-A

Condition (3) (loop-freeness of G₀^ER(Σ_C)) is now closed **unconditionally over loop-free bases** with an audited proof — 68.1% of the exhaustive k=3 corpus, 1,740 of 2,628 unimodular. The remaining Q-A obstruction is the **spectral condition (1)**: that all nonzero roots of q := χ_{N_C}/χ_A are roots of unity, equivalently the counting identity #nz-roots(q) = C(G₀^ER(Σ_C)) − 1 (`cor:QAresidue`). That is the next wall, and it is genuinely arithmetic/spectral, not graph-combinatorial — the ×β lever (β-expansion of the cut coordinate) is the live tool there, now applied to the spectrum of N_C rather than to cycle exclusion.

## Updated queue

1. **Spectral condition (1) of Q-A:** the counting identity #nz(q) = C − 1; are the extra eigenvalues of N_C (beyond spec A) forced onto the unit circle / roots of unity? ×β orbit-coding lever applies to the cut coordinate.
2. **Barge–Olimb at source** for the 888 unimodular b₁ > 0 specimens (cr = 2 not excluded there).
3. **Q-B** triple geometry (1,740-specimen unconditional stratum).
4. v13/v14 consolidation.
