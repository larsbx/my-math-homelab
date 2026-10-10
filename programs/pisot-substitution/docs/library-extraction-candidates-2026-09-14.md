# Library extraction candidates across PSC and NLAP-JT

**Status:** cross-repository engineering audit, dated 2026-09-14. It ranks code that could be lifted out of the two research repositories into shared libraries, states what must happen before each lift, and fixes the order. It is not a mathematical document: no row below discharges or weakens any theorem obligation, certificate gate, or conjecture status in either repository. Project terms follow `docs/terminology-registry.md` in NLAP-JT and `docs/conjecture-ledger.md` in PSC.

Heads audited, on the shared branch `claude/library-extraction-candidates-d9lp6i`:

| Tag | Repository | Head | Executable surface |
| --- | --- | --- | --- |
| `NLAP:` | `larsbx/NLAP-JT` | `ac7f8f9` | Mojo `src/`, compiled by CI through the closure of `src/smoke_tests.mojo`; Python `tools/` audits and `tests/` |
| `PSC:` | `larsbx/pisot-substitution-conjecture-research` | `970f214` | Mojo `kernel/psc/`, compiled and tested by CI (`pixi run test`, `verify`, censuses); Python `reference/psc_research/` oracle |

Markers: `[V]` was checked in this session by reading or executing the repository; `[U]` could not be checked here. Both CI workflows are green on their `main` heads `[V]` (NLAP run 679, PSC runs 884/721/665). Locally, PSC's Python suite passes in full and NLAP-JT's passes except the one test that requires a `mojo` binary, which this container lacks `[V]`.

## Execution status (updated 2026-10-06)

All reusable packages now come from `larsbx/finite-math-kernels`, pinned
in `vendored.toml`. The original standalone-repository names in the dated
analysis below describe the September extraction plan.

| Extraction | Current PSC binding |
| --- | --- |
| Exact integers, rationals and closed intervals | `kernel/finite_exact/`; rejected consumer states are handled by `kernel/psc/exact.mojo` |
| Alphabet-generic substitution dynamics | `kernel/substitution_dynamics/`; thin alphabet-3 views under `kernel/psc/` |
| Exact linear algebra | `kernel/finite_linear_algebra/`; PSC keeps its printed certificate basis |
| Proof records and generated ledger surfaces | `tools/proof_records/` and `tools/make_ledger.py` |
| Claim-governance audits | `tools/claim_governance/` with repository policy in `claim_governance.toml` |

Vendoring is byte-identical and checked by
`tools/vendoring/check_vendored_sync.py`. The remaining analysis, quoted heads
and external paths below are the 2026-09-14 audit record.

## 0. Summary

| Priority | Candidate | Source of truth on 2026-09-14 | Consumers | Readiness |
| --- | --- | --- | --- | --- |
| P0 | Exact integers and rationals (`finite_exact`) | `NLAP: src/bigint_z.mojo`, `src/rat_q.mojo` | PSC, NLAP-JT, later certificate projects | after the hardening list in section 1.3 |
| P0 | Substitution-dynamics kernel (`substitution_dynamics`) | `PSC: kernel/psc/{words,bpa,derived_system,...}.mojo` | PSC censuses, other symbolic-dynamics work | after alphabet generalization and uniform symbol validation |
| P1 | Closed rational intervals (`interval/closed_q`) | `NLAP: src/interval_q.mojo` (+ PSC checked-operation tests) | both programs | after `finite_exact`; spec hook already exists |
| P1 | Exact finite-dimensional linear algebra (`finite_linear_algebra`) | `PSC: kernel/psc/{mat3,qlinalg,tensor3,w3}.mojo` | spectral, wedge, incidence experiments | after moving scalars onto `finite_exact` |
| P1 | Finite proof-record infrastructure (`finite_proof_records`) | `NLAP: src/mojo_theorem_kernel.mojo` and the C1 ledgers | both programs | specification first; the current code is outside the compiled closure |
| P2 | Claim-governance and language audits (`math_repo_audit`) | `NLAP: tools/audit_*.py`, `tools/source_tokens.py` | every mathematical repository | nearly ready; policies must move to per-repository configuration |

Three arithmetic authorities exist today `[V]`: PSC's unchecked machine-width `Rat`, PSC's checked machine-width `CheckedRat`, and NLAP's unbounded `BigZ`-backed `Q`. The purpose of P0 is to reduce that to one.

## 1. Exact arithmetic: `finite_exact`

### 1.1 What exists

| Layer | NLAP-JT | PSC |
| --- | --- | --- |
| integers | `BigZ`: dynamic little-endian limbs in base `10^9`, sign in `{-1,0,1}`, add/sub/mul, order, quotient/remainder, exact division with rejection, Euclidean gcd, canonical `Z(sign, byte_len, big_endian_magnitude)` bytes, and `bigz_is_canonical` `[V]` | machine `Int` only |
| rationals | `Q`: normalized `BigZ` fraction, `den > 0`, `gcd = 1`, `rejected` flag propagated through every operation and through `q_canonical_bytes` `[V]` | `Rat` in `kernel/psc/rational.mojo`: normalized machine `Int`, unchecked overflow, `abort` on zero denominator `[V]`; `CheckedRat` in `kernel/psc/rational_interval.mojo`: normalized machine `Int` with overflow checks that `raise` `[V]` |
| polynomials | `PolyZ` in `src/poly_z.mojo`: fixed `MAX_DEGREE`, machine `Int` coefficients, not yet on `BigZ` `[V]` | integer coefficient lists inside `mat3.charpoly` and `rational_interval.eval_int_poly_at_rat` `[V]` |

Dependency chain as it stands:

```text
BigZ  -->  Q  -->  IQ  -->  ComplexIQ  -->  Krawczyk and exclusion predicates      (NLAP, compiled)
PolyZ (Int coefficients, bounded degree)   -->  P_{l,k} identities                  (NLAP, compiled, not on BigZ)
Rat (Int)  -->  qlinalg / tensor3 / w3 ;  CheckedRat (Int)  -->  RatInterval  -->  Perron enclosures   (PSC, compiled)
```

### 1.2 Verified findings on the NLAP stack

- `bigz_abs_divmod` is binary shift-and-subtract: it doubles the divisor until it exceeds the dividend, then halves and subtracts. Every step is a full limb-vector add or small-divide, so the cost is quadratic in limb count times the bit length of the quotient. It is correct on the smoke inputs and checked by `bigz_divmod_identity_holds`, but it is not a general backend division `[V]`.
- `Q.add`, `Q.sub`, `Q.lt`, `Q.le` cross-multiply raw numerators and denominators, and `Q.mul` multiplies before normalizing. No denominator-gcd or cross-cancellation is applied `[V]`. The transitional `src/checked_q.mojo` already implements both (denominator gcd in `checked_q_add`, cross-cancellation in `checked_q_mul`) over `Int64` `[V]`, so the fix is a port, not a design task.
- `IQ.point` and `ComplexIQ.point` exist as `@staticmethod` constructors `[V]`. `docs/no-points-invariant.md` permits a `point(...)` helper only when it means a singleton-box constructor and only with a comment saying so; `src/interval_q.mojo` carries no such comment `[V]`. The allowlist entries in `tools/audit_no_points.py` still spell the declarations `fn point(...)`, which no longer match the `def` text; the audit passes only because its regex does not match `def point(` `[V]`. Renaming to `singleton` removes the exception rather than repairing it.
- The 2026-09-14 project audit (`docs/project-audit-2026-09-14.md`, F1 and F2) predates the BigZ series. As of run 630 CI compiles and runs the smoke closure and all subsequent runs pass `[V]`. Modules outside that closure, in particular `src/mojo_theorem_kernel.mojo` and `src/canonical_serialization.mojo`, still use `inout self` and `fn` signatures and have not been compiled `[V]`.

### 1.3 Required before extraction

1. Randomized algebraic-identity tests for `BigZ` and `Q` against an independent oracle (Python `int` and `fractions.Fraction`, driven through the canonical byte encoding so no parser is trusted): ring axioms, `divmod` identity, `gcd` divisibility, order transitivity, normalization idempotence, and encode/decode round trips.
2. Replace shift-and-subtract with schoolbook long division on limbs (Knuth Algorithm D or the base-`10^9` equivalent). Keep the current routine as the oracle for the new one until the property tests cover both.
3. Port denominator-gcd addition, cross-cancelled multiplication, and gcd-reduced comparison from `checked_q.mojo` into `rat_q.mojo`.
4. Split canonical encoding: the integer and rational encodings (`bigz_canonical_bytes`, `q_canonical_bytes`) belong to the library; the certificate schemas in `canonical_serialization.mojo` stay in NLAP-JT.
5. Rename `IQ.point` and `ComplexIQ.point` to `singleton`, update the five call sites, and delete the stale allowlist lines.
6. Keep every certificate-acceptance or proof-grade predicate out of the package. Arithmetic readiness (`allows_certificate_acceptance`) is a consumer decision, as `docs/bigint-migration-handoff.md` already states.
7. Move `PolyZ` onto `BigZ` coefficients and unbounded degree, or document that the library ships `poly_z` as a bounded-degree specialization.

PSC then retires both `Rat` and `CheckedRat`. `CheckedRat` contributes its test file, its cancellation discipline, and its explicit unknown-versus-failure semantics; its bounded `Int` representation must not survive as a canonical backend.

## 2. Substitution-dynamics kernel: `substitution_dynamics`

### 2.1 What exists

`PSC: kernel/psc/words.mojo` (Parikh vector, streaming `N2`, `N3`, `Pair`), `bpa.mojo` (substitution application, coincidence boundaries, boundary lineage, `Automaton`, breadth-first `build` with a state cap, iterative Tarjan SCC, non-productive states), `derived_system.mojo`, `endpoint_core.mojo`, `hierarchy_offset.mojo`, `legal_tower.mojo`, `affine_ancestry_trace.mojo`, `swap_discrepancy.mojo`, together with their Mojo regression tests under `kernel/tests/` `[V]`. This is a coherent computational subject independent of the Pisot conjecture: finite words, substitutions, Parikh differences, balanced-pair factorization, boundary ancestry, recurrent components, and exact trace records.

### 2.2 Verified findings

- The alphabet size three is hard-coded as literal arrays or loop bounds in `words.parikh`, `words.n2`, `words.n3`, `bpa.coincidence_boundaries`, `bpa.seed_states`, `swap_discrepancy.discrepancy`, and `tensor3` (`idx3`, `zeros27`) `[V]`. `AGENTS.md` rule 1 asks for fixed dimensions in hot loops, so generalization must keep alphabet-3 as a compile-time specialization, not replace it with dynamic containers.
- Symbol validation is inconsistent. `bd_endpoint._validate_letter` and `affine_ancestry_trace._validate_sigma` reject letters outside `0..2`; `words.parikh`, `bpa.coincidence_boundaries`, and `swap_discrepancy.discrepancy` index `List[Int]` with the raw symbol and never check it `[V]`. The out-of-range-label regression fixed in commit `fbc26c3` was in the Python oracle `reference/psc_research/swap_discrepancy.py`; the Mojo `discrepancy` kernel has no equivalent guard `[V]`.
- Failure channels are mixed: `bpa.inherited_boundary_positions` calls `abort`, `bpa.build` is declared `raises` and additionally returns `capped=True` for resource exhaustion `[V]`. The docstring rule that a capped run is inconclusive is correct and must be preserved.
- Conjecture-specific vocabulary (G1, C3, C4, producer, renewal, hub) lives in module and function names beside general mechanics `[V]`.

### 2.3 Required before extraction

1. Introduce an explicit alphabet parameter with a compile-time fast path for size three.
2. Validate every symbol at the kernel boundary, once, with a typed rejection.
3. Replace `abort` with typed results distinguishing invalid input, resource cap, and valid negative answer; keep "capped means inconclusive".
4. Separate general balanced-pair mechanics from the PSC-named predicates; the latter stay in PSC and import the library.
5. Keep the Python oracle in PSC as a test dependency of the library, not as a second implementation of it.

## 3. Closed rational intervals: `interval/closed_q`

Semantics, already shared by both implementations `[V]`:

- exact rational endpoints, `lo <= hi`, closed;
- strict sign only when the whole interval excludes zero;
- an interval containing zero is *unknown*, never equality;
- invalid arithmetic (reversed endpoints, rejected endpoint, reciprocal across zero) is distinct from unknown;
- interval filtering never becomes exact acceptance without an independent exact predicate (`docs/rational-interval-arithmetic-spec.md` section 3.2).

Base: `NLAP: src/interval_q.mojo` (`IQ`, `ComplexIQ`, `IQSignResult`, `IQBoolResult`). Contribution from PSC: `kernel/tests/test_rational_interval.mojo` (natural Horner extension containment, division across zero fails closed) and the Perron-root enclosure use case, which becomes the first external consumer test.

The NLAP specification already carries a proposed PSC binding table (section 6.1) and a "future sync rule" requiring verbatim mirroring once PSC adopts it `[V]`. Extraction makes that rule concrete: the specification moves with the code, and each repository keeps only its binding rows.

Suggested layout: `exact/z`, `exact/q`, `exact/poly_z`, `interval/closed_q`, `interval/rank2`, `interval/polynomial`, `testing/reference_oracle`. Out of scope: Mandelbrot orbit logic, Krawczyk witnesses, Pisot tests.

## 4. Exact linear algebra and tensor combinatorics: `finite_linear_algebra`

Reusable `[V]`: `Mat3` (product, adjugate, determinant, characteristic polynomial, rational-root test), `qlinalg` (already generic `n`-dimensional RREF, rank, nullspace, span test over `Rat`), `tensor3` (lex indexing of `Q^27`, shuffle functional, cube action, Levi-Civita), `w3`, and the streaming `N2`/`N3` kernels that replace quadratic and cubic index loops by one pass.

Required before extraction:

1. Move scalars from `Rat` to the `finite_exact` rational.
2. Split general operations from PIP-specific predicates and cubic characteristic-polynomial tests, which stay in PSC.
3. Generalize dimension where cheap; keep `Mat3` and rank-three tensors as explicit fast paths, in line with `AGENTS.md` rule 1.
4. Keep spectral claims and certificate checklists in PSC: the library computes, it does not promote finite-corpus results to theorems.

## 5. Finite proof-record infrastructure: `finite_proof_records`

Reusable ideas `[V]`: `src/mojo_theorem_kernel.mojo` (statement, theorem-tag import, rule application, proof object, checked status), the theorem-tag import ledger and assumption-payload records, proof-block status records, the canonical-serialization gate, and the finite-certificate composition gates.

The generalizable content is the classification, not the C1 vocabulary:

| Record kind | Meaning |
| --- | --- |
| locally verified finite computation | replayable, canonical, machine-checked |
| imported theorem | external result with checked hypotheses and a named source |
| conjectural or source-pending dependency | named, unchecked, blocks completion |
| bounded experiment | evidence over an enumerated finite domain, never a general theorem |
| rejected or malformed record | fails closed |
| dependency closure | complete or incomplete, with the missing links named |

PSC needs exactly this separation between its finite exact censuses, the imported Barge-Stimac-Williams density theorem, source-pending Galois material, and the open G1, concentration, and renewal obligations.

Blockers: the kernel hard-codes NLAP policy (`uses_rank2_circle` rejection, `claims_global_mlc` open-frontier status) and is written in a Mojo dialect that CI has never compiled `[V]`. Extraction must therefore start from a written specification, with repository policies supplied by the consumer as predicates, and with the first implementation compiled and tested from day one.

## 6. Claim-governance and language tooling: `math_repo_audit`

Candidates `[V]`: `tools/audit_paper_language.py`, `tools/audit_terminology.py`, `tools/audit_exact_arithmetic.py`, `tools/audit_no_trig.py`, `tools/audit_no_points.py`, `tools/source_tokens.py`, the terminology registry and use-manifest format, and the theorem-status consistency tests.

The shared core should check: undeclared project terminology; apparent theorem claims without a status label; source-pending results described as proved; forbidden numerical primitives; inconsistent claim status across manuscripts, code, and ledgers. Repository policy (NLAP's no-trigonometry rule, its rank-2 vocabulary, PSC's named conjectures) moves to per-repository configuration. PSC has no counterpart audit today and `docs/README.md` in PSC asks reviewers to reconcile status surfaces by hand `[V]`, so it is the first consumer.

## 7. Secondary candidate: cryptographic constraint graphs `[U]`

The `crypto-composer` repository (catalogs, schemas, constraint checking, failure accounting, artifact emission) was named in the draft that preceded this audit. It is not in this session's repository scope and nothing about it was verified here. If it is extracted, it belongs in its own Zig package and may later consume the canonical integer encoding from section 1; it should not be mixed into the mathematical-library work.

## 8. Extraction sequence

1. Harden `finite_exact` inside NLAP-JT (section 1.3) and extract it.
2. Migrate PSC's `Rat` and `CheckedRat` consumers onto it; delete both.
3. Extract `substitution_dynamics` (section 2.3).
4. Separate exact linear algebra from PSC certificate logic (section 4).
5. Specify `finite_proof_records` around provenance and dependency closure (section 5).
6. Extract the audit tooling with per-repository policy configuration (section 6).

## 9. The first pull request

It stays inside NLAP-JT and does not create a shared repository:

- declare the public boundary of `BigZ`, `Q`, `IQ`, `ComplexIQ` (names, rejection semantics, canonical encodings, stability promise);
- add the oracle and property tests of section 1.3 item 1, run in CI next to `poly_reference.py`;
- replace the division routine (item 2) and port the cancellation discipline (item 3);
- rename `point` to `singleton` (item 5);
- leave every acceptance gate, theorem tag, and C1 ledger untouched.

Only after that lands and CI is green should a shared repository be created and PSC migrated. This avoids making an immature API the new source of truth in two programs at once.
