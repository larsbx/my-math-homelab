# Project audit — 2026-09-08 (≈3 months after the June 13–15 sessions)

Scope: the PSC program as it stands in (a) the project knowledge (`/mnt/project`, 224 files),
(b) the delivered outputs (`/mnt/user-data/outputs`, 58 files dated Jun 13–15), and (c) working
memory. Method: cross-check every load-bearing claim across the three sources; verify
against the files rather than trusting any one record.

Headline: **the mathematics is in good shape; the record-keeping is not.** The canonical
manuscript (v15) is scope-clean after six external review rounds, but the project knowledge
has not been updated since v13, a known-false "unconditional" claim still stands in the
project's own certificate documents three months after its patch was delivered, and working
memory asserts two things (a v16 manuscript, a 1,266-certificate count) that no file supports.

═══════════════════════════════════════════════════════════════════════════════
## A. CRITICAL — stale project knowledge and an un-applied correction
═══════════════════════════════════════════════════════════════════════════════

**A1. The project knowledge tops out at PSC_PROOF_v13.** Everything from the June 13–15 work
exists only in outputs and was never added to the project:
- `PSC_PROOF_v14`, `PSC_PROOF_v15` (the canonical manuscript, six review rounds, 20 pp),
- `Geometric_Mass_Balance_Two_Anchor_v8` (companion; project still holds the old unversioned copy),
- 20 verification/adjudication notes (`SESSION_2026_06_13_LEDGER.md` is the index),
- 30 instruments, including three that CORRECT trusted-instrument behavior: `legal_swaps.py`
  (legality-filtered seeds), `exact_lengths.py` (exact ℚ(β) genuineness), and the
  `trapped_scc_search.py` offset-matrix convention (AT = M, not Mᵀ).
The "read-first" `SESSION_2026_06_10_SUMMARY.md` predates all of this (1 incidental mention of
later work). A new session started from project knowledge alone would rediscover a v13-era
state, re-attempt the H3 letter-graph route (bug), re-attempt the Collar lemma (refuted), and
inherit the v34 overclaim below.
**Action:** upload the June 13–15 outputs to the project; replace the read-first pointer with
`SESSION_2026_06_13_LEDGER.md`; retire v13/v14 as superseded (see B3).

**A2. The v34 certificate patch was delivered on June 13 and NEVER APPLIED.** Verified today:
- `PROOF_CERTIFICATE.md` — 3 occurrences of "unconditional"; line 458 still reads "finite-closure
  input discharged via **PSC_PROOF_v5 Theorem 5.1**"; spine step 1 still cites Thm 5.1.
- `V34_CLOSURE.md` — 3 occurrences; title still "unconditional"; "no hypotheses" spine.
- `DOMINANT_K2_SOURCE_V34.md` — 8 occurrences; still states the false β·L(s′) ≤ L(s)+D.
v5 Theorem 5.1 is confirmed broken (worst ratio 8.0, excess 133k, unbounded scaling —
`v5_thm51_test.py`) and was independently re-derived as broken by the first external reviewer.
The Load-Bearing SCC Theorem is conditional on G1 (finite B_σ). These three documents have
carried a FALSE "unconditional / no hypotheses" claim for three months.
**Action:** apply `V34_CERTIFICATE_PATCH_2026_06_13.md` verbatim (exact replacements given).
This is the single highest-priority item: it is an incorrect claim in the project's own
certificate of record.

═══════════════════════════════════════════════════════════════════════════════
## B. MEMORY vs REALITY — claims in working memory not supported by any file
═══════════════════════════════════════════════════════════════════════════════

**B1. "PSC_PROOF_v16 (29 pp, freeze-stable per external audit)" — DOES NOT EXIST.** No v16 in
the project, in outputs, or anywhere on the filesystem. The verified canonical manuscript is
**v15 (20 pp)**, final revision dated Jun 15, containing all six review-round fixes (verified by
content: "legally repeatable" ×3, "closed recurrent SCC" ×7, "Hypothesis~\ref{thm:finiteness}"
×11). Either v16 was produced in a session whose files were never stored here, or the memory
entry is a confabulation. Until a file is produced, **treat v15 as canonical and the v16 claim
as unreliable.**

**B2. "1,266 sound per-specimen H3′ certificates" / "4,554/4,554 certified" — UNVERIFIED and
partly a conflation.** The project's own ledger (`H3PRIME_LFIX_REDUCTION.md`) records the
certificate count evolving 206 → 726 → 760 → **1,083 certified / 50 capped / 3 timeouts** as
its latest figure. No file supports 1,266. The "4,554/4,554" figure is the exhaustive k=3 PIP
count for the BPA-termination and BD-complex censuses (G1 elimination and b₁ census), NOT an
H3′ certificate count; memory has merged two different totals.
**Action:** correct memory to "1,083 sound H3′ certificates (latest verified ledger); 4,554 =
exhaustive k=3 PIP census size, a different quantity."

**B3. "v13/v14/v15/v16 manuscripts correctly reflect [PSC open]" — FALSE for v13 and v14.**
v13 (in project) and v14 (in outputs) both state `thm:finiteness` as a PROVED theorem with the
broken predecessor-contraction proof, and use it as a discharged input in the main assembly.
Only v15 carries finiteness as Hypothesis G1. v13/v14 overclaim finiteness and must not be
cited as reflecting the true status.
**Action:** mark v13/v14 superseded-with-known-error; v15 is the only citable version.

═══════════════════════════════════════════════════════════════════════════════
## C. MATHEMATICAL STATUS — verified sound
═══════════════════════════════════════════════════════════════════════════════

**C1. v15 is scope-clean.** Six external review rounds: rounds 1–4 each closed one genuine gap
(all "proof establishes the easy case, claims the general case": BSW converse; padding
total-run; phase-cycle complete-cutting; open-vs-closed SCC), round 5 wording only, round 6
one diagnostic softening. Every gap was verified empirically before patching. Final architecture:
        **B_σ finite (G1) + SCC Producer ⟹ PDS**,
with UD/local-injectivity/mass-balance/algebraic-embedding theorem-grade, the alphabet-3
wedge bound theorem-grade for closed wedge-nonzero SCCs, and existence of a qualifying SCC
conditional (companion β-richness). The reviewer's final classification: "submission-stable as a
conditional structural note." I concur after re-reading today.

**C2. Companion GMB_v8 `cor:cr` is sound and consistent with v15's conditional `cor:cr-floor`.**
Checked today because round 1 found a BSW-converse gap in v15's version of the same result. The
companion derives ¬PDS via **overlap** coincidence ("trapped component ⟹ fails overlap
coincidence ⟹ ¬PDS, [Sol97, AL11]"), which IS a genuine iff. The v15 gap was specific to
identifying the geometric trapped component with the BALANCED-PAIR closed nonproductive SCC —
that identification is exactly the "bridge converse" v15 now names. The two documents are
consistent; v8 should add one cross-reference sentence making the identification explicit.

**C3. Companion `cor:power` ("σ primitive irreducible Pisot ⟹ σ^p is too") is CORRECT for
Pisot β** — a point worth recording because reviewer 2 asked v15 to soften the analogous
sentence. For a Pisot number, Q(β^p) = Q(β): the conjugates of β over Q(β^p) would be β·ζ
(ζ a root of unity), of modulus β > 1, but every conjugate of β other than itself has modulus
< 1; so ζ = 1 and the degree is preserved. The v15 softening was harmless but unnecessary;
the companion's lemma stands as written. (The 12% imprimitivity of N_C found in the audit is a
separate matter — it concerns the SCC matrix, handled by the companion's power normalization.)

**C4. The open core is unchanged and correctly placed:** condition (1)'s upper bound
r ≤ C_comp−1 (homological-Pisot rigidity, non-generic, no census purchase) on the cohomology
side, twin to Conjecture `conj:producer` (SCC Producer) on the symbolic side; both behind the
no-coarse-quotient meta-theorem. G1 (finiteness) is open for |A| ≥ 3. Nothing in the last three
months' record changes this.

═══════════════════════════════════════════════════════════════════════════════
## D. INSTRUMENT STATE
═══════════════════════════════════════════════════════════════════════════════

- Trusted set unchanged in the project (`overlap_residual`, `qinf2`, `qinf_bigk`, `gap_census`,
  `gap_bigk`, `bd_exact`).
- Three June corrections live ONLY in outputs (A1): `legal_swaps.py` (G2 censuses seeded from
  all swaps over-count recurrent SCCs in ~2% of specimens), `exact_lengths.py` (float
  genuineness verified sound against exact ℚ(β), 0 mismatches), and the AT = M offset-matrix
  convention (the H3 letter-graph bug). Any future G2/H3 work must use these.
- Do-not-re-attempt (all in the ledger, none in project knowledge): H3 letter-graph / affine
  fixed point; Collar Certification Lemma; Q-B spectral over-constraint; condition (1) via census
  or ×β lever; Barge–Olimb for 1D; kernel-graph; Rauzy/DT address; bilateral-permutative route.

═══════════════════════════════════════════════════════════════════════════════
## E. ACTION LIST (ranked)
═══════════════════════════════════════════════════════════════════════════════

1. **Apply `V34_CERTIFICATE_PATCH_2026_06_13.md`** to the three certificate documents. (False
   "unconditional" claim, live for 3 months.)
2. **Upload the June 13–15 outputs to the project**; set `SESSION_2026_06_13_LEDGER.md` as
   read-first; mark v13/v14 superseded-with-error; v15 canonical.
3. **Correct working memory:** no v16 exists (v15 canonical, 20 pp); certificates = 1,083 (not
   1,266); 4,554 is the k=3 census size, not a certificate count; v13/v14 overclaim finiteness.
4. Add one cross-reference sentence to companion v8 `cor:cr` naming the geometric-vs-balanced-
   pair identification as the bridge converse (consistency with v15 §6.5).
5. Then — per the sixth reviewer — the next work is mathematical, not editorial: the companion
   β-richness/cyclic-vector route, or a direct attack on SCC Producer. Do not open another
   manuscript-scope pass.

═══════════════════════════════════════════════════════════════════════════════
## F. Summary judgement
═══════════════════════════════════════════════════════════════════════════════
The June work was sound and the review cycle converged; the failure is that none of it was
propagated into the project's canonical store, so the project as a new reader would find it
still asserts a broken theorem as proved and knows nothing of the corrections. This is the same
failure mode the June 13 audit itself caught in the v34 documents (retraction in memory, not in
the record) — now recurring one level up. The fix is mechanical (items 1–3) and should precede
any further mathematics.
