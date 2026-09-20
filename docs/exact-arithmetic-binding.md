# Exact-arithmetic binding table

This repository's binding table for
`docs/rational-interval-arithmetic-spec.md`, section 6. One row per module
that instantiates a layer, with its conformance class and what it currently
fails. The specification is the canonical copy from
`larsbx/finite-math-kernels`; the rows below are this repository's and are
enforced by `tools/audit_exact_arithmetic.py`.

A row is a statement about arithmetic, never about certificates. No class in
this table enables certificate acceptance, and this repository has no
certificate grammar yet to accept into.

## Table

| Spec item | Module | Class | Notes |
| --- | --- | --- | --- |
| 1.1 integer backend | `src/finite_exact/bigint_z.mojo` (`BigZ`) | CONFORMS | vendored unbounded backend; dynamic base-`10^9` limbs, exact ring and order operations, long division, Euclidean gcd, canonical encoding |
| 1.1–1.3 ℚ | `src/finite_exact/rat_q.mojo` (`Q`), stable facade `src/finite_exact/rational.mojo` | CONFORMS | vendored; normalized `BigZ` fraction with sticky rejection |
| 2.1–2.5 I_Q, complex boxes | `src/finite_exact/closed_q.mojo` (`IQ`, `ComplexIQ`), stable facade `src/finite_exact/closed_interval.mojo` | CONFORMS | vendored; J1 enforced, three-valued predicates with an explicit rejected state |
| 2.5 refinement | `src/finite_exact/enclosure_width.mojo` | CONFORMS | vendored; the width bounds of the refinement theorem, for a step factor `K` the caller supplies. `src/enclosure_bound.mojo` supplies `K = 6M` for `z -> z^2 + c` |
| 2.3-2.4 preperiodic certificates | `src/quadratic_orbit/preperiodic.mojo`, consumed by `src/preperiodic_witness.mojo` | CONFORMS | vendored; the residual and its chain-rule derivative on enclosures, exclusion by zero-miss and isolation by the Krawczyk hypothesis (`docs/preperiodic-certificates.md`) |
| 2.1–2.5 seeded quadratic orbit | `src/quadratic_orbit/orbit.mojo` | DEMO | vendored; the orbit of `z^2 + c` over singleton and non-degenerate boxes, the collision interval, and the three-valued zero-exclusion test; a direct `IQ` consumer, barred from certificate acceptance |
| 1–2 escape bound and multiplier classification | `src/julia_orbit.mojo` | DEMO | quadrance against a rational bound, exact cycle checks, and the five-way multiplier classification whose indifferent case refuses to decide; direct `Q` and `ComplexIQ` consumer |
| 1–2 escape certificate | `src/escape_certificate.mojo` | DEMO | the threshold and growth forms of `docs/escape-criterion.md`, both polynomial in two quadrances; exact rational comparisons only, and a rejected value refuses rather than answering |
| 1–2 enclosure width bound | `src/enclosure_bound.mojo` | DEMO | the one-step and iterated bounds of `docs/enclosure-width-lemma.md`; exact rational comparisons, and a rejected box measures as zero rather than refusing to measure |
| 1–2 three-valued classifier | `src/box_classifier.mojo` | DEMO | the escape and trap certificates of `docs/three-valued-classifier.md` over boxes; strict containment decides `IN`, the quadrance lower bound decides `OUT`, and an unverified trap is ignored |
| 1–2 corpus replay | `src/corpus_replay.mojo` | DEMO | runs the kernel against the generated corpus and prints the transcript the differential test consumes |
| 1–2 generated corpus | `src/parameter_corpus.mojo` | DEMO | generated from `tools/parameter_corpus.py`; exact `Int64` numerator and denominator pairs lifted into singleton boxes |
| 1–2 smoke suite | `src/smoke_tests.mojo` | DEMO | the canonical Mojo smoke driver; exercises the layers it reports on |
| 1–2 reference oracle (secondary) | `tools/gaussian_q.py`, `tools/julia_reference.py` | CONFORMS | Python `fractions.Fraction`; an independent implementation of the same verdicts, compared against the Mojo kernel transcript by `tests/test_mojo_replay.py` |

## Notes on the classes used

`CONFORMS` rows are the vendored packages and the Python oracle, all on
unbounded exact arithmetic. Every module this repository writes on top of them
is `DEMO`: the algebra is conformant and the backend is unbounded, but nothing
here has been replayed into a certificate path, because there is no
certificate path yet. There are no `QUARANTINED` rows: this repository has
never had a floating-point substrate, so there is nothing to schedule for
replacement.
