# Rational Trigonometry Policy

Status: binding implementation rule for the finite-regime Mandelbrot project.

## Hard constraint

The core verifier and generator must not depend on analytic trigonometry.

Forbidden in core code:

- `sin`
- `cos`
- `tan`
- `asin`
- `acos`
- `atan`
- degree/radian conversion
- unit-circle APIs
- polar-angle recovery
- transcendental smooth-coloring formulas

The project may mention these only in historical/literature notes or in explicitly quarantined comparison sections.

## Replacement vocabulary

Use rational trigonometry and finite algebraic invariants.

### Quadrance

For a vector `v=(x,y)`, use

```text
Q(v) = x^2 + y^2
```

This replaces squared length. No square root is needed.

### Spread

For two nonzero vectors `a,b`, use

```text
s(a,b) = det(a,b)^2 / (Q(a) Q(b))
```

where

```text
det(a,b) = a_x b_y - a_y b_x
```

This replaces the squared angular separation invariant. No angle is computed.

### Dot-ratio

When the complementary invariant is needed, use

```text
d(a,b) = dot(a,b)^2 / (Q(a) Q(b))
```

with

```text
dot(a,b) = a_x b_x + a_y b_y
```

For nonzero vectors over characteristic not equal to two, the algebraic identity is

```text
spread(a,b) + dot_ratio(a,b) = 1
```

provided the same quadratic form is used.

### Rotors

When a rotation-like action is needed, represent it by an algebraic pair `(c,s)` satisfying

```text
c^2 + s^2 = 1
```

The symbols `c` and `s` are coordinates only. They are not calls to cosine or sine.

The action on a vector is

```text
(x,y) -> (x c - y s, x s + y c)
```

This is permitted because it is polynomial arithmetic.

### External angles

External ray angles remain symbolic elements of `Q/Z`.

The only primitive operation on them is the doubling map

```text
D(theta) = 2 theta mod 1
```

No geometric angle measurement is allowed.

## Mandelbrot-specific consequences

The critical orbit layer uses only

```text
Q_0(C)=0
Q_{n+1}(C)=Q_n(C)^2+C
R_{ell,k}(C)=Q_{ell+k}(C)-Q_ell(C)
P_{ell,k}(C)=sqfree(R_{ell,k}(C))
```

The separation and landing layer uses only rational-angle combinatorics:

```text
theta in Q/Z
D(theta)=2theta mod 1
cyclic order on Q/Z
finite unlinking checks
kneading words
```

The interval/certificate layer uses only dyadic rational bounds:

```text
K_P(beta) subset int(beta)
0 notin H_{i,j}(beta)
```

## Agent rule

Any coding agent that introduces trigonometric functions into `kernel/` must treat that as a blocking invariant violation unless the file is explicitly marked as a non-core comparison artifact.

Acceptable replacements are:

- quadrance instead of length;
- spread instead of angle/sine;
- dot-ratio instead of cosine;
- rational rotors instead of angle-parametrized rotations;
- rational doubling instead of analytic ray-angle geometry.
