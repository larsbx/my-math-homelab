# T2 Prior-Art Boundary — SL2 Trace Coordinates

## Conclusion

For 2-dimensional determinant-one representations, finite polynomial closure of trace data under free-group automorphisms is established prior art. It must not be presented as a new theorem target.

The relevant classical-to-modern line is:

- Fricke / Klein / Vogt: trace coordinates for pairs of SL2 matrices;
- Horowitz: characters of free groups in SL2 and polynomial trace expressions;
- Goldman: trace-coordinate formulations of character varieties and mapping-class actions;
- Brown: polynomial automorphism action on Horowitz trace coordinates;
- modern finite-field Markoff-surface work: polynomial Out(F2) dynamics over finite fields.

## Core identity

For A,B in SL2 over a suitable commutative coefficient setting,
[
operatorname{tr}(AB)+operatorname{tr}(AB^{-1})
=
operatorname{tr}(A)operatorname{tr}(B).
]

This identity is the basic reduction mechanism behind Fricke-type trace algebras.

For a free group (F_n), classical trace-coordinate results show that traces of arbitrary words are polynomially controlled by finitely many basic traces. In rank two, the standard coordinates are
[
x=operatorname{tr}(A),qquad
y=operatorname{tr}(B),qquad
z=operatorname{tr}(AB).
]

The outer automorphism group acts polynomially on these coordinates.

## Implication for T2

The following route is closed as a novelty claim:

> "Prove that a finite trace-coordinate state exists for SL2 and that braid/free-group automorphisms act polynomially on it."

That is classical.

The viable questions are narrower:

1. **Finite-field arithmetic refinement.**
   Use trace-coordinate dynamics over finite fields to prove a new counting/orbit theorem tied specifically to the product-one/Hurwitz families in this repository.

2. **Orthogonal groups where traces do not generate the full character algebra.**
   Sikora's work shows that for even special orthogonal groups, ordinary and even generalized traces may fail to generate the character variety. That makes "minimal Hurwitz-closed observable state" genuinely nontrivial.

3. **Torus-normalizer images.**
   Analyze the smallest enlargement of a rank-one torus that retains nonabelian braid information.

4. **Trace-Gram vs full character coordinates.**
   Determine exactly which information the pairwise matrix
   [
   K_{ij}=chi(g_i g_j^{-1})
   ]
   loses relative to a standard trace-coordinate presentation.

## Relevant references

- Robert D. Horowitz, "Characters of free groups represented in the two-dimensional special linear group", Communications on Pure and Applied Mathematics 25 (1972), 635–649. DOI: 10.1002/cpa.3160250602.
- William M. Goldman, "Trace coordinates on Fricke spaces of some simple hyperbolic surfaces", 2009.
- Richard J. Brown, "Automorphisms of the Fricke characters of free groups", 2010.
- Sean Lawton and Adam Sikora, "Varieties of Characters", Algebras and Representation Theory 20 (2017), 1133–1141.
- Adam S. Sikora, "SO(2n,C)-character varieties are not varieties of characters", Journal of Algebra 478 (2017), 195–214.
- Matthew de Courcy-Ireland and Michael Magee, "Kesten–McKay law for the Markoff surface mod p", Annales Henri Lebesgue 4 (2021), 227–250.

## Revised priority

Do not spend the next theorem cycle rediscovering Fricke/Horowitz closure.

Prefer one of:

- finite-field Hurwitz orbit statistics in a trace-coordinate model;
- non-trace-generated orthogonal character varieties;
- torus-normalizer braid retention;
- exact comparison between trace-Gram and full character-coordinate states.
