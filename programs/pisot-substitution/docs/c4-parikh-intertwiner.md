# C4-C Parikh intertwiner for a hypothetical nonproductive sink SCC

**Status:** proved algebraic reduction, conditional only on the existence of the
finite closed SCC under discussion. It does **not** prove G1, C1, C4, or PSC.

This note adds an algebraic constraint to the endpoint-signature reductions.
The key point is that a closed nonproductive balanced-pair SCC carries its own
finite substitution, and the original incidence matrix is a rational quotient
of that derived substitution.

## 1. Derived substitution on a closed SCC

Let `sigma` be a substitution on a three-letter alphabet with incidence matrix
`M`. Let `C={T_1,...,T_r}` be a **closed nonproductive recurrent noncoincident
SCC** of the balanced-pair automaton.

For each state `T_j=(u_j,v_j)`, inflate and factor into irreducible balanced
pairs:

`red(sigma(T_j)) = T_{i_1} T_{i_2} ... T_{i_m}`.

Closure says every noncoincident child stays in `C`; nonproductivity says no
coincidence child occurs. Hence every child belongs to `C`, so this defines a
finite substitution `tau_C` on the alphabet `C`.

Let `N_C` be its incidence matrix, with column convention

`(N_C)_{i,j} = number of occurrences of T_i in tau_C(T_j)`.

Because `C` is strongly connected, `N_C` is an irreducible nonnegative integer
matrix.

## 2. Parikh matrix

For a balanced pair `T_j=(u_j,v_j)`, write

`p_j = Parikh(u_j) = Parikh(v_j) in Z_{>=0}^3`.

Let

`P_C = [ p_1  p_2 ... p_r ]`,

so `P_C` is a `3 x r` nonnegative integer matrix.

### Proposition 1 — exact intertwining identity

`P_C N_C = M P_C`.

### Proof

Fix a column `j`. The `j`-th column of `P_C N_C` is the sum of the Parikh
vectors of all irreducible child blocks in the reduction of `sigma(T_j)`, with
multiplicity. Concatenating those child blocks reconstructs `sigma(u_j)` on the
first side, so the sum is

`Parikh(sigma(u_j)) = M Parikh(u_j) = M p_j`.

This is exactly the `j`-th column of `M P_C`. QED.

This identity uses only additivity of Parikh vectors and exact balanced-pair
factorization; it contains no spectral approximation.

## 3. Irreducibility forces rank three

Assume now that the characteristic polynomial `chi_M` is irreducible over
`Q`, as in the standing PIP regime.

### Proposition 2 — full Parikh rank

`rank_Q(P_C)=3`.

### Proof

The image `W = im_Q(P_C)` is nonzero because every state contains a nonempty
word and hence has a nonzero Parikh vector. Proposition 1 gives

`M W = M im(P_C) = im(M P_C) = im(P_C N_C) subseteq W`.

Thus `W` is a nonzero rational `M`-invariant subspace of `Q^3`.

Since `chi_M` is irreducible of degree three, the minimal polynomial of `M` is
also `chi_M`. If `W` were a proper nonzero invariant subspace, the minimal
polynomial of the restriction `M|_W` would divide `chi_M`; irreducibility would
force it to equal `chi_M`. But a linear operator on a proper subspace of
`Q^3` has dimension at most two, so its minimal polynomial has degree at most
two, a contradiction.

Therefore `W=Q^3` and `rank(P_C)=3`. QED.

### Corollary 2.1 — no one- or two-state counterexample SCC

Every closed nonproductive recurrent noncoincident SCC in the standing
irreducible three-letter regime has

`|C| = r >= 3`.

This is a general theorem, not a corpus observation.

## 4. The original incidence action is a quotient of the SCC action

Because `P_C:Q^r -> Q^3` is surjective and satisfies

`P_C N_C = M P_C`,

its kernel is `N_C`-invariant. The induced action of `N_C` on
`Q^r / ker(P_C)` is conjugate to `M`.

### Proposition 3 — characteristic divisibility

`chi_M(x)` divides `chi_{N_C}(x)` over `Q` (and hence over `Z`, since both are
monic integer polynomials).

### Proof

Choose a rational basis of `Q^r` adapted to the invariant subspace
`ker(P_C)`. In that basis `N_C` is block upper triangular, and the quotient
block is similar to `M`. The characteristic polynomial therefore factors as

`chi_{N_C}(x) = chi_{N_C|ker(P_C)}(x) * chi_M(x)`.

QED.

### Corollary 3.1 — the three-state case is rigid

If `|C|=3`, then `P_C` is a square rationally invertible matrix and

`N_C = P_C^{-1} M P_C`.

Thus `N_C` and `M` have the same characteristic polynomial, trace,
determinant, and rational canonical form. Any three-state counterexample must
be a nonnegative-integer realization rationally conjugate to the original
incidence matrix through a nonnegative integer Parikh matrix.

## 5. Perron eigenvalue of the SCC substitution

Let `ell^T M = beta ell^T` be the positive left Perron eigenvector of `M`.
Define the positive row vector of geometric block lengths

`lambda^T = ell^T P_C`.

Every column of `P_C` is nonzero and nonnegative, so every entry of `lambda` is
strictly positive. Proposition 1 gives

`lambda^T N_C = ell^T P_C N_C = ell^T M P_C = beta lambda^T`.

Since `N_C` is irreducible and has a strictly positive left eigenvector,
Perron--Frobenius gives:

### Proposition 4 — mass balance at a closed nonproductive SCC

`PF(N_C)=beta`.

Thus a hypothetical closed nonproductive SCC is exactly a **no-leakage** block
substitution at the Perron rate. This recovers the spectral mass-balance normal
form from an explicit combinatorial derived substitution.

## 6. Interaction with the endpoint-signature reduction

`docs/c4-signature-reduction.md` shows that the same hypothetical SCC projects
to at most 1, 3, or 9 endpoint quotient signatures, depending on the two
endpoint quotient sizes. Proposition 2 here says the actual SCC alphabet must
nevertheless contain at least three states whose Parikh columns span `Q^3`.

So the remaining C4-C obstruction simultaneously has:

1. an irreducible nonnegative integer substitution `N_C` with `PF(N_C)=beta`;
2. a surjective nonnegative integer intertwiner `P_C` satisfying
   `P_C N_C=M P_C`;
3. `chi_M | chi_{N_C}`;
4. at least three actual balanced-pair states;
5. only 1, 3, or 9 possible projected endpoint signatures;
6. no coincidence child and no noncoincident escape;
7. every newborn and inherited boundary trapped between distinct
   synchronization quotient classes.

This is substantially smaller than the original unrestricted SCC Producer
problem.

## 7. Next eliminators

The next useful split is by `r=|C|`.

- `r=3`: exploit the rational conjugacy `N_C=P_C^{-1}MP_C` together with
  nonnegative-integral `N_C`, nonnegative-integral `P_C`, irreducible balanced
  pair realizability, and the endpoint signature constraints.
- `r>3`: work on the invariant kernel of `P_C`; its characteristic factor is
  the extra factor of `chi_{N_C}` beyond the irreducible Pisot cubic. Seek
  constraints from nonnegativity, SCC recurrence, and boundary signatures
  before invoking stronger Pisot contraction or mass-leakage arguments.

Any surviving algebraic template must still be checked for **realizability by
balanced words**; the previously identified synthetic matrix solutions show
that matrix algebra alone is not sufficient.
