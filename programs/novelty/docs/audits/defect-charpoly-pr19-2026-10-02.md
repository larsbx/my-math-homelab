# Independent AI audit of PR 19

**Reviewed head:** `ce6e7c8c67d6892473e2365d91bac87afbcda842`.
**Audit date:** 2026-10-02. **Repository follow-up:** 2026-10-03.
**Status:** pending human review; finite evidence and an AI proof assessment.

The audit of [PR #19](https://github.com/larsbx/novelty-lab/pull/19) found no
error in Lemma 3.19, Theorem 3.20, or the unipotence criterion of Corollary
3.21 under their stated assumptions: an eight-dimensional unital composition
algebra with nondegenerate norm over a field of characteristic not two.
The polynomial identity includes norm-zero operands; the normalized defect
requires `nu = N(x)N(y) != 0`. The identities are elementary consequences of
the classical composition and quaternion-doubling foundations, not a novelty
claim. Their proof records remain pending.

The density step is over an algebraic closure of the base field, which is
infinite even for a finite base field. The relevant nonempty open subsets of
affine space are dense there; equality of polynomial coefficients descends
through the injective field extension. It does not rely on sampling being
dense over a finite field. Doubling is used only where `nu N(xy-yx) != 0`.
The multiplication order gives `h = conj(xy) yx`; right multiplication by h
on a quaternion algebra has characteristic polynomial
`(Y^2 - T(h)Y + N(h))^2`, without a diagonalizability assumption.

## Required correction and exact counterexamples

The first open problem in the manuscript said that the conjugacy class of
the defect was governed by `tau`. Theorem 3.20 determines the characteristic
polynomial, which does not determine conjugacy. The follow-up corrects this
wording and keeps the additional conjugacy data as an open question.

In the repository's `cayley-dickson/v1 (-1,-1,-1)` model over F3, every pair
below has `nu = 1`. Coordinates use the fixed eight-element basis.

| x | y | dim Q | tau | rank of Delta minus I |
| --- | --- | --- | --- | --- |
| `(1,0,0,0,0,0,0,0)` | `(1,0,0,0,0,0,0,0)` | 1 | 2 | 0 |
| `(0,0,0,0,2,0,2,0)` | `(0,0,1,2,0,2,2,2)` | 3 | 2 | 2 |
| `(0,2,0,2,0,1,2,2)` | `(0,1,0,2,1,0,2,2)` | 4 | 2 | 4 |

These have `N(xy-yx) = 0` and the same polynomial `(X-1)^8`, but unequal
conjugacy-invariant ranks. For `x=y=1`, Q is a nondegenerate scalar line:
`N(xy-yx)=0` is equivalent to **dimension at most three or degeneracy of Q**,
not to degeneracy alone.

Two further pairs show that restricting to nondegenerate quaternion Q does
not repair the conjugacy claim. Over F3, `tau = -2 = 1`:

| x | y | rank of Delta squared minus I |
| --- | --- | --- |
| `(0,1,0,0,0,0,0,0)` | `(0,0,1,0,0,0,0,0)` | 0 |
| `(2,0,0,1,0,0,0,0)` | `(0,0,2,2,0,0,0,0)` | 2 |

Both have `dim Q=4`, `N(xy-yx)=1`, and characteristic polynomial
`(X-1)^4(X+1)^4`. Their minimal polynomials are `(X-1)(X+1)` and
`(X-1)(X+1)^2`, respectively. The second quaternion multiplier is
`g=(2,1,2,1,0,0,0,0)`; `g+1` is nonzero and squares to zero.

The follow-up also replaces the proof's reference to the pending fixed-Q
theorem with the direct associative computation `M(w)=nu w` inside Q, so
the written proof matches its declared composition/doubling dependencies.
It makes the unipotence converse and the use of Cayley-Hamilton explicit.
Neither clarification promotes the earlier rank-law dependency.

## Testing assessment and follow-up regressions

At the reviewed head all 127 repository tests passed. The independent audit
compared the new charpoly helper with a division-free SymPy oracle on 2,158
matrices. It independently checked 1,250 original seeded pairs and 500 pairs
in a separate Zorn vector-matrix implementation. Thirty explicit domain
fixtures passed, including refusal of all fifteen undefined normalized
defect evaluations. Python was 3.12.14 and SymPy was 1.14.0.

The existing tests reached `nu=0, N(xy-yx)!=0` and admissible degenerate
four-dimensional Q, but did not assert that coverage. Their standalone
companion fixture was already Hessenberg and did not independently exercise
similarity reduction. The dimension-three slice visited 1,543 pairs, with
720 admissible pairs, but counted only total pairs for its coverage check.

The follow-up adds deterministic counterexamples, norm-zero and scalar
fixtures, explicit coverage assertions, trace and nilpotence checks, and
arbitrary-matrix comparisons with a separate principal-minor/permutation
oracle. The doubling check evaluates every Q basis vector, verifies the norm
and trace of g, and finds an anisotropic vector among basis vectors and their
pairwise sums instead of skipping a complement with an isotropic basis.
These CI regressions use only the Python standard library. The matrix helper
is tested in characteristic two as well; the algebraic claims retain their
characteristic-not-two hypothesis.

Follow-up validation on October 3: all 133 repository tests passed, including
the 11 tests in `test_defect_charpoly.py`. The F3 tensor, registry, vendored
sync, generated-ledger and claim-governance checks passed, as did the exact
rank-law census, defect census, paper-table checks, and `latexmk` PDF build.
The Lean toolchain was unavailable locally; its separate GitHub workflow
remains required. The PDF build retains an overfull box in the unchanged
closing paragraph.
The archived replay script was also run from its new location against the
exact reviewed head, reproducing the original JSON byte for byte.

## Archived evidence and reproduction

The [original report](evidence/defect-charpoly-pr19-2026-10-02/novelty_lab_pr19_independent_audit_2026-10-02.md.txt),
[exact output](evidence/defect-charpoly-pr19-2026-10-02/pr19_audit_evidence.json),
[replay script](evidence/defect-charpoly-pr19-2026-10-02/pr19_audit_replay.py),
[test log](evidence/defect-charpoly-pr19-2026-10-02/pr19_unittest.log),
[validation record](evidence/defect-charpoly-pr19-2026-10-02/pr19_validation.json),
and [manifest](evidence/defect-charpoly-pr19-2026-10-02/pr19_manifest.json)
are archived byte for byte. The original report is stored with a `.txt`
suffix as immutable source evidence; its historical headings are not new
repository theorem declarations. The manifest retains the original `.md`
filename, so strip the storage suffix when matching that entry. The active
assessment above carries the repository's pending status.
The original report and proposed patch describe
the October 2 state before these follow-up changes, not the updated branch.
The replay script intentionally requires the exact reviewed head.

From the repository root, with Python 3.12.14 and SymPy 1.14.0 available:

```sh
git worktree add --detach /tmp/novelty-pr19-audit ce6e7c8c67d6892473e2365d91bac87afbcda842
python docs/audits/evidence/defect-charpoly-pr19-2026-10-02/pr19_audit_replay.py /tmp/novelty-pr19-audit > /tmp/pr19-audit.json
sha256sum /tmp/pr19-audit.json
python -m unittest discover -s tests -p 'test_defect_charpoly.py' -v
```

The archived JSON SHA-256 is
`5bf781c3cb1982cfbbda4eb6afe061b04bb8fe1039e00fe3711c26416e436879`.
The manifest records every other original artifact digest. The original
report records the foundation sources, search queries, scope restrictions,
seeds, and source-file digests required by the calibration policy. This was
a bounded foundation check; the separate prior-art and bibliography gates
remain open.

`DefectCharacteristicPolynomial` remains `pending_dependency`. No human
reviewer, `proof_reviewed`, review acceptance, or theorem/novelty promotion
is supplied by either this AI audit or these finite tests.
