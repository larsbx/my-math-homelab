# Unframed finite configuration replacement

**Status:** experimental result; classical algebraic construction, no novelty promotion.

The earlier claim that each Apollonian generator acts on unlabeled
configurations requires correction. The generator family descends as a
replacement multigraph; individual labeled generators need not descend.

## Labeled configuration model

Let k be a finite field of odd characteristic, n at least 2, and assume
n and n-1 are nonzero in k. Put m=n+2 and Q=I-J/n. Its determinant is
-2/n, so Q is nondegenerate. Specify a symmetric nondegenerate matrix R
and consider invertible W satisfying W^T Q W=R. The fiber can be empty:
nondegeneracy alone does not guarantee an isometry between Q and R.

The replacement S_i changes only row i, with coefficients -1 at i and
2/(n-1) elsewhere. Direct matrix algebra gives S_i^2=I and S_i^T Q S_i=Q.
Thus W maps to S_i W inside the same configuration fiber. Inverting the
Gram identity gives W R^-1 W^T=Q^-1=I-J/2, certifying every pairwise row
Gram entry, rather than only a curvature column.

These equations are algebraic configuration constraints. They do not
establish a Euclidean packing, non-overlap, or a geometric realization.

## Correct unframed object

The permutation group Sigma_m acts by row permutation. For its matrices P,
P^T Q P=Q and P S_i P^-1=S_(P(i)). It follows that the multiset
of neighboring unlabeled configurations [S_i W], over all i, depends only
on [W]. This defines a canonical replacement multigraph on Sigma_m-orbits.
Preserve repeated edges and loops; do not replace the multiset by a set.

There is generally no induced action of a fixed S_i on this quotient:
relabeling the input also relabels which row is replaced. The committed
negative regression exhibits equal unlabeled inputs with different
unlabeled outputs under S_0. The invariant object is the graph relation,
not a claimed action of each labeled generator.

## Octonionic boundary

The graph uses no octonion bridge. It is canonical relative to the declared
configuration data and replacement relations. It supplies no canonical
choice of an octonion multiplication tensor or defect embedding. Normal
closure of all bridge placements remains a separate, potentially collapsing
construction. The n=6, F7 bridge counterexample therefore stays in force.

## Executable scope and Lean obligations

The oracle covers only n=6 over F7. Tests check full Gram preservation,
replacement involutions, dual row Gram identities, normalization by adjacent
transpositions, quotient-neighbor multiplicities, and refusal of malformed
configurations. Adjacent transpositions generate the permutation group;
the general quotient argument above is a proof outline, not a Lean proof.

Pending Lean work: certify S_i^T Q S_i=Q under the exact characteristic
hypotheses; certify permutation equivariance; construct the quotient edge
multiset; prove representative independence. No new Lean certification is
claimed by this experiment.

Run `python -m experiments.soddy.n6_f7_configurations` and
`python -m unittest tests/test_n6_f7_configurations.py -v`.
