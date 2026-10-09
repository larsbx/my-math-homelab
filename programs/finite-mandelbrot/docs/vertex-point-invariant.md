# Vertex-Point Invariant

Status: normative correction

## Correction

The finite regime does not ban the word `point` absolutely. It bans the
analytic singleton meaning of point.

In this project, a point is admissible only as a finite incidence object:

```text
Point := Vertex(vertices)
```

That is: a point is a vertex of vertices, not an element of a completed real or
complex continuum.

## Allowed meanings

Allowed finite meanings:

- `Vertex`: an addressable finite incidence atom.
- `VertexSet`: a finite collection of vertices.
- `PointVertex`: a derived vertex whose payload is a finite set/list of lower
  vertices.
- `RootHandle`: a finite certificate handle naming an isolated algebraic root by
  polynomial plus box, not by analytic evaluation.
- `SingletonBox`: a degenerate rational box used as an input record, not a
  continuum point.

## Forbidden meanings

Forbidden in certificate core:

- point as an arbitrary member of R, C, or a topological continuum;
- point-membership as a primitive predicate;
- pointwise analytic evaluation as an oracle;
- limit point language inside finite certificates;
- generic boundary point as a finite object.

## Practical rewrite rule

When a proof step wants to say `point`, ask which finite carrier is meant:

```text
analytic point        -> forbidden
coordinate record     -> CoordRecord
singleton coordinate  -> SingletonBox
isolated root         -> RootHandle(poly, box, witness)
ray landing target    -> theorem-tag referent
incidence point       -> PointVertex(vertices)
```

## Consequence for the Mandelbrot certificate calculus

For Misiurewicz certificates, the finite core never manipulates the analytic
parameter point directly. It manipulates:

```text
RootHandle(P_l_k, beta, KrawczykWitness)
```

and, when incidence language is useful, wraps that handle as a vertex:

```text
PointVertex([RootHandleVertex, RayAddressVertexSet, BoxVertex])
```

The analytic assertion that this referent is a landing target or has a trivial
fiber remains outside the core and is discharged only by theorem tags.

## Policy

The old phrase `points are undefined` is replaced by:

```text
Analytic points are undefined in the finite core.
A point may exist only as a vertex of vertices.
```
