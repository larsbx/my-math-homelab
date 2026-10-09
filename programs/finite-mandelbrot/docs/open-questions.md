# Major Open Questions

## OQ1 — Finite replacement object

What is the canonical finite object at resolution `r`?

Candidate:

```text
G_r(box) -> IN | OUT | LANDING_CERT | UNKNOWN
```

with every non-UNKNOWN label carrying a finite machine-checkable certificate.

## OQ2 — Outside completeness

For every dyadic box whose closure is disjoint from the Mandelbrot set, does escape/refinement eventually certify `OUT`?

Expected: yes for a sufficiently careful interval/refinement scheme.

Hard part: complexity near parabolic parameters, filaments, and deep renormalization regions.

## OQ3 — Interior completeness

Are attracting-cycle certificates enough to certify every dyadic box compactly contained in the interior?

This touches the density-of-hyperbolicity frontier. A purely attracting-cycle certificate language may be complete only under strong structural assumptions.

## OQ4 — Boundary residual structure

Can the unresolved boxes be proven to form a controlled finite neighborhood of the boundary at every resolution?

## OQ5 — Finite MLC reformulation

Can MLC be expressed as stabilization of finite combinatorial nests?

Current target:

```text
finite combinatorial nest stabilization
  <=> triviality of all Mandelbrot fibers
  <=> MLC
```

The certificate calculus should isolate this statement rather than pretend to solve it.

## OQ6 — Symbolic-ray finitization

Can external-ray theory be represented by finite rational/binary angle certificates, kneading sequences, orbit portraits, and lamination data, without importing analytic coordinates inside the certificate?

## OQ7 — Finite-field shadows

Do finite-field or finite-ring reductions of the critical-orbit polynomials reveal useful Mandelbrot structure, or only unrelated finite functional-graph statistics?

Affine finite-field orbits do not land on infinity and always become periodic.
Projective infinity still has algebraic ramification and divisor multiplicity,
and valued extensions admit pole-order growth. Can Frobenius-stable effective
zero-cycles and these algebraic infinity invariants reveal structure that
survives a rigorously stated characteristic-zero bridge? They remain auxiliary
shadows, not the primary substrate; see `docs/projective-multiset.md`.

## OQ8 — Complexity of certificates

What is the worst-case certificate size needed to classify all pixels or boxes at resolution `2^-r`?

Separate:

- escape certificates;
- attracting-cycle certificates;
- Misiurewicz/parabolic landing certificates;
- generic unresolved nests.

## OQ9 — Formal verification

Can the entire finite verifier be reduced to:

- integer polynomial recurrence;
- Euclidean polynomial witnesses;
- rational interval arithmetic;
- finite combinatorics on rational angles;
- theorem-tag boundary rules?

## OQ10 — Minimal calculus

What is the smallest certificate grammar sufficient for practical proof-carrying Mandelbrot rendering?

Initial grammar:

```text
EscapeCert
InteriorCert
SquarefreeLocCert
ExactTypeCert
AngleCombCert
LandingTheoremTag
FiberTheoremTag
NestCert
```
