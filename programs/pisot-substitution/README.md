# Pisot Substitution Conjecture Research Program

Automated research workspace for the Pisot Substitution Conjecture (PSC), with emphasis on reproducible experiments, conjecture tracking, manuscript hygiene, theorem-audit automation, and exact finite certificates.

Repository structure and authority planes are declared in `ESTATE.toml`
(estate template `estate-repository-v2`, as in `larsbx/langlands-lab`); see
`ARCHITECTURE.md`.

## Implementation default

**Mojo is the canonical implementation language for executable research code in this repository.** New algorithms, exact finite-state machinery, census code, and performance-sensitive proof instrumentation should land in [`kernel/`](kernel/) first and use Mojo-native data/layout optimizations.

Python under [`reference/psc_research/`](reference/psc_research/) is a secondary reference/oracle and prototyping layer. Once a Mojo implementation exists, the Mojo module is the executable source of truth. See `AGENTS.md` for the detailed policy.

The generated [mathematical-object catalogue](docs/mathematical-object-catalogue.md)
provides a browsable taxonomy with explicit canonical-Mojo and independent-oracle
links. Its single machine-readable source is `docs/catalogues/mathematical_objects.toml`.

Censuses, catalogues and the taxonomies of the objects they classify are built
on one shared library (`kernel/psc/corpus.mojo`, `histogram.mojo`, `carrier.mojo`,
`symmetry.mojo` and the defect kernels), so a driver is a survey over the corpus
rather than a private copy of it. `kernel/pixi.toml` has one task per driver and
`pixi run test` loops over every `kernel/tests/test_*.mojo`. See
`docs/mojo-census-library-2026-09-16.md`, and
`docs/mojo-lookup-caches-2026-09-17.md` for the exact-arithmetic results the
drivers now look up instead of recomputing.

## Current mathematical state

Start here:

1. `docs/research-roadmap-2026-09-21.md` — live completion roadmap, including the #138 aligned branch, #139 strict-zipper branch, Level 2, hypothesis firewall, and prioritized closure criteria.
2. `docs/p1b-strict-zipper-literature-gate-2026-09-21.md` — completed #139 transfer audit and exact open adelic periodic-offset hitting obligation.
3. `docs/current-proof-architecture-2026-09-14.md` — canonical theorem architecture.
4. `docs/completion-ledger-2026-10-02.md` — latest merged weekly completion snapshot, refreshed to `main@ff9e5d3`; mathematical/evidence additions through PR #188 and the complete 24,486-specimen separation record.
5. `docs/claim-status-and-source-map-2026-09-13.md` — authoritative status/source taxonomy, updated through the current architecture reconciliation.
6. `docs/tier2-bridge-salvage-2026-09-23.md` — research-taxonomy note separating termination-style Descent Bridges from recurrent arithmetic Growth Bridges; moves no theorem status.
7. `docs/conjecture-ledger.md` and `docs/proof-ladder.md` — live prose dependency views.
8. `manuscripts/PSC_balanced_pair_state_2026-09-13.tex` — publication-form state-of-program exposition.

### Headline: one open premise on the shortest PDS route

The shortest current sufficiency chain is

```text
primitive irreducible Pisot
=> bounded discrepancy                                  [PROVED]
=> finite seed-patch overlap graph                      [PROVED]
=> one swap seed has only productive reachable overlaps [OPEN]
=> coincidence density one / dense good set             [PROVED]
=> pure discrete spectrum                               [IMPORTED theorem]
```

The only open premise on this route is **seedwise overlap productivity (Open Problem 5.35, issue #84)**. Manuscript Theorem 5.38 therefore no longer requires finite BPA / G1.

### Finiteness is now tied to the conjecture, not to the method

Three results of 2026-10-02/04 changed the shape of the programme. They add no
proof of PSC and move no open premise, but they settle how finiteness relates
to everything else.

1. **G1 is a necessary condition for PDS, not an artefact of the
   balanced-pair method.** Pure discrete spectrum implies finite `B_sigma`
   (manuscript Proposition `prop:PDS-implies-G1`, ledger `PDSImpliesRepoG1`,
   proved by the Theorem S route; *independently audited 2026-10-04, human
   review pending*). So the conditional main theorem (`thm:main-conditional`,
   G1 plus SCC Producer gives PDS) is not merely one sufficient route among
   possible others: any proof of PSC makes G1 true as well, and a substitution
   with an infinite `B_sigma` would be a counterexample to PSC.
2. **Former Open Problem 4.24 is answered in full.** PDS implies termination
   with coincidence from **every** seed `(ab,ba)`, legal factor or not
   (manuscript Theorem `thm:seedwise`, ledger `PDSImpliesSeedwiseTermination`,
   using the imported `StrongCoincidenceFromPDS`). The repository's all-seed
   graph is therefore covered, not just one convenient seed.
3. **Finiteness needs only half of the obstruction problem.** G1 now has three
   alternative conditional routes — G1b-2 renewal finiteness, all-seed overlap
   productivity (Proposition 5.46), or all-seed strict-zipper exclusion alone
   (Proposition 5.47) — each still carrying one open premise. Because the
   half-coincidence route needs only a common vertex rather than a
   coincidence, **G1 requires only the strict-zipper branch (#139); the
   strong-coincidence branch (#138) is needed for productivity and PDS, not
   for finiteness.**

Both new routes are the mechanism of Sirvent–Solomyak (2002) Theorem 5.6,
transferred to the repository's possibly illegal swap seeds with an explicit
bound; the imports behind Theorem S assume neither unimodularity nor
irreducibility. See `docs/bpa-termination-by-overlap-depth-2026-10-02.md`,
`docs/coincidence-rank-imports-literature-gate-2026-10-04.md`,
`docs/side-notes-ledger.md` §7 for the review record, and
`docs/audit-2026-10-04.md` §B for an independent re-derivation.

Keep the two productivity hypotheses separate. Theorem 5.38 needs only `OP_seed`: every overlap reachable from one selected swap seed is productive. Manuscript Open Problem 5.35 states the stronger `OP_all`: every vertex of the union overlap graph is productive. Proposition 5.39(iii), the all-pairs strong-coincidence consequence, the every-vertex hitting formulation, and the unimodular equivalence with PDS apply to `OP_all`, not to `OP_seed`. No one-seed-to-all-vertices implication is claimed. See `docs/audit-2026-09-20.md` §C. *Correction 2026-10-08:* one does hold through pure discrete spectrum, at the review status of the October 4 chain: `OP_seed` for one seed gives PDS (Theorem 5.38), and PDS gives productivity of every potential overlap (Corollary FP″). Theorem SC of `docs/p1-seed-strength-2026-10-08.md` records the equivalence. The two hypotheses still differ as proof targets, but not in truth.

The current strict-zipper attack retains actual ordered child occurrences and
certifies their exact affine recurrence `w'=Mw+q-p`. A productive
determinant-two regression has a six-edge zero-shift-free affine cycle, so the
next universal step is explicitly a child-closure plus
recognizability/full-internal-space theorem, not a bare cycle exclusion.

This does **not** mean the stronger structural problems are solved:

- **G1b-2 renewal finiteness / finite BPA (G1)** remains open (issue #44), but is now a parallel stronger theorem rather than a prerequisite of Theorem 5.38. G1 also follows from all-seed overlap productivity by the overlap-depth route, and from all-seed strict-zipper exclusion alone by the half-coincidence route (`docs/bpa-termination-by-overlap-depth-2026-10-02.md`).
- **Concentration (`K2=0`)** and **general wedge productivity (`K2!=0`)** remain open on the finite-BPA/SCC route (issue #43 covers the concentration branch).
- **SCC Producer** remains open generally.
- **Realization / coincidence-rank** remains an audited open bridge with G0–G6 obligations.
- **PSC remains open.**

### Established primary-route inputs

- **Unique decodability:** repository-proved from full incidence rank / the defect theorem. UD is derived, not assumed.
- **G1b-1 bounded discrepancy:** independently reconstructed and proved in PR #69; uses primitivity + Pisot spectrum, not unimodularity or UD.
- **Finite seed-patch overlap graph:** repository-proved in PR #72 from bounded discrepancy, with an explicit finite coordinate bound and no G1 assumption.
- **Full-rank bad-set constraint:** PR #76 proves that a nonempty child-closed noncoincidence overlap set has full rational intersection-vector rank and that its child-count matrix inherits the Galois spectrum of `M`. A bad set is algebraically rich, not rank-deficient.
- **Coincidence density:** repository Lemma 5.36 identifies overlap productivity with coincidence density one / density of the eventual-coincidence good set.
- **Density to PDS:** Barge–Štimac–Williams is imported with exact hypotheses audited in PR #77 / manuscript Imported Theorem 5.37.
- **Endpoint-aligned structure:** PR #82 identifies offset-zero/right-aligned overlaps with prefix/suffix strong coincidence and proves the exact prefix-Parikh boundary-hitting criterion.
- **Obstruction normal form in the manuscript:** Propositions 5.43–5.44 and Lemma 5.45 state and prove the closed irreducible obstruction, the aligned-versus-strict-zipper dichotomy (with first-/last-letter closure of the aligned pairs), and the ordered cycle equation with its purely periodic offset expansion.
- **Contracting lower bound:** PR #87 proves that a boundary hit at level `m` forces `|ς(t)| ≤ C_ς Σ_{s≤m} |ς(β)|^{-s}` for every contracting embedding (Proposition 5.42, decided exactly in `Q(β)`); on the corpus this lower bound is at most 8 while the hitting depth reaches 17, a gap of up to 14 inflations that this magnitude bound does not explain (the gap includes the slack of the bound; no further attribution is drawn).
- **Ordered affine/context boundary:** ordered occurrences satisfy the exact affine recurrence, but the determinant-two calibration reaches one affine child state through unequal one-step paired prefix-suffix addresses. Affine equality is therefore not a symbolic pump-deletion criterion. The radius-`m` collar (`docs/p1-overlap-collar-2026-09-16.md`) is exact: on the determinant-two graph one letter of context on each side resolves one-step ancestry, while 120 corpus specimens exhibit the precisely classified proper-power collapse. The seed-relative multiple-edge accounting is now proved (`docs/p1-overlap-seed-growth-bridge-2026-09-17.md`): occurrence-labelled paths count realized residual overlaps per inherited seed period, including repeated child types, and periodic collapse does not invalidate the forward update. The remaining bridge is the rigidity step excluding full-growth, child-closed, nonproductive realized occurrences; generic Perron growth and bounded-context equality do not do this.

### Current theorem target

Issue #84 is the primary completion issue. The preferred attack is to assume a **minimal finite reachable child-closed nonproductive overlap set** and combine:

- full rational rank;
- inherited child-count spectrum;
- ordered exact descendant offsets;
- prefix-Parikh boundary avoidance;
- Pisot contraction;

until a boundary hit / coincidence or an impossible finite configuration is forced.

Proving all seeds or every overlap vertex is stronger than necessary; one periodic swap seed built from distinct tile types per substitution suffices for Theorem 5.38. No substitution-language legality assumption is used.

### Exact finite evidence

On the exact 4,554-member ternary PIP short-image corpus:

- maximum reachable discrepancy: `14`;
- a reachable balanced-pair state has length `48,020`;
- seed-patch overlap graphs built / capped / failed: `4,554 / 0 / 0`;
- total overlap vertices: `1,118,850`;
- largest overlap graph: `2,640` vertices;
- specimens with a nonproductive overlap: `0`;
- maximum first-coincidence depth: `18`;
- maximum first left-aligned depth: `17`;
- maximum prefix/suffix strong-coincidence depth: `15`;
- contracting lower bound on the hitting level (Proposition 5.42): at most `8`, excess of the hitting depth over it at most `14`;
- every specimen satisfies the tested two-sided strong-coincidence condition.

The degree-two and degree-three fail-closed carrier certificates also have zero survivors in their exact stated domains. These are finite-domain theorems/evidence according to their individual completeness contracts; none proves the general PSC.

On the broader class of all 24,486 ternary primitive irreducible Pisot
substitutions with total image length at most 8, the deterministic separation
sweep is also complete at its declared caps:

- 23,634 specimens have a decided finite separation radius: `2,264` at radius
  `1`, `13,688` at `2`, `6,092` at `3`, `1,230` at `4`, `288` at `5`, `60`
  at `6`, and `12` at `9`;
- 852 have an exact proper-power seed-patch witness by level `6` and are
  structurally nonseparating under the existing occurrence contract;
- 0 specimens are inconclusive at the sweep's 2,000,000-state and radius-12
  budgets; and
- an independent driver reproduced the distribution, the 12-member radius-9
  orbit, and the 852 collapsing survivors.

This is exact finite-domain evidence, not a completeness theorem for arbitrary
substitutions. It does not close issues #84, #138, #139, G1, or PSC. See
`docs/lost-depth-indexed-formulation-2026-10-01.md` §9 and the archived
receipts under [`archive/2026-10-02/separation-radius-total-length/`](archive/2026-10-02/separation-radius-total-length/).

## The programme in context

Outside this repository, PSC is **proved for two letters** (Barge–Diamond
2002, Hollander–Solomyak 2003) and **open for three**, the unimodular case
included. For `d >= 3` the literature has two kinds of result. It proves
structured families: β-substitutions (Barge 2018), substitutive Arnoux–Rauzy
(Berthé–Jolivet–Siegel 2012), and a.e. S-adic Arnoux–Rauzy (Berthé–Steiner–
Thuswaldner 2019). It also verifies single specimens: Tribonacci (Rauzy
1982), Kol(3,1) (Baake–Sing 2004), and the Sirvent–Solomyak balanced-pair
examples.

This programme sits between those two kinds of result:

| | Literature | This repository |
| --- | --- | --- |
| general ternary PSC | open | open; one premise left on the shortest route (#84) |
| ternary size classes | specimen by specimen | PDS on 145,806 PIP specimens (images ≤ 4 or total ≤ 8), conditional on unreviewed Proposition V and Theorem B |
| ternary strong coincidence | open | 0 failures on 408,798 specimens (total ≤ 10) |
| PDS vs. BPA finiteness | ABBLS Thm 5.3, "one seed suffices" | PDS ⇒ G1 and every-seed termination (audited, human review pending) |
| regime | geometric tools mostly unimodular | all PIP; unimodularity never assumed |

Every PIP example in the circulated ternary list is already settled. Each one replays on
`B_sigma` with termination and coincidence (pinned by
`kernel/tests/test_ternary_literature_specimens.mojo`). One example from the
circulated list, `123, 1, 1132`, has `det M = 0` and is not a PSC instance.
See [`docs/motivations/`](docs/motivations/README.md), in particular
[`ternary-literature-context-2026-10-07.md`](docs/motivations/ternary-literature-context-2026-10-07.md).

## Generality firewall

The project deliberately targets the non-unimodular primitive irreducible Pisot setting. A general theorem must not silently add:

1. tile-length `Q`/`Z` independence as an independent hypothesis — derive it from irreducibility where used;
2. unique decodability as an independent hypothesis;
3. finite injectivity, prefix/suffix permutation, or boundary-injectivity assumptions;
4. unimodularity `|det M|=1`;
5. a purely Euclidean internal-space model where a non-unimodular argument requires more structure;
6. discreteness of `pi_s(Z^A)`;
7. global realization of a merely formal recurrent object;
8. completeness of a finite corpus/collar bound without an independent theorem.

## Stronger parallel programmes

### G1 / renewal finiteness

G1b-1 is proved; G1b-2 remains the exact missing theorem for finite BPA:

```text
realizable labelled first-return words
=> level-scaled contracting/Rauzy address
=> finite local return types / uniform discreteness
=> G1b-2
=> G1.
```

This route must preserve non-unimodular geometry and label/order data.

### Finite-BPA SCC route

Under G1, nonproductivity reduces to a finite closed/sink carrier and splits by first defect:

```text
K2 == 0  => concentration problem [OPEN]
K2 != 0  => wedge productivity    [OPEN].
```

The carrier-span theorem is proved; full span alone does not imply productivity. The exact 4,554-corpus degree-two and degree-three exclusions remain finite-domain theorems only.

### Realization / MEF route

The realization/coincidence-rank chain is an open bridge / certificate programme. Formal recurrence, global realization, and finite collar survival must remain distinct.

Research references: the [Penrose 2D interface bridge](docs/bridges/penrose-2d-to-psc-interface-program.md)
(PR #154) supplies analogies for renewal finiteness and realization, with a
narrower comparison to strict-zipper hitting. The [Padovan / Plastic-A conjecture
program](docs/post-proof-padovan-plastic-a-conjectures-2026-09-23.md) (PR #157)
records benchmark research targets. Both are non-load-bearing; #84, #138,
#139, G1, and general PSC remain open.

## Source/provenance status

The live project no longer depends on recovery of a historical `PSC_PROOF_v16` file:

- G1b-1 is independently repository-proved;
- degree-two carrier propagation is independently repository-proved;
- concentration is an open mathematical gate, not source-pending;
- the realization chain is an open bridge, not source-pending;
- the P0 manuscript hypothesis/attribution corrections are implemented.

Issue #45 is therefore closed as a completed status/source reconciliation task. The missing v16 artifact remains useful archival metadata only.

## Verification layers

| Priority | Layer | Tool | Scope |
|---|---|---|---|
| **Canonical executable** | [`kernel/`](kernel/) | Mojo | Source-of-truth exact implementation: PIP decision, BPA construction, structural C4 machinery, endpoint/C3/C4/defect finite censuses, and optimized corpus instrumentation. The reusable kernels under [`kernel/finite_exact/`](kernel/finite_exact/), [`kernel/substitution_dynamics/`](kernel/substitution_dynamics/), [`kernel/finite_linear_algebra/`](kernel/finite_linear_algebra/), [`kernel/parallel_fold/`](kernel/parallel_fold/), [`kernel/finite_graph/`](kernel/finite_graph/), [`kernel/finite_automata/`](kernel/finite_automata/), and [`kernel/mojo_smoke/`](kernel/mojo_smoke/) are vendored from one pinned `larsbx/finite-math-kernels` commit. |
| Formal state/dependency | [`proof/tla/`](proof/tla/) | TLA+ / TLC | BPA state-machine models and the machine-checked proof-dependency ledger, generated from the proof-record table in `tools/make_ledger.py` (`proof/tla/ledger.json` is its serialized output). |
| Deductive finite algebra | [`proof/PscVerif/`](proof/PscVerif/) | Lean 4 + Mathlib | Machine-checked finite algebra from the spectral module, with an axiom audit. |
| Secondary oracle | [`reference/psc_research/`](reference/psc_research/) + [`tests/`](tests/) | Python | Independent reference implementations, counterexample generation, and regression/oracle comparisons during migration to canonical Mojo modules. |

The thirteen logical packages vendored from `larsbx/finite-math-kernels` are checked against one commit and per-file digests in `vendored.toml` by `tools/vendoring/check_vendored_sync.py` (itself vendored) in CI. Status surfaces are checked against the claim ledger in `claim_governance.toml` by the vendored audit package under [`tools/claim_governance`](tools/claim_governance). The TLA+ ledger, its TLC models, `proof/tla/ledger.json`, the claim entries of every ledger node, `docs/ledger-index.md`, and the typed relationship graph `docs/claim-relationship-graph.json` are generated from the one table of proof records in `tools/make_ledger.py` through the vendored [`tools/proof_records`](tools/proof_records) package; edit that table and regenerate, since CI fails if any output is stale or hand-edited. Every Mojo test names the ledger claim or the contract it guards (the vendored `kernel/mojo_smoke/claims.mojo`), and the `coverage` check reads the receipts of the run, so a claim whose warrant is a finite computation cannot lose its regression unnoticed.

Run everything:

```bash
./tools/verify_all.sh
```

Unavailable toolchains are reported as skipped; a skip is not a passing proof.

The generated [proof bank](docs/proof-bank.md) inventories every governed
claim, named Lean proof and apparent source statement in the claim-policy
scope, with explicit evidence and partial-formalization boundaries. Provision
the pinned Lean/Lake project with `./tools/setup_lean.sh`, add
`${ELAN_HOME:-$HOME/.elan}/bin` to `PATH`, then run `./tools/check_lean.sh`.
The remote session hook provisions it automatically. CI and local verification
replay the same complete axiom audit even when the library build is cached.

## Repository layout

- `.` — planes and authority: ESTATE.toml, ARCHITECTURE.md
- [`kernel/`](kernel/) — canonical Mojo kernel + finite censuses (pixi workspace)
  - [`finite_exact/`](kernel/finite_exact/) — BigZ, Q, closed intervals (vendored, finite-math-kernels)
  - [`substitution_dynamics/`](kernel/substitution_dynamics/) — words, balanced pairs, automaton (vendored)
  - [`finite_linear_algebra/`](kernel/finite_linear_algebra/) — Mat3, RREF, rank-three tensors, W_3, integer vectors (vendored)
  - [`parallel_fold/`](kernel/parallel_fold/) — deterministic MAX-backed ordered map/fold (vendored)
  - [`finite_graph/`](kernel/finite_graph/) — SCCs, union-find, F2 signing (vendored)
  - [`finite_automata/`](kernel/finite_automata/) — deterministic finite automata (vendored)
  - [`mojo_smoke/`](kernel/mojo_smoke/) — claim and contract receipts of a test (vendored)
  - [`psc/`](kernel/psc/) — reusable Mojo research kernel
  - [`tests/`](kernel/tests/) — canonical executable regressions
- [`proof/`](proof/)
  - [`PscVerif/`](proof/PscVerif/) — Lean 4 + Mathlib finite-algebra proofs
  - [`tla/`](proof/tla/) — TLA+ BPA models; Ledger.tla, MCLedger*, ledger.json generated by tools/make_ledger.py
- [`reference/psc_research/`](reference/psc_research/) — non-authoritative Python reference layer
- [`oracles/`](oracles/) — independent Python census oracles; never acceptance
- [`experiments/`](experiments/) — growing PIP research corpus
- [`schemas/`](schemas/) — contracts: fixture schemas, p1b JSON contracts
- [`tests/`](tests/) — Python oracle/regression tests
- [`evidence/`](evidence/) — recorded run outputs, pinned by SHA256SUMS
- [`sources/`](sources/) — imported external sources, pinned by SHA256SUMS
- [`tools/`](tools/) — repository tooling (verify_all.sh, generators, checks) + vendored audit, ledger and vendoring packages
- [`docs/`](docs/) — live proof architecture, audits, ledgers; catalogues/ source
- [`manuscripts/`](manuscripts/) — publication drafts and referee records
- [`archive/`](archive/) — superseded records, verbatim
- [`ESTATE.toml`](ESTATE.toml) — estate manifest (estate-repository-v2, pinned audit)
- [`claim_governance.toml`](claim_governance.toml) — claim ledger policy
- [`vendored.toml`](vendored.toml) — commit and digest pins of the vendored packages
- [`AGENTS.md`](AGENTS.md) — Mojo-first implementation and optimization policy

## Quick start — Mojo

```bash
cd kernel
pixi run test
pixi run verify
```

Python remains available as an independent oracle:

```bash
python -m venv .venv
. .venv/bin/activate
pip install -e .[dev]
pytest
```

but new executable research logic should not default to Python.

## Standing regime

Unless a note says otherwise:

- `sigma: A -> A+` is primitive;
- `det M_sigma != 0`; **unimodularity is not assumed**;
- `char(M_sigma)` is irreducible over `Q`;
- `beta` is the Perron eigenvalue and Pisot.

## Research discipline

1. Do not promote empirical patterns to theorems.
2. Every load-bearing theorem must be proved in-repo or cited precisely with hypotheses checked.
3. Record failed routes so agents do not repeat them.
4. Keep G1 separate from statements conditional only on a given finite closed carrier.
5. Keep the one-seed overlap theorem distinct from stronger all-seed/all-vertex claims.
6. Do not stack fixed-size sieves without a credible uniform completeness theorem.
7. Default executable work to Mojo; Python is an oracle/prototype.
8. Fail closed on caps/incomplete exact computations and retain replayable countermodels.
