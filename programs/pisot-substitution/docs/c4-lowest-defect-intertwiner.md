# C4-C signed scattered-subword defect intertwiners

**Status:** the degree-2 and degree-3 signed intertwining identities are proved combinatorially and implemented exactly. The general lowest-degree mechanism is stated with its combinatorial proof. This does **not** prove C4, C1, G1, or PSC.

This note connects the closed-SCC/orientation program to the repository's existing `K_1,K_2,K_3,W_3` spectral module.

## 1. Word defects and orientation

For a word `w` and an ordered word `a_1...a_r` of letters, let

`N_{a_1...a_r}(w)`

be the number of scattered occurrences at strictly increasing positions. For a balanced pair state

`T=(u_T,v_T)`, define its degree-`r` defect

`K_r(T)=N_r(u_T)-N_r(v_T)`.

Swapping the two sides negates every defect:

`K_r(v,u)=-K_r(u,v)`.

For a normalized child occurrence `T -> U` with orientation sign `eps=+/-1`, the raw child's defect is therefore

`eps K_r(U)`.

Let `S=A-B` be the signed child-incidence matrix from the orientation-spectral reduction.

## 2. Lowest nonzero degree

All states of a balanced-pair component satisfy `K_1=0`.

For distinct finite equal-length words, some scattered-subword degree distinguishes them: at degree equal to the word length, the full word itself occurs once in one word and not in the other. Hence every noncoincident state has a finite first nonzero defect degree.

For a finite strict component `C`, define

`r(C)=min { r>=1 : K_r(T) != 0 for some T in C }`.

Then for **every** state `T in C`,

`K_s(T)=0` for all `s<r(C)`.

This common vanishing is what removes all correction terms below the first defect degree.

## 3. Concatenation lemma

Suppose a raw inflated parent factors into balanced raw children

`R_1 ... R_m`.

Scattered-subword counts of degree `r` in a concatenation are sums over ways of distributing the `r` selected positions among the blocks. The term placing all `r` positions in one block contributes `K_r(R_i)`. Every genuinely cross-block term uses a degree strictly smaller than `r` inside each participating block.

Therefore, if every child has vanishing defects below degree `r`, all cross-block top-minus-bottom terms cancel and

`K_r(R_1...R_m)=sum_i K_r(R_i)`.

For normalized children this becomes

`K_r(sigma(T)) = sum_i eps_i K_r(U_i)`.

In matrix form, if `Q_r` has the `K_r(T)` as columns,

`Q_r S = [columns K_r(sigma(T))]`.

## 4. Substitution lemma

Expand a degree-`r` scattered occurrence in `sigma(w)` according to how many output letters are selected from each source-letter position of `w`.

- Terms selecting output letters from exactly `r` distinct source positions contribute the pure tensor action `M_sigma^{tensor r} N_r(w)`.
- Every term using fewer than `r` source positions is a fixed linear combination of scattered-subword counts of degrees `<r` in `w`, with coefficients determined by the finite images `sigma(a)`.

Taking the difference of the two sides of a balanced pair whose lower defects all vanish therefore kills every correction term. Hence at the first nonzero degree

`K_r(sigma(T)) = M_sigma^{tensor r} K_r(T)`.

Combining with the concatenation lemma gives the general signed intertwiner

> `Q_r S = (M_sigma^{tensor r}) Q_r`

at the component's lowest nonzero defect degree.

The code in this PR implements and independently word-checks the cases `r=2` and `r=3`, which are the degrees already supported by the repository's exact spectral machinery.

The standard shuffle product identities also imply that a lowest-degree defect annihilates all nontrivial shuffle products of lower degrees; equivalently it lies in the corresponding shuffle-primitive/free-Lie sector. This general statement is not yet formalized in Lean here. The degree-3 instance needed below **is** already formalized as `BalancedPair.K₃_shuffle_zero` when `K_2=0`.

## 5. Degree two: exterior-square quotient

For a balanced pair on three letters, `K_2` is automatically skew-symmetric:

- diagonal entries vanish;
- `K_{ji}=-K_{ij}`.

Thus `K_2` is represented in the basis

`e_1 wedge e_2, e_1 wedge e_3, e_2 wedge e_3`

as a vector in `Lambda^2 Q^3`.

The pure tensor action restricted to this skew sector is `Lambda^2 M`. Therefore

> **Degree-2 signed intertwiner**
>
> `Q_2 S = (Lambda^2 M) Q_2`.

### PIP spectral consequence

Let the eigenvalues of the PIP incidence matrix be `beta, alpha_2, alpha_3`, with

`beta>1`, `|alpha_2|<1`, `|alpha_3|<1`.

The exterior-square eigenvalues are

`beta alpha_2`, `beta alpha_3`, `alpha_2 alpha_3`.

Hence

`rho(Lambda^2 M) < beta`.

Because `det M != 0`,

`Lambda^2 M` is rationally equivalent to `det(M) M^{-T}`.

If `chi_M` is irreducible cubic over `Q`, so is `chi_{Lambda^2 M}`: if `alpha` has degree three, then `det(M)/alpha` generates the same cubic field.

Now suppose `Q_2 != 0` for a hypothetical PIP counterexample SCC. Its image is a nonzero rational `Lambda^2 M`-invariant subspace, since

`(Lambda^2 M) im(Q_2) = Q_2 S(Q^C) subset im(Q_2)`.

Irreducibility of the cubic therefore forces

`rank_Q Q_2 = 3`.

Consequently `Lambda^2 M` is a rational quotient of `S` and its characteristic cubic divides the characteristic polynomial of `S`.

### Minimal three-state corollary

If `|C|=3` and `Q_2 != 0`, then `Q_2` is invertible and

`S = Q_2^{-1} (Lambda^2 M) Q_2`.

Thus

`rho(S)=rho(Lambda^2 M)<beta`.

So a three-state counterexample whose first nonzero defect is degree two is automatically in the **strict odd-contraction** case of the orientation-spectral trichotomy. Gauge and anti-gauge extremality are impossible there.

The repository's primitive non-Pisot negative control calibrates this identity exactly: its first defect degree is two and `tests/test_defect_intertwiner.py` verifies the signed exterior-square intertwiner.

## 6. Degree three: direct bridge to `W_3`

Assume now that every state in `C` has `K_2=0`. Then the degree-3 correction terms vanish and

> **Degree-3 signed intertwiner**
>
> `Q_3 S = (M^{tensor 3}) Q_3`.

The already-formalized shuffle theorem gives

`K_3(T) in W_3`

for every state, where the repository has proved/computed

`dim W_3=8`

and exact invariance under `M^{tensor 3}`.

Therefore `im(Q_3)` is a rational invariant subspace of the existing `W_3` spectral module, and the action on that image is a quotient of `S`. Since the orientation-spectral reduction gives `rho(S)<=beta`, any such image arising from a counterexample must be a **low-growth** rational invariant sector of `W_3`.

This is the missing SCC-level connection to the older Spectral Black Box.

### What the existing certificate already excludes

For the six certified length-7 `K_2=0` seed pairs, the exact Mojo certificate checks

`(Phi_3-det M)^2 K_3(s_k) != 0`

on the PIP matrix corpus, and the Lean/finite-algebra development proves the seed-specific centralizer and dominant-cubic obstructions used by that certificate.

Those checks show that the six named seed defects are not trapped entirely in the low determinant sector.

### What it does **not** yet exclude

A hypothetical SCC state is not known to have one of the six seed `K_3` vectors. An arbitrary rational invariant subspace generated by SCC `K_3` columns could, in principle, lie in a low-growth sector not hit by those named seeds.

Therefore the existing Target 1 calculation must **not** be promoted to a universal SCC theorem yet.

The new task is to classify the low-growth rational invariant sectors of `W_3` and prove that no irreducible balanced-pair SCC defect image can remain wholly inside them—or reduce every realizable image to a finite family already covered by a certificate.

## 7. The genuine remaining boundary: first defect can exceed degree three

Nothing presently proves that `r(C)<=3`. Distinct words can have identical scattered-subword counts through several degrees. The general lowest-defect intertwiner exists at whatever finite degree first separates the words, but the current verified spectral representation theory is detailed only for degrees two and three.

This gives a precise new proof boundary:

1. `r=2`: reduced to the exterior-square quotient, with spectral radius `<beta`.
2. `r=3`: reduced to a low-growth invariant-subspace problem inside the existing eight-dimensional `W_3` module.
3. `r>=4`: requires either a combinatorial reduction back to lower degree or a classification of low-growth rational sectors in the higher shuffle-primitive/free-Lie representations.

This is narrower than the original SCC Producer conjecture: the automaton, orientation, Parikh, and first-defect dynamics have all been converted into exact finite representation-theoretic constraints.

## 8. Executable scope

`reference/psc_research/defect_intertwiner.py` provides:

- exact `K_2` and `K_3` scattered-subword defects;
- the three-dimensional exterior-square matrix;
- the 27-dimensional tensor-cube matrix;
- exact construction and verification of the degree-2 signed intertwiner;
- exact construction and verification of the degree-3 signed intertwiner when all component `K_2` vanish;
- a generic sparse search for the lowest nonzero scattered-subword defect degree.

`tests/test_defect_intertwiner.py` calibrates degree two on the known strict non-Pisot component and degree three on one of the already-certified `K_2=0` seed pairs.
