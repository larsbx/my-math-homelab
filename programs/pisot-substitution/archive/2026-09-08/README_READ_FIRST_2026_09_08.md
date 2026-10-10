# READ FIRST — PSC program state (2026-09-08 remediation)

**This file supersedes `SESSION_2026_06_10_SUMMARY.md` as the read-first document.**
That summary predates the June 13–15 work and the six-round external review; reading it alone
reconstructs a v13-era state that asserts a broken theorem as proved. Read this, then
`SESSION_2026_06_13_LEDGER.md`, then `PROJECT_AUDIT_2026_09_08.md`.

## Canonical manuscripts
| Document | Status |
|---|---|
| **PSC_PROOF_v15.tex/.pdf** (20 pp) | **CANONICAL.** Six external review rounds; scope-clean. Architecture: B_σ finite (G1) + SCC Producer ⟹ PDS. |
| Geometric_Mass_Balance_Two_Anchor_**v9** (15 pp) | Companion (cohomological / transversal-substitution line). v9 = v8 + one bridge-converse cross-reference. |
| PSC_PROOF_v14 | SUPERSEDED **with known error**: states finiteness (thm:finiteness) as a proved theorem via the withdrawn predecessor contraction. Do not cite. |
| PSC_PROOF_v13 and earlier | SUPERSEDED with the same error. Do not cite. |
| "PSC_PROOF_v16 (29 pp)" | **Does not exist.** A memory entry referred to it; no file has ever been found. Treat as unreliable. |

## What is proved (v15 labels — every result carries exactly one)
- Theorem-grade: defect theorem ⟹ UD; UD for powers; local witness injectivity; mass-balance
  K₂ obstruction; closed-nonproductive algebraic embedding M_σ ⊆ N_C; alphabet-3 wedge bound
  ρ(N_C) ≥ β|β₂| for **closed** wedge-nonzero SCCs.
- Hypothesis G1: finiteness of B_σ (unconditional only for |A|=2 and verified families).
  **v5 Theorem 5.1 is withdrawn** — β·L(s′) ≤ L(s)+D is false (ratio 8.0, unbounded).
- Observation/diagnostic: phase-automaton padding (only legally-repeatable complete-cutting
  cycles are excluded; nonzero-offset recurrence uncontrolled — 19% empirically).
- Conjecture: SCC Producer (`conj:producer`) — the main open target.
- Conditional (companion): existence of a qualifying wedge-nonzero SCC (β-richness / pure-β-zero).
- Main result: **boxed conditional** B_σ finite + SCC Producer ⟹ PDS.

## The open core (unchanged since June)
Symbolic side: Conjecture conj:producer (no closed nonproductive SCC). Cohomology side: Q-A
condition (1)'s upper bound r ≤ C_comp−1 (homological-Pisot rigidity; non-generic; no census
purchase). Both sit behind the no-coarse-quotient meta-theorem. G1 open for |A| ≥ 3.

## Certificate / census figures (verified against files)
- H3′ per-specimen certificates: **1,083 certified / 50 capped / 3 timeouts** (latest ledger in
  H3PRIME_LFIX_REDUCTION.md). A memory figure of "1,266" is unsupported by any file.
- Exhaustive k=3 PIP census: **4,554** specimens (BPA termination 4,554/4,554, 0 caps; BD-complex
  b₁ census 4,554 rows). This is a census SIZE, not a certificate count.
- Spectral band ρ(N_C) ∈ [β|β₂|, β) on recurrent noncoincident SCCs; no closed nonproductive
  SCC, no trapped pair, no trapped triple in the corpus (elimination, not validation).

## Instrument corrections you MUST use (June 13; only in this bundle until uploaded)
- `legal_swaps.py` — G2/structural BPA runs must seed from legality-filtered swaps; all-swap
  seeding over-counts recurrent SCCs in ~2% of specimens. Termination is seed-invariant.
- `exact_lengths.py` — exact-ℚ(β) genuineness; float census verified sound (0 mismatches).
- Offset-propagation matrix is **M** (M[i,j] = #i in σ(j)), **not Mᵀ** — see `trapped_scc_search.py`.

## Do-not-re-attempt (all refuted or dead-ended; details in the ledger)
H3 letter-graph / affine-fixed-point trapped detector (transpose bug + wrong object) ·
Collar Certification Lemma (refuted; R(C) tracks cycle maxlen, not L_σ) · Q-B spectral
over-constraint (none; coupling is a bounded quotient) · condition (1) via census or ×β lever ·
Barge–Olimb for 1D (no content) · kernel-graph · Rauzy/DT address · bilateral-permutative route ·
Rauzy tiling-boundary and radius-ceiling as exclusion mechanisms.

## Certificate documents — PATCHED 2026-09-08
`PROOF_CERTIFICATE.md`, `V34_CLOSURE.md`, `DOMINANT_K2_SOURCE_V34.md` in this bundle are the
corrected versions: "unconditional" → "conditional on finite B_σ (G1)"; v5 Thm 5.1 marked
withdrawn. The versions in the project knowledge (pre-patch) carried a false "unconditional"
claim from June to September. Replace them.

## Next work (per the sixth reviewer)
Mathematical, not editorial: the companion β-richness/cyclic-vector route, or a direct attack on
SCC Producer / no diagonal-free zero-return systems. Do not open another manuscript-scope pass.
