# Session 2026-06-13 — BD transition complex, type decomposition, inherited loop-freeness

Companion line: v7 → **v8** (`Geometric_Mass_Balance_Two_Anchor_v8.tex/.pdf`, 15 pp, clean compile, 0 unresolved refs). New §: *Transition-complex constraints on the trapped shape* (`sec:trans`), inserted between the powers/period-trapped section and the computational-evidence section; `rem:QA` now forward-points into it.

## Literature pinned at source (this session)

- **BBJS12** (Barge–Bruin–Jones–Sadun, Israel J. Math. 188 (2012); read from Bruin's site, arXiv:1001.2027). Exact BD-complex convention: G₀ has one edge v_ij per legal 2-word, out_i → in_j, bipartite vertex set; induced map v_ij ↦ v_{lastσ(i), firstσ(j)} permutes ER edges. Exact sequence 0 → H̃⁰(G₀^ER) → lim Aᵀ → Ȟ¹(Ω) → H¹(G₀^ER) → 0. Calibration values used for gating: 1↦21112, 2↦121 (b₁=1); their 6-letter cr=3 specimen (C=3, b₁=0).
- **B15** (Barge, Bull. SMF 143 (2015), arXiv:1301.7094; read in full). Thm 4(5): PDS ⟺ cr=1, general Pisot family — provenance flag resolved. Thm 22: Pisot on letters (no irreducibility), **odd norm**, cr=2 ⟹ dim H¹ ≥ 2d−1. Cor 25: a PSC counterexample has an asymptotic cycle or cr ≥ 3.
- **Ledgered discrepancy:** CRC stated as "cr divides the norm" in B15 vs "cr divides a power of the norm" in BBJS12. Immaterial for unimodular (both force cr=1) but must be cited carefully outside that case.
- Barge–Olimb (arXiv:1101.4902): identified as mainly higher-dimensional branch-locus machinery; **not yet read at source** — queued for the b₁>0 stratum.

## Adjudication (retraction of a queue item)

STRATA §5(i) "backward branching of the avoidance walk" — **retracted as a target**. Two trapped pasts of one tail is automatic: asymptotic pairs exist in every primitive aperiodic substitution subshift, and every hull point of τ decodes trapped. Mossé/BSTY recognizability constrains desubstitution, not backward determinism of the shift — earlier misattribution ledgered. The refutable object is exactly **b₁(G₀^ER(Σ_C))**: by the type decomposition, a type-pure closed alternating chain of asymptotic branchings.

## New proved results (all in v8 §sec:trans; adversarially passed)

1. **Connectivity lemma** (`lem:connect`). Irreducible Pisot ⟹ 1 ∉ spec(Aⁿ) ∀n ⟹ G₀^ER(σ) connected; dim Ȟ¹(Ω_σ) = k + b₁(G₀^ER). Doubles as implementation validator (0 violations across both censuses).
2. **Boundary-Type Determinacy** (`lem:typedet`, unconditional). For a genuine overlap c=(i,δ,j), t=⟨δ,L⟩: left endpoint is I-type iff t<0, J-type iff t>0, prefix anchor iff t=0; right endpoint I iff t>L_i−L_j, J iff <, suffix anchor iff =. Anchor-free trapped ⟹ every cell has intrinsic left/right types.
3. **Type Decomposition** (`thm:decomp`). G₀^ER(Σ_C) = G_I ⊔ G_J, vertex-disjoint, both meeting ER ⟹ C(G₀^ER(Σ_C)) ≥ 2; b₁ additive; mixed cycles impossible.
4. **Root-of-Unity Corollary** (`cor:rootofunity`, unconditional for anchor-free trapped). q := χ_{N_C}/χ_A has ≥ C−1 ≥ 1 root-of-unity roots; |C| ≥ k+1 (strict improvement on Thm 2.5 size floor); spec(N_C) must contain a root of unity — new sharp corpus discriminator (no recurrent component in the corpus has this shape).
5. **Reduced Projection** (`lem:redproj`). Simple cycles of G₀^ER(Σ_C) are type-pure and project to *reduced* closed paths in G₀^ER(σ) via the letter coordinate (predecessor/successor determinacy from unit-step Lemma 6.9) ⟹ b₁(σ) ≥ 1.
6. **Inherited Loop-Freeness** (`thm:inherit`). b₁(G₀^ER(σ)) = 0 ⟹ b₁(G₀^ER(Σ_C)) = 0 for every anchor-free trapped C. Resolves Q-A condition (3) over loop-free bases — 68.1% of the exhaustive k=3 corpus, including 1,740 of 2,628 unimodular.
7. **Q-A Residue Corollary** (`cor:QAresidue`). Over loop-free bases: Σ_C homological Pisot ⟺ #nz-roots(q) = C(G₀^ER(Σ_C)) − 1, in which case all nonzero roots of q are roots of unity. The rigidity question is now a counting identity.
8. **Leg-Factor Lemma** (`lem:legfactor`, any trapped C). Ω_{Σ_C} factors onto Ω_σ (merge cells between I-vertices; local, syndetic, onto by minimality).
9. **cr Corollary** (`cor:cr`). cr(Σ_C) ≥ 2 unconditionally; unimodular σ + Q-A ⟹ cr(Σ_C) ≥ 3 (B15 Thm 22 with norm ±1: cr=2 would force dim H¹ ≥ 2k−1 > k).
10. **Conditional Placement** (`thm:QACRC`). **Q-A + CRC ⟹ unimodular PSC.** Honest placement (`rem:adjud`): a transfer into the homological-Pisot/CRC orbit, not a resolution — CRC is open exactly in the cr ≥ 3 regime the corollary lands in; positional avoidance residue untouched, consistent with the no-coarse-quotient meta-theorem.

## Instruments and censuses (gated before corpus use)

- **`bd_exact.py`** — exact-convention BD complex (legal 2-words via crossing closure; ER via nested-image stabilization; b₁ = E−V+C; ER permutation cycle types). Gate 4/4 against BBJS calibration values. TRUSTED.
- **Exhaustive k=3 census** (`bd_census.py`, `bd_rows.jsonl`, 4,554 rows; same PIP enumeration as census.py). Connectivity violations 0. b₁ ∈ {0: 3102 (68.1%), 1: 552, 2: 720, 4: 180}. Unimodular: 2,628, of which 1,740 loop-free. b₁=3 absent at k=3; max ER cycle length 6; max-b₁ specimen idx 1746 hand-verified = K₃,₃. Supersedes the 150-specimen proxy run (66% → 68.1%, same support).
- **k=4 random census** (seed 2026, |σ(a)| ≤ 3; `bd_rows_k4.jsonl`, 1,190 PIP). Connectivity 0 violations. b₁ ∈ {0: 698 (58.7%), 1: 142, 2: 125, **3: 104**, 4: 65, 5: 7, 6: 41, 7: 1, 9: 7}; ceiling b₁ = 9 = K₄,₄ attained. **The k=3 absence of b₁=3 is falsified as structural** — corpus artifact, ledgered.
- **`type_determinacy_check.py`** — validates `lem:typedet` + re-validates unit-step Lemma 6.9 against `overlap_residual.py` with exact integer-vector cuts: 24 PIP specimens, 9,945 boundaries, 9,660/9,660 sign-predicate matches on non-shared boundaries, 285/285 shared cuts anchor-adjacent. PASSED.

Census results are elimination, not validation; none bear on the uniform statements.

## Queue

1. **Q-A residue attack**: the counting identity #nz(q) = C(ER(Σ_C)) − 1. Spectral condition (1) is now the wall; ×β fiber-monodromy lever still available.
2. **Barge–Olimb at source** for the b₁ > 0 stratum (888 unimodular k=3 specimens where cr=2 is not yet excluded).
3. **Q-B triple geometry** (1,740-specimen-calibrated unconditional stratum).
4. v13/v14 consolidation of companion results into the main manuscript line.

## Shipped

`Geometric_Mass_Balance_Two_Anchor_v8.tex/.pdf`, `SESSION_2026_06_13_NOTES.md`, `bd_exact.py`, `bd_census.py`, `bd_rows.jsonl`, `bd_rows_k4.jsonl`, `type_determinacy_check.py`, `BD_EXACT_AND_BRANCHING_ADJUDICATION.md` (shipped earlier this session).
