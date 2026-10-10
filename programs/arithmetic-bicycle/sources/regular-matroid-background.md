# Fixed-TU Jacobians and the arithmetic boundary

These primary sources were checked on 2026-10-09. They provide definitions
and background; the arbitrary-modulus proof is written independently in
[the repository proof record](../proof/regular-modular-bicycle.md).
This contribution does not claim the fixed-TU theorem is new literature.

## Total unimodularity

Michel X. Goemans, *Linear Programming and Polyhedral Combinatorics*,
MIT 18.453 notes, April 5, 2017,
[Section 3.5, Definition 3.12](https://math.mit.edu/~goemans/18453S17/polyhedral.pdf).

The definition requires every square minor to be zero or a unit.
A full-row-rank TU matrix therefore has a unit maximal minor. The local
proof constructs an integral right inverse directly from that minor.

## Regular-matroid Jacobian

Spencer Backman, Matthew Baker, and Chi Ho Yuen,
*Geometric Bijections for Regular Matroids, Zonotopes, and Ehrhart Theory*,
[arXiv:1701.01051](https://arxiv.org/abs/1701.01051),
[PDF, Section 2.1](https://arxiv.org/pdf/1701.01051).

Proposition 2.1.2 identifies the edge-lattice Jacobian quotient with
$\operatorname{coker}(AA^\top)$ through $[\gamma]\mapsto[A\gamma]$.
This supplies context for calling the Gram cokernel a regular-matroid
group. The local modular proof establishes its explicit torsion maps and
modulus compatibility without importing representation uniqueness.

The October 9 acceptance review also located Lemma 2.1.1 in Section 2.1:
it states that full-row-rank TU representations of a regular matroid are
related by an integral unimodular row change, column permutation, and
column sign changes. Phase 3 must still audit the labeling and hypotheses
and provide a repository proof record applying the coordinate maps to
the whole modular tower. This source identification does not promote
representation independence in the fixed-TU contribution.

## Torsion-free and surjective arithmetic matroids

Roberto Pagaria and Giovanni Paolini,
*Representations of torsion-free arithmetic matroids*,
[arXiv:1908.04137](https://arxiv.org/abs/1908.04137),
[PDF, Section 2](https://arxiv.org/pdf/1908.04137).

Section 2 distinguishes torsion-free, $m(\varnothing)=1$, from surjective,
$m(E)=1$. It describes a torsion-free representation as integer vectors in
an ambient lattice and defines equivalence in Definition 2.5.
Those definitions permit $A=[2]$ in $\mathbb Z$: it is torsion-free but
not surjective. The [local counterexample](../proof/arithmetic-torsion-model-obstruction.md)
then gives an elementary obstruction to an unconditional torsion-group
model. It does not compare two realizations with matching arithmetic data.

## Independent exact Smith factors

The determinantal-divisor oracle reuses the all-minor characterization
already sourced in [the graph background record](graph-critical-group-background.md).
It does not use the theorem map to determine expected torsion or classes.
