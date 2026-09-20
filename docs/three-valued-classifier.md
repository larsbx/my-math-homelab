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
f_c^p(T) inside T
```

where the image is the interval enclosure and *inside* is inclusion, not
strict inclusion. The classifier then answers `IN` for any box whose iterate
lands inside `T`.

**Soundness.** Let `T` be a trap of period `p` and let `z` be in `T`. The
enclosure contains the true image, so `f_c^p(T)` is inside `T` as sets, and by
induction `f_c^{kp}(z)` is in `T` for every `k`. Every orbit point is
therefore in one of `T, f_c(T), ..., f_c^{p-1}(T)`, each a bounded set, so the
orbit is bounded and `z` is in `K_c`. If `f_c^n(B)` is inside `T` then the same
holds for every point of `B` from step `n` on, and a finite prefix cannot make
an orbit unbounded, so `B` is inside `K_c`. []

**No attracting cycle is named.** The roadmap phrased this certificate as
"attracting-cycle certificates plus basin pullback", and a trap is what that
amounts to once the analytic content is removed: invariance is checked
directly, so no multiplier, no linearisation, and no theorem about basins is
needed. It is also why inclusion needs no strictness. Strict inclusion is the
hypothesis of the contraction theorems (section 2.4 of
`docs/rational-interval-arithmetic-spec.md`), which buy an attracting
periodic point inside `T`. This certificate claims no such point: boundedness
is all it needs, and the induction above never uses strictness. The trap is a declared witness, verified before any verdict rests on
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

At a **parabolic** parameter `trap_candidate` still returns nothing however
far it shrinks, and that is a fact about the search, not about the parameter.
The search shrinks a box toward its own midpoint; a parabolic petal is
anchored at the parabolic fixed point and centred nowhere, so a centred search
walks away from it.

The petal itself is a trap. At `c = 1/4`, with the parabolic fixed point at
`1/2`,

```text
T = [1/4, 1/2] x [-1/4, 1/4],    F(T) = T
```

exactly, in the repository's own interval arithmetic. `F(T) = T` is inclusion
and not strict inclusion, which is precisely the case the certificate used to
reject, and rejecting it was the error: the soundness argument of section 2
never used strictness. So the classifier answers `IN` on the interior of a
parabolic basin like any other, and `TRAPS["cauliflower"]` pins the witness.

Two things had to be true for this box to be seen at all. The certificate had
to ask for inclusion rather than strict inclusion, and the enclosure had to be
sharp enough to notice: with the complex square in the expanded form
`Z * Z` the image of `T` overshoots by a sixteenth and the inclusion is lost.
Specification section 2.5 is about exactly that, and the kernel now squares
each coordinate by the rule of section 2.2.

At a parameter with **empty interior** (`dendrite`, `chebyshev`, `escaping`)
there is nothing to trap and `IN` is never reported, which the census shows.

## 6. Completeness

The roadmap's Phase 1 deliverable is a **completeness proof for hyperbolic
Gaussian-rational `c`**: every box whose closure misses `J_c` is classified at
some resolution. The missing ingredient was a bound on how enclosure width
propagates under a step, and it is now proved, with explicit rational
constants, in `docs/enclosure-width-lemma.md`. One theorem follows, in both
directions at once and unconditional:

> **Refinement decides.** A box is classified once refined below
> `delta / (12 M (6 M)^N)`, where the orbit of one of its points clears the
> escape bound by `delta` at step `N`, or lands `delta` inside a trap at step
> `N`, and stays inside the `M` square throughout.

The `IN` direction is about the **basin of the trap**, which is what the
classifier can see. The roadmap's statement is the corollary that the trap's
basin is the whole interior of `K_c` for a hyperbolic parameter, and that step
is classical and is **not** proved here: it enters as the tag
`FatouHyperbolicInteriorIsTheBasin`, which no literature gate has judged. So
the theorem holds on its own and the corollary is conditional on one named
import.

At a parabolic parameter the `IN` direction applies as it does anywhere else,
on the basin of the petal trap of section 5. Extending it from that basin to
the whole interior of `K_c` needs the same kind of import as the hyperbolic
case: that the interior is the parabolic basin.

## 7. What this document does not claim

It does not claim completeness, does not claim the residual approximates
`J_c`, and does not discharge any block of `docs/J1_proof_definition.md`. The
census is a record of behaviour at one resolution, not evidence about the
limit.
