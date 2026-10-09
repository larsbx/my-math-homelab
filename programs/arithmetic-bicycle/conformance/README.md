# Conformance

Versioned fixtures, canonical encodings, receipts, and counterexamples for replayable exact checks.

## Graph modular-bicycle evidence v1

Run from the repository root with Python 3.11 or later. No external packages
are required:

```sh
python conformance/check_claims.py
python -m unittest discover -s conformance -p 'test_*.py' -v
python conformance/replay_graph_modular_bicycle.py --check
python conformance/replay_regular_modular_bicycle.py --check
git diff --check
```

The original 17 conformance tests cover ten explicit multigraph fixtures at 53
moduli, and all 44 connected labeled simple graphs with at most four
vertices at moduli 2, 3, 4, and 6 (176 further graph/modulus cases).
The fixtures are constructions listed by their complete edge lists, not
an imported census. Loops have zero incidence columns and parallel edges
are separate coordinates.

The graph suite has 21 tests. Four additional
[independent review regressions](test_graph_modular_bicycle_audit.py) cover
all mixed edge orientations and vertex permutations on a doubled triangle,
single-vertex and loop-only graphs, large integral lift changes, and a
noncyclic `Z/2 + Z/6` tower through modulus 72. They check 37 further proper
tower pairs and 55 strict three-modulus chains. The original pinned receipt
retains its 53-case and 70-pair scope. See the
[October 9 independent audit](../docs/audits/graph-modular-bicycle-2026-10-09.md).

Two independent routes must agree:

| Candidate implementation | Independent oracle |
| --- | --- |
| Incidence-product Laplacian | Direct multiplicity Laplacian |
| Normalized-potential enumeration | Chord-valued cycles completed by tree leaf elimination |
| Rational Gauss-Jordan inverse | Exact Bareiss determinants and Cramer's rule |
| Explicit forward and inverse maps | Independently enumerated critical-group quotient |
| Bicycle element orders | Smith factors from gcds of all minors |

Both use integers and exact fractions. The oracle imports no kernel code;
it does not call the proposed theorem map to derive expected counts or
classes. A third literal edge/potential enumeration checks its tree method
on fixtures with at most four edges. Bareiss determinants are checked
against permutation expansion, and Smith factors against planted
unimodular transforms, including singular matrices.

Tests check both inverse identities, sampled integral representative
changes for every fixture bicycle, every computational root, linearity,
signed edge permutations, vertex relabeling, and both modulus maps and
their compositions. Negative tests reject non-cycles, non-cuts, incorrect
potentials, non-torsion divisors, invalid domains, and non-dividing tower
maps. They demonstrate why arbitrary edge lifts, unscaled inflation, and
assuming surjective reduction are invalid, and why mod-2 ranks miss
mod-4 exponents.

The checked-in JSON receipt records fixture results, element-order
profiles, bijection checks, tower checks, bicycle-set hashes, and hashes
of its source files and proof record. Replay compares canonical bytes and
fails on drift. After an intentional source change, inspect the cause and
regenerate with:

```sh
python conformance/replay_graph_modular_bicycle.py --write
```

Enumeration is exhaustive within the stated finite fixtures. There are no
silent caps or timeouts. Potential enumeration is exponential in V-1;
chord enumeration is exponential in E-V+1; the all-minors Smith oracle is
also for small matrices. These checks support the separate integral proof
and do not establish any arithmetic-matroid realization-invariance claim.

## Fixed-TU modular-bicycle evidence v1

The original 16 fixed-TU tests take the combined suite to 37. Seven explicit TU matrices
cover 36 modulus cases and 44 proper tower pairs in the new receipt.
They include rank zero with loop columns, identity coloops, parallel
elements, reduced graphic incidence matrices, and the cographic K3,3
fundamental-cycle matrix. Its Gram Smith factors (1,3,3,9) exercise both
noncyclic torsion and prime-power exponents at moduli 3,6,9.

| Candidate implementation | Independent oracle |
| --- | --- |
| Rational-elimination determinants for every TU minor | Bareiss determinants |
| First unit column basis and integral right inverse | Last unit column basis and Cramer inverse |
| Enumeration of normalized potentials | Nonbasis edge coordinates completed to cycles, then tested as cuts |
| Gauss–Jordan Gram coordinates and theorem maps | Cramer coordinates and quotient enumeration from generators |
| Bicycle orders | All-minor Smith factors and torsion order profiles |

The cycle oracle is also checked against literal edge/potential enumeration
on small fixtures. The tests classify every one of the 729 ternary 2-by-3
matrices: all 456 full-row-rank TU cases agree with the oracle and Smith
counts at moduli 2,3,4,6, giving 1,824 further matrix/modulus regressions.
Graph specialization agrees at every root of every original graph fixture.

Tests cover both inverse identities, integral potential and divisor
changes, large edge lifts, every bicycle pair's addition, integer scaling,
signed column permutations, a nonorthogonal unimodular row transformation,
and every fixture divisibility chain and both modulus-map composites.
Invalid representatives and domains are rejected.

Two separately labeled non-TU controls provide 12 further receipt cases.
A=[2] exhibits ambiguous potential images and contradicts the unconditional
finite-group torsion model; A=[1,2] has an integral right inverse and
satisfies the broader split-surjective lemma. Non-TU by itself is not a
failure signal. The [counterexample proof](../proof/arithmetic-torsion-model-obstruction.md)
withdraws the group strengthening and leaves realization invariance open.

The new replay pins the new proof records, candidate, independent oracle,
fixtures, tests, replay program, and inherited graph primitives by SHA-256.
The original graph receipt retains its scope and bytes. Regenerate only
after investigating an intentional change:

```sh
python conformance/replay_regular_modular_bicycle.py --write
```

All enumeration is exhaustive within its stated finite scope. TU
certification checks all square minors; potential enumeration costs n^r;
cycle enumeration costs n^(e-r). These are small-fixture algorithms with
no silent truncation. The integral proof supplies theorem authority;
Python and both oracles remain non-authoritative candidate/evidence code.

Four [independent acceptance-review tests](test_regular_modular_bicycle_audit.py)
take the combined suite to 41. They cover 48 signed column changes combined
with a row change that loses TU (288 coordinate/modulus cases), the
noncyclic K3,3 quotient at large composite moduli, 51 additional proper
tower pairs and 105 strict chains, and literal scalar-two edge membership
through modulus 128. The non-TU coordinate cases use literal enumeration
and Cramer equations while the TU candidate correctly rejects their
matrices. Both original source-pinned receipts retain their bytes and
scope; the added tests are tracked separately in the reviewed Git tree.
See the [acceptance audit](../docs/audits/regular-modular-bicycle-independent-2026-10-09.md).
