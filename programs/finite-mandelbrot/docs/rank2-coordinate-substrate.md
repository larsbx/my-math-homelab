# Rank-2 Coordinate Substrate

In this finite-regime project, a complex-like object is not an analytic or mystical object. It is a rank-2 coordinate record or vertex-data object equipped with the multiplication law

```text
(x, y) star (u, v) = (xu - yv, xv + yu)
```

The multiplication has the same algebraic behavior as ordinary complex multiplication, but the finite core interprets it as polynomial arithmetic over coordinate records, dyadic boxes, root handles, and vertex data.

## Rank-2 ontology rule

At rank 2, the primitive objects are coordinate records and polynomial relations among their coordinates.

The following are not primitive rank-2 objects:

- circle;
- unit circle;
- disk;
- arc;
- circumference;
- analytic point-locus.

The finite core may use the scalar polynomial

```text
Q(x, y) = x^2 + y^2
```

and may use the constraint

```text
Q(x, y) = r
```

as an algebraic condition. It must not reify that condition as a circle at rank 2. A circle-like locus, if ever needed, belongs to a higher incidence/constraint layer, not to the rank-2 coordinate substrate.

## Multiplication as a linear operator

Fix a coordinate record `(u, v)`. Multiplication by `(u, v)` sends any record `(x, y)` to

```text
(xu - yv, xv + yu)
```

Equivalently, it is the matrix action

```text
[ x' ]   [ u  -v ] [ x ]
[ y' ] = [ v   u ] [ y ]
```

So every coordinate record `(u, v)` defines a special 2x2 matrix

```text
M(u, v) = [[u, -v], [v, u]].
```

This is the finite-regime version of scale plus rotor-action.

## Rotor condition

The quadrance is

```text
Q(u, v) = u^2 + v^2.
```

Multiplication scales quadrance by

```text
Q((x, y) star (u, v)) = Q(x, y) Q(u, v).
```

Therefore:

- if `Q(u, v) > 1`, multiplication expands quadrance;
- if `Q(u, v) < 1`, multiplication contracts quadrance;
- if `Q(u, v) = 1`, multiplication preserves quadrance.

The last case is the rotor case. The finite core does not introduce measured angle coordinates, and it does not introduce a unit circle. It says only:

```text
(u, v) is a rotor iff u^2 + v^2 = 1.
```

A rotor is therefore a rational/algebraic pair satisfying a polynomial equation.

## Mandelbrot squaring

The Mandelbrot recurrence is represented as

```text
z_{n+1} = z_n^2 + c.
```

In rank-2 coordinates,

```text
(x, y)^2 = (x^2 - y^2, 2xy).
```

Squaring has two finite algebraic consequences:

1. it squares quadrance:

```text
Q(z^2) = Q(z)^2;
```

2. it doubles symbolic rotor/ray-address structure through the polynomial map

```text
(x, y) -> (x^2 - y^2, 2xy).
```

This is the algebraic reason external ray addresses use symbolic doubling

```text
D(theta) = 2 theta mod 1.
```

Internally, the finite core does not need measured angles. It uses coordinate records, quadrance, spread, determinants, rational ray addresses, and finite doubling of symbolic addresses.

## Correct phrasing

A nonzero rank-2 coordinate record acts as scaling plus rotor-action under multiplication.

A unit-quadrance record acts as a pure rotor.

The Mandelbrot squaring map is the algebraic operation that doubles rotor-address structure.

So complex-like records are not rotations by themselves. They are operators. Some are pure rotors; most are rotor-action plus scaling.

```text
Complex-like pair (u, v) -> linear operator M(u, v)
Q(u, v) = 1 -> rotor
Q(u, v) != 1 -> rotor-action plus scaling
```

All of this is expressible with polynomial arithmetic only.
