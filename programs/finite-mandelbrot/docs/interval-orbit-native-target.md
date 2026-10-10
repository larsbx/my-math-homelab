# Native Interval Orbit Target

Status: implementation target, not yet proof-grade code.

This note defines the next concrete coding task after the Python interval-exclusion oracle.

## Goal

Replace `reference/python/interval/interval_exclusion_reference.py` with a Mojo-native evaluator that uses only normalized rational endpoints and interval arithmetic.

The target file is:

- `kernel/mojo/dynamics/interval_orbit.mojo`

It must consume the rational interval primitives in:

- `src/rat_q.mojo`
- `src/interval_q.mojo`

## Required functions

```text
build_interval_orbit(c_box, horizon) -> orbit
collision_interval(orbit, i, j) -> complex_interval
excludes_zero(complex_interval) -> Bool
verify_exact_type_exclusions(c_box, ell, period, horizon) -> IntervalOrbitStatus
```

## Recurrence

The evaluator must implement the interval form of the critical orbit recurrence:

```text
Q[0] = 0
Q[n+1] = Q[n]^2 + c_box
```

For complex interval boxes, multiplication is rank-2 polynomial multiplication with interval endpoints.

## Exact-type rule

For every pair `0 <= i < j <= horizon`, route it as follows:

```text
if i >= ell and (j - i) % period == 0:
    structural equality
else:
    forbidden exclusion
```

Only forbidden exclusions are checked by interval zero exclusion.

Structural equalities must never be checked by sign/zero separation.

## Same-box invariant

The verifier must reject any witness that localizes the squarefree return polynomial on one box but checks forbidden collision exclusions on another.

One box means literally the same dyadic complex interval object or a cryptographic/object identity reference to it once the witness format exists.

## No analytic geometry

The evaluator must not use:

- floating point
- measured geometric angle APIs
- analytic trigonometric functions
- transcendental functions
- numerical root finders without rational certificate output

Allowed primitives:

- integer arithmetic
- rational arithmetic
- interval arithmetic over rationals
- polynomial recurrence
- rational ray-address doubling in `Q/Z`

## Acceptance tests

The native evaluator must match the current Python reference oracle:

- `c=-2`, `(ell, period, horizon) = (2, 1, 3)`: `5/5` forbidden exclusions.
- `M_{4,1}`, `(ell, period, horizon) = (4, 1, 6)`: `18/18` forbidden exclusions.

The native evaluator must also pass the no-trig audit.

## Deletion criterion for Python oracle

`reference/python/interval/interval_exclusion_reference.py` may be demoted to historical reference only after the Mojo-native evaluator:

1. uses proof-grade arbitrary-precision rationals;
2. evaluates the interval recurrence exactly;
3. verifies all forbidden exclusions on the same box;
4. reproduces both reference counts;
5. passes CI without any analytic-trig tokens in core source.
