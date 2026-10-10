# The defining quadratic family and its marked critical orbit

**Status:** authoritative mathematical interface. This document fixes what
object defines the classical Mandelbrot set and how the repository translates
that object into finite certificates. It is not a proof of Mandelbrot local
connectivity.

## 1. The family, not one unparameterized function

The Mandelbrot set is attached to the one-parameter family

```text
f_c(z) = z^2 + c,       c,z in C,
```

together with its marked critical point `z = 0`. The derivative is
`f_c'(z) = 2z`, so zero is the unique finite critical point of every
map in the family. The parameter and the dynamical variable have different
roles and must never be conflated:

| Symbol | Role |
|---|---|
| `c` | parameter selecting one quadratic map |
| `z` | dynamical state inside that selected map |
| `0` | marked critical point whose orbit classifies `c` |
| `n` | iteration depth |

Equivalently, the entire family is the skew-product map

```text
Phi(c,z) = (c, z^2 + c)
```

with marked section

```text
s(c) = (c,0).
```

Iteration preserves the parameter coordinate:

```text
Phi^n(s(c)) = (c, Q_n(c)).
```

## 2. Critical-orbit polynomials

The orbit of the marked critical point is represented by polynomials
in the parameter:

```text
Q_0(C) = 0,
Q_{n+1}(C) = Q_n(C)^2 + C.
```

After evaluation at `C = c`,

```text
Q_n(c) = f_c^n(0).
```

Thus `f_c` acts on the dynamical coordinate, whereas `Q_n` is a polynomial
function on parameter space obtained by iterating the marked section. The
repository's polynomial kernels implement the latter recurrence; they do not
replace the former family.

The first terms are

```text
Q_0(C) = 0,
Q_1(C) = C,
Q_2(C) = C^2 + C,
Q_3(C) = (C^2 + C)^2 + C.
```

## 3. Classical Mandelbrot set

The classical Mandelbrot set is

```text
M = {c in C : the sequence (Q_n(c))_{n >= 0} is bounded}.
```

Equivalently, it is the parameter locus for which the marked critical orbit of
`f_c` does not escape to infinity. For this normalized monic quadratic family,
the standard escape criterion is

```text
c not in M  iff  there exists n with |Q_n(c)| > 2.
```

In rank-2 coordinates `Q_n(c) = (x_n,y_n)`, the same finite witness is

```text
x_n^2 + y_n^2 > 4.
```

The analytic definition uses the Archimedean absolute value and quantifies over
the infinite orbit. A finite `OUT` certificate proves non-membership by one
verified escape witness. Failure to find such a witness at a bounded horizon
does not prove membership.

## 4. Fiberwise projective completion

For each finite parameter `c`, the dynamical map extends to the projective
line by

```text
F_c[X:Z] = [X^2 + c Z^2 : Z^2].
```

The infinity class `[1:0]` is fixed and totally ramified:

```text
F_c^*[infinity] = 2[infinity].
```

This completion is fiberwise over the affine parameter line. It must not be
silently promoted to a regular self-map of an arbitrary compactification of
both parameter and dynamical coordinates: the parameter-infinity fiber needs
a separately specified compactification or moduli construction.

Projective ramification explains the algebraic dynamics at infinity, but the
classical predicate “the critical orbit is bounded” still uses the selected
Archimedean place. Projectivization alone does not turn boundedness into a
purely Zariski-algebraic predicate.

## 5. Finite fields and multisets

Reduction modulo a prime gives

```text
f_bar_c(z) = z^2 + c       over F_p,
Q_bar_n(c) = f_bar_c^n(0).
```

Every affine orbit is eventually periodic, so this reduction has no subset
defined by the classical boundedness predicate: every residue orbit is finite.
Its tail lengths, cycle lengths, basin cardinalities, collision counts,
Frobenius orbits, and divisor multiplicities are arithmetic shadow invariants.

A weighted finite parameter cycle therefore has the form

```text
D_{p,mu} = sum_{c in F_p} mu(c)[c:1],
```

where `mu` must name its semantics. This does not automatically equal the
classical Mandelbrot set with multiplicity, but it is retained as a candidate
bridge object. `docs/multiset-bridge-program.md` gives separate routes for
algebraic root multiplicity, basin cardinality, Frobenius multiplicity,
projective intersection multiplicity, and escape-witness counts.

## 6. Repository type firewall

Implementations and specifications must preserve these type distinctions:

```text
QuadraticFamily       := (c,z) |-> z^2 + c
MarkedSection         := c |-> (c,0)
CriticalOrbitPoly(n)  := C |-> Q_n(C)
ClassicalMandelbrot   := bounded marked-orbit parameter locus over C
FiniteFieldShadow(p)  := functional-graph data over F_p
WeightedShadow(p,mu)  := effective parameter zero-cycle with declared weight
```

No verified general conversion from `FiniteFieldShadow` or `WeightedShadow` to
`ClassicalMandelbrot` is currently registered. Such conversions are theorem
targets, not prohibited constructions; the staged obligations are specified in
`docs/multiset-bridge-program.md`.
