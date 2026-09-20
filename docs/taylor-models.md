# Taylor models, and an honest measurement of what they buy

**Status:** derivation and measurement, dated 2026-09-20. Sections 1 to 3 are
proved here; section 4 is measured, and it does not say what the
specification's mitigation line implied.

## 1. The object

A **Taylor model** over a box is a jet in the local variable together with an
interval remainder, guaranteeing

```text
for every z = centre + e with e in domain,    g(z) in p(e) + remainder
```

`tools/jet.py` and `src/jet.mojo` supply `p`, exactly over `Q(i)`. What is
added here is the remainder and the guarantee. A plain enclosure treats every
occurrence of a variable as independent, so widths inflate through an iterated
map; a model carries the correlation in `p` and absorbs only what the
truncation drops.

## 2. Soundness, one operation at a time

**The variable.** `g(z) = z = centre + e = p(e)` exactly, so the remainder is
zero and stays zero until a truncation.

**Addition.** `(p + I) + (q + J) = (p + q) + (I + J)` componentwise. []

**Multiplication.** Write the full convolution `pq` and split it at the
order:

```text
(p + I)(q + J) = pq_low + [ pq_high + p J + I q + I J ]
```

Every term of the bracket is *enclosed*, not dropped: `pq_high` over the
domain, the two cross terms with each polynomial enclosed, and the product of
the remainders. Since each is an enclosure of the corresponding exact term
and the identity above is exact, the bracket encloses the whole difference. []

**The step.** `z^2 + c` is multiplication followed by adding a constant to the
jet's constant term, and neither changes the remainder's justification. []

`tests/test_taylor.py` samples points of the box and checks their iterates lie
inside the enclosure -- 1440 of them, none outside -- which is not a proof but
is what catches a proof written down wrongly.

## 3. Evaluation is term by term, not Horner

Section 2.5 of `docs/rational-interval-arithmetic-spec.md` requires Horner,
and is right about the case it is describing: a polynomial in a variable that
occurs once. A Taylor polynomial over a centred box is the other case. The
variable occurs in every term, Horner's nesting multiplies the same box by
itself repeatedly, and the dependency it induces costs more than the nesting
saves. Measured, on the cases of section 4, Horner is wider by

| case | order 2 | order 4 |
| --- | --- | --- |
| escaping | `1.008x` | `1.008x` |
| basilica | `1.091x` | `1.106x` |
| repelling | `1.215x` | `1.401x` |

Each power is taken by repeated squaring with the **sharp** square, for the
same reason one level down: `X * X` is wider than `X^2`.

## 4. What they buy, measured

Width of the real part of the enclosure after six steps, the same starting box
for both methods.

| case | Taylor | plain | verdict |
| --- | --- | --- | --- |
| escaping orbit, `c = 0`, radius `10^-3` | `1.22e18` | `7.69e18` | Taylor **6.3x tighter** |
| basilica, centre `1/2`, radius `1/32` | `0.1814` | `0.1926` | Taylor `1.06x` tighter |
| repelling fixed point, `c = 0`, centre `-1`, radius `1/64` | `4.28` | `3.14` | **plain `1.36x` tighter** |

**Taylor models are not uniformly better, and the specification's mitigation
line implied that they were.** They win where wrapping compounds over a long
expanding run, which is the escaping case and is exactly where the ray
itinerary of `docs/ray-certificates.md` loses digits. They lose where a single
sharp square is already close to optimal, which is a quadratic map at `c = 0`
near a repelling fixed point: there the plain step performs one exact
operation and the model pays for a remainder it did not need.

The reason the margin is as small as it is elsewhere is worth recording: most
of the available win was already collected when `ComplexIQ.square` was
corrected from `self.mul(self)` to the sharp coordinate form earlier the same
day. A model competes against a sharp square, not against a careless one.

**Higher order is not free.** Beyond order four nothing improves in any case
measured, and at large radius a higher order was *worse* before the evaluation
was fixed. The order that pays is the one that captures the step's own degree;
for `z^2 + c` that is two.

## 5. What this does not claim

It does not claim a tighter enclosure anywhere it has not been measured. It
does not reduce coordinate bit size -- the exact rationals still square every
step, so the budget of `tools/budget.py` binds exactly as before, and a model
costs *more* bits than a plain box for the same depth. It does not implement
affine arithmetic, which stays out of scope. And it changes no certificate:
every verdict in this repository still rests on the enclosure it always did,
and a Taylor model is one more way to compute one.
