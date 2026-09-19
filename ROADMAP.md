# Roadmap

Phases are indexed by what becomes checkable, not by what becomes plausible.

## Phase 0 — Scaffold and corpus

- [x] State why the dynamical plane is a separate program, and fix the
      Phase 0 decisions (`docs/julia-program-design-analysis-2026-09-19.md`).
- [x] Prove the rational multiplier dichotomy and bind it to the executable
      layer.
- [x] Vendor `finite_exact` from `larsbx/finite-math-kernels`, pinned and
      digest-checked.
- [x] Build the nine-parameter corpus covering every regime, with witnesses
      verified by exact arithmetic.
- [x] Two agreeing implementations: the Mojo kernel and the Python reference
      oracle, compared transcript for transcript.
- [x] Generate the regime ledger, `corpus.json`, and the Mojo corpus from one
      table, with `--check` gating them.
- [x] Run the literature gate for each local-connectivity theorem tag
      (`docs/literature-gate-2026-09-19.md`).
- [x] Take the shared orbit, smoke reporter, and vendoring checker upstream
      into `larsbx/finite-math-kernels` and vendor them back, so this
      repository holds no private copy of code a second consumer needs.
- [x] Gate `FilledJuliaLocalConnectivityTransfer`
      (`docs/literature-gate-2026-09-19-transfer.md`): discharged where `K_c`
      is connected, by Torhorst and by Carathéodory with the lamination model,
      plus an assembly step that gate owns rather than imports.
- [x] Bind this repository's arithmetic consumers. The canonical spec asks a
      consumer to keep its own binding table, so this repository keeps
      `docs/exact-arithmetic-binding.md` and enforces it with
      `tools/audit_exact_arithmetic.py`; `larsbx/finite-math-kernels` now names
      this repository among the consumers.

- [x] Check that the paths and tasks this repository's prose names resolve
      (`pixi run references`). The design analysis carried a reference to a
      file that never existed until this check was added.

## Phase 1 — The three-valued classifier

Deliver `G^c_r(box) -> IN | OUT | UNKNOWN` over dyadic boxes at a
Gaussian-rational parameter, with:

- escape certificates for `OUT`, from the exact quadrance bound;
- attracting-cycle certificates plus basin pullback for `IN`;
- `UNKNOWN` everywhere else, with the residual reported rather than shrunk.

The deliverable is a **completeness proof for hyperbolic Gaussian-rational
`c`**: every box whose closure misses `J_c` is classified at some resolution.
This is the claim the parameter plane cannot make, and it should be proved
rather than demonstrated.

## Phase 2 — Postcritically finite certificates

Reuse the squarefree route on the dynamical polynomial:

```text
R^c_{l,k}(z) = f_c^{l+k}(z) - f_c^l(z)        P^c_{l,k} = sqfree(R^c_{l,k})
```

with root isolation in dyadic boxes, Krawczyk uniqueness, and pointwise
exact-type exclusion. The kernels are the ones `interval_orbit` becomes once
it is parameterized by `(z_0, c)` in `larsbx/finite-math-kernels`; this phase
should consume them, not reimplement them.

## Phase 3 — Separator catalogue and the J1 ledger

- rational-angle combinatorics under `t -> 2t`, as dynamical-ray addresses;
- landed-ray separators and the finite separation predicate `Separated_k^c`;
- `J1` stated and discharged per regime, against
  `docs/J1_proof_definition.md`;
- the cross-check: run the parameter plane's adequacy machinery on regimes
  whose answer is a classical theorem, and report what it does.

## Phase 4 — Non-triviality and interval parameters

- a finite witness that the catalogue permanently fails to separate a named
  pair, at a parameter whose local connectivity is false;
- escalation of `c` from `Q(i)` to exact algebraic and interval parameters,
  which is the bridge back to the parameter plane.

## Standing obligations

- Nothing already present in `finite-mandelbrot-research/src` is copied here.
  It is lifted into `larsbx/finite-math-kernels` and vendored twice; the
  extraction ladder is section 5 of the design analysis. As of
  `finite-math-kernels@56ac8bc` the orbit, the collision partition, the smoke
  reporter, and the vendoring checker are upstream, and this repository holds
  no private copy of any of them.
- The remaining ladder rungs are the polynomial and Krawczyk kernels, which
  Phase 2 needs and this repository does not yet use. The reference-check
  engine went upstream as `references` when this repository became its second
  consumer, on the same rule.
