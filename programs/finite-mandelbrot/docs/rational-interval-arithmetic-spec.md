# Rational and interval arithmetic: canonical exactness specification

**Status:** cross-program arithmetic contract, implemented canonically in `larsbx/finite-math-kernels`. finite-mandlebrot-research and `larsbx/pisot-substitution-conjecture-research` each vendor the same pinned monorepo commit and enforce per-file digests. Sections 0 to 5 are repository-independent; section 6 records the consumer binding rows. Exact arithmetic does not decide certificate acceptance or settle C1.

Terminology in this file is field-recognizable (rational arithmetic, interval arithmetic, natural interval extension, dependency problem, floating-point filter). No novel bridge term is introduced. Where finite-mandlebrot-research terminology governance applies, every term here is Route A.

## 0. The problem being solved

Let `F ⊂ ℝ` be a floating-point format (`F = F_{53}` for IEEE binary64). `F` is finite and non-uniform: it samples `ℝ` densely near `0` and sparsely far from it. Every arithmetic operation on `F` is a rounded operation

```text
fl(x ∘ y) = (x ∘ y)(1 + δ),   |δ| ≤ u,   ∘ ∈ {+, −, ×, ÷},
```

with unit roundoff `u = 2^{-53}`. Three consequences drive this specification.

1. **Algebraic laws fail.** `fl` is commutative but neither associative nor distributive: `(a +ᶠ b) +ᶠ c ≠ a +ᶠ (b +ᶠ c)` in general, and `fl(0.1) +ᶠ fl(0.2) ≠ fl(0.3)`. A computation's value therefore depends on evaluation order.
2. **Rounding is silent.** `δ` is not observable from the result, so a computed sign, a computed equality, or a computed `≤` carries no certificate.
3. **Cancellation destroys digits.** If `x ≈ y`, then `x −ᶠ y` retains only the bits in which `x` and `y` differ, and those bits are exactly the ones already contaminated by earlier `δ`.

For a proof-support kernel, (2) is fatal on its own: any predicate whose truth value enters a certificate (`= 0`, `> 0`, `∈ box`, `has a root`) must be decided by an arithmetic that either **never rounds** or **bounds every rounding in a form the certificate can carry**. The two admissible arithmetics are stated below. They attack the problem from opposite directions and are combined in section 3.

## 1. Layer ℚ: eliminate rounding

### 1.1 Representation

A rational is a pair `(p, q) ∈ ℤ × ℤ_{>0}` in lowest terms:

```text
Q := { (p, q) : q > 0,  gcd(|p|, q) = 1 }.
```

Invariants, which every constructor and every operation must re-establish:

- **I1 (positive denominator):** `q > 0`.
- **I2 (reduced):** `gcd(|p|, q) = 1`. Zero is represented uniquely as `(0, 1)`.
- **I3 (total normalization):** no value of the type may exist that violates I1 or I2, so normalization happens inside the constructor, not at use sites.

### 1.2 Operations

With `a = (p₁, q₁)` and `b = (p₂, q₂)`:

```text
a + b = norm(p₁q₂ + p₂q₁,  q₁q₂)
a − b = norm(p₁q₂ − p₂q₁,  q₁q₂)
a × b = norm(p₁p₂,          q₁q₂)
a ÷ b = norm(p₁q₂,          q₁p₂)          (b ≠ 0; sign moved to numerator by norm)
−a    = (−p₁, q₁)
```

Cross-cancellation before multiplication (`gcd(p₁, q₂)`, `gcd(p₂, q₁)`) and gcd-of-denominators before addition are permitted optimizations. They change intermediate operand size, never the result.

### 1.3 Laws

`(Q, +, ×)` is a field. Every operation is closed, and

- associativity, commutativity, and distributivity hold **exactly**;
- results are independent of evaluation order and of intermediate normalization strategy;
- equality is decidable by pair comparison after normalization: `a = b ⟺ p₁ = p₂ ∧ q₁ = q₂`, equivalently `p₁q₂ = p₂q₁`;
- order is decidable by cross multiplication: `a < b ⟺ p₁q₂ < p₂q₁` (valid because `q₁, q₂ > 0`);
- cancellation is lossless: `(x + y) − y = x` exactly, for all `x, y ∈ Q`.

Hence `1/10 + 2/10 = 3/10` holds, and any sequence of `+ − × ÷` returns the mathematically correct rational.

### 1.4 Costs

- **Size growth.** `bits(den(a + b)) ≤ bits(q₁) + bits(q₂)` and `bits(num(a × b)) ≤ bits(p₁) + bits(p₂)` before reduction. Under iteration the bound compounds: a Newton step or a Gaussian-elimination pivot can double operand size per step, so `k` steps cost up to `Θ(2^k)` bits in the worst case. Reduction by gcd mitigates but does not remove this; it is a cost to be measured, not assumed away.
- **Closure boundary.** Only operations algebraic over `ℚ` stay in `Q`. `√2`, `e`, `sin x`, and the Perron root `β` of an irreducible cubic are not elements of `Q`. To handle them exactly one extends the field (`ℚ(√d)`, `ℚ(β)` represented through a minimal polynomial with a sign oracle such as Sturm–Tarski), or one leaves exactness for enclosure (section 2).
- **Speed.** No hardware support. Expect two to three orders of magnitude slower than binary64 on the same operation count, more when operands grow.

### 1.5 Backend requirement

The laws of 1.3 hold only over unbounded `ℤ`. A fixed-width integer backend (`Int64`, `Int`) is admissible in exactly one of two modes:

- **Proof grade (unbounded):** arbitrary-precision `ℤ`. Cross multiplication in `=` and `<` is then safe.
- **Checked fixed width (fail closed):** every `+ − × neg abs` on the backend is overflow-checked, and overflow **raises or aborts**. It must never wrap, saturate, or widen silently. Under this mode a completed computation is exact; an aborted computation is *no result*, not a wrong result.

An unchecked fixed-width backend is **demo grade**: it may back examples and smoke tests, and it must be barred from every path that emits or accepts a certificate.

### 1.6 Best fit

Geometry predicates, exact linear algebra over `ℚ`, Parikh and incidence algebra, gcd and squarefree witnesses, canonical serialization, and every decision whose wrong sign or false equality would be catastrophic.

## 2. Layer I: keep rounding, bound it

### 2.1 Representation

An interval is a closed set `[a, b] = { x ∈ ℝ : a ≤ x ≤ b }` with endpoints in an endpoint set `E`:

```text
I_E := { [a, b] : a, b ∈ E,  a ≤ b }.
```

Two endpoint sets are relevant.

- **`E = F` with directed rounding.** Lower endpoints are computed rounding toward `−∞`, upper endpoints toward `+∞`. Every result contains the true result. Requires rounding-mode control on the hardware; fast.
- **`E = Q` (rational endpoints).** Endpoint arithmetic is exact (section 1), so no rounding mode is needed and the enclosures are the tightest the formulas allow. This is the mode both repositories use; `E = F` is stated for completeness and is **not** admitted in certificate paths.

Invariant **J1:** `a ≤ b` at construction. Reversed endpoints must raise, not swap.

### 2.2 Operations

```text
[a,b] + [c,d] = [a+c, b+d]
[a,b] − [c,d] = [a−d, b−c]
[a,b] × [c,d] = [min S, max S],   S = {ac, ad, bc, bd}
1/[c,d]       = [1/d, 1/c]           only if 0 ∉ [c,d]; otherwise raise
[a,b] ÷ [c,d] = [a,b] × (1/[c,d])
[a,b]²        = [0, max(a², b²)]     if 0 ∈ [a,b];  else [a,b] × [a,b]
```

Under `E = F` each endpoint formula is evaluated with the outward rounding stated in 2.1; under `E = Q` it is evaluated exactly.

### 2.3 The inclusion theorem

For every operation `∘` above and every `x ∈ X`, `y ∈ Y` in `I_E`,

```text
x ∘ y ∈ X ∘ Y.
```

By induction, for any expression `f` built from `+ − × ÷` and constants, the **natural interval extension** `f_I` satisfies `f(x) ∈ f_I(X)` whenever `x ∈ X`. This is the only theorem the layer provides, and it is the whole point: rounding error becomes a **certified width** `b − a` rather than an unobservable `δ`. Transcendental and algebraic functions outside `ℚ` are admitted here through any enclosure `g_I` with `g(x) ∈ g_I(X)`, for example a rational bracket of a Perron root obtained by exact sign changes at rational points.

### 2.4 Decision semantics

An interval answers a sign question with three values, never two:

```text
sign_I([a,b]) = +1  if a > 0
              = −1  if b < 0
              =  0  otherwise   (meaning UNKNOWN, not "equals zero")
```

Consequently:

- `X ∩ Y = ∅` proves `x ≠ y`; overlap proves nothing.
- `0 ∉ f_I(X)` proves `f` has no zero in `X`; `0 ∈ f_I(X)` proves nothing.
- `f_I(X) ⊂ int(X)` (strict inclusion) is the hypothesis of contraction-type uniqueness theorems (Krawczyk, Brouwer); non-inclusion proves nothing.

An interval never returns equality, and `0` from `sign_I` must never be consumed as a mathematical zero.

### 2.5 Costs

- **Dependency problem.** Occurrences of the same variable are treated as independent. `X − X = [a−b, b−a] ≠ [0,0]` and `X × X ⊋ X²` when `0 ∈ X`. Only **subdistributivity** holds: `X(Y + Z) ⊆ XY + XZ`. Widths therefore inflate along long computations and through iterated maps (the wrapping effect). The natural extension of the same polynomial in Horner form and in expanded form gives different, both valid, enclosures; Horner is generally tighter and is the required form here.
- **Mitigations.** Bisection of `X` (width shrinks linearly in the number of pieces, cost grows the same way); centred forms and mean-value forms; affine or Taylor-model arithmetic, which tracks first-order correlations and cancels `X − X` exactly. Affine and Taylor models are out of scope for both repositories at present; bisection and Horner are in scope.
- **No exact answer.** The layer proves enclosure, never value. Equality is only ever refuted.

### 2.6 Best fit

Validated numerics, root isolation and exclusion, contraction witnesses for uniqueness, computer-assisted proofs (Hales' Kepler proof, Tucker's Lorenz attractor), branch-and-bound global optimization, and any "certified margin" statement.

## 3. Combining the layers

### 3.1 Rational endpoints

Take `E = Q` in section 2. The two layers then share one backend, the enclosure formulas are exact, and rounding-mode control disappears. The dependency problem (2.5) remains untouched: exact endpoints do not make `X − X` collapse to zero.

### 3.2 Filter-then-exact

For a predicate `P(x)` whose exact decision is expensive (an exact sign in `ℚ(β)`, an exact geometric orientation, an exact zero test on a large polynomial), define the two-stage procedure

```text
decide(x):
  s := sign_I(P_I(X))          # cheap enclosure with X ∋ x
  if s ≠ 0: return s           # interval-certified strict sign
  return sign_exact(P(x))      # exact oracle: ℚ, ℚ(β) with Sturm–Tarski, gcd witness, ...
```

**Soundness.** By 2.3 the strict interval sign, when it is nonzero, equals the exact sign. The filter can therefore never contradict the oracle, and the oracle is invoked exactly on the cases the filter cannot decide. This is the pattern of CGAL's filtered predicates and Shewchuk's adaptive-precision predicates: near-float cost on the common case, exact correctness on every case.

Two rules follow and are enforced (section 7):

- **R1.** The exact oracle is never bypassed on `s = 0`. An ambiguous interval is a *fallthrough*, not a *result*.
- **R2.** A result is labelled by which stage produced it (`interval_certified` versus exact fallback). Downstream code may count, report, or require interval certification, but must treat both labels as mathematically valid signs.

### 3.3 Exact-in-combinatorics, interval-in-geometry

Where a computation has a combinatorial skeleton (an automaton, a catalogue, a graph of states) and a geometric margin (a distance, a discriminant, a Perron-coordinate sign), the skeleton is built in `ℤ`/`ℚ` and the margins are certified by `I_Q` with exact fallback. The skeleton is never rebuilt from a floating summary of the geometry.

## 4. Decision table

| Question | Layer | Reason |
| --- | --- | --- |
| `x = y`? | ℚ only | I refutes equality but never proves it (2.4) |
| `x < y`, `x > 0`? | I with ℚ / ℚ(β) fallback (3.2) | strict interval sign is a proof; `0` falls through |
| `f(x) ∈ B`? | I | 2.3 gives a containment proof |
| `f` has no zero in `X`? | I (`0 ∉ f_I(X)`) | exclusion certificate |
| `f` has a unique zero in `X`? | I (contraction, strict inclusion) plus ℚ for the point evaluations | Krawczyk / Brouwer hypotheses |
| root bracket for `β ∉ ℚ`? | ℚ signs at rational points, bisection; box is `I_Q` | exact sign changes, enclosure output |
| gcd, squarefree, divisibility, rank | ℚ only | any rounding falsifies the witness |
| serialization / hashing of certificate data | ℚ (normalized form) | I1 to I3 make the encoding canonical |

## 5. Conformance criteria

A module implementing either layer is **conformant** when all of the following hold.

- **C1.** No floating-point type (`Float16`, `Float32`, `Float64`, `float`) appears in any code path that constructs, evaluates, or accepts certificate data. Floats are permitted only in explicitly quarantined demo files listed in the repository allowlist.
- **C2.** Rational construction normalizes (I1 to I3) and rejects `den = 0`.
- **C3.** Integer backend is unbounded, or checked fail-closed (1.5); an unchecked fixed-width backend is labelled demo grade in the binding table and in the module header.
- **C4.** Interval construction enforces J1 and interval reciprocal raises on `0 ∈ [c, d]`.
- **C5.** Sign queries on intervals are three-valued (2.4); no API converts `0` into "zero" or "false".
- **C6.** Every filter-then-exact site obeys R1 and R2.
- **C7.** The module header cites this specification by path.

The distinction between `Rat` (1.1) and a *checked* `Rat` is only C3; the algebra is the same.

## 6. Repository binding

The binding table lists every module that instantiates a layer, its conformance class, and the criteria it currently fails. Classes:

| Class | Meaning |
| --- | --- |
| CONFORMS | meets C1 to C7 with an unbounded backend |
| CONFORMS-CHECKED | meets C1 to C7 with a checked fail-closed fixed-width backend (1.5) |
| DEMO | unchecked fixed-width backend; algebra conformant; barred from certificate acceptance |
| QUARANTINED | uses floating point; allowlisted; barred from every certificate path; scheduled for replacement |

### 6.1 `larsbx/pisot-substitution-conjecture-research`

| Spec item | Module | Class | Notes |
| --- | --- | --- | --- |
| 1.1 integer backend, 1.1–1.3 ℚ, 2.1–2.5 I_Q | `mojo/finite_exact/bigint_z.mojo`, `mojo/finite_exact/rat_q.mojo`, `mojo/finite_exact/interval_q.mojo` | CONFORMS | copies of the three finite-mandlebrot-research modules of 6.2, identical up to the package qualification of their intra-package import lines; `scripts/check_finite_exact_sync.py` undoes that rewrite and compares SHA-256 digests with the upstream digests pinned in `mojo/finite_exact/UPSTREAM.md`, so any other local edit fails PSC CI |
| PSC conventions over the package | `mojo/psc/exact.mojo` | CONFORMS | a rejected enclosure raises, a rejected scalar in integer-seeded polynomial arithmetic aborts as an impossible state; integer lifts, Horner helpers, midpoint, diagnostic rendering |
| 1–2 direct consumers | `mojo/psc/qlinalg.mojo`, `mojo/psc/pisot.mojo`, `mojo/psc/tensor3.mojo`, `mojo/psc/w3.mojo` | CONFORMS | exact linear algebra, Sturm sequences, and the PIP screen over unbounded rationals; the former machine-width `Rat` is retired |
| 2.3 enclosure of `β ∉ ℚ` | `mojo/psc/perron_interval.mojo` (`perron_root_interval`) | CONFORMS | integer bracket by exact sign changes, then bisection with unbounded endpoints |
| 3.2 filter-then-exact | `mojo/psc/perron_interval.mojo` (`perron_sign_decision`) with oracle `psc.perron_field3.sign_at_perron` | CONFORMS | R1: fallback on `0`; R2: `interval_certified` flag |
| 3.3 skeleton/margin split | `mojo/psc/overlap_interval_audit.mojo` | CONFORMS | overlap graph exact; margins interval-first with exact fallback; uniform minimum reported only when every margin is interval-certified |

The earlier `CheckedRat`/`RatInterval` layer (`mojo/psc/rational_interval.mojo`, CONFORMS-CHECKED) and the unchecked `Rat` (`mojo/psc/rational.mojo`, DEMO) are deleted; their tests were carried over to `mojo/tests/test_exact_interval.mojo`.

### 6.2 `larsbx/finite-mandlebrot-research`

| Spec item | Module | Class | Notes |
| --- | --- | --- | --- |
| 1.1–1.3 exact field adapter | `vendor/mojo/finite_exact/field.mojo` (`ExactField`, `QField`) | CONFORMS | vendored; `QField` delegates to unbounded `Q` with sticky rejection; the trait specifies exact field operations |
| cyclotomic fields `Q(ζ_q)` over ℚ | `vendor/mojo/finite_polynomial/cyclotomic_q.mojo` (`CyclotomicQ`), `vendor/mojo/finite_polynomial/cyclotomic_field.mojo` (`Cyc`, `CyclotomicField`) | CONFORMS | vendored whole-package snapshot carried with `finite_polynomial`, whose `polynomial_fp` the exact-type irreducibility, R41 algebraic-root and critical-relation bridge kernels use; coefficients are unbounded `Q` with sticky rejection; no kernel here imports these two modules |
| finite prime field | `vendor/mojo/finite_exact/fp.mojo` (`Fp`, `FpField`) | DEMO | vendored whole-package snapshot used by `finite_field_orbit`; a compile-time prime bound below `2^31` keeps canonical-residue operations within Int64, and division by zero rejects. This supplies no rational certificate backend |
| 1.1–1.3 ℚ | `vendor/mojo/finite_exact/rat_q.mojo` (`Q`), stable facade `vendor/mojo/finite_exact/rational.mojo` | CONFORMS | normalized `BigZ` numerator/positive denominator storage; addition, subtraction, and order scale by denominator cofactors of `gcd(den, den')`, multiplication cross-cancels (`q_cross_terms`); zero denominators and division by zero propagate rejection; certificate acceptance remains disabled pending consumer replay |
| 1.1 integer backend | `vendor/mojo/finite_exact/bigint_z.mojo` (`BigZ`) | CONFORMS | dynamic base-`10^9` limbs; exact signed ring/order operations, quotient/remainder by schoolbook long division (Knuth Algorithm D) with the shift-and-subtract routine retained as an in-process reference, rejected non-divisions, Euclidean gcd, and canonical integer serialization; rational and core interval consumers are migrated, while certificate replay remains pending |
| finite angle-measure density | `kernel/mojo/c1/separator/separated_density.mojo` (`SeparatedDensityResult`) | CONFORMS | BigZ-backed `Q` atom lengths, midpoints, squares, and sums for the measure of the pairs a finite set of two-ray separators separates, aggregated by side signature (`docs/C1_separated_pair_density.md`); malformed or out-of-range endpoints, a separator with coincident rays, and a total length other than one reject; the measure is Lebesgue measure on external angles, never harmonic measure or a decision about a named pair |
| finite angle-measure density along a carrier | `kernel/mojo/c1/carrier/carrier_density_profile.mojo` (`CarrierDensityProfile`) | CONFORMS | BigZ-backed `Q` densities, residues, and per-level increments for every prefix of a residual directive carrier, each prefix measured by the kernel above (`docs/C1_separated_pair_density.md`); a level address that is not periodic, a separator that is not admissible under `docs/C1_admissible_separator_codes.md` (no accepted landing tag, no declared co-landing, or coincident rays), a separator the kernel refuses, a negative increment, a rising residue, and increments that do not sum to the final density all reject; the separator of each level is declared and checked, never derived from the level's address, and no level's measure is a statement about the carrier or about any named pair |
| finite rational ray-address dynamics | `kernel/mojo/dynamics/bigq_ray_address.mojo` (`BigQRayAddr`) | CONFORMS | inputs normalized as BigZ-backed `Q`, then held as the vendored `rational_dynamics` `ReducedFraction` (`vendor/mojo/rational_dynamics/rational.mojo`), whose `double_mod_one` and `fraction_equal` are the doubling and the equality; malformed and out-of-range inputs reject; finite symbolic addresses only, not measured angles |
| finite theorem-instance data | `kernel/mojo/certificates/c_minus_2/bigq_theorem_tag_payload_instances.mojo` | CONFORMS | normalized BigZ-backed `Q` address data and finite source-scope matching; classification-proof attachment and final import remain explicitly false |
| proof-grade c=-2 landing-target association | `kernel/mojo/certificates/c_minus_2/proof_grade_landing_target_association.mojo` | CONFORMS | acceptance-bearing BigZ/Q consumer: exact symbolic ray-address replay, exact BigZ coefficient replay of `R_{2,1}=C^3(C+2)`, lower-type and exact-orbit checks; imports the external landing theorem through the checked theorem-tag boundary and does not enable fiber or C1 acceptance |
| 2.1–2.5 I_Q, complex boxes | `vendor/mojo/finite_exact/closed_q.mojo` (`IQ`, `ComplexIQ`), stable facade `vendor/mojo/finite_exact/closed_interval.mojo` | CONFORMS | BigZ endpoints; `singleton` constructors for degenerate boxes; J1 and endpoint rejection enforced; reciprocal rejects zero-containing intervals; sign and containment/inclusion predicates preserve an explicit rejected state |
| 2.5 enclosure width bounds | `vendor/mojo/finite_exact/enclosure_width.mojo` (`sup_radius`, `iterated_radius_bound`, `orbit_gap_bound`, `refinement_radius`, `confined`) | CONFORMS | vendored from `larsbx/finite-math-kernels`; BigZ-backed `Q` bounds `K^n r` on the radius of iterated `ComplexIQ` enclosures from a caller-supplied rational step factor `K`; a rejected factor, radius or margin, a negative step count, and a non-positive margin return a rejected `Q`; no consumer in this repository yet, and no bound is a certificate by itself |
| 2.3–2.4 seeded quadratic orbit over boxes | `vendor/mojo/quadratic_orbit/orbit.mojo` (`zero_box`, `quadratic_step`, `orbit_term`, `collision_interval`, `complex_excludes_zero`), `vendor/mojo/quadratic_orbit/preperiodic.mojo`, `vendor/mojo/quadratic_orbit/krawczyk_operator.mojo` | CONFORMS | vendored from `larsbx/finite-math-kernels`; `z^2 + c` and term differences over BigZ-backed `ComplexIQ`, with a three-valued zero-exclusion test that returns rejected on any rejected coordinate and never promotes an overlapping box to exclusion; `kernel/mojo/dynamics/interval_orbit.mojo` imports the step, the collision box and the exclusion test from here, and the `(ell, period)` collision partition from `quadratic_orbit/collision.mojo`; no certificate acceptance is decided in the package |
| 2.3–2.4 Krawczyk root isolation | `vendor/mojo/root_isolation/krawczyk.mojo` (`krawczyk_image`, the Krawczyk operator), `vendor/mojo/root_isolation/krawczyk_moore.mojo` (`strictly_inside`), `vendor/mojo/root_isolation/boxes.mojo` (`centre`, `exact_inverse`, `excludes_zero`, `disjoint`) | CONFORMS | vendored from `larsbx/finite-math-kernels`; exact over BigZ-backed `ComplexIQ`, no rounding, a rejected operand gives a rejected image and a rejected test, kept apart from non-contraction; `kernel/mojo/certificates/krawczyk_witness.mojo` supplies `P_{2,1}`, its box and its preconditioner; the package decides the strict-interior hypothesis, never a root or certificate acceptance |
| 2.3–2.5 escape and multiplier tests | `vendor/mojo/quadratic_orbit/escape_criterion.mojo` (Carleson–Gamelin escape test `N(z) > max(4, N(c))`), `vendor/mojo/quadratic_orbit/multiplier_classification.mojo` (attracting / indifferent / repelling) | CONFORMS | vendored whole-package snapshot carried with `quadratic_orbit`; exact over BigZ-backed `Q` and `ComplexIQ`, a refused or negative quadrance rejects and UNDECIDED is kept apart from REJECTED; no kernel here imports these two modules |
| 1.1–1.3, 2.5 ring-generic jets and Taylor models | `vendor/mojo/finite_polynomial/coefficient_ring.mojo` (`CoefficientRing`, `FieldRing`, `CyclotomicRing`, `ComplexBoxRing`), `vendor/mojo/finite_polynomial/taylor_model.mojo` (Berz–Makino Taylor models over complex boxes) | CONFORMS | vendored whole-package snapshot carried with `finite_polynomial`; coefficients are unbounded `Q` or BigZ-backed `ComplexIQ` boxes with sticky rejection, no rounding; no kernel here imports these two modules |
| 1–2 property probe | `kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo` | CONFORMS | deterministic xorshift64* operands; prints canonical bytes of every `BigZ`, `Q`, and `IQ` result plus in-process long-division-versus-reference and canonicality self-checks; compared token by token by the secondary oracle in CI |
| 1–2 property oracle (secondary) | `reference/python/arithmetic/exact_arithmetic_property_oracle.py` | CONFORMS | Python `int` and `fractions.Fraction`; regenerates the probe operands and the canonical encodings independently; the only trusted channel between the two is the byte layout of `docs/canonical-serialization.md` |
| 2.3 natural extension, Horner | `kernel/mojo/polynomial/poly_interval_eval.mojo` | DEMO | ascending-coefficient Horner over `ComplexIQ` |
| 2.4 strict inclusion witness | `kernel/mojo/certificates/krawczyk_witness.mojo` | DEMO | Krawczyk contraction on `P_{2,1}`; `P_{4,1}` pending |
| 1–2 direct arithmetic consumers | `kernel/mojo/arithmetic/complex_inverse.mojo`, `kernel/mojo/arithmetic/coord_record_eval.mojo`, `kernel/mojo/dynamics/interval_orbit.mojo`, `kernel/mojo/arithmetic/rank2_operator.mojo`, `kernel/mojo/arithmetic/rational_trig.mojo`, `kernel/mojo/smoke/smoke_tests.mojo` | DEMO | direct `Q` or `IQ` consumers now inherit BigZ arithmetic, but remain barred from certificate acceptance until each acceptance-bearing consumer is replayed and promoted explicitly |
| 2.4 exclusion oracle (secondary) | `reference/python/interval/interval_exclusion_reference.py` | CONFORMS | Python `Fraction` endpoints over the vendored `closed_interval` package (`vendor/python/closed_interval/`), the Python twin of `closed_q` with the same sharp complex square; reference for `kernel/mojo/dynamics/interval_orbit.mojo` |
| exact base-ten rendering | `vendor/mojo/finite_exact/exact_decimal.mojo` (`bigz_decimal`, `q_decimal`) | CONFORMS | reads the vendored `BigZ` sign and base-`10^9` limbs and writes them as decimal digits, and a `Q` as `p/q` with the denominator kept; no division, no rounding and no floating point, so an exact value leaves the repository readable without becoming approximate; a rejected `Q` renders as `rejected` rather than as a number; first written in this repository and now vendored from `larsbx/finite-math-kernels` as part of `finite_exact/` |
| — | `kernel/mojo/dynamics/complex_box.mojo` (`C64`, `ComplexBox`), `kernel/mojo/dynamics/finite_mandelbrot.mojo`, `kernel/mojo/entrypoints/run_examples.mojo` | QUARANTINED | `Float64` demo substrate; replacement target is dyadic-rational endpoints per `docs/interval-orbit-native-target.md` |

Promotion of any DEMO row to CONFORMS requires the unbounded backend gate in `backend.toml` and `docs/bigint-migration-handoff.md`; promotion to CONFORMS-CHECKED requires overflow-checked operations in the constructor and every arithmetic method, with every unsafe case returning an explicit rejected result.

The checked Int64 transition stack (`checked_int64_backend.mojo`, `checked_ray_address.mojo`, `checked_q.mojo`, `checked_interval_q.mojo`, `checked_complex_interval.mojo`, `checked_krawczyk_witness.mojo`, `checked_interval_exclusion.mojo`, the checked-width localization gate and the checked c=-2 landing adapter and certificate gate) is retired. Its c=-2 certificates are replayed exactly by the BigZ/Q rows above (`krawczyk_witness.mojo`, `interval_orbit.mojo`, `bigq_ray_address.mojo`, `certificates/c_minus_2/bigq_*.mojo`), which are the certificates of record: on every half-width the Int64 stack accepted, the BigZ replay produces the same box, the same Krawczyk image and the same verdicts, and it answers where the Int64 stack rejected for overflow (Krawczyk beyond `2^-15`, exclusions beyond `2^-8`).

## 7. Hook: how the specification is enforced

The specification is a hook, not a note. Each repository wires it into its control surfaces as follows; the regression tests fail if any wire is removed.

1. **Audit script** (`tools/audit_exact_arithmetic.py` in finite-mandlebrot-research, `scripts/audit_exact_arithmetic.py` in PSC). Lexically scans the executable kernel scope for floating-point type tokens and decimal literal forms outside comments and strings, fails on any hit not in the allowlist, discovers direct arithmetic consumers and requires a binding row for each, and verifies that every module named in section 6 exists and cites this file (C7), including quarantined modules. Run in CI.
2. **Allowlist** (`tools/exact_arithmetic_allowlist.md` in finite-mandlebrot-research, `scripts/exact_arithmetic_allowlist.md` in PSC). The only place QUARANTINED files may be named. Adding a file here requires a matching QUARANTINED row in section 6.
3. **Law tests.** Executable checks of 1.3 (normalization, decidable equality, `1/10 + 2/10 = 3/10`, order-independence), 2.2 to 2.5 (inclusion, three-valued sign, `X − X ≠ [0,0]`, subdistributivity, fail-closed reciprocal and J1), and 3.2 (filter agrees with oracle; fallthrough on `0`). They exist in Mojo against the canonical kernels and in Python against the secondary oracle. finite-mandlebrot-research additionally runs the randomized property probe of `kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo` against `reference/python/arithmetic/exact_arithmetic_property_oracle.py` in CI (`pixi run property`); a disagreement on any canonical byte fails the build.
4. **Policy pointers.** `README.md` and the implementation policy file (`AGENTS.md` in PSC, `docs/mojo_first_execution_policy.md` in finite-mandlebrot-research) name this file as the arithmetic policy; `backend.toml` in finite-mandlebrot-research carries `exact_arithmetic_spec` and `no_float_certificate_arithmetic = true`.
5. **Cross-repository rule.** PSC consumes the finite-mandlebrot-research modules by pinned vendoring, not by mirroring this file. A change to `vendor/mojo/finite_exact/bigint_z.mojo`, `vendor/mojo/finite_exact/rat_q.mojo`, or `vendor/mojo/finite_exact/closed_q.mojo` here is picked up by PSC only when PSC re-vendors and updates `mojo/finite_exact/UPSTREAM.md`; a change to sections 0 to 5 must keep the public boundary of `docs/exact-arithmetic-public-boundary.md`. No finite-mandlebrot-research check or document may claim that a mirror of this file exists in PSC.

## 8. Non-goals

- This specification does not select an arbitrary-precision integer library; that remains the backend handoff in each repository.
- It does not introduce affine or Taylor-model arithmetic.
- It does not claim that exact arithmetic proves any theorem. Exactness removes one class of error from a computation; the epistemic status of the computation is governed by each repository's verification-architecture and claim-status documents.

## References

- IEEE Std 754-2019, *IEEE Standard for Floating-Point Arithmetic*.
- R. E. Moore, R. B. Kearfott, M. J. Cloud, *Introduction to Interval Analysis*, SIAM 2009 (inclusion theorem, dependency problem, natural extension).
- W. Tucker, *Validated Numerics*, Princeton 2011.
- J. R. Shewchuk, *Adaptive Precision Floating-Point Arithmetic and Fast Robust Geometric Predicates*, Discrete Comput. Geom. 18 (1997) (filter-then-exact).
- CGAL Editorial Board, *CGAL User and Reference Manual*, "Exact Geometric Computation" and filtered kernels.
- T. C. Hales et al., *A formal proof of the Kepler conjecture*, Forum Math. Pi 5 (2017).
- W. Tucker, *A rigorous ODE solver and Smale's 14th problem*, Found. Comput. Math. 2 (2002).
- L. H. de Figueiredo, J. Stolfi, *Affine arithmetic: concepts and applications*, Numer. Algorithms 37 (2004).
