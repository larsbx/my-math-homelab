# C4 degree-2 mid-area factorization identity

**Status:** exact combinatorial identity proved and executable. It is a necessary condition for a prescribed ordered child substitution to be the actual balanced-pair factorization. It does **not** prove C4, C1, G1, or PSC.

## 1. Why another degree-2 invariant is needed

For a balanced state `T=(u,v)`, the signed defect

`K2(T)=N2(u)-N2(v)`

forgets the common/average ordering information of the two side words. This is exactly why the signed intertwiner

`Q2 S=(Lambda^2 M)Q2`

sees orientation signs but not the order of child occurrences.

The synthetic G/F obstruction shows that incidence, signed `K2`, endpoint quotients, and actual balanced state columns can all be correct while the proposed child word is still not the actual zero-return factorization.

The first missing information already appears at absolute degree two.

## 2. Word area

For a three-letter word `w`, define

`area(w)=(N12-N21, N13-N31, N23-N32)`.

This is the antisymmetric part of the absolute degree-2 scattered-subword data, identified with `Lambda^2 Z^3`.

If `p(w)` is the Parikh vector and `M=M_sigma`, define the `3x3` internal-area matrix `C_sigma` by

`C_sigma[:,a]=area(sigma(a))`.

Then

> **Substitution area identity**
>
> `area(sigma(w))=(Lambda^2 M) area(w)+C_sigma p(w)`.

### Proof

A degree-2 occurrence in `sigma(w)` is either:

1. internal to the image of one source letter, contributing `C_sigma p(w)`; or
2. split between two distinct source positions, contributing the wedge of the two image Parikh columns.

The second contribution is precisely the exterior-square action on `area(w)`. QED.

## 3. Balanced-state mid-area

For a balanced state `T=(u,v)`, define

`H(T)=area(u)+area(v)`.

The difference is already known:

`area(u)-area(v)=2 K2(T)`.

Thus `K2` and `H` are respectively the difference and sum of the two side-area vectors.

## 4. Concatenation and ordered child cross terms

For words `x_1,...,x_m`,

`area(x_1...x_m)=sum_r area(x_r)+sum_{r<s} p(x_r) wedge p(x_s)`.

Now suppose the raw inflated parent factors in order into balanced raw children whose normalized states are

`R_1,...,R_m`.

A child may occur in either orientation. Swapping it exchanges its top and bottom side words, but leaves both

`H(R_r)`

and

`p(R_r)`

unchanged.

Adding the top and bottom concatenation formulas therefore gives

`H_actual = sum_r H(R_r)+2 sum_{r<s} p(R_r) wedge p(R_s)`.

The second term depends on the **ordered** child word.

## 5. Exact mid-area factorization identity

Applying the substitution area identity to the two parent sides gives

`H(sigma(T))=(Lambda^2 M)H(T)+2 C_sigma p(T)`.

Equating this with the ordered child concatenation yields:

> **Mid-Area Factorization Identity**
>
> `
> (Lambda^2 M)H(T)+2 C_sigma p(T)
>   = sum_r H(R_r)+2 sum_{r<s} p(R_r) wedge p(R_s).
> `

This is an integer identity for every actual zero-return factorization.

Crucially, orientation signs disappear while **child order remains**. The identity therefore sits strictly between:

- the signed `K2` intertwiner, which forgets child order; and
- complete word equality, which remembers every letter.

## 6. Matrix form for a proposed finite derived substitution

Let `C={T_1,...,T_m}` be candidate states and let `tau(T_j)` be a proposed ordered word of child-state labels. Put the mid-area columns into a `3xm` matrix `H`.

The unordered child-sum term is `H N`, but the ordered cross term is extra data. Define `Omega_tau` columnwise by

`Omega_tau[:,j]=sum_{r<s} p(R_r) wedge p(R_s)`

for the ordered child word `tau(T_j)`.

Then the complete system is

> `
> (Lambda^2 M)H + 2 C_sigma P = H N + 2 Omega_tau.
> `

This is the first proved factorization constraint in the program that depends on the ordering of children rather than only their incidence counts.

## 7. Strong synthetic G/F calibration

The synthetic artifact in `synthetic_degree2.py` passes:

- actual PIP incidence;
- rank-three Parikh and `K2` intertwiners;
- nonnegative positive/negative orientation counts;
- actual irreducible balanced state realization;
- actual nonsynchronizing endpoint types G/F;
- endpoint quotient phase compatibility.

For its proposed child words, the mid-area residuals are exactly

```text
T0: ( 0,  0, -4)
T1: ( 0, -4, -4)
T2: (-4, -8,-12)
```

so the proposed derived substitution is rejected already at absolute degree two.

For the **actual** zero-return children of the same states under the same substitution, every residual is exactly zero.

This is the desired calibration: the new identity rejects the golden negative case specifically at the factorization layer.

## 8. What remains

The mid-area identity is necessary but not yet known sufficient to rule out strict degree-2 SCCs. The next questions are:

1. combine it with the rank-three `P,Q` intertwiners for `|C|=3` and determine whether the affine system has any realizable solutions at all;
2. classify the finite possible `Omega_tau` values compatible with the 1/3/9 endpoint-signature dynamics;
3. use unique decodability/recognizability only after the degree-2 ordered-child system has been exhausted.

The exact three-state corpus census already shows that parity, traces, and endpoint types admit 546 candidate substitutions but actual BPA factorization realizes no recurrent size-3 SCC. The mid-area identity is a concrete algebraic candidate for explaining part of that gap.

## 9. Executable scope

`reference/psc_research/factorization_degree2.py` implements:

- word area and exterior products;
- the affine substitution-area identity;
- state mid-area and its relation to `K2`;
- ordered child cross-area;
- single-parent and whole-system mid-area residuals;
- verification that actual BPA factorizations have zero residual.

`tests/test_factorization_degree2.py` checks the theorem and the strong synthetic negative calibration exactly.
