# Serialization and Hash-Root Handoff

Status: canonical integer encoding implemented; rational and composite layers pending.

The repository now has a canonical serialization contract and Mojo-shaped schema scaffold. This is not yet a proof-grade hash-root layer.

## Current state

Implemented/scaffolded:

- deterministic schema tags;
- ordered record fields;
- finite-only primitive encodings;
- Misiurewicz certificate field order;
- debug serialization gate;
- proof-grade digest gate blocked by backend and hash-suite status.
- bigint-backed canonical integer serialization.

Blocked:

- proof-grade rational normalization;
- selected hash suite;
- theorem-tag stable identifiers;
- byte-level encoder implementation;
- root/digest comparison test vectors.

## Required next implementation

Implemented in `src/bigint_z.mojo`:

```text
Z(sign, byte_len, big_endian_magnitude)
```

The concrete encoding is one sign byte, an unsigned 8-byte big-endian magnitude
length, then the minimal big-endian magnitude. This completes only the integer
primitive; `backend.toml` remains unchanged until all proof consumers migrate.

1. Implement rational encoding:

```text
Q(num, den)
```

with normalized numerator and positive denominator.

2. Implement composite encoders:

```text
Coord2
Box2
RayAddr
Vertex
PointVertex
KrawczykWitness
ExactTypeExclusionWitness
MisiurewiczCertificate
```

5. Select hash suite and add explicit suite id to the backend manifest.
6. Add golden vectors for:

```text
c=-2 smoke certificate
M_4_1 placeholder rejection record
```

7. Only then allow proof-grade digest acceptance.

## Non-regression rules

Do not serialize:

- floats;
- analytic points;
- measured-angle values;
- host object identities;
- unordered maps without schema-defined canonical ordering;
- lower-collision gcd-stripped exact-type projectors.

The finite object remains:

```text
PointVertex({RootHandle, RayAddressSet, DyadicBox})
```

and the rank-2 substrate remains:

```text
Coord2(x,y), star multiplication, quadrance, rotor predicate, symbolic ray addresses.
```
