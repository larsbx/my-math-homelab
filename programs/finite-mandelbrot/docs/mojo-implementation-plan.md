# Mojo Implementation Plan

This document records the next implementation steps after extracting the finite-regime Mandelbrot computations into Mojo.

The current Mojo layer preserves computation paths and validator control flow. It does **not** yet claim to be a complete proof-carrying verifier. The hardening path is below.

---

## 1. Current committed computation layer

### `kernel/mojo/dynamics/complex_box.mojo`

Preserves:

- rank-2 complex arithmetic;
- critical orbit iteration `Q_{n+1}=Q_n^2+C` numerically;
- pairwise collision values `H_{i,j}=Q_j-Q_i`;
- rectangular complex box placeholder.

### `kernel/mojo/certificates/collision_sets.mojo`

Preserves the corrected semantic collision partition:

\[
\mathcal I_{\ell,k}(H)=\{(i,j): \ell\le i<j\le H,\ k\mid(j-i)\}
\]

and

\[
\mathcal F_{\ell,k}(H)=\{(i,j):0\le i<j\le H\}\setminus\mathcal I_{\ell,k}(H).
\]

### `kernel/mojo/entrypoints/run_examples.mojo`

Preserves:

- `c=-2` smoke-test orbit;
- `M_{4,1}` stress-test orbit;
- expected polynomial factorizations;
- angle/kneading period distinction.

### `kernel/mojo/certificates/validator_plan.mojo`

Preserves validator control flow:

1. build exact orbit polynomials;
2. compute raw return polynomial;
3. squarefree-localize, never gcd-strip forbidden factors;
4. Krawczyk-localize a root on the same box used for exclusions;
5. partition intended equalities and forbidden exclusions;
6. verify exact type pointwise;
7. verify angle datum;
8. bind theorem tags.

---

## 2. Next required module: exact polynomial arithmetic

Create:

```text
kernel/mojo/polynomial/poly_z.mojo
```

Required types:

```text
PolyZ
CoeffZ
Degree
EuclidWitness
SquarefreeWitness
```

Required operations:

```text
zero()
one()
variable_C()
add(p,q)
sub(p,q)
mul(p,q)
derivative(p)
div_rem(p,q)
gcd_with_witness(p,q)
squarefree_with_witness(p)
```

Acceptance tests:

```text
Q_0 = 0
Q_1 = C
Q_2 = C^2+C
Q_3 = C^4+2C^3+C^2+C
R_{2,1}=C^3(C+2)
sqfree(R_{2,1})=C(C+2)
```

For `M_{4,1}`:

```text
R_{4,1}=C^5(C+2)(C^3+2C^2+2C+2)F_7(C)
F_7=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2
```

---

## 3. Next required module: dyadic rational and dyadic complex intervals

Create:

```text
src/dyadic.mojo
src/complex_interval.mojo
```

Required types:

```text
Dyadic
IntervalQ
ComplexInterval
```

Required operations:

```text
add/sub/mul on Dyadic
interval add/sub/mul
complex interval add/sub/mul
contains_zero
interior_contains
box_diameter
```

Critical invariant:

All endpoints must be exact dyadic rationals. No floating point is allowed in certificate validation.

---

## 4. Next required module: Krawczyk verifier

Create:

```text
src/krawczyk.mojo
```

Required inputs:

```text
P: PolyZ
Pprime: PolyZ
beta: ComplexInterval
m: DyadicComplex
A: DyadicComplex
```

Required check:

\[
K(\beta)=m-AP(m)+(1-AP'(\beta))(\beta-m)
\subset \operatorname{int}(\beta).
\]

Acceptance tests:

1. `c=-2` with `P=C(C+2)` and a small box around `-2`.
2. `M_{4,1}` with `P=sqfree(R_{4,1})` and a small dyadic box around the upper root of `F_7`.

---

## 5. Next required module: exact type verifier

Create:

```text
src/exact_type.mojo
```

Required check:

For a claim `(ell,k,H,beta)`:

1. compute all `H_{i,j}=Q_j-Q_i` for `0 <= i < j <= H`;
2. route pairs in `I_{ell,k}(H)` to structural equality;
3. route pairs in `F_{ell,k}(H)` to strict interval exclusion;
4. reject if `0 in H_{i,j}(beta)` for any forbidden pair.

Joint condition:

The same `beta` must satisfy both:

\[
K_P(\beta)\subset\operatorname{int}(\beta)
\]

and

\[
\forall(i,j)\in\mathcal F_{\ell,k}(H),\quad 0\notin H_{i,j}(\beta).
\]

---

## 6. Next required module: rational angle verifier

Create:

```text
src/rational_angles.mojo
```

Required types:

```text
RatAngle
AngleSet
OrbitPortrait
KneadingDatum
```

Required operations:

```text
reduce_fraction
double_angle
iterate_double
cyclic_order
open_cyclic_arc_contains
sets_unlinked
portrait_permutation
kneading_type
```

Correct period rule:

```text
critical orbit type:      (ell,k)
angle preperiod:          lambda = ell - 1
raw ray period:           n
required relation:        k divides n
kneading/orbit period:    k
```

The validator must not require raw ray period `n` to equal critical-orbit period `k`.

Acceptance test:

```text
M_{4,1}
Theta={9/56,11/56,15/56}
lambda=3
n=3
k=1
D^3(Theta)={1/7,2/7,4/7}
D cyclically permutes {1/7,2/7,4/7}
```

---

## 7. Repo-level next actions

1. Implement `poly_z.mojo` first.
2. Add a small generated-output test file for `Q_n` and `R_{ell,k}`.
3. Implement dyadic interval endpoints.
4. Replace all Float64 checks in `complex_box.mojo` with exact dyadic intervals.
5. Implement Krawczyk inclusion.
6. Implement exact-type exclusion over the same box.
7. Implement angle unlinking.
8. Only after those are in place, promote `validator_plan.mojo` into `validator.mojo`.

---

## 8. Do-not-regress rules

- Do not gcd-strip forbidden factors from `R_{ell,k}`.
- Do not claim localization alone proves exact type.
- Do not use different boxes for localization and forbidden-collision exclusion.
- Do not route structural equalities to interval separation.
- Do not require raw ray period to equal critical-orbit period.
- Do not treat the generic boundary case as unconditionally finitely certifiable.
