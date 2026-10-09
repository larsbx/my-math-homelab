# T1′ audit and validation (2026-10-09)

**Status:** audit evidence. This records the source audit, a proof-notation
correction, independent mathematical review, and executable validation.
It changes no claim status and establishes no all-depth result.

PR #4 had already merged as `5c1f5ea08da569ad242a50e2238e34bdd8b59e96`
at 2026-10-09 08:01:42 UTC before this audit began. The follow-up is based on
`dfcd81632defafbde21f2892fbb8a4b5598d8f81`, after PR #5. Its bounded-anchor
extension remains conditional on its additional hypotheses.

## Validation object reconciliation

| Object | Exact identity | Interpretation |
|---|---|---|
| Original PR commit | `1466a39ee26c2f39f5d17c7581ab7b7724f5b528` | The T1′ contribution |
| Published validation tree | `18210ab1ad3eebe35f555bb01a2c07dc9d6e7c26` | Exactly `1466a39^{tree}`; a tree, not a commit |
| Final PR head | `6d9ff3005a42202e3a0a8ebd64c49df9dfa132ae` | Later review-waiver metadata commit |
| Final head and merge tree | `392e91be8d4fd061636667e21d869215b71152ec` | Exactly both `6d9ff30^{tree}` and `5c1f5ea^{tree}` |

Verified with `git cat-file -t`, `git rev-parse`, and a direct tree diff.
The final head changes five documentation/status files relative to the
published tree. Its `kernel/`, `reference/`, `tests/`, `tools/`, and policy
files are byte-identical to the original contribution. A commit-comparison
404 for the validation tree therefore supplied no evidence of drift.
Rather than relying only on equivalence, the final PR head was replayed
from its own detached checkout.

## Executable validation

| Checked source | Python tests | Mojo test files | Cross-language facts |
|---|---:|---:|---:|
| Actual final PR #4 head `6d9ff30` | 36 passed | 4 passed | 7,614 agree |
| Revised follow-up on `dfcd816` | 59 passed | 5 passed | 11,255 agree |

Both checks used the repository-pinned Mojo compiler
`1.1.0.dev2026090805` (`34562fa1`), executing the commands behind the pixi
tasks directly. Both passed the pinned estate audit, vendoring check,
claim-governance audit, receipt-based coverage, and whitespace check. The
estate audit's SHA-256 was verified as
`7dff31575b2834b937395f3ff6f7ce2e2d1d7927b893cf8229c682ad7f3a99d2`
before execution. Python used version 3.12.14 and pytest 9.1.1.

The final revised return-overlap regressions have SHA-256:

- `tests/test_return_overlap.py`:
  `9092935a33d68453d10c52da5a5c532e1d5fcfbafdfd01d2bc1f93c5fcf334c4`;
- `kernel/tests/test_return_overlap.mojo`:
  `82310a599680c0e89eaffab9b5fa5aba6966016b38032dfa0dc68c1fe03c2f84`.

The exact published follow-up commit and its GitHub check state are
recorded in the PR validation receipt. Local replay results here are not
presented as GitHub Actions results.

## Independent mathematical review record

Date: 2026-10-09. Reviewer: independent mathematical review agent.

Reviewed the T1 material in `docs/t1-uniform-overlap-finiteness.md` at merged
PR #4 head `6d9ff3005a42202e3a0a8ebd64c49df9dfa132ae` and main
`dfcd81632defafbde21f2892fbb8a4b5598d8f81`. The mathematical sections are
identical; main adds only a link and boundary explanation for the later
conditional bounded-anchor result. Read `AGENTS.md`, `docs/METHODOLOGY.md`,
and the literature gate before reviewing. Subsequently re-reviewed the
working-tree corrections to the proof and new Python/Mojo regression
controls. This is independent agent review, not a claim of separate human
review or formal proof verification.

## Verdict

Theorem T1′ is mathematically valid under BST19 Theorem 3.1's exact
hypotheses. No counterexample or gap was found in Lemmas S and P or the
overlap estimate. The one load-bearing notation ambiguity identified in
the initial review has been corrected: PRICE recurrence now explicitly
equates directive blocks. Re-review found no blocking mathematical issue
in the revised proof. The actual imported hypotheses already supplied
this stronger equality, so the theorem needed no additional hypothesis.

## Source verification

Independently read BST19 arXiv v5, §§2.1–2.2, Theorem 3.1, Definition 5.8,
and Lemmas 5.9 and 5.11. Definition 5.8 places its fixed positive matrix at
the terminal end of each recurring prefix and balance at the recurrence
endpoint. Its recurrence equates directive tuples. Lemma 5.9 supplies the
joint sequences; Lemma 5.11 also uses this positive suffix to compare image
sizes. Source: <https://arxiv.org/html/1410.0331v5>; checked against
<https://arxiv.org/pdf/1410.0331>.

## Exact checks of the proof

1. **Endpoint and orientation.** Set `t_k = n_k + ℓ_k`. For each
   `0 ≤ r < h`, directive-block recurrence gives
   `σ_(t_k-h+r) = σ_(ℓ_k-h+r)`, hence
   `M_[t_k-h,t_k) = B`. Incidence matrices act on Parikh columns, so the
   row of image lengths is `1ᵀ M_[0,t_k) = (1ᵀ M_[0,t_k-h)) B`.
   Every entry of the preceding length row is positive because the
   substitutions are non-erasing. Thus Lemma P and C-balance apply at the
   same depth, without a transpose or prefix/suffix reversal.

2. **Lemma P.** For fixed columns `a,b`, multiply each inequality
   `B_ra ≤ R_B B_rb` by `w_r ≥ 0` and sum. A nonzero row and positive B
   give positive output coordinates. A coordinate row supported at an
   extremal row proves sharpness for the stated nonnegative-row domain.

3. **Lemma S.** All four displayed cancellations are exact. In the last
   regime both remaining suffixes have length `|x|+|y|-j`; the two middle
   regimes compare a factor with the shorter whole image. Since `x,y`
   themselves belong to the shifted language, all factors used are legal.
   Neither `xy` nor `yx` needs to be legal. Boundaries including `j=0`,
   `j=min(|x|,|y|)`, `j=max(|x|,|y|)`, and `j=|x|+|y|` are covered.

4. **Overlap estimate.** The two swap words have the same ordinary length,
   so the comparison vertex `V[:p]` exists. Interior intersection implies
   `|x-y| < ℓ_max`; endpoint-only contact is correctly excluded. Therefore
   `|q-p| ℓ_min ≤ |y-y_p| < ℓ_max + C Σ_a ℓ_a`.
   Together with `v = π(V[:q])-π(V[:p])-Δ(p)`, this gives
   `‖v‖∞ < C + R_B(1+dC)`, and hence the paper's weaker non-strict bound.
   After replacing C by its integer ceiling,
   `b = C + ceil(R_B(1+dC))` is a valid conservative integer box radius.
   Its count `d²(2b+1)^d` is correct and is not asserted to be optimal.

## Exposition finding and verified correction

The initial displayed (R) said only
`σ_[n_k,n_k+ℓ_k) = σ_[0,ℓ_k)`.
That equality by itself does not identify individual terminal matrices.
For example, `(id,τ)` and `(τ,id)` compose to the same morphism, but when τ
has positive incidence matrix B, their final single-matrix blocks are B
and the identity. The revised bullet now states
`σ_(n_k+r)=σ_r` for `0≤r<ℓ_k`, and the proof spells out the terminal
product `M_(ℓ_k-h) ⋯ M_(ℓ_k-1) = B`. Its new identity/positive-block
control demonstrates the weaker composite equality. This resolves the
ambiguity without strengthening the imported hypotheses.

## Independent adversarial controls

These are fresh mathematical checks, not reused repository test receipts.

- Exhaustively checked all ordered pairs of nonempty binary words of
  length at most 5 and ternary words of length at most 3: 5,365 word pairs
  and 45,313 swap positions. Literal prefix-count differences agreed with
  all four cancellations and stayed within the joint factor-balance
  constant. The four regimes had 22,819, 2,520, 2,520, and 17,454 positions.
- Let `B=[[2,1],[1,1]]`, `S_m=[[1,m],[0,1]]`, and `w=(1,1)`.
  Then `w S_m B=(m+3,m+2)`, whose ratio is at most `R_B=2`, while
  `w B S_m=(3,3m+2)` has unbounded ratio. Both matrices are unimodular.
  Exact assertions passed for `m=2,12,1000,1000000`.
- The prefix mistake also produces a literal overlap-box violation:
  with `m=12`, lengths `(3,38)`, `x=a^12`, and `y=b`, the joint language of
  these two words is 1-balanced. Indeed they are factors of the
  1-balanced periodic word `(a^12 b)^∞`. Top position `p=8` intersects
  bottom position `q=0`, giving vector `(-8,0)`. Its norm 8 exceeds the
  falsely inferred radius 7. This checks the elementary geometry and
  does not claim a counterexample satisfying all BST19 hypotheses.
- A transpose control uses positive unimodular
  `D=[[1,100],[1,101]]`: the correct row ratio is 101; the maximum ratio
  within columns is only `101/100`, although `(1,1)D=(2,201)` has ratio
  `201/2`. Column extrema cannot replace row extrema for length rows.

## Review of the new regression controls

The revised Python and Mojo files independently guard the endpoint
`t=n+ℓ` using AR3 blocks followed and preceded by long repeated runs. The
selected endpoint has the ratio bound while both the start n and a
later depth violate it. They expressly do not certify balance or infinite
PRICE. The identity/positive swapped-factor control checks the composite
equality ambiguity. The exhaustive binary swap walk covers illegal
concatenation boundaries: `x=01,y=10` have joint balance 1, while the
artificial concatenations have balance 2. Finally, `x=0^n,y=1^n` shows
that individually 0-balanced images do not justify a shared C=0: the
literal overlap vector `(-n,n)` exceeds the resulting conditional box.
That control is correctly labelled as outside the primitive unimodular
BST19 regime. Invalid-matrix, negative-balance, and checked-overflow
refusals remain present. The literal prefix-error vector `(-8,0)` at
lengths `(3,38)` and the asymmetric row-versus-column matrix D from this
independent review are now incorporated into durable Python and Mojo
regressions. Re-reviewed those final additions and reran the targeted
Python test file: 19 passed. Inspected the matching Mojo additions, with
no mathematical defect found; full compiled-language verification is
recorded separately.

## Scope and certification boundary

The argument proves one common finite pool of integer type triples at
selected depths and all higher swap levels. It does not give transition
closure, bounds at intervening depths, balanced-pair termination,
productivity, or pure discrete spectrum. A finite matrix and a supplied C
compute a conditional box; finite word samples cannot certify PRICE or
balance of the infinite shifted languages. Full current-head CI and
validation provenance are outside this mathematical review.
