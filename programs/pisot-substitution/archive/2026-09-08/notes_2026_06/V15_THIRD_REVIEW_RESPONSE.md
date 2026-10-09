# v15 third-review response: the phase-cycle gap and final scope cleaning (2026-06-13)

The third review endorsed v15's architecture as "research-note stable" and flagged four items,
one a genuine mathematical gap (Lemma 4.5). All four addressed; the gap was verified empirically
before patching.

## Fix 1 (MATHEMATICAL GAP — verified): Lemma 4.5 phase-cycle ⟹ complete-cutting
Reviewer: the proof assumes a recurring non-diagonal phase state gives two COMPLETE σ-cuttings
σ(a)=W=σ(b), but a phase cycle can begin and end at a nonzero offset pair (α,β), emitting a
mid-image cyclic fragment, not a complete concatenation. So the UD contradiction need not apply.
**Verified empirically:** reconstructing the phase walk on 121 specimens, **27,949 of 149,025
recurring phases (19%) recur at a NONZERO offset** — mid-image fragments, no complete cutting.
The reviewer is right.
- **Lemma 4.5** (`lem:non-diag-cycle`) retitled "A complete-cutting non-diagonal cycle gives two
  complete cuttings" and now carries the explicit hypothesis that the cycle returns to zero
  source-offset on both sides; the proof uses that hypothesis precisely where the complete
  concatenation is needed.
- New **Remark** `rem:nonzero-offset` records that non-complete (nonzero-offset) recurrences
  (~1/5 empirically) are not controlled, so the UD contradiction handles only complete-cutting
  cycles.
- **Proposition 4.6 → Observation** (`prop:padding`, "Padding diagnostic"): states only the
  provable content — Φ_σ finite (≤ |A|²|σ|²_max states); a complete-cutting non-diagonal cycle
  is excluded by Theorem upc; non-complete recurrence is uncontrolled. The uniform non-diagonal
  length bound is recorded as a diagnostic, NOT proved. Since finiteness is the hypothesis G1,
  the bound is unused and the demotion costs nothing.

## Fix 2: stale "enters predecessor contraction below" phrase
Removed. The comparison remark now reads: "in the present version this constant is recorded as
a local diagnostic consequence of UD, not used to prove finiteness (Hypothesis G1)."

## Fix 3: Proposition 6.4 split into theorem-grade implication + conditional existence
- **Proposition 6.4** (`thm:v34`) now states ONLY the theorem-grade implication:
  Π^σ_dom K₂|_C ≠ 0 ⟹ ρ(N_C) ≥ β|β₂| (for alphabet 3, given G1), with its proof.
- New **Observation 6.4B** (`obs:v34-existence`): the EXISTENCE of a qualifying SCC via SCC
  condensation from a dominant length-2 seed, conditional on excluding the pure-β-zero
  alternative (No Pure β-Zero SCC / Case-B β-richness). The two claims are now cleanly separated.
- All downstream references (summary §, frozen-status §, rem:v34-scope) softened to "any
  recurrent SCC with nonzero dominant wedge ... existence conditional (Observation 6.4B)."

## Fix 4: abstract reworded to match the split
"record an alphabet-3 spectral mechanism — any recurrent SCC with nonzero dominant wedge
projection has within-SCC Perron eigenvalue at least β|β₂|, while the existence of such an SCC
(the pure β-zero alternative) is deferred to a companion β-richness analysis."

## Scope-label audit (final)
- Finiteness — Hypothesis G1.
- Padding — Observation (diagnostic; only complete-cutting exclusion is rigorous).
- Lemma 4.5 — scoped to complete-cutting cycles, with explicit zero-offset hypothesis.
- Alphabet-3 spectral implication — Proposition (theorem-grade for α-3).
- Existence of qualifying SCC — Observation (conditional).
- SCC Producer — Conjecture.
- Main result — boxed conditional: B_σ finite + SCC Producer ⟹ PDS.
- Cohomology §6.5 — conditional/independent (cr floor under bridge converse).
No mixed labels remain.

## Compile
PSC_PROOF_v15.tex → 20 pp, 0 unresolved references, balanced environments (17/17 proofs).

## Net
Three rounds of external review have each surfaced exactly one genuine mathematical gap that
internal audits missed: the §6.5 BSW-converse contradiction (round 1), the padding total-run
overclaim (round 2), and now the phase-cycle complete-cutting assumption (round 3). All three
are closed and empirically verified. The manuscript is now scope-clean with every result
correctly labeled and every UD-based proof restricted to what it actually establishes. The
honest conditional architecture (B_σ finite + SCC Producer ⟹ PDS) is intact; the proven core
(defect-theorem UD, local hierarchy, SCC Producer reformulation, mass-balance characterization,
algebraic embedding) is preserved.

## Deliverables
PSC_PROOF_v15.tex/.pdf (revised), this changelog, phase_cycle_test.py (the gap verification).
