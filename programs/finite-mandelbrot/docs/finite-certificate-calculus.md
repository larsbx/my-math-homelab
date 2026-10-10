# Finite Certificate Calculus for Mandelbrot Landing

## 1. Scope

This document specifies the finite certificate layer for algebraic Mandelbrot boundary anchors, especially Misiurewicz points.

The verifier uses only:

- integer polynomial arithmetic;
- rational/dyadic interval arithmetic;
- rational order comparisons;
- finite symbolic dynamics on rational angles.

Analytic facts enter only as named theorem tags.

## 2. Primary substrate

Let `C` be a formal variable. Define critical-orbit polynomials

```text
Q_0(C) = 0
Q_{n+1}(C) = Q_n(C)^2 + C
```

so `Q_n(C) in Z[C]`.

For claimed critical-orbit preperiod `l >= 1` and period `k >= 1`, define

```text
R_{l,k}(C) = Q_{l+k}(C) - Q_l(C)
P_{l,k}(C) = sqfree(R_{l,k}(C))
```

The verifier localizes roots of `P_{l,k}`, not globally gcd-stripped exact-type factors.

## 3. Why squarefree remains canonical

Exact critical-orbit type is constant on each irreducible factor over `Q`.
Indeed, for every fixed collision pair `(i,j)`, the equality
`Q_i(c) = Q_j(c)` is a rational polynomial identity and is therefore constant
on the Galois orbit of `c`. The complete collision pattern, and hence its
minimal preperiod and period, is constant on that factor. See
`docs/cross-program-bridge-psc-nlapjt-2026-09-12.md`, section C1, for the
elementary proof and exact low-horizon checks.

Consequently, gcd filtering against strictly lower collision relations can be
mathematically sound; the former contrary Galois rationale was false. This
calculus nevertheless keeps squarefree localization followed by pointwise
same-box exclusions as its canonical verifier policy. That route is
conservative, directly witnesses the claimed isolated root's exact type, and
does not require a separate factor-classification certificate.

The sound method is:

1. squarefree the raw relation;
2. isolate a single root in a dyadic complex box;
3. prove exact type pointwise using interval exclusions on that same box.

## 4. Dyadic complex boxes

A dyadic complex box is

```text
beta = [a-, a+] + i[b-, b+]
```

with dyadic rational endpoints.

The rank-2 presentation of multiplication is

```text
(x,y) * (u,v) = (xu - yv, xv + yu)
```

This is a presentation of the formal complex arithmetic, not a primitive appeal to analytic complex numbers.

## 5. Krawczyk localization

For `P(C) = P_{l,k}(C)`, center `m in beta`, and approximate inverse `A ~ 1/P'(m)`, define

```text
K(beta) = m - A P(m) + (1 - A P'(beta))(beta - m)
```

A localization witness proves

```text
K(beta) subset int(beta)
```

using rational interval arithmetic.

This proves that `P` has a unique zero `c0` in `beta`. Since `P | R`, it also proves the intended return

```text
Q_{l+k}(c0) = Q_l(c0).
```

It does not yet prove exact type.

## 6. Intended and forbidden collision sets

Choose a finite horizon `H >= l + k`.

The intended equality set is

```text
I_{l,k}(H) = {(i,j): 0 <= i < j <= H, i >= l, (j - i) mod k = 0}
```

The forbidden set is the complement

```text
F_{l,k}(H) = {(i,j): 0 <= i < j <= H} \ I_{l,k}(H).
```

For each pair define

```text
H_{i,j}(C) = Q_j(C) - Q_i(C).
```

Pairs in `I` are structural equalities. Pairs in `F` are strict exclusions.

At the minimal horizon `H = l + k`, the only intended pair is `(l, l+k)`. At larger horizons, later periodic-tail equalities are also intended and must not be forbidden.

## 7. Joint box witness

After squarefree localization, `W_loc` and `W_exact` are coupled through the same box.

A valid box witness is

```text
W_box(beta):
  K_{P_{l,k}}(beta) subset int(beta)
  and
  for all (i,j) in F_{l,k}(H), 0 notin H_{i,j}(beta)
```

The same dyadic box must simultaneously:

1. isolate a unique zero of `P_{l,k}`;
2. exclude every forbidden collision polynomial.

Completeness rests on the existence of a sufficiently small box around the exact point satisfying both requirements.

## 8. Equality/inequality routing

The validator must route every orbit statement to exactly one block.

### Structural equality block

If `(i,j) in I_{l,k}(H)`, prove `Q_i(c0) = Q_j(c0)` from the intended return and forward iteration.

Do not attempt interval separation.

### Strict inequality block

If `(i,j) in F_{l,k}(H)`, prove

```text
0 notin Q_j(beta) - Q_i(beta)
```

using rational interval arithmetic.

If a strict interval contains zero, the certificate fails at the current box.

## 9. Angle data

Let the critical-orbit type be `(l,k)`. The parameter-angle/kneading preperiod is

```text
lambda = l - 1.
```

The raw external ray period `n` can be a multiple of `k`, not necessarily equal to `k`.

The angle certificate records:

```text
critical orbit type:      (l,k)
angle preperiod:          lambda = l - 1
raw ray period:           n
condition:                k divides n
kneading/orbit period:    k
```

The matching rule compares critical type `(l,k)` with kneading type `(lambda,k)`, not with raw angle type `(lambda,k)`.

## 10. Theorem tags

The verifier accepts named analytic theorem tags:

- `RationalRayLanding`: rational parameter rays land with the verified combinatorics;
- `MisiurewiczFiberTriviality`: fibers are trivial at Misiurewicz parameters.

A third fact, `MisiurewiczReducedRootSimplicity`, is a completeness dependency: it guarantees arbitrarily small Krawczyk witnesses exist after squarefree localization. It is not needed to validate a completed certificate, because the completed certificate already contains the Krawczyk witness.

## 11. Inference rule

```text
W_sqf:       P_{l,k} = sqfree(R_{l,k})
W_box:       K_P(beta) subset int(beta) and all forbidden H_{i,j}(beta) exclude 0
W_comb:      rational angle data valid
W_match:     angle/kneading data matches exact orbit type
T_ray:       RationalRayLanding
T_fib:       MisiurewiczFiberTriviality
---------------------------------------------------------------
MisTriv(c0, Theta, beta)
```

The conclusion expands to:

```text
c0 in beta
Q_{l+k}(c0) = Q_l(c0)
type(c0) = (l,k)
parameter rays at Theta land at c0
Fib(c0) = {c0}
```

## 12. Generic boundary boundary

This certificate does not decide generic boundary landing.

For generic boundary vertices, the honest object is an infinite stream of finite nested certificates. Singleton stabilization of all such nests holds if and only if every Mandelbrot fiber is trivial and, under Schleicher's fiber framework, if and only if MLC holds.
