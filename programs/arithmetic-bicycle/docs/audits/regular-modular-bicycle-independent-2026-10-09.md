# Independent fixed-TU acceptance audit — 2026-10-09

Claims: `ABC-REGULAR-MODULAR-BICYCLE` and the retracted
`ABC-UNIVERSAL-TORSION-MODEL`.
PR: <https://github.com/larsbx/arithmetic-bicycle-conjecture-research/pull/3>.
Audited contribution: `2da34fe53a8f27f58d88f4159bf7965edb4604db`.
Original tree: `d91931e34f3f89efbf04f65a401b99d54b477a49`.
Merged graph main: `cd4a90d671c7bb92d1ce5f045e997f2b40158d8a`.
Main tree: `7807a2f282c59a9786e4d8c6e508d490aa74d618`.
Rebased contribution: `3f6e3f14b5f630b4fdcfe37e98dec4f11e223056`.

**Result:** the fixed-TU integral proof and its implementation pass a fresh
acceptance review. No mathematical or implementation defect was found.
The universal torsion-model counterexample is valid. Promote the fixed-TU
claim only; keep the arithmetic realization-invariance conjecture open.

This review was conducted by Codex in a separate acceptance-review session:
the maps were rederived from the integral splitting identity, the source
and independent oracle were inspected, and the pinned evidence was replayed.
The [contribution author's audit](regular-modular-bicycle-2026-10-09.md)
remains provenance. This supplement is the current fixed-TU acceptance
audit locator; computational independence and acceptance review are
different checks.

## Integral proof

A full-row-rank TU matrix has a unit maximal minor. Its inverse embeds
into an integral matrix `R` with `AR=I`. Therefore `R^T A^T=I` over every
`Z/n`, including arbitrary composite rings. The potential of a modular
cut is unique modulo `n`. The integral sum-of-squares argument proves
`Q=AA^T` nonsingular over `Q`; it does not assert that `Q mod n` is
invertible. Its modular kernel is exactly where nontrivial bicycles occur.

| Obligation | Independently checked identity |
| --- | --- |
| Forward domain | `b=A^T y mod n` and `Ab=0` give `Qy=nd` with `d` integral; `n[d]=[Qy]=0`. |
| Potential and lift independence | Equal modular gradients imply `y'-y=nz` by `R^T`; their divisors differ by `Qz`. Arbitrary raw edge lifts do not replace integral gradient lifts. |
| Module structure | Addition and integer scaling of potentials induce addition and scaling of divisor classes. Both modules are annihilated by `n`. |
| Injectivity | `Qy/n=Qz` implies `Q(y-nz)=0`; nonsingularity gives `y=nz` and hence `b=0`. |
| Inverse existence | By the cokernel definition, `n[d]=0` supplies an integral `y` with `Qy=nd`; its gradient is a cut and a cycle. |
| Inverse representatives | For a fixed `d`, nonsingularity gives a unique integral solution. Replacing `d` by `d+Qz` replaces it by `y+nz`, giving the same modular gradient. |
| Left inverse | For `d=Qy/n`, reuse `y`; `Psi_n(Phi_n(b))=b`. |
| Right inverse | For `Qy=nd`, the forward image of the inverse is `[Qy/n]=[d]`. |
| Rank zero | `Z^0`, its Gram cokernel, and the cut image are zero, even with zero/loop columns. |

None of these arguments divides by a nonunit in `Z/n`, assumes a field,
uses an element count to establish an inverse, or derives the theorem
from finite fixture agreement. The broader integral statement only needs
split surjectivity; the executable candidate deliberately verifies TU.

## Modulus compatibility

For `m=kn`, reduction uses the same integral potential and satisfies
`Phi_n(rho(b))=k Phi_m(b)`. Inflation sends `b` to `kb mod m`, uses
potential `ky`, and satisfies `Phi_m(iota(b))=Phi_n(b)`. Changing an edge
representative by `nz` changes its inflation by `mz`, so inflation is
well defined and injective. Both mixed composites are multiplication by
`k` on their respective modules. Reduction need not be surjective.
For `n|m|ell`, reductions compose and inflation scale factors multiply.
These identities also give the commuting inverse squares.

## Coordinate equivariance and claim boundary

For specified `A'=UAS`, with `U` integral unimodular and `S` a signed
permutation, the correct conventions are `b'=S^T b`, `y'=U^-T y`,
`Q'=UQU^T`, and `d'=Ud`. In particular,
`Q' Z^r=UQ Z^r`, so `[d] -> [Ud]` is an invertible cokernel map.
Substitution gives `Q'y'/n=UQy/n`. The inverse square follows from
`Q'y'=nUd`. A row change may lose TU but retains right inverse
`S^T R U^-1`; this is a statement of the split-surjective lemma,
not permission to bypass `TURepresentation` validation.

The proof establishes these specified equivalences. It does not itself
supply the theorem relating arbitrary representations of a regular matroid.
During source review, Backman–Baker–Yuen (arXiv:1701.01051v3), Section 2.1,
Lemma 2.1.1 was located: it states the TU coordinate-equivalence theorem.
Proposition 2.1.2 gives the Gram-cokernel identification cited by the
contribution. The [source record](../../sources/regular-matroid-background.md)
now identifies the lemma precisely. Phase 3 still requires an audit of
its labeling/hypotheses and a repository proof record for applying the
coordinate maps to the whole tower. No representation-invariance claim
is promoted by this contribution.

## Arithmetic obstruction

Pagaria–Paolini (arXiv:1908.04137), Section 2, distinguishes torsion-free
`m(empty)=1` from surjective `m(E)=1`. The representation `A=[2]` in `Z`
has multiplicities 1 and 2 respectively and is within the torsion-free
arithmetic domain of the withdrawn statement.

Direct edge membership gives `Bic_2={0}` and `Bic_4={0,2}`. In general,
`y -> 2y` identifies `ker(4 mod n)/ker(2 mod n)` with the bicycle module,
which is cyclic of order `gcd(n,4)/gcd(n,2)`. At modulus 2, potentials
0 and 1 give the same zero bicycle but proposed Gram classes 0 and 2
in `Z/4`, so the unsplit forward formula is not well defined.

If `H[2]=0` and `4x=0`, then `2x` is in `H[2]`, so `2x=0`, and then
`x` is in `H[2]`, so `x=0`. Thus no abelian group, finite or otherwise,
has the two required torsion modules. This disproves the universal group
strengthening. It supplies one realization, not two inequivalent
realizations with equal arithmetic data; it does not settle ABC.
The split-surjective non-TU control `A=[1,2]` correctly distinguishes
loss of splitting from loss of TU.

The registry, README, architecture, roadmap, current status, and both
new proof records consistently preserve this retraction. Earlier dated
graph/status audits remain historical snapshots.

## Exact evidence and added regressions

The entire tested original local Git tree matches the remote contribution
tree. The candidate checks every TU minor by rational elimination, uses
the first unit column basis, and computes Gram classes by rational
inversion. The oracle imports no kernel code: Bareiss determinants and
all-minor Smith factors, last-basis Cramer cycle completion, and quotient
enumeration from standard generators give independent routes. Its
expected quotient classes do not depend on either theorem map. Small
literal edge and potential enumerations cross-check the oracle.

The original 37 tests pass, including the 456 full-row-rank TU matrices
among all 729 ternary 2-by-3 matrices, checked at four moduli. Both original
source-pinned receipts replay without byte changes: 53 graph modulus
cases and 70 graph tower pairs; 36 TU modulus cases, 44 TU tower pairs,
and 12 separately labeled non-TU control cases.

Four [acceptance-review regressions](../../conformance/test_regular_modular_bicycle_audit.py)
raise the combined suite to 41 tests:

- All 48 signed column permutations of a triangle representation,
  combined with the nonorthogonal unimodular row change
  `U=((2,1),(1,1))`, at six moduli. The resulting matrices are non-TU;
  literal enumeration verifies all 288 coordinate/modulus cases and
  Cramer solves check the explicit forward and inverse squares.
- The cographic K3,3 Gram quotient, with Smith factors `(1,3,3,9)`, at
  nine further composite moduli through `9 * 2^80 * 5^4`. Independent
  quotient enumeration supplies all expected torsion classes and Cramer
  solutions, without attempting modulus-sized enumeration.
- The same noncyclic quotient at twelve moduli through 216: 51 proper
  tower pairs and 105 strict chains, checking reduction, inflation,
  their mixed composites, and both chain identities.
- Literal scalar-two edge membership for every modulus 2 through 128,
  with the ambiguous zero-bicycle potential images at every even modulus.

## Rebase provenance and validation

Current main and PR #2's head have exactly the same graph tree
`7807a2f282c59a9786e4d8c6e508d490aa74d618`. Reparenting only PR #3's
additional commit onto current main therefore gives the identical
contribution tree `d91931e34f3f89efbf04f65a401b99d54b477a49`, with no
graph commits or generated artifacts copied into the PR delta.
The original graph proof, kernel, oracle, fixtures, tests, replay,
receipts, dated audits, and graph claim record remain unchanged.
The original fixed-TU proof, counterexample, kernel, oracle, fixtures,
tests, replay, and receipt also remain unchanged by this supplement.

Validation on Python 3.12.14:

```sh
python conformance/check_claims.py
python -m unittest discover -s conformance -p 'test_*.py' -v
python conformance/replay_graph_modular_bicycle.py --check
python conformance/replay_regular_modular_bicycle.py --check
git diff --cached --check
```

Seven claim records validate; all 41 tests and both receipt replays pass.
Only the fixed-TU claim changes from `working` to `proved` relative to main.
The graph claim stays `proved`; the universal torsion model is retained
as `retracted`; ABC-MAIN and ABC-REALIZATION-INVARIANCE stay `open`.
Other preexisting claim states are unchanged. Python acceptance authority
remains false. Current-head CI and remote review are checked separately
as merge-time gates; this record does not substitute an old run for them.
