# Worked Example: Misiurewicz Point `c = -2`

This is the minimal algebraic smoke test for the certificate calculus.

## Type

Critical orbit:

```text
0 -> -2 -> 2 -> 2
```

So the critical-orbit type is

```text
(l,k) = (2,1)
```

The parameter-angle datum is

```text
Theta = {1/2}
```

The angle/kneading preperiod is

```text
lambda = l - 1 = 1
```

and

```text
D(1/2) = 0
D(0) = 0
```

so the angle type is `(1,1)`.

## Critical-orbit polynomials

```text
Q_0 = 0
Q_1 = C
Q_2 = C^2 + C
Q_3 = (C^2 + C)^2 + C
```

For `(l,k) = (2,1)`:

```text
R_{2,1} = Q_3 - Q_2
        = (C^2 + C)^2 + C - (C^2 + C)
        = (C^2 + C)^2 - C^2
        = C^3(C+2)
```

The squarefree localization polynomial is

```text
P_{2,1} = sqfree(R_{2,1}) = C(C+2)
```

The target root is `c0 = -2`.

## Krawczyk localization

Choose a dyadic complex box `beta_r` centered at `-2` and excluding `0`.

For example:

```text
beta_r = [-2 - 2^-r, -2 + 2^-r] + i[-2^-r, 2^-r]
```

for `r` large enough.

Let

```text
P(C) = C(C+2)
P'(C) = 2C + 2
```

At `m = -2`:

```text
P(m) = 0
P'(m) = -2 != 0
```

So complex Krawczyk contraction succeeds for sufficiently small `beta_r`.

## Minimal horizon

For `H = l+k = 3`, the intended equality set is

```text
I_{2,1}(3) = {(2,3)}
```

The forbidden set is

```text
F_{2,1}(3) = {(0,1),(0,2),(0,3),(1,2),(1,3)}
```

Forbidden values at `c=-2`:

```text
Q_1 - Q_0 = -2
Q_2 - Q_0 = 2
Q_3 - Q_0 = 2
Q_2 - Q_1 = 4
Q_3 - Q_1 = 4
```

All are nonzero, so sufficiently small boxes interval-exclude zero for every forbidden pair.

## Equality/inequality split

The intended equality

```text
Q_3 - Q_2 = 0
```

is structural and must not be checked by interval separation.

The forbidden inequalities are strict and must be interval-separated.

This example is useful precisely because it forces the validator to handle a structural equality at a real-degenerate endpoint while not deleting the competing root `0` globally.

## Conclusion

The certificate concludes:

```text
MisTriv(-2, {1/2}, beta_r)
```

meaning:

- `beta_r` contains the unique selected root `-2` of `P_{2,1}`;
- the exact critical-orbit type is `(2,1)`;
- the parameter ray at angle `1/2` lands at `-2`;
- the Mandelbrot fiber of `-2` is trivial.
