# Independent graph modular-bicycle audit — 2026-10-09

Claim: `ABC-GRAPH-MODULAR-BICYCLE`.
PR: <https://github.com/larsbx/arithmetic-bicycle-conjecture-research/pull/2>.
Audited theorem/implementation head: `4f41f2a6b42f6c14d50cfc71dd19e8d900844d0b`.
Base: `369e75e8388422ab1a77c9a917d02c3fa6c42b83`.
Original Git tree: `98c301632f65cf988e38401064a3299d02a8be70`.

**Result:** the integral theorem and candidate implementation pass independent
review. No mathematical or implementation defect was found. Four additional
regressions strengthen finite evidence without changing the theorem, kernel,
oracle, original fixtures, or original source-pinned receipt. This record
supersedes the contribution's [October 8 audit](graph-modular-bicycle-2026-10-08.md)
as the current graph-claim audit locator; the earlier record remains provenance.

## Integral proof audit

The convention is `K(G)=D^0(G)/L Z^V`: the finite degree-zero divisor
quotient, not the full Laplacian cokernel with its free summand.

For connected graphs, paths prove `ker(B^T mod n)=(Z/n)1` for every
modulus. Two integral potentials for the same modular gradient therefore
differ by `c1+nz`. No field division is used. Independently, the integral
identity `w^T Lw=sum_e(w_head-w_tail)^2` proves
`ker(L on Z^V)=Z1`. This must not be confused with the usually larger
modular kernel of `L`. Clearing rational denominators gives rank `|V|-1`;
the Laplacian image has finite index in `D^0(G)`. The degree map on the
full cokernel has free cyclic quotient, so its finite kernel is exactly
the torsion subgroup.

| Obligation | Independent verification |
| --- | --- |
| Forward map lands in the target | The cycle condition makes `Ly` divisible by `n`. Thus `d=Ly/n` is integral, degree zero, and `n[d]=[Ly]=0`. |
| Forward potential and lift independence | Changing `y` to `y+c1+nz` changes `d` by `Lz`, so its class is unchanged, including for negative lifts. |
| Module homomorphism | Adding or scaling potentials adds or scales `Ly/n`; annihilation by `n` makes the homomorphism `Z/n`-linear. |
| Injectivity | If `Ly/n=Lz`, then `y-nz` is an integral constant, so `B^T y=n B^T z` and the bicycle is zero. |
| Inverse existence | By the quotient definition, `n[d]=0` supplies an integral solution `Ly=nd`; its gradient is both a modular cut and a cycle. |
| Inverse solution independence | Two solutions for the same `d` differ by an integral constant; their gradients agree even integrally. |
| Inverse divisor independence | Replacing `d` by `d+Lz` admits solution `y+nz`. Any other solution differs by a constant, so the gradient modulo `n` is unchanged. |
| `Psi_n Phi_n=id` | Reuse the original potential with `d=Ly/n`; the inverse returns its gradient modulo `n`. |
| `Phi_n Psi_n=id` | Reuse any solution `Ly=nd`; the forward map returns `[Ly/n]=[d]`. Neither inverse identity is inferred from counts. |

### Graph equivariance, roots, loops, and parallel edges

For vertex permutation `P` and signed edge permutation `S`, the convention
`B'=P B S` gives `L'=P L P^T`, transformed bicycle `S^T b`, and
transformed divisor `Pd`. Potential `Py` proves the forward square,
and `L'(Py)=nPd` proves the inverse square. Any subset of edges can
be reversed independently.

Loops have zero incidence columns, hence zero coordinates in every
modular cut, and contribute nothing to the Laplacian. Parallel edges
remain separate coordinates and each contributes its incidence outer
product. For one vertex, with or without loops, all three groups are
zero and both formulas still apply.

Dropping a root coordinate identifies `D^0(G)` with an integral lattice.
Subtracting the root value from a potential identifies the dropped full
Laplacian image with the reduced Laplacian image. Its rational-potential
coordinate modulo integers is consequently faithful. An integral reduced
solution satisfies the omitted row because both sides have degree zero.
The theorem and both maps are independent of the computational root.

### Arbitrary composite-modulus compatibility

For every `m=kn`, `n>=2`, including nonunit `k` modulo `n`:

- Reduction preserves cuts and cycles. Using the same potential gives
  `Phi_n(rho b)=[Ly/n]=k[Ly/m]`: multiplication by `k` on torsion.
- Inflation `b -> kb mod m` is well defined since changing a representative
  by `nz` changes its inflation by `mz`. It is injective on the ambient
  module. Potential `ky` gives `Phi_m(iota b)=[L(ky)/m]=[Ly/n]`:
  inclusion of torsion subgroups.
- For `n|m|ell`, inflation factors multiply to `ell/n`, while ordinary
  reduction composes transitively. Both mixed compositions equal
  multiplication by `k` on the appropriate bicycle module. The same
  identities give compatibility of the inverse isomorphisms.

The two-parallel-edge negative control is correct: both modulus-2 and
modulus-4 groups have two elements, but reduction from 4 to 2 is zero.
Reduction is therefore not generally surjective; unscaled inclusion of
edge representatives cannot substitute for inflation.

## Implementation and independent oracle

The candidate validates connectedness, integer coordinates, moduli, and
roots. It checks both cut and cycle conditions, recovers a potential by
path integration, and uses the actual integral gradient to compute
`Ly/n`. Optional potentials are checked against the bicycle. Divisibility
is checked before exact division. Rational Gauss-Jordan inversion rejects
nonintegral solutions and checks the full Laplacian equation, including
the omitted row. Reduction/inflation validate the source bicycle and
divisibility relation. Python integers and `Fraction` avoid rounding
and fixed-width overflow; exhaustive enumeration has no silent cap.

The oracle imports no kernel code. It separately constructs the
multiplicity Laplacian, computes Bareiss determinants and all-minor
Smith factors, enumerates chord/tree cycles, and compares Cramer class
coordinates. Its critical-group enumeration uses divisor generators,
independently of bicycles and the proposed map. Entire sets, classes,
orders, and both inverse maps are checked. Determinants and Smith factors
also have separate permutation-expansion and unimodular-transform tests.

## Replayed and added evidence

Python 3.12.14 passed the original 17 tests, the six-claim registry
validation, and byte-for-byte receipt replay: ten fixtures, 53 modulus
cases, and 70 proper tower pairs. The original exhaustive 44-connected-
simple-graph check at four moduli also passed. All 26 original file blobs
and the complete local snapshot tree matched the audited Git objects.

Four additional tests in `conformance/test_graph_modular_bicycle_audit.py`
passed; the final combined suite has 21 passing tests:

1. Single-vertex graphs with no edges, one loop, or two loops, including
   constant potentials and rejection of nonzero loop coordinates.
2. An oppositely oriented parallel pair with a loop at each endpoint.
   The literal answer `(0,u,-u,0)` with `n|2u` is checked for moduli
   2 through 36, plus 72 and 144. Integral potential, divisor, and edge
   lift changes larger than 64 bits exercise representative independence.
3. A doubled triangle for all 64 independent edge-orientation choices,
   all six vertex permutations, and rotated/reversed edge orders at
   moduli 6 and 12. Both maps and every root are checked: 768 transformed
   graph/modulus scenarios and 9,216 transformed bicycle cases.
4. The doubled triangle, with independently checked critical group
   `Z/2 + Z/6`, at moduli `2,3,4,6,8,9,12,18,24,36,72`. Independent
   quotient classes check both maps. Tower identities cover 37 proper
   pairs and 55 strict three-modulus chains. Reduction from 72 to 12
   is explicitly zero on its twelve-element domain.

The original proof, kernel, oracle, fixture, and receipt bytes are
unchanged. The receipt retains its original 53-case/70-pair scope; the
additional tests are separate evidence run by the same CI workflow.

Original negative controls also passed: a cycle without a cut, a cut
without a cycle, incorrect potentials, non-torsion divisors, invalid
domains, arbitrary raw edge lifts in the forward formula, unscaled
inflation, nonsurjective reduction, and torsion exponents invisible
to mod-2 ranks. The added tests explicitly reject nonzero loop coordinates.

```sh
python conformance/check_claims.py
python -m unittest discover -s conformance -p 'test_*.py' -v
python conformance/replay_graph_modular_bicycle.py --check
git diff --check
```

## Review and claim boundary

Initially PR #2 was open and mergeable at the pinned head. Workflow
`37764201867` passed every graph-conformance step; the same-head push
workflow also passed. Automated review was completed without reported
inline findings. No inline review threads or blocking reviews were
present, and main had not advanced. There was no repository `AGENTS.md`
or mandatory-review ruleset. Current-head CI and review state must still
be read immediately before merging the audit supplement.

Only the graph claim satisfies the integral-proof and independent-evidence
gates. The five other claim records are preserved verbatim from the base:
the regular-matroid theorem, fixed-realization order, and projective shadow
stay `working`; `ABC-MAIN` and arithmetic realization invariance stay
`open`. Regular representation independence is not established.
Python remains candidate machinery with `acceptance_authority=false`.
