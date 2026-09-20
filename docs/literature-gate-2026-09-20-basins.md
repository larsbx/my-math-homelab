# Literature gate — the interior of `K_c` is a basin

## Proposed step

Two of this repository's completeness statements end at the same place. The
classifier decides a box by finding a trap and showing the box's iterate lands
in it, so what it proves is about **the basin of that trap**. The roadmap's
claim is about the **interior of `K_c`**. Something has to say those are the
same set, and nothing in this repository does:

```text
interior of K_c  =  the basin of the cycle a trap surrounds
    [FatouHyperbolicInteriorIsTheBasin: NOT GATED]
    [FatouParabolicInteriorIsTheBasin:  NOT GATED]
```

The first tag was named in the 2026-09-19 gate's second amendment and left
unjudged. The second is new: `docs/three-valued-classifier.md` section 5 now
exhibits a trap at a parabolic parameter, which gives the `IN` branch a
hypothesis there and raises the same question about the same set.

This gate asks, for each: does a located source state it, on the hypotheses
the repository's rows actually satisfy, and is the attribution right?

## Decision

**Both are ACCEPTED, as a chain of four classical results rather than as one
theorem, and the chain is what the repository should cite.** No verified
column depends on either, and the corollaries that use them stay conditional
imports, exactly as `FilledJuliaLocalConnectivityTransfer` does.

The gate also narrows what may be claimed: the chain gives the interior of
`K_c` as a *union of basins of one cycle*, and it does so only because the
quadratic family has one finite critical point. Neither tag is available for
a family with more.

## Findings

### 1. Every Fatou component is eventually periodic

Sullivan's no-wandering-domains theorem: a rational map has no wandering
Fatou component, so every component is eventually mapped onto a periodic
one.[^1] This is the step that turns a statement about periodic components
into a statement about the whole Fatou set, and without it the rest of the
chain says nothing about an arbitrary box.

Hypotheses: a rational map of degree at least two. A quadratic polynomial is
one.

### 2. A periodic component is one of four things

The Fatou classification: a periodic Fatou component is the basin of an
attracting cycle, the basin of one petal of a parabolic cycle, a Siegel disk,
or a Herman ring.[^2]

### 3. A polynomial has no Herman ring, and each basin holds a critical point

Two classical facts narrow the four. The immediate basin of an attracting or
parabolic cycle contains a critical point; a Siegel disk or Herman ring
instead has critical orbits accumulating on its boundary, and a Herman ring
needs two critical orbits accumulating on two different boundary
components.[^3] A polynomial's basin of infinity is completely invariant, and
a quadratic polynomial has exactly one finite critical point, so there is at
most one attracting or parabolic cycle in the finite plane and no Herman ring
at all.

This is where the restriction to the quadratic family does real work. The
step from "each basin contains a critical point" to "there is only one such
basin" is counting critical points, and the count is one.

### 4. The hypothesis of each row removes the remaining cases

For a **hyperbolic** parameter every critical orbit converges to an
attracting cycle, so there is no indifferent cycle: no parabolic basin, no
Siegel disk. Finding 2 leaves only attracting basins, finding 3 makes them
one cycle's, and finding 1 carries it to every component. The interior of
`K_c` is the basin of that cycle.

For a **parabolic** parameter the critical orbit converges to the parabolic
cycle, and the same elimination leaves only the parabolic basin. The interior
of `K_c` is that basin, and a petal is what a trap encloses.

### 5. What the repository may now say, and what it may not

The trap the classifier is handed must contain a neighbourhood of the cycle
for its basin to be the cycle's basin; the corollaries already say so and the
gate does not remove that hypothesis. The census at `c = 1/4` is behaviour, and
nothing in this gate makes it evidence.

Neither tag is proved here. An accepted tag is an accepted **import**, and the
two corollaries that rest on them remain conditional; what changes is that
their condition is now a judged statement with a located source rather than a
name.

## Verdicts

| Tag | Where used | Verdict |
| --- | --- | --- |
| `FatouHyperbolicInteriorIsTheBasin` | `docs/enclosure-width-lemma.md` section 6, `docs/three-valued-classifier.md` section 6 | ACCEPTED, quadratic family only (findings 1-4) |
| `FatouParabolicInteriorIsTheBasin` | `docs/three-valued-classifier.md` sections 5 and 6 | ACCEPTED, quadratic family only (findings 1-4) |

## What this gate did not do

It did not verify any theorem number against a printed text, which is why
every citation below names a section or a statement rather than a number:
the numbering of the classification differs between the preprint and the
printed editions of the same book. It did not obtain the cited works in full
and did not check a proof. It did not make any verified column of any ledger
depend on a tag, and no such dependency exists.

[^1]: D. Sullivan, *Quasiconformal homeomorphisms and dynamics I: solution of the Fatou-Julia problem on wandering domains*, Annals of Mathematics 122 (1985), 401-418. https://www.math.stonybrook.edu/~bishop/classes/math627.S13/Sullivan-1985-Nonwandering.pdf
[^2]: J. Milnor, *Dynamics in One Complex Variable: Introductory Lectures*, the section titled "The Sullivan Classification of Fatou Components": a component mapped onto itself is the immediate basin of an attracting fixed point, or of one petal of a parabolic fixed point, or a Siegel disk, or a Herman ring. https://arxiv.org/abs/math/9201272
[^3]: W. Bergweiler, *Iteration of meromorphic functions*, the survey's account of the classification: the immediate basin of an attracting or parabolic cycle contains a critical point, while rotation domains have critical orbits accumulating on their boundaries. https://arxiv.org/abs/math/9310226
