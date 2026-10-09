# Inverse-derivative handoff

Status: scaffolded, not yet full certificate engine.

## Purpose

Krawczyk localization needs an approximate inverse `A` for `P'(m)`.
This project computes that inverse algebraically:

```text
z^{-1} = conjugate(z) / quadrance(z)
quadrance(x,y) = x^2 + y^2
```

No analytic trigonometry, angle measurement, transcendental functions, or floating arithmetic are allowed in the certificate path.

## Completed

- `kernel/mojo/arithmetic/complex_inverse.mojo` defines `ComplexQ` and exact rational inverse by conjugate/quadrance.
- `inverse_p21_derivative_at_minus_2()` records the exact inverse for `P21'(-2)=-2`, namely `-1/2`.
- `inverse_derivative_m41_pending()` remains unaccepted until exact point evaluation of `P41'(m)` is available.
- CI runs `tests/test_complex_inverse.py`.

## Next implementation target

1. Add point evaluation for integer-coefficient polynomials over `ComplexQ`, not `ComplexIQ`.
2. Evaluate `P41'(m)` at the dyadic center
   `m=(-56912193317957 + 538341446717435 i) / 2^49`.
3. Compute `A = inverse(P41'(m))` using `ComplexQ.inverse()`.
4. Use `A.to_point_interval()` as the center inverse in the `M41` Krawczyk witness.
5. Only then attempt the full interval inclusion
   `K_P(beta) subset interior(beta)`.

## Acceptance rule

`M41` must remain rejected until all of the following are true on the same dyadic box:

- squarefree polynomial `P41` is used;
- `P41(beta)` and `P41'(beta)` are evaluated with rational interval arithmetic;
- `A` is obtained from exact rational point evaluation and quadrance inverse;
- Krawczyk image is strictly inside `beta`;
- all forbidden collision intervals for horizon `H=6` exclude zero on the same `beta`.
