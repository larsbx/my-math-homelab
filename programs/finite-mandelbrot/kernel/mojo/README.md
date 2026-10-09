# Implementation Notes

Prototype implementation will go here after the certificate grammar stabilizes.

## Required modules

```text
poly/        integer polynomial recurrence and Euclidean witnesses
interval/    dyadic rational and dyadic complex interval arithmetic
krawczyk/    complex Krawczyk inclusion checker
orbit/       collision-set enumeration and exact-type checks
angles/      rational-angle dynamics, kneading, unlinking
cert/        certificate parser and validator
render/      optional three-valued renderer bridge
```

## Non-goals for implementation

- no floating-point-trusted conclusions;
- no generic boundary completeness claim;
- no theorem proving of Douady-Hubbard/Schleicher analytic results inside this verifier.

The verifier checks finite hypotheses and imports analytic conclusions only through explicit theorem tags.
