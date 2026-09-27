# Exact parabolic-index bridge

**Status:** executable research bridge, not a certificate promotion.

This repository already has exact truncated jets over `Q(i)` for the
quadratic family `f_c(z) = z^2 + c`.  The bulb/Ford research program studies
the local germ

```text
g_lambda(w) = lambda w + w^2
```

at roots of unity.  These are not separate dynamics.  For

```text
z0 = lambda / 2
c  = lambda / 2 - lambda^2 / 4
z  = z0 + w
```

direct expansion gives

```text
f_c(z0 + w) - z0 = lambda w + w^2.
```

That identity is polynomial and exact.  It uses no angle measurement,
trigonometric function, limit, or floating-point approximation.

## Low-q exact slice

When `lambda` is one of the roots of unity already representable in
`Q(i)`, the whole local computation stays in exact Gaussian rationals.
`oracles/parabolic_index.py` reconstructs the fixed-point index from a finite
jet:

```text
w - g_lambda^q(w) = w^(q+1) P(w)
index = [w^q] 1/P(w).
```

The pinned fixtures are:

| q | lambda | c | index |
| --- | --- | --- | --- |
| 1 | 1 | 1/4 | 0 |
| 2 | -1 | -3/4 | 1/8 |
| 4 | i | 1/4 + i/2 | (1447 - 365 i)/4624 |
| 4 | -i | 1/4 - i/2 | (1447 + 365 i)/4624 |

The `q=4` row is additionally replayed by the existing quadratic jet:
`R^c_{0,4}` at `z0=i/2` has vanishing order `5=q+1`.

## Authority boundary

This bridge establishes exact finite algebra only:

- the translation between the two quadratic normalizations;
- the finite jet coefficients over `Q(i)`;
- the vanishing order of the parabolic residual;
- the exact low-`q` residue/index values.

It does **not** establish bulb diameters, component geometry, landing,
connectivity, local connectivity, or any Mandelbrot-set theorem.  Those
statements require their existing domain-specific theorem imports or research
evidence.

The Python implementation remains an independent reference oracle.  The Mojo
jet remains the repository's canonical finite execution layer for the
coefficient facts it checks.

## General-q frontier

For general `p/q`, `lambda` belongs to a cyclotomic extension rather than
`Q(i)`.  The next reusable-kernel boundary is therefore a finite exact
cyclotomic quotient representation together with canonical serialization and
independent replay.  That representation belongs in `finite-math-kernels`,
not in this domain repository.
