# M_{4,1} Native Interval Handoff

Status: implementation handoff.

The native interval evaluator in `kernel/mojo/dynamics/interval_orbit.mojo` now computes the critical-orbit recurrence and forbidden-collision exclusions over `ComplexIQ` for fixed horizons. The `c=-2` smoke test is wired to the native evaluator. The `M_{4,1}` status is still a contract placeholder and must not be treated as a completed proof witness.

## Target

Replace the placeholder in `demo_m41_status()` with a real call:

```text
verify_exact_type_exclusions_h6(m41_box(), 4, 1)
```

where `m41_box()` is a dyadic complex interval enclosing the upper root of

```text
F_7(C) = C^7 + 4C^6 + 6C^5 + 6C^4 + 6C^3 + 4C^2 + 2C + 2
```

near

```text
-0.10109636384562216 + 0.95628651080914150 i
```

## Required invariants

The same box must satisfy both:

```text
K_P(beta) subset interior(beta)
```

for the squarefree localization polynomial

```text
P_{4,1} = C(C+2)(C^3+2C^2+2C+2)F_7(C)
```

and

```text
0 notin Q_j(beta) - Q_i(beta)
```

for every forbidden pair in `F_{4,1}(6)`.

For `ell=4`, `period=1`, `horizon=6`, the intended equality set is:

```text
{(4,5), (4,6), (5,6)}
```

and the forbidden set has 18 pairs.

## Acceptance

The replacement is accepted only when:

1. `demo_m41_status()` calls the native interval verifier.
2. The returned status reports `excluded_forbidden_count == forbidden_count == 18`.
3. The placeholder warning is removed from `demo_m41_status()`.
4. A separate note records the dyadic endpoints of `m41_box()`.
5. No float, analytic trig, or geometric angle primitives are introduced.

## Current dependency blocker

`rat_q.mojo` remains backed by `Int64`, so large boxes and deep orbit intervals are not certificate-ready. The implementation may use small dyadic denominators for scaffolding, but proof-grade acceptance requires the bigint backend described in `kernel/mojo/arithmetic/big_int_boundary.mojo`.
