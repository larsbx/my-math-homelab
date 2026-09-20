# The three-valued classifier

**Status:** certificates and their soundness, dated 2026-09-20. Both
soundness proofs below are elementary and are this repository's own; nothing
classical is imported. The completeness question the roadmap asks for is
**not** settled here, and section 6 says exactly what is missing.

## 0. What it decides

For a Gaussian-rational parameter `c` and a box `B` with exact rational
corners,

```text
G_c(B) -> OUT | IN | UNKNOWN
```

- `OUT` means every point of `B` has an unbounded orbit, so `B` misses `K_c`.
- `IN` means every point of `B` has a bounded orbit, so `B` is contained in
  `K_c`.
- `UNKNOWN` means neither certificate fired at this resolution. It is not a
  statement about `B`.

The implementations are `tools/box_classifier.py` and
`src/box_classifier.mojo`, and they are compared against each other the way
the corpus verdicts are.

## 1. `OUT`: the escape certificate on a whole box

The classifier iterates the box, and at each step tests

```text
N(B_n).lo > max(4, N(c))
```

the *lower* endpoint of the box's quadrance against the escape bound. The
enclosure `B_n` contains the true image set, so its minimum quadrance is at
most every true point's; if that minimum is past the bound then so is every
point. Each such point then carries the growth certificate of
`docs/escape-criterion.md`, whose ratio the verdict reports.

**Soundness.** If `N(B_n).lo > max(4, N(c))` then every `z` in `B` has
`N(f_c^n(z))` past the bound, hence a rational ratio `r > 1` by which its
quadrance grows at every later step, hence an unbounded orbit. So
`B ∩ K_c = empty`. []

## 2. `IN`: the trap certificate

A box `T` is a **trap of period `p`** when

```text
f_c^p(T) strictly inside T
```

where the image is the interval enclosure and *strictly* means both
coordinates shrink at both ends. The classifier then answers `IN` for any box
whose iterate lands inside `T`.

**Soundness.** Let `T` be a trap of period `p` and let `z` be in `T`. The
enclosure contains the true image, so `f_c^p(T)` is inside `T` as sets, and by
induction `f_c^{kp}(z)` is in `T` for every `k`. Every orbit point is
therefore in one of `T, f_c(T), ..., f_c^{p-1}(T)`, each a bounded set, so the
orbit is bounded and `z` is in `K_c`. If `f_c^n(B)` is inside `T` then the same
holds for every point of `B` from step `n` on, and a finite prefix cannot make
an orbit unbounded, so `B` is inside `K_c`. []

**No attracting cycle is named.** The roadmap phrased this certificate as
"attracting-cycle certificates plus basin pullback", and a trap is what that
amounts to once the analytic content is removed: strict invariance is checked
directly, so no multiplier, no linearisation, and no theorem about basins is
needed. The trap is a declared witness, verified before any verdict rests on
it, exactly as a cycle witness is.

## 3. `UNKNOWN`: the residual

`UNKNOWN` carries no certificate and no trap, and the census in
`docs/classifier-census.md` reports it as its own column. A box counted there
is one the classifier refused at this resolution -- **not** one known to meet
the Julia set. Reading the residual as an approximation of `J_c` is the
mistake this column exists to prevent.

## 4. Two properties worth stating

**Refinement never reverses a decision.** Both certificates are inherited by
sub-boxes: a sub-box's quadrance lower bound is at least its parent's, and a
sub-box of a box that lands in `T` also lands in `T`. So refining can turn an
`UNKNOWN` into a decision and can never turn a decision into anything else.
`test_a_decided_verdict_survives_refinement` checks this over a whole grid.

**A wrong witness costs an `UNKNOWN`.** The trap is verified by the classifier
before it is used; an unverified one is ignored rather than believed, so a
mistaken witness can only lose information, never produce a false `IN`.

## 5. Where it stops, and why that is correct

At a **parabolic** parameter there is no trap, and `trap_candidate` returns
nothing however far it shrinks. That is not a gap in the search: a parabolic
fixed point is on the boundary of its own basin, and no box around it is
strictly invariant. The classifier therefore answers `UNKNOWN` on the interior
of a parabolic basin, which is the fail-closed answer -- it declines rather
than guessing -- and `test_the_parabolic_parameter_has_no_trap` pins the
behaviour so it cannot quietly change.

At a parameter with **empty interior** (`dendrite`, `chebyshev`, `escaping`)
there is nothing to trap and `IN` is never reported, which the census shows.

## 6. Completeness: not proved here

The roadmap's Phase 1 deliverable is a **completeness proof for hyperbolic
Gaussian-rational `c`**: every box whose closure misses `J_c` is classified at
some resolution. This document does not supply it. What exists is soundness,
both directions, and a census that is consistent with completeness without
being evidence for it.

Two things are missing, and they are different.

1. **`OUT` completeness.** Every point outside `K_c` escapes, so every box
   whose closure misses `K_c` eventually has an iterate past the bound. The
   gap is the enclosure: a box's image under one step has width roughly
   `2 |z| w + w^2`, so widths can grow faster than the orbit separates, and
   the certificate fires on the *enclosure*, not on the points. What is needed
   is a bound saying that refining the box far enough makes the enclosure
   track the true image closely enough for the test to fire. That is a
   statement about interval arithmetic, not about dynamics.
2. **`IN` completeness.** For hyperbolic `c` the interior of `K_c` is the union
   of the basin's preimages, and every compact subset of the basin reaches the
   trap in finitely many steps. Turning that into a statement about boxes
   needs the same enclosure control as above, plus the observation that a
   compact subset is covered by finitely many boxes of a given resolution.

Both reduce to one missing lemma about how enclosure width propagates, which
is why they are listed together and why neither is claimed. Until it exists,
the classifier is sound and its completeness is a conjecture with a census
beside it.

## 7. What this document does not claim

It does not claim completeness, does not claim the residual approximates
`J_c`, and does not discharge any block of `docs/J1_proof_definition.md`. The
census is a record of behaviour at one resolution, not evidence about the
limit.
