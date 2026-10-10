# v15 scope-cleaning pass: response to second review (2026-06-13)

The second review endorsed v15's architecture (boxed B_σ finite + SCC Producer ⟹ PDS) and
asked for a scope-cleaning pass: no mixed labels. All five requested edits applied; the new
mathematical finding (the padding-bound diagonal-run gap) was verified empirically before
patching.

## Fix 1 (NEW MATHEMATICAL GAP — verified): Proposition 4.6 demoted to non-diagonal bound
Reviewer: the padding proof's pigeonhole "forces some non-diagonal phase state to recur" is
wrong — a run can enter non-diagonal then spend most of its length in diagonal phase, and long
diagonal repetition does not contradict unique decodability.
**Verified empirically:** across 200 PIP specimens, 1,070 maximal coincidence runs EXCEED the
claimed bound |A|^2|sigma|^2_max (run lengths to 305 vs bound 81, ratio 3.77). So "every
maximal coincidence run ≤ D(σ)" is FALSE as written.
- `prop:padding` restated as a **Non-diagonal padding bound**: only the non-diagonal phase
  length is ≤ D(σ). The proof is corrected to pigeonhole over the non-diagonal phase states
  only; a scope remark records that diagonal phase is unconstrained and that the old total-run
  statement is withdrawn, with the empirical excess noted.
- Abstract and intro updated: "bounds the non-diagonal phase length of coincidence padding."
- The bound is not used elsewhere (finiteness is the hypothesis G1), so the demotion is clean.

## Fix 2: internal Conditional main theorem now states G1
Reviewer: `thm:cond-main` said "Conditional on Conjecture 6.12, ... PDS" but its proof uses G1;
a reader could quote it as an unconditional-finiteness result. Fixed: the statement now reads
"Conditional on G1 (Hypothesis, finiteness of B_σ) and on Conjecture (SCC Producer), ... PDS."

## Fix 3: Theorem 6.4 rewritten as a conditional Proposition aligned with the frozen status
Reviewer: it read like a theorem while saying inside that it is theorem-grade only in Case A.
Rewritten as **Proposition**: the implication Π^σ_dom K₂|_C ≠ 0 ⟹ ρ(N_C) ≥ β|β₂| is
theorem-grade for alphabet 3; the *existence* of a qualifying recurrent noncoincident SCC (the
pure-β-zero case) is conditional on one of two auxiliary lemmas. All 11 cross-references
changed Theorem → Proposition.

## Fix 4: Section 4 retitled
"Finiteness of B_σ" → "Unique decodability, padding, and the finiteness hypothesis."

## Fix 5: cohomology power-degree caution softened
Reviewer: "β^p has the same degree as β" is not automatically safe (powers can collide /
drop degree). Softened to: "after passing to a suitable power, primitivity of the induced
component can be arranged; irreducibility of the powered incidence matrix is not needed for the
local cohomological discussion, and primitivity of Σ_C is assumed."

## Scope-label audit (the reviewer's core ask)
Every headline object now carries exactly one label:
- Finiteness of B_σ — **Hypothesis G1** (10 references, all "Hypothesis").
- Padding — **Proposition** (non-diagonal phase length only; 7 "non-diagonal" mentions).
- Main result — **boxed conditional**: B_σ finite + SCC Producer ⟹ PDS.
- Conditional main theorem — states **G1 ∧ SCC Producer**.
- Alphabet-3 spectral bound — **Proposition** (theorem-grade implication + conditional existence).
- SCC Producer — **Conjecture**.
- Cohomology §6.5 — **conditional/independent development** (leg-factor + triple-ceiling
  unconditional; cr floor under the bridge converse).
No mixed labels remain.

## Compile
PSC_PROOF_v15.tex → 19 pp, 0 unresolved references, 0 undefined citations/environments.

## What was NOT changed (reviewer-endorsed or out of scope)
- The boxed architecture, UD-via-defect, mass-balance lemmas, local witness injectivity — kept.
- §6.5 was already flagged as independent/conditional; the reviewer's suggestion to move it to a
  companion note is deferred (it is internally consistent now that the power-caution and
  converse-dependence are explicit); a future split is reasonable but not required for honesty.

## Net
v15 is now scope-clean: every result is theorem, conditional theorem, hypothesis, proposition,
conjecture, or empirical remark, with no mixed labels. The two mathematical gaps the two reviews
surfaced (finiteness-as-theorem, padding-total-run-bound) are both removed, each verified
empirically. Supersedes the prior v15; remains the canonical conditional manuscript.

## Deliverables
PSC_PROOF_v15.tex/.pdf (revised), this changelog.
