# Canonical Serialization Contract

Status: design contract, not a cryptographic finalization.

This finite-regime project needs stable byte encodings before witness records can be committed into reproducible audit roots. The serialization layer is deliberately separate from the mathematics: it does not prove any Mandelbrot theorem, and it does not turn demo arithmetic into proof-grade arithmetic.

## Core rule

Every certificate-bearing object must serialize from finite data only:

- normalized integers and rationals;
- rank-2 coordinate records;
- dyadic boxes;
- rational ray addresses in `Q/Z`;
- vertex/incidence records;
- polynomial coefficient arrays;
- witness status records;
- theorem-tag identifiers.

No analytic singleton, measured angle, transcendental value, floating approximation, or implementation object identity may enter serialization.

## Version envelope

Every serialized record has this logical shape:

```text
SERIAL_V1(
  domain_tag,
  schema_version,
  field_count,
  ordered_fields
)
```

Field order is part of the schema. Map/dictionary iteration order is forbidden. Variable-length lists must include length before items.

## Primitive encodings

### Integer

```text
Z(sign, byte_len, big_endian_magnitude)
```

The concrete Mojo encoding is one sign byte (`0` zero, `1` positive, `2`
negative), followed by an unsigned 8-byte big-endian `byte_len`, followed by
exactly that many magnitude bytes. Zero has an empty magnitude. Nonzero
magnitudes use a minimal big-endian magnitude with no leading zero byte.

Golden vectors (hexadecimal):

```text
0           -> 00 0000000000000000
1           -> 01 0000000000000001 01
-1000000001 -> 02 0000000000000004 3b9aca01
```

### Rational

```text
Q(num: Z, den: Z)
```

The denominator must be strictly positive. The pair must be gcd-normalized. There is exactly one encoding for each rational.

### Rank-2 coordinate record

```text
Coord2(x: Q, y: Q)
```

This is not an analytic complex point. It is a finite coordinate record with the multiplication law

```text
(x,y) star (u,v) = (xu-yv, xv+yu)
```

### Dyadic box

```text
Box2(x_lo: Q, x_hi: Q, y_lo: Q, y_hi: Q)
```

Require `x_lo <= x_hi` and `y_lo <= y_hi`.

### Ray address

```text
RayAddr(num: Z, den: Z)
```

Require `den > 0`, `0 <= num < den`, and gcd-normalization.

### Vertex

```text
Vertex(tag: UTF8, id: UTF8)
```

### PointVertex

```text
PointVertex(name: UTF8, carrier: VertexSet)
```

A `PointVertex` is the only allowed finite meaning of point: a vertex whose carrier is a finite set of vertices.

## Certificate records

A Misiurewicz certificate serializes as ordered fields:

1. certificate schema id;
2. arithmetic backend manifest digest placeholder;
3. critical orbit type `(ell, k, H)`;
4. squarefree localization polynomial coefficients;
5. dyadic box;
6. Krawczyk witness payload;
7. exact-type exclusion payload;
8. ray-address datum;
9. theorem tags;
10. incidence carrier.

## Hash boundary

The project has not yet selected the final hash suite. Until then, code may compute a debug digest, but no digest is proof-grade unless `backend.toml` marks:

```toml
[hash]
canonical_hash_encoding = true
suite_selected = true
```

and the proof-grade backend gate accepts it.
