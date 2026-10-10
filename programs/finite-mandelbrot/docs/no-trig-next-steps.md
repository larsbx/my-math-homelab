# No-Trig / Rational-Trig Next Steps

## Decision

The finite-regime Mandelbrot implementation must not use analytic circular functions in core code.

External-ray data stays symbolic:

```text
theta in Q/Z
D(theta) = 2 theta mod 1
```

Geometric comparison uses rational trigonometry:

```text
quadrance(v) = x^2 + y^2
spread(a,b) = det(a,b)^2 / (quadrance(a) quadrance(b))
dot_ratio(a,b) = dot(a,b)^2 / (quadrance(a) quadrance(b))
```

Rotors are algebraic pairs `(c,s)` satisfying:

```text
c^2 + s^2 = 1
```

The symbols are coordinates, not functions.

## Implementation sequence

1. Normalize `Rat` by gcd and sign convention.
2. Replace `Int64` with the chosen bigint backend.
3. Add exact equality for rationals by cross multiplication.
4. Add interval versions of quadrance and spread.
5. Route all visual/geometric tests through quadrance/spread, never through angular measurement.
6. Keep rational external angles separate from measured geometry.
7. Run `tools/audit_no_trig.py` in CI.

## Acceptance

A patch passes this invariant only if:

- no core source file calls analytic circular functions;
- no core source file converts to radians/degrees;
- no core verifier result depends on angle measurement;
- parameter-ray combinatorics use only rational arithmetic on `Q/Z`;
- geometry uses only quadrance, spread, determinant, dot product, and algebraic rotor coordinates.
