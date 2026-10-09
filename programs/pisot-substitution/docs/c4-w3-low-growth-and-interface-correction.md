# C4-C universal low-growth classification in `W_3`

**Status:** rational spectral reduction proved from the existing certified factorization of `Phi_3`. Also records a necessary orientation-sign correction to the archived SCC quotient-transfer interface. This does **not** prove C4, C1, G1, or PSC.

## 1. Why this note is needed

The signed degree-3 defect intertwiner proved in the current C4 program is

`Q_3 S = Phi_3 Q_3`,

where

- `Phi_3=M_sigma^{tensor 3}|_{W_3}`;
- `S=A-B` is the **signed** orientation incidence of a normalized strict SCC.

The orientation-spectral reduction gives

`rho(S)<=beta`.

Hence `im(Q_3)` is a rational `Phi_3`-invariant subspace whose spectral radius is at most `beta`.

The archived Spectral Certificate already gives the full rational factorization of `Phi_3`; using it here classifies such low-growth images universally, without assuming that an SCC state is one of the six length-7 seeds.

## 2. Certified rational factorization of `Phi_3`

The existing certificate identifies

`W_3 ~= S_(2,1) V ~= sl_3(Q) tensor det(V)`

and, over the splitting field of the irreducible cubic `chi_M`, gives

`Spec(Phi_3)={beta_i^2 beta_j : i!=j} union {det M,det M}`.

Because `chi_M` is irreducible in characteristic zero, `Phi_3` is semisimple.

Write the roots as

`beta_1=beta`, with `|beta_2|>=|beta_3|` and `|beta_2|,|beta_3|<1`.

The determinant is a nonzero integer:

`|det M|=beta |beta_2 beta_3| >= 1`.

Also

`|det M|<beta`

because `|beta_2 beta_3|<1`.

The non-determinant rational part has two possible Galois forms.

### `S_3` branch

The degree-6 polynomial

`P_6(t)=prod_{i!=j}(t-beta_i^2 beta_j)`

is irreducible over `Q`. Thus its six-dimensional primary subspace `W_6` is a single irreducible rational `Q[Phi_3]`-module.

Its spectral radius is

`beta^2 |beta_2|`.

This is strictly greater than `beta`. Indeed

`1 <= |det M| <= beta |beta_2|^2`,

so `|beta_2|>=beta^{-1/2}` and therefore

`beta |beta_2| >= sqrt(beta)>1`.

Hence

`beta^2 |beta_2|>beta`.

### `A_3` branch

The degree-6 part factors into two irreducible cubic factors `P_+ P_-`. Their corresponding rational subspaces are the two three-dimensional Galois orbits of off-diagonal matrix units under the `sl_3 tensor det` model.

One cubic contains a weight of modulus

`beta^2 |beta_2|>beta`.

The other contains a weight of modulus

`beta^2 |beta_3|`.

This is also strictly greater than `beta`, because

`beta |beta_3| = |det M|/|beta_2| > 1`

using `|det M|>=1` and `|beta_2|<1`.

Thus **both** irreducible cubic factors have spectral radius greater than `beta`.

## 3. Universal low-growth theorem

### Theorem

Let `Y` be a rational `Phi_3`-invariant subspace of `W_3`. If

`rho(Phi_3|Y)<=beta`,

then

`Y subset W_det`,

where

`W_det=ker(Phi_3-det(M) I)`

is the two-dimensional determinant eigenspace.

### Proof

By semisimplicity and the rational primary decomposition, `Y` is the direct sum of its intersections with the rational irreducible factors of `Phi_3`.

- In the `S_3` branch, any nonzero intersection with `W_6` equals all of the irreducible six-dimensional factor and therefore has spectral radius `beta^2|beta_2|>beta`.
- In the `A_3` branch, any nonzero intersection with either irreducible cubic factor equals that full factor; each cubic has spectral radius greater than `beta` by the estimates above.

Therefore a subspace of spectral radius at most `beta` has zero projection to every non-determinant factor and lies entirely in `W_det`. QED.

## 4. Counterexample consequence for degree three

For a hypothetical strict PIP counterexample SCC with `K_2=0`, the signed intertwiner gives

`Q_3 S=Phi_3 Q_3`.

Therefore `im(Q_3)` is rational and `Phi_3`-invariant. The induced action on this image is a quotient of `S`, so

`rho(Phi_3|im Q_3)<=rho(S)<=beta`.

By the theorem,

> `im(Q_3) subset W_det`.

Under the existing `Theta` identification

`W_3 ~= sl_3(Q) tensor det`,

the determinant eigenspace corresponds exactly to the traceless centralizer of `M`:

`Theta(W_det)={A in sl_3(Q): AM=MA}`.

Thus every degree-3 defect matrix arising in such a counterexample must commute with `M`.

Since an irreducible cubic matrix has a three-dimensional rational centralizer `Q[M]` in `M_3(Q)`, its traceless part has dimension two. Consequently

`rank_Q Q_3 <= 2`.

This is a universal SCC conclusion; it does **not** depend on the six seed vectors.

The six-seed Target 1 theorem can now be read as showing that those particular seed defects violate this necessary counterexample condition: their `K_3` vectors are not in `W_det`.

## 5. Minimal three-state refinement

If a hypothetical counterexample has exactly three states, then `N_C` is rationally similar to `M` and is primitive. The orientation-spectral trichotomy says the extremal odd cases are gauge or anti-gauge.

In either gauge case, after a diagonal sign change (and an additional global minus sign in the anti-gauge case), `S` has irreducible cubic characteristic polynomial. Therefore any nonzero rational intertwiner out of `S` has zero kernel.

If `Q_3!=0`, this would force

`rank Q_3=3`,

contradicting the universal degree-3 bound `rank Q_3<=2` above.

Hence for a three-state counterexample with `K_2=0` and `Q_3!=0`, gauge and anti-gauge are impossible; it must again lie in the **strict odd-contraction** case.

This still leaves the possibility `K_2=K_3=0`, whose first defect degree is at least four.

## 6. Correction to the archived SCC quotient-transfer interface

The archived `PROOF_CERTIFICATE.md`, Section 11, states an SCC interface of the form

`L_C N_C = Phi_3 L_C`

for normalized balanced-pair SCC states.

That formula omits orientation signs and is not correct in general.

When the raw child `(x,y)` normalizes to `(y,x)`,

`K_3(y,x)=-K_3(x,y)`.

Therefore normalized unsigned child counts cannot reproduce the defect of the raw concatenation. The exact formula is

> `Q_3 S = Phi_3 Q_3`, with `S=A-B`.

The archived **seed-level Spectral Black Box remains valid**: its finite statements about individual `K_3(s_k)` vectors, `W_3`, `Theta`, Target 1, and dominant capture do not use the erroneous unsigned SCC interface.

### When an unsigned interface can be recovered

If the orientation cocycle is gauge-trivial, there is a diagonal sign matrix `D` with

`S=D N D^{-1}`.

Then

`Q_3 D N = Phi_3 Q_3 D`.

So after reorienting the SCC basis, an unsigned derived-substitution intertwiner is valid.

In the anti-gauge case,

`S=-D N D^{-1}`,

so

`Q_3 D N = -Phi_3 Q_3 D`,

and after squaring,

`Q_3 D N^2 = Phi_3^2 Q_3 D`.

For genuinely nontrivial/non-phase-coherent monodromy there is no reason for an unsigned quotient relation to exist.

### The v34 `K_2` mass/path-counting route is not invalidated

The archived v34 route uses the whole-pair identity

`K_2(sigma^k s_0)=sum_{raw descendants c} K_2(c)`

followed by the triangle inequality and **unsigned descendant counts**. It does not require an exact unsigned linear intertwiner from normalized SCC states to `Lambda^2 M`.

Orientation signs are absorbed before path counting by taking norms. Therefore the orientation correction above targets the archived Section-11 `K_3` quotient-transfer statement, not the v34 mass-growth/path-counting argument.

## 7. Updated degree-3 proof boundary

The degree-3 case is now sharper than “classify low-growth sectors”:

> Any degree-3 counterexample image must be centralizer-valued, equivalently contained in the two-dimensional determinant eigenspace `W_det`.

The remaining degree-3 task is to eliminate **realizable centralizer-valued balanced-pair defect families**, not to classify the spectrum of `W_3` again.

Together with the signed lowest-defect bridge, the remaining cases are:

1. first defect degree `2`: exterior-square quotient, spectral radius `<beta`;
2. first defect degree `3`: all `K_3` columns centralizer-valued, rank at most `2`;
3. first defect degree `>=4`: higher shuffle-primitive/free-Lie sectors, still open.
