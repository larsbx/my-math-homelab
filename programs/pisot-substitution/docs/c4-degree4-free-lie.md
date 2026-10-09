# C4-D degree-4 first-defect reduction

**Status:** exact characteristic decomposition and PIP spectral comparison proved for degree four. This does **not** prove C4, C1, G1, or PSC.

This note continues the lowest-nonzero-defect program after the signed degree-2 and degree-3 intertwiners.

If a hypothetical strict closed nonproductive SCC has

`K_1=K_2=K_3=0`

on every state and some nonzero degree-4 defect, the general lowest-degree lemma gives

`Q_4 S = (M_sigma^{tensor 4}) Q_4`,

with the image lying in the degree-4 shuffle-primitive/free-Lie sector. The purpose of this note is to classify that sector for a three-letter alphabet and compare all of its rational spectral factors with the orientation bound

`rho(S) <= beta`.

## 1. Degree-4 free-Lie character

For a rank-three vector space `V`, the degree-4 free-Lie functor has Witt character

`ch Lie_4(V) = (p_1^4-p_2^2)/4`.

Its Schur decomposition is

`Lie_4(V) ~= S_(3,1)(V) direct-sum S_(2,1,1)(V)`.

The repository verifies this identity directly at character level in `psc_research.lie4`:

- `s_(3,1)=h_3 h_1-h_4` by Jacobi--Trudi;
- `S_(2,1,1)(V) ~= det(V) tensor V` for `dim V=3`;
- the two characters sum exactly to the degree-4 Witt character.

Dimensions are

`dim S_(3,1)=15`,

`dim S_(2,1,1)=3`,

so

`dim Lie_4(Q^3)=18`,

agreeing with Witt's formula `(3^4-3^2)/4=18`.

Standard reference: Reutenauer, *Free Lie Algebras*, Chapter 8; the degree-4 Schur expansion is also reproduced by the symmetric-function computation encoded in this repository.

## 2. Weight families

Let the three roots of the irreducible PIP cubic be

`beta, alpha, gamma`,

ordered by

`beta>1`, `1>|alpha|>=|gamma|>0`.

Write

`d=det M = beta alpha gamma`,

so `d` is a nonzero integer and `|d|>=1`.

The character computation has only three exponent-orbit shapes.

### Family A: permutations of `(3,1,0)`

There are six weights

`lambda_i^3 lambda_j`, `i != j`.

They occur once in `S_(3,1)`.

### Family B: permutations of `(2,2,0)`

There are three weights

`lambda_i^2 lambda_j^2 = (d/lambda_k)^2`.

They occur once in `S_(3,1)`.

### Family C: permutations of `(2,1,1)`

There are three weights

`lambda_i^2 lambda_j lambda_k = d lambda_i`.

They occur with multiplicity two in `S_(3,1)` and once more in
`S_(2,1,1) ~= det tensor V`, hence with total multiplicity three in `Lie_4(V)`.

The executable orbit catalogue is in `psc_research.lie4.orbit_families`.

## 3. Family A is always strictly above beta

Even the smaller Perron-containing weight has modulus

`beta^3 |gamma|`.

From

`|d|=beta |alpha gamma| >= 1`

we obtain

`beta |gamma| >= 1/|alpha| > 1`.

Therefore

`beta^2 |gamma| > beta > 1`,

and hence

`beta^3 |gamma| > beta`.

So **every Galois orbit arising from family A has spectral radius strictly greater than `beta`**.

This remains true in the cyclic `A_3` Galois case where the six weights split into two rational cubic factors: one contains `beta^3 alpha`, the other `beta^3 gamma`, and both exceed `beta` in modulus.

## 4. Family B is at least beta

The largest family-B modulus is

`beta^2 |alpha|^2`.

Since `|alpha|>=|gamma|`,

`beta |alpha|^2 >= beta |alpha gamma| = |d| >= 1`.

Thus

`beta^2 |alpha|^2 >= beta`.

Equality occurs exactly when both inequalities are equalities:

1. `|d|=1`, and
2. `|alpha|=|gamma|`.

For an irreducible cubic with three distinct real roots, `|alpha|=|gamma|` would force `alpha=-gamma`; then the trace would equal `beta`, making the Perron root rational, impossible. Therefore equality is possible only in the one-real/two-complex-conjugate case.

Hence family B has:

- spectral radius `> beta` unless `|det M|=1` and the stable roots form a complex-conjugate pair;
- spectral radius exactly `beta` in that unimodular complex-pair case.

## 5. Family C is det times the standard representation

Every family-C eigenvalue is `d lambda_i`, so its spectral radius is

`|d| beta >= beta`.

Equality occurs exactly when

`|d|=1`.

Because this factor occurs three times in the full degree-4 free-Lie module, the entire possible low-growth family-C sector has dimension nine, but it is built from three copies of the same irreducible cubic representation `det tensor V`.

## 6. Degree-4 low-growth classification

Combining the three families gives:

### Theorem — degree-4 PIP spectral floor

Every nonzero rational invariant factor of `Lie_4(Q^3)` under a PIP incidence matrix has spectral radius at least `beta`.

Moreover:

- family A is always strictly greater than `beta`;
- family B can equal `beta` only when `|det M|=1` and the stable roots are a complex-conjugate pair;
- family C can equal `beta` only when `|det M|=1`.

Therefore if `|det M|>1`, **every nonzero rational degree-4 factor has spectral radius strictly greater than `beta`**.

## 7. Consequence for a first degree-4 SCC defect

Let `C` be a hypothetical strict closed nonproductive PIP SCC whose first nonzero scattered-subword defect degree is four. Then

`Q_4 S = Phi_4 Q_4`

on the degree-4 free-Lie sector, while the orientation comparison gives

`rho(S)<=beta`.

The image of `Q_4` is a nonzero rational `Phi_4`-invariant quotient of `S`.

Hence:

### Corollary A — non-unimodular elimination

If `|det M|>1`, no first degree-4 counterexample can exist.

Every possible nonzero degree-4 rational factor has spectral radius `>beta`, contradicting `rho(S)<=beta`.

### Corollary B — strict odd contraction eliminates degree four universally

If

`rho(S)<beta`,

no first degree-4 counterexample can exist even in the unimodular case, because every degree-4 factor has spectral radius `>=beta`.

Thus a surviving degree-4 counterexample must satisfy **both**:

1. `|det M|=1`, and
2. orientation is Perron-extremal: `rho(S)=beta`.

For primitive `N_C`, the orientation-spectral trichotomy then leaves only gauge or anti-gauge. Anti-gauge becomes gauge-trivial after squaring.

### Corollary C — surviving rational sectors

In the unimodular extremal case:

- the three copies of `det tensor V` (family C) are possible `rho=beta` sectors;
- additionally, in the complex-stable-root case, the family-B cubic is another possible `rho=beta` sector;
- family A is never available.

This is a finite list of rational representation types.

## 8. Minimal three-state normal form through degree four

The Parikh-intertwiner theorem gives `|C|>=3`. Suppose the minimum is attained: `|C|=3`. Then `P_C` is invertible and

`N_C = P_C^{-1} M P_C`,

so `N_C` is primitive and has the same irreducible cubic characteristic polynomial as `M`.

The earlier defect reductions then sharpen as follows.

### Degree two

If `Q_2 != 0`, irreducibility of `Lambda^2 M` forces `rank Q_2=3`; hence

`S = Q_2^{-1} (Lambda^2 M) Q_2`

and

`rho(S)<beta`.

Thus a three-state first-degree-two obstruction is necessarily in the strict odd-contraction case.

### Degree three

If `K_2=0`, the signed degree-3 theorem forces

`im Q_3 subset W_det`,

and `Phi_3` acts on `W_det` by the rational scalar `d=det M`.

If orientation were Perron-extremal, primitivity of `N_C` would make

`S` diagonally similar to `+N_C` or `-N_C`.

But `+N_C` and `-N_C` both have irreducible cubic characteristic polynomial and therefore no rational eigenvalue. The relation

`Q_3 S = d Q_3`

would make every nonzero row of `Q_3` a rational left eigenvector of `S` with rational eigenvalue `d`, impossible. Hence `Q_3` must vanish in the extremal phase-coherent cases.

Therefore a genuine three-state first-degree-three obstruction also forces

`rho(S)<beta`.

### Degree four

A degree-four obstruction cannot have `rho(S)<beta` by Corollary B. Hence a three-state degree-four obstruction must be Perron-extremal and unimodular.

Write the orientation phase as `zeta=+1` in the gauge case and `zeta=-1` in the anti-gauge case. Then

`S` is similar to `zeta M`.

A nonzero degree-4 image is three-dimensional because `S` itself has an irreducible cubic characteristic polynomial. Family A is unavailable by spectral radius. Family B, when it has radius `beta`, has root-modulus multiset

`{beta, beta, beta^{-2}}`

in the unimodular complex-pair case, while `zeta M` has modulus multiset

`{beta, beta^{-1/2}, beta^{-1/2}}`.

Since `beta>1`, these cannot be similar. Thus the only possible three-state image is family C, whose operator is `d M`.

Similarity of `zeta M` and `d M` forces equality of determinants. Since `d,zeta in {+1,-1}`,

`det(zeta M)=zeta d`,

while

`det(d M)=d^4=1`.

Therefore

`zeta=d`.

So the only minimal three-state degree-4 survivor has the exact phase match:

- `det M=+1` with trivial gauge, or
- `det M=-1` with anti-gauge.

After squaring the substitution/derived substitution, both reduce to the orientation-trivial, determinant-`+1` case.

### Three-state summary

For a hypothetical three-state strict PIP counterexample:

- first defect degree 2 => strict odd contraction;
- first defect degree 3 => strict odd contraction;
- first defect degree 4 => only the unimodular phase-matched family-C case survives;
- if `|det M|>1`, a three-state counterexample must have first defect degree at least 5.

This is a structural theorem, not corpus evidence.

## 9. Why this matters for the remaining proof

The previous frontier was simply “first defect degree `>=4`.” Degree four is now reduced to a narrow arithmetic/monodromy corner:

- non-unimodular PIP: degree four eliminated;
- any strict orientation contraction: degree four eliminated;
- only unimodular phase-coherent orientation survives;
- its possible defect image lies in explicitly identified cubic factors;
- at minimal SCC size, only the phase-matched family-C cubic survives.

The next two tasks are therefore:

1. test the exact 4554-substitution PIP corpus for the size of this unimodular survivor regime, separated into real-root and complex-pair cubics;
2. attack the unimodular gauge/anti-gauge word-realization case, where the defect module has the same Perron modulus as the base but lives in one of the explicit family-B/C cubic representations.

## 10. Guardrails

This note does not assume unimodularity globally. It proves that unimodularity is **forced only for a hypothetical first-degree-four obstruction**.

It also does not claim that every degree-4 free-Lie weight orbit is a single irreducible rational factor in every Galois branch. The spectral conclusions use Galois-stable orbit factors: in the `S_3` branch family A is degree six, while in the `A_3` branch it splits into two cubics. The modulus inequalities above apply to every such rational subfactor.

Higher first-defect degrees remain open.
