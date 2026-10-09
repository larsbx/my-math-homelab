# C4-C orientation-even/odd spectral decomposition

**Status:** exact algebraic decomposition proved; Perron comparison stated with its precise equality cases. This does **not** prove C4, C1, G1, or PSC.

This note refines the orientation-monodromy dichotomy by splitting the oriented double cover into deck-even and deck-odd linear sectors.

## 1. Positive and negative child-incidence matrices

Let `C={T_1,...,T_m}` be a strict closed nonproductive recurrent SCC. For each normalized parent state `T_j`, every irreducible child occurrence lies in `C` and carries an orientation sign `+1` or `-1`.

Define two nonnegative integer matrices:

- `A[i,j]` = number of positive occurrences of `T_i` in `sigma(T_j)` after reduction;
- `B[i,j]` = number of negative occurrences.

Then the ordinary derived-substitution incidence is

`N = A+B`,

while the **signed orientation incidence** is

`S = A-B`.

The exact implementation is `psc_research.orientation_spectrum.build_orientation_incidence`.

## 2. Oriented double-cover incidence

Order the oriented alphabet as

`(T_1,+),...,(T_m,+),(T_1,-),...,(T_m,-)`.

A positive child preserves the parent sheet and a negative child flips it. Therefore the oriented derived substitution has incidence

```text
N~ = [ A  B ]
     [ B  A ].
```

Let `E_+={(x,x)}` and `E_-={(x,-x)}` be the deck-even and deck-odd subspaces of `Q^{2m}`.

### Proposition 1 — exact deck decomposition

`N~` preserves `E_+` and `E_-`, acting as

- `N` on `E_+`;
- `S` on `E_-`.

Equivalently, over `Q`, the Hadamard change of coordinates block-diagonalizes the cover:

```text
H^{-1} N~ H = diag(N,S),
H = [ I  I ]
    [ I -I ].
```

Hence

`char(N~)=char(N) char(S)`.

### Proof

Direct multiplication gives

`N~(x,x)=((A+B)x,(A+B)x)=(Nx,Nx)`

and

`N~(x,-x)=((A-B)x,-(A-B)x)=(Sx,-Sx)`.

QED.

The implementation verifies these identities on every basis vector.

## 3. The Parikh quotient is entirely deck-even

Let `P=P_C` be the common-Parikh matrix from the Parikh-intertwiner theorem. Both orientations of a normalized state have the same Parikh vector, so the cover Parikh map is

`P~=[P P]`.

Therefore

`P~(x,-x)=0`

for every odd vector. The whole deck-odd sector lies in `ker P~`.

Moreover

`P~ N~ = M_sigma P~`,

because

`[P P] [A B; B A] = [P(A+B), P(A+B)] = [PN,PN] = M_sigma[P P]`.

Thus the irreducible Pisot quotient carried by `M_sigma` lives entirely in the deck-even sector. The odd sector is pure orientation data invisible to abelianization.

## 4. Perron comparison for the odd sector

Because `C` is strongly connected, `N` is an irreducible nonnegative matrix. The Parikh-intertwiner theorem gives

`rho(N)=beta`,

the Perron eigenvalue of `M_sigma`.

Entrywise,

`|S| <= N`.

### Proposition 2 — odd-sector spectral bound

Every eigenvalue `lambda` of `S` satisfies

`|lambda| <= beta`.

Hence

`rho(S) <= beta`.

### Proof

If `Sx=lambda x`, then entrywise

`|lambda| |x| = |Sx| <= |S| |x| <= N |x|`.

The Perron/Collatz-Wielandt comparison for irreducible `N` implies `|lambda|<=rho(N)=beta`. QED.

So the oriented cover never creates a growth rate exceeding the original Perron rate.

## 5. Two easy strictness criteria

The inequality is already strict in many cases without calculating any eigenvalues.

### Mixed parallel signs

If some fixed parent-child pair has both positive and negative occurrences, then for that matrix entry

`|S[i,j]| < N[i,j]`.

For irreducible `N`, strict Perron comparison gives

`rho(S) < beta`.

The helper `parallel_signs_are_consistent` detects this exact combinatorial condition.

### Phase frustration

Suppose there are no mixed-sign parallel occurrences. Equality `rho(S)=beta` is still rigid. The equality case of the irreducible Perron/Wielandt comparison implies the existence of a unit complex number `zeta` and unit vertex phases `d_i` such that, on every child edge `j -> i`,

`sign(i<-j) = zeta d_i d_j^{-1}`.

Equivalently, the product of signs around any directed cycle of length `L` is `zeta^L`.

Call this **phase coherence**. If no such phase system exists, then again

`rho(S)<beta`.

This isolates a finite monodromy obstruction much more sharply than merely saying the cocycle is nontrivial.

## 6. Primitive derived matrix: only gauge or anti-gauge can be extremal

Assume now that `N` is primitive. Its directed cycle lengths have gcd `1`.

In the equality case, every cycle sign product is `zeta^L` and is real `+/-1`. Therefore

`zeta^{2L}=1`

for every cycle length `L`. Since their gcd is `1`,

`zeta^2=1`,

so

`zeta=+1` or `zeta=-1`.

After a global phase normalization, the vertex phases may then be chosen in `{+1,-1}`.

Thus:

### Proposition 3 — primitive extremal trichotomy

For primitive `N`, exactly one of the following occurs:

1. **strict odd contraction:** `rho(S)<beta`;
2. **gauge case:** there is `g:C->{+/-1}` with
   `g(child)=sign(edge) g(parent)` on every occurrence, and `S` is diagonally similar to `N`;
3. **anti-gauge case:** there is `g:C->{+/-1}` with
   `g(child)=-sign(edge) g(parent)` on every occurrence, and `S` is diagonally similar to `-N`.

The existing orientation gauge solver handles case 2. `solve_constant_phase_gauge(...,-1)` detects case 3.

In the anti-gauge case, after reorienting vertices every one-step child occurrence reverses orientation. Therefore every two-step child path preserves orientation, so the orientation cocycle of the squared derived substitution `tau_C^2` is trivial.

## 7. Minimal three-state counterexample corollary

The Parikh-intertwiner theorem proved that any PIP counterexample SCC has at least three states. If `|C|=3`, then `P_C` is invertible over `Q` and

`N=P_C^{-1} M_sigma P_C`.

Hence `N` has exactly the same spectrum as the primitive matrix `M_sigma`. Since `N` is irreducible and has no other eigenvalue on the Perron circle, `N` itself is primitive.

Therefore a hypothetical **three-state** counterexample has only the three orientation possibilities in Proposition 3:

- strict odd spectral contraction;
- trivial orientation gauge;
- anti-gauge, which becomes trivial after squaring.

There is no more complicated extremal orientation phase in the minimal-size case.

## 8. Calibration: the existing non-Pisot negative control

For

`1 -> 2, 2 -> 123, 3 -> 2`

with strict component

`A=(12,21), B=(23,32)`, the signed reductions are

`A -> A^- B^+`,
`B -> A^+ B^-`.

Thus

```text
A_pos = [0 1]
        [1 0],

B_neg = [1 0]
        [0 1],

N = [1 1]
    [1 1],

S = [-1  1]
    [ 1 -1].
```

The cocycle is not gauge-trivial, but it **is anti-gauge**. Correspondingly `S` has eigenvalue `-2` while `N` has Perron eigenvalue `+2`: the odd sector is extremal in modulus rather than strictly contracted.

This example is outside the PIP regime and has rank-two Parikh data, but it is an important calibration: nontrivial monodromy does not by itself imply a strict spectral gap. The correct distinction is strict versus phase-coherent monodromy.

## 9. Next C4-C target

The remaining obstruction now splits into sharply different finite cases:

- **strict odd contraction:** combine `rho(S)<beta` with endpoint-signature recurrence and Pisot stable contraction;
- **trivial gauge:** analyze the two distinct word realizations `U,V` of the same derived substitution;
- **anti-gauge:** pass to `tau_C^2`, where orientation becomes trivial, and reduce to the two-realization case;
- **imprimitive extremal phase:** only possible when `N` is imprimitive and `|C|>3`; classify the finite period/phase data before using Pisot algebra.

This is a smaller target than the raw monodromy dichotomy and keeps the abelian/Perron quotient separate from the orientation-odd kernel where the remaining obstruction lives.
