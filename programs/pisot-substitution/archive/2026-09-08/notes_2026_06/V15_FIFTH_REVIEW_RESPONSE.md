# v15 fifth-review response: final editorial-precision patches (2026-06-13)

The fifth review found NO mathematical gaps — the closed-SCC restriction from the previous round
resolved the last structural issue. It requested four editorial patches to align claim wording
with what the body proves. All applied; the reviewer's verdict was that after these the manuscript
is a stable conditional framework note.

## Patch 1: padding wording (abstract + two intro sentences)
The abstract/intro said Level 2 "bounds the non-diagonal phase length of coincidence padding,"
but the body (Observation 4.6) proves only that complete-cutting non-diagonal cycles are excluded,
with nonzero-offset recurrences uncontrolled and the uniform bound diagnostic.
- Abstract → "gives a finite phase-automaton diagnostic for coincidence padding: complete-cutting
  non-diagonal cycles are ruled out by unique decodability, while nonzero-offset recurrences are
  not controlled; finiteness ... is carried as a hypothesis."
- Both intro sentences → "unique decodability rules out complete-cutting non-diagonal phase cycles."

## Patch 2: Section 4 opening no longer framed as proving finiteness
Was: "The aim of this section is the finiteness of B_σ ... (iii) predecessor contraction from
β>1 (Hypothesis G1)" — stale (the section doesn't prove finiteness; contraction is withdrawn).
Now: "This section records the unique-decodability and phase-automaton facts formerly used in the
Level-2 finiteness attempt ... then states finiteness of B_σ as Hypothesis G1. The
predecessor-contraction argument of earlier versions is withdrawn."

## Patch 3: Proposition 6.4 proof attribution
The proof opened "By Lemma 6.3, the K₂-pushforward..." but Lemma 6.3 is the dominant length-2
source lemma, not the pushforward identity. Now: "By the K₂-pushforward identity K₂(σs) =
Λ²M_σ·K₂(s) on whole pairs (companion note)..." Lemma 6.3 (lem:dom-K2) now appears only in the
existence Observation 6.4B, where the dominant-seed selection belongs.

## Patch 4: Remark 6.6 first bullet
Was: "rules out the degenerate possibility that EVERY recurrent noncoincident SCC has spectral
radius below β|β₂|" — too strong, since Prop 6.4 applies only to closed wedge-nonzero SCCs.
Now: "rules out such spectral collapse for any closed recurrent SCC with nonzero dominant wedge
projection."

## Compile
PSC_PROOF_v15.tex → 20 pp, 0 unresolved references, balanced environments.

## Final claim-structure (reviewer's table, confirmed)
| Component | Status |
|---|---|
| UD from defect theorem | theorem-grade |
| Phase automaton | diagnostic, correctly scoped |
| Finiteness of B_σ | Hypothesis G1 |
| Local witness injectivity | theorem-grade |
| SCC Producer | main open conjecture |
| Mass-balance K₂ obstruction | theorem-grade |
| Closed-nonproductive algebraic embedding | theorem-grade |
| Alphabet-3 β|β₂| lower bound | theorem-grade for closed wedge-nonzero SCCs |
| Existence of qualifying SCC / pure-β-zero | companion conditional analysis |
| Main result | boxed conditional: B_σ finite + SCC Producer ⟹ PDS |

## Net (five review rounds)
Rounds 1–4 each surfaced one genuine mathematical gap (BSW converse, padding total-run,
phase-cycle complete-cutting, open-vs-closed SCC); round 5 found none and asked only for wording
precision. The manuscript is now a stable conditional framework: every result correctly labeled,
every proof restricted to what it establishes, the honest architecture B_σ finite + SCC Producer
⟹ PDS intact, and the proven core (defect-theorem UD, local hierarchy, SCC Producer reformulation,
mass-balance, algebraic embedding) preserved.

## Deliverables
PSC_PROOF_v15.tex/.pdf (final wording pass), this changelog.
