# Tier-2 bridge salvage for the PSC programme

**Status:** research-program note only. This file moves no theorem status and does
not change the current #84 / #138 / #139 completion boundary.

## 1. Why this note exists

The 2D Penrose/Tier-2 programme exposed a distinction that is useful to the
current PSC proof architecture:

- a **Descent Bridge**, where noncoincident dynamics terminate because a
  well-founded rank forces eventual coincidence;
- a **Growth Bridge**, where recurrent noncoincident packet dynamics are
  allowed, but an arithmetic quantity on the lifted exact state grows
  uniformly and the contradiction is spectral/arithmetic rather than
  finite-time termination.

These are different proof mechanisms and should not be conflated.

The current PSC roadmap already contains both kinds of pressure:

- the aligned branch (#138) is structurally close to a descent/coincidence
  programme;
- the strict-zipper branch (#139) is an affine / contracting-space recurrence
  programme where bare cycle exclusion is already known to be insufficient.

## 2. Descent Bridge placeholder

The Descent Bridge is the closest analogue of the historical finite-BPA /
balanced-pair termination route.

Schematic form:

```text
finite exhaustive state universe
+ eventual confinement
+ well-founded noncoincident rank
=> eventual coincidence
=> pure discrete spectrum (via the relevant imported coincidence theorem)
```

This is **not** claimed here for the standing PSC regime. It is retained as a
named route so that future arguments can say exactly when they are using a
termination mechanism.

## 3. Growth Bridge

The Growth Bridge allows recurrence in the finite quotient.

Schematic form:

```text
finite exhaustive overlap universe
+ finite packet factorisation
+ bounded-time packet entry / confinement
+ lifted arithmetic cocycle with uniform positive growth
=> spectral / phase-locking obstruction
=> pure discrete spectrum
```

The important distinction is that the arithmetic cocycle lives on the lifted
exact state (for example, an ordered affine / prefix state), not necessarily on
the recurrent quotient state itself.

No such Growth Bridge theorem is claimed for PSC in this note. The value of the
abstraction is diagnostic: if a proposed #139 proof permits recurrent packet
dynamics, then a well-founded-rank proof is the wrong template and the argument
must instead identify the arithmetic or geometric obstruction created by that
recurrence.

## 4. FOUC-style abstraction

A useful generic name for the finite-coverage step is **finite
overlap-universe completeness (FOUC)**:

1. after the chosen normalisation/collaring, the represented exact-overlap
   universe is finite;
2. every overlap in the declared scope is represented in that universe;
3. each represented class is assigned to a finite residual packet / component
   family.

Here **represented** is deliberately neutral: it does not mean legal in the
substitution language. In particular, the PSC periodic swap seed may use two
distinct tile types even when the corresponding two-letter word is not a
language factor.

For the current PSC shortest route, the already-proved finite exact seed-patch
overlap graph supplies the required seed-relative finite represented universe.
That finiteness/coverage input is already closed.

Open Problem 5.35 is instead a **productivity** obligation: every vertex already
represented in the finite union overlap graph is productive (eventually reaches
coincidence). Theorem 5.38 uses the weaker seedwise form needed by the shortest
route. FOUC must therefore not be presented as the missing content of Open
Problem 5.35; the open bridge is productivity/eventual coincidence, not graph
coverage.

## 5. Relevance to #84 / #138 / #139

### #138 aligned branch

The natural bridge shape is still coincidence/descent-like: eliminate the
exposed non-eventually-coincident pair using the existing endpoint and strong
coincidence structure.

### #139 strict-zipper branch

The live obstruction already contains recurrent affine structure, and the
repository has exact counterexamples to bare affine-cycle / pump exclusion.
Therefore:

- do not infer termination from recurrence alone;
- do not call a recurrent packet a contradiction merely because it recurs;
- preserve the full non-unit representation-space hypothesis firewall;
- if the final proof is growth-type, identify the exact lifted arithmetic
  object and the exact spectral/covering contradiction it creates.

The current repository target remains
**AdelicPeriodicOffsetHitting**. This note does not replace it.

## 6. What is reusable elsewhere

The abstractions above are good candidates for shared infrastructure, but their
authority remains domain-local:

- finite overlap / packet graph data structures can move to
  `finite-math-kernels`;
- exact arithmetic / eigenspace / cocycle differential checks can be mirrored in
  `julia-oracle-lab` as non-authoritative oracles;
- bridge-shape equivalence / packet normal-form contracts can be explored in
  `semantic-categorical-oracle` without acquiring proof authority.

## 7. Non-claims

This note does **not**:

- prove #84, #138, or #139;
- prove FOUC beyond the already-proved seed-relative finite graph;
- prove a Growth Bridge for the standing non-unimodular PSC regime;
- add unimodularity, legality, FI, or a Euclidean-only internal-space premise.

Its purpose is to sharpen the research taxonomy so future proof attempts are
checked against the correct mechanism.
