# v15 fourth-review response: Proposition 6.4 restricted to closed SCCs (2026-06-13)

The fourth review found one remaining load-bearing correction: Proposition 6.4's within-SCC
spectral bound is valid only for CLOSED recurrent SCCs, not arbitrary recurrent SCCs. Applied,
verified empirically. The review judged that after this fix the manuscript is "submission-stable
as a conditional structural note."

## The correction (verified)
Reviewer: the proof's step Σ_{c∈D_k}‖K₂(c)‖ ≳ (β|β₂|)^k ⟹ |D_k∩C| ≳ (β|β₂|)^k is invalid for
an OPEN SCC, because descendants can leave C and the dominant wedge growth may be carried by
escaping components — which the within-SCC matrix N_C does not see.
**Verified empirically:** across 151 specimens, all 12 open recurrent SCCs have edges escaping
the SCC (12/12), while all 150 closed SCCs do not. So for open SCCs descendants genuinely leave
C, and the within-SCC counting cannot capture the wedge growth. The reviewer is right.

## Fix applied
- **Proposition 6.4** (`thm:v34`) retitled "Spectral lower bound on N_C, **closed** SCC,
  alphabet 3" and restricted to closed recurrent noncoincident C. The proof now uses closedness
  explicitly: "Because C is closed, every descendant of s∈C remains in C (noncoincident children
  stay in C; coincidence children carry no wedge mass), so D_k ⊆ C and the wedge growth cannot
  escape." A closing sentence states the hypothesis is essential and why it fails for open SCCs.
- **Observation 6.4B** (`obs:v34-existence`) reworded to the reviewer's global-condensation form:
  "the global descendant growth forces some recurrent component of the condensation graph to
  carry the spectral growth, provided the dominant wedge mass is not lost through escape into
  pure β-zero components" — conditional on the No-Pure-β-Zero / β-richness lemmas.
- **Abstract** now reads "any \emph{closed} recurrent SCC with nonzero dominant wedge projection
  has within-SCC Perron eigenvalue at least β|β₂|, while the existence of such an SCC (the pure
  β-zero/escape alternative) is deferred to a companion β-richness analysis."
- Downstream references (frozen-status §, summary §, rem:v34-scope) all updated to "closed
  recurrent SCC."

## Final status table (per the reviewer)
| Part | Status |
|---|---|
| UD from defect theorem | theorem-grade |
| Phase automaton | diagnostic, correctly scoped (Observation) |
| Finiteness of B_σ | hypothesis G1 |
| Local witness injectivity | theorem-grade |
| SCC Producer reformulation | correct open target (Conjecture) |
| Mass-balance K₂ obstruction | theorem-grade |
| Algebraic embedding M_σ ⊆ N_C | theorem-grade |
| Alphabet-3 β|β₂| lower bound | theorem-grade for CLOSED SCCs (Prop 6.4) |
| Global existence of qualifying SCC | conditional on pure-β-zero / β-richness (Obs 6.4B) |
| Main result | boxed conditional: B_σ finite + SCC Producer ⟹ PDS |

## Compile
PSC_PROOF_v15.tex → 20 pp, 0 unresolved references, balanced environments (17/17 proofs).

## Net (four review rounds)
Each of the four external reviews surfaced exactly one correction my internal audits had missed:
(1) §6.5 BSW-converse contradiction; (2) padding total-run overclaim; (3) phase-cycle
complete-cutting assumption; (4) Proposition 6.4 open-vs-closed SCC. All four verified
empirically and fixed. The first three were "proof asserts X, establishes only the easy case of
X" gaps in UD/cohomology steps; the fourth was a descendant-escape gap in the spectral counting.
The manuscript's claims now align with the actual proof status throughout, with the honest
conditional architecture (B_σ finite + SCC Producer ⟹ PDS) intact.

## Deliverables
PSC_PROOF_v15.tex/.pdf (revised), this changelog, prop64_escape2.py (the closed/open
escape verification).
