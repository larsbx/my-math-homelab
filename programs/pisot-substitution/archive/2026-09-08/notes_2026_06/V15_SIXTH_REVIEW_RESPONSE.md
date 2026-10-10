# v15 sixth-review response: final Lemma 4.5 softening (2026-06-13)

The sixth review classified v15-5 as "submission-stable as a conditional structural note" and
flagged one remaining mathematical softness, in the diagnostic Lemma 4.5, with a suggested safe
weakening. Applied. No other changes requested.

## The softness
Lemma 4.5 concluded "$W^n$ is a legal factor for every $n$" from a quick "iterate the cycle /
use primitivity" argument. In a primitive substitution language, a factor occurring once does
not imply all powers $W^n$ occur. Since the phase-cycle section is explicitly diagnostic (not
load-bearing — finiteness is Hypothesis G1), this was not fatal, but the unproved repetition
step should not be asserted.

## Fix applied (the reviewer's safe weakening)
- **Lemma 4.5** (`lem:non-diag-cycle`) now concludes only the solid part unconditionally:
  a complete-cutting non-diagonal cycle gives $\sigma(a)=W=\sigma(b)$ with $a\ne b$. The
  contradiction with unique periodic cutting is stated conditionally: "If, moreover, $\gamma$ is
  legally repeatable --- so that $W^n$ is a legal factor for every $n$ --- then unique periodic
  cutting (Theorem upc) is contradicted." The proof's final clause explicitly says: "We do not
  assert that an arbitrary complete-cutting cycle is legally repeatable; the contradiction is
  available precisely in the periodic-realizable case."
- **Observation 4.6** (`prop:padding`) adjusted to match: it now excludes "legally repeatable
  complete-cutting" recurrences and explicitly lists complete-cutting cycles not known to be
  repeatable among the uncontrolled cases. The diagnostic status is unchanged.

This removes the dependence on the unproved repetition claim while preserving the rigorous
content (the two-complete-cuttings step, which uses only the zero-offset hypothesis).

## Compile
PSC_PROOF_v15.tex → 20 pp, 0 unresolved references, balanced environments (17/17).

## Final status (unchanged from the reviewer's table; now fully consistent)
| Component | Status |
|---|---|
| Defect theorem ⟹ UD | theorem-grade |
| UD for powers | theorem-grade |
| Phase automaton | diagnostic, correctly scoped (repeatable complete-cutting exclusion only) |
| Finiteness of B_σ | Hypothesis G1 |
| Local witness injectivity | theorem-grade |
| SCC Producer | main open conjecture |
| Mass-balance K₂ obstruction | theorem-grade |
| Closed-nonproductive algebraic embedding | theorem-grade |
| Alphabet-3 wedge lower bound | theorem-grade for closed wedge-nonzero SCCs |
| Existence of qualifying SCC | conditional / companion |
| Final PDS implication | conditional on G1 + SCC Producer |

## Net (six review rounds)
Rounds 1–4 each caught one genuine mathematical gap (BSW converse, padding total-run,
phase-cycle complete-cutting, open-vs-closed SCC); round 5 found only wording issues; round 6
found one diagnostic softness now removed. The manuscript is a stable conditional framework note:
\[ \mathcal B_\sigma \text{ finite} + \text{SCC Producer} \Rightarrow \text{PDS}, \]
with every result correctly labeled and every proof restricted to what it establishes. Its
strongest honest claim: UD + local hierarchy + the SCC Producer reformulation reduce PSC to G1
plus SCC productivity.

## Next work (per the reviewer — not manuscript cleanup)
Either the companion β-richness/cyclic-vector route (to discharge the existence-of-qualifying-SCC
condition) or a direct attack on SCC Producer / no diagonal-free zero-return systems.

## Deliverables
PSC_PROOF_v15.tex/.pdf (final), this changelog.
