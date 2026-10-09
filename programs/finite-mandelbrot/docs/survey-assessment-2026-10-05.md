# Survey assessment — next directions (2026-10-05)

Status: research-direction assessment. No theorem-status change, no tag gated,
no C1 block closed. Every item marked *gate* below needs a literature gate before
anything cites it.

Source: `docs/literature/open-problems-survey-2026-10.md` (external survey,
stored verbatim, status as of October 2026). Section numbers `§x.y` refer to it.

Sister assessments: `larsbx/finite-julia-set-research`
`docs/survey-assessment-2026-10-05.md`, `larsbx/finite-math-kernels`
`docs/survey-assessment-2026-10-05.md`, `larsbx/finite-dynamics`
`docs/survey-assessment-2026-10-05.md`.

## 0. Bottom line

1. **C1's residual now coincides with the field's residual.** After Yoccoz,
   Kahn–Lyubich, Dudko–Lyubich (bounded type, arXiv:2309.02107, accepted to
   Publ. IHÉS) and Kahn–Kapiamba–Lyubich (arXiv:2606.27272), the parameters at
   which MLC is open are infinitely renormalizable with either unbounded
   satellite combinatorics or primitive combinatorics accumulating on the main
   molecule (survey §1.1, "What remains unknown"). This is the class
   `docs/C1_residual_directive_carrier.md` already isolates. The deliverable is
   to make `MissingTheoremCatalogueLink` exits *name* which side of that
   partition they fall on. Closing them is Dudko's Problems 4.3/4.4 and is out
   of scope.
2. **The cheapest new finite object is the eventually periodic directive.** A
   carrier prefix can never certify bounded type, because bounded type is a
   property of the whole infinite tail. An eventually periodic directive
   `u · v^ω` is finite data, though, and it names a single infinitely
   renormalizable parameter of bounded type (stationary combinatorics:
   Feigenbaum is `v = (period-doubling)`). It is the first class where a
   class-specific tag can discharge a residual exit for a *named* parameter.
3. **Arithmetic is where the repository is already ahead of its own docs.** The
   exact-type irreducibility certificates (`ell + k <= 10`) cover the Gleason
   polynomials through period 10 and the Misiurewicz types `(m, 4)` for
   `m <= 6`, the survey's "explicit next open case" (§6). They can be extended
   to certified Galois groups, using machinery the certificates already contain.
4. **Interior completeness (OQ3 / C5) is DH-strength, so it should be stated as
   conditional.** It should not be listed as an open engineering question.

## 1. Mapping: survey item → repository object

| Survey | Repository object | Relation | Action |
|---|---|---|---|
| §1.1 MLC | C1, `docs/top-conjecture-blocks.md` | C1 ⇔ MLC (meta-level, via Schleicher) | unchanged; §2 below sharpens the residual |
| §1.1(iv)(a) Yoccoz | tag `YoccozPuzzleLocalConnectivityUnderHypotheses` | class-specific import | *gate* against Hubbard 1993 / Milnor 2000 |
| §1.1(iv)(g) DL bounded type | tag `RenormalizationWithAprioriBounds` | class-specific import, bounded `p̄` | *gate*; consumer = §2.2 |
| §1.1(iv)(d) KL ε-away / anti-molecule | same tag family | class-specific | *gate*, lower priority (decorations need a combinatorial adapter) |
| §1.1(iv)(h) KKL parabolically bounded | same tag family | depends on unpublished [DKLP] | **defer**: not gateable until [DKLP] is public |
| §1.1(iv)(i) DKL veins / ℝ | — | announced, no preprint | **forbidden import** until a preprint exists |
| §1.2 DH, §1.3 NILF | OQ3, C5, C6 | interior completeness ⇒ DH (§3) | restate OQ3 as conditional |
| §1.4 rational ray landing | tag `RationalRayLanding` | already imported | none |
| §1.5 area | three-valued renderer (Phase 3) | certified box sums | §5, optional |
| §1.5 Ewing–Schober `b_m` | — | exact rationals with 2-power denominators | kernels (§5) |
| §1.7 limbs `O(1/q²)` | — | bulb–Ford program | `larsbx/finite-dynamics` assessment |
| §4 Hertling | C6 | DH ⇒ computability of M | cite in C6 as the classical anchor (*gate*) |
| §5 core entropy | `docs/hubbard-core-entropy-literature-gate-2026-09-17.md` | census already licensed | unchanged; the survey adds nothing that changes that gate |
| §6 Gleason / Misiurewicz | `kernel/mojo/dynamics/exact_type_irreducibility.mojo` | finite-range certificates | §4 |
| §6 Poonen | — | rational periodic points over ℚ | **not recommended** (§6) |
| §6 equidistribution | tag `HarmonicMeasureAlmostEveryFibreTrivial`; B4 of `docs/multiset-bridge-program.md` | classical background | none |
| §7 Multibrot, tricorn, cubic locus | — | out of scope | none; the cubic failure of local connectivity is a useful negative control for prose that over-generalises C1 |

## 2. C1: sharpening the residual

### 2.1 Partition of residual exits

Write `D = (τ_1, τ_2, …)` for the directive sequence of an infinitely
renormalizable parameter, where `τ_i` is the tuning pattern at level `i` with
relative period `p_i`, flagged satellite (`S`) or primitive (`P`). From §1.1:

```text
sup_i p_i < ∞                                  ⇒ MLC at c      (DL 2309.02107)        [bounded]
finitely renormalizable                        ⇒ MLC at c      (Yoccoz)                [not residual]
otherwise, unbounded:
  (U-S) infinitely many unbounded S-levels     open (Dudko Problem 4.3)
  (U-P) P-levels accumulating on main molecule open (Dudko Problem 4.4)
  KL / KKL / Cheraghi–Shishikura subclasses    known, class-specific
```

Proposed refinement of the exit type, data only, with no new closure:

```text
MissingTheoremCatalogueLink
  := ResidualUnboundedSatellite   -- Problem 4.3
   | ResidualMoleculePrimitive    -- Problem 4.4
   | ResidualUnclassified         -- finite prefix cannot decide the split
```

**Honest limit.** A finite carrier prefix decides none of the three, since each
is a tail property. The refinement is useful only for exits whose directive is
*given* as finite data (§2.2). For carriers built from finite ray prefixes,
`ResidualUnclassified` is the correct, permanent label.

### 2.2 Eventually periodic directives

Object: `PeriodicDirective := (u: [Level], v: [Level])`, `v ≠ []`, read as
`u · v^ω`.

- Finite, exact and checkable by the existing kernel. Each level is a periodic
  rational address, as in `docs/C1_residual_directive_carrier.md`.
- `sup p_i = max over u ++ v` is computed, not asserted, so bounded type follows
  by inspection.
- Under the gated tag `RenormalizationWithAprioriBounds[DL-bounded]`, the fibre
  of the named parameter is trivial. That discharges `PersistentNonSeparation`
  for any pair in which one side is such a parameter. It would be the first
  residual exit closed for a named infinitely renormalizable parameter.
- Satellite/primitive flag per level: a level is a relative (untuned) address,
  and it is `S` ⇔ its component is a `p/q`-satellite of the main cardioid,
  read off the ray pair by the existing
  angle-doubling kernels. Needs one spec paragraph and paired controls: the
  rabbit `1/7` (the `1/3`-satellite of the main cardioid) is `S`, and the
  airplane `3/7` (the real period-3 component, whose root lies on no other
  component) is `P`.

Test plan (TDD):

- Feigenbaum: `u = []`, `v = [level(1/3)]` (basilica tuning, `p = 2`, `S`).
- Tripling: `v = [level(3/7)]` (real, `P`) and `v = [level(1/7)]` (complex,
  `S`; the Goldberg–Khanin–Sinai case of §1.1(g)).
- Adversarial: `v = []` is refused, and an overflowing period product is refused.

### 2.3 Tag ledger hygiene

- `RenormalizationWithAprioriBounds` should carry `conclusion_scope =
  bounded_type(p̄)`. Its strength class stays `CLASSICAL_IMPORTED_CLASS_SPECIFIC`,
  which the ledger already requires.
- Add DKL (veins and ℝ), [DKLP] and "Virtual renormalization" to *Forbidden
  imports* as announced-unpublished, with a re-check trigger when preprints
  appear.

## 3. OQ3 / C5: interior completeness is DH-strength

Claim (classical, via §1.2):

```text
(∀ dyadic B ⋐ int M) ∃ attracting-cycle certificate for B   ⇒   DH
```

Proof sketch: a queer component `W` would contain a box `B ⋐ W`, and no
parameter in `W` has an attracting cycle, so no certificate exists. Conversely,
under DH, `int M` is a disjoint union of open hyperbolic components and a box
is connected, so `B ⋐ int M` forces `B ⋐ H` for a single component `H`. Hence:

```text
C5(int M)  ⇔  DH  ∧  C5(H) for every hyperbolic component H
C5(H)      — expected provable unconditionally (multiplier bound |λ| < 1 on compact B ⋐ H)
```

So the open content of OQ3 is DH, and the finite content is `C5(H)`.

Edits: `docs/open-questions.md` OQ3 and `docs/bridge-conjectures.md` C5 should
say this. C6 should cite Hertling (DH ⇒ M computable) as its classical anchor,
because C6's "complete precisely to the degree that …" is the finite shadow of
that theorem.

## 4. Arithmetic: from irreducibility to Galois groups

Current state (`docs/multiset-bridge-program.md`, B1): `E_{ell,k}` is irreducible
over ℚ for `ell + k <= 10`. The certificates are distinct-degree factor patterns
at up to five primes, with only trivial common subset sums.

Survey anchors (§6):

- Gleason `G_n` is irreducible for `n <= 19` only by an unpublished Magma
  computation (Doyle–Fili–Tobin, via Ramadas). No public, replayable
  certificate exists.
- Misiurewicz `d = 2` is proved for all `m` only when `n <= 3`.
- Galois groups are open.

Directions, cheapest first:

1. **Certified `Gal = S_d`.** Given that `E` is irreducible (transitive), suppose
   that at good primes `p_1, p_2`:
   - `E mod p_1` has squarefree pattern `(2, 1, …, 1)`, which gives a transposition;
   - `E mod p_2` has pattern `(d−1, 1)`, which gives a `(d−1)`-cycle, so the
     group is doubly transitive.

   Then `Gal(E/ℚ) = S_d`, since a doubly transitive group containing a
   transposition is symmetric. The certificate format already holds the
   patterns; this adds a search over primes and a checker. A capped search that
   finds no witness is *inconclusive*, never "not `S_d`".
2. **Gleason `n = 11 … 14`, replayable.** Degrees are 1023, 2010, 4095 and 8127.
   Mod 2, every factor of `G_n` has degree `n`, or `n/2` for even `n`
   (recomputed 2026-10-05 for `n <= 16` by a scratch distinct-degree
   factorisation; this repeats the Buff–Floyd–Koch–Parry picture and claims no
   novelty). So the prime 2 alone never certifies, and the subset-sum argument
   needs further primes. Cost is dominated by Frobenius powering mod `E`; kernel
   placement is a finite-math-kernels question.
3. **Misiurewicz `(m, 4)` for `m > 6`.** These are finite-range data towards
   the open `n = 4` case. Goksel's mod-2 criterion cannot settle it, because
   `G_4 mod 2 = (deg 2)(deg 4)`. Before any claim, a literature check is needed:
   finite-range computations for `n = 4` may already exist.

Each item is a finite fact with a replay. None of them bears on C1.

## 5. Area (optional, engineering-heavy)

The three-valued renderer of ROADMAP Phase 3 already defines the right objects:

```text
area(M) ≥ Σ_{B certified IN} |B|        area(M) ≤ |R| − Σ_{B certified OUT} |B|
```

Both bounds are exact dyadic rationals, with no `π` and no floats. Targets:

- beat Heiland-Allen's fully certified `[1.4165, 1.8479]` (§1.5);
- stretch: Fisher–Hill's `[1.50297, 1.57013]`, which is rigorous only up to
  double precision.

Inscribed rational polygons in the main cardioid come free from rational points
on the multiplier conic (`c = λ/2 − λ²/4` with `λ` of quadrance 1), and give
interior area without a trap search. The Ewing–Schober upper bound
`area/π ≤ 1 − Σ_{m ≤ N} m b_m²` is an exact rational statement once `b_m` are
computed exactly. That belongs in the kernels (see the sister assessment).

Priority: below §2 and §4. It is publishable only if it beats a certified
bound, and it does not touch C1.

## 6. Not recommended

- **Poonen's conjecture, period ≥ 6.** Rational points on dynamical modular
  curves need Chabauty and descent machinery. The certificate calculus has no
  leverage, and naive height searches are saturated (Hutz–Ingram to `10^8`).
- **Re-deriving MLC subcases.** The tags import them; the repository verifies
  hypotheses and does not re-prove analytic theorems
  (`docs/top-conjecture-blocks.md`).
- **Core-entropy regularity (§5 Hölder spectra).** These are analytic questions
  about limits, with no finite certificate shape.

## 7. Proposed order

1. Tag-ledger hygiene (§2.3) and OQ3/C5/C6 restatement (§3). Docs only.
2. Literature gates: `RenormalizationWithAprioriBounds[DL-bounded]`, Yoccoz,
   Hertling.
3. `PeriodicDirective` plus satellite/primitive flag (§2.2), test-first.
4. Certified `S_d` Galois groups for `ell + k <= 10` (§4.1).
5. Gleason `n = 11 … 14` (§4.2), after a kernel placement decision.
