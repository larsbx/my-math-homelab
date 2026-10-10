# C4 degree-2 integral lattice lifting certificate

**Status:** exact finite arithmetic refinement of the three-state mean-area lift. It is a necessary realizability test, not a proof of C4, C1, G1, or PSC.

## 1. From rational lifting to integral lifting

The mean-area equation for an ordered three-state candidate is

`L(J)=b`,

where

`L(X)=(Lambda^2 M)X-XN`

is an integral `9x9` Sylvester operator and

`b=Omega_tau-C_sigma P`

is integral. Under the irreducible three-state hypotheses, `L` is nonsingular over `Q`, so there is a unique rational solution.

The actual requirement is stronger:

> `b` must lie in the integral lattice `L(Z^9)`.

This depends on the concrete integral representative `N`, not merely on its rational characteristic polynomial.

## 2. Exact Cramer certificate

For any nonsingular integer matrix `L`, Cramer's rule gives

`x_i=det(L_i(b))/det(L)`,

where `L_i(b)` is obtained from `L` by replacing column `i` by `b`.

Therefore

> `Lx=b` has `x in Z^n` iff `det(L)` divides every `det(L_i(b))`.

For the three-state problem this gives nine exact divisibility conditions. It is a complete membership test for this single right-hand side.

Computationally, this is an alternative to constructing a full Smith or Hermite normal form. SNF would describe the entire cokernel `Z^9/L(Z^9)`; the Cramer certificate answers exactly the membership question needed for one ordered child system with no additional dependency.

## 3. Golden G/F obstruction

For the synthetic G/F ordered child system already used to calibrate the factorization layer,

`det(L)=-16`,

while the nine Cramer numerators are

```text
-8, 8, -24, -24, -8, -24, -8, -8, 40.
```

Every reduced coordinate denominator is `2`. Hence none of the nine coordinates is integral and the ordered factorization fails the lattice-lift test immediately.

This restates the half-integral forced mean-area solution as a pure integer divisibility certificate.

## 4. Why this is stronger than the resultant

The closed resultant formula controls `|det(L)|` when `N` is rationally similar to `M`, so it identifies primes that may appear in the finite cokernel. It does not determine whether a particular `b` lies in the image lattice.

The Cramer numerators depend on the actual integral operator and on the ordered child term `Omega_tau`. Thus the test retains both:

- the integral `Z[t]`-lattice represented by `N`;
- the child ordering represented by `tau`.

This is the first exact congruence-level obstruction in the degree-2 program that sees both pieces simultaneously.

## 5. Relation to Smith normal form

For a nonsingular `L`, SNF would produce invariant factors

`d_1 | ... | d_9`

and identify the cokernel as `direct_sum Z/d_i Z`. That is useful if many right-hand sides are to be tested against one operator.

For the present one-template-at-a-time elimination, the Cramer certificate is already necessary and sufficient. A later enumerator may add SNF/HNF for efficiency, but no proof step depends on doing so.

Crucially, neither the resultant nor the Smith invariants are determined by rational similarity alone at the integral-lattice level. The concrete `N` must remain part of the candidate data.

## 6. Next proof use

For a proposed three-state strict SCC template:

1. verify `P N=M P` and rank `P=3`;
2. verify signed `K2` compatibility and endpoint quotient constraints;
3. enumerate admissible ordered child words `tau`;
4. form `L` and `b`;
5. reject the candidate whenever one Cramer divisibility condition fails;
6. if the lift is integral, apply side-area parity/magnitude conditions and then the remaining word-realizability constraints.

The golden G/F template is rejected at step 5. The next computational target is to measure how much of the hypothetical three-state template space survives this integral lifting layer.

## 7. Executable scope

`reference/psc_research/lattice_lift.py` provides:

- exact column replacement;
- fraction-free determinants;
- Cramer numerators and reduced denominators;
- a complete integral-image decision for nonsingular integer operators;
- a three-state mean-area candidate wrapper enforcing the Parikh intertwiner hypotheses.

`tests/test_lattice_lift.py` pins the exact G/F certificate and cross-checks it against the Fraction-based rational solver.
