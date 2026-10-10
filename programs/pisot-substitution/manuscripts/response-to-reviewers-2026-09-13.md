# Response to the referee report

**Manuscript:** *The balanced-pair route to the Pisot substitution conjecture: finite obstructions, two open gates, and the current frontier* (`manuscripts/PSC_balanced_pair_state_2026-09-13.tex`).
**Referee report:** `manuscripts/codex-referee-report-2026-09-13.md` (Codex, review of commit `66e43cd` on pull request #65, posted 2026-09-13T03:13Z).
**Revision:** the manuscript as committed on the branch `claude/pisot-conjecture-manuscript-ax4m51` after the review, together with the recompiled PDF.

We thank the referee for a careful reading. All seven findings are accepted. Two of them (Findings 1 and 3) concern genuine overstatements in the first draft, and we are grateful that they were caught before the manuscript circulated further. The table below maps each finding to the edit made; details follow.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 1 | P1 | Concentration was described as "absorbed" although it is only equivalent to the higher-degree case | Accepted. Concentration restored as an explicit open problem; abstract, headline status, Section 5.7, the unresolved-statements list, and the discussion reworded | Abstract; §1.4 third bullet; §5.7 (new Open Problem "Concentration"); §8 items 6–8; §9 |
| 2 | P2 | "Closed" was defined too strongly for the "closed productive" cases discussed | Accepted. "Closed" now means every noncoincident child stays in the component; the equivalence "closed and nonproductive ⇔ closed with no coincidence child" is stated | Definition 2.11 |
| 3 | P1 | The claim "if \|det M\|>1 and \|C\|=3 then r ≥ 5" used ρ(S)=β without justification | Accepted. Claim removed; the three-state clause is split into the Perron-extremal case and the non-extremal case, and the unknown status of r ∈ {2,3} with ρ(S)<β is stated | Theorem 5.17 statement and proof sketch |
| 4 | P3 | f(−2) = −10, not −8 | Accepted and corrected | Example 4.8 |
| 5 | P2 | "Exhaustive enumeration at length 12" was not documented | Accepted. The word "exhaustive" and the minimality implication are removed; only the directly checkable witness is kept | Computational Proposition 6.3, limitation paragraph |
| 6 | P2 | K₂ was used both as a vector in Z^{d²} and as an element of Λ²Z³ | Accepted. The antisymmetry of K₂ on balanced pairs and the identification with (K₁₂,K₁₃,K₂₃) are stated before first use and recalled where the area identity is used | §5.5 (after the definition of K_r); Proposition 5.19(iii) |
| 7 | P2 | Placeholder citation for the Wielandt equality case | Accepted. Replaced by Horn–Johnson, *Matrix Analysis*, Thm 8.4.5; the equality-case argument now spells out the entrywise equality of the absolute value of S with N, the diagonal unitary similarity, the cycle-phase argument, and the reduction of the phases to ±1 | Proposition 5.13 proof; bibliography |

## Detailed responses

### Finding 1 (P1) — concentration

The referee is right. The wedge dichotomy (Proposition 5.20) proves: for a closed nonproductive component either K₂ ≡ 0 or the K₂ vectors span Λ²Q³, in which case the dominant projection is nonzero somewhere. This makes step (a) of the spectral route ("concentration") *equivalent* to the statement that no closed nonproductive component has K₂ ≡ 0; it does not make it automatic, because the K₂ ≡ 0 case is exactly the case the higher-degree sieves constrain without excluding. The first draft's phrase "absorbed" was therefore misleading.

Edits. (i) The abstract now says that the dichotomy shows concentration is equivalent to excluding closed nonproductive components with vanishing degree-two defect, and the final step is equivalent to excluding those with nonvanishing degree-two defect, and that both remain open. (ii) The headline status bullet in §1.4 says the same. (iii) Section 5.7 now states two open problems side by side, "Concentration" (no strict component with K₂ ≡ 0) and "Wedge productivity" (no strict component with K₂ ≢ 0), explains that (b) follows from (a) with no Galois argument, and says explicitly that we have found no proof of (a) or of (c). (iv) The unresolved-statements list (§8) has a separate "Concentration" item, and the "Higher first defects" item cross-references it. (v) The discussion no longer speaks of eliminating concentration as a gate; it says the spectral route splits the coincidence problem by first defect degree into the two open problems and that we regard this as a clarification, not progress. The referee's remark that the headline statements for G1b-2 and the Pisot substitution conjecture are accurate is noted with thanks; those statements are unchanged.

### Finding 2 (P2) — closed versus closed among noncoincident children

Accepted. Definition 2.11 now defines an SCC to be *closed* if every noncoincident child of every state lies in it, with coincidence children allowed, and records that a closed SCC is nonproductive if and only if no state in it has a coincidence child. With this definition the remark after Theorem 5.2 (closed productive components with ρ(N) < β) and Proposition 5.21 ("productive or not") are consistent, and a *strict component* (finite, closed, nonproductive, recurrent, noncoincident) has the meaning used throughout Section 5. The sink component produced in Theorem 5.1 is closed in the stronger sense as well, so that proof is unaffected; the Parikh intertwiner (Theorem 5.2) uses closedness together with nonproductivity, which is what it needs.

### Finding 3 (P1) — three-state higher-degree conclusion

Accepted. Proposition 5.13 gives diagonal similarity of S to ±N only in the Perron-extremal case ρ(S) = β, and the first draft used that similarity for |C| = 3 without the hypothesis. The sentence "if |det M| > 1 and |C| = 3 then r ≥ 5" has been removed. Theorem 5.17 now states, for |C| = 3: in the extremal case ρ(S) = β one has r ≡ 1 (mod 3), |det M| = 1, and the image of Q_r is the constituent det(M)^m ⊗ M; in the non-extremal case ρ(S) < β one has r ≡ 0 or 2 (mod 3). The proof sketch is rewritten accordingly, and it states that we do not know whether a three-state strict component can have ρ(S) < β with r ∈ {2, 3}; Theorem 5.16(ii),(iii) constrain but do not exclude those cases. The general statement "r = 4 forces |det M| = 1 and ρ(S) = β" is retained, since it uses only Theorem 5.15 and the degree-4 spectral floor and does not depend on |C|.

### Finding 4 (P3) — rational-root values

Corrected to −4, −2, −2, −10.

### Finding 5 (P2) — exhaustive enumeration

Accepted. The manuscript now presents the length-12 pair only as a directly checkable certificate that first defect degree four occurs for irreducible ternary balanced pairs, and explicitly makes no claim that the length is minimal. (Independently of the manuscript, we verified by exact computation that the displayed pair is balanced, irreducible, has vanishing defects through degree three, and has nonzero degree-four defect.)

### Finding 6 (P2) — degree-two identification

Accepted. Immediately after the definition of K_r in §5.5 the manuscript now proves that K₂ is antisymmetric on balanced pairs (K_aa = 0 and K_ab + K_ba = 0 because the two words have the same letter counts) and fixes the identification of K₂ with (K₁₂, K₁₃, K₂₃) ∈ Λ²Z³ for d = 3, noting that this is the instance Lie₂ = Λ² of Theorem 5.15 and that the identification is used in §5.6 and §5.7. Proposition 5.19(iii) recalls the identification before the equality area(u) − area(v) = 2K₂(T).

### Finding 7 (P2) — Wielandt citation

Accepted. The placeholder is replaced by Horn and Johnson, *Matrix Analysis* (Cambridge, 1985), Theorem 8.4.5, and the bibliography entry is added. The proof of Proposition 5.13 now states the equality case in full: if λ = βe^{iφ} is an eigenvalue of S of maximal modulus and |S| ≤ N with N irreducible, then |S| = N and S = e^{iφ} D N D⁻¹ for a diagonal unitary D; hence every edge sign is e^{iφ} d_i d_j⁻¹ and the sign product around a directed cycle of length L is e^{iφL} ∈ {±1}; when N is primitive the cycle lengths have greatest common divisor 1, so e^{2iφ} = 1 and e^{iφ} = ±1; since S and ±N are real with the same support and the graph is strongly connected, the phases d_i can be rescaled to ±1. This covers the three points the referee asked to be verified (irreducible N, complex peripheral phases, reduction to ζ = ±1).

## Changes made independently of the report

Before the review was received we corrected one sentence in Example 7.1: the period-3 leftmost-child cycle in the flipped-Tribonacci component runs through (12,21) → (213,312) → (1213,3121), not "the first three states" as an earlier version of this program stated; the state (13,31) has the single noncoincident child (12,21). This was verified by direct computation and does not affect any argument.

## Items not changed

No finding requested changes to the imported theorems, the computational propositions other than Finding 5, or the status statements for G1b-2 and the Pisot substitution conjecture; these are unchanged.

## Second round (re-review of `03d085a`)

The referee re-reviewed the revised head and posted two further findings; both are accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 8 | P2 | The new equivalence "closed SCC nonproductive iff no coincidence child" fails for a coincidence singleton, which is closed, has no coincidence child, and is productive | Accepted. The equivalence is restricted to closed *noncoincident* SCCs, and the coincidence-singleton case is noted explicitly | Definition 2.11 |
| 9 | P3 | Unescaped bars in the Finding 7 table row of this document broke the Markdown table | Accepted. The cell is reworded without literal bars | This document, first table, row 7 |

### Finding 8 (P2)

Accepted. Under Definition 2.11 a reachable coincidence block $(a,a)$ is a terminal singleton SCC that is closed (it has no noncoincident children) and has no coincidence child, yet is productive by the empty path. The sentence now reads: a closed *noncoincident* SCC is nonproductive if and only if no state in it has a coincidence child, with the singleton case noted in parentheses. Every later use of the equivalence (Theorem 5.1, Section 5.2, Proposition 5.20, Proposition 5.21) already carried the noncoincidence hypothesis, so no other statement changes.

### Finding 9 (P3)

Accepted; the table cell is reworded.

---

## Third round (pull request #69, G1b-1 reconstruction)

The referee reviewed the bounded-discrepancy import and posted three findings; all are accepted. None concerns the mathematics of Theorem 4.4 or Proposition 4.11.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 10 | P1 | The Python census screened the corpus with floating-point roots and a tolerance, so "exact" was overstated | Accepted. Screening is now exact: rational-root test for irreducibility and Sturm sequences over the rationals for the Pisot property, mirroring the repository's exact procedure; the corpus size and every reported statistic are unchanged | `oracles/python/swap_discrepancy_census.py` |
| 11 | P1 | Proof-support computation was Python-only, against the Mojo-first policy | Accepted. Canonical Mojo kernel, census driver and deterministic regression added; the Python layer is retained as the independent oracle and both layers agree | `kernel/psc/swap_discrepancy.mojo`, `kernel/swap_discrepancy_census.mojo`, `kernel/tests/test_swap_discrepancy.mojo`; proof note, section 6 |
| 12 | P2 | The backward direction of the realization equivalence needs the realizing windows to be cofinal; it is not definitional | Accepted. The backward direction is restated with cofinal coverage as an explicit hypothesis and a new gap (G3) records it; the gap count in the conclusion is updated | `sources/issue-45/realization-coincidence-rank-audit.md`, sections 2–3 |

### Finding 10 (P1)

Accepted. The floating-point Cardano/Newton screen with a `1e-9` margin is replaced by the exact criterion used by the canonical kernel: a monic integer cubic is irreducible iff it has no integer root dividing its constant term; it is Pisot iff Sturm counting over the rationals finds exactly one root above one and, in the three-real-root case, two roots in the open unit interval, while in the one-real-root case `beta |beta_2|^2 = det` reduces the condition to `chi(det) < 0`. The exact screen reproduces the corpus of 4,554 and the same maximum discrepancy, longest state and histogram.

### Finding 11 (P1)

Accepted. The kernel now exists in the canonical layer with a fixed three-coordinate accumulator and no floating point, and the regression pins the reduction step (blocks of an inflated seed inherit the swap-walk bound) and the example values (Tribonacci flat at 1; the level profile of the non-unimodular example up to level 18; reachable maxima 1 and 5). The Python module is kept as an independent oracle, as the policy allows, and the proof note names the Mojo implementation as canonical.

### Finding 12 (P2)

Accepted. Coincidence-freeness of windows implies coincidence-freeness of the tilings only when the windows cover every position of the pair. The audit now states the backward direction with cofinal coverage as a hypothesis, records it as gap (G3), renumbers collar completeness to (G4), and keeps the conclusion that the equivalence is a conjectural bridge.

---

## Fourth round (pull request #69)

One further finding on the realization audit; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 13 | P2 | The gap inventory omitted two forward-direction requirements named in the same note (transfer of non-coincidence to reductions; recurrence under G1), so the gap count was inconsistent | Accepted. Entries (G5) transfer of non-coincidence and (G6) recurrence added; conclusion now refers to (G0)–(G6); README and provenance summary synchronized to the seven obligations | `sources/issue-45/realization-coincidence-rank-audit.md`, section 3; `README.md`; `docs/source-provenance-v16-later-audit-2026-09-12.md` |

### Finding 13 (P2)

Accepted. The two requirements were stated in section 2 as (b) and (c) but not carried into the table, so the "with (G0)–(G4) open" conclusion under-counted. They are now (G5) and (G6), both marked open with the note that neither has ever been written down in reachable history, so there is nothing to recover; the downstream summaries say seven obligations G0–G6.

---

## Fifth round (pull request #69)

Two further findings; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 14 | P2 | The limitation paragraph of the discrepancy census called the level profile of the non-unimodular example "still increasing", although the exact computation shows the profile is bounded by the reachable maximum 5 and attains it at level 15 | Accepted. The paragraph now states the sharp fact (a swap walk splits at its zero returns into reachable states, so the level supremum never exceeds the reachable maximum, attained at level 15) and contrasts it with the far larger analytic constant, whose slow convergence is the only thing the second eigenvalue's modulus explains | Computation 6.3, limitation; proof note, section 6 |
| 15 | P2 | Claim-status rule 5 of the provenance audit still called the realization equivalence source-pending, contradicting the table row | Accepted. Rule 5 now classifies it as a conjectural bridge with the seven open obligations G0–G6 | `docs/source-provenance-v16-later-audit-2026-09-12.md`, rule 5 |

### Finding 14 (P2)

Accepted. The referee's argument is exactly the reduction step of the proof of Theorem 4.4 read in the other direction: the level-`n` supremum of a swap walk is the largest discrepancy among the depth-`n` descendants of the seed, all of which are reachable states, so for a finite automaton the profile is bounded by the maximal reachable discrepancy and, for the example in question, reaches it at level 15. The earlier sentence conflated the sharp value with the slow convergence of the analytic bound; they are now separated.

### Finding 15 (P2)

Accepted; rule 5 is rewritten to match the table and the audit note.

---

## Sixth round (pull request #69)

The referee re-reviewed the revised head and posted no findings. Findings 1–15 across the six rounds are all accepted and addressed; the review record above is complete for this revision.

---

## Seventh round (pull request #72, overlap route)

Two findings; both accepted. Neither concerns Theorem 4.22, Lemmas 5.30–5.31, or parts (i)–(v) of Theorem 5.32.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 16 | P1 | With coincidences terminal, the vertex set of the overlap graph is not "every occurring type", and the child-mass identity fails on sets containing a coincidence | Accepted. The occurrence statement is weakened to what is true: every vertex is an occurring type, every occurring non-coincidence type is a vertex, and the omitted occurring coincidences are exactly the descendants of coincidences. Corollary 5.33 now states the mass identity over the geometric children and restricts the closed-set consequence to sets of non-coincidence overlaps; the finiteness bound is restated for occurring types, which bounds the vertex count. Census counts are unchanged since the graph definition is unchanged | Section 4.7 (definition paragraph, Theorem 4.22), Corollary 5.33 and its proof; note Lemma 1.1, Theorem 2.1, Corollary 4.2 |
| 17 | P1 | "G1 becomes a consequence of PDS" does not follow from the density bridge: the imported theorem gives termination ⇒ PDS only, and G1 also involves illegal seeds | Accepted. All such sentences are replaced: a positive bridge would let PDS follow from overlap productivity for one legal seed without finiteness, but would not settle G1, whose status also depends on Open Problem 4.24 and on the unused converse of Imported Theorem 2.16 | Section 5.9 closing paragraph, headline status bullet, Section 8 item, Section 9 discussion; note section 6; README; conjecture ledger; proof ladder; pull-request description |

### Finding 16 (P1)

Accepted. The referee's Tribonacci example is exact: the coincidence `(1,1,0)` has geometric children that are the coincidences of the inflated tile, and the graph does not form them. The definition of the graph is kept (coincidences terminal, as for the balanced-pair automaton), and the statements are now those the definition supports.

### Finding 17 (P1)

Accepted. The inference reversed an implication that is used in one direction only and ignored the seedwise question; it is withdrawn everywhere it appeared.

---

## Eighth round (pull request #72)

The referee re-reviewed the revised head and posted no findings. Findings 16–17 are addressed; the record for the overlap-route revision (Theorem 4.22, Lemmas 5.30–5.31, Theorem 5.32, Corollary 5.33, Open Problems 5.34–5.35) is complete.

---

## Ninth round (pull request #77, density import)

Four findings; all accepted. None concerns Imported Theorem 5.37 or the hypothesis check preceding Theorem 5.38.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 18 | P1 | `G_m ⊆ G_{m+1}` is false as stated: subdivision points of an inflated common tile lie in the parent interior but in no child interior, and the proof of Lemma 5.36 (c)⇒(a) relied on it to pick a level `m ≥ N` | Accepted. The nesting claim is replaced by the true statement: `G_m \ G_{m'}` is finite for every `m' ≥ m` (finitely many subdivision points per level). The proof of (c)⇒(a) now picks any level `m` with `U ∩ G_m ≠ ∅`, notes that this open set is infinite, and passes to `m' = max(m, N)` by finiteness of the difference; the refinement of the inflated level-`N` tiles by the level-`m'` tilings is made explicit. (b)⇒(c) used only `G(s) ⊇ G_m(s)` and is unchanged | Section 5.9, good-set paragraph and proof of Lemma 5.36 |
| 19 | P2 | Note item 6.3, note Section 7 introduction, audit Section 7 and claim-map item 5 still call the transfer the remaining step and list a density-bridge open problem | Accepted. All four passages are rewritten: the transfer is unproved but not needed for sufficiency, the density bridge is the imported theorem, and the only open input of the route is Open Problem 5.35 | Note Sections 6 and 7; audit Section 7; claim map completion program item 5 |
| 20 | P2 | The sentence before the new material still says a positive answer to Open Problem 5.35 does not give PDS | Accepted. Replaced by: Imported Theorem 2.16 alone does not, since it needs termination; Theorem 5.38 supplies the bridge that does | Section 5.9, paragraph after Open Problem 5.35 |
| 21 | P3 | Ledger route comment still calls `DensityToPDSBridge` the separate open input | Accepted. Comment rewritten: `DensityToPDSBridge` is the imported theorem (proved) and `PDSOverlapRoute` is conditional on `OverlapProductivity` alone; TLC 10/10 PASS | `proof/tla/Ledger.tla` overlap-route comment |

### Finding 18 (P1)

Accepted. The referee is right that the sets of interiors are not nested; a common tile with two or more children loses its subdivision points at the next level. What the argument needs is weaker and true: each `G_m` differs from every later `G_{m'}` by finitely many points, so an open set meeting `G_m` meets `G_{m'}`. The lemma statement is unchanged.

---

## Tenth round (pull request #77)

Two findings; both accepted. Neither concerns the manuscript.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 22 | P2 | The note's Lemma 8.1 still asserts that the `G_m(s)` increase and its proof still picks a witnessing level at least `N` without justification | Accepted. The note now carries the manuscript's finite-difference statement and the repaired proof of (c)⇒(a) verbatim in substance | Note Section 8, good-set paragraph and proof of Lemma 8.1 |
| 23 | P2 | The probe passed the heuristic window `14 + k` to `oa_types`, below the documented bound `(g(W) + l_max)/l_min` for large length ratios, so level-0 types could be missed | Accepted. The bound is now computed exactly in `Q(β)` (`oa_window`: least `n` with `n·l_min > g(W) + l_max`, decided by exact signs) and used by default; an explicit smaller window, or a prefix too short for the window, raises (fail closed). The same heuristic (`window = 14`, `k ≤ 8`) had been used for the Section 7 sample table, so both the sample and the probe were re-run with the exact window; the recomputation reproduced every reported figure exactly (same 22 failures, same least witnesses, same type counts), and the note now states the method with the exact window | `reference/psc_research/oa_overlap_graph.py` (`oa_window`, `oa_types`, `type_inclusion_report`), both scripts, regression tests in `tests/test_oa_overlap_graph.py`; note Section 7 table and addendum |

### Finding 23 (P2)

Accepted. The referee's example is exact: for `1 → 2, 2 → 3, 3 → 133` the bound at `k = 24` is 87 against the 38 passed. Since a too-small window can only omit level-0 types, the earlier figures could over-report inclusion; they were withdrawn pending the exact-window rerun, which reproduced them exactly; they are restated with the exact method, still labelled exploratory and uncertified.

---

## Eleventh round (pull request #79)

The automated Codex review of commit `90663fb3af9c1f87f8cea7c5040e4afc90d75ecd`, containing the substantive exact-window restatement of the Section 7 figures, posted no findings. Findings 18–23 are recorded as addressed.

---

## Twelfth round (pull request #82, strong-coincidence revision)

Two findings from the automated Codex review of commit `68a392abcbccb0a874e7b090718a6d9233dab2af`; both accepted. Neither affects the identification of endpoint-aligned productivity with eventual coincidence, the hitting criterion (a)⇔(c), or the census values.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 24 | P2 | "For every ordered `i ≠ j`, `(i, j, 0)` is a seed overlap" does not match a graph seeded with one orientation per unordered pair; `(3,2,0)` is absent for `τ` | Accepted. Proposition 5.39 now states the top/bottom exchange `(a, b, t) ↦ (b, a, −t)` (commutes with inflation, preserves coincidences), fixes `(ij, ji)` as the seed of the unordered pair in the orientation used to generate the graph, and states the ordered claims for both orientations as consequences; (iii) is phrased per unordered pair. The depth API docstrings say that each pair is counted in the orientation that occurs and that the depth is orientation-independent; Computation 6.7 says so too | Proposition 5.39 and proof; Computation 6.7; `overlap_graph.py`, `overlap_seed_patch.mojo` docstrings; note Section 9 |
| 25 | P2 | Condition (b) admitted the bottom tile's right endpoint as a "boundary coincidence", where (c) fails; the example `1→2, 2→3, 3→12`, `O = (3,3,−1)`, level 1 is exact | Accepted. (b) now reads: some sub-tile of the inflated top tile and some sub-tile of the inflated bottom tile have the same left endpoint (a common boundary other than the right endpoint of either inflated tile); the proof of (a)⇔(b) is restated in terms of sub-tile left endpoints, and Corollary 5.41(iii) is restated accordingly. The propagated statements in the note, both ledgers, and the TLA ledger comment are corrected; the code measured the corrected notion already | Proposition 5.40 statement and proof; Corollary 5.41(iii); note Section 9; `docs/conjecture-ledger.md`, `docs/proof-ladder.md`; `proof/tla/Ledger.tla` comment |

### Finding 25 (P2)

Accepted. The referee's example is exact: at level 1 the bottom tile `[−1, 1]` of `(3,3,−1)` ends at the internal top boundary `1`, no bottom sub-tile starts there, and `M w = −e_2` is not a difference of proper-prefix Parikh vectors. The equivalence (a)⇔(c) was never in doubt; (b) was the wrong paraphrase of it, and the census function measured (c).

---

## Thirteenth round (pull request #82)

One finding from the automated Codex review of commit `310f06c06bdf757745cdb9c19f4e0411d20a9cd5`; accepted. It concerns the Python oracle only.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 26 | P2 | The Python depth helper returned depths on a capped partial graph, unlike the canonical Mojo kernel | Accepted. `first_depths` now raises on a capped graph (so do the coincidence, left-aligned and strong-coincidence wrappers), matching `_first_depths` and `nonproductive`; regression test on `τ` with `max_states = 1` | `reference/psc_research/overlap_graph.py`; `tests/test_swap_discrepancy.py` |

---

## Fourteenth round (pull request #82)

Two findings from the automated Codex review of commit `3dc397856ab8ceaf0298c34c3e1df8855e612f10`; both accepted. Both concern the census driver; no census value changes.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 27 | P2 | A nonproductive graph would raise in the depth validations before being counted, so a counterexample would surface as `FAILED` with the nonproductive count still zero | Accepted. The driver now records and prints a nonproductive specimen immediately after the productivity check and skips the depth statistics for it, which are undefined on such a graph | `kernel/swap_overlap_census.mojo` |
| 28 | P2 | The prefix and suffix strong-coincidence scans each recomputed the coincidence depths, three reverse searches per graph | Accepted. `strong_coincidence_depth_from(depths, ...)` takes the precomputed vector (length-checked); `strong_coincidence_depth` wraps it; the census passes the one vector it already holds. The Python oracle takes an optional `depths` argument likewise. Census lines unchanged | `kernel/psc/overlap_seed_patch.mojo`, `kernel/swap_overlap_census.mojo`, `kernel/tests/test_overlap_seed_patch.mojo`, `reference/psc_research/overlap_graph.py`, `oracles/python/overlap_depth_census_oracle.py` |

---

## Fifteenth round (pull request #82)

Two findings from the automated Codex review of commit `2288163613668619be3185e97b1474ca059f3dc2`; both accepted. Both concern the Mojo census path; no census value changes.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 29 | P2 | `strong_coincidence_depth_from` accepted a capped automaton with a length-matching vector | Accepted. It now raises on a capped automaton before consuming the depths, like `_first_depths`; regression test with a capped graph | `kernel/psc/overlap_seed_patch.mojo`, `kernel/tests/test_overlap_seed_patch.mojo` |
| 30 | P2 | The census rebuilt the exact tables for the endpoint scans after `build_seed_overlap_graph` had built them | Accepted. `build_seed_overlap_graph_from_tables(tables, cap)` is the builder; `build_seed_overlap_graph(sigma, cap)` wraps it; the census builds the tables once per specimen and passes them to the graph construction and both scans | `kernel/psc/overlap_seed_patch.mojo`, `kernel/swap_overlap_census.mojo` |

---

## Sixteenth round (pull request #87, contracting bound)

Three findings from the automated Codex review of commit `3b8e6d42acfac4c1d9c23abe6f5190e6656e0ce8`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 31 | P1 | The contracting-bound kernel and census existed only in the Python layer | Accepted. Canonical Mojo implementation: `kernel/psc/real_root_sign.mojo` (exact Sturm–Tarski queries over unbounded rationals: root counting, isolation, sign at an isolated root) and `kernel/psc/overlap_contracting.mojo` (field norm, discriminant, increment set, `ContractingBound.least_level`, capped graphs rejected; all field arithmetic in Q[x]/(χ) over unbounded rationals with every sign a Sturm–Tarski query at an isolated root, the Perron root included, since the fixed-width Perron oracle fails closed on the coefficient growth of the level tests); `kernel/tests/test_overlap_contracting.mojo` pins the same values as the Python oracle; `kernel/overlap_contracting_census.mojo` is the census driver, asserted line by line in CI; the Python module is the oracle and prints the same nine summary lines (without the specimen-count header) | `kernel/psc/real_root_sign.mojo`, `kernel/psc/overlap_contracting.mojo`, `kernel/tests/test_overlap_contracting.mojo`, `kernel/overlap_contracting_census.mojo`, `kernel/pixi.toml`, `.github/workflows/ci.yml` |
| 32 | P1 | "Dominated by a scale-free combinatorial part" and "cannot come from a contraction argument" do not follow from `b ≥ m_0`, since the excess includes the slack of the triangle and Cauchy–Schwarz steps | Accepted. Every such sentence is replaced by the statement the executable result supports: this magnitude bound accounts for at most 7 of the up to 17 inflations and leaves a gap of up to 14, the gap includes the slack of the bound, and whether a sharper contracting-space argument explains part of it is not decided | Computation 6.7 "Meaning"; note Section 10; `docs/conjecture-ledger.md`, `docs/proof-ladder.md`, `README.md`, `docs/README.md`; pull-request description |
| 33 | P1 | `N(c)/c` and `N(t)/t` are undefined at the zero increment and at offset-zero vertices, while the code excluded them silently | Accepted. Proposition 5.42 now defines `m_0(0) = 0` separately, states the complex-pair display for `t ≠ 0`, and takes `K` over `F \ {0}` (the zero increment contributes nothing to `C_ς`); the proof and the note say the same, and both implementations match the statement | Proposition 5.42 statement and proof; note Section 10 |

---

## Seventeenth round (pull request #87, canonical-implementation revision)

Two findings from the automated Codex review of commit `7d74aa42c3ce138afe85b332b4964e30f58dacd2`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 34 | P1 | The rational Horner evaluator lived in `real_root_sign.mojo` instead of the designated adapter | Accepted. `eval_q_poly_at_q` now lives in `kernel/psc/exact.mojo` next to the integer Horner helper; `real_root_sign.mojo` imports it and keeps only polynomial algebra (trim, derivative, product, remainder) and the Sturm–Tarski queries | `kernel/psc/exact.mojo`, `kernel/psc/real_root_sign.mojo` |
| 35 | P1 | The complex-pair test decided the Cauchy–Schwarz relaxation `N(t)/t ≤ K m Σ ρ^s`, which is one-way, so the census was not a census of the stated `m_0` (example: `1→2, 2→33, 3→213`, offset `(−8, −2, 5/2)`: relaxation 5, defining inequality 6) | Accepted. Both implementations now decide the defining inequality exactly: with `ρ = β/D`, `(Σ_{s≤m} ρ^{s/2})² = A_m + ρ^{1/2} B_m` with `A_m, B_m ∈ Q(β)` (`n_k = min(k−1, 2m+1−k)` pairs), so `N(t)/t ≤ K(A_m + ρ^{1/2}B_m)` iff `N(t)/t ≤ K A_m`, or `N(t)/t > K A_m` and `(N(t)/t − K A_m)² ≤ K² ρ B_m²`: at most two sign tests at `β`, no relaxation. Proposition 5.42 and its proof state this formulation; every mention of Chebyshev or Cauchy–Schwarz is removed from statement, proof, "Meaning", note Section 10, and both implementations. The referee's example is pinned in both regression suites (`m_0 = 6`), and the census was rerun with the exact test in both implementations and repinned in CI, Computation 6.7, the note, the ledgers, and the READMEs (the largest `m_0` rises from 7 to 8, attained on 12 vertices of 6 substitutions; the largest excess stays 14; the totally real specimens are unchanged) | Proposition 5.42 statement and proof; Computation 6.7; note Section 10; `kernel/psc/overlap_contracting.mojo`, `reference/psc_research/overlap_contracting.py`, `kernel/tests/test_overlap_contracting.mojo`, `tests/test_oa_overlap_graph.py`, `.github/workflows/ci.yml` |

---

## Eighteenth round (pull request #87, exact-test revision)

One finding from the automated Codex review of commit `0b989e0ccc07d5690d5413e16fc8fe07484dd590`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 36 | P2 | `B_1 = 0`, so "`A_m` and `B_m` positive at `β`" is false for `m = 1` | Accepted. The statement now reads "`A_m > 0` and `B_m ≥ 0` at `β` (`B_1 = 0`)"; the proof already used only `ρ^{1/2} B_m ≥ 0`; the note says the same | Proposition 5.42 statement; note Section 10 |

---

## Nineteenth round (pull request #87, nonnegativity revision)

One finding from the automated Codex review of commit `059c4c5536cc4f0f9252a55a628ca90e7ea0bdf4`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 37 | P1 | `least_level` rebuilt the level tables `A_m`, `B_m` (complex pair) and the β-powers and `G_m` (real conjugates) for every shift and level, although they depend only on the substitution | Accepted. The constructor now builds `A_m`, `B_m` for `m ≤ max_level` (complex pair) and `β^m`, `G_r[m]` (real conjugates) once per substitution; `least_level` indexes them. The Python oracle precomputes `A_m`, `B_m` the same way (its real branch already did). Census rerun: identical lines | `kernel/psc/overlap_contracting.mojo`, `reference/psc_research/overlap_contracting.py` |

---

## Twentieth round (pull request #87, level-table revision)

The automated Codex review of commit `eb0615f609` posted no findings. Findings 31–37 are recorded as addressed.

---

## Twenty-first round (pull request #92, obstruction normal form)

One finding from the automated Codex review of commit `e61628428e`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 38 | P2 | Proposition 5.44(ii) called the forward-invariant aligned-pair sets "unions of cycles", which forward invariance does not give | Accepted. The statement now says that every orbit under the first-/last-letter map is eventually periodic and stays in the set, so a nonempty `A_±(S)` contains a cycle of pairs of distinct letters; the proof cites eventual periodicity of forward orbits under a self-map of a finite set together with forward invariance; the sentence after the proposition says the same | Proposition 5.44(ii) and proof; following paragraph |

---

## Twenty-second round (pull request #92, forward-invariance revision)

The automated Codex review of commit `4e68dcdc7d` posted no findings. Finding 38 is recorded as addressed.

---

## Twenty-third round (pull request #92, manuscript-source guard)

Two findings from the automated Codex review of commit `d2adbb9b97`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 39 | P2 | A PDF truncated after its `%PDF-` header passed the guard | Accepted. The guard now requires `%%EOF` within the last 1024 bytes, a `startxref` offset before the final `%%EOF`, and that the offset lies inside the file and points at an `xref` table or a cross-reference stream object; tests cover a header-only PDF and a bad `startxref` | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 40 | P2 | Missing or renamed manuscript files passed silently; an empty directory reported success | Accepted. `manuscripts/MANIFEST` lists the required files; the guard fails on a missing manifest, an empty manifest, any listed file that is absent, and a manifest without a `.tex` and a `.pdf`; tests cover a deleted PDF and an empty directory | `manuscripts/MANIFEST`, `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |



---

## Twenty-fourth round (pull request #95, hardened guard)

Two findings from the automated Codex review of commit `be9dfc3abf`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 41 | P2 | `PSC_PROOF_next_source_audit.tex` is tracked but was absent from the manifest, so deleting it passed | Accepted. Added to `manuscripts/MANIFEST` | `manuscripts/MANIFEST` |
| 42 | P2 | An in-range `startxref` pointing at any ordinary object passed | Accepted. When the offset points at an object, its dictionary must contain `/Type /XRef`; a test rewrites the offset to an ordinary object and expects failure | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |


---

## Twenty-fifth round (pull request #95, manifest and XRef revision)

Two findings from the automated Codex review of commit `ea83b495c5`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 43 | P2 | With several trailers in the last 1024 bytes the guard validated the first, not the one before the final `%%EOF` | Accepted. The guard locates the final `%%EOF`, takes the last `startxref` before it, and requires the text between them to be exactly the offset; a test appends a corrupt trailer after the valid one and expects failure | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 44 | P2 | An XRef-typed object without a stream body passed | Accepted. An object-pointing offset must lead to a dictionary containing `/Type /XRef` followed by a `stream` keyword and a later `endstream`; a classic `xref` table must be followed by `trailer`; a test builds a PDF whose only object is XRef-typed with no stream and expects failure | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |


---

## Twenty-sixth round (pull request #95, trailer revision)

Two findings from the automated Codex review of commit `c6032e3dad`; both accepted. The guard now parses the cross-reference structure instead of matching delimiter tokens.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 45 | P2 | A classic table was accepted from the bare `xref` and `trailer` keywords | Accepted. The table is parsed: `xref`, one or more `start count` subsections, exactly `count` entries of 20 bytes matching `nnnnnnnnnn ggggg n/f`, at least one entry in total, then `trailer` and a dictionary containing `/Size` and `/Root`; tests cover a minimal valid classic PDF and the entryless one | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 46 | P2 | An empty or corrupted cross-reference stream body was accepted | Accepted. The stream dictionary must contain `/Type /XRef`, `/Size`, `/Root`, `/W` and a direct `/Length`; the body must have exactly `/Length` bytes followed by `endstream`; a Flate body must inflate (other filters fail closed); the payload must be a positive multiple of the `/W` row width (plus one under a PNG predictor); tests cover an empty stream and a one-byte mutation of the repository PDF's compressed payload | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |


---

## Twenty-seventh round (pull request #95, structural parser)

Three findings from the automated Codex review of commit `3a9d53ee10`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 47 | P2 | `/Length 4 0 R` was read as the direct length 4 | Accepted. The `/Length` token is parsed with an optional trailing `g R` group, and an indirect reference fails explicitly; test with `/Length 4 0 R` | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 48 | P2 | Only divisibility of the payload by the row width was checked, not the declared row count | Accepted. The number of rows must equal the sum of the `/Index` subsection counts, or `/Size` without `/Index`; tests with `/Size 100` and `/Index [0 3]` against a one-row payload, and a passing one-row stream | same |
| 49 | P2 | The array form `/Filter [/FlateDecode]` was not recognized | Accepted. `/Filter` is parsed as a name or an array of names; the chain must be exactly `[FlateDecode]`, any other form or chain fails closed; tests inflate an array-form Flate stream and reject `[/LZWDecode]` | same |


---

## Twenty-eighth round (pull request #95, length, row-count and filter revision)

Four findings from the automated Codex review of commit `a9242e36aa`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 50 | P2 | A file truncated right after `endstream` passed | Accepted. The stream must be closed by `endstream` followed by `endobj`; test truncates after `endstream` | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 51 | P2 | `/Index` start values and odd-length arrays were ignored | Accepted. `/Index` must be a nonempty array of start/count pairs with positive counts whose ranges lie within `/Size`; tests with `[999 1]`, `[0 1 2]`, `[0 0]` | same |
| 52 | P2 | `/W [4]` was accepted as a row width | Accepted. `/W` must have exactly three fields; test with `/W [4]` | same |
| 53 | P2 | Classic in-use entries were checked only for their textual shape | Accepted. Every `n` entry must point inside the file at the header `num gen obj` of its own object number (subsection start plus index) and generation; tests alter the offset to 8 and to 9999999999 and the generation to 1 | same |


---

## Twenty-ninth round (pull request #95, endobj, index, arity and entry revision)

Two findings from the automated Codex review of commit `9256ace9d9`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 54 | P2 | A classic subsection could exceed the trailer's `/Size` | Accepted. `/Size` is parsed and every subsection must satisfy `start + count ≤ /Size`; test changes the minimal classic fixture's `/Size 2` to `/Size 1` | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 55 | P2 | Cross-reference stream rows were counted but not decoded | Accepted. Every row is decoded per `/W` (type defaulting to 1 when the first field is absent); type-1 entries must point inside the file at the header `num gen obj` of their object, type-2 entries must name an object stream below `/Size`, other types fail; PNG row prediction (filters 0–4) is undone first, an unknown filter fails; tests cover an out-of-file offset, a wrong offset, an unknown type, an out-of-range object stream, and a predicted stream that decodes correctly; the passing fixtures now describe object 1 at its real offset | same |


---

## Thirtieth round (pull request #95, subsection-range and row-decoding revision)

Three findings from the automated Codex review of commit `f158aab509`; all accepted. Each is another part of the cross-reference format that the hand-written structural checks did not model, so the guard now also parses the whole file with a real PDF parser (pypdf 6.1.3, strict mode, pinned as a dev dependency and installed in the provenance CI job), dereferences every object including object-stream members, and reads the page tree; the structural checks stay in front of it because the parser repairs some offset and `/Size` mangling silently. A missing parser is a failure, not a skip.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 56 | P2 | `/Prev` chains were not followed | Accepted. The full parse follows `/Prev`; test adds `/Prev 999999` to a complete classic PDF and expects failure | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py`, `pyproject.toml`, `.github/workflows/ci.yml` |
| 57 | P2 | A type-2 entry was accepted on the numeric bound alone | Accepted. The full parse resolves every object-stream member; test points object 1 at the page-tree object as its container and expects failure | same |
| 58 | P2 | Predictor parameters were not validated | Accepted. The full parse validates the predictor and its geometry; tests with `/Predictor 99` and `/Columns 999` expect failure, and a correct predictor-12 stream passes | same |
\n


---

## Thirty-first round (pull request #95, full-parse revision)

Two findings from the automated Codex review of commit `22716cd7a0`; both accepted. Both were verified before the fix: on the repository PDF the highest object number is 1132 against `/Size 1133`, and pypdf's decoder returns empty data, without raising, on a Flate payload with one flipped byte.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 59 | P2 | An oversized `/Size` was accepted | Accepted. `/Size` must equal one more than the highest object number reachable through the whole cross-reference chain (type-1 and type-2 entries alike); tests inflate `/Size` to 99 on a complete classic PDF and on a cross-reference stream with a consistent `/Index` and expect failure | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 60 | P2 | Ordinary streams were dereferenced but not decoded | Accepted. Every stream object is decoded: the filter chain must be empty or exactly `/FlateDecode`, a Flate body must inflate with zlib to the end of the deflate member with no trailing bytes, and pypdf's decode (with predictors) is then applied; test flips one byte in the first content stream of the repository PDF, leaving offsets and lengths intact, and expects failure | same |


---

## Thirty-second round (pull request #95, exact-extent and stream-decoding revision)

One finding from the automated Codex review of commit `7d557ac9f8`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 61 | P2 | A free highest-numbered entry made a valid file fail the `/Size` check | Accepted. The structural stage now walks the whole cross-reference chain along `/Prev` (an out-of-file offset or a revisited offset fails) and returns the highest object number over every entry of every section, free entries and type-0 rows included; the full-parse stage compares `/Size` with one more than the larger of that extent and pypdf's in-use maximum, so an oversized `/Size` still fails. Tests: a classic table with objects 1–3 in use, object 4 free and `/Size 5` passes; a cross-reference stream with a trailing type-0 row and `/Size 6` passes; a cyclic `/Prev` fails; an incremental update rewriting only object 1, whose `/Size 4` is justified by the original section, passes | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |


---

## Thirty-third round (pull request #95, chain-extent revision)

Two findings from the automated Codex review of commit `7ec39a90c0`; both accepted. The section parsers now return their entry tables instead of a bare extent, and the chain walk merges the sections newest-first before checking invariants that span the whole table.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 62 | P2 | Free entries were checked for shape only | Accepted. A free entry's pointer must be an object number below `/Size` and its generation at most 65535 (classic tables and type-0 rows alike; a saturated narrow generation column in a stream stands for 65535, as in the repository PDF's one-byte column). On the merged table, object 0 must be free with generation 65535 and head a chain of free entries that returns to object 0 and covers every free entry. Tests: an out-of-range pointer on a classic table and on a stream row; object 0 with generation 0; a free object 4 that object 0 does not link; object 0 pointing at an in-use object; the passing free-top fixtures now link object 4 from object 0 | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 63 | P2 | A zero-count subsection inflated the extent | Accepted. A zero-count subsection fails ("empty xref subsection"), and the extent is now the highest key of the merged entry table, so no phantom object number can enter it; test appends `9999 0` with `/Size 9999` and expects failure | same |


---

## Thirty-fourth round (pull request #95, free-list revision)

Two findings from the automated Codex review of commit `30d16e00e8`; both accepted, the second with one qualification grounded in the repository PDF itself. Every entry now records whether it came from a classic table or from a cross-reference stream.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 64 | P2 | Unlinked free entries in a cross-reference stream were rejected | Accepted. Full free-list coverage is required only of entries that came from a classic table; a stream type-0 entry may be unlinked provided its next-free field is 0, while an unlinked entry pointing elsewhere still fails. The chain from object 0 must still consist of unvisited free entries and return to 0. Tests: the reviewer's example (a free object 5 with fields `(0, 0, 0)`) passes; the same entry pointing at object 3 fails | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 65 | P2 | A saturated one-byte generation column was rescaled to 65535 | Accepted: the decoded generation is kept unchanged, and a stream free entry with generation above 65535 fails. Qualification: the requirement that object 0 carry generation 65535 is stated by the standard for classic tables only, and the repository PDF (pdfTeX, `/W [1 3 1]`) encodes object 0 as type 0 with a one-byte generation of 255, so the guard requires 65535 of object 0 only when its entry comes from a classic table. Tests: a two-byte column holding exactly 65535 passes; a three-byte column holding 65536 fails; a classic object 0 with generation 0 still fails | same |


---

## Thirty-fifth round (pull request #95, provenance revision)

Three findings from the automated Codex review of commit `99cc3be753`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 66 | P2 | Free-list coverage was judged on the final merged table | Accepted. The chain walk now collects the sections and replays them oldest first, validating the free list on the effective table at each section, since every prefix of the chain was once a complete file. At a classic section every free entry must be on the chain from object 0; at a stream section a free entry off the chain may point at 0 or at another free entry but never at an object in use. Test: the reviewer's mixed chain (a classic table whose object 0 links a free object 4, then a stream section replacing object 0 with an unlinked row) passes | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 67 | P2 | A huge `/Size` or `/Index` count materialized object numbers before any comparison | Accepted. The declared row count is computed arithmetically, the Flate payload is inflated with a ceiling of one byte past the declared size and must end the deflate member exactly there, and object numbers are materialized only after the payload's row count equals the declaration. Test: `/Size 1000000000` and `/Index [0 1000000000]` against a one-row payload fail immediately with "declares 1000000000" | same |
| 68 | P2 | The generation bound covered free rows only | Accepted. The bound of 65535 is applied before branching on the entry type, for classic entries and stream rows alike. Tests: an in-use classic entry with generation 65536 and an in-use stream row with a three-byte generation of 65536 both fail | same |


---

## Thirty-sixth round (pull request #95, per-section revision)

Three findings from the automated Codex review of commit `f89f2b61d7`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 69 | P2 | A matching compression bomb could still exhaust the runner | Accepted. A declared row count above 1 000 000 (the repository PDF has 1133 objects) fails before any inflation, and every stream decoded in the full-parse stage is inflated with a ceiling of 64 MiB (the largest decoded stream in the repository PDF is 34 KB). Test: two million all-zero rows, compressed to a few kilobytes, with a matching `/Size 2000000` fail with "above the ceiling" | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 70 | P2 | A classic trailer's `/XRefStm` companion stream was not walked | Accepted. A classic section names its `/XRefStm` offset; the companion stream is parsed as a section (in the file, not revisited) and merged beneath the table's own entries, and the combined section is validated under the classic rule with the per-entry provenance deciding which free entries must be linked. Tests: a hybrid file whose companion describes itself and an unlinked free object 5 passes; the same file with the companion's free row pointing beyond `/Size` fails, naming `/XRefStm` | same |
| 71 | P2 | Only the final trailer's `/Size` was compared with the extent | Accepted. Every section carries its trailer `/Size`, and during the oldest-first replay each section's `/Size` must be one more than the highest object number of its effective table. Test: an original section covering objects 0–3 with `/Size 5`, followed by an update adding object 4 with `/Size 5`, fails at the original section | same |


---

## Thirty-seventh round (pull request #95, ceiling and hybrid revision)

Three findings from the automated Codex review of commit `a76630a9ed`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 72 | P2 | The `/XRefStm` companion's own `/Size` was discarded | Accepted. A hybrid section carries both the trailer's `/Size` and the companion's, and the replay checks each against the section's effective table. Test: the hybrid fixture with the companion's `/Size` changed to 7 fails | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 73 | P2 | A historical in-use entry could point into a later revision | Accepted. Every section records the offset just past itself; its in-use entries must point before the `startxref` that closes its revision, since an object appended by a later update did not exist when the section was written. Test: the original section's entry for object 3 is redirected to the copy of object 3 that a later update appends (matching header, superseded in pypdf's view) and fails "beyond the end of its revision"; the same file with the entry intact passes | same |
| 74 | P2 | The row ceiling did not bound decoded bytes | Accepted. The declared decoded size `rows × row width` must not exceed 64 MiB before zlib is called. Test: `/Size 1 /W [1 1000000000 1]` fails with "decoded bytes, above the ceiling" | same |


---

## Thirty-eighth round (pull request #95, revision-bound revision)

Two findings from the automated Codex review of commit `273d95fb7d`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 75 | P2 | A stream superseded by a later revision was never decoded | Accepted. After the replay, every in-use entry that the effective table supersedes is inspected structurally: if its object is a stream, the body must have a direct `/Length`, be closed by `endstream`, carry no filter or exactly `/FlateDecode`, and inflate strictly within the 64 MiB ceiling. Test: an original revision whose content stream is replaced by an update passes intact and fails with "superseded stream object 4 does not inflate" once a byte of the old body is flipped | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 76 | P2 | A historical entry could point into its own trailer region | Accepted. An in-use entry must now point before its own cross-reference section (a cross-reference stream may point at its own object), since objects precede the section that lists them. Test: the original section's entry for object 3 is redirected to a `3 0 obj` text embedded in that section's trailer while a later update supersedes object 3; it fails "not before its cross-reference section" | same |


---

## Thirty-ninth round (pull request #95, superseded-stream revision)

Three findings from the automated Codex review of commit `bb3f62c23f`; all accepted. All three concern the superseded-stream inspection added in the previous round, which now applies the same discipline as the cross-reference stream parser.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 77 | P2 | An unparsable `/Filter` on a superseded stream counted as no filter | Accepted. A present `/Filter` that is not a name or an array of names fails ("unparsable /Filter"). Test: `/Filter 9 0 R` | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 78 | P2 | `/DecodeParms` on a superseded stream were not validated | Accepted. `/DecodeParms` must be a direct dictionary (or a one-element array of one) with `/Predictor` 1, 2 or 10–15 and positive geometry; for a PNG predictor the inflated length must be a whole number of rows of the declared width, each carrying a known row filter. Tests: `/Predictor 12 /Columns 4` on a matching payload passes; `/Predictor 99`, `/Predictor 12 /Columns 999` and an indirect `/DecodeParms 7 0 R` fail | same |
| 79 | P2 | A superseded stream needed only `endstream` | Accepted. The body must be closed by `endstream` followed by `endobj`. Test: the superseded object's `endobj` token altered | same |


---

## Fortieth round (pull request #95, superseded-stream discipline revision)

Three findings from the automated Codex review of commit `7394ee76d2`; all accepted. Finding 82 also applied to the cross-reference stream parser, which used the same prefix match, so both now share one PDF name parser.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 80 | P2 | TIFF predictor 2 skipped the geometry check | Accepted. For predictor 2 the inflated length must be a whole number of rows of `⌈Columns × Colors × BitsPerComponent / 8⌉` bytes; PNG predictors keep the extra filter byte per row. Tests: `/Predictor 2 /Columns 4` on eight bytes passes; `/Predictor 2 /Columns 999` on one byte fails | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 81 | P2 | A superseded object whose `stream` keyword was malformed counted as a non-stream | Accepted. A superseded object must be a dictionary followed by `stream` or by `endobj`, or a non-dictionary object closed by `endobj` before any other object header; anything else fails. Test: `stream` changed to `streaX` | same |
| 82 | P2 | Filter names were matched as a prefix, ignoring `#xx` escapes and delimiters | Accepted. A shared name parser reads whole PDF names (any character other than whitespace, delimiters and `#`, or a `#xx` escape), decodes the escapes, and requires a delimiter after the name; the `/Filter` key itself must be delimited. Tests: `/FlateDecode#58` fails as unsupported in a superseded stream and in the cross-reference stream, `/FlateDecode#5` fails as unparsable, and `/Flate#44ecode` (an escaped `D`) passes | same |


---

## Forty-first round (pull request #95, whole-name revision)

Three findings from the automated Codex review of commit `f427597e50`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 83 | P2 | Type-2 entries were bounded by `/Size` only, and superseded ones never resolved | Accepted. During the oldest-first replay every type-2 entry of a section is resolved against that revision's effective table: the container must be an in-use object whose dictionary is `/Type /ObjStm` with a direct `/N` above the entry's index. Tests: an uncompressed object stream holding one member passes; index 1 against `/N 1` fails; a container that is the page tree fails, and still fails when a later classic update supplies the member in use | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 84 | P2 | A malformed predictor field fell back to its default | Accepted. A present predictor field must be a whole nonnegative integer followed by a delimiter; anything else fails ("malformed predictor parameter value"). Tests: `/Predictor /Bogus` and `/Columns -1` | same |
| 85 | P2 | A non-dictionary superseded object was accepted on `endobj` alone | Accepted. A small direct-object parser (dictionary, array, literal and hex strings, name, number, boolean, null, indirect reference) must consume exactly one complete object, which `endobj` must then close. Tests: a nested array of every primitive passes; `not-a-PDF-object` and an unclosed array fail | same |


---

## Forty-second round (pull request #95, one-object-parse revision)

Three findings from the automated Codex review of commit `026cdcd882`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 86 | P2 | Dictionaries were accepted on bracket balance alone | Accepted. Every dictionary the guard reads (trailers, cross-reference and object stream dictionaries, `/DecodeParms`, superseded objects) is now parsed as name keys each followed by one complete direct value. Tests: a dictionary holding an array, a nested dictionary, strings, a boolean, an escaped name and null passes; `<< /Type >>`, `<< garbage >>`, a key without a value and a non-name key fail. A `/Filter` name with a truncated escape now fails at the dictionary itself | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 87 | P2 | A type-2 entry was not matched to the object stream's header member | Accepted. Each object stream named by a type-2 entry is decoded once per byte offset (direct `/N`, `/First` and `/Length`, unfiltered or Flate body inflated strictly, `/DecodeParms` validated, header of exactly `/N` integer pairs with offsets inside the data), and the entry's index must select a member whose object number is the entry's own. Test: member header `9 0` for object 5 fails, and still fails when a later classic update supplies object 5 | same |
| 88 | P2 | An older trailer's `/Root` was never resolved | Accepted. Every section's `/Root` (and a hybrid companion's) must resolve, in that revision's effective table, to an object in use with the referenced generation whose dictionary is `/Type /Catalog`, a compressed root being looked up in its decoded object stream. Tests: `/Root 9 0 R`, `/Root 2 0 R` (the page tree) and `/Root 1 1 R` in the original trailer fail. The repository PDF's own root, a compressed object, resolves | same |


---

## Forty-third round (pull request #95, structural-dictionary revision)

Three findings from the automated Codex review of commit `b4a3799157`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 89 | P2 | Compressed members were located but not parsed | Accepted. When an object stream is decoded, every member is parsed as one complete direct object that ends, up to whitespace, before the next member offset or the end of the data; a type-2 entry (or a compressed root) whose member fails this is rejected. Test: a member body `not-a-object` fails, and still fails when a later revision supplies the member directly | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 90 | P2 | The catalog and object-stream type checks scanned raw dictionary bytes | Accepted. Dictionaries are parsed into their top-level items (decoded key to raw value), and `/Type`, `/N`, `/First`, `/Length`, `/Filter` and `/DecodeParms` are read from those items; a nested `/Type /Catalog` no longer counts. Test: the reviewer's root `<< /Pages 2 0 R /Foo << /Type /Catalog >> >>`, later replaced by a valid catalog, fails | same |
| 91 | P2 | Inherited type-2 rows were not revalidated after their container was replaced | Accepted. At every section of the replay all effective type-2 rows are resolved against that revision's table, and object streams are cached by byte offset so a replaced container is decoded anew. Test: a three-revision chain in which the second revision replaces the container with one whose member is object 9 fails at that revision, and still fails after a third revision supplies object 5 directly | same |


---

## Forty-fourth round (pull request #95, member-parse revision)

Two findings from the automated Codex review of commit `b961e70914`; both accepted. Finding 92 was applied to the cross-reference stream dictionary as well as the classic trailer, so both section parsers now read every key from top-level items.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 92 | P2 | Trailer keys were found by scanning the serialized dictionary | Accepted. `/Size`, `/Root`, `/Prev` and `/XRefStm` of a classic trailer, and `/Type`, `/Size`, `/Root`, `/Prev`, `/W`, `/Index`, `/Length`, `/Filter` and `/DecodeParms` of a cross-reference stream, are read from the dictionary's top-level items; a present `/Prev` or `/XRefStm` must be a whole integer. Tests: the reviewer's trailer `<< /Size 4 /Foo << /Root 1 0 R >> >>` followed by a valid update fails, and the same nesting in a cross-reference stream dictionary fails | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 93 | P2 | Overlapping member offsets let one object count as two members | Accepted. Member offsets must be strictly increasing before the members are parsed against their bounds. Tests: a header `5 0 7 13` over two objects passes; `5 0 7 0` fails | same |


---

## Forty-fifth round (pull request #95, top-level-keys revision)

Three findings from the automated Codex review of commit `dff1e3ac05`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 94 | P2 | A superseded stream's `/Length` was still found by a recursive regex | Accepted. It is read from the dictionary's top-level items and must be a whole nonnegative integer. Tests: a nested `/Length` and `/Length 1.5` both fail | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 95 | P2 | Predictors were validated but not undone before an object stream's header was parsed | Accepted. The decode-parameter validator now returns the unpredicted bytes (PNG predictors 10–15 via the row unfilter, TIFF predictor 2 by undoing horizontal differencing at 8 bits per component, other depths failing closed), and object streams read their header and members from those bytes. Tests: object streams predicted with `/Predictor 12` and with `/Predictor 2` pass end to end | same |
| 96 | P2 | `/Index` ranges could overlap or descend | Accepted. Consecutive ranges must be in increasing order and disjoint. Tests: `[0 3 1 1]` and `[2 1 0 2]` fail | same |


---

## Forty-sixth round (pull request #95, predictor and index revision)

Three findings from the automated Codex review of commit `b084115186`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 97 | P2 | A repeated dictionary key kept the last value | Accepted. The dictionary parser rejects a repeated decoded key, so every dictionary the guard inspects fails closed on duplicates. Test: a superseded stream with two `/Length` keys | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 98 | P2 | A forward `/Prev` inverted the replay chronology | Accepted. A section's `/Prev` and `/XRefStm` must point before the section itself; a forward or self-pointing link is rejected before it is followed. Test: the final `startxref` names section A whose `/Prev` points forward at section B; the earlier bogus and self-pointing `/Prev` cases now fail at this check | same |
| 99 | P2 | Overlapping classic subsections overwrote rows | Accepted. Each subsection is checked against the accumulated ranges before its entries are decoded. Test: a `1 1` subsection appended to a table that already covers object 1 | same |


---

## Forty-seventh round (pull request #95, chronology revision)

Three findings from the automated Codex review of commit `caf7c77d0d`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 100 | P2 | The hybrid companion's own `/Prev` was discarded unchecked | Accepted. A companion's `/Prev`, if present, must be the classic trailer's own earlier `/Prev`; anything else (forward, self-pointing, or inconsistent with the trailer) fails. Tests: companions carrying `/Prev 999999` and `/Prev 0` under a trailer without `/Prev` | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 101 | P2 | An object stream could declare the same object twice | Accepted. The header's object numbers must be unique. Test: header `5 0 5 13` | same |
| 102 | P2 | A historical catalog was accepted on its type alone | Accepted. Every section's root is now resolved through a reference resolver over that revision's effective table (in-use objects at their offsets with matching generation, compressed objects as decoded members), and its `/Pages` reference must head a consistent, nonempty page tree: the root a `/Pages` node, every node's `/Kids` an array of references each naming the node as `/Parent`, every `/Count` equal to the pages beneath, no cycles and at most 64 levels. Tests: historical catalogs with `/Pages 9 0 R`, with `/Pages` naming a page rather than the root node, and without `/Pages`, each later repaired by an update, all fail; a `/Count 2` over one page later repaired fails. The repository PDF's own tree of 36 pages walks cleanly | same |


---

## Forty-eighth round (pull request #95, page-tree revision)

Four findings from the automated Codex review of commit `bddda784b3`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 103 | P2 | An object-stream member with no type-2 row went unexamined | Accepted. For every object stream that a section itself introduces, each header member must be listed by a type-2 entry naming that container and index in the section's revision; a later revision may still replace a member by a direct object, which is the legitimate incremental-update pattern. Test: the reviewer's second member numbered 4 while object 4 is the container | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 104 | P2 | Older revisions were not required to end with their own terminator | Accepted. Every non-companion section must be followed by `startxref` naming that section's offset and `%%EOF`, so each replayed prefix was a complete file. Test: an incremental update whose original revision lost its `startxref` and `%%EOF` | same |
| 105 | P2 | A page-tree root could carry a `/Parent` | Accepted. The root node must have no `/Parent`. Test: a root `/Pages` with `/Parent 1 0 R`, later repaired; a page used as the root now fails on this rule first | same |
| 106 | P2 | A stream object could pose as a catalog or page node | Accepted. A resolved in-use node must be a dictionary object closed by `endobj`; a stream body fails. Test: a catalog written as a stream, later repaired | same |

## Forty-ninth round (pull request #95, member-mapping revision)

Three findings from the automated Codex review of commit `8df488e563`; all accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 107 | P2 | An introduced object stream with no type-2 entry was never decoded | Accepted. Every in-use object introduced by a section whose top-level `/Type` is `/ObjStm` is now decoded whether or not any type-2 entry names it, and each header member must still map to a type-2 entry for that container and index. Test: the reviewer's example, object 5's row changed from type 2 to free | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 108 | P2 | A manifest entry could escape the manuscript directory and bypass the format check | Accepted. Manifest entries must be bare file names (no absolute paths, no directory components); every required `.tex`/`.pdf` file is now checked directly rather than through a directory listing. Test: entries `../archive/...pdf`, `/etc/hostname`, `sub/dir.pdf` | same |
| 109 | P2 | `%%EOFX` was accepted as a historical `%%EOF` | Accepted. Each revision's `%%EOF` must end at a line boundary (or the end of file); the final marker must end the file up to trailing newlines. Test: an original revision ending in `%%EOFX` followed by a valid update; a file with a trailing byte after the final marker | same |

## Fiftieth round (pull request #95, unreferenced-object-stream revision)

One finding from the automated Codex review of commit `621133b1e3`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 110 | P2 | PNG Sub, Average and Paeth prediction used the previous byte rather than the previous pixel | Accepted. The PNG row filters now predict from the previous pixel of `ceil(Colors × BitsPerComponent / 8)` bytes. The `/DecodeParms` validation is shared by object streams, superseded streams and the cross-reference stream, whose predicted row width must now equal the `/W` row width and whose TIFF predictor is now undone as well. Tests: an object stream Sub-encoded over three-byte pixels under `/Colors 3` (passes) and one encoded byte by byte under the same declaration (fails); a cross-reference stream with `/Columns 2 /Colors 2` over a four-byte `/W` (passes) and `/Columns 999` (fails) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-first round (pull request #95, pixel-width revision)

One finding from the automated Codex review of commit `998cf89ae0`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 111 | P2 | A cross-reference stream could omit its own object from its entries and from `/Size` | Accepted. A cross-reference stream is an object of its own revision, so its section must list it as an in-use entry at its own offset with its own generation; the existing `/Size` check then accounts for it. The repository PDF's stream (object 1132) lists itself. Tests: the reviewer's object `99 0 obj` under `/Size 5 /Index [0 3 4 1]`, and a stream whose own row is free | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-second round (pull request #95, self-listing revision)

One finding from the automated Codex review of commit `98d583269e`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 112 | P2 | A classic table could free or move the `/XRefStm` companion stream it names | Accepted. After the table's entries take precedence over the companion's, the effective entry for the companion's object must still be in use at the companion's offset with its generation. The scenario (companion listing itself, table freeing object 4 with the free list 0 → 4 → 0) was confirmed to pass the previous revision. Test: that scenario | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-third round (pull request #95, companion-precedence revision)

One finding from the automated Codex review of commit `8c4ad88fb2`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 113 | P2 | The lexer used Python's white-space class, which omits NUL and admits vertical tab | Accepted. Every pattern and every byte-string strip or split in the guard now spells out the six PDF white-space bytes (NUL, tab, line feed, form feed, carriage return, space); a test asserts the generic class no longer occurs in the source. The scenario (`/Bad\x00Name` in a superseded object) was confirmed to pass the previous revision. Tests: that object (fails), NUL and form feed as separators with vertical tab inside a name (passes), vertical tab glued to a number (fails) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-fourth round (pull request #95, white-space revision)

Two findings from the automated Codex review of commit `c2a67ae3c9`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 114 | P2 | A historical object could close only through bytes appended after its revision | Accepted. Every in-use entry of a section is now parsed as one complete object (a direct object closed by `endobj`, or a dictionary with a stream of its direct `/Length` closed by `endstream` and `endobj`) within the bytes before that section, at the point where the section is read; the superseded-stream pass reuses the same parser under the same bound and keeps only the content checks. The scenario (an unterminated string closed by a comment appended after the update) was confirmed to pass the previous revision. Test: that scenario | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 115 | P2 | `endobj` and `obj` were bounded by a word boundary, which vertical tab satisfies | Accepted. Every `obj`/`endobj` keyword must be followed by a PDF white-space or delimiter byte or the end of the buffer. The scenario (`endobj` followed by a vertical tab) was confirmed to pass the previous revision. Test: that scenario | same |

## Fifty-fifth round (pull request #95, object-extent revision)

One finding from the automated Codex review of commit `426c06dd38`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 116 | P2 | A same-named symbolic link could stand in for a required manuscript source | Accepted. The manifest, every required file and every `.tex`/`.pdf` present must be regular files (no symbolic link) whose resolved parent is the resolved manuscripts directory; anything else fails. The scenario (the required PDF replaced by a same-named link to a PDF outside the directory) was confirmed to pass the previous revision. Tests: that scenario, a link inside the directory, and a linked manifest | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-sixth round (pull request #95, symbolic-link revision)

One finding from the automated Codex review of commit `156822e056`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 117 | P2 | The manuscripts directory itself could be a symbolic link | Accepted. A linked directory now fails before its manifest or children are read; the helper's contract is restated accordingly. The scenario was confirmed to pass the previous revision. Test: a link to the directory (fails) while the real directory passes | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-seventh round (pull request #95, linked-directory revision)

One finding from the automated Codex review of commit `ee3e4b8f3f`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 118 | P2 | An indirect object listed by no cross-reference entry escaped every check | Accepted. Every revision's body (from the end of the previous revision, or the start of the file, to its cross-reference section) must now consist exactly of the in-use objects its section lists there, separated only by white space and comment lines (the header line is one); any other bytes fail. The scenario was confirmed to pass the previous revision. Tests: the reviewer's unlisted object 99 and stray text (fail), a comment line (passes); the hybrid fixture no longer carries a stale table in its body | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-eighth round (pull request #95, coverage revision)

One finding from the automated Codex review of commit `c472c2b3c8`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 119 | P2 | A separator comment could run into the header of the object it precedes | Accepted. Each comment between listed objects must now be closed by its line ending before the next object or section begins. The scenario (`% hidden 1 0 obj`) was confirmed to pass the previous revision. Tests: that scenario (fails), a whole comment line with a CRLF ending (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Fifty-ninth round (pull request #95, separator-comment revision)

One finding from the automated Codex review of commit `d4ce42bb76`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 120 | P2 | A revision terminator could put `startxref`, the offset and `%%EOF` on one line | Accepted. Every revision's terminator, the final one included, must now carry a line ending after `startxref` and after the offset, and `%%EOF` must end at a line boundary. The scenario (an original revision terminated on one line under a valid update) was confirmed to pass the previous revision. Tests: that scenario (fails), the same with CR and CRLF endings (passes), the final terminator on one line (fails) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Sixtieth round (pull request #95, terminator revision)

Two findings from the automated Codex review of commit `9bd427d395`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 121 | P2 | `\begin{document}` / `\end{document}` were accepted inside TeX comments | Accepted. The sentinels are now located on lines with their comments stripped (an unescaped `%` to the line end), so a commented sentinel does not count. The scenario was confirmed to pass the previous revision. Tests: the only `\end{document}` commented, the `\begin{document}` commented (both fail), an escaped `\%` after the sentinel (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 122 | P2 | The line ending before `endstream` was optional | Accepted. Every stream (superseded, cross-reference and object stream) must now have an end-of-line marker between its data and `endstream`. The scenario was confirmed to pass the previous revision. Tests: a superseded stream, a cross-reference stream and an object stream with that line ending deleted (all fail) | same |

## Sixty-first round (pull request #95, sentinel revision)

Two findings from the automated Codex review of commit `e59444dfba`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 123 | P2 | A `%` after `\\` was treated as escaped rather than as a comment | Accepted. A comment now starts at a `%` preceded by an even run of backslashes (`\\` being a control sequence and `\%` an escaped percent). The scenario (`\\%\end{document}` as the only closing sentinel) was confirmed to pass the previous revision. Tests: that line (fails), `\%\end{document}` (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 124 | P2 | Reversed sentinels on one line compared equal line indices | Accepted. The sentinels are now ordered by character position in the comment-stripped text. The scenario (`\end{document} \begin{document}` as the only occurrences) was confirmed to pass the previous revision. Test: that line (fails) | same |

## Sixty-second round (pull request #95, parity revision)

Two findings from the automated Codex review of commit `b8ea3754c5`; both accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 125 | P2 | `/Predictor 1` geometry changed the cross-reference row width | Accepted. Predictor 1 predicts nothing, so its geometry is ignored and the `/W` row width stands; the surplus bytes of the scenario now exceed the inflation ceiling. The scenario was confirmed to pass the previous revision. Tests: that scenario (fails), predictor 1 with irrelevant geometry and no surplus (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 126 | P2 | A zero-member object stream could carry arbitrary data | Accepted. `/First` must lie inside the data, and with `/N 0` the bytes from `/First` on must be white space only. The scenario was confirmed to pass the previous revision. Tests: `/N 0` over a nonempty body and `/First` beyond the data (fail), `/N 0` over white space (passes) | same |

## Sixty-third round (pull request #95, predictor-one revision)

One finding from the automated Codex review of commit `4967a92624`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 127 | P2 | The object-stream header could run into its first member without a token boundary | Accepted. The byte before `/First` must be white space or the byte at `/First` a white-space or delimiter byte, so the header's last integer cannot continue into the member. The scenario (`5 0true` with `/First 3`) was confirmed to pass the previous revision. Tests: that scenario (fails), a delimiter right at `/First` (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Sixty-fourth round (pull request #95, token-boundary revision)

One finding from the automated Codex review of commit `873ff91650`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 128 | P2 | An active `\end{document}` before the opening sentinel was masked by a later one | Accepted. The opening sentinel must now precede the first active `\end{document}`, since TeX stops at the first one it reaches. The scenario was confirmed to pass the previous revision. Test: an early `\end{document}` before an otherwise valid pair (fails) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Sixty-fifth round (pull request #95, first-end-sentinel revision)

One finding from the automated Codex review of commit `319b7f7f53`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 129 | P2 | `\\begin{document}` and `\\end{document}` were accepted as sentinels | Accepted. A sentinel now counts only when its own backslash follows an even run of backslashes, the same parity rule as for comment markers. The scenario was confirmed to pass the previous revision. Tests: both sentinels escaped (fails), `\\` immediately before a real sentinel (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Sixty-sixth round (pull request #95, sentinel-parity revision)

One finding from the automated Codex review of commit `95d3a614f7`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 130 | P2 | Sentinels inside macro bodies counted as the document environment | Accepted. Each sentinel must now be a standalone line of the comment-stripped text (surrounding white space allowed), which also subsumes the backslash-parity rule; the two earlier same-line passing cases now put `\\` and `\%` on the line before. The scenario was confirmed to pass the previous revision. Tests: sentinels only inside `\newcommand` bodies (fails), a sentinel with surrounding white space (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Sixty-seventh round (pull request #95, standalone-sentinel revision)

One finding from the automated Codex review of commit `174114be1e`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 131 | P2 | Sentinels on their own lines inside multiline macro bodies still counted | Accepted. A sentinel now counts only at brace depth zero of the comment-stripped text, braces escaped by an odd run of backslashes not nesting. The scenario was confirmed to pass the previous revision. Tests: sentinels inside multiline `\newcommand` bodies (fails), escaped braces before a real sentinel (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Sixty-eighth round (pull request #95, brace-depth revision)

One finding from the automated Codex review of commit `4f7ca64ce0`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 132 | P2 | Sentinels inside `\iffalse` … `\fi` still counted | Accepted. Since the guard cannot evaluate TeX, a sentinel now counts only outside every conditional region: an `\if…` control word among the TeX, e-TeX and pdfTeX primitives or declared by `\newif` in the source opens one and `\fi` closes it (`\iff` and brace-argument macros such as `\ifthenelse` do not). The scenario was confirmed to pass the previous revision. Tests: sentinels in an `\iffalse` branch and a declared conditional left open (fail); a balanced declared conditional, `\iff` and `\ifthenelse` before the sentinel (passes). Three sentinel-wrapping fixtures spliced the end sentinel with a stale index and were corrected | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Sixty-ninth round (pull request #95, conditional-region revision)

One finding from the automated Codex review of commit `5510b474cb`; accepted.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 133 | P2 | A `\fi` inside a macro body cancelled a real conditional opener | Accepted. Conditional tokens now count only at brace depth zero, since a token inside a brace body is not executed. The scenario was confirmed to pass the previous revision. Tests: `\newcommand{\fake}{\fi}` before an `\iffalse` around the sentinels (fails), `\newcommand{\fake}{\iffalse}` before a real sentinel (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventieth round (pull request #95, macro-body revision)

One finding from the automated Codex review of commit `e4a69e56aa`; accepted, with the resolution chosen on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 134 | P2 | A conditional opener inside an executed group was discarded like a macro-body token | Accepted. The guard cannot tell an executed group from a macro body without interpreting TeX, so a conditional token at nonzero brace depth is now a problem in itself and the source fails; conditional tokens at the top level are counted as before. The scenario was confirmed to pass the previous revision. Tests: `{\iffalse}` around the sentinels closed by `\else`, `}`, `\fi`, a `\fi` in a macro body, and an `\iffalse` in a macro body (all fail); the repository sources contain no conditionals | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-first round (pull request #95, brace-group revision)

One finding from the automated Codex review of commit `3360c47049`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 135 | P2 | An `\endinput` before the sentinels left them counted although TeX never reads them | Accepted. Any `\endinput` control word in the comment-stripped text that precedes the closing sentinel now fails the source, at any depth, since one inside a macro body or a skipped branch cannot be told apart from an executed one. The scenario was confirmed to pass the previous revision. Tests: `\endinput` before the sentinels and inside a macro body before them (fail), `\endinput` after `\end{document}` (passes); the repository sources contain none | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-second round (pull request #95, endinput revision)

One finding from the automated Codex review of commit `fb9d9910f9`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 136 | P2 | `\csname endinput\endcsname` constructs `\endinput` without the literal control word | Accepted. The `\endinput` rule is generalised to a fixed set of control words the guard cannot follow, since they end the input, read other files, construct control sequences or change how the rest of the source is read: `\endinput`, `\csname`, `\catcode`, `\scantokens`, `\lowercase`, `\uppercase`, `\directlua`, `\input`, `\include`, `\InputIfFileExists`, `\@input`, `\openin`, `\stop`, `\dump`; any of them before the closing sentinel, at any depth, fails the source. The repository sources use none. The scenario was confirmed to pass the previous revision. Tests: `\csname endinput\endcsname`, `\input{other}`, a `\catcode` change and `\scantokens{x}` before the sentinels (fail); longer control words such as `\inputencoding` (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-third round (pull request #95, stop-control revision)

One finding from the automated Codex review of commit `b6753bdd51`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 137 | P2 | `^^` notation could encode a control word the guard scans for | Accepted. Any `^^` in the source now fails it before any other check, since the guard does not model TeX's input processor; the repository sources contain none. The scenario was confirmed to pass the previous revision. Test: `\end^^69nput` before the sentinels (fails) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-fourth round (pull request #95, caret-notation revision)

One finding from the automated Codex review of commit `0ff3859a4b`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 138 | P2 | `\begin` and `\end` could be redefined before the sentinels | Accepted. `\begin` and `\end` may now occur only as environment uses followed by `{`, the internal `\document` and `\enddocument` control words may not occur at all, and no environment-defining command may target `document`; any of these fails the source. The scenario was confirmed to pass the previous revision. Tests: `\def\begin#1{}` with `\def\end#1{}`, `\let\begin\relax`, `\renewcommand{\end}[1]{}`, `\renewenvironment{document}{}{}`, `\RenewDocumentEnvironment{document}{}{}{}` and `\let\document\relax` (all fail); `\begingroup`, `\endgroup` and `\begin {center}` (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-fifth round (pull request #95, sentinel-redefinition revision)

One finding from the automated Codex review of commit `9a48edeaad`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 139 | P2 | `\def\begin{}` put the target before a brace and passed as an environment use | Accepted. A definer control word (`\def` and its variants, `\let`, `\futurelet`, a prefix such as `\global`, `\long`, `\outer` or `\protected`, or any control word containing `command`/`Command`) followed by `\begin`, `\end`, `\document` or `\enddocument` as its target now fails the source, in addition to the earlier rules. The scenario was confirmed to pass the previous revision. Tests: `\def\begin{}` with `\def\end{}`, `\renewcommand\begin{}`, `\global\let\end{}`, `\NewCommandCopy\begin{\relax}` and the alias `\let\foo\begin` (fail); a macro body using `\begin{center}` (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-sixth round (pull request #95, definer-target revision)

One finding from the automated Codex review of commit `bc8d534802`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 140 | P2 | A definer's target on the next line evaded the definer rule | Accepted. TeX skips the white space after a control word, a line ending included, and a comment ends a line; so the definer rule, the environment-defining rule and the `\newif` declaration now allow line endings wherever they allowed spaces and tabs. The scenario, its comment-separated form, `\renewenvironment` with `{document}` on the next line and `\newif` with its name on the next line were all confirmed to pass the previous revision. Tests: `\def` then `\begin{}` on the next line (with `\end{}` alike), `\def%` then `\begin{}`, `\renewcommand` then `{\end}{}`, `\global` across a blank line then `\let` then `\end{}`, `\renewenvironment` then `{document}{}{}`, `\NewDocumentEnvironment` then `*` then `{ document }` (all fail); a line-broken definer with another target and a line-broken `\newenvironment{doc}` (pass); `\newif` then `\ifdraft` on the next line with the conditional left open (fails) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-seventh round (pull request #95, line-ending revision)

One finding from the automated Codex review of commit `b51e7ebbbb`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 141 | P2 | A starred definer such as `\renewcommand*\begin{}` evaded the definer rule | Accepted. The definer rule now allows an optional `*` before the target, as the environment-defining rule already did. Two related gaps were closed in the same revision: a `...namedef...` or `...namelet...` macro (such as `\@namedef`) whose brace argument spells `begin`, `end`, `document` or `enddocument` fails the source, since it defines that control word without a `\csname` in the source; and `\ExplSyntaxOn` joins the control words the guard cannot follow, since it changes which characters form control words. The starred scenario, `\DeclareRobustCommand*` with its target on the next line, `\@namedef{begin}{}`, `\@namedef{ enddocument }{}` and `\ExplSyntaxOn` were all confirmed to pass the previous revision. Tests: `\renewcommand*\begin{}` with `\renewcommand*\end{}`, `\newcommand*{\end}{}`, `\DeclareRobustCommand*` then `\begin{}` on the next line, `\@namedef{begin}{}`, `\@namedef{ enddocument }{}`, `\@namelet` then `{end}{relax}` and `\ExplSyntaxOn` before the sentinels (all fail); `\renewcommand*{\foo}{\begin{center}}` and `\@namedef{beginfoo}{}` (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-eighth round (pull request #95, starred-definer revision)

One finding from the automated Codex review of commit `d05f64b009`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 142 | P2 | A definer target assembled by expansion (`\expandafter\def\the\toks0`) evaded the definer rule | Accepted, and resolved at the level of the TeX primitives rather than of this scenario. The control words the guard cannot follow now include every TeX-level definer, prefix, register definer and allocator that can clobber a control word (`\def`, `\gdef`, `\edef`, `\xdef`, `\let`, `\futurelet`, `\chardef`, `\mathchardef`, `\countdef`, `\dimendef`, `\skipdef`, `\toksdef`, `\muskipdef`, `\font`, `\read`, `\readline`, `\global`, `\long`, `\outer`, `\protected`, `\newtoks`), every expansion-control primitive (`\expandafter`, `\noexpand`, `\unexpanded`, `\the`, `\aftergroup`, `\afterassignment`) and every token register TeX inserts by itself (`\toks`, `\everypar`, `\everymath`, `\everydisplay`, `\everyhbox`, `\everyvbox`, `\everycr`, `\everyeof`, `\everyjob`, `\output`, `\errhelp`); any of them before the closing sentinel fails the source. The repository manuscripts use none of them (their only definer is `\newcommand`). For the LaTeX-level definers that remain, a `Declare...` macro or a register allocator (`\newcount`, `\newdimen`, `\newskip`, `\newmuskip`, `\newbox`, `\newread`, `\newwrite`, `\newlanguage`, `\newinsert`, `\newfam`, `\newmarks`, `\newattribute`) may not target a sentinel word either, and a `...command...` macro must name its target as a control word right there, so a target reaching it through a macro parameter or through another macro's body (a wrapper around the definer) fails the source. The reported scenario, `{\aftergroup\def}\begin{}`, `\let\d\def` with `\d\begin{}`, a `\noexpand` assembly, `\DeclareTextSymbol\begin{OT1}{65}`, `\newcount\begin{}` and the two wrappers were all confirmed to pass the previous revision. Tests: the reported scenario, the `\aftergroup`, `\let`, `\edef`/`\noexpand`, `\everypar`, `\newtoks`, `\font` and `\read` forms (all fail as constructions the guard cannot follow); `\DeclareTextSymbol\begin{OT1}{65}`, `\newcount\begin{}`, the two wrappers, `\renewcommand{#1}{}` and a bare `\newcommand` before the sentinel (all fail as sentinel tampering); `\DeclareMathOperator`, `\DeclareGraphicsExtensions`, `\newcounter`, `\newlength`, `\newdimen`, `\newcommand\foo{}`, `\newcommand*{ \bar }[1]{#1}` and `\providecommand` naming their targets (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Seventy-ninth round (pull request #95, primitive-stop revision)

One finding from the automated Codex review of commit `c5fc74d300`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 143 | P2 | A package's name-based definer (`\csdef{begin}{}`) evaded every definer rule | Accepted, and resolved by an allowlist rather than by another pattern, since the set of package macros that define a control sequence from a name is open-ended. `manuscripts/TEX_CONTROL_WORDS` (listed in the manifest) now names the control words a source may use, one per line, sorted; every control word before the closing sentinel must be listed, or the source fails, and the list itself must be sorted, without repetition, nonempty, made of names, and free of the control words the guard can never follow. The list was generated from the two repository manuscripts (167 words, all standard LaTeX and amsmath control words plus the manuscripts' own macros; the only definers are `\newcommand` and `\newtheorem`). Control symbols (a backslash and one non-letter) define nothing and are exempt. Four further gaps were closed alongside, each confirmed to pass the previous revision: a macro body may not reorder its parameters (`#2#1` would move a definer next to a sentinel word in ways the guard cannot follow; parameters must be `#1`..`#9`, inside a body, strictly increasing within one top-level group), a `...command...` definer must be followed by its body or argument count after its control-word target (`\newcommand\foo\bar` fails), an environment definer may not target `begin`, `end` or `enddocument` either, and the manuscripts directory may hold no TeX input file (`.sty`, `.cls`, `.clo`, `.def`, `.cfg`, `.fd`, `.ltx`, `.dtx`, `.ins`) that a source could load in place of the installed one. The reported scenario was confirmed to pass the previous revision. Tests: `\csdef{begin}{}` with `\csdef{end}{}`, `\cslet{end}\relax`, `\@namedef{beginfoo}{}` and an unlisted `\newcommand{\foo}{x}` (all fail as unlisted), the same `\foo` once listed and `\csdef` after `\end{document}` (pass), a list containing `\def`, an unsorted, repeated, malformed or empty list, and a missing list (all fail); `#2#1`, `#1#2#1`, `\f{#2}{#1}`, a `#1` outside any body, `##1` and `#a` (all fail) and `\f{#1}{#2}` with a one-parameter `\f` (passes); `\newcommand\foo\bar`, `\NewCommandCopy\foo\bar`, `\renewenvironment{begin}{}{}` and `\newenvironment*{ end }{}{}` (all fail); `geometry.sty`, `article.cls` and `t1enc.def` in the directory (all fail) | `tools/check_manuscript_source.py`, `manuscripts/TEX_CONTROL_WORDS`, `manuscripts/MANIFEST`, `tests/test_check_manuscript_source.py` |

## Eightieth round (pull request #95, allowlist revision)

One finding from the automated Codex review of commit `e22297f7b7`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 144 | P2 | A sentinel wrapped in a macro body and invoked early was ignored rather than rejected | Accepted. Every `\begin{document}` or `\end{document}` before the closing sentinel other than the two standalone sentinels themselves now fails the source, since a macro or group could execute it; and `\begin`/`\end` must be followed by `{name}` with a plain name (letters, digits, `*`), since a name assembled from a macro parameter (`\begin{docu#1}`, `\end{#1}`) could spell `document`. The reported scenario and the two assembled-name forms were confirmed to pass the previous revision. Tests: `\newcommand{\foo}{\end{document}}` then `\foo`, `\newcommand{\foo}{\begin{document}}` and `x \end{document}` before the sentinels (all fail as not the standalone sentinel); `\begin{docu#1}`, `\end{#1}` in macro bodies and `\begin{ center }` (all fail as sentinel tampering); `\begin{align*}` (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-first round (pull request #95, stray-sentinel revision)

One finding from the automated Codex review of commit `f1e1ee8fb3`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 145 | P2 | A TeX input file in a subdirectory, loaded by path, escaped the input-file rule | Accepted. The manuscripts directory may now hold no subdirectory at all, and every package or class loader (`\documentclass`, `\usepackage`, `\RequirePackage`, `\LoadClass` and their `WithOptions` forms) before the closing sentinel must name plain names (letters, digits, `-`, `_`, comma-separated after an optional options group), never a path. The scenario (`sub/evil.sty` with `\usepackage{sub/evil}`) was confirmed to pass the previous revision. Tests: a subdirectory holding `evil.sty` and an empty subdirectory (both fail); `\usepackage{sub/evil}`, `\usepackage{../evil}`, `\usepackage{evil.sty}`, `\usepackage[a]{geometry, sub/x}`, `\documentclass{./article}`, `\usepackage{\foo}` and a bare `\usepackage` (all fail); options, comma-separated names and line-broken arguments (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-second round (pull request #95, subdirectory revision)

Two findings from the automated Codex review of commit `af8f2a3975`; both accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 146 | P2 | A closing brace before its opener summed to depth zero at the sentinels | Accepted. The running brace depth before the closing sentinel may never go negative: the first closer with no opener before it fails the source, since TeX stops there with an error before the document. The scenario was confirmed to pass the previous revision. Test: `}` then `{` before the sentinels (fails); a `}` after `\end{document}` (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |
| 147 | P2 | A `\fi` before its opener summed to depth zero at the sentinels | Accepted, by the same rule applied to conditional tokens: the running conditional depth before the closing sentinel may never go negative. The scenario was confirmed to pass the previous revision. Test: `\fi` then `\iffalse` before the sentinels with the real `\fi` after them (fails); a `\fi` after `\end{document}` (passes) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-third round (pull request #95, unmatched-closer revision)

One finding from the automated Codex review of commit `d794f9c534`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 148 | P2 | `\newtheorem{document}` escaped the environment-definer rule | Accepted. The rule now covers every `...theorem...` macro alongside the `...environment...` macros, since `\newtheorem` defines an environment too: one targeting `document`, `begin`, `end` or `enddocument` fails the source. The scenario, its starred form and its optional-argument form were confirmed to pass the previous revision. Tests: `\newtheorem{document}{Broken}`, `\newtheorem*{end}{Broken}` and a line-broken `\newtheorem` with `{begin}[section]{Broken}` (all fail) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-fourth round (pull request #95, theorem-definer revision)

One finding from the automated Codex review of commit `f3a2082a88`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 149 | P2 | A duplicate `startxref`/`%%EOF` pair appended after a valid PDF left unaccounted bytes | Accepted. The newest cross-reference section's terminator must now be the one the file ends with: any bytes after it other than line endings fail the file, so appended content, a duplicate terminator included, cannot bypass the structural walk. The scenario and a variant with stray bytes before the duplicate were both confirmed to pass the previous revision. Tests: a duplicate terminator and stray bytes plus a duplicate terminator appended to a valid file (both fail); trailing line endings after the real terminator (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-fifth round (pull request #95, terminator revision)

One finding from the automated Codex review of commit `d67b8eacf7`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 150 | P2 | An allowlisted name containing `@` could hide a stop word (`\endinput@foo`) | Accepted. Allowlist names are now letters only, so no name containing `@` can be listed; the scanner keeps taking `@` as a letter, so a control word containing `@` fails whichever catcode `@` has, as one unknown word or as a known word the scan would otherwise have cut short. The scenario (`endinput@foo` listed and `\endinput@foo` used) was confirmed to pass the previous revision. Tests: `\endinput@foo` before the sentinels (fails as unlisted); a list containing `x@y` (fails as malformed) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-sixth round (pull request #95, letters-only revision)

One finding from the automated Codex review of commit `0977d0f55c`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 151 | P2 | An environment definer whose name argument was a macro expanding to `document` escaped the literal-target rule | Accepted. Every `...environment...` or `...theorem...` definer must now name its target as a literal plain name (letters, digits, `*`) right there, and that name may not be a sentinel word; a macro, a padded name, a parameter or a missing argument fails the source, since LaTeX expands the argument into the environment's control-sequence names. The scenario and its `\newtheorem` form were confirmed to pass the previous revision. Tests: `\newcommand{\foo}{document}` followed by `\renewenvironment{\foo}{}{}` or by `\newtheorem{\foo}{Broken}`, `\newenvironment{ doc }{}{}`, `\newenvironment{do#1}{}{}` and a bare `\newtheorem` (all fail); `\newenvironment{doc}` and `\newtheorem*{lem2}[doc]{Lemma}` (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-seventh round (pull request #95, literal-name revision)

One finding from the automated Codex review of commit `747fd3b77f`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 152 | P2 | Sentinels wrapped in a `comment` environment sat at brace and conditional depth zero and passed | Accepted. The environment uses up to the closing sentinel must now nest properly (at any brace depth, since a macro body cannot be told apart), with no environment open at the opening sentinel and nothing but `document` open at the closing one: a sentinel inside any other environment, an environment left open at either sentinel, an `\end` closing no open environment or closing a different one, and a macro body containing an unmatched `\begin` all fail the source. The scenario was confirmed to pass the previous revision. Tests: the sentinels inside `comment`, `\begin{center}` left open before the opening sentinel and before the closing one, a stray `\end{center}`, `\begin{center}\end{quote}` and `\newcommand{\foo}{\begin{center}}` (all fail); a macro body holding a whole environment and an `\end{center}` after `\end{document}` (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-eighth round (pull request #95, environment-nesting revision)

One finding from the automated Codex review of commit `385bc8e3c0`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 153 | P2 | A bare argument-taking command before the opening sentinel would take `\begin` as its argument | Accepted. The guard now carries the mandatory-argument count of every allowlisted control word (and of every macro a source declares with `\newcommand`, from its declaration), and checks the up to nine argument units (brace groups, control words, control symbols, single characters) before each sentinel and before the end of every brace group other than a definer's target group `{\name}`: a call among them with fewer units after it than it takes (a `*` and `[...]` groups right after the call being optional; a declared `[n][default]` makes the first argument optional), or one whose arity the guard does not know, fails the source, since a macro body's expansion, an argument a body re-emits and a bare macro passed as a single-token argument are all followed by whatever comes after the call, the sentinel included. The bare `\title` scenario, a bare `\emph` before the closing sentinel and a macro body ending in `\emph` invoked before the opening sentinel were all confirmed to pass the previous revision. Tests: those three, `\usepackage[a]{b}\sqrt` before the opening sentinel, a two-argument macro called with one, `\newcommand{\foo}{\frac{a}}`, `\newenvironment{foo}{x}{\emph}`, an unknown-arity word, `\foo{\sqrt}` and `\foo\sqrt` for a macro re-emitting its argument, and `\textbf{\emph}` (all fail); `\title{X}`, `\usepackage[a]{b}`, `\frac12`, `\bar\beta`, `\sqrt[3]{x}`, `\\`, `\{\}`, a body `{\emph{x}}` and a macro declared `[1][d]` called bare (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Eighty-ninth round (pull request #95, argument-boundary revision)

One finding from the automated Codex review of commit `f2d4a86492`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 154 | P2 | A declaration anywhere in the source, including after the document or in a skipped branch, set the arity of earlier calls | Accepted. A macro now takes the arity of the latest declaration that executes before the call: one at brace depth zero, outside every conditional, before the closing sentinel and earlier in the source than the call; a conditional declared by `\newif` likewise takes none only from its declaration on. A call with no such declaration and no kernel arity has an unknown arity and fails within reach of a sentinel or a group end. A declaration later in the preamble, one in a skipped branch and one inside a group were each confirmed to establish the arity under the previous revision. Tests: `\foo` before its declaration, a declaration inside `\iffalse`…`\fi`, one inside a brace group, and one after `\end{document}` (all fail) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Ninetieth round (pull request #95, declaration-order revision)

One finding from the automated Codex review of commit `0eccfebc91`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 155 | P2 | A `\providecommand` of an already defined name was recorded as a new arity although LaTeX leaves the definition unchanged | Accepted, and extended to the two neighbouring cases: only a declaration LaTeX carries out now counts. `\newcommand` and `\providecommand` establish an arity only for a name not yet defined (a kernel word or an earlier executed declaration leaves them without effect, the former with an error), and `\renewcommand` only for a name that is defined; a call whose only declarations were of no effect keeps its earlier arity, or has none and fails within reach of a sentinel or a group end. The scenario, `\newcommand{\emph}{}` followed by a bare `\emph`, and `\renewcommand` of an undefined name followed by a bare call were all confirmed to pass the previous revision. Tests: those three (all fail); `\providecommand` of a new name followed by `\renewcommand*` with `[1][d]` and a bare call (passes). The four declaration-order tests announced in the eighty-ninth-round response had not reached that revision's test file, the edit that carried them having failed alongside a rejected code edit; they are committed with this revision | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Ninety-first round (pull request #95, carried-out-declaration revision)

One finding from the automated Codex review of commit `692ecf821b`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 156 | P2 | A `\DeclareRobustCommand` declaration was not collected, so a later no-op `\providecommand` counted as a new zero-argument definition | Accepted, with both remedies the finding offers. The guard now models a fixed set of definers by what LaTeX does with an already defined name: `\newcommand`, `\providecommand`, `\DeclareMathOperator`, `\newlength` and `\newsavebox` define only a fresh name; `\renewcommand` redefines only a defined one; `\DeclareRobustCommand` and the plain allocators (`\newcount`, `\newdimen`, `\newskip`, `\newmuskip`, `\newbox`, `\newread`, `\newwrite`, `\newfam`, `\newinsert`, `\newlanguage`) define either way; `\newif` defines the conditional and its `...true` and `...false` setters. Any other control word of the definer families (a `...command...` macro, a `Declare...` macro or an allocator) has an effect the guard does not model and fails the source. The scenario was confirmed to pass the previous revision. Tests: the scenario (fails as a call short of arguments); `\NewCommandCopy{\foo}{\emph}` and `\DeclareGraphicsExtensions{.pdf}` (fail as unmodelled definers); `\DeclareRobustCommand{\foo}[1]{#1}` followed by `\foo{x}`, and `\newif\ifdraft` followed by a bare `\drafttrue` (pass). The positive fixture that used `\DeclareGraphicsExtensions` now omits it | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |

## Ninety-second round (pull request #95, modelled-definer revision)

One finding from the automated Codex review of commit `f0efd6a485`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 157 | P2 | The nine-unit lookback could be exhausted by the contents of an optional argument before reaching the call that takes it | Accepted, with the second remedy the finding offers: the lookback has no cap. Before a sentinel it reaches the start of the source, and before a closing brace it reaches the group's opener, so every call in the group or at the top level is examined, and the argument count is computed by index so the uncapped scan stays linear in the source. The scenario was confirmed to pass the previous revision. Tests: the scenario and an unclosed `\foo[abc` (fail as calls short of arguments), the scenario after a complete call (fails); `\foo[abcdefghijk]{x}`, `\foo[abc]{y}` and `\foo[abcdefghijk][x]{y}` (pass) | `tools/check_manuscript_source.py`, `tests/test_check_manuscript_source.py` |


## Ninety-third and ninety-fourth rounds (pull requests #95 and #100)

Two P2 findings were accepted on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 158 | P2 | Known arity was incorrectly treated as proof that a control word was already defined | Accepted. Declaration history now establishes definite definition; an arity-table entry without an executed declaration is uncertain. State-dependent definers targeting an uncertain name fail closed. Coverage includes \`\newcommand\`, \`\providecommand\`, and \`\renewcommand\` against package-dependent \`\mathbb\`, plus a fresh three-argument custom command | \`tools/check_manuscript_source.py\`, \`tests/test_check_manuscript_source.py\` |
| 159 | P2 | Uncapped backward scanning repeatedly rescanned a long plain-letter run and became quadratic | Accepted. The scanner retains the discovered start of the current plain-letter run while emitting its characters, so the uncapped safety check remains linear. Coverage exercises a 10,000-character run | \`tools/check_manuscript_source.py\`, \`tests/test_check_manuscript_source.py\` |

## Ninety-fifth round (pull request #101, radius-`m` collar slice)

One finding from the automated Codex review of commit `c14afe4f2b`; accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 160 | P2 | The oracle's separation-radius search returned None on a negative cap, which reads as a surviving collision | Accepted. The oracle now raises on a negative bound, as the canonical Mojo `separation_radius` already did; a test asserts the error, so an empty search can no longer be recorded as a survivor | `reference/psc_research/overlap_collar.py`, `tests/test_overlap_collar.py` |

## Ninety-sixth round (pull request #101, negative-cap revision)

Two findings from the automated Codex review of commit `d5be52f0f2`; both accepted, on the fail-closed side, in the canonical implementation and the oracle alike.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 161 | P2 | `inflate_collar` with a negative radius returned empty collars instead of raising | Accepted. Both implementations now reject a negative radius before inflating; tests assert the error | `kernel/psc/overlap_collar.mojo`, `reference/psc_research/overlap_collar.py`, tests |
| 162 | P2 | A pump certificate whose first state has no fibre in the collared graph lifted to no orbits, which the census would read as a constant collar | Accepted. Both implementations now fail when the starting fibre is empty; tests lift the collapsing specimen's certificate against the determinant-two collared graph and assert the error | `kernel/psc/overlap_collar.mojo`, `reference/psc_research/overlap_collar.py`, tests |

## Ninety-seventh round (pull request #101, invalid-input revision)

Two findings from the automated Codex review of commit `5b06d74b19`; both accepted, on the fail-closed side.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 163 | P2 | `patch_power_level` with equal letters reported level 1 for every substitution, since `sigma(a)sigma(a)` is always a power | Accepted. Both implementations reject equal endpoints, as a swap seed needs two distinct letters; tests assert the error | `kernel/psc/overlap_collar.mojo`, `reference/psc_research/overlap_collar.py`, tests |
| 164 | P2 | The oracle's `inflate_collar` returned sides shorter than the radius when the input collar was undersized, where the canonical implementation raises | Accepted. The oracle now carries the same post-inflation length check; both test files inflate a radius-1 collar at radius 2 under a length-one image and assert the error | `reference/psc_research/overlap_collar.py`, tests |

## Ninety-eighth round (pull request #101, equal-letter revision)

Two findings from the automated Codex review of commit `400010cf0a`; both accepted, and the oracle's input validation brought to parity with the canonical module in the same revision.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 165 | P2 | The oracle lifted a certificate whose edge sequence did not match its states, so an empty edge sequence read as a constant pump | Accepted. The oracle now rejects an empty certificate and one whose edge and state sequences differ in length, as the canonical implementation does; tests assert the error on three malformed certificates | `reference/psc_research/overlap_collar.py`, `tests/test_overlap_collar.py` |
| 166 | P2 | The oracle's `legal_factors` accepted a nonpositive length and returned the letters | Accepted. The oracle rejects a length below one, as the canonical routine does; a test asserts the error. The oracle's `collared_seeds` also rejects a capped graph, the one remaining check the canonical module had and the oracle lacked | `reference/psc_research/overlap_collar.py`, `tests/test_overlap_collar.py` |

## Ninety-ninth round (pull request #101, oracle-parity revision)

One finding from the automated Codex review of commit `a238e8dfb9`; accepted, on the fail-closed side, in both implementations.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 167 | P2 | A certificate with a valid first state and valid edges but corrupted later states lifted to the original periods, since only the first state was consulted | Accepted. Both implementations now check, before lifting, that every edge's parent is the state at its index and its child the cyclically next state, the invariant `verify_affine_pump` enforces; tests corrupt every later state entry of the golden certificate and assert the error | `kernel/psc/overlap_collar.mojo`, `reference/psc_research/overlap_collar.py`, tests |

## Hundredth round (pull request #101, pump-state revision)

One finding from the automated Codex review of commit `89550a4350`; accepted, on the fail-closed side, in both implementations.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 168 | P2 | A certificate edge with a valid ordinal but stale child indices was followed by ordinal alone, so the lift accepted an edge `verify_affine_pump` rejects | Accepted. Both lifts now compare the selected collared edge's child state and both child indices with the certificate edge before following it; tests corrupt the top child index of the golden certificate's first edge and assert the error | `kernel/psc/overlap_collar.mojo`, `reference/psc_research/overlap_collar.py`, tests |

## Hundred-and-first round (pull request #101, occurrence-edge revision)

One finding from the automated Codex review of commit `938a1100fc`; accepted, at the root: the lift no longer trusts any field of a certificate.

| # | Priority | Finding (short) | Action | Where in the revision |
| --- | --- | --- | --- | --- |
| 169 | P2 | A certificate with corrupted prefix or forcing payload still lifted, since the collared edge retains no such fields | Accepted. Both lifts now take the seed-patch tables and graph and replay the certificate in full with `verify_affine_pump` (every field of every edge, and the exact cycle identity) before lifting, so only a verified affine pump is lifted; the census passes its tables through. Tests forge the forcing term of the golden certificate's first edge and assert the error | `kernel/psc/overlap_collar.mojo`, `reference/psc_research/overlap_collar.py`, `kernel/swap_overlap_census.mojo`, tests |

## Hundred-and-second round (pull request #101, verified-lift revision)

The automated Codex review of commit `fdeacddc6e` posted no findings. No change.
