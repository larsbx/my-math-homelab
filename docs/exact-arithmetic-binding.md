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
| 1.1–1.3 exact field adapter | `vendor/mojo/finite_exact/field.mojo` (`ExactField`, `QField`) | CONFORMS | vendored; `QField` delegates to unbounded `Q` with sticky rejection; the trait specifies exact field operations. Included with the whole package; unused here |
| finite prime field | `vendor/mojo/finite_exact/fp.mojo` (`Fp`, `FpField`) | DEMO | vendored whole-package snapshot; a compile-time prime bound below `2^31` keeps canonical-residue operations within Int64, and division by zero rejects. Unused here; no rational certificate path rests on it |
| 1 checked fixed width and support decision | `vendor/mojo/finite_linear_algebra/integer_matrix.mojo` | CONFORMS-CHECKED | vendored; square dimensions, products and accumulation are checked and raise on refusal. Primitivity uses exact Boolean support powers rather than weighted products. Unused here |
| 1.1 integer backend | `vendor/mojo/finite_exact/bigint_z.mojo` (`BigZ`) | CONFORMS | vendored unbounded backend; dynamic base-`10^9` limbs, exact ring and order operations, long division, Euclidean gcd, canonical encoding |
| 1.1–1.3 ℚ | `vendor/mojo/finite_exact/rat_q.mojo` (`Q`), stable facade `vendor/mojo/finite_exact/rational.mojo` | CONFORMS | vendored; normalized `BigZ` fraction with sticky rejection |
| 2.1–2.5 I_Q, complex boxes | `vendor/mojo/finite_exact/closed_q.mojo` (`IQ`, `ComplexIQ`), stable facade `vendor/mojo/finite_exact/closed_interval.mojo` | CONFORMS | vendored; J1 enforced, three-valued predicates with an explicit rejected state |
| 2.5 refinement | `vendor/mojo/finite_exact/enclosure_width.mojo` | CONFORMS | vendored; the width bounds of the refinement theorem, for a step factor `K` the caller supplies. `kernel/enclosure_bound.mojo` supplies `K = 6M` for `z -> z^2 + c` |
| 2.3-2.4 preperiodic certificates | `vendor/mojo/quadratic_orbit/preperiodic.mojo`, consumed by `kernel/preperiodic_witness.mojo` | CONFORMS | vendored; the residual and its chain-rule derivative on enclosures, exclusion by zero-miss and isolation by the Krawczyk hypothesis (`docs/preperiodic-certificates.md`) |
| 1 checked fixed width | `vendor/mojo/angle_doubling/angle.mojo`, consumed by `kernel/angle_witness.mojo` | CONFORMS | vendored; rational angles on `Q/Z` under doubling, with a denominator limit that refuses rather than wraps (`docs/angle-types-and-landing.md`) |
| 2.4 three-valued sign | `kernel/separator.mojo` | CONFORMS | the side of a rational cut a box is enclosed on, three-valued and fail-closed (`docs/finite-separator.md`) |
| 1 exact rational order | `kernel/separator.mojo` (`certifies_real_rays`) | CONFORMS | the rational inequalities of the real-axis ray witness (`docs/ray-certificates.md`) |
| 1.1-1.3 Q(i) jets | `kernel/jet.mojo`, oracle `reference/jet.py` | CONFORMS | truncated Taylor jets over `Q(i)`; multiplicity as the order of vanishing (`docs/preperiodic-certificates.md`) |
| 2.5 Taylor models | `kernel/taylor.mojo`, oracle `reference/taylor.py` | CONFORMS | an exact jet plus a rigorous interval remainder, evaluated term by term with sharp powers (`docs/taylor-models.md`) |
| 2.1 `E = F` endpoints | `reference/dyadic.py`, `reference/scaled.py` | CONFORMS | dyadics with directed rounding and a separated binary exponent, outward always (`docs/scaled-boxes.md`) |
| 2.2 charts | `vendor/mojo/projective/chart.mojo` and `vendor/mojo/projective/homogeneous.mojo`, mirror `reference/chart.py` | CONFORMS | vendored; the chart at infinity and its step, refusing where the division has no domain (`docs/ray-certificates.md`) |
| 2.1–2.5 seeded quadratic orbit | `vendor/mojo/quadratic_orbit/orbit.mojo` | DEMO | vendored; the orbit of `z^2 + c` over singleton and non-degenerate boxes, the collision interval, and the three-valued zero-exclusion test; a direct `IQ` consumer, barred from certificate acceptance |
| 1–2 escape bound and multiplier classification | `kernel/julia_orbit.mojo` | DEMO | quadrance against a rational bound, exact cycle checks, and the five-way multiplier classification whose indifferent case refuses to decide; direct `Q` and `ComplexIQ` consumer |
| 1–2 escape certificate | `kernel/escape_certificate.mojo` | DEMO | the threshold and growth forms of `docs/escape-criterion.md`, both polynomial in two quadrances; exact rational comparisons only, and a rejected value refuses rather than answering |
| 1–2 enclosure width bound | `kernel/enclosure_bound.mojo` | DEMO | the one-step and iterated bounds of `docs/enclosure-width-lemma.md`; exact rational comparisons, and a rejected box measures as zero rather than refusing to measure |
| 1–2 three-valued classifier | `kernel/box_classifier.mojo` | DEMO | the escape and trap certificates of `docs/three-valued-classifier.md` over boxes; strict containment decides `IN`, the quadrance lower bound decides `OUT`, and an unverified trap is ignored |
| 1–2 corpus replay | `kernel/corpus_replay.mojo` | DEMO | runs the kernel against the generated corpus and prints the transcript the differential test consumes |
| 1–2 generated corpus | `kernel/parameter_corpus.mojo` | DEMO | generated from `reference/parameter_corpus.py`; exact `Int64` numerator and denominator pairs lifted into singleton boxes |
| 1.1-1.3 exact rational linear algebra | `vendor/mojo/finite_linear_algebra/qlinalg.mojo`, `vendor/mojo/finite_linear_algebra/scalar.mojo`, `vendor/mojo/finite_linear_algebra/madic_ball.mojo`, `vendor/mojo/finite_linear_algebra/tensor3.mojo`, `vendor/mojo/finite_linear_algebra/w3.mojo` | CONFORMS | vendored as part of the package `qpoly` belongs to; elimination over `Q`, the integer lifts and the fail-closed zero test `qpoly` uses, `m`-adic balls, and the rank-three tensor combinatorics. Only the integer lifts are reached from this repository; the rest is here because a package is vendored whole |
| 2.4 three-valued sign | `kernel/kneading.mojo`, oracle `reference/kneading.py` | DEMO | the side of the critical cut `x = 0` each iterate of the critical point is on, three-valued and fail-closed, and the word handed to the vendored tuning layer (`docs/kneading-and-tuning.md`) |
| 1.1-1.3 exact rational polynomials | `vendor/mojo/finite_linear_algebra/qpoly.mojo`, consumed by `kernel/markov.mojo` | CONFORMS | vendored; Euclidean division, greatest common divisor, squarefree part, the Cauchy root bound and the Sturm chain over `Q`, and an isolating bracket for the largest real root that carries its own sign change (`docs/exact-polynomial-root-isolation-spec.md`) |
| 1.1-1.3 exact integer module normal form | `vendor/mojo/finite_linear_algebra/integer_module.mojo` | CONFORMS | vendored as part of the package `qpoly` belongs to; the row Hermite normal form of an embedded subgroup of `Z^d` over unbounded `BigZ`. Nothing in this repository reaches it |
| 1 checked fixed width | `vendor/mojo/finite_linear_algebra/integer_vector.mojo` | CONFORMS | vendored as part of the package `qpoly` belongs to; short integer vectors whose every sum and product is checked and raises rather than wraps. Nothing in this repository reaches it |
| 1.1-1.3 exact decimal rendering | `vendor/mojo/finite_exact/exact_decimal.mojo`, consumed by `kernel/markov.mojo` | CONFORMS | vendored; base-ten text of a `BigZ` and of a `Q` (always `p/q`, and `rejected` for a value that carries no number), with no division, rounding or floating point |
| 1 exact rational order | `kernel/markov.mojo`, oracle `reference/markov.py` | DEMO | the postcritical partition of a real postcritically finite parameter and its transition matrix, decided by rational inequalities; the characteristic polynomial and the largest-root bracket from the vendored `qpoly` on the Mojo side, and the oracle's own Faddeev-LeVerrier and sign-change bracket on the Python side (`docs/tiling-connections-2026-09-20.md`) |
| 1–2 markov transcript | `kernel/markov_transcript.mojo` | DEMO | prints the partition transcript the differential test consumes; decides nothing |
| 1–2 smoke suite | `kernel/smoke_tests.mojo` | DEMO | the canonical Mojo smoke driver; exercises the layers it reports on |
| 1–2 reference oracle (secondary) | `reference/gaussian_q.py`, `reference/julia_reference.py` | CONFORMS | Python `fractions.Fraction`; an independent implementation of the same verdicts, compared against the Mojo kernel transcript by `tests/test_mojo_replay.py` |

## Notes on the classes used

`CONFORMS` rows are the unbounded vendored arithmetic and the Python oracle.
`CONFORMS-CHECKED` records the bounded matrix operations that raise on refusal;
the finite prime-field snapshot is `DEMO` and unused here.
Every module this repository writes on top of the unbounded packages
is `DEMO`: the algebra is conformant and the backend is unbounded, but nothing
here has been replayed into a certificate path, because there is no
certificate path yet. There are no `QUARANTINED` rows: this repository has
never had a floating-point substrate, so there is nothing to schedule for
replacement.
