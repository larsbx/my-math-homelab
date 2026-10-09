# Session ledger — 2026-06-13 (BD inheritance, consolidation, verification sweep)

Consolidates a long session spanning the companion BD-complex line, the v13→v14 merge, and
the discharge of all three standing verification items. Status tags: SOLID (proved/verified),
BREAK (disproved/withdrawn), CANDIDATE (empirical, unproven), RETRACTED (prior claim pulled).

═══════════════════════════════════════════════════════════════════════════════
## A. REQUIRES USER ACTION
═══════════════════════════════════════════════════════════════════════════════

**A1. Apply the v34 certificate patch (V34_CERTIFICATE_PATCH_2026_06_13.md).** Three project
documents — PROOF_CERTIFICATE.md, V34_CLOSURE.md, DOMINANT_K2_SOURCE_V34.md — still label the
Load-Bearing SCC Theorem "unconditional / no hypotheses" via the WITHDRAWN PSC_PROOF_v5
Theorem 5.1. These claims are FALSE as written; the theorem is conditional on finite B_σ (G1).
The patch gives exact drop-in replacements. The canonical v13/v14 line is already correct, so
the program's headline status is unaffected — only the v34 auxiliary docs overstate. [Priority:
this is a live incorrect "unconditional" claim in the certificate.]

═══════════════════════════════════════════════════════════════════════════════
## B. NEW RESULTS — manuscript-grade (in GMB_v8 / PSC_PROOF_v14)
═══════════════════════════════════════════════════════════════════════════════

**B1. Inherited loop-freeness + audited redproj. [SOLID]** Over the loop-free base stratum
(68.1% of exhaustive k=3; 1,740 unimodular), b₁(G₀^ER(σ))=0 ⟹ b₁(G₀^ER(Σ_C))=0, closing Q-A
condition (3). The redproj proof was rewritten and audited: routes through π₁ non-triviality
(reduced nontrivial closed walk ⟹ graph not a tree), NOT the loop's H₁ class. A wrong
intermediate "orientation/H₁" argument was self-caught (brute force: v-edge bipartite graph
has no directed cycles) and replaced. (GMB_v8 lem:redproj, thm:inherit; AUDIT_REDPROJ.)

**B2. Leg-factor cr floor. [SOLID, conditional labeling fixed]** Ω_{Σ_C} factors onto Ω_σ ⟹
cr(Σ_C) ≥ 2 unconditionally; ≥ 3 under unimodular + Q-A (B15 odd-norm). v14 §sec:cohomology-
companion. AUDIT fix: the "primitive Σ_C" assertion needed the σ→σ^p power-normalization
(N_C imprimitive in 12.1% of recurrent SCCs); patched in v14.

**B3. Triple mass-balance ceiling. [SOLID]** The cr≥3 triple system obeys PF(N_C^(3))=β iff
closed, <β otherwise — verbatim the pair dichotomy, via the gated triple partition identity.
v14 lem:triple-ceiling; QB_TRIPLE.

**B4. Second conditional route. [SOLID as conditional]** σ unimodular + Q-A + CRC ⟹ PDS.
Audited: the norm = norm(β) = ±1 is a property of β's minimal polynomial (shared with σ), not
N_C's reducible char poly. v14 prop:qa-crc.

**B5. Condition (1) exact reduction. [SOLID]** On the b₁=0 stratum, Q-A condition (1) reduces
to the single identity r = (C_comp−1) − b₁ with all C_comp−1 nonzero q-roots = 1. Validated
on both BBJS homological-Pisot triple covers (q = x^a(x−1)², r=2). The residual is the UPPER
bound r ≤ C_comp−1, which is NON-GENERIC (producing N_C have full nonzero spectrum, median
r₀/|C| = 1.000) — i.e. it IS the homological-Pisot rigidity, not derivable from b₁=0.
GMB_v8 rem:cond1-irreducible; COND1_REDUCTION. (Self-caught minpoly sign error mid-derivation.)

═══════════════════════════════════════════════════════════════════════════════
## C. CONSOLIDATION & INSTRUMENT HARDENING
═══════════════════════════════════════════════════════════════════════════════

**C1. v13 → v14 merge. [SOLID]** Companion cohomological line merged into the canonical
manuscript: closed-nonproductive SCC ≡ transversal substitution Σ_C (keystone identity),
§sec:cohomology-companion with B1–B4. v14: 19 pp, clean compile, conditional (two routes).
V13_TO_V14_CONSOLIDATION.

**C2. Exact ℚ(β) certification. [SOLID]** Built/gated exact_lengths.py: genuineness decisions
by exact algebraic-number sign in ℚ(β), no float threshold. 4,050 decisions, 0 float/exact
mismatches; 2,152 seed overlaps, 0 mismatches incl. anchors. The float census genuineness was
SOUND. (Self-caught probe artifact: a crude inline predicate gave 1,202 false "mismatches" at
anchors; the real predicate agrees with exact.) EXACT_QBETA_UPGRADE.

**C3. Barge–Olimb. [closed — no 1D content]** Read at source (+ Sadun survey full): a d≥2
paper; 1D asymptotic structure reduces to BD composants already in BBJS. No 1D cr-extension
for the 888 unimodular b₁>0 specimens. Added rem:convention (C, b₁ are complex-dependent;
uncollared convention fixed) + Sadun bibitem to v8. BARGE_OLIMB_ADJUDICATION.

═══════════════════════════════════════════════════════════════════════════════
## D. VERIFICATION SWEEP (three standing items, all discharged)
═══════════════════════════════════════════════════════════════════════════════

**D1. ABBLS seed-legality. [SOLID verdict + actionable fix]** Only 60% of standard swap seeds
are both-legal. Termination is seed-legality-INVARIANT (0/400) ⟹ refutation bar SOUND, G1
SOUND. But all-swap seeding over-counts recurrent SCCs in 2% of specimens (spurious illegal-
seed components) — G2 censuses should use legal-swap seeding. Delivered gated legal_swaps.py.
19/400 specimens have no legal swap seed = degenerate-valid (no length-2 balanced pair).
ABBLS_SEED_LEGALITY.

**D2. v5 Theorem 5.1. [BREAK re-confirmed + propagation defect found]** Predecessor
contraction β·L(s′) ≤ L(s)+D is FALSE (worst ratio 8.0, excess 133k, 34,936 scaling
violations). Retraction correct but NOT propagated → see A1. V5_THM51_RETRACTION_VERIFICATION.

**D3. Collar Certification Lemma. [BREAK — refuted]** R(C) ≤ L_σ (per-σ constant collapse) is
FALSE: ratio grows with corpus (2.0→3.0), tracks cycle maxlen (corr 0.85). Factor-2 bound was
a corpus-size artifact (caught by larger-corpus test). Sound bound is per-cycle R(C) ≤
maxlen(C)−1 (already banked). Does NOT affect the G1a 4·B(σ) ceiling (different constant).
COLLAR_LEMMA_REFUTED.

═══════════════════════════════════════════════════════════════════════════════
## E. DEAD-ENDS / DO-NOT-RE-ATTEMPT
═══════════════════════════════════════════════════════════════════════════════

**E1. H3 letter-graph / affine-fixed-point trapped detector. [BREAK — bug]** Reported ~11k–19k
"trapped candidates" contradicting Q∞ certificates. Cause: (i) used offset matrix M.T instead
of M (incidence is M[i,j]=#i in σ(j), so offset matrix = M); (ii) wrong object — affine fixed
point of one routing ≠ forward-closed anchor-free cone. Corrected search: 0 trapped (matches
qinf2). The letter-graph/affine framing is NOT a sound trapped detector. H3_LETTERGRAPH_BUG.

**E2. Q-B over-constraint by spectral/counting means. [closed]** No over-constraint beyond the
pair case; the triple coupling δ₃−δ₂ is a bounded symbolic quotient, governed by the
no-coarse-quotient meta-theorem. ~1,750 triple SCCs, 0 closed-triple. QB_TRIPLE.

**E3. Condition (1) via census or ×β lever. [closed]** Premise (χ_M | χ_{N_C}) ⟺ trapped
object, absent from corpus by construction; no census purchase, no ×β traction.
SPECTRAL_CONDITION_1_RECON, COND1_REDUCTION.

═══════════════════════════════════════════════════════════════════════════════
## F. THE OPEN CORE (unchanged, accurately placed)
═══════════════════════════════════════════════════════════════════════════════

The sole genuinely-open arithmetic item: condition (1)'s upper bound **r ≤ C_comp−1** on the
b₁=0 stratum — equivalently, does (cut-disjoint, anchor-free, ρ(N_C)=β) force the trapped Σ_C
to be spectrally minimal (q(x) = x^{|C|−k}, all extra N_C-spectrum nilpotent)? This is the
homological-Pisot rigidity, provably non-generic, with NO census purchase. It sits behind the
no-coarse-quotient meta-theorem (positional, not count-level). The symbolic-side twin is
Conjecture conj:producer (G2). PSC headline status: CONDITIONAL on G1 (finite B_σ) ∧ G2
(producer), with two parallel conditional routes and the unconditional leg-factor/triple
structure as supporting facts.

═══════════════════════════════════════════════════════════════════════════════
## G. CORPUS-SIDE FACTS (all hold under corrected/exact instruments)
═══════════════════════════════════════════════════════════════════════════════
- Q∞: every genuine Δ-state's cone reaches an anchor (corrected AT=M; matches qinf2). [SOLID]
- No closed-nonproductive SCC / no trapped pair / no trapped triple in corpus. [elimination]
- Spectral band PF(N_C) ∈ [β|β₂|, β) for recurrent noncoincident SCCs. [SOLID]
- BPA termination: 4,554/4,554 k=3, 0 caps (elimination, NOT a finiteness proof — see D2/A1).
- Genuineness predicate exact-ℚ(β)-certified (C2). Legal-swap seeding available (D1).

## Discipline notes (self-caught this session)
4 self-caught errors before promotion: redproj H₁-orientation (B1), cond1 minpoly sign (B5),
exact-probe anchor artifact (C2), v34 primitivity omission (B2/AUDIT). 2 corpus-size artifacts
caught by larger-corpus testing: collar factor-2 (D3), and the H3 transpose bug caught by
cross-check against a trusted certificate (E1). Census-contradicts-certificate ⟹ bug-until-
proven-otherwise held throughout.
