# Bridge Conjectures for the Finite-Regime Mandelbrot Program

This note records the highest-priority conjectures that connect the finite-regime certificate calculus to existing work in complex dynamics, computable analysis, interval certification, rational-ray combinatorics, and arithmetic dynamics.

The guiding rule is: do not conjecture what is already a theorem. Existing theorems enter as named theorem tags. The project conjectures finite reformulations, certificate completeness, and stabilization principles.

## C1. Finite Fiber Stabilization

For every symbolic ray-address nest, let

```text
beta_0 >= beta_1 >= beta_2 >= ...
```

be the certified dyadic-box nest produced by rational-ray separation data. The central conjecture is:

```text
all certified nests stabilize to singleton incidence vertices
<=> all Mandelbrot fibers are trivial
<=> MLC.
```

In the finite regime, the endpoint of stabilization is not an analytic singleton. It is a finite incidence object: a `PointVertex` whose carrier records the root handle, ray-address set, and dyadic-box nest data.

## C2. Rational-Ray Certificate Completeness

Every rational parameter-ray landing theorem instance for a Misiurewicz or parabolic parameter can be compiled into the finite grammar:

```text
RootHandle + RayAddressSet + DyadicBox + Comb + TheoremTag
```

The finite core checks algebraic and symbolic hypotheses. The theorem tag discharges analytic landing.

## C3. Squarefree Localization + Pointwise Exclusion

Let

```text
R_{ell,k}(C) = Q_{ell+k}(C) - Q_ell(C)
P_{ell,k}(C) = sqfree(R_{ell,k}(C))
```

For every exact Misiurewicz root handle and every finite horizon `H >= ell+k`, there exists a dyadic box `beta` such that:

```text
K_P(beta) subset interior(beta)
```

and for every forbidden collision pair `(i,j)`:

```text
0 notin Q_j(beta) - Q_i(beta).
```

No lower-collision gcd stripping is allowed. Exact type is a property of the isolated root handle inside the box, not a globally removable polynomial factor.

## C4. Same-Box Joint Witness

Localization and exact-type exclusion must be checked on the same dyadic box.

```text
same beta witnesses Krawczyk localization and all forbidden exclusions.
```

This is the main machine-checkable soundness boundary.

## C5. Finite Hyperbolic Interior Certificates

Every dyadic box compactly contained in a hyperbolic component should admit a finite attracting-cycle certificate, phrased only in polynomial equations and rational inequalities.

## C6. Conditional Computable Rendering Equivalence

A three-valued renderer with certificate-carrying labels

```text
IN / OUT / UNKNOWN
```

is complete precisely to the degree that exterior escape certificates, hyperbolic interior certificates, and fiber-stabilization certificates cover the requested resolution.

## C7. Symbolic Ray-Address Finitization

All rational-ray combinatorics needed for Misiurewicz and parabolic certificates should be expressible with:

- finite words;
- rational addresses in `Q/Z`;
- address doubling;
- kneading data;
- orbit portraits;
- finite cyclic-order and unlinking checks.

No measured-angle geometry is part of the core.

## C8. Rank-2 Coordinate Substrate Equivalence

Every certificate step using ordinary complex arithmetic has a finite translation into rank-2 coordinate records with multiplication

```text
(x,y) star (u,v) = (xu-yv, xv+yu)
```

plus quadrance, determinant/spread, symbolic ray addresses, and finite incidence objects.

## C9. Finite Incidence Point Formalization

A point is not an analytic singleton in the core. It is a finite incidence vertex:

```text
PointVertex({RootHandle, RayAddressSet, DyadicBox})
```

or, in the user's shorter phrase:

```text
point := vertex of vertices.
```

## C10. Finite-Field Shadow

Finite affine-field dynamics of `z -> z^2 + c` does not reproduce classical
analytic escape: every affine orbit eventually cycles and none lands on the
infinity divisor. The projective morphism does retain exact algebraic infinity
data, including total ramification and divisor pullback multiplicity; over
valued function or global fields, pole-order growth gives a further algebraic
escape invariant. These constructions may provide arithmetic shadows of the
critical-orbit polynomials and Misiurewicz/parabolic loci, but no transfer to
the classical parameter plane is claimed. See `docs/projective-multiset.md`.

This is lower priority and must not be confused with the main dyadic/rational certificate calculus.
