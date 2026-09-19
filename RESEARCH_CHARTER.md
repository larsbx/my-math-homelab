# Research Charter

## Research question

What genuinely new structure appears when finite-group product-one data from Hurwitz/Nielsen theory is transported, via representations, into rank-one algebraic groups attached to quadratic spaces?

## Accepted foundations

The project may freely use established machinery from:

- algebraic groups and group schemes;
- quadratic forms and orthogonal groups;
- Weil restriction and norm-one tori;
- Hurwitz spaces and Nielsen classes;
- braid actions and mapping-class actions;
- character varieties;
- the multiplicative Deligne–Simpson problem;
- quasi-Hamiltonian / group-valued moment-map reduction;
- étale cohomology and Frobenius point counts;
- projective geometry with a specified absolute quadric.

## Foundational exclusions

The following are not admissible as primitives in the core theory:

- real-number topology;
- analytic angle functions;
- sine/cosine parametrizations;
- a unit circle as foundational geometry;
- transcendental logarithmic distance formulas;
- unnamed "complex rotation" arguments.

When a quadratic extension is needed, use a quadratic étale algebra
[
E=F[t]/(t^2-d)
]
or its rank-two matrix model.

## Rank-one group policy

For a nondegenerate binary quadratic space, the connected special orthogonal group is a one-dimensional torus.

- split case: isomorphic over F to (mathbb G_m);
- nonsplit case: a norm-one torus (R^1_{E/F}mathbb G_m).

Unipotent (mathbb G_a)-behavior is **not** a third form of the same torus. It may appear only through an explicit degeneration, contraction, special fiber, or separately specified stabilizer construction.

## Novelty policy

A statement belongs in the main theorem track only if it goes beyond the following known observations:

- product-one loci are fibers of multiplication maps;
- Nielsen tuples are product-one tuples plus generation and quotient conditions;
- character varieties are products of conjugacy classes with product one modulo conjugation;
- group-valued moment maps reduce at the identity;
- norm-one tori model rank-one nonsplit orthogonal groups;
- split and nonsplit finite-field tori have q-1 and q+1 rational points respectively.

## Evidence classes

Every mathematical claim in prose should be classified as one of:

- **Theorem (external):** established in cited literature.
- **Lemma (internal):** proved in this repository.
- **Computation:** established by exact finite computation with replayable artifact.
- **Conjecture:** precise and falsifiable.
- **Heuristic:** explicitly non-theorem.
