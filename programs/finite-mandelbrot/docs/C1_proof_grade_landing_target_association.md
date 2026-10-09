# Proof-grade landing-target association

Status: successor slice to PR #19 source-scope checks.

## Scope

This slice discharges the narrow c=-2 landing-target association used by the
`RationalParameterRayLanding` theorem-tag payload:

```text
address 1/2
  -- exact BigZ/Q doubling -->
preperiod 1, period 1
  -- imported rational parameter-ray correspondence -->
critical-orbit type (ell, period) = (2, 1)
  -- exact BigZ coefficient replay -->
R_{2,1}(C) = Q_3(C) - Q_2(C) = C^3(C+2)
  -- lower-type exclusion -->
C = 0 is not exact type (2, 1)
  -- exact orbit check -->
C = -2 has orbit 0 -> -2 -> 2 -> 2
```

Therefore the unique exact-type target compatible with the imported
correspondence is `c=-2`.

> Since retired: the checked Int64 localization, ray-address orbit and landing adapter named below were deleted; the source-scope checks now consume the BigZ/Q replay (`certificates/c_minus_2/bigq_landing_target_adapter.mojo`), which reproduces their verdicts exactly. See `docs/rational-interval-arithmetic-spec.md` 6.2.

## What changed from the checked-width adapter

The previous `checked_landing_target_adapter.mojo` correctly established a
bounded-width association but made proof-grade status depend on
`CheckedLocalizationEnvelope.proof_grade_accepted()`.

That dependency is unnecessary for this particular association. The target can
be identified algebraically:

- the ray-address orbit is replayed with normalized BigZ-backed `Q`;
- the critical-orbit recurrence is replayed symbolically over BigZ
  coefficients through degree four;
- the raw relation is checked exactly as `C^3(C+2)`;
- `C=0` is checked as lower type;
- `C=-2` is checked directly as exact type `(2,1)`.

No Krawczyk box or fixed-width interval arithmetic participates in the
proof-grade association predicate.

## Imported theorem boundary

The analytic statement that a strictly preperiodic rational parameter ray lands
at a Misiurewicz parameter with the stated preperiod/period correspondence is
not reproved internally.

The proof object therefore carries an explicit checked import record with:

- source key `SchleicherRationalParameterRays`;
- source title `Rational Parameter Rays of the Mandelbrot Set`;
- covered class `preperiodic rational parameter rays`;
- conclusion kind `RationalParameterRayLanding`;
- local landing strength only;
- source-specific assumption payload;
- preperiod offset `+1`;
- period preservation;
- explicit strictly-preperiodic coverage.

The import is accepted only through the existing theorem-tag ledger and payload
validators. A citation string alone remains insufficient.

## Negative controls

The compiled smoke path rejects:

- the same algebra with target `c=-1`;
- the same target with the wrong source key.

These controls prevent the association from collapsing into a name-only or
target-label-only acceptance rule.

## Resulting theorem-tag status

For the checked `c=-2` path:

```text
RationalParameterRayLanding:
  source scope checked          yes
  proof-grade target associated yes
  final import admissible       yes

Misiurewicz trivial fiber:
  source scope checked          yes
  final import admissible       no
```

The second import remains fail-closed.

## Non-goals

This slice does not prove:

- Misiurewicz fiber triviality internally;
- generic MLC;
- all-fiber triviality;
- `ResidualClosureNoMissingLinks`;
- C1.

It also does not promote bounded search, renderer evidence, Krawczyk
localization, or fixed-width arithmetic to proof-grade evidence.

## Next target

```text
ProofGradeMisiurewiczTrivialFiberClassification
```

That slice should attach and validate the class-specific trivial-fiber theorem
for the now exact type-`(2,1)` parameter without weakening any global
frontier.

## Successor status

The successor classification is now implemented in
`kernel/mojo/certificates/c_minus_2/proof_grade_misiurewicz_trivial_fiber_classification.mojo`. It binds the
checked Schleicher class-specific import to the proof-grade `c=-2`, exact
type-`(2,1)` witness and rejects wrong target, type, source, and payload-kind
controls. Its global-boundary predicates remain hard-false.
