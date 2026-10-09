# Cross-program bridge audit: PSC balanced-pair route and NLAP-JT finite Mandelbrot fibers

**Status:** comparative audit of two repositories, dated 2026-09-12. It records structural correspondences, corrections found by comparison, capability gaps, and ranked bridging contributions. It proves neither the Pisot Substitution Conjecture (PSC) nor Mandelbrot local connectivity (MLC), and it promotes no correspondence to a theorem. Everything below is labelled with one of the status values in section 0.2. Project terms used here are governed by `docs/terminology-registry.md` in NLAP-JT and by `docs/conjecture-ledger.md` in PSC.

Repositories compared, at the heads on the shared branch `claude/isomorphisms-gaps-analysis-jkvo3f`:

| Tag | Repository | Head | Conjecture | Finite object |
| --- | --- | --- | --- | --- |
| `PSC:` | `larsbx/pisot-substitution-conjecture-research` | `f2afa9e` | pure discrete spectrum for primitive irreducible Pisot substitutions | balanced-pair automaton `B_sigma` |
| `NLAP:` | `larsbx/NLAP-JT` | `652f7b9` | triviality of all Mandelbrot fibers (MLC, Schleicher form) | separator-catalogue prefixes `Cat_k` |

Verified-here markers: `[V]` means the statement was checked in this session by reading or executing the repository; `[L]` means it rests on a literature statement that must be pinned to an exact theorem before any ledger uses it.

## 0. Front matter

### 0.1 Terminology declaration: certificate-stream fibre schema

Terminology declaration: A *certificate-stream fibre schema* is a tuple `Sigma = (X, ~, (Cert_k)_k, R, Phi)` as defined in section 1. It is the common shape into which both repositories' proof architectures are placed for comparison.

Genealogy: Schleicher's fiber definition by rational-ray separation (NLAP); the Barge--Kwapisz coincidence rank and the maximal equicontinuous factor (MEF) of a Pisot substitution tiling (PSC); the balanced-pair algorithm of Sirvent--Solomyak as surveyed by Akiyama--Barge--Berthé--Lee--Siegel; standard recursion-theoretic vocabulary (a `Sigma^0_1` event and its co-r.e. residual).

Bridge claim: Definition-only. The schema is a bookkeeping template. Each row of the instantiation table in section 1.2 is separately labelled THEOREM, CONDITIONAL, DEFINITION, ANALOGY, or FALSE. No claim is made that the two instantiations are isomorphic as dynamical systems, and the word *isomorphism* is used below only for named maps with stated domain, codomain, preserved structure, and leaks.

Known leaks: The PSC fibre statement is measure-theoretic (almost every MEF fibre is a singleton), the NLAP fibre statement is topological (every fibre is a singleton). The two `Sigma^0_1` events have opposite polarity (section 1.3). PSC states are unary automaton states, NLAP predicates are binary on representatives. Finiteness of the state space is a hypothesis on the PSC side (`G1`) and is false by design on the NLAP side. Nothing in the schema transfers a proof.

Use discipline: Use only in this document and in documents that cite it. Do not cite the schema as evidence for either conjecture, and do not use a row of the correspondence table as a lemma.

### 0.2 Status vocabulary

| Label | Meaning |
| --- | --- |
| THEOREM | proved in the named repository file, or an exact literature statement already pinned by that repository |
| CONDITIONAL | a theorem in one repository whose hypotheses name an open gate |
| DEFINITION | a correspondence that holds by unfolding definitions; no mathematical content transfers |
| ANALOGY | a structural resemblance with a named leak; heuristic value only |
| FALSE | a claim in one repository that this audit refutes, with the refutation recorded |
| GAP | a capability present in one repository and absent in the other |

### 0.3 Executive summary

- **One schema, opposite polarity.** Both programs reduce their conjecture to "the co-r.e. residual of a monotone finite certificate stream is trivial". PSC's certificate witnesses fibre *collapse* (coincidence); NLAP's witnesses fibre *separation*. Consequently PSC's residual is already a counterexample object, while NLAP's residual needs an extra adapter plus the triviality step (section 1.3).
- **Same retired fallacy.** Each program independently discovered and retired "bounded per-stage state implies global termination" (PSC withdrawn Theorem V5-5.1; NLAP alignment-audit P0). PSC's retired-route list is a tested negative catalogue NLAP does not yet have (section 2, I4).
- **A false rationale in NLAP.** Exact Misiurewicz type is constant on every irreducible factor over `Q`; verified exactly for all `(l,k)` with `l <= 4`, `k <= 2` (section 3, C1). The "squarefree-only, no gcd stripping because Galois conjugates mix types" justification is refuted. The pointwise policy remains sound but the false rationale hides a finite algebraic catalogue object NLAP needs for completeness.
- **Related Galois arguments, now separated.** PSC's carrier-level wedge-span implication is self-contained by irreducibility of `chi_(Lambda^2 M)`; its archived degree-three seed theorem still uses Galois transitivity. NLAP's exact-type invariance remains another instance of a `Q`-rational predicate being constant on Galois orbits (section 5, B2).
- **PSC's open finiteness gate has a geometric twin in which finiteness is a theorem.** The overlap-coincidence algorithm (Solomyak; Akiyama--Lee) ranges over realized overlaps, which are finitely many by finite local complexity and the Meyer property, and decides pure discrete spectrum. PSC's `G1b-2` asks for finiteness of *realizable* reduced balanced pairs. The exact residual is a relative-density statement about simultaneous boundaries (section 5, B1). PSC's manuscript "routes around the contracting space entirely" while its only live Level-2 direction is a contracting address; this needs adjudication (section 3, C5).
- **NLAP's verification stack is currently a specification.** Its main CI is red at the first step on every recent push, its Mojo has never been compiled in CI and uses pre-2025 syntax, and its tests are text scans of source files (section 3, C2--C3). PSC's Mojo, TLA+, and Lean layers execute in CI and are directly portable (section 5, B3--B4).
- **PSC underclaims its census and overclaims one import.** Each of its 4,554 terminating productive BPA runs is, under the literature criterion, a per-substitution certificate of pure discrete spectrum, not "evidence only" (section 5, B5). Conversely `StandardBPAEquivalence` sits in the TLA `ProvedDef` although it is an imported literature theorem whose seed clause the repository itself flags as unverified (section 3, C4).

## 1. The shared schema

### 1.1 Definition

A certificate-stream fibre schema is

```text
Sigma = (X, ~, (Cert_k)_{k in N}, R, Phi)
```

where

- `X` is a class of finite representatives;
- `~` is the classical "same fibre" equivalence on the classical referents of `X`;
- `Cert_k` is a decidable predicate on `X` or `X x X`, monotone in `k` (`Cert_k => Cert_{k+1}`);
- `E := exists k. Cert_k` is the resulting `Sigma^0_1` event;
- `R` is the classical relation `E` is meant to capture, and *adequacy* is `E <=> R`;
- `Phi` is the fibre-triviality conclusion the conjecture asserts on the residual `not E`.

The conjecture in each program has the form

```text
forall x in Dom:  not E(x)  =>  Phi(x).
```

### 1.2 Instantiation table

| Component | PSC | NLAP | Status |
| --- | --- | --- | --- |
| `X` | normalized balanced pairs `(u,v)` reachable in `B_sigma` from seeds `(ab,ba)` | admissible finite representatives: `RootHandle`, `PointVertex`, nest carriers | DEFINITION |
| `~` | same MEF fibre; balanced pairs are fibre-mates by construction (equal Parikh vector, hence equal tile length under `Q`-independence of tile lengths) | Schleicher same-fibre: not separated by any admissible rational-ray separator | DEFINITION |
| `Cert_k` | a coincidence state is reachable from `(u,v)` within `k` inflation-and-cut steps (`productive within k`) | `Separated_k(A,B)`: a certified separator in `Cat_k` places `A`, `B` on opposite sides | DEFINITION |
| `E` | productive | classically separated (after adequacy) | DEFINITION |
| adequacy `E <=> R` | `StandardBPAEquivalence` + `RepoSeedUnionBridge` + `PDSImpliesRepoG1` (open) + the Akiyama--Lee converse used at manuscript line 480 | `SeparatorCatalogueSoundness` + `SeparatorCatalogueCompleteness` + `FiberDefinitionAdapter` | CONDITIONAL in both |
| residual `not E` | closed recurrent nonproductive sink SCC (under `G1`) | `PersistentNonSeparation(A,B)` | THEOREM (PSC, under `G1`) / DEFINITION (NLAP) |
| `Phi` | the residual is empty on reachable states | `BoundaryEquality(A,B)` or an established trivial-fibre tag | DEFINITION |
| finiteness of state space | hypothesis `G1` (open, `G1b-2`) | false by design: the rational-ray catalogue is infinite; replaced by `StrictCarrierRefinementWellFounded` (open) | GAP, see I4 |

### 1.3 Polarity duality `[V]`

Write `E_P` for PSC productivity and `E_N` for NLAP separation.

- `E_P(u,v)` witnesses that the two fibre-mates *identify*: the pair reaches a coincidence, and under the literature criterion this is the finite witness of proximality for that pair.
- `E_N(A,B)` witnesses that `A` and `B` are *not* fibre-mates.

Hence for a pair of distinct classical referents:

```text
PSC:   not E_P  <=>  same fibre and never identified     (a counterexample to PDS once realized)
NLAP:  not E_N  <=>  same fibre                          (a counterexample to MLC only if A != B)
```

The NLAP residual therefore carries one fewer bit than the PSC residual: NLAP has no finite *positive* witness of equality for generic boundary representatives, and `BoundaryEquality` is routed structurally rather than certified. Dually, PSC has no finite *negative* witness: a formal nonproductive SCC is not a certificate of non-PDS because it may be unrealized (`docs/conjecture-ledger.md`, "No realization shortcut"). Each program lacks the certificate polarity the other has. Section 5 B1 identifies the object that would supply PSC's missing negative certificate.

## 2. Correspondences

Each item names the map, what it preserves, what leaks, and its status.

### I1. Fibre to fibre

- Map: MEF fibre `pi^{-1}(x)` of `pi: Omega_sigma -> T_MEF` maps to the Schleicher fibre of a boundary point, i.e. the fibre of the quotient `M -> M_comb` to the combinatorial (pinched-disk) model.
- Preserved: both are fibres of a factor map onto a "combinatorial" model; both conjectures say the factor map is injective in the relevant sense; both programs isolate the fibre-triviality step as the frontier.
- Leaks: PSC injectivity is almost-everywhere (`coincidence rank = 1`), NLAP injectivity is everywhere. Under PDS the exceptional PSC fibres are exactly the boundary points of Rauzy subtiles, and they are decided by the boundary graph of Siegel--Thuswaldner. NLAP's "on-separator, route to boundary equality" case is the topological shadow of that measure-zero exceptional set.
- Status: DEFINITION, with the leak THEOREM-backed on the PSC side `[L]` (Barge--Kwapisz; Siegel--Thuswaldner).

### I2. Residual obstruction extraction

- Map: state `(u,v)` to carrier state; edge "inflate and cut" to "accepted strict refinement"; nonproductive set `NP` to persistent non-separation; closed sink SCC to non-shrinking nested carrier; "productive through a later SCC" to `RefinesToOppositeSideSeparation`.
- Preserved: the forward-closure lemma (`PSC: docs/sink-scc-reduction.md` Lemma 1) has an exact NLAP counterpart in `UW-2` of `NLAP: docs/C1_unresolved_wake_to_carrier_obstruction.md` (a bounded failed search is not persistent evidence).
- Leaks: PSC's Lemma 2 ("a finite nonempty DAG has a sink") is what makes the extraction a THEOREM under `G1`. NLAP has no finiteness, so the DAG argument is replaced by a ranking function on `(unresolved_wake_slot_count, carrier_vertex_count, boundary_candidate_count, missing_link_count)`, and `StrictCarrierRefinementWellFounded` is an open target. The lexicographic measure's fourth coordinate is allowed to *increase* on "missing-link exposure" (`NLAP: docs/C1_canonical_content_refinement_order.md`, case 4), so the order as stated is not obviously well-founded. This is precisely the shape of PSC's retired argument: a bounded quantity per stage does not bound the chain.
- Status: THEOREM (PSC, conditional on `G1`); open target (NLAP); the transfer is ANALOGY.

### I3. Finite witness and its dual

- Map: a Parikh-prefix zero return (`coincidence_boundaries` in `PSC: kernel/psc/bpa.mojo`) maps to a certified separator code (`SeparationLine` in `NLAP: src/separation_grammar.mojo`).
- Preserved: both are finite, canonicalized, monotone-accumulating witnesses; both repositories insist the witness is checkable without the classical object (no analytic point, no realized tiling).
- Leaks: polarity (section 1.3). The PSC witness is unary on automaton states, the NLAP witness is binary on representatives.
- Status: DEFINITION.

### I4. Two-gate architectures and the shared retired fallacy `[V]`

| PSC gate | NLAP block | Relation |
| --- | --- | --- |
| `P5` final PDS bridge audit: `StandardBPAEquivalence`, `RepoSeedUnionBridge`, `PDSImpliesRepoG1`, the Akiyama--Lee converse | `SeparatorCatalogueSoundness`, `SeparatorCatalogueCompleteness`, `FiberDefinitionAdapter` | the same adequacy pair; PSC has it split over three documents and one manuscript remark, NLAP names it once |
| `SCCProducer` via concentration / aux-B | `ResidualClosureNoMissingLinks` | the residual-triviality step |
| `G1` finiteness via `G1b-2` renewal finiteness | no counterpart; `StrictCarrierRefinementWellFounded` substitutes | GAP |
| withdrawn `V5Thm51`: `beta L(s') <= L(s) + D` (bounded discrepancy does not bound state length) | alignment-audit P0: "finite carrier at each step does not imply absence of an infinite chain" | the same fallacy, independently discovered and retired |

- Status: DEFINITION for the dictionary; the retired-fallacy row is THEOREM-grade negative knowledge on the PSC side (explicit counterexamples: 135 difference vertices, first-return data of length at least 17,078; `archive/2026-10-06/status-snapshots/completion-ledger-2026-09-11.md` section II) and prose on the NLAP side.

### I5. Information-losing quotients

- Map: PSC's canonical collision `(001,100)` versus `(021,120)` (same cumulative difference walk, different labelled words; `PSC: docs/p1b-labelled-renewal-program.md` section 1) maps to NLAP's `NoRenamingAsRefinement` and the display-name-blind canonical content record.
- Preserved: both programs concluded that the natural quotient loses the state and both retained two coordinates (PSC: labelled first return plus level-scaled address; NLAP: four sorted finite lists).
- Leaks: PSC established its conclusion by an executable collision census with retained residual witnesses (11,520 residual pairs after the symbolic quotient, a same-depth survivor with equal scaled defect `(-84,-100,-44)`). NLAP has no mathematical counterexample anywhere in its test suite `[V]`; its tests assert the presence of strings in source files.
- Status: ANALOGY; the *method* (counterexample-driven quotient falsification) is a transferable GAP item (section 5, B6).

### I6. Contraction and descent templates

- Map: PSC's ancestry recurrence `x_{k+1} = M x_k + c_{k+1}` with terminal `x_n = 0` (`PSC: docs/c4-pisot-ancestry-finiteness.md`) maps to NLAP's nest refinement `Refines(N_k, N_{k+1})` with diameter bounds.
- Preserved: both are digit-address recurrences (matrix-radix Pisot numeration; kneading/critical-orbit recurrence `Q_{n+1} = Q_n^2 + C`), both need a two-sided control to conclude finiteness of intermediate states.
- Leaks: PSC's control is linear (stable directions forward, Perron direction backward from the terminal zero), so finiteness of intermediate defects is a THEOREM. The quadratic map has no spectral-gap surrogate; the analytic input NLAP names for the analogous shrinking is puzzle shrinkage / a priori bounds, which is the MLC frontier itself. PSC's own negative control (Tribonacci depth-6 nonzero ancestry loop) shows finiteness of intermediate states does not yield a contradiction without recognizability.
- Status: THEOREM (PSC) / ANALOGY (transfer).

### I7. One Galois lemma, opposite uses `[V]`

- Statement `G`: let `f in Q[x]` be irreducible and let `P` be a predicate on roots defined by `Q`-rational polynomial identities or their negations. Then `P` is constant on the roots of `f`.
- PSC use: the historical degree-three seed capture in `archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md` uses `G`. The live degree-two carrier span result no longer needs this application: Proposition 5.20 derives it from the irreducibility of `chi_(Lambda^2 M)`.
- NLAP use: exact Misiurewicz type is a function of the collision pattern `{(i,j) : Q_i(c) = Q_j(c)}`, each member of which is a `Q`-rational identity; hence exact type is constant on each irreducible factor. NLAP currently asserts the negation (section 3, C1).
- Status: THEOREM (elementary); the PSC application is CONDITIONAL on the `Q`-rationality audit; the NLAP application refutes a repository claim.

### I8. Arithmetic completions: profinite coordinates and dyadic boxes `[V]`

- Map: the non-Archimedean factor of PSC's non-unimodular internal space maps to NLAP's dyadic box datum `Dyadic(mantissa, shift)`.
- Detail: PSC's canonical determinant-2 regression `0->1, 1->021, 2->001` has `chi = x^3 - x^2 - 2x - 2`, `det M = 2`, `N(beta) = 2`, and `beta (beta^2 - beta - 2) = 2`. The completion of `Q(beta)` at the prime above `beta` has residue degree one, so it is isomorphic to `Q_2`. The quotients `Z^3 / M^k Z^3` proposed in `PSC: docs/p1b-labelled-renewal-program.md` section 10 are the level-`k` approximations of that completion, up to the index of `Z[beta]` in the maximal order (`disc(chi) = -152 = -2^3 * 19`, so that index must be audited at 2). PSC's residue table modulo `2, 4, 8, 16, 32` is therefore a table of 2-adic ball memberships. NLAP's dyadic endpoints lie in `Z[1/2]`, which is dense in both `R` and `Q_2`, so a single finite record serves as a real interval endpoint and as a 2-adic ball datum.
- Preserved: exact finite representability of both completions from the same integer pair.
- Leaks: for `det M` with an odd prime factor the completion is `Q_p`-based and the dyadic record does not apply; for the Archimedean complex-pair factor PSC needs `R^2` boxes, which NLAP's `ComplexBox` already is.
- Status: THEOREM (the algebraic facts); GAP (no shared kernel exists).

### I9. Methodology

| Discipline | PSC | NLAP | Status |
| --- | --- | --- | --- |
| Mojo-first executable kernel | executes in CI (`pixi run test`, `verify`, four censuses) `[V]` | never compiled in CI; tests are text scans `[V]` | GAP (NLAP) |
| machine-checked dependency ledger | TLA+ `ProofArchitecture` + `Ledger` with TLC invariants `[V]` | `C1_theorem_status.mojo` boolean flags `[V]` | GAP (NLAP) |
| deductive layer | Lean 4 + Mathlib with axiom audit `[V]` | none; roadmap Phase 5 | GAP (NLAP) |
| theorem-tag import metadata | none; imports sit in `ProvedDef` `[V]` | `TheoremTagImport` with hypotheses, conclusion, leak note `[V]` | GAP (PSC) |
| proof-grade arithmetic gate | none; machine `Int` throughout `[V]` | `backend.toml`, `proof_grade = false`, gate rejects Int64 `[V]` | GAP (PSC) |
| lexical firewall | none | no-trig, no-points, terminology, paper-language audits `[V]` | GAP (PSC), but see C2 |
| terminology declarations (genealogy/leaks) | none; private terms `carrier`, `concentration`, `aux-B`, `renewal address` undeclared | registry + manifest + linter `[V]` | GAP (PSC) |
| negative controls / counter-calibrations | synthetic G/F artifact, non-Pisot strict component, Tribonacci ancestry loop `[V]` | none `[V]` | GAP (NLAP) |
| exact census with CI-pinned counts | 4,554 PIP; 5,022 SCCs; 385,926 states; 24 degree-3 `[V]` | two hand examples (`c = -2`, `M_{4,1}`) `[V]` | GAP (NLAP) |
| canonical serialization / hash root spec | none (issue #2 open) | `docs/canonical-serialization.md` `[V]` | GAP (PSC) |

## 3. Corrections found by comparison

### C1. NLAP: exact Misiurewicz type is Galois-invariant `[V]` — status FALSE for the repository's stated rationale

`NLAP: docs/finite-certificate-calculus.md` section 3 states: "Galois conjugates can mix exact-type and lower-type roots inside the same irreducible factor over `Q`. Removing that factor can delete the genuine target root." The first sentence is false.

Proof. For fixed `(i,j)`, `Q_i(c) = Q_j(c)` is the vanishing of `Q_j - Q_i in Z[C]` at `c`, hence holds at every Galois conjugate of `c` if it holds at `c`, and fails at every conjugate if it fails at `c`. The collision pattern `Pat(c) = {(i,j) : Q_i(c) = Q_j(c)}` is therefore constant on Galois orbits, and exact type `(l,k)` is the function `(min preperiod, min period)` of `Pat(c)`. Equivalently, for irreducible `f`, `gcd(f, Q_j - Q_i)` is `1` or `f`.

Exact check performed in this session (sympy, divisibility of `Q_j - Q_i` by each irreducible factor, horizon `H = 7`):

```text
R_{2,1} = C^3 (C+2)                                    types: C->(0,1), C+2->(2,1)
R_{3,1} = C^4 (C+2) (C^3+2C^2+2C+2)                    cubic ->(3,1)
R_{4,1} = C^5 (C+2) (C^3+2C^2+2C+2) F7                  F7    ->(4,1)
R_{2,2} = C^3 (C+1)^2 (C+2) (C^2+1)                     C^2+1 ->(2,2)
R_{3,2} = ... (C^3+C^2-C+1) ...                         ->(3,2)
R_{4,2} = ... (C^8+4C^7+6C^6+6C^5+4C^4+1) ...           ->(4,2)
```

Every irreducible factor carries exactly one exact type. NLAP's own `examples/stress-test-m41.md` already lists `R_{4,1}` factored by type and is consistent with this.

Consequences.

1. The pointwise-exclusion policy remains *sound*, but it is not *necessary*, and gcd-stripping against strictly lower relations never deletes an exact-type root. The prohibition in section 3 and in bridge conjecture C3 rests on a false premise.
2. Exact-type loci are unions of `Q`-irreducible factors of `sqfree(R_{l,k})`: a finite algebraic catalogue object exists for every `(l,k)`. The generalized dynatomic polynomial of Hutz--Towsley is the literature form of this object, and its root simplicity is the fact NLAP calls `MisiurewiczReducedRootSimplicity` `[L]`.
3. `SeparatorCatalogueCompleteness` on the Misiurewicz class becomes checkable by an exact counting identity between factor degrees and rational-angle orbit classes (section 5, B6).
4. The squarefree step is still required, for multiplicity (`C^5` in `R_{4,1}`), not for Galois reasons.

### C2. NLAP: the governance layer has outrun the content; main CI is red `[V]`

- The five most recent `main` runs of `finite-regime-core-audit` (run numbers 263–267) all fail at step 3, "Run no-trig core audit", so every downstream step is skipped, including all proof-object tests.
- Cause: `tools/audit_no_trig.py` bans the token `degree` lexically; the six hits are all *polynomial* degree (`src/poly_witness.mojo:17 var degree: Int64`, `src/poly_interval_eval.mojo:79 # Degree 12`, and four more). A polynomial-certificate project cannot ban the word.
- `tools/audit_terminology.py` reports 41 further findings on the same head, mostly the deprecated term used without migration context in twenty `docs/C1_*` files, plus scoped terms in `docs/mojo_first_execution_policy.md` and `src/alignment_audit_status.mojo`.
- `pytest` on the same head: 16 failed, 290 passed, all failures in the same lexical class.

Nothing in NLAP is currently verified by its own gate.

### C3. NLAP: the Mojo theorem kernel is a specification, not an executable `[V]`

- No CI step installs or runs Mojo; the only `subprocess` use in `tests/` runs a Python oracle.
- `src/*.mojo` uses `fn __init__(inout self, ...)` (17 structs) and `@value` (14 structs). PSC pins `modular >= 26.6` and writes `def __init__(out self, ...)`, `mut`, `ref`, and `Copyable, Movable` traits. The NLAP forms predate that toolchain and are not expected to compile on it.
- `tests/test_krawczyk_joint_scaffold.py::test_p21_demo_is_computed_not_status_asserted` asserts that a substring `verify_p21_krawczyk_c_minus_2(8)` appears in the source; it does not run it.
- `src/cert_types.mojo` states of `KrawczykWitness`: "The current fields are metadata; exact interval enclosures will replace them."

### C4. PSC: an imported theorem is recorded as proved `[V]`

`PSC: proof/tla/Ledger.tla` places `StandardBPAEquivalence` in `ProvedDef`. It is Akiyama--Barge--Berthé--Lee--Siegel Theorem 5.3, and `docs/bpa-literature-bridge.md` section 3 says the seedwise clause "should be checked in the theorem's proof ... rather than inferred from the word 'any'". `ProofArchitecture.tla` has `Proved`, `Withdrawn`, `Assumed` but no `Imported` category carrying hypotheses, conclusion, and leak note. The v16 source-pending results are handled by exclusion only. NLAP's `TheoremTagImport` (`src/mojo_theorem_kernel.mojo`) is the missing structure.

### C5. PSC: two contradictory policies on the contracting space `[V]`

- `manuscripts/PSC_PROOF_next_source_audit.tex` line 128: "The present work routes around the contracting space entirely."
- `docs/proof-ladder.md`, `docs/conjecture-ledger.md`, `docs/current-proof-architecture-2026-09-14.md`: the only live `G1b-2` direction is "level-scaled contracting/Rauzy address => uniform discreteness / finite return types".
- `archive/2026-10-06/status-snapshots/completion-ledger-2026-09-11.md` section X item 5: the archive's do-not-reattempt list contains "Rauzy/DT address".

The comparison in section 5 B1 shows that the contracting-space formulation is the one in which the finiteness PSC needs is a theorem. The three statements should be reconciled in one place rather than left as a manuscript policy, a ledger target, and an archive prohibition.

### C6. PSC: arithmetic is not fail-closed and the Pisot test is cubic-only `[V]`

- `kernel/psc/rational.mojo`, `mat3.mojo`, `renewal_address.mojo` use machine `Int`; `AGENTS.md` rule 8 ("fail closed") is not enforced at the arithmetic level. `M^d delta` at depth 7 is safe, but nothing aborts on overflow.
- `kernel/psc/pisot.mojo::is_pisot_charpoly` handles monic cubics only. Any bridge in section 5 B8 needs degree `n`.

## 4. Gap matrix

`+` present, `-` absent, `~` partial.

| Capability | PSC | NLAP | Transfer direction |
| --- | --- | --- | --- |
| compiled, CI-executed Mojo kernel | + | - | PSC -> NLAP |
| TLA+ proof-dependency ledger with invariants | + | - | PSC -> NLAP |
| Lean 4 deductive layer | ~ (older spectral core only) | - | PSC -> NLAP |
| exact census with pinned counts | + | - | PSC -> NLAP |
| negative controls in the test suite | + | - | PSC -> NLAP |
| theorem-tag import metadata | - | + | NLAP -> PSC |
| proof-grade arithmetic gate | - | + | NLAP -> PSC |
| canonical serialization spec | - | + | NLAP -> PSC |
| terminology registry with genealogy and leaks | - | + | NLAP -> PSC |
| lexical firewall linters | - | ~ (present, currently self-blocking) | NLAP -> PSC, after C2 |
| finite negative certificate (counterexample object) | - (realization gap) | + (separator) | see B1 |
| finite positive certificate (identification object) | + (coincidence) | - (structural equality only) | see B6 |
| degree-`n` exact Pisot/Perron screen | - | - | new, B8 |
| shared `R x Q_2` dyadic box kernel | - | ~ | new, B7 |

## 5. Bridging contributions, ranked

Ranking is by expected leverage on the named repository's own open gate, then by cost. Each item names the first file to touch.

### B1. Transport `G1b-2` to the overlap graph, and implement overlap coincidence as a second PDS certificate route — PSC, mathematics and executable

- Literature `[L]`: for a Pisot-family self-affine tiling the tiling has the Meyer property (Lee--Solomyak 2012); for such tilings pure discrete spectrum is decided by the overlap-coincidence algorithm (Solomyak 1997; Akiyama--Lee 2011), whose state set is the finite set of realized overlaps (finite by finite local complexity and the Meyer property). PSC's manuscript line 85 already records "overlap coincidence: equivalent to PDS for self-affine tilings with the Meyer property", and line 122 records that Balchin--Rust's Grout implements the algorithm.
- Correspondence: a *realizable* irreducible balanced pair is a chain of overlaps between two consecutive simultaneous tile boundaries of two tilings in one MEF fibre; a coincidence is an overlap that is a full tile. The finite set that PSC's `G1b-2` asks for ("only finitely many realizable reduced interior-zero-free balanced pairs with `R(s) <= R0`") is the set of such chains, and it is finite exactly when simultaneous boundaries recur with bounded gaps. So the exact residual content of `G1b-2` is:

  ```text
  for any two tilings T, T' in one MEF fibre of Omega_sigma,
  the set  Bd(T) ∩ Bd(T')  of simultaneous boundaries is relatively dense in R.
  ```

  This is a statement about two Meyer sets in one cut-and-project scheme, not about balanced words, and it is where the profinite factor enters in the non-unimodular case (Minervino--Thuswaldner 2014 `[L]`). PSC's `docs/c4-prefix-difference-return-calculus.md` section 5 proves the bounded-gap statement *inside* a strict closed component; the geometric statement is its unconditional target.
- The unrealized formal states of `B_sigma` are the excess between `G1` and the theorem; PSC's realization firewall already says the formal graph over-generates. Whether the repository graph from seeds `(ab,ba)` explores unrealizable states is the same question as `PDSImpliesRepoG1`, and it should be settled on that side, not on the finiteness side.
- Executable deliverable: a Mojo overlap-coincidence kernel over the same 4,554-specimen corpus, with the CI regression "BPA productive iff overlap coincident" on every specimen. That regression is a NLAP-style adequacy theorem made executable, and it supplies PSC's missing finite negative certificate (a realized non-coincident overlap cycle certifies non-PDS).
- First files: `PSC: docs/bpa-literature-bridge.md` (add the overlap dictionary), then a new `kernel/psc/overlap.mojo`.
- Status: CONDITIONAL program, not a theorem; the geometric statement is offered as the correct target, not as proved.

### B2. One Lean lemma for both Galois uses — PSC and NLAP, formal

- Statement to formalize in `PSC: proof/PscVerif/`: for `f` irreducible over `Q`, a predicate given by `Q`-rational polynomial equalities and disequalities is constant on the roots of `f`. Mathlib has the Galois action on roots of an irreducible polynomial.
- PSC payoff: a Lean formulation would strengthen formal coverage of the archived degree-three seed proof, but it is no longer a prerequisite for the live degree-two carrier span implication. The TLA source-pending invariant is retired by the audited wedge-dichotomy reconstruction, not by importing a missing v16 file.
- NLAP payoff: the exact-type invariance of C1, and the algebraic catalogue object it licenses.
- First file: `PSC: proof/PscVerif/PscVerif/Spectral.lean` (extend the axiom-audited module).
- Status: THEOREM-grade target, small.

### B3. Port the TLA+ dependency ledger to NLAP — NLAP, infrastructure

- `PSC: proof/tla/ProofArchitecture.tla` is generic (`CONSTANTS Results, Requires, Proved, Withdrawn, Assumed`) and needs no change. NLAP supplies a `Ledger.tla` with the seven proof blocks of `docs/C1_proof_definition_and_priority.md`, the theorem tags as `Assumed` in one configuration and absent in another, and invariants such as `C1NotEstablished`, `MissingLinkNeverTerminal`, `MLCStrengthUnreachableWithoutResidualClosure`. TLC then checks what `src/C1_theorem_status.mojo` currently asserts by hand.
- Add an `Imported` constant to the shared `ProofArchitecture.tla` while porting (also fixes C4 on the PSC side).
- First files: new `NLAP: proof/tla/Ledger.tla`, `NLAP: proof/tla/check.sh` copied from PSC.

### B4. Give NLAP a compiling Mojo toolchain and CI — NLAP, infrastructure

- Copy `PSC: kernel/pixi.toml` (pin `modular >= 26.6`), port `inout self` to `out self`/`mut`, replace `@value` with explicit `Copyable, Movable`, add a `verify.mojo` in PSC's `Check` style, and add a `mojo-kernel` CI job. Until this exists the "Mojo theorem kernel" and the Krawczyk computation are prose.
- Prerequisite: C2 (the current CI never reaches any later step).
- First files: `NLAP: .github/workflows/no-trig-audit.yml`, new `NLAP/mojo/pixi.toml`.

### B5. Upgrade PSC's census to per-instance certificates with import metadata — PSC, semantics and serialization

- Under the literature criterion (BPA terminates with coincidence for the irreducible Pisot substitution, seed bridge pinned) each of the 4,554 runs is a certificate of pure discrete spectrum for that substitution. The correct caveat "evidence only" applies to the universal `G1`, not to the instances. Emit `PDSCertificate(sigma) = {incidence, PIP witness, BPA graph hash, productivity witness paths, theorem tag with hypotheses and seed-bridge status}` per specimen using NLAP's canonical serialization envelope, closing issue #2 with a format that is already specified.
- Add a `TheoremTagImport`-style record to `kernel/psc/certificate.mojo` and an `Imported` set to the TLA ledger (C4).
- First files: `PSC: kernel/census.mojo`, `PSC: docs/verification-architecture.md` section 1.

### B6. Exact-type catalogue and a counting identity for separator completeness — NLAP, mathematics and executable

- From C1: define `Mis_{l,k}(C) :=` product of the irreducible factors of `sqfree(R_{l,k})` whose collision pattern has exact type `(l,k)`, computed by divisibility as in this audit. Its degree is the number of exact-type parameters.
- Rational-angle side: count `Q/Z` doubling-orbit classes with preperiod `l-1` and period dividing `k` with the required kneading match; landing multiplicity at Misiurewicz points is finite and combinatorially determined `[L]` (Douady--Hubbard; Schleicher; Milnor orbit portraits). The identity "angle classes, counted with landing multiplicity, equal `deg Mis_{l,k}`" is the first exact, executable check of `SeparatorCatalogueCompleteness` on the Misiurewicz class, in the same sense that PSC's `PIP specimens: 4554` line is an exact completeness regression for its corpus.
- Add PSC-style negative controls: a lower-type root inside the same box (e.g. `0` next to `-2` in `R_{2,1}`) must fail the forbidden exclusions; a horizon `H < l+k` must be rejected; a wrong-period ray datum must fail `RayAddressDatum.valid`.
- First files: `NLAP: docs/finite-certificate-calculus.md` section 3 (rewrite the rationale), new `NLAP: tools/misiurewicz_catalogue_reference.py` as the Python oracle, then Mojo.

### B7. A shared `R x Q_2` dyadic box kernel — PSC and NLAP, executable

- From I8: one record `(mantissa, shift)` as real interval endpoint and as 2-adic ball radius `2^{-shift}`. PSC uses it for the non-Archimedean coordinate of the determinant-2 regression (after auditing the index of `Z[beta]` at 2); NLAP uses the real part as is. A Lean-verified rational interval arithmetic would serve both and is the natural first NLAP Lean target.
- First files: `NLAP: src/interval_q.mojo` (port to the current toolchain), new `PSC: kernel/psc/padic.mojo`.
- Status: THEOREM-grade arithmetic; the *usefulness* for `G1b-2` is CONDITIONAL on B1.

### B8. Hubbard-tree edge substitutions: a census of the algebraic type of core entropy — cross-field, exploratory

- For a postcritically finite quadratic parameter, the Hubbard tree map is Markov on edges and its transition matrix `A_c` is a nonnegative integer matrix with `rho(A_c) = exp(h_core(c))` `[L]` (Thurston, "Entropy in dimension one"; Tiozzo). NLAP's exact rational-angle machinery produces the tree combinatorics; PSC's exact screen (`is_primitive`, irreducibility, Pisot test) classifies `A_c`, once `is_pisot_charpoly` is generalized to degree `n` (C6).
- Deliverable: for all Misiurewicz parameters with `(l,k)` in a box, the exact algebraic type of `exp(h_core)` (Pisot / Salem / other Perron), and for the Pisot cases the BPA run on the induced edge substitution. This connects Thurston's lamination program and his Pisot-tiling program through both repositories' existing kernels. Whether "Pisot core entropy" has been characterized in the literature must be searched before any claim; Tiozzo's Galois-conjugate results and the Master Teapot literature are the entry points `[L]`.
- First files: `PSC: kernel/psc/pisot.mojo` (degree-`n` Sturm/Pisot), then a new NLAP module for tree transition matrices.
- Status: ANALOGY today; the census question is well-posed.

### B9. A hypothesis-firewall linter and terminology declarations for PSC — PSC, infrastructure

- PSC's ledger lists the leaks it forbids (unimodularity, lattice assumption, inverse of `M`, realization shortcut, "bounded hence finite"). NLAP enforces its analogous invariants lexically. A `PSC: tools/audit_firewall.py` that flags `|det M| = 1`, `M^{-1}`, "lattice" without negation, and "therefore finite" outside allow-listed archive files is cheap, and a `docs/terminology-registry.md` with declarations for `carrier`, `concentration`, `aux-B`, `renewal address`, `level-scaled address` resolves the archive/ledger collision noted in C5.
- First file: new `PSC: tools/audit_firewall.py`, wired into `ci.yml`.

### B10. Make NLAP's own gate green — NLAP, prerequisite

- Make `audit_no_trig.py` token-aware (exclude `degree` when preceded by polynomial context or restrict to angular units), reconcile the deprecated term in the twenty `docs/C1_*` files, and re-run the sixteen failing tests. Nothing in B3, B4, or B6 is verifiable by NLAP's CI before this.
- First file: `NLAP: tools/audit_no_trig.py`.

## 6. Non-claims

- No correspondence above transfers a proof. The schema of section 1 is bookkeeping.
- B1 is a program: the relative-density statement is proposed as the correct target for `G1b-2`, not asserted.
- The Galois lemma of I7 and B2 is elementary; its PSC payoff is conditional on the `Q`-rationality audit of the wedge functional.
- B8 is exploratory and requires a literature search before any statement about Pisot core entropies.
- Counts quoted for NLAP CI and tests are as of head `652f7b9`; counts quoted for PSC are those pinned by its own CI at head `f2afa9e`.

## 7. Citation targets to pin before any ledger uses them

- Akiyama, Barge, Berthé, Lee, Siegel, *On the Pisot Substitution Conjecture* (2015), Theorem 5.3 (balanced pairs) and the overlap/geometric coincidence sections.
- Solomyak, *Dynamics of self-similar tilings* (1997), overlap coincidence; Akiyama, Lee, *Algorithm for determining pure pointedness of self-affine tilings* (2011).
- Lee, Solomyak, *Pisot family self-affine tilings, discrete spectrum, and the Meyer property* (2012).
- Barge, Kwapisz, *Geometric theory of unimodular Pisot substitutions* (2006), coincidence rank and MEF fibres.
- Siegel, Thuswaldner, *Topological properties of Rauzy fractals* (2009), boundary graph and contact graph.
- Minervino, Thuswaldner, *The geometry of non-unimodular Pisot substitutions* (2014), Euclidean times profinite representation space.
- Sirvent, Solomyak (2002); Hollander, Solomyak (2003), balanced pairs versus overlaps in one dimension.
- Schleicher, *On fibers and local connectivity of Mandelbrot and Multibrot sets*; *Rational parameter rays of the Mandelbrot set*.
- Hutz, Towsley, *Misiurewicz points for polynomial maps and transversality* (2015), generalized dynatomic polynomials and root simplicity.
- Thurston, *Entropy in dimension one* (2014); Tiozzo, *Galois conjugates of entropies of real unimodal maps*; Bray, Davis, Lindsey, Wu, *The shape of Thurston's Master Teapot* — entry points for B8 only.
