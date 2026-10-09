# Auditing the exact cubic kernel — correctness, envelope, cost, 2026-09-20

A pass over the arithmetic the overlap and coincidence work rests on:
`psc/perron_field3.mojo` (exact `Z[beta]` arithmetic and the Perron sign
oracle), `psc/pisot.mojo` (the PIP screen), `finite_linear_algebra/mat3.mojo`,
`psc/automata.mojo`, and the state bound in `psc/pisot_state.mojo`.

Three questions, in order: is it right, what is its domain, and where does its
time go. Everything below is measured or proved; the differential dumps and
their oracles are reproducible from the recipe at the end.

## 1. Correctness: exact, or it raises — never wrong

The kernel's own claim is that every theorem-facing operation is checked and
that a successful run is exact. That was tested against oracles that share no
method with it.

**Small-coefficient sweep.** 20 distinct corpus cubics against a 9^3
coefficient grid: 14,580 `sign_at_perron` verdicts, checked against an exact
rational oracle that isolates `beta` by bisection on `chi` over `(1, B]` and
then brackets `Q` over the isolating interval by its endpoints and vertex.

```
compared: 14580  agree: 14580  disagree: 0  raised: 0
```

**Wide-magnitude sweep.** The harder question is whether the kernel ever wraps
*silently* at large coefficients instead of raising, which would be a
correctness defect rather than a robustness one. 21,620 records over
`sign_at_perron`, `cubic_mul`, `cubic_mul_beta` and `charpoly`, at coefficient
magnitudes `10^2, 10^4, 10^6, 10^9, 10^12, 10^15`, each checked against a
Python big-integer oracle (polynomial product reduced mod `chi`; `c2 = -tr`,
`c1 = sum of principal 2x2 minors`, `c0 = -det`).

| operation | compared | agree | disagree | raised |
| --- | --- | --- | --- | --- |
| `charpoly` | 20 | 20 | **0** | 0 |
| `sign_at_perron` | 2,488 | 2,488 | **0** | 4,712 |
| `cubic_mul` | 4,792 | 4,792 | **0** | 2,408 |
| `cubic_mul_beta` | 7,200 | 7,200 | **0** | 0 |

**Zero disagreements at any magnitude.** The fail-closed discipline holds end
to end: where the kernel answers it is exact, and where it cannot it raises.

Of `cubic_mul`'s 2,408 refusals, 2,406 were *necessary* — the true product
genuinely leaves `Int64`. Only 2 were conservative, and both had a true value
within 13% of `Int64.MAX`, refused because the degree-4 coefficient before
reduction overflowed. That is as tight as the algorithm can be without a
wider intermediate.

Checked by reading, all sound:

- `_checked_mul` refuses a product equal to exactly `Int.MIN` — conservative,
  never wrong.
- The Sturm–Tarski chain starting `P, rem(P'Q, P)` is sound because the
  remainder agrees with `P'Q` at every root of `P`, so the Cauchy index is
  preserved; the omitted pseudo-division scales are positive, so the sign
  variations are unchanged.
- `_perron_integer_bound = max|chi_i| + 1` is a valid Cauchy bound, and for a
  Pisot cubic `beta` is the only root in `(1, B]`.
- `is_pisot_charpoly` case B: `beta |z|^2 = det`, so `|z| < 1` iff
  `det < beta`; the quadratic factor `(t-z)(t-z_bar)` is positive on all of
  `R`, so `sign chi(t) = sign(t - beta)` and the test is `chi(det) < 0`. Its
  precondition — irreducibility, which is what excludes a root at exactly 1 —
  is discharged by every one of its three production callers.
- `charpoly` by Newton's identity `c1 = (t1^2 - t2)/2` agrees with the
  principal-minors formula on all 20 corpus cubics.
- `is_primitive` checks `M^1..M^5`; Wielandt's exponent for `n = 3` is
  `n^2 - 2n + 2 = 5`.

## 2. The envelope: the ceiling belonged to the rung, and is gone

The machine-integer rung of `sign_at_perron` decides coefficients up to
roughly `2 * 10^6` and cannot go past that. On the family `beta^2 - p beta + p`
over `x^3 - x - 1`, bisection puts its exact threshold at **458,007**. The
binding term is `A * A * A * c * c` in `_quadratic_terminal_sign`'s terminal
resultant `R`, a cubic form in `(A, B, C)` with `A, B, C` linear in `Q`'s
coefficients — so the chain costs one cube of the input range, and a fixed
width buys a fixed ceiling.

Measured, that ceiling never binds. Instrumenting every call:

| driver | `sign_at_perron` calls | largest coefficient seen |
| --- | --- | --- |
| coincidence-formula-census | 23,762,617 | **66** |
| overlap-contracting-census | 278,662 | **36** |

Four orders of margin — but one guard was written as though there were none:

> `ENTRY_BOUND = 1 << 52` in `psc/pisot_state.mojo` admitted state coordinates
> about `2 * 10^9` times larger than the sign query the reserve comparison ends
> in could settle. A coordinate that passed it near `2^52` produced a
> `CubicElt` the oracle refused, so the run raised anyway — fail-closed, never
> a wrong answer, but the bound named in the source was not the bound that
> governed.

**Fixed, by making the function total rather than by lowering the bound.**
`sign_at_perron` is now a three-rung ladder, and the coefficient range belongs
to rung 2 alone:

1. `_sign_without_remainders` — the coefficient signs, then a bracket over the
   integer enclosure of `beta`. Answers three calls in five (§3).
2. the Sturm–Tarski chain in machine integers — exact, fast, bounded.
3. `psc/perron_root_sign.mojo` — the same sign from a rational enclosure of
   `beta` over unbounded `finite_exact` arithmetic.

Rung 3 is reached through a *static* test, `_remainder_chain_fits`, which asks
whether `32 K^3 C^2` fits in `Int` for `C = max(|chi_i|, 1)` and
`K = H (C^2 + 7C + 3)` — a bound on the largest intermediate the chain can
form. It is deliberately not a `try` around the chain: the chain also raises on
a malformed field or a lost coprimality, and those are defects that must stay
audible rather than be quietly rerouted. The price is that a band of
coefficients the chain would in fact have settled goes to the enclosure
instead, which is exact and merely slower — and which nothing in the corpus
enters, since the largest coefficient seen is 66.

Rung 3 terminates, at a depth known before it starts. `chi` is irreducible of
degree three and `deg Q <= 2`, so `Res(chi, Q) = prod_i Q(beta_i)` is a nonzero
integer; `beta` is Pisot, so its conjugates lie in the open unit disc and
`|Q(beta_i)| <= 3H`. Hence

```
|Q(beta)| >= 1 / (9 H^2).
```

The root is bracketed between consecutive integers, so `k` bisections leave
width `2^-k`, over which the natural Horner extension of `Q` has width at most
`3 H B 2^-k`. Any `k` with `2^k > 27 H^3 B` puts that below the separation, and
an interval of width under `|Q(beta)|` that contains `Q(beta)` cannot contain
zero. `_sufficient_refinements` returns such a `k` from bit lengths alone;
exhausting it is a defect and raises, never an inconclusive verdict.

Re-running the same wide-magnitude differential of §1 against the ladder:

| `sign_at_perron` | before | after |
| --- | --- | --- |
| decided | 2,488 | **7,200** |
| refused | 4,712 | **0** |
| disagreed with the oracle | 0 | **0** |

Every one of the 4,712 newly decided cases — at magnitudes to `10^15` — agrees
with the independent oracle. `sign_at_perron` now decides every nonzero element
of `Z[beta]` whose coordinates fit in `Int`, so `ENTRY_BOUND` governs the
stepping arithmetic it was written for and nothing narrower sits behind it.

The ladder costs nothing on the happy path: three runs of the coincidence
census at 55.82 s, 48.23 s, 47.47 s against 50.31 s, 50.46 s, 47.89 s for the
shortcut alone, with output unchanged — the static test is ten integer
operations on the 40% of calls that reach it.

`psc/perron_interval.mojo` keeps its role — the field's own type, and one
enclosure cached per field — and now delegates its bracketing to
`psc/perron_root_sign.mojo` rather than carrying a second copy of it.

## 3. Where the time goes: 60% of the hot primitive was wasted

`sign_at_perron` is the hot primitive of the coincidence census: 23.76M calls
in a ~58s run. Classifying each call by the cheapest method that would have
sufficed:

| class | calls | share |
| --- | --- | --- |
| coefficients all of one sign | 7,535,437 | 31.7% |
| endpoint bracket over `[1, B]` | 6,724,655 | 28.3% |
| genuinely needs the remainder chain | 9,502,525 | 40.0% |

Three in five calls built a degree-5 resultant they did not need.

## 4. What changed

### Landed — four changes, all measured

**(a) A two-step shortcut at the front of `sign_at_perron`.** Before any remainder is
built: if the coefficients are all of one sign the answer is that sign, since
`beta > 1 > 0`; otherwise, if the vertex of the quadratic falls outside
`(1, B)`, the two endpoint values bound `Q` over the whole enclosure and a
bound excluding zero proves the sign. Both are exact and one-sided — a `0`
return means *undecided here*, never *zero* — and neither can narrow the
decidable domain: the first does no arithmetic at all, and the second falls
through on an overflow the authoritative path is free to report itself.

Paired alternating runs of the coincidence census, same container:

| run | baseline | shortcut |
| --- | --- | --- |
| 1 | 56.70 s | 50.31 s |
| 2 | 59.56 s | 50.46 s |
| 3 | 58.90 s | 47.89 s |
| **mean** | **58.39 s** | **49.55 s** |

**−15.1%**, with every pair favouring it. Census output byte-identical.

**(b) A hash index in `psc/automata.mojo`.** `_subset_index` and `minimised`
both scanned a `List[String]` linearly, and `minimised`'s inner loop had no
early exit, so it always scanned the full class list. Both are now
`Dict[String, Int]`. Indices are still assigned by first encounter, so the
automata are *identical*, not merely language-equal — which is what the new
regression pins.

| numeration-conversion-census | scan | hash |
| --- | --- | --- |
| `PROJECTABLE = 200` (the cap then) | 11.58 s | 10.95 s |
| `PROJECTABLE = 1500` (the cap now, (d)) | 21.78 s | 18.79 s |

**(c) The unbounded rung, which removes the envelope.** §2 in full: a new
`psc/perron_root_sign.mojo`, reached through a static fits-test so defects stay
audible, turning `sign_at_perron` from bounded to total. This is the one change
here that alters an answer — on inputs that previously raised, and only
there — and the wide differential confirms every newly decided case.

(a) to (c) are guarded by new regressions: six in `tests/test_exact_interval.mojo`
(among them a 2,184-case differential of the fixed-width oracle against the
unbounded rational one, the shortcuts' contracts, a mixed-sign element that must
still reach the chain, and the absence of a coefficient ceiling up to `2^62`)
and one in `tests/test_automata.mojo`; (d) is guarded by the census's own three
`grep -Fx` pins, moved to the counts it now reports. All 39 test files,
`verify.mojo`, all six governance checks, and every census line but those three
pass unchanged.

### Also landed — the projection cap

**(d) `PROJECTABLE = 200` was over-conservative by measurement.** The
conversion census argued that carrying the letter map across "costs the
conversion's size squared", and capped at 200 — which left 27 of 115
conversions unprojected. The growth is real; the constant is not what the cap
assumed:

| `PROJECTABLE` | letter maps carried across | too large | seconds |
| --- | --- | --- | --- |
| 200 (was) | 88 | 27 | 10.9 |
| 400 | 107 | 8 | 13.9 |
| 800 | 112 | 3 | 16.0 |
| **1500 (is)** | **115** | **0** | 13.4 – 20.8 |

Full coverage costs a handful of seconds on a census that is nowhere near CI's
critical path, and reports **13,800 letter verdicts with 0 mismatches**, up
from 10,560. The cap now sits above every conversion this corpus and stride
produce — the largest minimised one is 1421 — so the skipped count is zero and
the outcome separation stands ready for a corpus that produces a larger one.
Three `grep -Fx` pins moved with it; the largest letter map grew from 198 to
1015, which is the object the extra 27 specimens were hiding.

Both of the first pass's open recommendations are therefore closed. The
rational-interval layer, which answered where the fixed-width chain refused and
had no production caller, is now rung 3 of `sign_at_perron` (§2); the
projection cap is (d) above. Nothing from this audit is left outstanding.

## How this was measured

- **Differential dumps.** Two Mojo drivers outside the repository tree (Mojo
  resolves `psc.*` from anywhere with `-I .`) print one record per operation —
  inputs, and either the kernel's answer or `RAISE`. Python checkers replay
  every record against big-integer oracles. A refusal is classified by asking
  whether the true value fits in `Int64`: if it does the refusal was
  conservative, if not it was necessary.
- **Call counts and coefficient ranges.** `sign_at_perron` temporarily prints
  one line per call; the census is run and the lines aggregated. The
  instrumentation is reverted before anything is committed.
- **Timings.** Paired alternating runs on one container, never against CI
  numbers, per the discipline of
  `docs/census-performance-handoff-2026-09-18.md`: a probe must print an
  aggregate depending on every value it computes, or the work is optimised
  away and the layer measures as free.
