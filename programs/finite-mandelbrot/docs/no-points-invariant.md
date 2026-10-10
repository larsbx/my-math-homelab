# No-Points Invariant

Status: mandatory design invariant for the finite-regime Mandelbrot project.

## Rule

Inside the finite certificate calculus, **points are not primitive objects**.

A certificate may speak about:

- dyadic boxes;
- singleton dyadic boxes;
- rational coordinate records;
- symbolic external-ray addresses in `Q/Z`;
- algebraic root handles defined by a polynomial plus a localization box;
- theorem-tag referents at analytic binding boundaries.

A certificate must not treat an ideal point of the real or complex plane as directly available.

## Replacements

| Avoid | Use instead |
|---|---|
| point | singleton box, coordinate record, root handle |
| point membership | box containment / root localization |
| exact point evaluation | evaluation at a rational coordinate record, or interval evaluation on a box |
| `c0` as an object | `root_handle(P, beta)` or localized root referent |
| parameter point | parameter box or localized parameter root |
| orbit point | orbit value box or algebraic coordinate record |

## Boundary convention

Named analytic theorem tags may refer to classical points in their external theorem statements, but the finite verifier may only bind to those theorems through finite hypotheses:

```text
squarefree polynomial P
localization box beta
Krawczyk inclusion K(beta) subset interior(beta)
forbidden collision exclusions on beta
rational external-ray address data
```

Thus the theorem tag may say, externally, that the unique classical parameter in `beta` has a trivial fiber. Internally, the verifier only has the localization certificate and box/ray data.

## Coding rule

Core source should avoid `Point` as a type name for finite-regime objects. Prefer:

- `ComplexQ` for rational coordinate records;
- `ComplexIQ` for complex rational interval boxes;
- `RootHandle` for `(polynomial_id, beta_id)` referents;
- `RayAddr` for symbolic external-ray addresses.

Singleton-box constructors are named `singleton(...)` (`IQ.singleton`, `ComplexIQ.singleton`) and rational coordinate constructors `coord(...)`; a constructor named `point(...)` is rejected by `tools/audit_no_points.py`. Their comments must state that no ideal point is being introduced.

## Consequence for Krawczyk

A Krawczyk witness does not certify an ideal point. It certifies:

```text
there exists a unique root of P in beta
```

The root is thereafter referenced by a root handle:

```text
RootHandle(P, beta, witness_id)
```

Every subsequent exact-type exclusion must use the same `beta`, not an assumed point value.
