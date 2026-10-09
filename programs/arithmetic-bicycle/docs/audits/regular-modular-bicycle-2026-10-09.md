# Fixed-TU proof audit — 2026-10-09

Scope: ABC-REGULAR-MODULAR-BICYCLE and the separate retraction of
ABC-UNIVERSAL-TORSION-MODEL. The graph proof and its October 9 independent
audit are preserved. This record is the contribution author's proof audit;
it does not assert review by a second person or a formal proof assistant.
The computational oracle is algorithmically independent of the candidate
implementation and imports no kernel code.

## Integral obligations

| Obligation | Audited argument |
| --- | --- |
| Full row rank and TU | A nonzero maximal minor is a unit; its inverse embeds into an integral right inverse R. |
| All moduli, including composites | R transpose is a left inverse of A transpose over every Z/n; no division by a nonunit or field-rank argument is used. |
| Nonsingular Gram matrix | The sum of integer squares in the Gram quadratic form vanishes only for zero; clearing denominators proves rational nonsingularity. |
| Forward map domain | The cycle condition makes Qy/n integral and its class n-torsion. |
| Integral lift independence | Replacing y by y+nz changes Qy/n by Qz. |
| Potential independence | Equal gradients imply equal potentials modulo n by the integral left inverse. |
| Injectivity | Qy/n=Qz implies y=nz by rational nonsingularity. |
| Surjectivity | An n-torsion divisor has nd=Qy for an integral y; its gradient is a bicycle. |
| Inverse independence | Replacing d by d+Qz changes the unique solution y to y+nz. |
| Both inverse identities | Substituting Qy=nd recovers the input bicycle and the input quotient class. |
| Module structure | Addition and integer scaling of potentials induce Z/n-linearity. |
| Modulus compatibility | For m=kn, reduction corresponds to multiplication by k and inflation by k to subgroup inclusion. Both composites multiply by k, and dividing-modulus chains compose. |
| Coordinate equivariance | For A'=UAS, b'=S transpose b and d'=Ud give the commuting formula. The right inverse survives even if the row change loses TU. |
| Degenerate dimensions | Rank zero has only the zero cut and trivial Gram cokernel, even with loop columns. |

The proof's sufficient hypothesis is an integral right inverse. TU is the
verified executable contract. Coordinate equivariance for specified
transformations does not establish that every pair of regular-matroid TU
realizations is related by those transformations. That is the next gate.

## Independent exact evidence

| Candidate route | Independent route |
| --- | --- |
| Rational-elimination TU determinants | Bareiss determinants for every square minor |
| First unit column basis and Gauss–Jordan inverse | Last unit column basis and integral Cramer inverse |
| Enumeration of rank-many potentials | Enumeration of nonbasis edge coordinates, cycle completion, and a cut check |
| Rational Gram inverse for classes | Cramer coordinates and quotient enumeration from standard generators |
| Bicycle counts and element orders | All-minor Smith factors and finite-group torsion profiles |

The inherited Bareiss and determinantal-divisor primitives already have
permutation-expansion, planted-unimodular, and singular-matrix regressions.
Small fixtures additionally compare the new cycle oracle with literal
edge and potential enumeration. Expected quotient classes are constructed
without using either direction of the proposed theorem map.

The new 16 tests pass. Seven TU fixtures exercise 36 modulus cases,
including prime, prime-power, and mixed composite moduli. The cographic
K3,3 fixture has Gram Smith factors (1,3,3,9); modulus 9 distinguishes its
exponent from the dimension visible at modulus 3. Rank zero, loops,
coloops, parallel elements, and graphic examples are included.

The source-pinned TU receipt checks complete bicycle sets, independent
torsion classes, both inverse directions, order profiles, and 44 proper
tower pairs. Tests also check all dividing-modulus chains, huge integral
representative changes, linearity on every fixture pair, signed column
permutations, and a nonorthogonal unimodular row change.

The bounded ternary census checks all 729 integer 2-by-3 matrices with
entries in {-1,0,1}. Independent recognition finds 456 full-row-rank TU
matrices; their 1,824 cases at moduli 2,3,4,6 agree with the oracle and
Smith counts. The remaining matrices are rejected by the TU interface.
This census is a regression, not an arithmetic realization search.

Graph specialization is checked at every root of every original graph
fixture at moduli 2,3,4,6. The matrix formula equals the graph formula with
the omitted divisor coordinate removed. The graph source-pinned receipt
retains its original scope and bytes.

## Negative controls and formulation correction

Two labeled non-TU matrices supply 12 receipt cases:

- A=[2] has no integral right inverse. At modulus 2, two potentials for
  the zero bicycle give distinct proposed classes in coker([4]). Its
  bicycle modules at moduli 2 and 4 contradict every universal group
  torsion model. It is torsion-free as an arithmetic matroid because
  m(empty)=1; this does not mean surjective.
- A=[1,2] is non-TU but has an integral right inverse. Its literal bicycle
  sets match the Gram-group model. Non-TU by itself is not an obstruction.

Other controls reject incorrect cuts, cycles, potentials, divisors,
domains, and nondividing modulus maps. A four-cycle control demonstrates
why multiplying a raw modular edge representative by A and dividing by n
does not give the forward divisor.

The elementary group argument is audited independently of enumeration:
H[2]=0 forces H[4]=0. Thus the bootstrap's unconditional finite-group
strengthening is false. The one-realization example does not decide
realization invariance. The withdrawn strengthening receives its own
`retracted` record; ABC-MAIN remains `open` with its principal
realization-invariance statement.

## Validation and authority

On Python 3.12.14, the registry gate passes for seven claims, all 37
conformance tests pass, and both source-pinned receipts replay with exact
agreement. The patch whitespace check passes. The commands are listed in
[conformance/README.md](../../conformance/README.md). The new proof and
independent evidence satisfy the fixed-TU promotion gate. Python remains
candidate machinery with acceptance authority false. Arithmetic
realization invariance and regular-matroid representation independence
are not promoted.
