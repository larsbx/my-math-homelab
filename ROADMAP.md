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

- [x] Derive the escape criterion instead of importing it
      (`docs/escape-criterion.md`). `ESCAPES` was a decided verdict resting on
      an implication nothing here proved and no tag named.
- [x] Check that the paths and tasks this repository's prose names resolve
      (`pixi run references`). The design analysis carried a reference to a
      file that never existed until this check was added.

## Phase 1 — The three-valued classifier

- [x] `G^c_r(box) -> IN | OUT | UNKNOWN` over dyadic boxes, in both
      implementations, with soundness proved for both certificates
      (`docs/three-valued-classifier.md`).
- [x] `OUT` from the escape certificate applied to a whole box; `IN` from a
      declared trap, verified before any verdict rests on it; `UNKNOWN`
      reported as its own column in the generated
      `docs/classifier-census.md`.
- [x] The enclosure-width lemma, with explicit rational constants
      (`docs/enclosure-width-lemma.md`), and the two completeness theorems it
      unlocks: a box missing `K_c` is `OUT` below an explicit radius, and a
      box whose iterate enters a trap's interior is `IN` below one. Both
      unconditional.
- [ ] Gate `FatouHyperbolicInteriorIsTheBasin`, the one import the corollary
      needs to turn Theorem B into the roadmap's statement about the whole
      interior of `K_c`.
- [ ] Completeness at a parabolic parameter, where no trap exists and
      Theorem B has no hypothesis to offer.

The remaining deliverable, restated:

- escape certificates for `OUT`, from the exact quadrance bound and the
  growth ratio of `docs/escape-criterion.md`;
- attracting-cycle certificates plus basin pullback for `IN`;
- `UNKNOWN` everywhere else, with the residual reported rather than shrunk.

`docs/projective-completion-and-escape.md` argues that `OUT` should be the
same shape as `IN` rather than an inequality: infinity is a superattracting
fixed element of the homogeneous lift, so escape is a contraction certificate
in the chart at infinity, with the quadrance bound kept as the cheap filter
ahead of it. Decide that before the classifier is written, not after.

The deliverable is a **completeness proof for hyperbolic Gaussian-rational
`c`**: every box whose closure misses `J_c` is classified at some resolution.
This is the claim the parameter plane cannot make, and it should be proved
rather than demonstrated. The census is not that proof and is not evidence
for it.

## Phase 2 — Postcritically finite certificates

Reuse the squarefree route on the dynamical polynomial:

```text
R^c_{l,k}(z) = f_c^{l+k}(z) - f_c^l(z)        P^c_{l,k} = sqfree(R^c_{l,k})
```

with root isolation in dyadic boxes, Krawczyk uniqueness, and pointwise
exact-type exclusion. The kernels are the ones `interval_orbit` becomes once
it is parameterized by `(z_0, c)` in `larsbx/finite-math-kernels`; this phase
should consume them, not reimplement them.

**First rung delivered, 2026-09-20.** `docs/preperiodic-certificates.md`, with
`quadratic_orbit/preperiodic.mojo` upstream and `tools/preperiodic.py` as the
Python side. All three properties are there, and the squarefree step is not:
`R^c_{l,k}` is evaluated as a difference of orbit terms and its derivative by
the chain rule, so what `sqfree` would buy -- a simple root -- is checked
directly on an enclosure of `R'`. Exclusion is proved in-layer; isolation is
the Krawczyk-Moore hypothesis and the theorem is gated as an import in
`docs/literature-gate-2026-09-20-krawczyk.md`. Six witnesses across three
parameters, verified in both implementations.

**Second rung, same day.** The two gaps the first rung named are closed.
The critical point needed no deflated residual, because it needs no box: it
is a Gaussian rational, so its type is an identity over `Q(i)` and its
multiplicity is exact, by the recursion `R_{l,k} = R_{l-1,k} . f` whose only
doubling is the two-to-one branching of `f` at `0`. Enumeration is built, with
a completeness certificate that is a count: `deg R^c_{l,k} = 2^(l+k)`, so
isolated simple roots plus named multiplicities reaching the degree leaves no
room for another root. Six enumerations pinned, one budget exhaustion
reported as such.

What remains in this phase: a multiple root that is *not* exactly
representable, which happens at a parabolic parameter where `R'` vanishes on
the cycle -- `exact_multiplicity` refuses there rather than guessing. Nothing
in the phase reaches `J_c` itself; the roots certified here are its finite
skeleton, and what connects the two is Phase 3's business.

## Phase 3 — Separator catalogue and the J1 ledger

- rational-angle combinatorics under `t -> 2t`, as dynamical-ray addresses;
- landed-ray separators and the finite separation predicate `Separated_k^c`;

**First rung delivered, 2026-09-20.** The first bullet, and only it.
`docs/angle-types-and-landing.md`, with `angle_doubling/angle.mojo` upstream
and `tools/angle.py` as the Python side: an angle's preperiod and period are
closed forms in its denominator rather than searches, and the counting
identity `2^l (2^k - 1) + 2^l = 2^(l+k)` meets Phase 2's degree at `c = 0`,
where the second summand is the critical point's multiplicity. Both finite,
both proved, neither importing anything.

The second bullet is **not** built and the note says why. Landing is gated as
`RationalRayLanding` in `docs/literature-gate-2026-09-20-landing.md` -- before
anything uses it, which is the order the escape-criterion episode taught --
but landing gives a point, not a cut. Deciding which side of a ray pair a box
lies on is geometry about the rays as curves, which this repository has no
certificate for and does not fake.
**Second rung, 2026-09-20: the separator, restated.** The ray-pair
separator is not writable here, so `docs/finite-separator.md` replaces the ray
pair with an exact rational cut and the side test with the three-valued
interval sign. Soundness, the monotone nest, constructive adequacy and the
failure of transitivity are proved; the identification with fiber separation
becomes the named, ungated `CutCatalogueRayEquivalence`. Adequacy and
non-triviality are now statements about a *declared* catalogue, which is a
real change: an unrestricted catalogue separates everything distinguishable,
so Phase 4's witness only has content against a fixed one.

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
