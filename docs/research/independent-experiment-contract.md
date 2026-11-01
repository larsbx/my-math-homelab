# Independent finite experiment contract v1

The arithmetic-bicycle pilot is the implementation pattern for onboarding the
remaining programmes in issue #10. The experiment accepts **finite replay
only**. Source repositories retain theorem, proof, novelty, and retraction
authority. Merging this contract cannot promote a calculation into a general
theorem, nor does a passing source CI grant mathematical acceptance.

## Admission pattern

1. Name the precise question, definitions, imported hypotheses and existing
   source claim IDs. Preserve retractions. Separate the next open obligation
   from established source theorems. Select finite source-owned fixture data;
   do not create a second source research census or schedule its scripts again.
2. Pin one immutable source commit. Review each snapshot against that commit's
   Git tree; preserve raw file bytes, Git blob SHA-1 and SHA-256. Pin the
   selection manifest's SHA-256 in `policy/math-experiments.toml`. Changing a
   pin, selection, expected answer or bound requires another reviewed change.
3. Implement two meaningfully different methods in separate local modules.
   Check witness membership, distinctness and completeness independently.
   Equality between two wrappers of the same source routine is insufficient.
4. Preflight the entire finite scope against explicit dimension, modulus,
   input-size and total-state budgets before exponential work. Never silently
   truncate a scope. Bound CPU, address space, output size and wall time.
5. Test malicious witness omissions, duplicates, false membership, incorrect
   expected answers, fixture/provenance mutation, dropped hypotheses, forbidden
   claim promotion, unavailable workers and exhausted budgets. Cross-check
   methods on tiny exhaustive boxes as well as the source fixtures.
6. Add an allowlisted executor in `tools/math_experiments.py`; policy/fixtures
   cannot supply shell commands, module names or executable source code. The
   child runs with `python -I -B`, an empty credential environment, no stdin,
   a temporary working directory and read-only data inputs. There is no source
   checkout or source process. This is isolation for reviewed local code,
   **not an OS sandbox for arbitrary hostile code**.
7. Opt in exactly one portfolio track with `mode = "independent_finite"`.
   Use its existing weekly shard. Daily collection records registration and
   current source provenance without executing it. AKN keeps its existing
   specialist; do not add another cron or automation for this pilot.
8. Retain source pin, actual input/code/registry digests, homelab Git SHA and
   working-tree state, complete witnesses, both method results, a machine
   verdict and the next source mathematical obligation. Publish exact-revision
   artifacts on CI. A checked-in deterministic worker receipt binds code
   bytes; the coordinator adds the runtime Git revision to its artifact.

## Verdicts and error semantics

| State | Meaning | Exit status |
| --- | --- | --- |
| `verified_finite` | Every selected case completed; distinct witnesses pass independent membership and completeness checks; pinned expected answers agree. | 0 |
| `failure` | Hash/schema mismatch, changed retraction, wrong expected result, method disagreement, invalid witness or malformed worker evidence. | 1 |
| `inconclusive` | Declared finite budget insufficient; worker unavailable; timeout, memory limit or terminating signal prevents full replay. | 2 |

The portfolio cycle returns nonzero for either non-success state and retains
stdout, stderr and `experiment.json`. Its index records `sources_with_errors`;
`unreadable_sources` remains the separate source-provenance failure list.
No partial result is marked complete. Every outcome keeps
`automatic_claim_promotion=false`, `mathematical_theorems_promoted=0`, and
`independent_mathematical_claim_verified=false`.

A pinned experiment is not automatically a test of a later source head.
`source_revision` is the immutable fixture authority;
`observed_current_source_head` is the separately collected current default
head. The equality flag exposes drift. The source's CI state remains separate
from `finite_experiment_verified`; neither fills in the other's acceptance.

## Arithmetic-bicycle pilot

**Question:** Can an independent homelab replay reproduce the existing rank-two
refutation while respecting the essential surjective (`m(E)=1`) theorem's
hypotheses? This does not reopen the original conjecture.

**Pinned source:** `larsbx/arithmetic-bicycle-conjecture-research` at
`87737671a039ba610ba3cfda7c91b78c61fbc1d5`. The manifest snapshots three
source fixture files and four source proof/claim records as inert data under
`policy/fixtures/arithmetic-bicycle/source/`. These are distinct from the
older historical import under `programs/arithmetic-bicycle/`, which is not
changed. No source computation is copied or invoked.

**Route 1:** Enumerate every potential in `(Z/n)^r` to construct `im(A^T)`;
separately enumerate every edge vector in `(Z/n)^e` satisfying `Ax=0`;
intersect the two sets. Deduplicate gradients. No field operations are used.

**Route 2:** Compute Smith invariant factors by gcds of all determinantal
minors over the integers, with a separate exact cofactor determinant. For
`G=AA^T`, the pinned source code-hull interface gives

`Bic_n(A) = ker(G mod n) / ker(A^T mod n)` up to its specified isomorphism.

For Smith factors `d_i` of a matrix with domain dimension `q`, the kernel
cardinality is `n^(q-rank) * product(gcd(n,d_i))`. Thus use the **quotient of
kernel cardinalities** even for nonsurjective matrices. This step does not
assume a right inverse. For the surjective fixtures the denominator is one.
These all-minors computations import neither the enumerator nor source code.

**Witness checker:** For each enumerated edge vector check `Ax=0` independently
and test cut membership in the full-rank integer lattice
`L=A^T Z^r+n Z^e`. Adjoining a vector preserves `[Z^e:L]` exactly when it
belongs to L, checked by gcds of maximal minors. Valid, distinct witnesses
whose count equals Route 2's answer prove completeness in this finite scope.
This also rejects cycles that are not cuts and plausible equal-size fake sets.

All labeled subset ranks and multiplicities are recomputed. The counterexample
must have signature `[(0,1),(1,1),(1,1),(2,5)]`. It has `m(empty)=1` but
`m(E)=5`; torsion-free does not imply surjective. Surjective pairs are checked
for complete arithmetic-data equality under the source's label permutation,
not merely equal determinants. Two positive pairs have no unit maximal minor,
which prevents weakening surjectivity to an invertible-column-basis condition.

## Reproduced finite evidence

The selection contains **12 matrices, 36 matrix/modulus cases, 27,990 potential
and edge states**. Scope is explicit in `manifest.json` and the deterministic
receipt `evidence/arithmetic-bicycle-v1.json`.

| Control | Moduli | Enumerated orders |
| --- | --- | --- |
| `[[1,1],[0,5]]` | 5, 10, 25 | 1, 1, 5 |
| `[[1,2],[0,5]]` | 5, 10, 25 | 5, 5, 5 |
| Scalar `[[2]]` | 2, 4, 8, 12 | 1, 2, 2, 2 |
| Rank zero, two loop coordinates | 2, 4 | 1, 1 |
| Surjective C13 pair, no unit basis | 2, 4, 13, 26 | 1, 1, 13, 13 for both |
| Surjective C49 pair, no unit basis | 2, 7, 14 | 1, 7, 7 for both |
| Primitive non-TU pair | 5, 10 | 5, 5 for both |
| Noncyclic C3+C3 source pair | 3, 6, 9 | 9, 9, 9 for both |

The fixture's C3+C3 description is source-owned; this replay checks its Gram
Smith factors and finite witnesses/counts, not a new tower classification or
all transition/transport maps. Agreement at modulus 25 does not repair the
refutation at 5 and 10. The original two invariance claims and the separate
universal torsion-model claim remain `retracted` in the pinned source ledger.
The corrected surjective theorem remains a **source-proved baseline**; this
adapter supplies bounded consistency evidence, not a new universal proof.

**Resource ceilings:** at most 2 rows, 4 columns, modulus 26, entry magnitude
100, 200,000 vectors per case, 1,000,000 total vectors and 128 KiB source
input. The worker is limited to 10 CPU seconds, 30 wall seconds, 256 MiB
address space, 4 MiB output per stream and 32 file descriptors. Budgets can be
lowered; raising reviewed ceilings requires changing the allowlist code.
Python 3.11+ and Linux resource limits are required; no numerical dependencies
or solver downloads are used.

```sh
python tools/math_research_portfolio.py --mode validate
python -m pytest -q tests
python kernel/workspace.py
python tools/math_experiments.py --out /tmp/ab-pilot
python tools/math_research_portfolio.py --mode weekly --select arithmetic-bicycle --out /tmp/ab-weekly
```

CI replays conformance on PR changes and manual `validate`. Routine daily and
weekly registry validation does not run the pilot conformance suite: recurring
research execution occurs once in weekly shard 0. After review/merge, inspect
the first actual weekly artifact before claiming hosted scheduled acceptance.
Issue #10 stays open for the other programmes and the acceptance gate; do not
check off a source solely because adapter code or offline tests exist.

**Next mathematical obligation:** source task ABC-RD-01, identifying the extra
lattice data needed by nonsurjective towers. Extend only reviewed pinned
fixtures; no general nonsurjective classification is asserted here.

## Local acceptance record (November 1, 2026)

All 45 workspace tests and 24 mutation subtests pass. The estate audit passes
using the exact pinned auditor bytes (SHA-256
`412a64dea58d709aae21e5a0315b8e7e96488c310a9d999267927ba3d8146a30`).
`kernel/workspace.py` verifies all 18 source locks unchanged; the portfolio
validates all 16 active tracks. Every snapshot blob was separately matched
against the GitHub tree for source commit
`87737671a039ba610ba3cfda7c91b78c61fbc1d5`.

A live `weekly --select arithmetic-bicycle` cycle produced `verified_finite`
for all 36 cases and independently retained `source_ci_regression_observed`:
the source's `phase6-lean` run
[39866957515](https://github.com/larsbx/arithmetic-bicycle-conjecture-research/actions/runs/39866957515)
failed while its graph-conformance and estate-audit runs succeeded. This
source CI regression is unresolved by this homelab PR. It does not change
the finite answers or the source's retractions. See the PR's exact-head CI
and attached runtime artifacts for hosted acceptance; the checked-in worker
receipt binds the implementation and inputs by SHA-256 without embedding a
self-referential commit ID.
