# C4 degree-2 three-state mean-area lifting obstruction

**Status:** exact algebraic consequence of the order-sensitive degree-2 factorization identity. It gives a finite necessary realizability test for an ordered three-state candidate. It does **not** prove C4, C1, G1, or PSC.

## 1. Genealogy and terminology

The degree-2 data used here is standard in adjacent literatures, even though its application to the balanced-pair SCC problem is new in this project.

For a word `w`, let

`p(w)=Parikh(w)`

and

`a(w)=(N12-N21,N13-N31,N23-N32)`.

Then concatenation satisfies

`(p,a)(q,b)=(p+q, a+b+p wedge q)`.

This is the antisymmetric degree-2 truncation of the scattered-subword/Magnus signature of a word. It is also the central-coordinate law of a class-2 nilpotent extension of the abelian Parikh lattice. Parikh-matrix and subword-history work studies closely related finite truncations of scattered-subword data; the Magnus morphism is a standard device for packaging all scattered-subword counts.

**Normalization leak.** With the integral `area` convention above, the commutator of two letter generators has central coordinate `2 e_i wedge e_j`. Thus this integral lattice is not literally the most common Mal'cev-coordinate lattice of the free class-2 nilpotent group; over `Q` the structures agree after rescaling the center. We use the central-extension/Magnus genealogy only to identify the algebraic structure, not to import an unjustified integral isomorphism.

The term **mean-area** below is project-local shorthand for the integral lift `J=(a(u)+a(v))/2`; it is not asserted to be standard terminology in combinatorics on words.

Related standard sources include Mateescu--Salomaa--Yu, *Subword histories and Parikh matrices* (JCSS 68, 2004), and Salomaa, *Connections between subwords and certain matrix mappings* (TCS 340, 2005). Generalized Parikh mappings are also commonly formulated through the Magnus morphism.

## 2. From mid-area to an integral lift

For a balanced state `T=(u,v)`, define

`H(T)=a(u)+a(v)`.

Because

`a(u)-a(v)=2 K2(T)`,

we have

`H(T)=2(a(v)+K2(T))`.

Hence

> `J(T)=H(T)/2`

is an integer vector for every actual balanced state.

For a candidate ordered child substitution `tau`, the mid-area factorization identity becomes

> `(Lambda^2 M) J - J N = Omega_tau - C_sigma P`.

Here:

- `N` is the unsigned child-incidence matrix;
- `P` contains the common Parikh columns;
- `C_sigma[:,a]=area(sigma(a))`;
- `Omega_tau[:,T]=sum_{r<s} p(R_r) wedge p(R_s)` for the **ordered** child word of `T`.

All terms on the right are integer data. Thus the problem is an integral lifting problem through a central extension: the abelian/Parikh factorization has to admit compatible degree-2 central coordinates.

## 3. Why the three-state lift is unique over Q

For `|C|=3`, the proved Parikh rank theorem gives

`P N=M P`

with `det(P)!=0`, so

`N=P^{-1} M P`.

Therefore `N` and `M` have the same irreducible cubic spectrum.

Let the eigenvalues of `M` be `lambda_1,lambda_2,lambda_3` and `d=det M`. If an eigenvalue of `M` were also an eigenvalue of `Lambda^2 M`, then for some indices

`lambda_i=lambda_j lambda_k=d/lambda_i`,

so

`lambda_i^2=d in Q`.

That would give `lambda_i` algebraic degree at most two, contradicting irreducibility of the cubic.

Hence

`spec(N) cap spec(Lambda^2 M)=empty`.

The Sylvester map

`L_N : X -> (Lambda^2 M)X-XN`

is therefore invertible over `Q`. Every prescribed ordered child word `tau` forces one and only one rational matrix

`J=L_N^{-1}(Omega_tau-C_sigma P)`.

Actual balanced-word realization requires at minimum:

1. `J` is integral;
2. the two side-area columns `J+Q` and `J-Q` obey the elementary Parikh parity and magnitude bounds.

These checks occur before any attempt to solve complete word equations.

## 4. Resultant versus Sylvester-operator determinant

Write

`chi_M(x)=x^3-Tx^2+Ux-d`

and

`chi_Lambda2(x)=x^3-Ux^2+dT x-d^2`.

With the standard polynomial-resultant convention,

`Res(chi_M,chi_Lambda2)` equals

```text
-d^2 (T-U+d-1)^2
  (-T^2 d - 2 T d + U^2 + 2 U d + d^2 - d).
```

Our `9x9` linear operator is ordered as

`X -> (Lambda^2 M)X-XM`.

Its determinant is the product of the reversed pairwise eigenvalue differences. Since `3*3=9` is odd,

> `det(L_M) = -Res(chi_M,chi_Lambda2)`.

Therefore the operator determinant is

```text
+d^2 (T-U+d-1)^2
  (-T^2 d - 2 T d + U^2 + 2 U d + d^2 - d).
```

This sign distinction is regression-tested explicitly. For the G/F calibration below,

`Res=+16`

while

`det(L_M)=-16`.

The nonvanishing follows from the disjoint-spectrum argument, not from inspection of the factorization.

## 5. Strong G/F calibration

Use the actual PIP substitution

```text
1 -> 2
2 -> 3
3 -> 132
```

and the three balanced-state Parikh/K2 columns in `synthetic_degree2.py`. The proposed ordered unsigned child words are

```text
T0 -> T1
T1 -> T2
T2 -> T0 T1 T2.
```

They pass the incidence, Parikh, signed `K2`, and endpoint-quotient constraints, but they are not the true zero-return factorization.

The unique rational mean-area matrix forced by the lifting equation is

```text
J = [ 1/2 -1/2  3/2]
    [ 3/2  1/2  3/2]
    [ 1/2  1/2 -5/2].
```

It is not integral. Therefore **no replacement of the three side-word pairs with the same Parikh and K2 columns can realize this ordered child system**.

This is stronger than comparing the particular synthetic words directly: the obstruction belongs to the ordered factorization data itself.

## 6. Side-area feasibility after integrality

If `J` is integral, then

`a(u_j)=J_j+Q_j`,

`a(v_j)=J_j-Q_j`.

For Parikh vector `p=(n1,n2,n3)`, any word area `a=(a12,a13,a23)` satisfies

`|a_ij| <= n_i n_j`

and

`a_ij == n_i n_j (mod 2)`,

because

`N_ij+N_ji=n_i n_j`

and

`a_ij=N_ij-N_ji`.

These are necessary, not sufficient, conditions for a word with that Parikh vector and area to exist.

## 7. Integral-lattice caveat

The rational Sylvester determinant depends only on the common cubic spectrum. The **integral** cokernel does not depend only on the characteristic polynomial: rationally similar integer matrices `N` can define different `Z[t]`-lattices.

Accordingly:

- the resultant identifies possible denominator primes;
- it does **not** by itself give the full congruence obstruction for every integral representative `N`;
- Smith-normal-form conditions must be computed for the actual integral Sylvester operator.

This is the point where integral conjugacy / `Z[t]`-module structure enters. Any later use of Latimer--MacDuffee-type ideal-class language must state that additional genealogy explicitly rather than treating rational similarity as integral conjugacy.

## 8. Research consequence

For a three-state strict degree-2 candidate, child order is no longer a decorative refinement of `N`. Once `sigma`, the Parikh lattice `P`, the integral representative `N`, and the ordered child words `tau` are fixed, the central-extension lift is forced.

This gives a finite elimination program for each concrete candidate:

1. enumerate child orders compatible with `N` and the endpoint first/last selectors;
2. compute `Omega_tau`;
3. solve the exact Sylvester equation;
4. reject nonintegral `J`;
5. reject impossible side-area parity/bounds;
6. only then attempt full balanced-word realization.

The exact 4,554-PIP census already shows that parity, endpoint types, and power traces admit 546 three-state arithmetic candidates while actual BPA factorization realizes no recurrent size-three SCC. The mean-area lift is a concrete finite mechanism that can explain part of that gap without comparing whole words.

## 9. Executable scope

`reference/psc_research/meanarea_integrality.py` provides:

- exact child-incidence, Parikh, `K2`, and ordered cross-area matrices;
- the `9x9` Sylvester operator;
- Fraction-exact forced mean-area solution;
- enforcement of the three-state `PN=MP` hypothesis;
- integrality and side-area feasibility checks;
- separate resultant and operator-determinant formulas;
- fraction-free determinant verification.

`tests/test_meanarea_integrality.py` pins the half-integral G/F obstruction, the `Res=+16` / `det=-16` convention, and several independent companion-matrix determinant checks.
