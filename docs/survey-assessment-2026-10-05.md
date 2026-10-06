# Survey assessment — next directions (2026-10-05)

Status: research-direction assessment. No tag gated, no row of the regime
ledger changed. Items marked *gate* need a literature gate in this repository's
format before anything cites them.

Source: the external open-problems survey stored verbatim in
`larsbx/finite-mandelbrot-research` as
`docs/literature/open-problems-survey-2026-10.md` (status October 2026).
Section numbers `§x` refer to it. The parameter-plane assessment lives beside it
in that repository.

## 0. Bottom line

The survey is mostly about the parameter plane. Its main effect here is to
**confirm that the regime ledger has the right shape**:

- every connected corpus row except `niven` is in a regime where local
  connectivity is classical;
- the `niven` row is permanently `UNDECIDED` for finite data, for a stronger
  reason than the ledger currently gives (§2).

Three things in the survey are actionable here:

1. a **residual-measure completeness** theorem for the classifier;
2. a precise reason why `UNKNOWN` at `niven` admits no general completeness
   theorem;
3. one roadmap box that is already discharged.

## 1. Residual-measure completeness (new target)

The classifier has two unconditional completeness theorems
(`docs/enclosure-width-lemma.md`): a box missing `K_c` becomes `OUT`, and a box
whose iterate enters a trap becomes `IN`. Neither says how much `UNKNOWN`
remains. The natural third statement is:

```text
RC(c):   area( ⋃ { B ∈ grid_r : G^c_r(B) = UNKNOWN } )  →  0     as r → ∞
```

Here `RC` is meta-level, as the other completeness theorems are. Each finite
census reports a dyadic rational, and the limit is never inside a certificate.

`RC(c)` needs two inputs:

- **`area(J_c) = 0`.** By §1.5 (Lyubich), `J_c` has zero area whenever `p_c`
  has no irrationally indifferent cycle and is not infinitely renormalizable.
  That covers every connected corpus row except `niven`. The hyperbolic rows
  need only the elementary argument; the Misiurewicz and parabolic rows are
  covered by the geometrically finite literature already cited by the
  `TanYinGeometricallyFiniteLocallyConnected` gate. *Gate:* a zero-area tag,
  scoped to "not infinitely renormalizable and no irrationally indifferent
  cycle".
- **Interior coverage.** Hyperbolic rows already have it, from trap completeness
  plus `FatouHyperbolicInteriorIsTheBasin`. Parabolic rows do not: this is the
  open roadmap item "Completeness at a parabolic parameter". `RC` at
  `cauliflower`, `parabolic_minus_one` and `parabolic_i` is therefore blocked
  by that item and by nothing else.

The deliverable has three parts:

- `RC` proved for `c0`, `basilica`, `dendrite`, `dendrite_conjugate` and
  `chebyshev`;
- `RC` stated as conditional on parabolic completeness for the three parabolic
  rows;
- `docs/classifier-census.md` reporting the `UNKNOWN` area column as a decreasing
  sequence of dyadic rationals, with no extrapolation.

**Explicit non-claim.** Positive-area quadratic Julia sets exist (§1.3:
Buff–Chéritat; Avila–Lyubich; Dudko–Lyubich), so `RC` must never be stated
without its regime.

## 2. `niven` is undecidable for finite data, twice over

`niven` is `c = (37 + 16i)/100`, with an irrationally indifferent fixed point of
multiplier `(3 + 4i)/5`. The ledger records local connectivity as open because
the Brjuno status of the rotation number is unknown. The survey sharpens this
in two ways.

1. **Rotation-number classes are tail properties.** Every positive result the
   survey lists for the Siegel case depends on the full continued fraction of
   the rotation number:
   - bounded type: Douady–Ghys, Zhang;
   - almost every rotation number: Petersen–Zakeri;
   - high type: Shishikura–Yang, JEMS 2025;
   - Herman numbers.

   An exact computation can produce any finite prefix of that continued
   fraction. No prefix decides Brjuno, bounded type, high type or Herman. So no
   tag can ever be *checked* at `niven` from finite data, and `UNDECIDED` is the
   permanent finite verdict. It is not a gap waiting for a better tag.
2. **No general completeness at irrationally indifferent parameters.**
   Braverman–Yampolsky (§4) give computable parameters with an irrationally
   indifferent fixed point whose `J_c` is not computable. Filled Julia sets,
   on the other hand, are always computable. Consequences for the classifier:
   - `OUT`-completeness (boxes missing `K_c`) is consistent with this and
     already proved;
   - any `RC`-type statement over the whole irrationally indifferent regime
     would contradict Braverman–Yampolsky, so `RC` must stay per-regime and
     must exclude this row.

Proposed ledger annotation: next to the existing `OPEN` for local connectivity
at `niven`, record "finite-data undecidable: tail property (§2.1);
no regime-wide completeness (Braverman–Yampolsky)". *Gate* Braverman–Yampolsky
before citing it.

A continued-fraction prefix of the rotation number is still worth computing
exactly, as data. Under the rational-trigonometry discipline it has to come from
the multiplier's powers, never from an inverse trigonometric function. It must
be reported as a prefix, never as evidence for a rotation-number class.

## 3. Phase 4 and the survey

- **Witnesses where local connectivity fails.** These cases need a Cremer
  point (non-Brjuno rotation number), or a Siegel disk whose boundary misses
  the critical point (Brjuno but not Herman, per Shishikura–Yang at high
  type), or an infinitely renormalizable satellite with the
  Milnor/Sørensen/Levin criteria (§3). None of them is reachable at a
  Gaussian-rational parameter with a decided regime.
  `docs/permanent-non-separation.md` is right that this item is out of reach.
  The survey gives no new route to it.
- **Interval-parameter escalation.** When `c` is an enclosure, the parameter
  box generally meets infinitely renormalizable parameters. Dudko–Lyubich
  (bounded type) gives local connectivity of `J_c` there (§1.1(g)), but only
  for parameters named by infinite combinatorics. The parameter-plane
  assessment's eventually periodic directive is the matching finite name. Any
  bridge should go through that object, not through boxes.

## 4. Housekeeping

- The ROADMAP box "Gate `FatouHyperbolicInteriorIsTheBasin`" is discharged by
  `docs/literature-gate-2026-09-20-basins.md`, which accepts it for the
  quadratic family. It is ticked in the same change as this note.
- `docs/J1_finite_classical_dictionary.md` and the verdict table of
  `docs/literature-gate-2026-09-19.md` still describe
  `FilledJuliaLocalConnectivityTransfer` as ungated, but
  `docs/literature-gate-2026-09-19-transfer.md` discharges it. Those two
  documents should be amended.

## 5. Proposed order

1. Housekeeping (§4).
2. Zero-area tag gate, then `RC` for the five non-parabolic connected rows (§1).
3. `niven` annotation and Braverman–Yampolsky gate (§2).
4. Parabolic completeness, which unblocks `RC` on the remaining three rows and
   was already the open Phase 1 item.
