# Backend Selection Handoff

Status: Mojo-native dynamic-limb integer backend complete; proof-grade
certificates remain blocked pending rational and consumer migration.

The repository now separates demo arithmetic from certificate arithmetic.

## Current state

`Int64DemoBackend` is allowed for small smoke tests only. It must never enable proof-grade acceptance, because the verifier requires unbounded exact arithmetic for:

- normalized rational endpoints;
- polynomial coefficients in `Z[C]`;
- Euclidean gcd and squarefree witnesses;
- exact divisibility checks;
- interval endpoint comparison;
- deterministic serialization of certificate data.

## Required backend contract

A proof backend must satisfy the `CertIntBackend` fields:

```text
unbounded_storage = true
exact_add_sub_mul = true
exact_order = true
euclidean_gcd = true
exact_divisibility = true
normalized_serialization = true
```

Only then may `BackendGate.allows_certificate_acceptance` be true.

## Selected path

The repository uses a Mojo-native, little-endian dynamic-limb representation
with base `10^9`. `src/bigint_z.mojo` implements canonical signed storage,
construction from every `Int64`, exact addition, subtraction, multiplication,
equality, order, quotient/remainder, rejected non-divisions, Euclidean gcd, and
canonical integer serialization. The byte encoding is a sign code (`0`, `1`,
or `2`), an unsigned 8-byte big-endian magnitude length, and a minimal
big-endian magnitude. Its dynamic `List[UInt64]` storage is not limited to an
`Int64` magnitude.

The integer capability record is ready for rational migration. Repository
certificate acceptance remains false because `Q`, interval consumers, and
composite serialization do not yet use this backend. Python remains a reference
oracle, not the finite certificate engine.

## Regression rules

Do not:

- mark `Int64DemoBackend` certificate-ready;
- allow `M_{4,1}` proof-grade acceptance before Krawczyk, exact-type exclusions, theorem tags, and incidence all pass on a proof backend;
- replace rational interval endpoints with floats;
- introduce analytic trig or analytic point primitives.

## Next implementation target

Replace the `Q`/`Rat` storage layer with normalized `BigZ` integers while
preserving existing public operations:

```text
add/sub/mul/div/square/eq/lt/le/gcd/normalize
```

After that, promote:

1. `SquarefreeWitness` from contract to executable witness.
2. `CoordRecord` evaluation for `P'_{4,1}` from pending to computed.
3. `M_{4,1}` Krawczyk from placeholder to computed inclusion.
