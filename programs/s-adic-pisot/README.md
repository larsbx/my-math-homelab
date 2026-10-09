# s-adic-pisot-conjecture-research

Research programme on the S-adic Pisot conjecture. It builds on the exact
infrastructure of
[`pisot-substitution-conjecture-research`](https://github.com/larsbx/pisot-substitution-conjecture-research)
and [`finite-math-kernels`](https://github.com/larsbx/finite-math-kernels).

**Status:** the S-adic Pisot conjecture is **open**. The repository's own results are a few elementary lemmas and finite-domain theorems, among them a census of the Brun `d = 4` periodic points. They are listed in `CLAIMS.md`.

Start with [`docs/METHODOLOGY.md`](docs/METHODOLOGY.md). It gives the general
method for attacking a generalization from an existing programme (phases G0–G7
and their invariant rules), and §5 instantiates it for this repository.

Then read:

- [`docs/literature-gate-2026-10-09.md`](docs/literature-gate-2026-10-09.md):
  exact hypotheses of the imported results, and the per-algorithm,
  per-dimension status matrix;
- [`CLAIMS.md`](CLAIMS.md): the claim register;
- [`docs/sadic-kernel-g2-slice.md`](docs/sadic-kernel-g2-slice.md): the exact
  Mojo kernel `kernel/sadic/` (directive shifts, checked incidence cocycle,
  positive blocks, Hilbert cross-ratio bound, balance lower bounds) and its
  Python oracle;
- [`docs/sadic-kernel-g2-spectrum.md`](docs/sadic-kernel-g2-spectrum.md):
  exact irreducibility and Pisot certificates, periodic points, and the `ι`
  regression against the PSC corpus;
- [`docs/sadic-g3-brun4-census.md`](docs/sadic-g3-brun4-census.md): replication
  of BST23's Brun `d = 4` certificate, and the periodic-point census;
- [`docs/sadic-g6-brun-higher-census.md`](docs/sadic-g6-brun-higher-census.md):
  Brun in every dimension. Every primitive composite is in the mirror Barge
  class (Theorem B). For `d = 5, 6` only the Pisot condition is missing
  (Theorem C). Every such Pisot point also has symbolic pure discrete spectrum
  (Corollary B″), so for every `5 ≤ d ≤ 10` the Pisot condition is the only
  missing input (Theorem C′). Census for `d = 5, 6`;
- [`docs/t1-uniform-overlap-finiteness.md`](docs/t1-uniform-overlap-finiteness.md):
  the swap-walk and uniform overlap bounds (T1), and the finite pool of
  overlap types at selected PRICE return depths (T1′). The all-depth
  extension remains open.
- [`docs/all-depth-bounded-anchors.md`](docs/all-depth-bounded-anchors.md):
  a conditional all-depth bound using balanced positive-suffix anchors,
  and the obstruction that bounded gaps in growing prefix returns force
  periodicity. The anchor condition is an additional assumption.

Layout and authority: [`ARCHITECTURE.md`](ARCHITECTURE.md). Working rules and
the pre-push checks: [`AGENTS.md`](AGENTS.md).
