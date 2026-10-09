# Coordinate-record evaluation handoff

## Purpose

The finite-regime calculus must not use analytic point primitives. The next native Krawczyk milestone still needs evaluation of `P_4_1` and `dP_4_1`, but that evaluation must be phrased as coordinate-record evaluation or singleton-box evaluation.

## Current status

`kernel/mojo/arithmetic/coord_record_eval.mojo` now provides:

- `ComplexQ` coordinate-record arithmetic through `complex_inverse.mojo`;
- Horner evaluation for a fixed 13-coefficient polynomial;
- `eval_p41_coord_record`;
- `eval_p41_derivative_coord_record`;
- `m41_coord_eval_status_pending_backend`.

The result remains non-certificate-ready because the current rational backend is still `Int64`.

## Required next step

Implement a certificate-ready integer backend, then upgrade coordinate-record evaluation so:

1. coefficient arrays are unbounded integer vectors;
2. coordinate-record rational arithmetic is normalized after every operation;
3. derivative evaluation is generated from coefficients, not manually copied;
4. the derivative coordinate record can be inverted using quadrance;
5. the inverse record can be widened to a dyadic complex interval for the Krawczyk parameter `A`.

## Forbidden shortcut

Do not introduce `point_eval`, `eval_point`, analytic singleton membership, floating approximations, or trigonometric APIs. A coordinate record is finite data; if it participates in incidence, it must be wrapped as a `Vertex` or `PointVertex` package.

## Acceptance target for M41

The M41 certificate may be accepted only after all of the following are true on the same dyadic box:

- `P_4_1(beta)` and `dP_4_1(beta)` are evaluated by rational intervals;
- `A` encloses the inverse derivative computed from the coordinate record;
- Krawczyk inclusion is strict;
- the horizon-6 exact-type exclusions are all certified;
- the resulting finite substitute is a `PointVertex`, not an analytic point.
