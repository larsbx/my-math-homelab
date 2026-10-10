# BigInt Migration Handoff

## Purpose

The repository retains bounded `Int64` transition/demo paths for negative controls, but the canonical exact rational path now uses the dynamic-limb BigZ backend and normalized BigZ-backed `Q`. Full proof-grade certificate acceptance remains fail-closed until every acceptance-bearing downstream predicate and imported theorem obligation is discharged.

## Non-negotiable invariant

Do not change the certificate semantics to fit the backend.

The backend must satisfy the calculus, not the other way around.

## Required integer backend properties

A certificate-ready backend must provide:

1. unbounded signed integers;
2. exact addition, subtraction, multiplication, and negation;
3. exact order comparison;
4. Euclidean gcd;
5. exact divisibility with rejected non-divisions;
6. deterministic canonical serialization;
7. an explicit `allows_certificate_acceptance=true` gate.

## Required rational backend properties

`Q` must become a normalized fraction over the bigint backend:

```text
Q = num / den
where den > 0 and gcd(abs(num), den) = 1
```

Every constructor and operation must normalize. Equality and order may use cross multiplication only after the bigint backend is active.

## Files that define the gate

- `kernel/mojo/arithmetic/bigint_adapter.mojo`
- `kernel/mojo/arithmetic/rat_backend_plan.mojo`
- `kernel/mojo/arithmetic/cert_backend.mojo`
- `kernel/mojo/certificates/c_minus_2/proof_grade_gate.mojo`
- `tests/test_backend_migration.py`
- `tests/test_proof_grade_gate.py`

## Migration sequence

0. **Retired:** the checked Int64 transition stack (`checked_q.mojo`,
   `checked_interval_q.mojo`, `checked_complex_interval.mojo`,
   `checked_krawczyk_witness.mojo`, `checked_interval_exclusion.mojo`,
   `certificate_arithmetic_migration_gate.mojo`, and the checked c=-2
   `checked_landing_target_adapter.mojo` and `checked_finite_certificate_gate.mojo`)
   carried the c=-2 certificates at bounded width while the integer backend was
   migrated. Each is replayed exactly by the BigZ/Q path (steps 1 to 5), which
   is the certificate of record, so the stack is deleted. The acceptance-bearing
   successor `kernel/mojo/certificates/c_minus_2/proof_grade_landing_target_association.mojo`
   identifies the target with exact BigZ/Q ray replay, exact BigZ replay of
   `R_{2,1}=C^3(C+2)`, lower-type exclusion of `C=0`, exact type-`(2,1)`
   verification at `C=-2`, and the canonical checked rational-ray theorem
   import record. `kernel/mojo/arithmetic/checked_int64_backend.mojo` and the
   address primitives of `kernel/mojo/dynamics/checked_ray_address.mojo` are
   deleted too: the kneading and tuning kernels that imported them now use the
   vendored `rational_dynamics` doubling over BigZ.
1. **Selected:** Mojo-native dynamic base-`10^9` limbs in `vendor/mojo/finite_exact/bigint_z.mojo`.
2. **Complete:** the integer layer implements unbounded signed storage, exact
   add/sub/mul/order, quotient/remainder, rejected non-divisions, Euclidean gcd,
   and canonical `Z(sign, byte_len, big_endian_magnitude)` serialization.
3. **Complete:** `Q` stores normalized `BigZ` numerator and denominator values while preserving its public arithmetic names; invalid denominators and division by zero propagate rejection.
4. **Complete (arithmetic hardening):** the public boundary of `BigZ`, `Q`, `IQ`, and `ComplexIQ` is declared in `docs/exact-arithmetic-public-boundary.md`; long division replaces shift-and-subtract; `Q` cancels before multiplying and comparing; the randomized property probe runs against the Python oracle in CI.
5. **Complete for the c=-2 replay path:** interval arithmetic, exact-type
   exclusions, rational ray-address replay, and the proof-grade landing-target
   association now execute on the BigZ/Q path.
6. **Next theorem boundary:** validate the class-specific Misiurewicz
   trivial-fiber import for the exact type-`(2,1)` `c=-2` instance.
7. Keep complete certificate acceptance fail-closed until that theorem import,
   incidence serialization/replay requirements, and every remaining
   acceptance-bearing gate are satisfied.

## Forbidden shortcuts

Do not use:

- bounded integer overflow assumptions;
- floating approximations;
- analytic trigonometry;
- analytic point membership;
- lower-factor gcd stripping for exact type.

The accepted pipeline remains:

```text
squarefree localization
+ same-box forbidden collision exclusions
+ rational ray-address combinatorics
+ theorem tags
+ PointVertex incidence packaging
+ proof-grade bigint/rational backend
```
