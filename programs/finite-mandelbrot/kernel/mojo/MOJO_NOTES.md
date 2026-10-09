# Mojo computation preservation

This directory preserves the computations from the finite-regime Mandelbrot certificate work in Mojo source files.

## Files

- `finite_mandelbrot.mojo` — executable numeric anchors for the critical-orbit recurrence, the `c=-2` smoke test, and the `M_{4,1}` stress-test orbit. It also preserves the explicit polynomial factorizations used in the spec.
- `certificate_sets.mojo` — finite combinatorial computations: rational-angle doubling, intended equality sets, forbidden collision sets, and the horizon-sensitive split used by the validator.

## Design boundary

The Mojo code does **not** pretend to contain a complete exact polynomial algebra or certified interval library yet. The preserved computations are split into:

1. executable finite arithmetic where direct Mojo scalar arithmetic is sufficient;
2. certificate obligations expressed as comments/docstrings and function boundaries, ready to be backed by exact polynomial and dyadic interval modules.

## Computations preserved

### Critical orbit recurrence

```text
Q_0(C) = 0
Q_{n+1}(C) = Q_n(C)^2 + C
```

### Rank-2 complex multiplication presentation

```text
(x,y) * (u,v) = (xu - yv, xv + yu)
```

### Escape/norm form

```text
N(x,y) = x^2 + y^2
```

### `c=-2` smoke test

```text
0 -> -2 -> 2 -> 2
(ell, k) = (2, 1)
R_{2,1}(C) = C^3(C + 2)
P_{2,1}(C) = sqfree(R_{2,1}) = C(C + 2)
Theta = {1/2}
lambda = ell - 1 = 1
```

### `M_{4,1}` stress test

```text
c0 ~= -0.10109636384562216 + 0.95628651080914150 i
(ell, k) = (4, 1)
Theta = {9/56, 11/56, 15/56}
lambda = 3
ray period n = 3
kneading/orbit period k = 1
H = 6
I = {(4,5), (4,6), (5,6)}
F = all other pairs 0 <= i < j <= 6
```

### Horizon-sensitive intended equality set

```text
I_{ell,k}(H) = {(i,j): 0 <= i < j <= H, i >= ell, k | (j-i)}
F_{ell,k}(H) = all pairs minus I_{ell,k}(H)
```

## Next implementation step

Add an exact polynomial module over `Int` coefficient arrays:

- polynomial addition/subtraction/multiplication;
- derivative;
- Euclidean gcd over rational-normalized polynomials;
- squarefree factor witness;
- evaluation on dyadic complex boxes.

Then add a dyadic interval module and make the Krawczyk witness executable instead of documentary.
