# C4 degree-2 parity sieve

**Status:** exact arithmetic reduction for a hypothetical strict closed nonproductive SCC with nonzero `K2`. It does **not** prove C4, C1, G1, or PSC.

The merged first-defect census shows that degree two is overwhelmingly the live finite-corpus case. The signed defect theorem gives

`Q2 S = (Lambda^2 M) Q2`,

while the Parikh theorem gives

`P N = M P`.

This note extracts a new arithmetic restriction from the fact that the unsigned and signed child-incidence matrices are congruent modulo two.

## 1. Setup

Let `C` be a strict closed nonproductive recurrent SCC with `m=|C|`, and write

`N=A+B`,

`S=A-B`,

where `A` and `B` count positive and negative oriented child occurrences.

Then entrywise

`N == S (mod 2)`.

Suppose `K2` is nonzero on `C`. The degree-2 signed intertwiner and irreducibility of the PIP characteristic cubic imply that `Q2` has rational rank three. Hence `Lambda^2 M` is a rational quotient of `S`.

The Parikh intertwiner already gives rank three and makes `M` a rational quotient of `N`.

Therefore, over `Q`,

`chi_M | chi_N`,

`chi_{Lambda^2 M} | chi_S`.

All matrices are integral and both divisor polynomials are monic integral cubics, so Gauss's lemma upgrades these to divisibility in `Z[t]`.

## 2. Reduction modulo two

Because `N == S (mod 2)`,

`chi_N == chi_S (mod 2)`.

Thus the same degree-`m` polynomial over `F2` is divisible by both reduced cubic factors

`p_bar = chi_M mod 2`,

`q_bar = chi_{Lambda^2 M} mod 2`.

Consequently

> `m >= deg lcm(p_bar,q_bar)`.

This lower bound uses no positivity cone for `K2` and no phase-coherence assumption.

Write

`chi_M(t)=t^3-T t^2+U t-d`,

where `T=tr M`, `U` is the second elementary symmetric coefficient, and `d=det M`.

If the roots of `M` are `lambda_1,lambda_2,lambda_3`, the roots of `Lambda^2 M` are `lambda_1 lambda_2`, `lambda_1 lambda_3`, `lambda_2 lambda_3`. Hence

`chi_{Lambda^2 M}(t)=t^3-U t^2+d T t-d^2`.

Modulo two, signs disappear.

## 3. Complete parity table

Let `(tau,upsilon,delta)=(T mod 2,U mod 2,d mod 2)`. Direct polynomial gcd computation in `F2[t]` gives:

| `tau` | `upsilon` | `delta` | `deg lcm(p_bar,q_bar)` | necessary `|C|` |
|---:|---:|---:|---:|---:|
| 0 | 0 | 0 | 3 | `>=3` |
| 0 | 0 | 1 | 3 | `>=3` |
| 0 | 1 | 0 | 4 | `>=4` |
| 0 | 1 | 1 | 6 | `>=6` |
| 1 | 0 | 0 | 4 | `>=4` |
| 1 | 0 | 1 | 6 | `>=6` |
| 1 | 1 | 0 | 5 | `>=5` |
| 1 | 1 | 1 | 3 | `>=3` |

The executable table is `psc_research.degree2_parity` and is regression-tested exhaustively over all eight parity classes.

### Generic odd-determinant case

When `d` is odd and `T,U` have opposite parity, the two reduced cubics are coprime. Therefore

`|C| >= 6`.

Indeed their difference is `t(t+1)` modulo two, while neither cubic vanishes at `0` or `1`, so they have no common factor.

### Three-state consequence

A three-state degree-2 counterexample can exist only when `p_bar=q_bar`. The parity possibilities are exactly

`(T,U,d) mod 2 in {(0,0,0),(0,0,1),(1,1,1)}`.

Thus the earlier algebraic three-state normal form is eliminated in five of the eight coefficient-parity classes before any endpoint analysis.

## 4. Retired endpoint-cone route

A tempting attempt was to use `K2` as signed projected area and seek a linear functional that is positive on all irreducible balanced pairs with swapped outer endpoints

`u_0=0, v_0=1, u_{n-1}=1, v_{n-1}=0`.

Short words suggested such a cone, but the statement already fails at length nine. Four exact irreducible balanced pairs in that single endpoint class have wedge-coordinate `K2` vectors

```text
q1 = ( 2,-5,-2)
q2 = ( 2, 3, 4)
q3 = (-2, 4, 2)
q4 = ( 1,-3,-9)
```

and satisfy the positive integer relation

`50 q1 + 8 q2 + 61 q3 + 6 q4 = 0`.

Hence the origin lies in the convex hull of that endpoint class and **no linear half-space can contain it**. In particular the previously observed short-word functional `2 K12 + K13 - K23` is not a theorem.

One choice of word-pair witnesses is:

```text
q1:
  u=021020001
  v=100002120

q2:
  u=010112021
  v=120021110

q3:
  u=011100021
  v=120001110

q4:
  u=022211001
  v=100112220
```

(all letters zero-based). Each pair is balanced and has no intermediate zero-return cut.

This route is therefore retired; any successful degree-2 argument must retain more than a fixed linear cone determined by outer endpoint letters.

## 5. What the parity sieve buys

The sieve does not eliminate all degree-2 strict SCCs, but it constrains the only remaining live structural case without relying on a fragile geometric sign claim.

It combines naturally with the existing independent bounds:

- `|C|>=3` from the Parikh rank theorem;
- at most 1/3/9 projected endpoint signatures;
- orientation spectral trichotomy for primitive derived incidence;
- exact parity lower bound `3..6` from this note.

The next useful step is to intersect these arithmetic size classes with endpoint-signature recurrence and with the actual degree-2 sink-SCC distributions in the exact PIP corpus. A proof still needs a reason that a strict closed nonproductive SCC cannot realize the surviving combinations.
