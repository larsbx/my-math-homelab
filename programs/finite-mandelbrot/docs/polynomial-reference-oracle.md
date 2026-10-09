# Polynomial Reference Oracle

`reference/python/polynomial/poly_reference.py` is a development-time oracle for polynomial identities.

It is not the certificate engine and must not become the source of truth for the
finite calculus. Its role is to check that the Mojo implementation preserves the
known integer-polynomial computations while the arbitrary-precision backend and
native squarefree witness checker are still being built.

## What it checks now

- Critical orbit recurrence:
  - `Q_0 = 0`
  - `Q_{n+1} = Q_n^2 + C`
- Raw return polynomial:
  - `R_{ell,k}=Q_{ell+k}-Q_ell`
- Worked identities:
  - `R_{2,1}=C^3(C+2)`
  - expected squarefree localization polynomial `P_{2,1}=C(C+2)`
  - `R_{4,1}=C^5(C+2)(C^3+2C^2+2C+2)F_7(C)`
  - expected squarefree localization polynomial `P_{4,1}=C(C+2)(C^3+2C^2+2C+2)F_7(C)`

where

```text
F_7(C)=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2.
```

## Hard invariant

Exact-type filtering is never performed by globally stripping lower-collision
factors.

The valid path is:

```text
P_{ell,k} = squarefree(R_{ell,k})
localize one selected root of P_{ell,k} inside beta
exclude all forbidden H_{i,j} on that same beta
```

The reference oracle must only support this path.

## Replacement target

The Mojo implementation should eventually replace the Python oracle with:

1. native arbitrary-precision integer coefficients;
2. primitive-part normalization;
3. exact polynomial pseudo-division or rational division;
4. Euclidean gcd witness checking;
5. squarefree witness checking;
6. exact reconstruction tests for `R_{2,1}` and `R_{4,1}`.

Until then, CI runs the reference oracle to keep the recorded computations from
drifting.
