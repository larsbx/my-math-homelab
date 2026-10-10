# C4-E arbitrary-degree multidegree spectral sieve

**Status:** exact generalized-Witt enumeration plus a PIP-cone spectral exclusion theorem. This does **not** prove C4, C1, G1, or PSC.

The preceding C4 reductions show that a hypothetical strict closed nonproductive SCC has a finite first nonzero scattered-subword defect degree `r`. At that degree all lower concatenation and substitution correction terms vanish, giving the signed intertwiner

`Q_r S = Phi_r Q_r`,

where `Phi_r` is the action of `M_sigma^{tensor r}` on the degree-`r` shuffle-primitive/free-Lie sector and

`rho(S) <= beta`.

Degrees two, three and four were analyzed separately. This note gives the common arbitrary-degree spectral sieve.

## 1. Exact multidegree multiplicity

For three letters, let `(a,b,c)` be a multidegree with total

`r=a+b+c`.

The generalized Witt formula gives the multiplicity of that ordered weight in the degree-`r` free Lie algebra:

`m(a,b,c) = (1/r) sum_{d | gcd(a,b,c)} mu(d) * (r/d)! / ((a/d)!(b/d)!(c/d)!).`

`reference/psc_research/multidegree_sieve.py` implements this formula exactly, enumerates all positive-multiplicity multidegrees, and verifies that their orbit dimensions sum to the ordinary Witt dimension

`dim Lie_r(Q^3) = (1/r) sum_{d|r} mu(d) 3^(r/d)`.

No floating point or root approximation occurs in the sieve.

## 2. The PIP logarithmic cone

Let the roots of the irreducible PIP cubic be

`beta, alpha, gamma`,

with

`beta>1`, `1>|alpha|>=|gamma|>0`.

Put

`x=log beta`, `y=-log|alpha|`, `z=-log|gamma|`,

so

`z>=y>0`.

Since

`|det M| = beta |alpha gamma|`

is a nonzero integer, write

`delta=log|det M| = x-y-z >= 0`,

hence

`x=y+z+delta`.

Sort a weight as

`a>=b>=c>=0`.

In the full `S_3` Galois orbit, the largest modulus is obtained by assigning exponent `a` to `beta`, exponent `b` to the larger stable modulus `|alpha|`, and exponent `c` to `|gamma|`:

`R(a,b,c)=beta^a |alpha|^b |gamma|^c`.

Relative to the Perron bound,

`log(R/beta) = (a-1-b)y + (a-1-c)z + (a-1)delta.`

This one expression drives the classification.

## 3. All-distinct weights are always too large

Suppose

`a>b>c`.

Then

`a-1-b>=0`, `a-1-c>=1`,

so the displayed logarithm is strictly positive. Therefore the full `S_3` orbit has spectral radius `>beta`.

The cyclic `A_3` Galois case needs one extra check because a six-element all-distinct orbit splits into two three-element rational orbits. Each cyclic orbit still contains a weight with exponent `a` on `beta`:

- one has stable exponents `(b,c)` and logarithm above;
- the other has stable exponents `(c,b)` and logarithm
  `(a-1-c)y + (a-1-b)z + (a-1)delta`,
  whose first coefficient is at least one.

Thus **both** cyclic suborbits are strictly above `beta`.

So every possible low-growth rational factor has a repeated exponent.

## 4. Repeated-exponent classification

There are three cases.

### 4.1 All equal: `(m,m,m)`

This requires

`r=3m`.

The weight is the scalar

`(beta alpha gamma)^m = det(M)^m`.

It is not uniformly above `beta`; it remains a candidate exactly when

`|det M|^m <= beta`.

### 4.2 Two smaller exponents equal: `(a,b,b)`

The logarithm becomes

`(a-1-b)(y+z) + (a-1)delta`.

It can fail to be strictly positive only when

`a=b+1`.

Writing `b=m` gives

`r=3m+1`, `weight=(m+1,m,m)`.

Its three eigenvalues are

`det(M)^m lambda_i`,

so this is the **standard-twist cubic** `det^m tensor V`, with spectral radius

`|det M|^m beta`.

For `r>=4` (`m>=1`) it is at or below `beta` exactly in the unimodular case, where it is equal to `beta`.

### 4.3 Two larger exponents equal: `(a,a,c)`

Now

`log(R/beta) = -y + (a-1-c)z + (a-1)delta`.

Let `t=a-c`.

- `t=1`: the expression is `-y+(a-1)delta`, which may be negative. Writing `c=m`, this is
  `r=3m+2`, `weight=(m+1,m+1,m)`.
  The operator type is
  `det^m tensor Lambda^2(V) ~= det^(m+1) tensor V*`,
  with spectral radius
  `|det M|^m beta |alpha|`.
  It is at or below `beta` exactly when
  `|det M|^m |alpha| <= 1`.

- `t=2`: the expression is `-y+z+(a-1)delta>=0`.
  Equality requires both `z=y` and `delta=0`: unimodularity and equal stable-root moduli. This is possible only in the one-real/two-complex-conjugate PIP branch. Writing `a=m+1` gives
  `r=3m+1`, `weight=(m+1,m+1,m-1)`.
  Its cubic weights are
  `det^(m-1) (lambda_i lambda_j)^2 = det^(m+1)/lambda_k^2`.
  Call this the **pair-square boundary cubic**.

- `t>=3`: the expression is strictly positive.

## 5. The mod-3 spectral sieve

Therefore, up to permutation, the only free-Lie multidegrees whose rational Galois factors can have spectral radius at most `beta` are:

### `r=3m`

Only

`(m,m,m)`,

the scalar `det^m` sector.

### `r=3m+1`

Always only the standard-twist boundary

`(m+1,m,m)`,

and, in the complex-stable-root branch only, the additional pair-square boundary

`(m+1,m+1,m-1)`.

### `r=3m+2`

Only

`(m+1,m+1,m)`,

the dual-twist sector `det^m tensor Lambda^2(V)`.

This is the main arbitrary-degree reduction: **at most two Galois weight families survive in any first-defect degree**.

The executable classifier `candidate_families` reproduces:

- degree 2: `(1,1,0)`;
- degree 3: `(1,1,1)`;
- degree 4: `(2,1,1)` and, for complex stable roots, `(2,2,0)`;
- degree 5: `(2,2,1)`;
- degree 6: `(2,2,2)`;
- degree 7: `(3,2,2)` and, for complex stable roots, `(3,3,1)`;
- degree 8: `(3,3,2)`;
- degree 9: `(3,3,3)`;
- degree 10: `(4,3,3)` and, for complex stable roots, `(4,4,2)`.

All other positive-multiplicity multidegrees are theoremically forced above the orientation bound.

## 6. Recovery of the previous low-degree results

The general sieve recovers the earlier special cases.

### Degree two

`r=2=3*0+2` gives `(1,1,0)`, namely `Lambda^2 V`, with spectral radius `beta|alpha|<beta`.

### Degree three

`r=3` gives only `(1,1,1)`, the determinant scalar. This is the two-dimensional determinant/centralizer weight inside the degree-3 primitive module once multiplicity is included; every non-determinant `W_3` factor is spectrally too large.

### Degree four

`r=4` gives the standard twist `(2,1,1)=det tensor V`, plus the complex-only pair-square boundary `(2,2,0)`. This is exactly the degree-4 theorem already proved.

### Degree five

`r=5` gives only `(2,2,1)=det tensor Lambda^2 V ~= det^2 tensor V*`.

Its spectral radius is

`|det M| beta |alpha|`.

In the unimodular case this is `beta|alpha|<beta`. Thus degree five is the first place where a genuinely sub-Perron higher-degree factor survives, explaining why the degree-4 spectral-floor argument cannot be extrapolated.

## 7. Minimal three-state global normal form

Now suppose a hypothetical strict counterexample has the minimum possible size

`|C|=3`.

The Parikh intertwiner makes

`N_C` rationally similar to `M`, hence primitive. If the orientation sector is Perron-extremal, the orientation-spectral theorem gives

`S ~ zeta M`, `zeta in {+1,-1}`.

Because `char(S)` is an irreducible cubic, any nonzero rational first-defect map `Q_r` from the three-dimensional state space is injective. Therefore its image is a three-dimensional irreducible cubic factor similar to `S`.

Apply the mod-3 list.

### `r=3m`: impossible under phase coherence

The only candidate is the rational scalar `det^m`. A three-dimensional matrix with irreducible characteristic polynomial cannot have this rational eigenvalue. So no phase-coherent minimal counterexample can start in degree `0 mod 3`.

### `r=3m+2`: impossible under phase coherence

The candidate is

`det^m Lambda^2 M`.

If it were similar to `zeta M`, comparing determinants gives

`|det M|^(3m+2)=|det M|`,

so `|det M|=1`. But then the candidate spectral radius is

`beta|alpha|<beta`,

whereas `zeta M` has spectral radius `beta`. Contradiction.

### `r=3m+1`: only the standard twist survives

The pair-square boundary, when present, has in the unimodular complex-pair case the modulus multiset

`{beta,beta,beta^-2}`,

whereas `zeta M` has

`{beta,beta^-1/2,beta^-1/2}`.

They cannot be similar.

The standard twist is

`det^m M`.

Its spectral radius is at most `beta` only when `|det M|=1`. Similarity

`zeta M ~ det^m M`

then forces equality of determinants:

`zeta det M = det(M)^(3m+1)`.

Since `det M=+/-1`, this gives the exact phase condition

`zeta = det(M)^m`.

Hence:

> **Minimal phase-coherent normal form.** A three-state Perron-extremal counterexample can have first nonzero defect only in degree
> `r=3m+1`; it must be unimodular; its defect image is the standard-twist cubic `det^m V`; and its orientation phase is `zeta=det(M)^m`.

After passing to a suitable square when the phase is `-1`, the orientation becomes trivial.

## 8. Strict-orientation complement at minimal size

If instead

`rho(S)<beta`,

then no first-defect image can have spectral radius `>=beta`.

Both degree-`3m+1` candidate families have spectral radius at least `beta`, so they are excluded.

Thus:

> **Minimal strict-phase normal form.** A three-state counterexample with strict odd contraction can have first nonzero defect only in degrees
> `r=0 mod 3` or `r=2 mod 3`.

This yields a clean mod-3 dichotomy for the minimal SCC:

- phase-coherent/Perron-extremal -> `r=1 mod 3`, unimodular standard twist;
- strictly contracted orientation -> `r=0 or 2 mod 3`, scalar or dual-twist family.

## 9. What remains open

The spectral representation frontier is no longer “all higher degrees.” It is the realizability of the near-balanced candidate families above.

For arbitrary larger SCCs the first-defect image may be a proper quotient of `S`, so the minimal-size similarity argument does not apply directly. The remaining work should combine:

1. the at-most-1/3/9 endpoint synchronization signatures;
2. the Parikh quotient `P_C N_C=M P_C`;
3. orientation gauge/anti-gauge or strict contraction;
4. the mod-3 candidate family of the first defect;
5. word-level unique decodability inside supertiles.

The Level-2 unique-decodability theorem alone does **not** identify the two gauge-trivial word realizations `U,V`: balanced-pair child cuts are not yet proved to align with sigma-supertile boundaries. That boundary-alignment step remains a genuine combinatorial obligation.

## 10. Guardrails

- This is a spectral **sieve**, not a proof that every candidate multidegree is realizable by balanced words.
- The upper repeated `3m+1` boundary is included only for the complex-stable-root branch; equal stable moduli are impossible for a three-distinct-real-root irreducible cubic.
- Corpus counts are not used in the theorem.
- G1 and C1/C4 remain open.
