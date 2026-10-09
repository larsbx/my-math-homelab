# Stress Test: Principal Branch Misiurewicz Point `M_{4,1}`

This example is intended to exercise the validator paths that `c = -2` does not:

- multi-ray landing;
- non-vacuous cyclic-order unlinking;
- squarefree localization with multiple roots retained globally;
- horizon `H > l+k`;
- structural routing of later periodic-tail equalities.

## Claimed data

Critical-orbit type:

```text
(l,k) = (4,1)
```

Use a longer horizon:

```text
H = 6 > l+k = 5
```

Candidate parameter:

```text
c0 ≈ -0.10109636384562216 + 0.95628651080914150 i
```

Candidate angle datum:

```text
Theta = {9/56, 11/56, 15/56}
```

Angle/kneading preperiod:

```text
lambda = l - 1 = 3
```

Raw ray period:

```text
n = 3
```

Kneading/orbit period:

```text
k = 1
```

This stresses the rule that raw ray period need not equal orbit period.

## Polynomial target

Critical-orbit recurrence:

```text
Q_0 = 0
Q_{n+1} = Q_n^2 + C
```

Raw return polynomial:

```text
R_{4,1} = Q_5 - Q_4
```

Previously computed factorization target:

```text
R_{4,1} = C^5(C+2)(C^3+2C^2+2C+2)
          (C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2)
```

Squarefree localization polynomial:

```text
P_{4,1} = sqfree(R_{4,1})
        = C(C+2)(C^3+2C^2+2C+2)
          (C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2)
```

The target is the upper non-real root of the degree-7 factor.

## Horizon logic

For `H = 6` and `(l,k) = (4,1)`, intended equalities are:

```text
I_{4,1}(6) = {(4,5), (4,6), (5,6)}
```

because the orbit is fixed after step `4`.

All other pairs `0 <= i < j <= 6` are forbidden.

Total pairs:

```text
binomial(7,2) = 21
```

Intended pairs:

```text
3
```

Forbidden pairs:

```text
18
```

A valid certificate must prove:

```text
0 notin Q_j(beta) - Q_i(beta)
```

for every forbidden pair, using the same box `beta` used for Krawczyk localization.

## Joint box target

The completed stress-test certificate should provide one dyadic complex box `beta` such that:

```text
K_{P_{4,1}}(beta) subset int(beta)
```

and

```text
for all (i,j) in F_{4,1}(6), 0 notin Q_j(beta)-Q_i(beta).
```

This is the joint-smallness condition surfaced by the squarefree-localization patch.

## Angle orbit

Under doubling `D(theta)=2theta mod 1`:

```text
B0 = {9/56, 11/56, 15/56}
B1 = {9/28, 11/28, 15/28}
B2 = {1/14, 9/14, 11/14}
A0 = {1/7, 2/7, 4/7}
```

Then

```text
D(A0) = A0
```

with cyclic permutation

```text
1/7 -> 2/7 -> 4/7 -> 1/7
```

So the rays have raw period `3` while the critical orbit lands on a fixed point, `k=1`.

## Unlinking witness to verify

The finite cyclic-order checker should verify pairwise non-crossing/unlinking of the pullback portrait:

```text
B0, B1, B2, A0
```

Store the proof as rational cyclic-order comparisons or complementary-arc witnesses.

## Status

This file records the intended stress-test target. The exact dyadic Krawczyk witness and interval exclusion margins still need to be generated and checked by the prototype verifier.
