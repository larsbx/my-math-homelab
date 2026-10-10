# v5 Theorem 5.1 retraction-status verification (2026-06-13)

## Task
Standing item: verify the retraction status of PSC_PROOF_v5 Theorem 5.1 (Finiteness of
B_σ), recorded in working memory as "found concretely broken; v34 retracted to conditional
on BPA finiteness."

## Finding 1 — the breakage is REAL (re-verified empirically, not taken on faith)
Theorem 5.1's load-bearing step is the predecessor contraction
        β·L(s′) ≤ L(s) + D            (s → s′ a BPA child edge, D a constant padding bound),
which yields a geometric-span bound B = max(L_max, D/(β−1)) and hence |B_σ| < ∞.

Direct test over 300 PIP specimens (every parent→child edge, exact tile lengths):
- worst β·L(child) − L(parent) = **133,500** (with D ≈ 2–5),
- worst ratio β·L(child)/L(parent) = **8.02**,
- **34,936** edges where the excess grows with parent length (no additive-constant D possible).
Mechanism: a balanced-pair split can hand a child block spanning most of the inflated word,
so |child| > |parent| (e.g. 19 from 11), making β·L(child) ≫ L(parent) unboundedly. The
inequality is FALSE. The retraction is correct.

## Finding 2 — the retraction is NOT PROPAGATED (the actual defect)
Three project documents still cite Theorem 5.1 as a proved, discharged input and assert the
downstream result UNCONDITIONAL:
- **PROOF_CERTIFICATE.md** (≈ lines 455–467): "With the finite-closure input discharged via
  PSC_PROOF_v5 Theorem 5.1, the Load-Bearing SCC Theorem is **unconditional**"; proof spine
  step 1 = "PSC_PROOF_v5 Theorem 5.1: B_σ finite."
- **V34_CLOSURE.md** (≈ lines 1–20): title "Load-Bearing SCC Theorem **unconditional**";
  "v34 closed unconditional by citing PSC_PROOF_v5 Theorem 5.1"; "Eight-step proof spine
  (**no hypotheses**)" with step 1 = Theorem 5.1.
- **DOMINANT_K2_SOURCE_V34.md** (≈ lines 3, 84, 98–129, 161–196): "full chain unconditional
  via PSC_PROOF_v5 Theorem 5.1"; Theorem 5.1 stated with the now-false predecessor
  contraction "β L(s′) ≤ L(s) + D".

These "unconditional" / "no hypotheses" claims are FALSE as written. With Theorem 5.1
withdrawn, the Load-Bearing SCC Theorem (ρ(N_{C*}) ≥ β|β₂|) is **conditional on finiteness
of B_σ** — i.e. on G1, which is itself open in general and proved only for |A|=2 (HS03) and
verified families.

## Required corrections (to be applied to the manuscript line; documents are read-only here)
Replace, in all three documents:
  "unconditional" / "no hypotheses" (re the Load-Bearing SCC Theorem)
→ "conditional on finiteness of B_σ (G1)".
And replace proof-spine step 1:
  "PSC_PROOF_v5 Theorem 5.1: B_σ finite"
→ "HYPOTHESIS (G1): B_σ is finite for this σ. [v5 Thm 5.1's predecessor-contraction proof
   is withdrawn — β·L(s′) ≤ L(s)+D is false; see V5_THM51_RETRACTION_VERIFICATION. Finiteness
   is known unconditionally only for |A|=2 and verified families; the exhaustive k=3 BPA
   sweep (4,554/4,554, 0 caps) is empirical elimination, not a proof of finiteness.]"

The conditional Load-Bearing SCC statement itself (given finite B_σ ⟹ ρ(N_{C*}) ≥ β|β₂|) is
unaffected by the retraction — only its UNCONDITIONAL labeling is wrong. Steps 2–8 of the
spine (K₂ basis, Lemma 1, intertwining) do not depend on Theorem 5.1's proof, only on B_σ
being finite, which is now correctly a hypothesis.

## Cross-check with the canonical manuscript line
PSC_PROOF_v13/v14: these were ALREADY correctly conditional (v14 §sec:v34-bound states the
spectral bound on a recurrent SCC without claiming unconditional finiteness; the open core is
Conjecture conj:producer). So the CANONICAL line is sound; the defect is confined to the
v34/DOMINANT_K2/CERTIFICATE auxiliary documents, which lag the retraction. v14's status
("conditional, two routes") is the correct global status and is unchanged.

## Net
- Breakage re-confirmed (worst ratio 8.0, excess 133k, scaling unbounded). Retraction correct.
- Three auxiliary documents carry an un-propagated "unconditional" claim that is FALSE; exact
  edits specified above. The canonical v13/v14 line is already correct, so the program's
  headline status (conditional on G1 / the producer conjecture) is accurate; only the v34
  certificate wording overstates.
- Recommend: demote the three documents' "unconditional" to "conditional on G1" and add the
  withdrawal note, so no reader treats v5 Thm 5.1 as a discharged input.

## Artifacts
`v5_thm51_test.py` (predecessor-contraction breakage test, 300 specimens).
