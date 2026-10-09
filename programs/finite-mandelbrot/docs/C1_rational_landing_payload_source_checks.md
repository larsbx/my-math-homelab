# Rational landing payload source checks

Status: PR #19 baseline; source-scope slice completed before the proof-grade successor.

This document records the narrow purpose of branch `c1/rational-landing-payload-source-checks` in the canonical repository `larsbx/finite-mandelbrot-research`.

> Since retired: the checked Int64 localization, ray-address orbit and landing adapter named below were deleted; the source-scope checks now consume the BigZ/Q replay (`certificates/c_minus_2/bigq_landing_target_adapter.mojo`), which reproduces their verdicts exactly. See `docs/rational-interval-arithmetic-spec.md` 6.2.

## Purpose

The repository already has theorem-tag payload instances for the checked `c=-2` path:

- rational parameter-ray landing for address `1/2`;
- Misiurewicz trivial-fiber import for critical orbit type `(ell, period) = (2, 1)`;
- finite localization and ray-address checks routed through Mojo smoke tests.

This slice makes the source-scope status explicit:

```text
source-scope checked     yes
proof-grade final import no
```

The distinction matters. A source-scoped payload may verify that the tag, covered class, address data, and finite localization data line up with the intended theorem family. It still must not become final proof evidence until the parameter association and proof-grade classification are accepted.

## Accepted source-scope checks

For `RationalParameterRayLanding`, the source-scope check requires:

- citation key `SchleicherRationalParameterRays`;
- covered class `preperiodic rational parameter rays`;
- finite ray-address orbit for `1/2` with preperiod `1` and period `1`;
- landing box name `beta_c_minus_2`;
- checked-width landing-target association;
- explicit exclusion of generic boundary use.

For the Misiurewicz trivial-fiber import, the source-scope check requires:

- citation key `SchleicherFibersLC`;
- covered class `Misiurewicz parameters`;
- checked-width localization at `beta_c_minus_2`;
- critical orbit type `(ell, period) = (2, 1)`;
- explicit exclusion of generic boundary use.

## Non-goals

This slice does not claim:

- the priority conjecture;
- generic MLC;
- all-fiber triviality;
- residual closure;
- proof-grade final import admissibility.

It also does not make bounded search, renderer output, or generic theorem tags admissible as final evidence.

## Next target

After this slice, the next concrete bottleneck is:

```text
ProofGradeLandingTargetAssociation
```

That target must upgrade the checked-width landing-target association to a proof-grade association, or preserve a precise reason why the import remains non-final.


## Successor status

The stacked successor `c1/proof-grade-landing-target-association` now
discharges the rational landing-target association without changing the
historical claim made by this document:

```text
PR #19 source-scope baseline
  rational landing source scope     checked
  rational landing final import     fail-closed

successor proof-grade association
  exact BigZ/Q target association   accepted
  rational landing final import     admissible
  Misiurewicz trivial-fiber import  fail-closed
```

The proof-grade landing path no longer depends on the checked-width localization
gate for final admissibility. It uses exact BigZ/Q ray-address replay, exact
BigZ coefficient replay of `R_{2,1}=C^3(C+2)`, lower-type exclusion of
`C=0`, an exact type-`(2,1)` check at `C=-2`, and the canonical checked
rational-ray theorem import record.

The next concrete bottleneck after the successor is:

```text
ProofGradeMisiurewiczTrivialFiberClassification
```
