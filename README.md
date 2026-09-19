# Closure Fibers of Multiplication Research

A literature-first research program on algebraic closure constraints expressed as identity fibers of multiplication maps.

## Scope

The repository studies connections among:

- Hurwitz spaces and Nielsen product-one tuples;
- multiplicative Deligne–Simpson problems and character varieties;
- group-valued moment maps and reduction at the identity;
- rank-one orthogonal groups, split tori, and norm-one tori of quadratic étale algebras;
- finite-field arithmetic of split and nonsplit rank-one groups;
- Gram, inverse-Gram, and adjugate constructions in quadratic geometry;
- representation-theoretic maps from finite monodromy data to algebraic-group closure data.

## Non-negotiable mathematical boundary

This project does **not** claim that "closure as the fiber m^{-1}(1)" is new. That mechanism is established in Hurwitz/Nielsen theory, character varieties, multiplicative Deligne–Simpson theory, and quasi-Hamiltonian geometry.

Novelty must come from new theorems about bridges between those settings.

The project also avoids analytic primitives as foundational objects: no trigonometric functions, no unit-circle semantics, and no use of complex numbers as primitive geometry. Quadratic étale algebras, rank-two matrix models, norm maps, Gram data, and finite/projective constructions are first class.

## Current priority

1. Define a functorial map from Nielsen data through orthogonal representations into rank-one torus closure data without collapsing all braid information.
2. Define and test trace-Gram invariants of Nielsen tuples.
3. Prove finite-field comparison results that distinguish split (q-1) from nonsplit (q+1) rank-one targets.
4. Treat unipotent behavior only through an explicit degeneration/group-scheme construction.

## Repository map

- `RESEARCH_CHARTER.md` — scope, invariants, and claim policy.
- `research/2026-09-19-deep-literature-review.md` — archived literature synthesis.
- `research/SOURCES.md` — primary-source ledger.
- `claims/CLAIM_LEDGER.md` — established / standard / open / prohibited claims.
- `theorems/THEOREM_ROADMAP.md` — theorem targets.
- `docs/TERMINOLOGY.md` — field-standard vocabulary.
- `notes/PAPER_OUTLINE.md` — current paper architecture.
- `src/` and `experiments/` — Mojo-first exact computation scaffold.
