# Literature gate — rational rays land

## Proposed step

`docs/angle-types-and-landing.md` section 3 needs the step from an angle to
the point a ray at that angle reaches:

```text
a rational angle  ->  a preperiodic point of the matching type
    [RationalRayLanding: NOT GATED]
```

Sections 1 and 2 of that note do not need it, which is worth saying first:
the closed form for an angle's type and the counting identity at `c = 0` are
finite arithmetic and hold whether or not any ray lands. The import is what
the rest of Phase 3 would rest on.

## Decision

**ACCEPTED for the quadratic family with connected `K_c`, in the direction the
repository would use, and with the hypothesis stated rather than assumed.**
No verified column depends on it, and nothing in this repository currently
uses it: the tag is gated *before* it is relied on, which is the order the
programme asked for after the escape criterion was found relying on an
ungated import.

## Findings

### 1. The statement, and its hypothesis

The Douady-Hubbard landing theorem: for a polynomial of degree `d >= 2` with
**connected** filled Julia set, every periodic dynamical ray lands at a
periodic point, which is repelling or parabolic; and strictly preperiodic
rational rays land at strictly preperiodic points.[^1][^2]

The hypothesis is connectivity of `K_c`, equivalently a bounded critical
orbit. That is a real restriction and this repository can see it: the
`escaping` row of `docs/J1_regime_ledger.md` has an escaping critical orbit,
so its `K_c` is a Cantor set and the theorem is simply unavailable there. Any
use of this tag has to name the row it is used on.

### 2. The converse direction, which is the one a separator would need

A repelling periodic point is the landing point of at least one and finitely
many rational rays, and the set of angles landing at a given such point is a
finite union of cycles under doubling.[^2] A separator built from ray pairs
needs this direction -- it is what says the catalogue of angles is rich
enough to separate anything.

### 3. What the gate does not grant

Landing gives a point, not a cut. That a pair of rays landing at a common
point separates the plane into two pieces, and which piece a box lies in, is
geometry about the rays as curves, and neither this tag nor any other in this
repository supplies it. `docs/angle-types-and-landing.md` section 4 says the
predicate is not implemented, and this gate does not make it implementable.

### 4. Counting is not correspondence

Section 2 of the note checks that the angle count and the root count agree at
`c = 0`. That agreement is evidence of nothing beyond itself: it is arithmetic
on both sides, it would hold if the landing map were any bijection at all, and
it holds at one parameter. The gate records this so that a later reader does
not promote a count into a correspondence.

## Verdicts

| Tag | Where used | Verdict |
| --- | --- | --- |
| `RationalRayLanding` | `docs/angle-types-and-landing.md` section 3; nothing executable yet | ACCEPTED, connected `K_c` only, both directions (findings 1-2) |

## What this gate did not do

It did not verify a theorem number against a printed text, obtain the cited
works in full, or check a proof. It did not judge the Riemann-mapping and
Böttcher-coordinate machinery the cited proofs rest on, which this repository
does not name. It made no ledger column depend on a tag, and no such
dependency exists.

[^1]: A. Douady and J. H. Hubbard, *Étude dynamique des polynômes complexes* (the Orsay notes), where the landing theorem for rational rays is proved for polynomials with connected filled Julia set.
[^2]: J. Milnor, *Periodic Orbits, External Rays and the Mandelbrot Set: An Expository Account*, which states and proves the landing theorem and the converse count of rays landing at a repelling periodic point. https://arxiv.org/abs/math/9905169
