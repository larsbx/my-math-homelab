# Barge–Olimb at source: adjudication and closure of queue item 2 (2026-06-13)

## Source read
- Barge–Olimb, "Asymptotic structure in substitution tiling spaces," ETDS (2013),
  arXiv:1101.4902 — abstract + reception, plus Sadun's survey "Cohomology of
  Hierarchical Tilings" (arXiv:1406.0882) read in full at source, which gives the
  precise 1D BBJS exact sequence and situates the Barge–Olimb branch locus.

## Verdict: queue item 2 is CLOSED — Barge–Olimb has no 1D content to apply.
Barge–Olimb is fundamentally a **d ≥ 2** paper. Its object — the *branch locus*,
a (d−1)-dimensional subspace of Ω summarizing "asymptotic in at least a
half-space" behavior — is introduced precisely because in dimension ≥ 2 there are
infinitely many directions of asymptoticity to track. In **d = 1** the asymptotic
structure is exactly the finite set of Barge–Diamond asymptotic composants, which
manifest as closed loops on Γ_BD generating the ℤ^ℓ (= ℤ^{b₁}) term of Ȟ¹(Ω) —
the content already captured by the BBJS exact sequence used throughout §sec:trans.
There is no Barge–Olimb 1D theorem extending the coincidence-rank machinery to the
b₁ > 0 (asymptotic-cycle) regime; the branch-locus cohomology is a higher-
dimensional homeomorphism invariant, not a 1D cr bound.

Consequence for the 888 unimodular b₁ > 0 specimens: the hoped-for "Barge–Olimb
asymptotic-cycle extension of cr ≥ 3" does NOT exist as a citable 1D result. The
cr status of that stratum rests on what is genuinely available:
- B15 Thm 22 (odd norm, cr = 2 ⟹ dim H¹ ≥ 2k−1) applies ONLY to homological
  Pisot σ (b₁ = 0); it is silent on b₁ > 0.
- The unconditional Leg-Factor cr ≥ 2 (lem:legfactor/cor:cr) still holds for ALL
  trapped components regardless of b₁(σ).
So on the b₁ > 0 stratum we have cr(Σ_C) ≥ 2 unconditionally and nothing sharper;
cr = 2 is NOT excluded there, and no 1D literature excludes it. This is the honest
ceiling. The b₁ > 0 stratum is where Corollary 25 of B15 ("a PSC counterexample
has an asymptotic cycle OR cr ≥ 3") bites with the *asymptotic-cycle* disjunct
rather than the cr ≥ 3 disjunct — consistent, no gap, but no extra leverage.

## Independent confirmation of the v8 exact sequence (Sadun survey, eq. 8–9)
Sadun states the 1D BBJS sequence in general form:
  0 → ℤ^{k−1} → lim(ℤ^N, A^T) → Ȟ¹(Ω) → ℤ^ℓ → 0,
with k = #components(S₀^ER), ℓ = b₁(S₀^ER), N = #tiles. This matches v8's
  dim Ȟ¹ = dim lim M^T − (C−1) + b₁
exactly (rearranged). The connectivity corollary lem:connect (irreducible Pisot ⟹
k = 1) is the case ℤ^{k−1} = 0. Confirmed.

## Convention-dependence flag (new, from Sadun's Fibonacci collared example)
Sadun shows the UNCOLLARED Fibonacci S₀^ER is contractible (k=1, ℓ=0), while a
COLLARED presentation gives k=2, ℓ=0 — same Ȟ¹(Ω) = ℤ² either way. Moral: C and
b₁ individually are invariants of (Ω, chosen Barge–Diamond complex), not of Ω
alone; only Ȟ¹(Ω) is the homeomorphism invariant. The v8 instrument fixes the
uncollared one-v-edge-per-legal-2-word convention throughout (gated 4/4 against
BBJS calibration: fib C=1 b₁=0, bbjs_ac C=1 b₁=1, trib C=1 b₁=0, φ₂ C=3 b₁=0), so
all censused b₁ values are convention-locked and mutually comparable. No claim in
§sec:trans depends on b₁ being a bare-Ω invariant: cor:rootofunity and
cor:QAresidue use C and b₁ of the FIXED complex G₀^ER(Σ_C), and dim Ȟ¹(Ω_{Σ_C})
(the genuine invariant) is what the counting identity is set against. Consistent.
A one-line caveat to this effect should be added near lem:connect.

## Updated queue
1. **Condition (1) residual (open, arithmetic):** are the remaining
   deg q − (C−1) nonzero roots of q forced to roots of unity? Sole cohomological-
   side gap of Q-A; no census purchase (premise = trapped object).
2. ~~Barge–Olimb~~ CLOSED (no 1D content).
3. **Q-B** triple geometry (1,740-specimen unconditional stratum) — now the next
   live structural item.
4. v13/v14 consolidation of the companion line.

## Ledger note
The earlier queue framing ("read Barge–Olimb at source for the asymptotic-cycle
extension of the cr machinery") presupposed a 1D extension that does not exist.
Not an overclaim in the manuscript (it was a queue item, never promoted), but
logged so the route is not re-attempted: the b₁ > 0 cr question has no 1D
literature handle; it would need either a new 1D argument or the higher-
dimensional branch-locus machinery, which is out of scope for 1D PSC.
