# Separating the exponent, and what it lifts

**Status:** derivation and measurement, dated 2026-09-20. It closes the
question `docs/taylor-models.md` section 5 left open, and the answer is not
the one that note expected.

## 1. The ceiling was the value, not the method

An escaping orbit reaches magnitude `2^(2^n)` after `n` steps. Writing that
down exactly costs `2^n` bits, so the coordinate budget of
`reference/budget.py` is spent at around step twelve **whatever the arithmetic
does**. Measured, on the ray itinerary of `docs/ray-certificates.md` at
`c = 0`:

| starting radius | plain boxes | Taylor, exact | Taylor, coefficients rounded |
| --- | --- | --- | --- |
| `10^-3` | 8 | 11 | 11 |
| `10^-6` | 12 | 12 | 11 |
| `10^-12` | 11 | 11 | 11 |

Every method stops in the same place, and narrowing the starting box past
`10^-6` *loses* digits rather than gaining them. Taylor models were the wrong
tool for this: they reduce width, and width was not what ran out.

Rounding the coefficients did exactly what it was built to do -- the largest
coefficient went from 5696 bits to 274 at step eight, with no measurable
change in width -- and it did not move the ceiling, because the residue is
the *exponent*, and an exponent stored inside a rational is stored in unary.

## 2. Two pieces instead of one

A **scaled box** is a mantissa box together with an integer exponent,
standing for `mantissa * 2^exponent`. After each step the mantissa is
renormalised to `O(1)` and rounded outward to a bounded precision:

```text
(m 2^e)^2 + c  =  (m^2 + c 2^(-2e)) 2^(2e)
```

The parameter is brought into the mantissa's scale rather than the value
being brought out of it. Where the exponent is large, `c 2^(-2e)` is tiny and
the outward rounding absorbs it.

**Soundness.** Scaling a box by a power of two is exact -- it moves the
endpoints and nothing else -- so renormalisation loses nothing. Rounding is
outward, so the mantissa only ever grows, and `mantissa * 2^exponent`
therefore still encloses everything it did. []

**The digit is scale invariant.** `2^exponent` is positive, so it cannot move
a point across the real axis: the sign of the mantissa's imaginary part is
the sign of the value's. That is why the itinerary can be read off the
mantissa alone, and it is the reason this works at all.

This is section 2.1's `E = F` endpoint set, which the specification admits and
describes as needing rounding-mode control on the hardware. It does not: a
dyadic with a bounded numerator is the same idea done exactly, and the
rounding direction is a floor or a ceiling over `Z`, decided rather than
configured.

## 3. What it lifts

Digits of the external angle obtained at `c = 0`, by starting radius:

| starting radius | exact boxes | scaled, 53-bit mantissa | scaled, 200-bit |
| --- | --- | --- | --- |
| `10^-3` | 8 | 8 | 8 |
| `10^-6` | 12 | 15 | 15 |
| `10^-12` | 11 | 28 | 28 |
| `10^-24` | 10 | 34 | **58** |
| `10^-48` | 9 | 34 | **117** |

Two things changed, and the second is the one that matters.

**The exact column goes the wrong way.** A narrower starting box gives
*fewer* digits, because the budget is spent writing the input down. That is
an accounting artefact standing where a certificate's real constraint should
be, and it is gone.

**The scaled columns go the right way, and then the mantissa binds.** At 53
bits the depth saturates at 34: the exponent no longer costs anything, so
what runs out next is the mantissa. Widen it to 200 bits and the same
starting box yields 117 digits. Precision is a dial again rather than a
wall.

An earlier draft of this note said precision past 53 bits changed nothing.
That was measured at `10^-12` and is true there, where the box's own width
binds first; it is false at every narrower radius, and the table above is the
corrected measurement.

## 3.1 The power that must not be built

`c 2^(-2e)` is the term that brings the parameter into the mantissa's scale,
and computing it directly defeats the whole exercise: by step twenty-eight
`2^(2e)` is a sixty-seven megabyte integer, and it multiplies a parameter
that stopped mattering twenty steps earlier. Twenty-eight steps took three
seconds that way.

Where the term is smaller than the mantissa's last bit, a symmetric box
around zero encloses it, and the test for that is a comparison of bit
lengths, so nothing large is built to decide it. Forty steps now take five
milliseconds.

## 4. What this does not claim

It does not make the orbit cheaper: the exponent still doubles every step,
and after `n` steps it is a `2^n`-sized integer stored in `log` space rather
than a `2^n`-bit numerator. It does not apply to the classifier, the
separator, or any certificate that needs an exact value rather than a decided
side; those still use `reference/interval_box.py` and are unaffected. It does not
replace Taylor models, which remain the right tool for width and the wrong
one for magnitude. And rounding a mantissa is a *widening*: a scaled box is
never tighter than the exact box it came from, only affordable.
