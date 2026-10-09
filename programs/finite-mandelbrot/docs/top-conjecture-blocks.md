# Top Conjecture Blocks Register

Status: active research control document.

This document narrows the project to its highest-priority conjecture and removes distracting implementation threads from the critical path.

## Highest-priority conjecture

### C1 — Finite Fiber Stabilization iff MLC

Let finite rational-ray separation data generate a nested family of dyadic/combinatorial neighborhoods for a symbolic address or fiber label:

```text
B_0 >= B_1 >= B_2 >= ...
```

where each `B_k` is certificate-bearing finite data: rational ray addresses, separation lines, dyadic boxes, and incidence vertices.

The top conjecture is:

```text
Global finite-nest stabilization
iff
triviality of all Mandelbrot fibers
iff
MLC.
```

This is not a claim that the project proves MLC. It is a finite-certificate reformulation of the classical obstruction.

## What is already imported, not reproved

The finite core may cite named theorem tags for:

1. rational parameter-ray landing at rational addresses;
2. Schleicher fiber definitions using rational-ray separation lines;
3. triviality of fibers at Misiurewicz parameters and hyperbolic-component boundaries;
4. fiber triviality iff local connectivity, under Schleicher's framework.

These are not targets for reimplementation in Mojo. The project verifies finite hypotheses and records theorem-tag dependencies.

## Active blockers

### B1 — Define the finite nest object precisely

Current risk: the repo has root handles, boxes, ray-address sets, and incidence vertices, but the `Nest` object is not yet formalized.

Required object:

```text
FiniteNest_k := {
  depth: k,
  ray_separation_data,
  finite_piece_id,
  dyadic_cover_or_box,
  incidence_carrier,
  theorem_tags_used
}
```

Acceptance condition: a `FiniteNest` can be checked without analytic points, measured angles, real/complex primitives, or transcendental maps.

### B2 — Define refinement/stabilization without limits inside certificates

Current risk: wording like `diameter tends to zero` belongs to the meta-theorem, not inside a finite certificate.

Finite certificate must instead say:

```text
Refines(N_k, N_{k+1})
DiameterBound(N_k, q_k)
q_{k+1} < q_k
```

The meta-theorem may quantify over all depths and state stabilization externally.

### B3 — Prove identity with fiber separation, not arbitrary boxes

Current risk: nested dyadic boxes alone do not imply fiber-theoretic meaning.

Required bridge:

```text
same fiber
iff
not separated by any certified rational-ray separation line.
```

The finite nests must be generated from Schleicher-style separation lines, not from renderer heuristics.

### B4 — Separate established cases from open frontier

The repo must preserve three regions:

```text
Misiurewicz: established trivial fiber, finite certificate target.
Hyperbolic boundary: established trivial fiber, finite certificate target.
Generic boundary: open, with global fiber-triviality / MLC strength.
```

Any statement implying unconditional generic co-landing or generic singleton fibers is invalid.

### B5 — Keep implementation subordinate

Current risk: bigint, serialization, and Krawczyk work can consume the project before the top theorem is pinned.

Rule: implementation work is paused unless it supports C1 directly.

Allowed implementation work:

- finite nest schema;
- separation-line schema;
- ray-address combinatorics;
- incidence representation;
- theorem-tag dependency records.

Deferred implementation work:

- full bigint backend;
- hash-root finalization;
- general Krawczyk optimization;
- finite-field shadow experiments;
- renderer/pixel work.

## Immediate next proof obligations

### P1 — Formal finite separation-line grammar

Define the finite object corresponding to a Schleicher separation line:

```text
SeparationLine := {
  ray_addr_left,
  ray_addr_right,
  landing_anchor_kind,
  landing_anchor_handle,
  separates_piece_ids
}
```

The landing anchor is theorem-tagged, not analytically constructed.

### P2 — Fiber equivalence lemma

Prove or cite with exact scope:

```text
c and c' are in the same fiber
iff
no finite certified separation line separates their incidence carriers.
```

Inside the finite calculus, replace `c` and `c'` by root handles, dyadic nests, or `PointVertex` carriers.

### P3 — Nest construction lemma

Given a symbolic address/fiber label, define:

```text
N_k = intersection/combinatorial refinement of all certified separation data up to depth k.
```

This must be finite at each `k`.

### P4 — Stabilization theorem statement

State the meta-theorem:

```text
For every fiber label tau, the finite nests shrink to a singleton incidence class
iff
all fibers are trivial
iff
MLC.
```

Use external mathematical language only in the theorem statement, not in certificate payloads.

## Output target

The next paper-grade deliverable is not more code. It is:

```text
SPEC_finite_fiber_stabilization.md
```

with:

1. finite separation-line grammar;
2. finite nest grammar;
3. refinement predicate;
4. stabilization predicate as a meta-level scheme;
5. theorem-tag boundary;
6. established cases;
7. generic open frontier.
