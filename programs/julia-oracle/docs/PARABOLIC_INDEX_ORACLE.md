# Quadratic parabolic-index oracle

**Status:** pre-registration exact oracle slice.

This module independently recomputes a finite coefficient invariant of the
quadratic germ

```text
g_lambda(w) = lambda*w + w^2
```

when `lambda` is exactly representable in `Q(i)` and satisfies
`lambda^q = 1`.

It forms the truncated iterate exactly, factors the known `w^(q+1)`
vanishing order from

```text
w - g_lambda^q(w),
```

and returns the coefficient `[w^q] 1/P(w)` where

```text
w - g_lambda^q(w) = w^(q+1) P(w).
```

The implementation uses only `BigInt`, `Rational{BigInt}`, and exact
Gaussian-rational coordinate arithmetic.  It has no dependency on numerical
root finding, FFTs, ball arithmetic, trigonometric functions, or complex
floating point.

## Initial fixtures

The first lane pins four values:

```text
q=1, lambda=1     -> 0
q=2, lambda=-1    -> 1/8
q=4, lambda=i     -> (1447 - 365 i)/4624
q=4, lambda=-i    -> (1447 + 365 i)/4624
```

These are deliberately low-q values because they lie entirely in `Q(i)`.
General `p/q` belongs to a cyclotomic extension and is outside this v1
oracle.

## Result vocabulary

`compare_fixture` returns only the estate-standard oracle outcomes:

- `agrees`
- `disagrees`
- `oracle_error`

The module does not expose `accepted`, `proved`, or any certificate verdict.

## Registration gate

This slice is intentionally **not yet added to the shared oracle registry**.
Registry binding waits for the domain-owned exact contract/checker boundary to
merge first.  That prevents the Julia lab from inventing claim ownership or a
checker identity merely because it can independently recompute a value.

Once the consumer contract is pinned, the registry entry should bind to that
claim and checker revision and retain Julia as differential evidence only.
