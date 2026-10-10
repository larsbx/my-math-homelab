# Verification architecture

The repository uses several complementary verification layers. No layer is allowed to claim more than it actually checks.

## 0. Canonical executable language

**Mojo is the canonical executable implementation layer.** New algorithms, exact finite-state machinery, census drivers, and performance-sensitive theorem-support code should be implemented in `kernel/` first. Python is retained as an independent reference/oracle and prototyping layer, not as the default implementation surface.

This is also an optimization policy: hot kernels should be redesigned around Mojo's strengths rather than mechanically translated from Python. In the standing alphabet-3 regime, prefer fixed-dimension exact arithmetic, streaming prefix accumulators, precomputed substitution-local tables, compact integer-index graph representations, iterative traversals, and storage reuse. Diagnostic string serialization and Python-style dynamic object graphs should stay out of inner loops where an exact compact representation is available.

The detailed agent/review rules are in `AGENTS.md`.

| Layer | Tool | Question it answers | Scope |
|---|---|---|---|
| **Canonical exact implementation** | Mojo | Is the executable finite arithmetic/automaton computation correct? | exact PIP decision, BPA construction, structural C4 machinery, C3/C4/defect censuses, finite algebra, optimized corpus instrumentation |
| Secondary structural oracle | Python | Does an independently written reference reproduce structural identities/counter-calibrations? | reference SCC/endpoint/orientation/defect/factorization/lattice models during Mojo migration |
| State/dependency model | TLA+ / TLC | Does the finite automaton/model behave as claimed, and which proof conclusions are reachable from which assumptions? | BPA model checks and proof-dependency ledger |
| Deductive finite algebra | Lean 4 + Mathlib | Do the formalized finite-algebra theorems follow? | seed/spectral algebra and axiom audit |

Run the available layers with `tools/verify_all.sh`. A missing toolchain must be reported as skipped, never converted into a vacuous pass.

## 1. What is proved versus computed

The exact 4,554-substitution corpus is a **finite calibration**, not a proof of G1, C1, C4, or PSC. Mojo verifies that the chosen finite parameter space was screened exactly and that the reported BPA/census statistics are reproducible.

Executable identities in Mojo or Python are still regression/certificate computations, not proof-assistant theorems merely because they are exact. The architectural preference for Mojo changes the source-of-truth implementation, not the epistemic status of computation.

Lean currently formalizes the older finite spectral core, not the full C4 stack. TLA+ checks dependency reachability and selected finite-state models; it does not prove the mathematical C4 lemmas merely by naming them in a ledger.

## 2. Mojo kernel and optimization policy

The Mojo kernel uses exact integer/rational operations (unbounded `BigZ`-backed rationals and closed rational intervals from `kernel/finite_exact/`, vendored from one pinned `larsbx/finite-math-kernels` commit) for:

- incidence and characteristic-polynomial arithmetic;
- primitive / irreducible / Pisot screening;
- balanced-pair factorization and SCC construction;
- seed `K2/K3/W3` certificate computations;
- endpoint/C3/C4 finite censuses;
- the exact first-defect census;
- new C4 structural machinery as it is migrated from the Python oracle layer.

For new work, the preferred optimization order is:

1. exploit known fixed dimensions before introducing generic containers;
2. replace combinatorial enumeration with exact streaming recurrences when possible;
3. precompute data depending only on a substitution/specimen;
4. intern states once and use integer indices in graph algorithms;
5. reuse scratch storage and avoid temporary strings/lists in hot loops;
6. keep SCC/reachability algorithms iterative;
7. fuse repeated exact passes only when doing so preserves auditability;
8. fail closed on impossible invariants;
9. never trade exact arithmetic for floating heuristics on proof-relevant predicates;
10. accompany material hot-kernel changes with deterministic correctness regressions and complexity/benchmark notes where practical.

The `N2/N3` word counters are a canonical example: in a three-letter alphabet they should use one-pass prefix accumulators rather than `O(n^2)` / `O(n^3)` tuple enumeration.

The established finite alphabet-3 corpus has 4,554 PIP substitutions with image lengths `<=3`. All BPA constructions terminate below the configured cap in this corpus; every observed sink is productive. This is finite evidence only.

Issue #2 tracks the remaining infrastructure step: make this exact screen the canonical documented corpus-export interface with deterministic machine-readable JSONL.

## 3. Python reference/oracle layer

`reference/psc_research/` and `tests/` contain exact reference implementations for much of the live C4 reduction stack, including:

- sink-SCC and boundary-lineage tooling;
- seven endpoint-map types and synchronization quotients;
- Parikh/child-incidence intertwiners;
- orientation cocycle, even/odd incidence, and spectral phase cases;
- signed `K2/K3` first-defect intertwiners;
- degree-4 and generalized-Witt multidegree sieves;
- mod-2 degree-2 size obstruction;
- synthetic G/F factorization negative control;
- ordered degree-2 mid-area identity;
- three-state mean-area and integral-image calibration;
- recent recognizability/prefix-ancestry prototypes while their Mojo ports are being completed.

These files remain valuable because an independently written oracle can catch mistakes in the canonical Mojo path. They should not become the default location for new theorem-support code. A Python-only new module is temporary unless an explicit blocker makes a Mojo implementation impractical.

The strong G/F synthetic artifact is important precisely because it prevents overclaiming: it satisfies the real PIP substitution, endpoint phases, incidence, Parikh and `K2` data, and actual irreducible state columns, yet fails the true zero-return child factorization.

## 4. TLA+ proof-dependency layer

`ProofArchitecture.tla` is a generic dependency state machine (the same module as `proof_records/ProofArchitecture.tla` in `larsbx/finite-math-kernels`). A result can be discharged only when all prerequisites in one sufficient proof branch are already established; withdrawn results can never be discharged. `Ledger.tla` supplies the current mathematical dependency graph and is generated, together with one `MCLedger<Set>` model per assumption set, from the proof records tabulated in `tools/make_ledger.py` (`proof/tla/ledger.json`). Repository theorems are `ProvedDef`, imported theorems `ImportedDef` (established only by assumption, so a model that needs Barge–Štimac–Williams names it in its assumption set), withdrawn claims `WithdrawnDef`. Every generated model holds; a model's `Reachable` set states what its assumptions derive and its `<Name>NotEstablished` invariants what they do not, replacing the earlier configurations that demonstrated derivations through expected invariant violations.

The dependency graph must encode **sufficiency**, not converse implications. The primary route is the G1-free overlap route,

```text
G1b1BoundedDiscrepancy => SwapOverlapFiniteness,
OverlapProductivity + SwapOverlapFiniteness => CoincidenceDensityOne,
CoincidenceDensityOne + DensityToPDSBridge (imported) => PDSOverlapRoute,
```

checked in both directions by `MCLedgerOverlapGateAssumed` (reaches `PDSOverlapRoute`, asserts `PDS`, `G1`, `SCCProducer` not established) and by `MCLedgerOpen` / `MCLedgerImports` (assert `PDSOverlapRoute` not established). The overlap-depth route `AllSeedOverlapProductivity + SwapOverlapFiniteness => G1OverlapRoute => G1` is checked by `MCLedgerAllSeedOverlapGateAssumed`: it reaches canonical `G1` and its downstream finite-BPA reductions, while `G1b2RenewalFiniteness` and `PDS` remain unestablished. The half-coincidence route `AllSeedStrictZipperExclusion + SwapOverlapFiniteness => G1HalfCoincidenceRoute` is a third alternative establishment of canonical `G1`, checked by `MCLedgerAllSeedStrictZipperGateAssumed` (reaches `G1`, asserts `PDS` and `OverlapProductivity` not established). The box-automaton route `FormalProductivity + BoxCycleContainment => G1FormalProductivityRoute` is a fourth, checked with the two FP routes to PDS (`PDSFormalProductivityRoute` through `BoxAutomatonPDSCertificate` and the separate imported `PisotMeyerProperty` / `OverlapCoincidenceCriterion`, `PDSFormalProductivitySeedRoute` through `DensityToPDSBridge`) by `MCLedgerFormalProductivityGateAssumed` (reaches `G1` and both routes, asserts `PDS`, `SCCProducer` and every seed gate not established). Canonical `G1` declares `G1FromRenewal` OR `G1OverlapRoute` OR `G1HalfCoincidenceRoute` OR `G1FormalProductivityRoute` as sufficient proof branches through digest-bound `dependency_alternatives` evidence in its source record. AND remains the rule within each branch. Both `MCLedgerOpen` and `MCLedgerImports` still leave `G1` unestablished. The alternatives do not prove the open all-seed productivity or strict-zipper gates, #84, #138, #139, or PSC; G1 retains its open status. The generic record closure conservatively audits every branch, while the establishment fixpoint discharges any one branch. The finite-BPA route

```text
C4 => C3-local => C2 => SCCProducer,
G1 + SCCProducer => PDS
```

is retained as a conditional side route. G1 is used there to extract a finite sink SCC from global nonproductivity. Structural statements conditional on an already-given finite closed SCC should not all be made to depend on G1 in the ledger.

The literature relation between PDS and standard BPA termination is tracked separately. Until the repository's normalized all-seed graph is explicitly bridged to the literature algorithm, the ledger must not silently add `PDS => G1`.

## 5. Lean layer

The Lean development proves the formalized finite spectral algebra and audits axioms. It does **not** currently formalize:

- G1 or SCC Producer;
- sink-SCC extraction;
- endpoint synchronization quotients;
- the general first-defect free-Lie statement;
- C4's prefix-difference/recognizability route;
- the ordered mid-area or mean-area lattice identities.

Those omissions should remain visible rather than being implied away by passing computational tests.

## 6. Source/interface discrepancies

Four discrepancies are now canonical.

### D1 — printed shuffle map is transposed

The archived certificate's displayed basis-action form of the shuffle map is transposed relative to the coordinate map used by the rest of the certificate. The coordinate convention is the one implemented in Mojo and Lean and is the one under which the printed basis and seed `K3` vectors lie in the intended kernel.

### D2 — the degree-3 shuffle argument needs lower-degree corrections

The naive degree-3 shuffle identity is false on diagonal indices because scattered-subword multiplication is the infiltration product, not pure shuffle. The correction terms have degree two and cancel when `K2=0`; the intended conclusion remains valid. Lean proves the corrected instance used by the seed calculation.

### D3 — archived v34 status table still contradicts the withdrawal

The archived `V34_CLOSURE.md` contains stale prose saying alphabet-3 finiteness was proved by the withdrawn v5 theorem and that the Load-Bearing SCC theorem was unconditional. The live ledger is authoritative instead; the archived file remains preserved as historical source.

### D4 — archived normalized SCC transfer omits orientation signs

The archived `PROOF_CERTIFICATE.md` degree-3 SCC interface uses

```text
L_C N_C = Phi_3 L_C.
```

For normalized balanced-pair states this is not correct in general: when a raw child appears reversed relative to its normalized representative, the odd scattered-subword defect changes sign. The exact normalized relation is

```text
Q_3 S = Phi_3 Q_3,
S=A-B,
```

and similarly `Q2 S=(Lambda^2 M)Q2` at degree two.

This correction does **not** invalidate the seed-level finite Spectral Black Box. It corrects the SCC-level transfer interface. The older v34 norm/path-counting argument that takes norms before using unsigned counts is a separate statement and is not changed merely by D4.

## 7. Current verification and implementation gap

*Refreshed 2026-10-05. Until then this section called factorization and
recognizability "the deepest current mathematical gap", which the overlap-depth
work had already displaced (`audit-2026-09-27.md` §G.2, `audit-2026-10-04.md`
§D.6).*

The primary gap is **seedwise overlap productivity** (manuscript Open
Problem 5.35, issue #84): productivity of every vertex of the finite
seed-patch overlap graph reachable from the swap seeds. Theorem 4.22 makes
that graph finite unconditionally, and Theorem 5.38 turns the one-seed form of
productivity into pure discrete spectrum through the imported
Barge–Štimac–Williams bridge, so this one hypothesis carries the shortest
route to PDS. It splits into two branches, and the live frontier is both of
them:

- **aligned strong coincidence** (#138), where the cycle normal form is proved
  and the fixed bad hub edge and alternating type-E templates remain;
- **strict-zipper hitting** (#139), where the literature, cylinder and carry
  reductions are complete and a uniform non-unit-safe
  `AdelicPeriodicOffsetHitting` theorem remains.

Finiteness of the balanced-pair automaton (G1) is no longer an independent
obligation on this frontier, in either direction. It is **necessary**: pure
discrete spectrum implies G1 (`prop:PDS-implies-G1`, independently audited
2026-10-04, human review pending), so no route to PDS can route around it and
an infinite automaton would refute the conjecture. And it is **cheaper than
productivity**: by Corollary 5 of the half-coincidence route (Proposition
5.47), excluding strict zippers alone gives G1, with no appeal to #138. So
#139 buys finiteness as a by-product, while productivity and PDS need both
branches.

Factorization and recognizability remain live, but as a *secondary* route
rather than the headline gap: they feed G1b-2 renewal finiteness (manuscript
`prob:G1b2`, roadmap P2), which since 2026-10-04 is the least load-bearing of
the three routes to G1, and they remain relevant to possible
bridge routes. What that route still needs is unchanged:

- the prefix-difference walk determines balanced child return times;
- finite closed SCC recurrence produces many bounded-gap returns under inflation;
- Pisot contraction constrains multi-level ancestry defects;
- recognizability constrains recurrent child cuts relative to supertile boundaries;
- the remaining object is the relative hierarchy-offset/address state.

The implementation gap is explicit too: Python structural prototypes on the
factorization route must be migrated into canonical Mojo modules, beginning
with multi-level prefix ancestry/legal towers and the relative
hierarchy-offset state (`AGENTS.md`, "Porting order for the live C4
program"). New work on this path should be Mojo-first.

Nothing in this section discharges an open premise: #84, #138, #139, G1b-2 and
PSC all remain open. The live planning surface is
`research-roadmap-2026-09-21.md`; the claim taxonomy is
`claim-status-and-source-map-2026-09-13.md`.
