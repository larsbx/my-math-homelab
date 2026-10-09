# Exact Algebra Acceptance Criteria

This document defines the next non-negotiable implementation target for the finite-regime Mandelbrot validator.

## Scope

The next hardening pass must replace preserved/formula-level computations with executable exact algebra over `Z[C]`.

The implementation must support:

1. construction of `Q_n(C)` from
   
   ```text
   Q_0(C) = 0
   Q_{n+1}(C) = Q_n(C)^2 + C
   ```

2. construction of raw return polynomials

   ```text
   R_{ell,k}(C) = Q_{ell+k}(C) - Q_ell(C)
   ```

3. derivative computation;
4. exact polynomial addition, subtraction, and multiplication;
5. exact divisibility checks;
6. Euclidean gcd witness verification over `Q[C]` or primitive-part normalized `Z[C]`;
7. squarefree construction

   ```text
   P_{ell,k}(C) = sqfree(R_{ell,k})
   ```

8. rejection of any implementation that attempts global lower-factor gcd stripping.

## Must-pass computations

### `c = -2`, type `(ell,k)=(2,1)`

The implementation must derive:

```text
R_{2,1}(C) = Q_3(C) - Q_2(C)
           = C^3(C+2)
```

and

```text
P_{2,1}(C) = sqfree(R_{2,1})
           = C(C+2)
```

It must not reduce `P_{2,1}` to `C+2` by deleting the lower-type root globally.

The lower root `0` is excluded only by the chosen dyadic box around `-2` and the pointwise exact-type checks.

### `M_{4,1}`, type `(ell,k)=(4,1)`

The implementation must derive:

```text
R_{4,1}(C) = Q_5(C) - Q_4(C)
```

and verify the preserved factorization:

```text
R_{4,1}(C)
= C^5(C+2)
  (C^3+2C^2+2C+2)
  (C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2)
```

It must derive:

```text
P_{4,1}(C)
= C(C+2)
  (C^3+2C^2+2C+2)
  (C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2)
```

Again, no lower-type factor may be globally removed except by squarefree multiplicity removal.

## Same-box rule

For a certificate box `beta`, the validator must require a joint witness:

```text
K_P(beta) subset interior(beta)
AND
for all forbidden (i,j), 0 notin H_ij(beta)
```

where

```text
H_ij(C)=Q_j(C)-Q_i(C).
```

The Krawczyk inclusion and all forbidden exclusions must be computed over the same `beta`.

Passing Krawczyk on one box and exclusions on another is invalid.

## Horizon-aware collision partition

Given `(ell,k,H)` with `H >= ell+k`, intended equalities are:

```text
I_{ell,k}(H) = {(i,j): 0 <= i < j <= H, i >= ell, (j-i) mod k = 0}
```

Forbidden collisions are the complement:

```text
F_{ell,k}(H) = all pairs (i,j), 0 <= i < j <= H, minus I_{ell,k}(H)
```

At minimal horizon `H=ell+k`, this reduces to the single intended pair `(ell, ell+k)`.

At longer horizon, periodic-tail equalities must be routed structurally, not forbidden.

## Angle/kneading rule

The validator must distinguish:

```text
critical orbit type:      (ell,k)
angle preperiod:          lambda = ell - 1
raw ray period:           n
kneading/orbit period:    k
required relation:        k divides n
```

It must not require raw ray period `n` to equal orbit period `k`.

The `M_{4,1}` stress test has:

```text
ell = 4
k = 1
lambda = 3
n = 3
Theta = {9/56, 11/56, 15/56}
```

This must pass header-level validation.

## Regression failures

The implementation fails if it does any of the following:

1. localizes on raw `R_{ell,k}` instead of `sqfree(R_{ell,k})`;
2. globally strips lower-collision gcd factors after squarefree;
3. routes intended tail equalities to interval exclusion;
4. routes forbidden exclusions to structural equality;
5. permits Krawczyk and forbidden exclusions on different boxes;
6. requires raw ray period `n` to equal orbit period `k`;
7. treats theorem tags as internally proved by arithmetic routines.
