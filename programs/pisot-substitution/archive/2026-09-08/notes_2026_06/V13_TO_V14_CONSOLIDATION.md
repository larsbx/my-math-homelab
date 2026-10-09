# PSC_PROOF v13 → v14 consolidation changelog (2026-06-13)

Surgical merge of the companion (Geometric_Mass_Balance / GMB_v8) cohomological results
into the canonical manuscript line. No change to the existing v13 mathematics; the
consolidation is additive and cross-referential.

## What was added

**New subsection §`sec:cohomology-companion` "The cohomological face of the obstruction:
an independent development"**, inserted after Remark `rem:v34-scope` (the spectral-band
discussion), before "The remaining open question". Contents:

1. **Identification of the trapped object across the two developments.** v13's closed
   nonproductive SCC (intertwining N_C P = P M_σ^⊤, `eq:intertwining`; |C| ≥ |A|, χ_{M_σ} |
   χ_{N_C}, PF = β; Lemmas `lem:mass-balance`, `lem:alg-structure`) is *the same object* as
   the companion's transversal substitution Σ_C on the Barge–Diamond side, with dilatation
   β and reducible char poly χ_{M_σ}·q. This is the keystone: the symbolic/balanced-pair
   obstruction (Conjecture `conj:producer`) and the cohomological/homological-Pisot program
   are two faces of one object.

2. **Lemma `lem:leg-factor` (Leg factor):** Ω_{Σ_C} factors onto Ω_σ. (Cell-merge local
   rule between grid boundaries; image is a closed invariant subset of the minimal Ω_σ.)

3. **Corollary `cor:cr-floor` (Unconditional cr floor):** cr(Σ_C) ≥ 2 always; cr(Σ_C) ≥ 3
   if σ unimodular and Σ_C homological Pisot (B15 = `Barge2016` odd-norm exclusion of
   cr = 2). Unconditional geometric counterpart to `lem:alg-structure`.

4. **Lemma `lem:triple-ceiling` (Triple mass-balance ceiling):** the cr ≥ 3 triple system
   obeys PF(N_C^(3)) = β iff closed, < β strictly otherwise — verbatim the dichotomy of
   `lem:mass-balance`, proved via the triple partition identity (common refinement of three
   grids). Computational surrogate (~1,750 triple SCCs, no closed triple) noted as
   elimination.

5. **Proposition `prop:qa-crc` (Second conditional route):** σ unimodular + (Q-A: Σ_C
   homological Pisot) + CRC ⟹ σ has PDS. A *second* conditional route to unimodular PSC,
   parallel to v13's Conjecture `conj:producer` route, proved through invariants of Σ_C
   rather than of σ.

6. **Remark `rem:two-faces`:** honest placement — both Q-A and CRC are open (CRC precisely
   in the cr ≥ 3 regime this route reaches); the route is a transfer into the
   homological-Pisot/CRC program, not a closure. Theorem `thm:v34` constrains the bottom of
   the spectral band [β|β₂|, β]; Q-A constrains the top (residual spectrum q forced onto
   roots of unity). No census evidence bears on either route (the common object occurs
   nowhere in the corpus).

**Architectural-contribution remark (`rem:architecture`)** extended with one bullet
recording the cohomological consolidation (leg-factor floor, triple ceiling, second
conditional route).

**Bibliography:** added `BD08` (Barge–Diamond, Cohomology in 1D substitution tiling
spaces, Proc. AMS 136 (2008)) and `Sa14` (Sadun, Cohomology of hierarchical tilings,
Progr. Math. 309 (2015)). Both now cited in §`sec:cohomology-companion`. (`BBJS` and
`Barge2016` = B15 were already present.)

## Status of the manuscript after consolidation

Unchanged in kind: v14 remains **conditional**. It now carries *two* conditional routes to
the same conclusion, both two conjectures deep on the hard cases:
- **Symbolic route** (existing): Conjecture `conj:producer` (SCC Producer Theorem) ⟹ PDS,
  all alphabets. Settled |A|=2 (HS), β-substitutions and self-similar families.
- **Cohomological route** (new, unimodular only): Q-A (Σ_C homological Pisot) + CRC ⟹
  unimodular PDS.
Neither closes the conjecture; the open core remains the positional/avoidance residue
governed by the no-coarse-quotient meta-theorem. The consolidation's value is that the
trapped object is now attacked from two disjoint directions, with the unconditional
leg-factor floor cr ≥ 2 and the triple ceiling as new structural facts on the board.

## Compile

PSC_PROOF_v14.tex → 19 pp, 0 unresolved references, 0 undefined citations. pdflatex ×2.

## Provenance / caveats (carried from companion)

- BD08 read one step removed (via BBJS's statement of the exact sequence and Sadun's
  survey, both read at source); flagged.
- C and b₁ are invariants of (Ω, chosen Barge–Diamond complex); the companion fixes the
  uncollared convention. Not load-bearing for any v14 statement (all use χ_{N_C}, |C|,
  and dim Ȟ¹, the genuine invariants).
- Census is elimination throughout; no closed nonproductive SCC / no trapped triple in the
  corpus, by construction (a specimen with one would refute PSC).

## Deliverables

`PSC_PROOF_v14.tex`, `PSC_PROOF_v14.pdf`, this changelog. Companion line
(Geometric_Mass_Balance_Two_Anchor_v8) remains the detailed source for the leg-factor,
transition-complex, and triple-ceiling proofs.
