# Finite-regime Julia design analysis

**Status:** planning document, dated 2026-09-19. It states why this repository
exists separately from `larsbx/finite-mandelbrot-research`, what transfers from
that program unchanged, what must not be transferred, and which decisions the
Phase 0 scaffold takes. It is not a mathematical document: no section below
discharges a theorem obligation, and the one lemma it proves (section 6) is
restated and tested in the executable layer rather than relied on from here.

Heads audited when this was written: `larsbx/finite-mandelbrot-research` at
`cea36cc`, `larsbx/finite-math-kernels` at `8af9d7a`, this repository at
`5701025` (README only).

## 0. The asymmetry that drives the design

| | finite-mandelbrot-research | this repository |
| --- | --- | --- |
| object | one set `M` | a family `{K_c}` indexed by exact data `c` |
| substrate | `Q_{n+1}(C) = Q_n(C)^2 + C` in `Z[C]`, one variable, no parameter | `f_c^{n+1}(z) = f_c^n(z)^2 + c` in `Q(i)[z]`, `c` fixed exact data |
| frontier | MLC: one open conjecture, `OPEN_FRONTIER` | local connectivity of `J_c`: **stratified**, known true on several regimes and known false on others |

The last row is the reason for a separate program. `C1` can be isolated but
not closed. Its dynamical-plane analogue splits into cells that are already
classical theorems (Douady-Hubbard for hyperbolic and postcritically finite
`c`; Yoccoz for at most finitely renormalizable `c` with all cycles repelling;
Petersen for bounded-type Siegel) and cells where local connectivity **fails**:
a Cremer cycle, or a Siegel disk whose boundary contains no critical point
(`docs/literature-gate-2026-09-19.md`, finding 5; an earlier draft of this
section wrote "non-Brjuno Siegel", which is an empty class in the quadratic
family, since a non-Brjuno rotation number gives a Cremer point).

Consequences, in the order they matter:

1. This repository is the place where the separator/fiber calculus can be
   **confirmed or falsified against known answers**. If catalogue adequacy is
   sound it must stabilize on hyperbolic and postcritically finite `c`, and it
   must fail to stabilize on Cremer `c`. Nothing in the parameter plane tests
   this today.
2. Targets here can be *closed*, not only isolated.
3. A finite certificate of fiber **non**-triviality is available here and is
   not available in the parameter plane.

## 1. Exact data reaches every regime

The concern is that `c` in `Q(i)` reaches only the degenerate cases. It does
not. With `z^2 + c = z` and multiplier `lam = 2z`,

```text
c = lam (2 - lam) / 4
```

parameterizes the main-cardioid boundary exactly, so any `lam` in `Q(i)` with
quadrance `N(lam) = 1` gives a Gaussian-rational parameter with an indifferent
fixed point. Taking the Niven multiplier `lam = (3 + 4i)/5`:

```text
c = (37 + 16i)/100
```

is an exactly representable parameter with an **irrationally indifferent**
fixed point whose Siegel-or-Cremer status turns on the Brjuno condition for
`theta = arg(lam) / 2pi`, and which, even in the Siegel case, leaves local
connectivity turning on whether the critical point lies on the disk's
boundary. Exact data, open dynamics. Roots of unity
`lam in {1, -1, i, -i}` give the parabolics `c = 1/4`, `-3/4`, `(1 + 2i)/4`,
`(1 - 2i)/4`.

The corpus this produces is the generated `docs/J1_regime_ledger.md`. Every regime except
"Siegel with bounded type" is reached by exactly representable data.

## 2. What transfers unchanged

- `finite_exact` (`BigZ`, `Q`, `IQ`, `ComplexIQ`), vendored from
  `larsbx/finite-math-kernels` at the pins already used by the Mandelbrot
  repository.
- The governance stack: `claim_governance`, `proof_records`, the generated-
  surface discipline, `backend.toml`, the rational-interval arithmetic
  specification, the rank-2 layer rule, the no-trigonometry and no-points
  audits, and the two-directional **fail-closed** table (refuse to proceed
  versus refuse to destroy). That doctrine is repository-independent and is
  adopted verbatim.
- Squarefree localization, root isolation, Krawczyk uniqueness, pointwise
  exact-type exclusion. The variable changes; the method does not:

```text
R^c_{l,k}(z) = f_c^{l+k}(z) - f_c^l(z)        P^c_{l,k} = sqfree(R^c_{l,k})
```

- Angle combinatorics on `Q/Z` under `t -> 2t`: kneading sequences, orbit
  portraits, lamination data. The finite data type is identical; the referent
  becomes a dynamical ray rather than a parameter ray, so the theorem tags
  differ even where the encodings agree.

## 3. What is easier here, and should be said so

Two parameter-plane open questions collapse in the dynamical plane.

- `OQ2`, outside completeness, becomes a theorem. The escape radius is exact:
  `N(z) > max(4, N(c))` implies escape, and the test is a quadrance compared
  against a rational bound, so it is rank-2 legal with no circle primitive and
  no analytic input. Every box whose closure misses `K_c` certifies `OUT` in
  finitely many steps.
- `OQ3`, interior completeness, stops touching density of hyperbolicity. For
  fixed hyperbolic `c` the interior of `K_c` is the union of preimages of the
  immediate basin, so `IN` is a pullback certificate from a single attracting-
  cycle witness, and the witness is decided exactly by
  `lam = 2^k * prod z_j`, `N(lam) < 1`.

So `G^c_r(box) -> IN | OUT | UNKNOWN` is **finitely completable for hyperbolic
Gaussian-rational `c`**: a provable Phase 1 deliverable rather than a scaffold.

## 4. What must not be transferred

`C1` as `PRIORITY_ZERO` must not be transplanted. That framing places an
unreachable statement at the head of the queue, and it is why the Mandelbrot
repository carries thirty-six `C1_*` blocks against one open frontier.

The analogue here is a **regime ledger**, not a conjecture: rows indexed by
regime, columns for the local-connectivity theorem tag, catalogue adequacy
status, certificate completeness, and the open cells. `J1` is stated per
regime and discharged per regime:

```text
J1(c):  A != B                      =>  exists k. Separated_k^c(A, B)
        not exists k. Separated_k^c(A, B)  =>  SameFiber_c(A, B)
        all fibers of K_c trivial   <=>  J_c locally connected   [theorem tag]
```

Two targets follow that the parameter plane cannot offer:

1. **Confirmation against known answers.** `J1(c)` must come out true on
   `c in {0, -1, i, -2, 1/4}` by independent classical theorem.
2. **Finite certificates of non-triviality.** For a Cremer parameter the fiber
   is provably non-trivial, so the honest finite object is a witness that the
   catalogue permanently fails to separate. That direction is closable.

## 5. Shared code: the second consumer is the forcing function

Nothing already present in `finite-mandelbrot-research/src` is to be copied
into this repository. It is lifted into `larsbx/finite-math-kernels` and
vendored twice; otherwise the certificate calculus forks and the `C1`/`J1`
cross-checks lose their meaning. Plane-agnostic modules, in order:

```text
P0  poly_z, integer_gcd, poly_witness, poly_interval_eval
P0  complex_box, checked_complex_interval, rank2_operator
P1  krawczyk_witness, interval_orbit
P1  ray_address, angle_tuning, collision_sets
P2  mojo_theorem_kernel, canonical serialization primitives
```

`interval_orbit` is the sharp one. It hardcodes `Q_0 = 0` over `Z[C]`;
parameterizing it by `(z_0, c)` makes the Mandelbrot critical orbit the
special case `(0, C)` and hands this repository its main loop. That single
refactor is most of the shared surface, and it belongs in the kernels
repository with the Mandelbrot repository as its second consumer.

**Done, at `finite-math-kernels@56ac8bc`.** The orbit is the
`quadratic_orbit` package there, seeded rather than critical, with the
collision partition beside it; the smoke reporter and the vendoring checker
went with it. This repository vendors all three and holds no private copy.
The P1 polynomial and Krawczyk rungs are still local to the Mandelbrot
repository, and Phase 2 is what will need them.

## 6. The rational multiplier dichotomy

A finite lemma that the corpus depends on, stated here and tested in
`tools/julia_reference.py` and `src/julia_orbit.mojo`.

**Lemma.** Let `lam` in `Q(i)` with `N(lam) = 1`. Then `lam` is a root of
unity if and only if `lam` is in `{1, -1, i, -i}`.

*Proof.* If `lam` is a primitive `m`-th root of unity then
`Q(lam) = Q(zeta_m)` has degree `phi(m)` over `Q`, and `Q(lam)` is contained
in `Q(i)`, so `phi(m)` divides 2 and `m` is in `{1, 2, 3, 4, 6}`. The values
`zeta_3` and `zeta_6` generate `Q(sqrt(-3))`, which is not contained in
`Q(i)`. So `m` is in `{1, 2, 4}`, giving exactly `{1, -1, i, -i}`. The
converse is immediate. []

**Consequence.** For a Gaussian-rational parameter with an indifferent cycle,
the split *parabolic versus irrationally indifferent* is exactly decidable by
finite means: compute `lam`, test `N(lam) = 1`, then test membership in the
four-element set. The split *Siegel versus Cremer* is **not** decided by it,
because that turns on the Brjuno condition for the rotation number. The
regime ledger therefore has one provably decidable cell next to one provably
open cell, on the same exactly representable parameter.

## 7. Decisions taken for Phase 0

| Decision | Taken | Reason |
| --- | --- | --- |
| parameter domain | `c` in `Q(i)` only | reaches every regime (section 1) and keeps arithmetic closed; interval and algebraic `c` is Phase 4, and is the bridge back to the parameter plane |
| terminology | governed registry of this repository, cross-referencing the Mandelbrot registry for shared terms; shared specifications mirrored verbatim | a second divergent registry defeats the cross-check |
| conjecture tag | `J1` throughout | ledger surfaces rendered by the same generator must not collide with `C1` |
| priority framing | regime ledger, no `PRIORITY_ZERO` conjecture | section 4 |
| executable substrate | Mojo kernels over vendored `finite_exact`, with a Python reference oracle for differential testing | matches the Mandelbrot Mojo-first policy and keeps the corpus checkable without a Mojo toolchain |

## 8. Phases

- **Phase 0** — scaffold, governed terminology, vendoring, the parameter
  corpus with exact expected verdicts, the reference oracle, the generated
  regime ledger.
- **Phase 1** — the three-valued classifier `G^c_r`, with a completeness proof
  for hyperbolic Gaussian-rational `c`.
- **Phase 2** — postcritically finite and Misiurewicz certificates reusing the
  squarefree route, on `P^c_{l,k}`.
- **Phase 3** — dynamical-ray separator catalogue, `J1` per regime, and the
  cross-check against `C1`'s adequacy machinery.
- **Phase 4** — non-triviality witnesses at `(37 + 16i)/100`, and escalation
  of `c` from `Q(i)` to exact algebraic and interval parameters.

## 9. What this document does not claim

It does not claim local connectivity of any Julia set, any Brjuno or
Diophantine property of `arg((3 + 4i)/5) / 2pi`, or that any classical
statement cited above has been verified against its literature. Every
classical statement enters the executable layer as a named theorem tag and is
unverified until the literature gate for that tag is run. The regime table in
`docs/J1_regime_ledger.md` records tags, not proofs.
