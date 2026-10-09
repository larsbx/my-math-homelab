# Roadmap

## Phase 0 — Research scaffold

- [x] State the finite-regime thesis.
- [x] Separate finite certificates from analytic theorem tags.
- [x] Add worked algebraic smoke test at `c = -2`.
- [ ] Add a computed multi-ray stress test with verified interval margins.

## Phase 1 — Certificate calculus

Deliver a paper-ready specification for:

- critical-orbit polynomial recurrence `Q_0 = 0`, `Q_{n+1} = Q_n^2 + C`;
- squarefree localization polynomial `P_{l,k} = sqfree(Q_{l+k} - Q_l)`;
- dyadic complex interval boxes;
- complex Krawczyk uniqueness witnesses;
- semantic intended-equality sets `I_{l,k}(H)`;
- forbidden-collision sets `F_{l,k}(H)`;
- joint box witnesses combining localization and exact-type exclusion;
- rational-angle / kneading / orbit-portrait certificates;
- theorem tags for rational-ray landing and Misiurewicz fiber triviality.

## Phase 2 — Prototype verifier

Build a finite checker using exact integer/rational arithmetic.

Suggested implementation layers:

1. polynomial recurrence engine;
2. squarefree and Euclidean witnesses;
3. dyadic interval arithmetic;
4. complex Krawczyk checker;
5. collision-set enumerator;
6. rational-angle combinatorics;
7. certificate parser and validator.

## Phase 3 — Certified renderer bridge

Integrate the boundary certificate calculus with a three-valued renderer:

- escape certificates for `OUT` boxes;
- attracting-cycle or bulb/cardioid certificates for `IN` boxes;
- Misiurewicz/parabolic landing certificates for algebraic boundary anchors;
- `UNKNOWN` boxes for unresolved generic boundary regions.

## Phase 4 — Fiber/MLC reduction

Formalize the generic-boundary stream:

```text
finite combinatorial nest stabilization
  <=> triviality of all Mandelbrot fibers
  <=> MLC
```

The deliverable is not an unconditional generic co-landing certificate; it is a finite certificate reformulation of the fiber program with MLC isolated as the exact stabilization obstruction.

## Phase 5 — Formalization target

Choose proof-assistant and implementation targets.

Possible split:

- Lean/Rocq: certificate grammar and integer-polynomial soundness;
- Rust or Zig: exact dyadic interval verifier;
- Python/Sage: exploratory computation and example generation only.
