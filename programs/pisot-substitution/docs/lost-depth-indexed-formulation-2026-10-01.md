# Lost depth-indexed formulation: provenance record — 2026-10-01

**Status:** missing-source provenance record, plus finite-domain evidence
computed in this repository (§4–§6, each labelled with its evidence class).
Every item attributed to the lost files is unverified, is not cited by
any status surface, and must not enter `claim_governance.toml`, the ledgers or
the manuscript until it is reconstructed from scratch with its own proof or
replayable finite certificate. This note does not change the status of any
rung of `docs/proof-ladder.md`.

## 1. What was lost

Notes from earlier working conversations describe a parallel formulation of
the proof programme whose source files no longer exist anywhere reachable:

| Lost file | Recorded role |
| --- | --- |
| `PROOF_LADDER.md` (118 lines) | depth-indexed ladder, distinct from `docs/proof-ladder.md` |
| `PAPER_SUBMISSION.md` | submission plan |
| `LEVEL3_SUBMISSION.tex` | Level-3 manuscript draft |
| `SWEEP_RESULTS.md` | results of a 24,486-specimen sweep |
| `TRANSPORTABLE_METHOD.md` | method write-up |

Searched on 2026-10-01, with no hit for any file name or for the strings
`S-child`, `joint full support`, `9.26j`, `24486` / `24,486`,
`TRANSPORTABLE_METHOD`, `psc_suite`:

- every commit, every branch and every unreachable object (`git fsck
  --lost-found`) of this repository and of `larsbx/finite-math-kernels`;
- `larsbx/tiling-theory-research`, a single-commit stub;
- GitHub code search across the `larsbx` account;
- Google Drive full-text and title search.

## 2. The two formulations differ in what "level" indexes

In this repository a level names a **proof route**: Level 2 is finite BPA
(G1, reduced to the open G1b-2), and Level 3 is the SCC Producer, posed under
G1. The lost formulation used levels as **depth-indexed criteria** over a
larger class of substitutions. Statements do not transfer between the two
automatically. In particular, Level 3 here presupposes Level 2, so no
"higher level implies lower level" transfer exists on this ladder.

## 3. Recorded items and their disposition

| Recorded item (as the notes state it) | Disposition |
| --- | --- |
| Level 3 "computationally closed for all 24,486 substitutions with \|σ\| ≤ 8 via a 2-step criterion" | **Unverified; wording rejected.** The 2-step criterion's definition is lost. Under hypothesis-firewall item 8 of `docs/proof-ladder.md`, a finite sweep is finite-domain evidence and cannot close a level. The domain is recovered (§4). |
| "Joint full-support lemma", false by Tribonacci; remaining gap stated as joint-support growth | **Counterexample reproduced** (§5). The lemma plays no role on this repository's routes: the bad-SCC normal form already has `rank_Q(V_S) = \|A\|`. |
| "S-child" statement: child support = supp σ(x) ∪ supp σ(y) | **Elementary, to be re-derived where used:** σ(xy) = σ(x)σ(y), so supp σ(xy) = supp σ(x) ∪ supp σ(y). Which graph's "child" was meant is lost. |
| Level 2 "closed for ℤ-independent substitutions with max \|σ\| ≤ 4" (Thm 9.28, chain 9.26a–j) | **Unverified and suspect.** It adds ℤ-independence as a hypothesis, which firewall item 2 forbids, and it conflicts with G1b-2 remaining open. It may descend from the retracted inference "UD ⇒ bounded padding ⇒ finite BPA" (see `archive/2026-10-06/status-snapshots/completion-ledger-2026-09-11.md`); this is a conjecture about provenance, not a finding. If it is ever reconstructed, it can only be a restricted-class result inside G1b-2. On the total-length ≤ 8 part of that slice, finite `B_sigma` holds for every specimen as a finite-domain consequence of `docs/bpa-termination-by-overlap-depth-2026-10-02.md` (Proposition 1 with the exact overlap verdicts of §6), including the 120 whose direct builds exhaust the budget of §7. The recorded theorem and its proof remain lost, and nothing is claimed beyond that class. |
| 4,554-PIP `psc_suite` run | Matches this repository's standing corpus (`kernel/psc/corpus.mojo`). |

## 4. Recovered sweep domain

The count 24,486 is exactly the number of primitive irreducible Pisot
substitutions on three letters with **total** image length
Σ_a |σ(a)| ≤ 8. "|σ| ≤ 8" in the notes therefore meant total length, not
maximum image length. Cumulative counts by maximum image length:

| max_a \|σ(a)\| ≤ | 2 | 3 | 4 | 5 | 6 |
| --- | --- | --- | --- | --- | --- |
| count (Σ_a \|σ(a)\| ≤ 8) | 72 | 4,554 | 14,670 | 22,080 | 24,486 |

The standing 4,554 corpus is exactly the max-image ≤ 3 slice: total length 9
adds no member, because images of lengths (3,3,3) are constant-length, so
β = 3 and the incidence polynomial is reducible.

**Evidence class:** exact finite count, replayable in Mojo. The canonical
enumeration is `psc.corpus.pip_corpus_total_length`, and the regression
`test_the_total_length_corpus_contains_the_standing_corpus` in
`kernel/tests/test_census_library.mojo` pins the total, every cumulative slice,
and the max-image ≤ 3 slice's identity with the standing corpus, label for
label. The Python screen `reference/psc_research/pip_screen.py` is the
independently written oracle and gives the same counts. The class is a corpus
for exploratory sweeps, not for censuses (§6).

## 5. Primitivity and joint-support exponents on the standing corpus

Also oracle-only, computed in the same session over the 4,554 corpus:

| k | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| specimens with primitivity exponent γ(M) = k | 0 | 2,880 | 1,596 | 66 | 12 |
| specimens whose pairwise joint support first fills at k | 1,152 | 2,958 | 444 | 0 | 0 |

Wielandt's bound `γ ≤ (d−1)² + 1 = 5` is attained by 12 specimens, and
`max_a |σ^γ(a)| ≤ 42` across the corpus. Tribonacci (σ: 1→12, 2→13, 3→1) has
supp σ(2) ∪ supp σ(3) = {1,3}, γ = 3, and first joint saturation at k = 3.

Passing to σ^k preserves Ω_σ, pure discrete spectrum and "∃n" coincidence
conditions, but it does not remove the obstruction on this repository's
routes: a bad closed SCC for σ, sampled every k steps, is still a bad closed
recurrent structure for σ^k.

## 6. Exploratory overlap sweep over the recovered domain

**Evidence class:** finite-domain evidence on the stated class only. It does
not reconstruct the lost 2-step criterion, does not close any level, and says
nothing about substitutions outside the class.

`kernel/swap_overlap_total_length_sweep.mojo` runs the survey of
`kernel/swap_overlap_census.mojo` unchanged over the 24,486 specimens of §4
(`psc.corpus.pip_corpus_total_length(8)`). It is an exhaustive, deterministic
exploratory sweep, not a census: the repository's censuses survey the
canonical 4,554 corpus (`AGENTS.md`, "The census library"). Because 24
specimens exhaust a diagnostic budget (below), the sweep reports itself
incomplete and exits non-zero after printing its summary. Two kernel changes made this
possible: the exact Perron layer is certified to column sum
`MAX_CERTIFIED_COLUMN_SUM = 6` with the overflow bound stated in
`kernel/psc/perron_field3.mojo`, and `PerronCache` no longer leaves a stale
entry behind a refused build. The same driver on the standing corpus
reproduces every published line exactly.

| | standing 4,554 | total length ≤ 8: 24,486 |
| --- | --- | --- |
| overlap graphs built / capped | 4,554 / 0 | 24,486 / 0 |
| total overlap states | 1,118,850 | 7,522,892 |
| largest overlap graph | 2,640 | 14,826 |
| specimens with a nonproductive overlap | 0 | 0 |
| maximum first-coincidence depth | 18 | 26 |
| maximum first left-aligned depth | 17 | 24 |
| maximum prefix / suffix strong-coincidence depth | 15 / 15 | 15 / 15 |
| unimodular collapsing seed patches (must be 0) | 0 | 0 |

Diagnostics that did not complete, reported as such:

- **24 specimens** exceed the 200,000-state cap of the collared occurrence
  graph, so their collar and pump-lift diagnostics are inconclusive. Their
  productivity verdict is decided before those diagnostics (commit
  `bb79c1c`; the first run decided it last and so skipped it), and all 24 are
  productive. The figures above combine the first full run with a run of the
  same survey over those 24 specimens; the survey is deterministic.
- **12 specimens**, one orbit under relabelling and reversal (representative
  `0 -> 1, 1 -> 2, 2 -> 022102`), keep a collar collision at the survey cap of
  radius 6 without a collapsing seed patch by level 6.

The separation radius beyond the survey's cap is the subject of §9.

## 7. Exploratory bounded BPA sweep on the longest-image ≤ 4 slice

**Evidence class:** finite-domain evidence on the stated slice and budgets
only. A build that exhausts a budget is inconclusive; it is neither a
counterexample to G1 nor evidence of termination. Nothing here bears on
G1b-2 in general.

`kernel/bpa_total_length_sweep.mojo` builds `B_sigma` with
`psc.bounded_bpa.build_bounded` for the 14,670 specimens of §4 with longest
image at most 4, under the shared 20,000-state cap and a state-length budget
of 100,000 letters. A state-count cap alone did not bound memory here: on the
first attempt one specimen grew a single automaton past 9 GB while staying
under 20,000 states.

| longest image | specimens | terminated | exhausted (state length) | non-productive | largest `B_sigma` | longest state |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 72 | 72 | 0 | 0 | 32 | 16 |
| 3 | 4,482 | 4,482 | 0 | 0 | 1,502 | 48,020 |
| 4 | 10,116 | 9,996 | 120 | 0 | 4,305 | 62,707 |

The longest-image ≤ 3 rows are the standing corpus, and their longest state,
48,020, matches the figure recorded in `docs/proof-ladder.md`. No build
exhausted the state count. The sweep exits non-zero because 120 builds are
inconclusive.

The 120 inconclusive specimens form one structural family: image lengths
(1, 3, 4) with one letter sent to the cube of another (for example
`0 -> 1, 1 -> 222, 2 -> 0222`), determinant 3, and one of two characteristic
polynomials, `x^3 - 2x^2 - 3x - 3` (72 specimens) or `x^3 - 3x^2 - 3`
(48 specimens). An exploratory probe of `0 -> 1, 1 -> 222, 2 -> 0222` (not a
sweep) under larger length budgets finds at most 102 states, while the
longest state grows from 85,719 letters to 280,899 and then exceeds 400,000.
The ratio 280,899 / 85,719 ≈ 3.2770 is close to the Perron root
β ≈ 3.2790 of `x^3 - 3x^2 - 3`, as if one irreducible balanced pair kept
inflating with almost no coincidence cut. The chain terminates:
`docs/bpa-termination-by-overlap-depth-2026-10-02.md` proves that a
productive seed-patch overlap graph of largest first-coincidence depth `D`
bounds every balanced-pair state by `2 beta^D ell_max`, and this specimen's
graph is productive with `D = 19`, giving a bound of about `4.5e10`
letters. The budget exhaustion is growth towards that bound, not an infinite
automaton, and the same argument gives a finite `B_sigma` for all 120
inconclusive specimens and for the whole class of §6.

## 8. Follow-up tasks

1. Mathematical review of Proposition 1 of
   `docs/bpa-termination-by-overlap-depth-2026-10-02.md` (manuscript
   Proposition 5.46), now recorded in the ledger as `G1OverlapRoute`.
2. Decide whether finiteness already follows from every reachable overlap
   reaching a half-coincidence, as Sirvent–Solomyak Theorem 5.6 suggests
   (`docs/bpa-overlap-depth-literature-gate-2026-10-02.md` §6).

## 9. Completed deterministic separation follow-up — 2026-10-02

`kernel/separation_radius_total_length_sweep.mojo` surveys the same complete
24,486-member class in corpus order. It reuses the reviewed occurrence and
proper-power contracts of `psc.overlap_collar`; this is a replay extension,
not a new recognizability diagnostic or a universal invariant. The prior
literature gate and countermodel are recorded in
`p1-overlap-collar-2026-09-16.md` (§3.2 and its literature references).

Explicit budgets: overlap states 20,000; collared occurrence states
2,000,000; separation radii 0–12 inclusive. Proper-power seed witnesses are
searched through level 6, as in the existing survey. A witnessed collapse is
reported as structurally nonseparating with its exact seed pair and level;
it is not assigned a fictitious finite radius. Every remaining specimen is
searched from radius zero, and only its first fully closed collision-free
graph supplies a radius. A missing collapse witness proves nothing.

Every specimen emits its image triple and outcome. Radii above 6 additionally
emit the canonical relabelling/reversal representative; orbit totals follow
in deterministic corpus order. State caps, radius exhaustion and other errors
retain the specimen as inconclusive and force a nonzero exit. Histogram lines
are partial unless the final `COMPLETE` receipt is reached. The dedicated
workflow preserves the full log even on failure.

**Execution status:** complete. [Workflow run 36966474792](https://github.com/larsbx/pisot-substitution-conjecture-research/actions/runs/36966474792)
passed on source head `9a59dcd4a8fe22958ab2d36cfa8ab8c9c5ce7aab`, subsequently
merged as `7c7cf103a7ca1743ea8065b230249ace8855637f` (PR #184).
Canonical Mojo regressions, claim receipts, governance and the exhaustive
sweep all passed in that run. Its exact artifact, full per-specimen log,
receipts and derived summary are retained in
[`archive/2026-10-02/separation-radius-total-length/`](../archive/2026-10-02/separation-radius-total-length/README.md).

| Least finite separation radius | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Specimens | 0 | 2,264 | 13,688 | 6,092 | 1,230 | 288 | 60 | 0 | 0 | 12 | 0 | 0 | 0 |

- **23,634** specimens have a decided least finite radius; maximum `9`.
- **852** have an exact proper-power seed-patch witness by level `6`,
  establishing structural nonseparation under the existing occurrence
  contract. They have no assigned finite radius and are not resource caps.
- **0** are inconclusive. The two categories sum to **24,486**.

Exactly the following 12 specimens exceed radius `6`, and each separates at
radius `9`. Image triples use `σ(0)/σ(1)/σ(2)`; their shared canonical
relabelling/reversal representative is **`012001/2/0`**, equivalent to the
previously probed `1/2/022102`:

| | | |
| --- | --- | --- |
| `1/2/022102` | `1/2/201220` | `1/120112/0` |
| `1/211021/0` | `2/0/122012` | `2/0/210221` |
| `2/011201/1` | `2/102110/1` | `012001/2/0` |
| `021002/0/1` | `100210/2/0` | `200120/0/1` |

The archived log's specimen sequence matches an independently screened
exact Python corpus: every member occurs once, in canonical order. Its
histogram and orbit totals agree with its records, and all emitted power
witnesses replay exactly. The artifact ZIP SHA-256 is
`545ab0e762446810c439950608f2700dea3027b6538305f0e810148bd75abb61`;
the uncompressed log SHA-256 is
`b9f7ccb1dd43bae7c1867ee50bd9b30a40fc45c6405f54bafc1dc54e12037a8f`.
The archive includes a reproducible independent receipt checker and
negative-control tests for truncation, omissions, inconclusive records and
changed histogram counts. This checker validates receipt integrity and
power witnesses; it does not independently recompute separation radii.

Two further checks, from a separate local run:

- **Independent recomputation.** The receipt checker above validates the
  log's integrity and power witnesses but does not recompute radii. An
  independently written exploratory driver (radius cap 12, collapse level
  12, 1,000,000 collared states; commit `be8eb9c`, later removed in favour of
  the canonical sweep) recomputed them on all 24,486 specimens with none
  capped or failed. It gave the same radius distribution, the same 12
  radius-9 specimens, and 852 survivors at radius 12, every one with a
  collapsing patch. A local run of the canonical sweep also reproduced the
  distribution above, ending with the same `COMPLETE` receipt.
- **The 24 collar-cap specimens of §6.** All 24 specimens whose collar
  diagnostics exhaust the 200,000-state cap of the swap-overlap survey are
  decided by the canonical sweep under its 2,000,000-state budget: 12
  separate at radius 2 and 12 at radius 3, and none is structurally
  nonseparating. In the swap-overlap survey itself they remain inconclusive.

This completes the separation follow-up only. The earlier pump-lift
failures in §6 were not re-run by this dedicated survey. Absence of a
collapsing patch through level `14` remains the earlier single-specimen
probe, not a new 24,486-member result. #84, #138, #139 and general PSC remain
open. No ledger, manuscript or theorem status is promoted.
