# Exact arithmetic public boundary

Status: repository invariant for `vendor/mojo/finite_exact/bigint_z.mojo`, `vendor/mojo/finite_exact/rat_q.mojo`, and `vendor/mojo/finite_exact/closed_q.mojo`. It declares which names, semantics, and encodings downstream modules may rely on, so that the three modules can later move into a shared library without changing their consumers. It states no theorem and enables no certificate acceptance: arithmetic readiness is a property of the backend, acceptance is decided by the consumers named in `docs/bigint-migration-handoff.md`.

Specification of the arithmetic itself: `docs/rational-interval-arithmetic-spec.md`. Encodings: `docs/canonical-serialization.md`. Rationale for the boundary: `docs/library-extraction-candidates-2026-09-14.md`, section 1.

## 1. Public names

| Layer | Type | Constructors | Operations | Predicates | Encoding |
| --- | --- | --- | --- | --- | --- |
| Z | `BigZ` | `bigz_zero`, `bigz_from_i64` | `bigz_add`, `bigz_sub`, `bigz_mul`, `bigz_neg`, `bigz_abs`, `bigz_divmod`, `bigz_div_exact`, `bigz_gcd` | `bigz_eq`, `bigz_lt`, `bigz_is_canonical`, `BigZ.is_zero` | `bigz_canonical_bytes`, `canonical_bytes_equal` |
| Q | `Q` | `Q(n, d)`, `Q.zero`, `Q.one`, `Q.from_int`, `q_from_bigz` | `add`, `sub`, `mul`, `div`, `neg`, `square`, `q_abs`, `q_min`, `q_max` | `eq`, `lt`, `le`, `accepted` | `q_canonical_bytes` |
| I_Q | `IQ` | `IQ(lo, hi)`, `IQ.singleton` | `add`, `sub`, `mul`, `neg`, `square`, `reciprocal` | `sign`, `contains_zero`, `excludes_zero`, `subset_of`, `strict_subset_of`, `accepted` | endpoints via `q_canonical_bytes` |
| rank-2 I_Q | `ComplexIQ` | `ComplexIQ(re, im)`, `ComplexIQ.singleton` | `add`, `sub`, `mul`, `square`, `quadrance` | `subset_of`, `strict_subset_of`, `accepted` | components via `q_canonical_bytes` |

Result carriers `BigZDivModResult`, `BigZExactDivisionResult`, `BigZCanonicalBytes`, `QCanonicalBytes`, `IQBoolResult`, and `IQSignResult` are public. Every other name in the three modules, in particular `bigz_abs_*`, `bigz_abs_divmod_shift_subtract`, `q_normalize_bigz`, `q_cross_terms`, `QCrossTerms`, and the `*_smoke` and `demo_*` entry points, is internal and may change without notice.

## 2. Semantics that consumers may rely on

1. **Exactness.** Every operation on accepted inputs returns the mathematically exact result. There is no rounding, saturation, or wraparound at any magnitude.
2. **Canonical form.** An accepted `BigZ` has `sign` in `{-1, 0, 1}`, no leading zero limb, and every limb below `10^9`; zero has no limbs. An accepted `Q` has a canonical numerator, a canonical strictly positive denominator, and `gcd(|num|, den) = 1`. An accepted `IQ` has accepted endpoints with `lo <= hi`.
3. **Rejection is explicit and sticky.** Invalid construction (non-canonical limbs, zero denominator, reversed endpoints), division by zero, non-exact division, and reciprocal of a zero-containing interval produce a carrier whose `rejected` flag is true. Every operation with a rejected operand returns a rejected carrier. Predicates on rejected operands return `False` for `eq`, `lt`, `le`, and a carrier with `rejected = True` for `IQBoolResult` and `IQSignResult`; a consumer must test `rejected` before reading `value` or `code`.
4. **Three-valued sign.** `IQ.sign` returns `1` only when `0 < lo`, `-1` only when `hi < 0`, and `0` otherwise. `0` means unknown, never equality.
5. **Division convention.** `bigz_divmod` truncates toward zero: the remainder has the sign of the dividend and `|remainder| < |divisor|`. `bigz_div_exact` rejects unless the remainder is zero. `bigz_gcd` is non-negative and `bigz_gcd(0, 0) = 0`.
6. **Order agrees with value.** `Q.lt` and `Q.le` decide the rational order exactly; `Q.eq` is structural equality of canonical forms and coincides with rational equality.
7. **Encodings are injective and total on accepted values.** `bigz_canonical_bytes` is `Z(sign_code, byte_len, big_endian_magnitude)` with sign codes `0, 1, 2` for zero, positive, negative, an unsigned 64-bit big-endian length, and a magnitude with no leading zero byte. `q_canonical_bytes` is the concatenation of the numerator and denominator encodings. Equal values have equal bytes and distinct values have distinct bytes. Rejected values have no encoding.

## 3. Semantics that consumers must not rely on

- Limb base, limb width, or the internal representation of `BigZ`.
- Intermediate magnitudes: `Q.add`, `Q.sub`, `Q.lt`, and `Q.le` scale by denominator cofactors and `Q.mul` cross-cancels, but the bound on intermediate growth is an implementation property, not a contract.
- The algorithm behind `bigz_divmod`. Long division is current; the retained shift-and-subtract routine exists only as a reference for the property probe.
- Cost. No operation promises a complexity class.
- Any relation between arithmetic acceptance and certificate acceptance. `Q.accepted()` says the value is a well-formed rational, nothing more.

## 4. Verification of the boundary

- `kernel/mojo/smoke/smoke_tests.mojo` executes the field laws, interval enclosure laws, `bigz_long_division_smoke`, and `q_cancellation_smoke` on every CI run.
- `kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo` draws deterministic pseudo-random operands and prints the canonical bytes of every result; `reference/python/arithmetic/exact_arithmetic_property_oracle.py` recomputes them with Python `int` and `fractions.Fraction` and compares token by token. Long division is checked in-process against the shift-and-subtract reference on every case, and every produced value is checked for canonical form. CI runs this as `pixi run property`.
- `tests/test_exact_arithmetic_hardening.py` checks the wiring above, the oracle's own encoder against the documented byte examples, and, when a `mojo` binary is present, runs the full comparison.

## 5. Stability promise

Names and semantics in sections 1 and 2 change only with a note in this file, a matching change in `docs/rational-interval-arithmetic-spec.md` section 6.2, and a passing property probe. Names outside section 1 carry no promise. Nothing in this file promotes any DEMO row of the specification's binding table, changes `backend.toml`, or affects `ProofGradeCertificateStatus`.
