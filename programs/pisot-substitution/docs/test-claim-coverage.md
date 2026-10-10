# Which test guards which claim

**Status:** engineering record of the `coverage` check, round-two item R8 (transfer A2) of `docs/cross-pollination-round-two-2026-09-16.md`. It states no mathematics and changes no claim status. The mechanism is the vendored `claim_governance` package (`audit/docs/policy-format.md` in `larsbx/finite-math-kernels`, section `[coverage]`); the policy is the `[coverage]` table of `claim_governance.toml`; the declarations are the vendored `kernel/mojo_smoke/claims.mojo` (formerly `kernel/psc/claim_tests.mojo`).

## 1. What a declaration says, and what it does not

`larsbx/crypto-composer` refuses to let a test exist without a proof statement, an argument, and the constraint identifiers it guards. This repository had the same intent in the `AGENTS.md` review gate — "Mojo regression coverage for the theorem/invariant contract" — and nothing that linked a test file to a claim. Now each file under `kernel/tests/` ends its `main` with one of:

- `require_claim("<Name>")` — the test pins a contract that the named ledger claim's certificate rests on;
- `require_contract("<what it pins>")` — the test pins a contract that is no ledger claim, as for a vendored kernel.

A declaration is a link, not evidence. That the contract holds is what the test's assertions decide; that the claim follows from the contract is what its own proof, certificate, or manuscript argument decides. In particular a declaration never promotes anything: the status of every claim is the ledger's, and the ledger is generated from the proof-record table of `tools/make_ledger.py`.

## 2. The three layers, and what each can catch

| Layer | Runs | Catches |
| --- | --- | --- |
| static | anywhere, no toolchain | a test that declares neither a claim nor a contract; a name that is in no claim or alias of the ledger; a required claim that no test names |
| receipts | after `kernel/run_tests.sh` | a declaration the run did not reach, because the test body is never called from `main` or its file failed; a receipt no test declares |
| seam | `pytest tests/test_claim_coverage.py` | drift between the Mojo receipt prefixes, the `awk` that reads them, and the policy paths |

`run_tests.sh` rewrites `kernel/build/claim-receipts.tsv` from empty on every run and appends only the receipts of tests that *passed*, so a red suite credits nothing and a stale receipt cannot survive. The file is a run product and is not committed. Without it — a checkout with no Mojo toolchain — the static layer still runs and reports honestly that it is the only one that did.

## 3. Which classes must be guarded, and why only those

`require_classes = ["finite-domain", "evidence"]`. Those two classes are the ones whose whole warrant is an exact finite computation: the live claim map gives "canonical Mojo certificate" as the source of each. An unguarded claim of either kind has no live warrant at all, so the check refuses it.

A repository-proved claim is deliberately not required to name a test. Its warrant is a manuscript proof, a Lean proof in `proof/PscVerif/`, or an archived certificate, and demanding a Mojo test of `PhiSemisimplicity` or `WedgeBound` would manufacture a link this repository does not have. The ranked item asked for "every `proved` claim names at least one passing test"; that is narrowed here, and section 5 records what the narrowing leaves open.

## 4. The declarations

| Test | Claims guarded | Contract stated |
| --- | --- | --- |
| `test_affine_ancestry_trace.mojo` | `G1b2RenewalFiniteness` | — |
| `test_bd_endpoint.mojo` | `GlobalEndpointSync` | — |
| `test_boundary_sync.mojo` | `SinkSCCReduction` | the seeded sweep is reproducible from its seed alone, and an exhausted budget reports itself rather than a verdict |
| `test_census_library.mojo` | `BoundedDegree3Exclusion`, `BoundedDegree2WedgeProductivity`, `ParitySieve`, `DefectIntertwiner` | — |
| `test_endpoint_core.mojo` | `EndpointCore`, `SignatureReduction` | — |
| `test_exact_interval.mojo` | — | the exact rational and closed-interval layer: an unknown containment or sign is never promoted, and a coarse audit withholds a partial minimum |
| `test_finite_cokernel_address.mojo` | `G1b2RenewalFiniteness` | — |
| `test_finite_exact.mojo` | — | the vendored `finite_exact` arithmetic and closed-interval kernels compile and hold under the PSC toolchain |
| `test_good_edge_system.mojo` | `GlobalEndpointSync` | — |
| `test_hierarchy_offset.mojo` | `OrientationMonodromy` | the derived system interns each normalized state once and packs relative context with one sentinel |
| `test_hub_cocycle.mojo` | `OrientationMonodromy` | — |
| `test_hub_selector.mojo` | `EndpointCore` | — |
| `test_joint_local_census.mojo` | `G1b2RenewalFiniteness` | — |
| `test_joint_local_type.mojo` | `G1b2RenewalFiniteness` | — |
| `test_kernel.mojo` | `Target1`, `W3LowGrowth` | — |
| `test_legal_tower.mojo` | `C3Locality` | — |
| `test_loop_quotient_census.mojo` | `G1b2RenewalFiniteness` | — |
| `test_oa_overlap_types.mojo` | `SwapOverlapFiniteness` | the Sirvent–Solomyak overlap-type layer agrees with the repository seed-patch graph on the tribonacci calibration |
| `test_overlap_affine_pump.mojo` | `OrderedAffineCycleIdentity` | — |
| `test_overlap_collar.mojo` | `PeriodicPatchCollar`, `FiniteCollarDeath` | — |
| `test_overlap_context.mojo` | `OneStepContextEquality` | — |
| `test_overlap_contracting.mojo` | `OverlapBadSCCNormalForm` | manuscript Proposition 5.42: the contracting bound is decided by exact Sturm–Tarski counting, and a capped graph is rejected |
| `test_overlap_seed_patch.mojo` | `SwapOverlapFiniteness`, `AlignedOverlapsAreStrongCoincidence`, `BoundaryCoincidenceCriterion` | — |
| `test_overlap_zipper.mojo` | `OverlapBoundaryZipperDichotomy` | — |
| `test_pisot_screen.mojo` | — | the degree-`n` Pisot screen is exact and fail-closed: a refusal is never a negative result, and the cubic decider stays canonical for PIP |
| `test_renewal.mojo` | `G1b2RenewalFiniteness` | — |
| `test_renewal_address.mojo` | `G1b2RenewalFiniteness` | — |
| `test_signing.mojo` | `OrientationSpectrum` | — |
| `test_swap_discrepancy.mojo` | `G1b1BoundedDiscrepancy` | — |
| `test_tuning_kernels.mojo` | — | the vendored `substitution_dynamics` tuning, directive-prefix, and column-coincidence kernels hold under the PSC toolchain |
| `test_words_streaming.mojo` | `DefectIntertwiner` | — |

A claim named against an open or conditional node — `G1b2RenewalFiniteness` most often — records that the test guards a diagnostic of that gate's program. It says nothing about the gate.

## 5. What this does not yet cover

- **The Python oracle layer is not read.** `tests = ["kernel/tests/test_*.mojo"]`, so a claim whose only regression is a Python oracle (`tests/test_lattice_lift.py`, `test_meanarea_integrality.py`, `test_multidegree_sieve.py`, `test_lie4.py` among them) counts as unguarded. That is deliberate while Mojo is the canonical layer, and it means the guarded counts below understate the regression coverage of the degree-2 lattice results.
- **Census drivers are not read.** The exhaustive censuses under `kernel/*.mojo` are run by CI and by `tools/verify_all.sh` with their exact output pinned, but they emit no receipt, so a finite-domain claim is guarded here through the library contracts its driver is a survey over, not through the driver's own run.
- **Guarded is not complete.** 18 of the 42 repository-proved claims name a Mojo test today. The rest are manuscript-, Lean-, or certificate-backed, and the check does not ask which of those has a regression, because it cannot tell an absent one from an inapplicable one.

None of the three is a gap in a proof. Each is a bound on what the mechanism reports, stated here so that a passing `coverage` check is not read as more than it is.
