# The enclosure-width lemma, and completeness

**Status:** derivation, dated 2026-09-20. It supplies the lemma that section 6
of `docs/three-valued-classifier.md` named as missing, and the completeness
theorem that follows from it. The theorem is this repository's own and
unconditional. The corollary that turns it into the roadmap's Phase 1 claim is
**not** unconditional: it rests on one named classical import, and section 6
says which.

## 0. The gap this closes

The classifier's certificates fire on the *enclosure*, not on the points it
encloses. Soundness is therefore free, and completeness is not: refining a box
shrinks its width, but each step of the interval map can widen it again, and
nothing so far ruled out the widening winning the race. In the notation below,
a box of radius `r` around a point `a` has image radius roughly `2 |a| r`, so
widths grow wherever `|a| > 1/2`, which is most of the region of interest.

What rescues it is that the growth is *bounded by a constant per step* once
the iterates are confined, so over a **fixed** number of steps the enclosure
is a fixed multiple of the starting radius. Refinement then wins because the
number of steps is chosen first and the radius second.

## 1. Notation

For a box `B = X × Y` with exact rational corners write `rad(B)` for half its
larger coordinate width, the radius in the sup norm, and say `B ⊆ M` when
every coordinate of every point of `B` has magnitude at most `M`. Let `F` be
the interval step of `tools/box_classifier.py`,

```text
F(B) = B^2 + c,    re F = X^2 - Y^2,    im F = 2 X Y
```

and `f` the point map `z -> z^2 + c`. Interval arithmetic is inclusion
monotone, so `f(B) ⊆ F(B)` and, by induction, `f^n(a) ∈ F^n(B)` for every
`a ∈ B`.

## 2. Lemma (one step)

**Let `M >= 1`, `B ⊆ M`, `c ⊆ M`, and `r = rad(B)`. Then**

```text
rad(F(B)) <= 4 M r + 2 r^2 <= 6 M r
```

*Proof.* Write `r_x = rad(X) <= r` and `r_y = rad(Y) <= r`.

(i) *The square of one coordinate.* The exact range of `x^2` over `X` has
radius at most `2 M r_x`. If `0` is not in `X` the range is
`[min^2, max^2]`, of radius `(max + min)(max - min)/2 <= M · 2 r_x`. If `0` is
in `X` the range is `[0, max(x_1^2, x_2^2)]`, and both endpoints of `X` are
then at most the width `2 r_x` in magnitude, so the radius is at most
`2 r_x^2 <= 2 M r_x`, using `r_x <= M`.

(ii) *The real part.* `X^2 - Y^2` has radius at most `2 M r_x + 2 M r_y <= 4 M r`.

(iii) *The imaginary part.* For intervals `X = a ± p` and `Y = b ± q` the
product satisfies `X Y ⊆ a b ± (|a| q + |b| p + p q)`, so `X Y` has radius at
most `M r + M r + r^2`, and `2 X Y` at most `4 M r + 2 r^2`.

(iv) The larger of (ii) and (iii) is (iii), and adding the singleton `c`
changes no width. Finally `r <= M`, because `B ⊆ M`, so `2 r^2 <= 2 M r`. []

## 3. Corollary (many steps)

**If `F^k(B) ⊆ M` for `k = 0, ..., n-1`, then**

```text
rad(F^n(B)) <= (6 M)^n rad(B)
```

**and every point of `F^n(B)` is within sup-distance `2 (6 M)^n rad(B)` of
`f^n(a)`, for every `a ∈ B`.**

*Proof.* The radius bound is section 2 applied `n` times. For the second part,
`f^n(a)` lies in `F^n(B)` by inclusion monotonicity, and two points of a box
of radius `s` are within `2 s` of each other in the sup norm. []

## 4. Two lemmas: the iterates stay confined, and quadrance moves slowly

**(a) If `f^k(a) ⊆ M - 1` for `k <= n`, and `2 (6 M)^n rad(B) <= 1`, then
`F^k(B) ⊆ M` for every `k <= n`.**

*Proof.* Induction on `k`. The hypothesis of section 3 holds up to `k - 1`, so
every point of `F^k(B)` is within `2 (6 M)^k rad(B) <= 1` of `f^k(a)`, whose
coordinates are at most `M - 1`. []

**(b) If `w ⊆ M` and `w' ⊆ M` are within sup-distance `e <= 1`, then**

```text
|N(w') - N(w)| <= 6 M e,        N(x, y) = x^2 + y^2
```

*Proof.* `|x'^2 - x^2| = |x' - x| (|x'| + |x|) <= e (2 M + e) <= e (2 M + 1)`,
and `2 M + 1 <= 3 M` because `M >= 1`, so each coordinate contributes at most
`3 M e`. []

Lemma (a) is what makes the corollary usable: its hypothesis is not an
assumption about the enclosure but a consequence of the box being small
enough, and "small enough" is the rational quantity `sufficient_radius`
computes. Lemma (b) is what lets the escape test be read on the enclosure:
the test is a quadrance against a rational bound, so what section 3 gives in
sup-distance has to be converted into a quadrance gap, and `6 M` is the
rational conversion factor. No modulus and no square root enter.

## 5. Theorem (refinement decides), finite and unconditional

Fix `M >= 1`, a step count `N >= 0`, and a rational margin `0 < delta <= 1`.
Put

```text
L = (6 M)^N,        s = delta / (12 M L)
```

**Let `a` satisfy `f^k(a) ⊆ M - 1` for `k <= N`, and let `B` be a box
containing `a` of radius below `s`. Then**

- **(OUT)** **if `N(f^N(a)) >= R + delta`, where `R` is the escape bound, the
  classifier answers `OUT` at step `N` at the latest;**
- **(IN)** **if `f^N(a)` lies in a verified trap `T` at sup-distance at least
  `delta` from everything outside `T`, the classifier answers `IN`.**

*Proof.* `2 L rad(B) < 2 L s = delta / (6 M) <= 1`, so section 4(a) confines
every enclosure to the `M` square, and section 3 puts every point `w` of
`F^N(B)` within sup-distance `e < delta / (6 M)` of `f^N(a)`.

(OUT) By 4(b), `N(w) > N(f^N(a)) - 6 M e > (R + delta) - delta = R`. The
*whole* enclosure is past the bound, which is what the escape test reads.

(IN) `e < delta / (6 M) <= delta`, so every `w` is in `T`, hence
`F^N(B) ⊆ T` and the trap certificate fires. []

One theorem, one constant, both directions, and nothing in it is a limit: `s`
is a rational that `refinement_radius` computes and a caller can check.

## 6. Corollary (completeness), and where the import enters

**Let the closure of `B_0` be either disjoint from `K_c` or inside the basin
of a verified trap. Then there is a rational `s > 0` such that every sub-box
of `B_0` with radius below `s` is classified.**

*Proof.* Only to supply section 5's `N`, `delta`, and `M`, uniformly over the
closure, which is compact.

*Disjoint from `K_c`:* every point has an unbounded orbit, so some iterate has
quadrance above `R`, and by `docs/escape-criterion.md` the certificate that
fires there fires at every later step. The sets `U_n = {z : N(f^n(z)) > R}`
are therefore open and increasing, so a single `U_N` covers the closure, and
`delta = min(1, min over the closure of N(f^N) - R)` is positive by continuity
on a compact set.

*Inside the basin:* `f^N(closure B_0) ⊆ interior T` for some `N`, and `delta`
is the minimum of `1` and the distance from that compact image to the
complement of `T`, again positive.

Either way take `M` to be one more than the largest sup-norm coordinate
reached by `f^k` on the closure for `k <= N`, and section 5 decides every
sub-box below `s`. []

The two hypotheses are exactly what the classifier can see. Reaching the
roadmap's statement -- *every* box whose closure misses `J_c` -- means knowing
that the interior of `K_c` is the trap's basin:

> **Corollary (hyperbolic completeness).** For a hyperbolic parameter with
> attracting cycle and a trap `T` containing a neighbourhood of that cycle,
> every box whose closure misses `J_c` satisfies one of the two hypotheses
> above, so it is classified at some resolution.

The step from "interior of `K_c`" to "attracted to the cycle" is classical and
is **not** proved here. It enters as the tag
`FatouHyperbolicInteriorIsTheBasin`, which no literature gate has judged. So
this last corollary is conditional, and section 5 and section 6 are not.

## 7. What the bounds cost, and what they do not say

The constants are pessimistic by design. At `M = 4` over four steps the factor
`(6M)^4` is `331776`, so the theorems ask for a radius around `10^-7` where
the classifier in practice decides at `10^-2`. That gap is the usual distance
between a worst-case bound and behaviour, and closing it is an optimisation,
not a correctness question.

`tools/enclosure_bound.py` and `src/enclosure_bound.mojo` compute each
quantity above exactly and agree: the step factor, the iterated bound,
section 4(b)'s quadrance drift, and section 5's `s` itself, as
`refinement_radius`.

`refine_until_decided` in `tools/box_classifier.py` is the constructive side:
it subdivides the undecided part and reports the share of the original box
still unresolved. On a box straddling the quadrance-1 locus at `c = 0` -- which
`docs/terminology-registry.md` forbids calling anything else -- that share
falls from `1` to about `0.09` over six levels. **That is behaviour, not
evidence**: the theorems are proved above, and a census neither strengthens
nor weakens them.

## 8. What this does not claim

It does not claim the residual approximates `J_c`, does not settle
completeness at a parabolic parameter, where no trap exists and section 5's
`IN` branch has no hypothesis to offer, and does not discharge any block of
`docs/J1_proof_definition.md`.
