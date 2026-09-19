# Theorem Roadmap

## T0 — Typing and normalization library

Establish the base-field and representation conventions used by every later theorem.

Deliverables:
- quadratic étale algebra representation (E=F[t]/(t^2-d));
- rank-two multiplication matrices;
- norm-one subgroup equations;
- exact split/nonsplit finite-field cardinality lemmas;
- no square-root or transcendental notation in theorem statements.

## T1 — Orthogonal image of Nielsen data

Given a finite group (G), a Nielsen tuple ((g_1,ldots,g_r)), and an orthogonal representation
[
ho:G	o O(V,B),
]
prove that
[
(ho(g_1),ldots,ho(g_r))
]
defines a finite-image point of the corresponding product-one representation variety.

Then characterize when the image lies in, or canonically projects to, a rank-one special orthogonal subgroup.

**Novelty threshold:** the first sentence is elementary and not publishable by itself. The characterization/projection must contain actual new structure.

## T2 — Hurwitz transformation law for trace-Gram matrices

Define
[
K_{ij}=operatorname{Tr}(ho(g_i)ho(g_j)^{-1}).
]

Tasks:
1. prove symmetry for self-dual/orthogonal (ho);
2. derive the exact update to (K) under each Hurwitz generator;
3. identify polynomial functions of (K) invariant under:
   - simultaneous conjugation,
   - pure braid action,
   - full braid action when classes are unlabeled;
4. classify failure modes by counterexample.

Candidate invariants:
- rank;
- determinant;
- principal-minor multiset;
- characteristic polynomial;
- orbit-average characteristic polynomial.

## T3 — Split versus nonsplit finite-field comparison

For (F=mathbb F_q), construct nontrivial Hurwitz families carrying 2-dimensional quadratic representations with split or nonsplit connected rank-one image.

Prove a comparison theorem for one of:
- fiber cardinalities;
- distribution of torus-valued closure invariants;
- component counts;
- Frobenius traces after a controlled enrichment.

The theorem must use more than the elementary (qpm1) count.

## T4 — Toric-to-unipotent degeneration

Construct an explicit group scheme
[
mathcal G	o S
]
with:
- generic fiber toric;
- special fiber with prescribed unipotent behavior;
- a multiplication map (mathcal G^r	omathcal G);
- a theorem describing specialization of the identity fiber.

No informal "parabolic limit" language is allowed without this construction.

## T5 — Projective compatibility theorem

Fix a projective absolute quadric and a rank-one quadratic torus. Construct an explicit comparison between:
- a Cayley–Klein cross-ratio coordinate;
- a character of the torus after passage to a splitting algebra.

A shared (mathbb G_m)-valued codomain is insufficient; the theorem must identify the maps.
