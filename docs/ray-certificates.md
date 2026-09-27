# Ray certificates: the part of a ray that is exactly representable

**Status:** derivation, dated 2026-09-20. Sections 1 to 3 are proved here.
Section 4 names the one import, which is gated before anything uses it.

`docs/literature-gate-2026-09-20-cut-equivalence.md` rejected the idea that a
straight cut can stand in for a ray, and ended by saying that reaching the
classical reading means building pieces out of rays. This is the first such
piece. It does not construct a ray. It certifies the parts of one that are
exactly representable, and at a **real** rational parameter that turns out to
be most of what the separator needs.

## 1. The direction at infinity is not the obstruction

An earlier draft of this note said a ray must be named by the direction it
approaches infinity in; that at rank 2 a direction is a coordinate record, so
only `0, 1/4, 1/2, 3/4` name one; and that every other ray is therefore out of
reach. **That was wrong**, and the projective layer this repository already
has is what shows it.

In the chart at infinity, `u = 1/z`, the point at infinity is an ordinary
coordinate record with value zero, fixed, and superattracting of order two
(`docs/projective-completion-and-escape.md` section 3). Its neighbourhood is
a bounded box, not an unbounded one, and `reference/chart.py` computes the step
`u -> u^2 / (1 + c u^2)` there, refusing where the chart's domain fails
rather than being handed a caller contract.

That changes the question, because **near that fixed point every ray looks
the same**. The tail carries no angular information at all; all rays converge
into any contracting neighbourhood of `u = 0`. So nothing about a ray can be
read off its direction, and nothing needs to be. What distinguishes one ray
from another is the finite itinerary of section 3, and that is available at
every angle.

The worked case is angle `1/3`, whose direction `e^(2 pi i / 3)` is not a
coordinate record and never will be. A box around `2 e^(2 pi i / 3)` at
`c = 0` yields the itinerary

```text
(+, -, +, -, +, -, +, -, +, -, +, -)
```

twelve digits of `0.010101...`, which is `1/3` in binary. No direction was
named anywhere in producing it.

**The real limit is different and is stated in section 4**: a finite
certificate pins a dyadic interval of angles of width `2^-n`, never an angle.
And `n` is bounded by the coordinate budget rather than by how narrow the box
is -- narrowing the box from `10^-6` to `10^-9` buys no further digits,
because exact iteration squares the coordinates and the budget runs out
first. That is the wrapping effect setting the price, not the geometry.

## 2. The real axis of a real parameter, certified

**Let `c` be rational and real, and let `outer` and `segment` be rationals
with**

```text
outer >= 1,   outer^2 + c - outer > 0,   0 < segment,
segment^2 + c <= segment,   c >= -segment,   segment < outer
```

**Then:**

**(a) every real `x` with `|x| >= outer` escapes.** *Proof.* Write
`g(x) = x^2 + c - x`. For `x >= outer >= 1`,
`g(x) - g(outer) = (x - outer)(x + outer - 1) >= 0`, so
`f(x) - x >= growth := outer^2 + c - outer > 0`. The orbit therefore advances
by at least `growth` at every step and is unbounded after `n` steps by at
least `n * growth`, with no limit argument anywhere. For `x <= -outer`,
`f(x) = f(-x)` puts the orbit on the previous case at once. []

**(b) `[-segment, segment]` is forward invariant, hence inside `K_c`.**
*Proof.* For `|x| <= segment`, `f(x) = x^2 + c` lies in
`[c, segment^2 + c]`, which is inside `[-segment, segment]` by the two
hypotheses. A forward-invariant bounded set has bounded orbits. []

**(c) the half-lines are the angle-zero ray and its preimage.** `f` maps
`[outer, ∞)` onto itself increasingly and maps `(-∞, -outer]` onto it, which
is the doubling `0 -> 0` and `1/2 -> 0` on the angle side. That correspondence
is section 4's import; what (a) and (b) prove is the dynamics, not the naming.

**What is not certified** is the stretch between `segment` and `outer`.
`certify_real_rays` names what it covers and nothing else.

At `c = 1` the certificate **refuses**, and correctly: `x^2 + 1 = x` has no
real solution, so the real axis carries no invariant segment. `K_1` is a
Cantor set with empty interior, and the refusal is that fact arriving as a
value.

## 3. What this buys the separator

`reference/separator.py` treats every cut alike, and
`docs/literature-gate-2026-09-20-cut-equivalence.md` showed that an arbitrary
cut is blind in different places from a ray pair. At a real parameter the cut
`y = 0` is not arbitrary:

```text
real axis  =  the two certified escaping half-lines  ∪  an uncertified stretch
              ∪  a certified forward-invariant segment inside K_c
```

So this one cut runs along genuine rays outside and along trapped real
dynamics inside. It is the first cut in this repository with a dynamical
warrant rather than only a soundness proof, and `REAL_RAYS` in
`reference/parameter_corpus.py` declares the witness for every real row of the
corpus.

The **itinerary** of an escaping orbit relative to that cut -- the sequence of
sides its iterates are on -- is a finite invariant, and every claim it makes
is the separator's soundness claim: every point of the box has its iterates
on those sides. `itinerary` returns `None` the moment a step is undecided,
because a word with a gap is not a word.

## 4. The import: the itinerary is the angle

Reading the digits of that itinerary as the binary expansion of the external
angle is classical and is **not** proved here. It is the tag
`ExternalAngleItinerary`, gated in
`docs/literature-gate-2026-09-20-external-angle.md` before anything uses it.

Nothing in sections 1 to 3 depends on it. The itinerary is a sound invariant
whatever it is called, and the separator uses it as an invariant; the word
*angle* is the part that needs the import.

## 5. What this does not claim

It does not construct a ray, does not claim the certified half-lines are the
whole ray, and does not locate a landing point -- `x -> β` is a limit and this
layer has none. It does not name a ray's direction, does not need to, and pins only a dyadic
interval of angles at any finite depth. It does not apply to a non-real parameter at
all. And it discharges no block of `docs/J1_proof_definition.md`.
