# Patch: demote v34 "unconditional" claims to conditional-on-G1 (2026-06-13)

Apply these replacements to the read-only project documents (copy to a writable location
first). Each removes reliance on the withdrawn PSC_PROOF_v5 Theorem 5.1.

---
## PROOF_CERTIFICATE.md  (≈ lines 455–467)

REPLACE:
> The v33–v34 program established a parallel route to the alphabet-3 spectral lower bound,
> independent of the Spectral Black Box of §14. With the finite-closure input discharged via
> **PSC_PROOF_v5 Theorem 5.1**, the Load-Bearing SCC Theorem is **unconditional**:
>
> > **Theorem (Load-Bearing SCC, unconditional).** ...
>
> **Proof spine** ...
> 1. PSC_PROOF_v5 Theorem 5.1: $B_\sigma$ finite (defect theorem + Mossé + $\beta>1$).

WITH:
> The v33–v34 program established a parallel route to the alphabet-3 spectral lower bound,
> independent of the Spectral Black Box of §14. The Load-Bearing SCC Theorem is **conditional
> on finiteness of $B_\sigma$ (G1)**:
>
> > **Theorem (Load-Bearing SCC, conditional on finite $B_\sigma$).** For every PIP σ on
> > alphabet 3 with $B_\sigma$ finite, there exists a recurrent NC-SCC $\mathcal{C}^*$ of
> > $B_\sigma$ with $\rho(N_{\mathcal{C}^*}^{\mathrm{total}}) \ge \beta|\beta_2|$.
>
> **Proof spine** (full details in `v34/DOMINANT_K2_SOURCE_V34.md`):
> 1. **HYPOTHESIS (G1):** $B_\sigma$ is finite. [The predecessor-contraction proof of
>    PSC_PROOF_v5 Theorem 5.1 is **withdrawn**: $\beta L(s') \le L(s)+D$ is false (worst
>    ratio 8.0, excess unbounded; see V5_THM51_RETRACTION_VERIFICATION_2026_06_13). Finiteness
>    is unconditional only for $|A|=2$ and verified families; the k=3 sweep (4,554/4,554, 0
>    caps) is elimination, not proof.]

---
## V34_CLOSURE.md  (title + lines 1–20)

REPLACE title "# v34 Closure — Load-Bearing SCC Theorem unconditional"
WITH         "# v34 Closure — Load-Bearing SCC Theorem (conditional on finite $B_\sigma$)".

REPLACE bullet "- **v34 closed unconditional** by citing PSC_PROOF_v5 Theorem 5.1 ..."
WITH    "- **v34 reduced to the single hypothesis G1 (finite $B_\sigma$).** The earlier
         closure via PSC_PROOF_v5 Theorem 5.1 is withdrawn (predecessor contraction false);
         finiteness is a hypothesis, unconditional only for $|A|=2$ and verified families."

REPLACE "## Eight-step proof spine (no hypotheses)"
WITH    "## Eight-step proof spine (one hypothesis: G1, finite $B_\sigma$)"
REPLACE spine step 1 "**PSC_PROOF_v5 Theorem 5.1**: $B_\sigma$ is finite for every PIP σ."
WITH    "**HYPOTHESIS (G1):** $B_\sigma$ is finite (Theorem 5.1's proof withdrawn; see note)."

---
## DOMINANT_K2_SOURCE_V34.md  (lines 3, 98–129, 161–196)

REPLACE "## Status: Lemma 1 proved — full chain unconditional via PSC_PROOF_v5 Theorem 5.1"
WITH    "## Status: Lemma 1 proved — full chain conditional on G1 (finite $B_\sigma$); v5 Thm 5.1 withdrawn".

In the Theorem 5.1 statement (≈ lines 128–129), mark the predecessor contraction as FALSE:
REPLACE "predecessor contraction gives $\beta L(s') \le L(s) + D$, so the geometric span is
         bounded ..."
WITH    "[WITHDRAWN] the claimed predecessor contraction $\beta L(s') \le L(s)+D$ is false
         (worst ratio 8.0, excess unbounded; V5_THM51_RETRACTION_VERIFICATION_2026_06_13);
         finiteness of $B_\sigma$ is therefore a HYPOTHESIS (G1), not proved here."

In the status tables (≈ lines 161–196), change every "Proved (... Thm 5.1)" and "Finite
balanced-pair closure | Proved (PSC_PROOF_v5 Theorem 5.1)" to "Hypothesis (G1; v5 Thm 5.1
withdrawn)".

---
## Note
The conditional theorems (given finite $B_\sigma$ ⟹ ρ ≥ β|β₂|; Lemma 1; intertwining) are
UNCHANGED — only the "unconditional" labeling and the citation of Theorem 5.1 as discharged
are corrected. The canonical PSC_PROOF_v13/v14 line was already conditional and needs no
change.
