# Project audit, 2026-09-14

Status: audit report. Scope: every checkable surface of the repository at commit `e963088` on `main`: CI history, test suite, Mojo sources, Python oracles and lexical audits, documentation, manuscript, mathematics, and repository hygiene. Terminology in this file follows `docs/terminology-registry.md`.

Method: every claim below was reproduced in a clean container. Polynomial identities were recomputed independently with plain integer arithmetic (not with the repository's own oracle). GitHub Actions history was read through the API.

## Verdict

The repository has a coherent and honestly bounded research thesis, a sound manuscript, and correct reference oracles. Its executable and verification layers do not yet back the claims made for them:

| Measure | Value |
| --- | --- |
| GitHub Actions runs, all-time | 284 |
| GitHub Actions runs that passed | 0 |
| pytest results at `main` | 17 failed, 308 passed |
| pytest results at the first commit of this history | 16 failed, 244 passed |
| Assertions in `tests/` | 1160 |
| Assertions that are substring checks on source text | 1131 |
| Mojo lines | 7328 |
| Mojo lines ever compiled by CI | 0 |
| Functions returning a bare literal (`True`, `False`, or a string) | 80 of 817 |

## Findings, ordered by severity

### F1. CI has never passed and never reaches the tests (critical)

All 284 workflow runs since run #1 on 2026-09-08 conclude `failure`. The first step, `tools/audit_no_trig.py`, exits 1 and the job stops, so `pytest`, `poly_reference.py`, and `interval_exclusion_reference.py` have never executed on GitHub. Every commit message of the form "Wire X into CI" wired X into a job that halts before X.

Root cause: the no-trig regex bans the bare token `degree`, which is the polynomial degree in `poly_z.mojo`, `poly_witness.mojo`, and `poly_interval_eval.mojo`. The scanner also walks `tests/`, where every forbidden-token list is itself a hit. `tools/no_trig_scan_scope.md` recorded this as a "known cleanup task" on 2026-09-08. It has not been done.

### F2. The Mojo has never been compiled (critical)

There is no `pixi.toml`, `mojoproject.toml`, `magic.lock`, or CI step that invokes `mojo`. The sources mix constructs from incompatible language eras and contain constructs that no Mojo release accepts:

| Construct | Files | Occurrences | Status in current Mojo |
| --- | --- | --- | --- |
| `let` bindings | 11 | 75 | removed (24.4) |
| `inout self` | 62 | 155 | replaced by `mut`/`out` (25.x) |
| `@value` | 3 | 14 | deprecated |
| `StaticTuple` | 1 | 1 | renamed `InlineArray` |
| struct methods without `self` and without `@staticmethod` | 7 | 12 | compile error in every release |

The last row is decisive: `Q.zero()`, `IQ.point()`, `ComplexIQ.point()`, `Coord2.zero()`, `Rat.one()`, and `BigIntLike.zero()` are called as static methods but declared as instance methods without a receiver. None of the 7328 lines has been type-checked. The "Mojo theorem kernel" that `README.md` names as the trusted checker is, today, prose in a `.mojo` extension. The repository's own cross-program bridge document (2026-09-12, rows I9 and B4) reached the same conclusion two days ago.

### F3. The hardcoded `P_{4,1}` coefficients are wrong (high)

`kernel/mojo/polynomial/poly_interval_eval.mojo` returns

```text
[0, 8, 20, 36, 56, 72, 76, 68, 52, 32, 16, 6, 1]
```

for `P_{4,1} = C (C+2) (C^3+2C^2+2C+2) F_7`. The correct ascending expansion, recomputed independently and agreeing with `tools/poly_reference.py`, is

```text
[0, 8, 20, 40, 68, 94, 114, 116, 94, 60, 28, 8, 1]
```

Every coefficient from `C^3` upward is wrong. `tests/test_poly_interval_eval.py` computes the convolution correctly and then asserts the wrong literal, so the test fails against its own arithmetic. Consumers of the wrong polynomial: `krawczyk_witness.eval_p41`, `krawczyk_witness.eval_p41_derivative`, and `coord_record_eval.eval_p41_coord_record`. Any `M_{4,1}` Krawczyk witness built on this module would localize a root of a polynomial unrelated to the target. The Python oracle printed the right answer in every local run; nothing compared the two.

Verified in passing: `R_{4,1} = C^5 (C+2) (C^3+2C^2+2C+2) F_7` holds, `P_{4,1}` is squarefree (`gcd(P, P') = 1` over `Q`), the three nonlinear factors are pairwise coprime, and `F_7` and the cubic have no rational roots.

### F4. The test suite tests text, not behaviour (high)

1131 of 1160 assertions are of the form `"<substring>" in read_text(path)`. Only `tests/test_interval_exclusion_reference.py` executes anything, and what it executes is the Python oracle, not Mojo. Consequences observed:

- A function can return the wrong value and pass (F3 is the instance where the test happened to also compute the value).
- Rewording a comment breaks a test.
- Three tests could never have passed: `"P21(C)=C(C+2)"` has never appeared in `krawczyk_witness.mojo` and `"Proof: finite to classical"` has never appeared in any document (verified with `git log -S` over the full history). 16 tests were already failing at the first commit of this history.

### F5. Three-way drift between ledger code, ledger doc, and ledger test (high)

| Source | "next immediate block" |
| --- | --- |
| `kernel/mojo/c1/proof/final_proof_block_ledger.mojo` | `TheoremTagPayloadInstances` |
| `docs/C1_final_proof_block_ledger.md` | `TheoremTagImportLedger` |
| `tests/test_C1_final_proof_block_ledger.py` | `TheoremTagImportLedger` |

The commit `e963088` advanced the Mojo without advancing the document or the test. Because CI never runs (F1), the drift was not caught. The same pattern produced 14 of the 17 current failures.

### F6. The lexical firewalls fail on the repository that defines them (medium)

- `audit_terminology.py` reports 40 violations at `main`, including in `tests/test_paper_language_linter.py`, `tests/test_alignment_audit_incorporation.py`, and 22 documents written after the rule was introduced. The deprecated term `catalogue extensionality` (deprecated in favour of `SeparatorCatalogueAdequacy`) still appears in 20 files without migration context.
- `audit_no_points.py` flags the seven test files that define its own forbidden lists.
- `audit_no_trig.py`: see F1.

The scanners are lexical over comments, strings, and test fixtures alike. They need a token-level pass that strips comments and string literals, an explicit exclusion of `tests/` and `tools/`, and a project-level allowlist for `degree` in its polynomial sense. Until then a green audit is unreachable without rewording mathematics.

### F7. Int64 arithmetic overflows silently inside the intended domain (medium)

`rat_q.Q` cross-multiplies in `lt`, `le`, `add`, `sub`, and `mul` with no overflow check; Mojo `Int64` wraps. Independently computed growth of the critical-orbit polynomials:

| n | deg Q_n | max coefficient |
| --- | --- | --- |
| 7 | 64 | 17999433372 |
| 8 | 128 | 2676118542978972739644 (exceeds Int64) |

`poly_z.MAX_DEGREE = 256` caps the recurrence at `Q_9`; Int64 fails at `Q_8`. `backend.toml` correctly declares `proof_grade = false`, and `proof_grade_gate.mojo` correctly rejects the Int64 backend, so nothing is accepted as proof-grade today. The risk is prospective: the bigint boundary is a comment block (`bigint_adapter.mojo`, `big_int_boundary.mojo`) rather than an interface with an implementation. `Q(n, 0)` also produces a zero denominator silently.

### F8. Policy encoded as literals; enums encoded as strings; four copies of gcd (medium)

- 80 of 817 functions return a bare literal (`return True`, `return False`, `return "ResidualClosureNoMissingLinks"`). Files such as `alignment_audit_status.mojo` (9 of 12 functions), `mojo_optimization_contract.mojo` (10 of 15), and `C1_final_proof_block_ledger.mojo` (9 of 22) are configuration tables wearing function syntax. They cannot be wrong or right; they can only be asserted.
- 136 string comparisons of the form `kind == "RayLanding"` stand in for enumerations. A typo is a silent `False`.
- Duplicated implementations: `gcd` in `rat_q.mojo`, `big_int_boundary.mojo`, `certificate_sets.mojo`, and `C1_rational_separator_coding.mojo`; rational structs `Q`, `Rat` (twice); ray-address structs `RayAddr`, `RayAddrCode` (twice), `RayAddrFinite`, `RayAddressDatum`.

### F9. A false mathematical sentence survives in the calculus document (medium)

`docs/finite-certificate-calculus.md` line 40: "Galois conjugates can mix exact-type and lower-type roots inside the same irreducible factor over `Q`." This is false. For fixed `(i,j)`, the collision `Q_i(c) = Q_j(c)` is the vanishing of `Q_j - Q_i` in `Z[C]` at `c`, so it holds at every conjugate of `c` if it holds at `c`; the collision pattern, hence the exact type, is constant on Galois orbits. `docs/cross-program-bridge-psc-nlapjt-2026-09-12.md` section C1 already proves this. The policy that the sentence motivates (pointwise exclusion rather than global factor stripping) remains sound, only over-conservative; the justification should be corrected rather than the policy.

### F10. Documentation drift (low)

- `kernel/mojo/README.md` says "Prototype implementation will go here after the certificate grammar stabilizes" and lists `poly/`, `interval/`, `krawczyk/` subdirectories that do not exist; `src/` holds 69 flat files.
- `ROADMAP.md` Phase 5 names Lean/Rocq, Rust or Zig, and Python/Sage; `README.md` declares Mojo-first. Phase 0's "computed multi-ray stress test" is unchecked although `M_{4,1}` material exists.
- Three Mojo files are referenced by no test, tool, or document: `interval_exclusion_plan.mojo`, `poly_division_plan.mojo`, `smoke_tests.mojo`.
- The CI workflow file is named `no-trig-audit.yml` but the workflow is `finite-regime-core-audit`, and it enumerates 59 test files by hand instead of `pytest tests/`.

### F11. Repository hygiene (low)

- No `LICENSE`. For a repository pairing a manuscript with code this leaves reuse undefined.
- No `.gitignore`; a local `pytest` run leaves `__pycache__` ready to be committed.
- No `pyproject.toml` or `requirements.txt`; CI depends on whatever `pytest` the runner image ships.
- The workflow declares no `permissions:` block and pins `actions/checkout@v4` by tag rather than SHA.
- No secrets, credentials, or personal data were found.

## What is sound

- The manuscript `paper/finite_certificates_for_mandelbrot_fibers.tex` is internally consistent. All 9 citation keys resolve. The conditional proof criterion (the theorem in section 6) is a valid contrapositive argument under its four stated hypotheses. The paper claims nothing beyond a reduction. TeX was not available in the audit container, so compilation was not verified.
- `tools/poly_reference.py` and `tools/interval_exclusion_reference.py` are correct; both pass, and their outputs agree with independent recomputation.
- Independently verified identities: `R_{2,1} = C^3 (C+2)`; `R_{4,1} = C^5 (C+2) (C^3+2C^2+2C+2) F_7`; the `M_{4,1}` parameter angles `{9/56, 11/56, 15/56}` have doubling preperiod 3 and period 3, consistent with `lambda = 3` and `(l,k) = (4,1)`.
- The interval kernels in `interval_q.mojo` (`IQ.mul`, `IQ.sub`, `IQ.square`, `ComplexIQ.mul`) are mathematically sound enclosures, modulo dependency widening, once the language issues in F2 are fixed.
- The boundary-of-claims discipline (`README.md`, `docs/C1_proof_definition_and_priority.md`, `mojo_theorem_kernel.check_proof_object`) consistently refuses to let bounded search, renderer output, or label equality count as a proof of C1. That discipline is the repository's strongest asset.

## Remediation, in order

1. **Make CI reach the tests.** Restrict the lexical scanners to code tokens in `src/`, exclude `tests/` and `tools/`, allowlist `degree` as polynomial degree. Expect one hour. (F1, F6)
2. **Fix the four defects the tests already found.** Replace the `P_{4,1}` literal with the computed expansion, or better, compute it from the factors at module load; update the ledger document and test to `TheoremTagPayloadInstances`; delete or rewrite the two tests that never matched anything. Run `pytest tests/` unfiltered in CI. (F3, F4, F5)
3. **Give Mojo a toolchain.** Add `pixi.toml` pinning a Mojo release, port `let`/`inout`/`@value`/`StaticTuple`, add `@staticmethod`, add a `mojo build`/`mojo run smoke_tests.mojo` CI job. Convert each `"fn foo(" in src` test into a call to `foo` from an executable Mojo test. (F2, F4)
4. **Correct the Galois sentence** in `docs/finite-certificate-calculus.md` and cite the bridge document's proof. (F9)
5. **Replace literal-returning policy functions** with data checked by the kernel, and string kinds with enums, so a ledger state is derived rather than declared. Collapse the duplicate `gcd`, rational, and ray-address types. (F8)
6. **Implement the bigint boundary** before any certificate is marked proof-grade; add overflow tests at `Q_8`. (F7)
7. **Add `LICENSE`, `.gitignore`, `pyproject.toml`**, `permissions: contents: read` in the workflow, and reconcile `kernel/mojo/README.md` and `ROADMAP.md` with `README.md`. (F10, F11)

Items 1 and 2 are small and unblock everything else. Until item 3 is done, no statement of the form "checked by the Mojo theorem kernel" is true.
