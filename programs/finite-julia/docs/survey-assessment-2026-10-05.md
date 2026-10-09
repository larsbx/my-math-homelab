# Survey assessment — next directions (2026-10-05)

Status: research-direction assessment, corrected 2026-10-06 by
`docs/literature-gate-2026-10-06-algebraic-multiplier.md`. The algebraic
multiplier is now gated; local-connectivity cells and executable verdicts
are unchanged. Other items marked *gate* still need their own literature gate.

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
- the algebraic multiplier at `niven` supplies Diophantine and Brjuno through
  an accepted import; local connectivity and `J1` remain open (§2).

Three things in the survey are actionable here:

1. a **residual-measure completeness** theorem for the classifier;
2. a rotation-domain `IN` research target at `niven`, with explicit
   quantitative and certificate obligations;
3. one roadmap box that is already discharged.

## 1. Residual-measure completeness (new target)

The classifier has two unconditional completeness theorems
(`docs/enclosure-width-lemma.md`): a box missing `K_c` becomes `OUT`, and a box
whose iterate enters a trap becomes `IN`. Neither says how much `UNKNOWN`
remains. The natural third statement is:

```text
RC(c):   area( ⋃ { B ∈ grid_r : G^c_r(B) = UNKNOWN } )  →  0     as r → ∞
```

Here the grid covers a fixed bounded observation window. `RC` is meta-level,
as the other completeness theorems are, and asserts convergence without a
computable modulus. Each finite census reports a dyadic rational, and the
limit is never inside a certificate.

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
  `cauliflower`, `parabolic_minus_one` and `parabolic_i` needs that item,
  the zero-area gate and a refinement argument. At `niven`, rotation-domain
  coverage remains a separate open task; the algebraic-multiplier gate
  alone proves no zero-area statement.

The limit also requires fair refinement and increasing certificate-search
budgets, while retaining previously certified boxes. A fixed-horizon census
does not establish this. Zero Julia area plus eventual coverage of every
point off `J_c` would give vanishing residual area on the bounded window;
the actual refinement policy must prove those hypotheses.

The deliverable has three parts:

- `RC` proved for `c0`, `basilica`, `dendrite`, `dendrite_conjugate` and
  `chebyshev`;
- `RC` stated as conditional on parabolic completeness for the three parabolic
  rows;
- `docs/classifier-census.md` reporting the `UNKNOWN` area column as a decreasing
  sequence of dyadic rationals under that persistent refinement policy, with
  no extrapolation from the current fixed-resolution census.

**Explicit non-claim.** Positive-area quadratic Julia sets exist (§1.3:
Buff–Chéritat; Avila–Lyubich; Dudko–Lyubich), so `RC` must never be stated
without its regime.

## 2. `niven`: algebraic Brjuno import, open local connectivity

`niven` is `c = (37 + 16i)/100`, with fixed multiplier `(3 + 4i)/5`.
The multiplier is algebraic and is not a root of unity. The accepted
`AlgebraicMultiplierDiophantine` import in
`docs/literature-gate-2026-10-06-algebraic-multiplier.md` gives Diophantine,
hence Brjuno. The existing linearization import then gives a Siegel disk;
Herman's unicritical theorem puts the critical point on its boundary. Neither
fact settles local connectivity. The ledger keeps `OPEN` and `UNDECIDED` for
those separate obligations.

The former assertion that no tag could ever be checked from this finite
multiplier is withdrawn. A finite continued-fraction prefix alone cannot
decide arbitrary tail classes, but this multiplier's algebraicity supplies
additional information. The gate proves no bounded-type assertion.

The former noncomputability-based exclusion from `RC` is also withdrawn.
Braverman–Yampolsky's obstruction concerns prescribed-accuracy Hausdorff
computation. `RC` asserts only area convergence without a modulus, which
does not give that computation (gate finding 5). Noncomputability therefore
proves neither failure of `RC(niven)` nor failure throughout the irrationally
indifferent regime. Zero-area and interior-coverage obligations must be
addressed on their own.

**Research direction.** A rotation-domain `IN` certificate needs explicit
audited Diophantine constants, a quantitative linearization theorem, and a
finite checker proving a box lies in the resulting domain. Gate finding 7
derives a conditional Brjuno tail estimate from the Diophantine constants.
An exact prefix computed from multiplier powers could supply its finite
part; logarithm enclosures and analytic bounds stay consumer-side. No
numerical bound, radius or such certificate is currently implemented.

The Laurent route advertised in PR #7's body is withdrawn by gate finding 6:
its multiplicative-independence hypothesis was not supplied. Nor does this
assessment adopt the unlanded claim that every non-strict trap is impossible
or that `RC(niven)` fails for the trap language.

## 3. Phase 4 and the survey

- **Witnesses where local connectivity fails.** These cases need a Cremer
  point (non-Brjuno rotation number), or a Siegel disk whose boundary misses
  the critical point (Brjuno but not Herman, per Shishikura–Yang at high
  type), or an infinitely renormalizable satellite with the
  Milnor/Sørensen/Levin criteria (§3). None is established by the corpus's
  exact multiplier verdicts. In particular, the algebraic irrational fixed
  multiplier at `niven` gives neither a Cremer example nor a Siegel disk
  missing its critical boundary point.
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
3. Rotation-domain `IN` specification and quantitative bounds at `niven`
   (§2); the qualitative algebraic-multiplier gate is now landed.
4. Parabolic completeness, which unblocks `RC` on the remaining three rows and
   was already the open Phase 1 item.
