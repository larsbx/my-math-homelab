# Graph critical groups and exact Smith factors

This source record supplies background for the graph theorem. It does not
promote the regular-matroid or arithmetic-matroid claims, and does not assert
that the repository-local graph proof is a new theorem.

## Exact Smith-normal-form reference

Richard P. Stanley, *Smith Normal Form in Combinatorics*,
[arXiv:1602.00166](https://arxiv.org/abs/1602.00166).

Theorem 2.4 gives the determinantal-divisor characterization: the product
of the first k Smith factors is the gcd of the k by k minors. This is the
formula implemented by the independent oracle. Unimodular row and column
operations preserve these gcds; on a divisibility-ordered diagonal matrix
the gcd is the product of the first k entries. Section 3, especially
Theorem 3.1, records the reduced-Laplacian cokernel description of the
critical group. Those sections were checked on 2026-10-08.

## Broader critical-group background

David G. Wagner, *The critical group of a directed graph*,
[arXiv:math/0010241](https://arxiv.org/abs/math/0010241), 2000.

The abstract places the Laplacian cokernel definition in the standard
critical-group literature. Its convention includes a free part; this
repository uses the finite degree-zero quotient for connected undirected
graphs. The graph proof states that distinction explicitly. The abstract
and bibliographic metadata were checked on 2026-10-08.

David Jekel, Avi Levy, Will Dana, Austin Stromme, and Collin Litterell,
*Algebraic Properties of Generalized Graph Laplacians: Resistor Networks,
Critical Groups, and Homological Algebra*, SIAM Journal on Discrete
Mathematics 32(2), 2018, 1040-1110,
[arXiv:1604.07075](https://arxiv.org/abs/1604.07075),
[DOI:10.1137/16M1072607](https://doi.org/10.1137/16M1072607).

The abstract describes connections between critical groups and harmonic
functions via homological algebra. This is background context only; the
repository proof does not depend on an imported result from this paper.
The abstract and bibliographic metadata were checked on 2026-10-08.
