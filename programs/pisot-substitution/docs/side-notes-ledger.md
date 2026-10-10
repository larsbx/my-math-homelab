# Side-notes ledger

**Status:** live, append-only working ledger. It records side findings so that
no session re-spends cycles on them: refuted mechanisms, redirected routes,
specimens already settled by the literature, withdrawn figures, finite
observations, and tooling pitfalls. It changes no claim status; each entry
points to the note or receipt that carries the evidence. Policy:
`AGENTS.md`, "Record side findings".

Entry format: date · finding · evidence locator. Add entries at the end of the
right section; correct an entry by adding a dated correction under it, never
by deleting it.

## 1. Refuted or retired mechanisms (do not re-attempt)

- 2026-10-02 · One-step descent of the contracting size `q(t)` (or of
  `max_k |sigma_k(t)|/B_k`) as a local reason for boundary hitting: fails on
  234 of 1,166 recurrent vertices of the cube specimen. ·
  `p1b-vertex-coincidence-box-2026-10-02.md` §5.2
- 2026-10-02 · Endpoint hitting (first common vertex on the leftmost or
  rightmost chain): fails on the golden pump (8 of 716). · same, §5.2
- 2026-10-02 · First-hit depth ≤ contracting lower bound `m_0` + small
  constant: excess reaches 14. · same, §§5.2, 5.4
- 2026-10-03 · Ratio laws `K_V <= c / log(1/mu)` with `c = 3.2` or `4`:
  violated on images ≤ 4 (1,506 and 72 specimens). The existential form
  (Conjecture UH) stays open. · same, §5.5a
- 2026-10-03 · One-tile reduction (every recurrent vertex reaches a catch-up
  hit): false; 360 corpus specimens fail, 210 totally. · same, §5.6b
- 2026-10-04 · One-step M-adic valuation ascent as a local mechanism for T2:
  holds on none of the 210 (corpus) or 654 (total length ≤ 8) catch-up-free
  specimens; ascent depth reaches 25. · same, §5.6d;
  `kernel/valuation_ascent_census.mojo`
- 2026-10-04 · Universal noncoincident-cycle exclusion: retired earlier
  (flipped Tribonacci); formal carriers confirm that coincidence-free cycles
  are ubiquitous (13,260 on the corpus), realized or not. ·
  `formal-overlap-carriers-2026-10-04.md`
- 2026-06-13 (archive) · H3 letter-graph / affine-fixed-point trapped
  detector: transpose bug (offset matrix is `M`, not `M^T`) and wrong object.
  · `archive/2026-09-08/notes_2026_06/H3_LETTERGRAPH_BUG_2026_06_13.md`
- 2026-06-13 (archive) · Collar certification lemma `R(C) <= L_sigma`:
  refuted. · `archive/2026-09-08/notes_2026_06/COLLAR_LEMMA_REFUTED_2026_06_13.md`

- 2026-10-06 · Hub-guarded nonincrease of the physical cut potential `|i-j|`
  on target-free PIP occurrence transitions is false: replayed cycle
  `396,820` has hub word `1,1` and offset `0,1,0`; its first edge selects an
  actual interior child. The support is productive, so this is a local
  monovariant negative, not a strict component counterexample. ·
  `c4-ordered-hub-offset-negative-2026-10-06.md` §3;
  `evidence/ordered-hub-packets-2026-10-06/`

## 2. Redirected routes (no lever there; see the decision)

- 2026-10-05 · The `CU` / one-tile route cannot reach #139, and Proposition LC
  says why in terms of objects rather than counts: a `CU`-failure *is* a
  prefix-vs-interior periodic pair, whose centre is a vertex of one tiling of
  infinite level and interior to every level tile of the other — hence
  **never** a common vertex, by construction. So these pairs are a forced,
  abundant family (10,584 on the corpus, on 2,760 specimens) that costs
  nothing: G1 holds on the whole standing corpus anyway. The genuine
  obstruction to #139 is the **interior-vs-interior** pair of Theorem B, where
  the centre is a vertex of neither tiling and a shared vertex elsewhere is
  open — `psc.periodic_pair` and PPVC. Spend #139 effort there. The leftmost
  chain's remaining use is Corollary LC5. ·
  `p1b-leftmost-chain-periodic-pair-2026-10-05.md` §8b

- 2026-10-03 · Barge's (W) / beta-numeration monotonicity as a route to PPVC:
  it is a consequence of pure discrete spectrum, not independent of it. ·
  `p1b-vertex-coincidence-box-2026-10-02.md` §5.7 route check
- 2026-10-04 · Adelic coverage for T2 on the catch-up-free class: needs the
  multiplicity-one window property, which pure discrete spectrum gives; the
  class's arithmetic does not lower the bar. · same, §5.6e
- 2026-10-04 · Vertex-sheet alignment as a PDS-free lever: under SC_all a
  common vertex of two `Phi^r`-fixed tilings forces a common tile (Lemma VT),
  so it is tile coincidence. · same, §5.6f
- 2026-10-04 · Recoding a catch-up-free `|det M| = 2` substitution to a
  unimodular one on three letters: impossible, `|det M| = |N(beta)|` is an
  invariant of the Perron number. · same, §5.6e
- 2026-10-04 · Barge-class conjugacy for catch-up-free substitutions with one
  E letter and a length-1 image: powers provably never work (Lemma B); no
  rotation witness found (0 of 264 at total length ≤ 8). · same, §5.6g

- 2026-10-07 · A symbolic (Sellami-style) balanced-pair run over Theorem E's
  parameters, as a route to termination on the catch-up-free `|det M| = 2`
  class: the states are not parametric words. Maximal state length grows
  exponentially along lines (class A `(n, n − 1, n)`: 480, 2,124, 27,768
  letters at `n = 4, 5, 6`; class D `(1, 0, 0)`: 7,987). Work on the overlap
  graph, whose vertices are bounded. · `p1b-catch-up-free-ppvc-2026-10-07.md`
  §3; scratch `explore.py`

- 2026-10-07 · A one-step contracting trapping region as the finite
  candidate set for PPVC on a line of class B: finite but not constant (413 to
  593 lattice points for `q = 2..25` on `p = 2q + 2`, `r = q + 1`), while the
  true recurrent set is a constant 120 vertices. Use the swap-seed closure
  instead: pure discrete spectrum needs one seed, G1 needs the three, and
  neither needs a box. · `p1b-symbolic-line-2026-10-07.md` §2;
  `archive/2026-10-07/symbolic-line-probes/trap_float_probe.out`

## 3. Settled by the literature (do not target with new machinery)

- 2026-10-04 · Specimens with a power or common-prefix/suffix conjugate in
  Barge's 2016 class or its mirror have pure discrete spectrum, hence PPVC
  and G1: 1,248 of the 4,554 corpus specimens, 6,336 of the 24,486 of total
  length ≤ 8; in the catch-up-free class 78 of 210 and 174 of 654. List them
  with `pixi run barge-class-census [total]`. Rests on the imported Barge
  (2016) and, for PPVC, on Theorem S (unreviewed). ·
  `p1b-vertex-coincidence-box-2026-10-02.md` §5.6g

- 2026-10-04 · PDS ⇒ all-pairs prefix strong coincidence for irreducible
  Pisot substitutions: Akiyama–Lee 2014, Corollary 4.5; in the non-unit case
  the height-group step is Theorem R (repository, unreviewed), since Sing's
  2006 thesis is not retrievable (Bielefeld repository refuses access). Do
  not re-search; consequence FP ⟺ PDS. ·
  `pds-strong-coincidence-literature-gate-2026-10-04.md`

- 2026-10-07 · Theorem K's family has no power or rotation in Barge's PDS
  class or its mirror: the initial (and final) letters of `sigma^n` on
  `o, y, z` alternate `(y, o, o)` / `(o, y, y)`, never injective, never
  constant, no common first letter. Do not test Theorem K's members against
  `barge_witness` again. · `p1a-tail-literature-gate-2026-10-07.md` §3

- 2026-10-07 · **Bounded `Z_2` closes the tails for every `Delta`.** With
  `Z_2 <= cap` the members' run patterns are finitely many and fully
  revealed (`w_1` or `u` beginning with `z`, at most `Z_2 + s` z-runs;
  `w_2` at most `cap`), symbolic in `Delta` and the run lengths; split by
  the value of `Z_2` (pieces above `cap` left out) each closes:
  `s = +1, Z_2 <= 1`: 24 patterns, 51 regions, 3 s; `Z_2 <= 2`: 60
  patterns, 748 regions, 45 s; `s = −1, Z_2 <= 2`: 20 patterns, 92 regions,
  2.5 s. Days of the open-tail run tree had not closed what this
  decomposition closes in seconds: decompose by the Pisot factor first.
  · `kernel/odd_letter_family_certificate.mojo` (`zcap_cover`, driver
  `2 zcap s cap budget`)

- 2026-10-07 · The Z_2-cap route, measured beyond cap 3. s = −1, Z_2 <= 4
  does not close: of its patterns, `zy | yzyzyz`, `zy | yzyzyzy`,
  `zy | yzyzyzyz` keep 9, 36 and 10 open regions after the finishers
  (Fourier-Motzkin bounds, implied equalities, point-by-point decision up
  to 2,000 points): the leftovers are finite boxes of up to ~18,000 points
  (`n2` in `[20, 42]`, `n4, n6 <= 27`), slices with large constants
  inherited from earlier carvings, where certificates found elsewhere do
  not extend. Cost per cap: 3 s, 45 s, 82 s for the closed caps, hours at
  cap 4. Witness shapes at `s = −1, Delta = −2`, `|w_1| <= 6` (scratch
  census of distinct members): `Z_2 = 2`: 24 members, 20 shapes; `Z_2 = 3`:
  186, 42; `Z_2 = 4`: 470, 86. The leading shapes at `Z_2 = 3` and `4` are
  the same level-3 paths (`w_1` read from its start, `w_2` from its end),
  so the bulk is uniform in `Z_2`, but the number of shapes grows with it:
  no finite named-path lemma covers all `Z_2` from this census. ·
  `kernel/odd_letter_family_certificate.mojo` (`zcap_cover`); scratch
  `zshape.py`

- 2026-10-07 · Unbounded `Z_2`: Lemma P1 is needed only **linearly**. At
  the McCormick corner `(floor, b_lo)` (`a = Z_2`, `b = |Delta| − 1`) it
  implies one affine form, `2 Y_2 >= Z_2 + 2 Delta − 8` (`s = +1`,
  `Delta >= 2`, `Z_2 >= 3`) and `2 Y_1 >= Z_2 + 3|Delta| − 4` (`s = −1`,
  `|Delta| >= 2`, `Z_2 >= 4`) (`z_floor_forms`). On that polyhedral region
  every non-crossing pair tested is coincident, PIP or not: exhaustive
  `|w_1| <= 9` (`s = +1`: 453 pairs; `s = −1`, `|w_2| <= 13`: in progress)
  holds only PIP pairs (non-PIP region points need longer words), so a
  seeded sample of the **non-PIP** part (seed 1, 150 draws each sign,
  `Z_2 <= 8`, `|Delta| <= 6`; seed 2, `s = +1`, 400 draws, `Z_2 <= 14`,
  `Delta <= 10`) found every pair coincident by level 4 (draw budget 200
  per wanted pair, not exhausted). Outside it, non-PIP pairs do fail (e.g.
  `w_1 = z^k y^3`, `w_2 = z^(k−1)`, `k >= 6`: no tile by level 7), so the
  quadratic is replaced, not dropped. Consequence: the open-tail cover needs
  no McCormick staircase; `2 zfloor s delta floor budget` runs it.
  · `kernel/odd_letter_family_certificate.mojo` (`z_floor_forms`,
  `cover_pattern_guided(z_floor=)`); scratch `lin.py`, `linsamp.py`
  Correction (2026-10-07): the `s = −1` exhaustive run "in progress" never
  started (launched from the wrong directory); the `s = −1` exhaustive figure
  is `|w_1| <= 7`, `|w_2| <= 11`: 1,395 region pairs, all PIP, all coincident
  by level 5. The seed-2 `s = −1` sample (400 wanted, `Z_2 <= 14`,
  `|Delta| <= 10`) was killed out of memory (10.5 GB: `first_tile` expands
  whole level-6 words), so it reports nothing; `s = −1` rests on seed 1 only.

- 2026-10-07 · Unbounded `Z_2`, the z_floor cover run: **what blocks is a
  product inside the certificates, not Lemma P1's staircase.** (1) The
  open-tail trees `2 zfloor 1 2 3 5000 8` and `2 zfloor -1 -2 4 5000 8`
  refine their roots and first children (open regions 12, 59 and 58, 184;
  10–30 min per pattern) and were stopped after ~1 h without a verdict. The
  root's open regions are opaque-tail regions with no certificate, so z_floor
  leaves §3i's doubly open chain where it was. Re-running the cells
  `(+1, 2)` and `(−1, −2)` after the cover-leak fixes
  (`2 cell ±1 ±2 30000 8 plain`) walks the same chain: no verdict after 70
  min. (2) Fully revealed patterns with every run length symbolic, so `Z_2`
  and `Delta` unbounded, under z_floor (scratch `zruns`, budget 5,000):
  `s = +1`, `Z_2 >= 3`, `Delta >= 2`: all 17 patterns with `u` of at most 2
  runs and `w_2` of at most 4 runs close (at most 28 regions, 7 s each)
  except `zy +y^(2+e) | zyzy`, with no verdict after 40 min. `s = −1`,
  `Z_2 >= 4`, `Delta <= −2`: 11 close; `zy | yz` and `zy | yzy` end with 1
  and 2 open regions, and `zy | yzyz` gave no verdict after 25 min.
  (3) The open region of `zy | yz` is `w_1 = z^a y^b`,
  `w_2 = y^(b+2+e) z^(a+1)`, `Delta = −2 − e`. Its witnesses
  `(y, z, −e_o) → (y, z, a e_z − (a+2) e_y) → (y, y, −4 e_o) → (y, y, 0)`
  have `M d = (−4, 2a − 2b + ae, −a)`: the `a b` terms cancel. So the
  level-3 positions `k` (in `y^b`) and `m` (in `y^(b+2+e)`) need
  `k − m = 2b − 2a − ae`. That product is Lemma P1's own:
  `f(−1) = ae + a − 2b + 2`, and `k − m = 2 − a − f`. The certificate is
  affine in `(a, b, e, q = ae)` but not in `(a, b, e)`, so lifting by run
  offsets only carves slices (polynomial line mode's "degree-2 part does
  not vanish"). This one family, with the level-4 offset `t` in `0..2`,
  verifies on 1,134 of the 4,913 members with `a <= 11`, `b < 80`, `e <= 8`
  (brute recomputation, scratch `qcert.py`). In line mode,
  `M (c_0 + lambda (e_z − e_y)) = M c_0 + lambda (0, −Delta, −s)` with
  `lambda` affine and `Delta = D ± e`, so every product a line certificate
  needs has the form `n_j e` (`e` included). **Next:** lift the cover by
  the coordinates `q_j = n_j e`. Lemma P1 then becomes exactly affine, so
  no McCormick wedge is left; certificates become affine; regions are
  polyhedra in `(n, q)` whose real points satisfy `q = n e`, under the
  envelope `q_j >= lo_j e + lo_e n_j − lo_j lo_e`. Do not spend more budget
  on z_floor trees or on fixed-`Delta` cells with opaque tails. ·
  `experiments/z2-route/` (`zruns.mojo`, `onepat.mojo`); scratch `qcert.py`;
  `kernel/odd_letter_family_certificate.mojo` (`cover_pattern_guided(z_floor=)`)

- 2026-10-07 · **The q-lift closes the `s = −1` tail leaf `zy | yz`**
  (`Delta = −2 − e <= −2`, `Z_2 >= 4`): `2 qlift -1 -2 4 5000 zy 0 yz 0`
  ends with 104 regions, 35 certified (20 by polynomial paths lifted over
  `(n, q)`), 6 cut, 34 without a real member, **0 open**, in ~50 s; the
  plain z_floor cover of the same leaf leaves 1 open region of 16. Three
  things were needed besides the lift itself, each a finding: (1) the
  point search must reach the path at all: with offset bound 3 it cannot
  pass `(y, y, −4 e_o)`, and with the line offset bounded it cannot pass
  `(0, −(a+2), a)` once `a > 3`, so the q-lift searches with bound 4 off
  the line and the line position free (`search_witness_line(line_cap=)`);
  (2) the lift must not solve a line coordinate to the point's constant
  (that pins `lambda = a` and carves the slice `a = const`, an endless
  staircase), and among lifts it prefers one whose end offset is zero over
  `(n, q)` (`lift_path_poly(lift=)`); (3) regions without a real point are
  settled exactly when `e` is bounded, by `search_point` on the forms with
  `e` fixed (`_point_search`). Beyond `zy | yz` no verdict after ~15 min
  (budget 5,000, runs stopped): `zy | yzy` walks a staircase in `a` (each
  lifted path carries a bound `a <= const`; 1,293 regions, 11 open so
  far), `zy | yzyz` reports regions open, mostly with no real point found
  (159 of 812 regions so far), and `s = +1` `zy +y^(2+e) | zyzy` (Delta >= 2,
  Z_2 >= 3) walks a staircase in one run length (187 regions, none open). ·
  `kernel/odd_letter_family_certificate.mojo` (`cover_pattern_guided(q_lift=)`,
  main mode `qlift`); `kernel/psc/product_lift.mojo`; `kernel/psc/poly_line.mojo`;
  `test_the_q_lift_closes_the_zy_yz_tail_leaf`

- 2026-10-07 · The q-lift measured, budget 5,000 per pattern, `timeout
  1800` per run (four runs side by side on 4 cores): **only `zy | yz`
  closes; nothing else reached a verdict.** `s = −1` (`Delta <= −2`,
  `Z_2 >= 4`): `zy | yz` closed (104 regions, 0 open, 49 s); `zy | yzy`
  timed out after 1,657 regions (354 line and 232 polynomial paths, 11 open
  with no real point), climbing a staircase that had reached `a = 191`;
  `zy | yzyz` timed out after 938 regions (103 polynomial paths, 1
  polynomial crossing, 161 open with no real point, 26 open with no
  certificate). `s = +1` (`Delta >= 2`, `Z_2 >= 3`): `zy +y^(2+e) | zyzy`
  timed out after 212 regions (206 paths, none open), a staircase of one
  region per value of one run length, which had reached 235. Sweeps
  (`zruns … 4 4 5000 1`, 36 patterns each, timed out): `s = −1` closed the
  first 12 patterns (11 one region or none, `zy | yz` in 48 s) and then
  spent the rest of the time on `zy | yzy`; `s = +1` closed the first 13
  and then spent the rest of the time on `zy +y^(2+e) | yzyz`. **The q-lift
  is not a uniform improvement.** The plain z_floor cover closed
  `zy +y^(2+e) | yzyz` in 3 regions, but under the q-lift it climbs a
  staircase (a 4-minute verbose run: 138 regions, 92 polynomial paths, 42
  open with no real point). The other 23 patterns of each sweep were never
  reached. · `experiments/z2-route/zruns.mojo` (optional `qlift` argument);
  `kernel/odd_letter_family_certificate.mojo` (main mode `qlift`)

- 2026-10-07 · The q-lift's staircases are gone and its no-point regions are
  refuted exactly; **`zy | yzy` now ends with 1 open region, and the q-lift
  closes 2 more `s = +1` patterns in the sweep.** Four additions, all under
  `q_lift` only (flag-off output byte-identical): (1) extent-aware lift
  selection: `lift_path_poly` ranks children by whether the state is affine
  over `(n, q)` and returns the complete lift with the largest `lift_key`
  (number of real probe points of the region, `probe_points`, where the
  carving forms and the zero end offset hold, then lowest offset cost);
  `_poly_carve` lets the tree lift compete with `solve_lift` by that key, and
  `_implied_equality` is substituted eagerly. The staircases came from lifts
  that copy a coordinate of the base point into an offset (pinning `a` in
  `zy | yzy`, one run length in `zy +y^(2+e) | zyzy`). (2) RLT cuts
  (`product_lift.rlt_forms`): `(e − lo_e) g >= 0` and `(hi_e − e) g >= 0`
  for every assumption `g` over `n` alone, expanded with `n_k e = q_k`.
  (3) An exact phase-1 LP (`psc/farkas_lp.mojo`, Bland's rule over
  `finite_exact.Q`) whose answer counts only through a Farkas vector checked
  exactly (`y >= 0`, `yᵀA <= 0`, `yᵀc < 0`), used where a region gets no
  base point; kernel Fourier–Motzkin keeps redundant rows and hits its
  4,000-row cap even on 3 live variables. (4) `_value_split`: a variable
  whose range is bounded by checked certificates is split into its values,
  an exact partition. Measured (budget 5,000): `sweep.sh`, r1 = r2 = 4, 300
  s per pattern, the two signs in parallel: `s = +1` (`Delta >= 2`,
  `Z_2 >= 3`) 30 closed by plain, 2 by the q-lift, 0 open, 4 timeouts
  (was 30 / 0 / 0 / 6); `zyz +y^(2+e) | yzyz` (q-lift 121 regions, 27 s)
  and `zyzy +y^(2+e) | yzy` (193 regions, 66 s) went from timeout to closed.
  `s = −1` (`Delta <= −2`, `Z_2 >= 4`) 25 plain, 1 q-lift, 1 open, 9
  timeouts (was 25 / 1 / 0 / 10): `zy | yz` closes in 42 regions, 10 s (was
  104, 49 s), and `zy | yzy` went from timeout to open. The other 69
  patterns kept their verdicts; every remaining timeout outside `zyz | yz`
  is killed inside the plain cover, so the q-lift never runs on it (this
  includes `zy +y^(2+e) | zyzy`, which the q-lift alone closes in 17
  regions, 3 s). Single runs (`2 qlift -1 -2 4 5000 zy 0 … 0`, `timeout
  1200`): `zy | yzy` 120 regions (49 certified, 46 line, 44 polynomial, 1
  crossing, 2 cut, 58 not member), **1 open**, 89 s, terminating; `zy |
  yzyz` timed out at 1,200 s at region #1293 with 14 open without a real
  point, 3 open without a certificate and 10 value splits traced. **Open:**
  `zy | yzy`'s region is LP-feasible over `(n, q)` with no bounded variable;
  at each fixed `e` it has `n_0 = 3`, `n_1` in `[2e + 11, 2e + 13]`, `n_4` in
  `[e − 1, e]` and no integer point for `e <= 60`, so it needs `e`-parametric
  integer reasoning (a split on an affine form such as `n_1 − 2e`, or
  `e`-parametric Fourier–Motzkin). `zy | yzyz`'s no-certificate regions hold
  real points; their liftable paths sit at depth 4–5, which the shared
  5,000-node point-path enumeration in `_poly_carve` never reaches (0 paths
  at 5,000 nodes, 401 at 2,000,000), so they need a larger or lazy
  enumeration (and `Q_OFFSET_BOUND` there). **Measured, not shipped:**
  splitting off the face `e = 0` first (`zy | yzy` 56 regions, 1 open, 28
  s, but `zy +y^(2+e) | yzyz` 2 → 117 regions and `zy | yz` 42 → 69);
  peeling `e = lo | e >= lo + 1` up to `lo = 8` (no extra closures, more
  regions); a value split from Fourier–Motzkin bounds (never fired: FM hits
  its caps); RLT without the LP (`zy | yzy` 216 regions, 4 open). Not
  proved: termination of the lift selection; it is measured. ·
  `kernel/psc/poly_line.mojo` (`lift_path_poly`, `lift_key`,
  `probe_points`); `kernel/psc/product_lift.mojo` (`rlt_forms`);
  `kernel/psc/farkas_lp.mojo`; `kernel/odd_letter_family_certificate.mojo`
  (`_poly_carve`, `_value_split`); `experiments/z2-route/sweep.sh`

- 2026-10-08 · **The q-lift closes `s = −1` `zy | yzy`** (`Delta <= −2`,
  `Z_2 >= 4`): `2 qlift -1 -2 4 5000 zy 0 yzy 0` ends with 121 regions (49
  certified, 44 polynomial, 2 cut, 59 not member), **0 open**, 91 s. The last
  region needed a value split whose probes carry their envelope
  (`_affine_value_split`): a probe `L >= h + 1` or `L <= h − 1` is refuted
  on the region plus the probe plus `_with_envelope` of that, by bound
  propagation or a checked Farkas certificate, for `L = n_k − c e`,
  `c` in `0..3`; the pieces `n_k := v + c e` (`q_k := v e + c q_e`, with
  `v + c e >= 0` kept) partition the real points. The previous round's
  diagnosis was off: on that region's polyhedron over `(n, q)` no form
  `n_k − c e` (`k` in `{0, 1, 4}`, `c` in `−1..3`) is bounded both ways,
  `n_1 − 2e` included, since `q` is free of `n e` there. What bounds it is
  the envelope of the probe (`n_0 >= 4` raises the McCormick floor of
  `q_0`): `n_0 >= 4` and `n_0 <= 2` are each refuted with their envelopes,
  so the split is the single value `n_0 = 3` (slope 0), and that piece is
  refuted outright. `zy | yz` (42 regions, 0 open, 12 s), `zy +y^(2+e) | zyzy` (17,
  0 open, 3 s) and the flag-off `zcap` runs (byte-identical) are unchanged.
  `zy | yzyz` still times out (`timeout 900`: region #1037, none open yet,
  3 value splits; the old cover reaches #1075 in the same time with none
  open either, so its open regions lie past where 900 s gets). The sloped
  forms (`c > 0`) are exercised by the seeded test only; no cover run has
  needed one yet. · `kernel/odd_letter_family_certificate.mojo`
  (`_affine_value_split`, `_affine_top`, `_refuted_with`, `_value_pieces`);
  `test_the_affine_value_split_partitions_the_real_points`,
  `test_the_affine_value_split_refutes_the_zy_yzy_region`,
  `test_the_q_lift_closes_zy_yzy`
- 2026-10-08 · **A deep lazy lift gives `zy | yzyz`'s no-certificate regions a
  certificate; the leaf still times out.** Under `q_lift` only (flag-off
  `zcap` output byte-identical): `_poly_carve` enumerates point paths with
  `Q_OFFSET_BOUND` (4) through a resumable `PointPaths` and lifts each as
  it comes (`_lazy_lift`): the first `solve_lift` that solves wins, else
  the best `lift_key`, stopping at the first whole-region lift
  (`whole_region_lift`: end offset lifts to zero, carving forms hold at
  every probe point). The ordinary pass keeps 5,000 nodes and 40 paths; a
  region past the peel limit with no certificate gets one deep pass,
  2,000,000 nodes and no path cap, before it is reported open. Running the
  deep pass on every failed lift is ruinous: one `zy | yz` region spent
  175 s (1,320 paths, 155 s in `lift_path_poly`, ~117 ms a path) without a
  whole-region lift. At the four no-certificate regions of the
  `zy | yzyz` run (#1150, #1165, #1198, #1338) the deep pass certifies in
  7–8 s each, two carving nothing. Measured (`timeout` as given, 3–4 runs
  side by side; the lazy-lift branch alone, before the value split was
  merged): `zy | yz` 42 regions, 0 open, 11 s (unchanged); `zy | yzy`
  120 regions, 1 open (no point), 91 s (unchanged); `zy | yzyz` timed out
  at 1,800 s at region #1493 with 15 regions certified by the deep pass,
  none failing, 0 open without a certificate, 18 open without a real
  point, 33 value splits (at 5c43b85, 1,300 s: #1352, 4 / 15 / 16); `s =
  −1` `zyz | yz` timed out at 900 s at #581, 2 deep certifications, 0 / 13
  / 15 (at 5c43b85: #1053, 4 / 38 / 20; the runs diverge at #90, the
  first deep certification). Two of the deep lifts (#1463, #1472) carve
  slices `n_1 >= 67`, `n_1 >= 60`. Not tried: restricting deep line
  positions to anchors (the deep pass already finds its lift in seconds).
  What blocks `zy | yzyz` now is regions with no real point found. ·
  `kernel/odd_letter_family_certificate.mojo` (`_lazy_lift`,
  `_certify_at(deep=)`); `kernel/psc/poly_line.mojo` (`PointPaths`,
  `whole_region_lift`); `test_the_deep_lazy_lift_certifies_a_zy_yzyz_region`
- 2026-10-08 · Round 3 of the q-lift, measured in the sweep: **3 more
  patterns close, none opens; 3 `s = +1` and 8 `s = −1` patterns still time
  out.** Round 3 added the envelope-carrying value split
  (`_affine_value_split`) and the deep lazy lift (`_lazy_lift`), merged
  together (entries above), and `sweep.sh` now gives the two stages
  separate timeouts (`sweep.sh BIN s delta floor r1 r2 budget plain_secs
  qlift_secs`, through `zruns ... at i plain|qlift`), so a pattern whose
  plain cover times out still gets the q-lift; before, every timeout killed
  inside the plain cover never reached it. Measured (budget 5,000, r1 = r2 =
  4, 300 s plain then 600 s q-lift, the two signs in parallel, the full test
  suite running beside them for the first ~hour): `s = +1` (`Delta >= 2`,
  `Z_2 >= 3`) 30 closed by plain, 3 by the q-lift, 0 open, 3 timeouts (was
  30 / 2 / 0 / 4); `s = −1` (`Delta <= −2`, `Z_2 >= 4`) 25 / 3 / 0 / 8 (was
  25 / 1 / 1 / 9). The verdict changes, all to closed by the q-lift:
  `zy +y^(2+e) | zyzy` (timeout → q-lift 17 regions, 3 s, after the plain
  cover's 300 s), `s = −1` `zy | yzy` (open → 121 regions, 93 s; the value
  split) and `s = −1` `zyzy | zyz` (timeout → 7 regions, 2 s, after the
  plain cover's 300 s). The first and third come from the separate
  timeouts alone; the other 69 patterns keep their verdicts, and the
  region counts of every pattern closed in both sweeps are unchanged.
  **Open:** the 11 timeouts, every one killed in the q-lift as well: `s =
  +1` `zyzy +y^(2+e) | yzyz`, `| zyz`, `| zyzy` (plain and q-lift both
  killed); `s = −1` `zy | yzyz`, `zyz | yzy`, `zyz | yzyz`, `zyzy | yz`,
  `zyzy | yzy`, `zyzy | yzyz`, `zyzy | zyzy` (both killed) and `zyz | yz`
  (plain 45 regions, 1 open, 13 s; q-lift killed at 600 s). `zy | yzyz`
  alone (`timeout 1800`) reaches region #1215 with 1 region open without a
  real point; `zyz | yz` (`timeout 900`) reaches #563 with none open; what
  blocks both is time, then regions with no real point found. **Measured,
  not shipped:** the lazy lift without the value split reaches further in
  the same time (`zy | yzyz` #1493 against #1215 in 1,800 s) but leaves 18
  regions open without a real point (8 by #1215) and `zyz | yz` 13 by #581;
  the deep pass on every failed lift (one `zy | yz` region 175 s). The
  sloped forms (`c > 0`) of the value split still fire in no cover run. ·
  `experiments/z2-route/sweep.sh`, `zruns.mojo` (`at i plain|qlift`);
  scratch `/tmp/claude-0/r5/sw/sweep-{plus,minus}.txt` (against
  `/tmp/claude-0/r2/final/sweep-{plus,minus}.txt`)

## 4. Withdrawn or unreproducible figures

- 2026-10-04 · "1,764 formal producer-free cycles; maximum death radius 7;
  collar tested to 40" (`completion-ledger-2026-09-11.md` §V): no instrument
  exists in the repository or the archive. Superseded by the exact
  formal-overlap carrier census. · `formal-overlap-carriers-2026-10-04.md` §1

## 5. Finite observations worth not recomputing

- 2026-10-04 · Formal carriers: 13,260 on the corpus (6,078 realized, 7,182
  unrealized), none closed, no nonproductive potential overlap; identical
  under three different seeding regions. Realization separates the escape
  mechanism (aligned and fast vs strict and slow), not productivity. ·
  `formal-overlap-carriers-2026-10-04.md`; receipts in
  `evidence/formal-overlap-carriers-2026-10-04/`
- 2026-10-04 · The §5.6b trichotomy holds on all 24,486 specimens of total
  length ≤ 8: no exception; every total Q1 failure is catch-up-free; P′ exact.
  · `p1b-vertex-coincidence-box-2026-10-02.md` §5.6c
- 2026-10-04 · The catch-up-free class is not confined to `|det M| = 2`: 84 of
  654 at total length ≤ 8 have another determinant (all 210 corpus members
  have `|det M| = 2`). · same, §5.6e
- 2026-10-04 · Lemma E (§5.6e) and Proposition C (§5.6b, from `main`) are the
  same statement; Proposition P″ (§5.6b) shows the M-adic centres of a
  periodic pair coincide, so the M-adic coordinate alone excludes nothing.
  Do not re-derive either. · `p1b-vertex-coincidence-box-2026-10-02.md`
- 2026-10-04 · `L` (per-carrier least offset-zero depth, max 12) and `K_V`
  (per-vertex greatest first left-aligned depth, max 17) are different
  statistics; do not compare them as equals. ·
  `formal-productivity-reduction-2026-10-04.md` §6

- 2026-10-04 · SC_all holds on 408,798 specimens of total length ≤ 10 and on
  the 135,990 with images ≤ 4 (exact, 11 and 3 minutes); deepest residual pair
  level 15 on `0 -> 1, 1 -> 2, 2 -> 10` on every domain. With the recorded
  PPVC runs this gives PDS on 145,806 specimens; the catch-up-free specimens
  without a Barge witness are settled one by one, only a uniform argument is
  open. Lemma A: on the catch-up-free `|det M| = 2` class an unmerged aligned
  pair has no interior offset-zero child. · `strong-coincidence-census-2026-10-04.md`

- 2026-10-04 · The two cube-image certificates behind Propositions 5.46/5.47
  were executed in Mojo, not just cited: all 15 seed-patch-overlap tests pass
  and the receipts reproduce 1,142 vertices, first-coincidence depth `D = 19`
  and first left-aligned depth `K' = 17`. The stated state bounds
  `2 beta^19 ell_max = 45,136,797,534` and `2 beta^17 ell_max = 4,198,004,819`
  recompute exactly in 60-digit decimal, and both integer floors are right.
  Do not re-verify. · `kernel/tests/test_overlap_seed_patch.mojo`;
  `audit-2026-10-04.md` §B.3

- 2026-10-06 · All four retained real-secondary packet SCCs and both controls
  have acyclic nonzero-physical-cut induced graphs; coherent defined hub phase
  also survives on the non-Pisot strict support. Neither finite property
  distinguishes PIP or gives balanced alignment. ·
  `c4-ordered-hub-offset-negative-2026-10-06.md` §§2,5

- 2026-10-07 · Only 70 of the 383 PIP members of Theorem E's classes with
  `p, q, r <= 11` have the characteristic polynomial of a three-letter
  simple-Parry β-substitution, a necessary condition for conjugacy to one;
  the other 313 cannot inherit Barge (2018) that way, and the 70 are not
  shown conjugate. · `p1b-catch-up-free-ppvc-2026-10-07.md` §3; scratch check

- 2026-10-08 · Theorem Ω's box automaton is **not** a faster exact decider
  than `coincidence_level` on Theorem K's members: on the `s = −1` leaf
  `zy | yz`, 3.9 s against 0.05 s at (3, 3, 0), 105.6 s against 51.9 s at
  (9, 7, 0), and no verdict within 180 s at (7, 9, 1), which
  `coincidence_level` decides in 58 s; 27,000–65,000 box states already at
  `a, b <= 9`. Use it as a cross-check for its stronger FP verdict, not to
  speed up member decisions. · `audit-finite-regime-advice-2026-10-08.md`;
  `experiments/z2-route/boxtime.mojo`

## 6. Tooling pitfalls

- 2026-10-04 · `pkill -f PATTERN` inside a shell command whose own text
  contains PATTERN kills that command. Kill by PID from a separate command.
  (Hit again the same day: `pkill -f 'scratchpad/scc'` killed its own shell.)
- 2026-10-04 · `/usr/bin/time` is not installed in the cloud container; time
  runs with `date +%s` differences.
- 2026-10-04 · `cmd | tail -1 && next` tests `tail`'s status, not `cmd`'s:
  a failing governance audit then lets the commit through. Capture `$?`.
- 2026-10-04 · Editing a `require_contract` text makes the recorded receipts
  stale until `kernel/run_tests.sh` reruns; the coverage audit then fails
  locally (CI regenerates the receipts).
- 2026-10-04 · Prefer Mojo with `parallel_fold` to throwaway Python for any
  exact check; a Python-only computation is a defect under `AGENTS.md`.
- 2026-10-04 · Seeding the formal census from Proposition V's box takes 7
  minutes; the earlier `K_T` seeding took 107. Reuse the box graph.
- 2026-10-04 · Background jobs are capped at two hours; long oracle sweeps
  must be chunked or restricted to labelled samples.
- 2026-10-04 · The exact Python formal-overlap oracle is slow on specimens with
  two real contracting conjugates unless each `q(c)` is bounded tightly
  (binary search on exact signs): `1 5 20` takes 42 s, about 7 minutes before.
- 2026-10-04 · Estate layout on `main`: `mojo/` → `kernel/`, `scripts/` →
  `tools/` (Python censuses → `oracles/python/`), `src/psc_research` →
  `reference/psc_research`, `docs/evidence/` → `evidence/`, `tla/` →
  `proof/tla/`. A pixi env cannot be moved (absolute prefixes; `std` not
  found): keep `mojo/.pixi` and symlink `kernel/.pixi` to it, excluded in
  `.git/info/exclude`.
- 2026-10-04 · `p1b-vertex-coincidence-box-2026-10-02.md` §§5.6h–5.6i were
  §§5.6c–5.6d on `main`; the checksummed archive index still cites the old
  numbers. Do not edit the archive README (its `SHA256SUMS` covers it).

- 2026-10-04 · `tools/make_ledger.py` binds eleven generated claim surfaces to
  `WEEKLY = docs/completion-ledger-2026-09-14.md`, a frozen dated snapshot, so
  claims are validated against a superseded weekly ledger. Repointing `WEEKLY`
  to `completion-ledger-2026-10-02.md` is **not** a drop-in: the consistency
  check then fails on five anchors the newer snapshot does not carry
  (`ConcentrationAuxB`, `G1b2RenewalFiniteness` twice, `SpanRichProductivity`,
  and `OverlapProductivity` for want of a status label within 0 lines). Either
  give the new snapshot those anchors with status labels, or drop the WEEKLY
  bindings and rely on the live surfaces, which is arguably correct since a
  snapshot is not a proof source. Left at 09-14 deliberately rather than
  changing what eleven claims are checked against. · `tools/make_ledger.py`
  (`WEEKLY`); `audit-2026-10-04.md` §D.5
- 2026-10-05 · Vendored `madic_ball.mojo` (finite-math-kernels da41c27) now
  states that the generators of `M^k Z^n` are the *columns* of the row-major
  `M`; the row span is a different lattice. `psc/overlap_madic_filter.mojo`
  does not call `contains_exact` but solves `M^m x = d` with its own
  adjugate inverse of `qmat_pow(lift_square(incidence))`, where
  `incidence()[3*i + j]` counts letter `i` in `sigma(j)`; that is the column
  span, the one `d = M^m w` for Parikh vectors needs. Checked by reading the
  adjugate entry by entry; nothing changed. ·
  `kernel/finite_linear_algebra/madic_ball.mojo`;
  `kernel/psc/overlap_madic_filter.mojo` (`_inverse_lattice3`)
- 2026-10-05 · The vendoring checker moved to the vendored
  `tools/vendoring/check_vendored_sync.py`; the old `tools/check_vendored_sync.py`
  is gone. `CONTRIBUTING.md` (gate 7), `.github/` and `.forgejo/`
  `PULL_REQUEST_TEMPLATE.md` and `.claude/skills/steward/SKILL.md` still name the
  old path: they are rendered from `larsbx/agent-icm` and must be corrected
  there and re-rendered, not hand-edited here. Until then run the new path. ·
  `vendored.toml`; `tests/test_vendored_sync.py`
- 2026-10-05 · `mojo build kernel/pisot_polynomial_bench.mojo` needs `-I tests`
  as well as `-I .`: it imports `tests/polynomial_reference.mojo`. Without it
  the build fails to locate the module, before and after the re-vendor. ·
  `kernel/pisot_polynomial_bench.mojo` line 7
- 2026-10-06 · Python-oracle `_poly_gcd` can reuse exact immutable `Fraction`
  coefficients while retaining conversion for every other type, including
  subclasses: 4,800 gcd pairs and all 3,375 cubic screen results agree with
  `main@c2bd9a0`; median normalization time drops 0.477466 -> 0.031462 s,
  with a 6.4% full-screen gain on the shared-container run. Keep the exact-type
  guard and distinguish normalization-only from caller speedup. ·
  [poly-gcd-fraction-normalization-2026-10-06.md](poly-gcd-fraction-normalization-2026-10-06.md#benchmark-evidence)
  (source digests and replay in §Reproduce); `tests/test_pisot_screen.py`

- 2026-10-06 · `PacketGraph.expansions` has two entries per BPA state,
  indexed by `2*state_id + Int(sign == -1)`; indexing by state ID selects
  another state's factor row. The new ordered-hub golden regressions caught
  this during implementation before export. ·
  `kernel/psc/target_packets.mojo::_prepare`;
  `kernel/tests/test_packet_hub_analysis.mojo`

- 2026-10-06 · Claim coverage reads live passing receipts. Running governance
  or the full Python suite before `kernel/run_tests.sh` finishes can report
  uncovered claims from its incomplete receipt file. Complete the Mojo run
  first, then audit; the completed 60-file run and subsequent full checks pass.
  · `c4-ordered-hub-offset-negative-2026-10-06.md` §7

- 2026-10-06 · Cleanup decision: subtract unused Julia scaffolds, obsolete
  boundary-sync integration/task notes, the superseded architecture pointer,
  duplicate Python optimization advice and repeated workflow paths; the live
  automation protocol now follows the claim taxonomy and both proof routes. Ten
  remaining frozen-weekly status bindings now check the live proof ladder and
  roadmap, resolving the September 14 snapshot debt above; all 71 proof
  records and claim statuses stay unchanged. September 11/14 completion
  ledgers are preserved byte-for-byte at their new archive locators. ·
  `tools/make_ledger.py`;
  `archive/2026-10-06/status-snapshots/README.md`

- 2026-10-07 · `search_point` enumerates every value of a bounded domain, so
  on forms with large coefficients (the q-lift's tail-fixed forms) one node
  pushes thousands of boxes: 14 GB and an OOM kill. Pass `span_cap`.

- 2026-10-07 · `finite_linear_algebra.mat3.has_rational_root` evaluates `r^3`
  in unchecked `Int` for every divisor `r` of `det M`; safe at the audited
  column-sum bound 6 and at entries up to 64, not beyond. Any path that admits
  larger matrices must use `psc.pisot_screen.has_rational_root` (exact over
  `Q`, divisor pairs up to `sqrt |det|`), as `screened_perron_field3` now does.
  · `kernel/psc/perron_field3.mojo`

- 2026-10-07 · Run-position ranges in a symbolic overlap closure: the upper
  end is the largest `m` with `ell_A − t − m ell_y > 0`, which is (least `m`
  with `t + m ell_y − ell_A >= 0`) − 1, **non-strict**. Computing it with a
  strict inequality admits one invalid child exactly when `t + m ell_y = ell_A`
  identically, and on the class B line it produced 123 vertices (4 without a
  hit) instead of the exact 119. · `kernel/psc/symbolic_line.mojo` (`least_m`)

## 7. Review outcomes

- 2026-10-04 · Independent status audit (`audit-2026-10-04.md`) re-derived
  Propositions 5.46, 5.47 with Corollary 5, and Theorem B: all hold. Theorem
  B's realization does **not** breach the formal-recurrence firewall — it
  builds `Phi^r`-fixed tilings from *interior* occurrences, whose patches are
  allowed for `sigma`, and takes offset integrality from the cycle equation.
  The ledger's new set-of-sets `Requires` with existential discharge is sound
  and no route establishes anything from nothing. Two findings of that audit
  were self-corrected: the 2026-10-04 review *is* recorded (§7 here, not a
  standalone file), and `PDSImpliesRepoG1` *does* name its repository inputs
  in the record source, though they are not ledger nodes so the closure cannot
  track them. · `audit-2026-10-04.md` §§B, D.2, D.4
- 2026-10-04 · The four 2026-10-04 claims (`PDSImpliesRepoG1`,
  `PDSImpliesSeedwiseTermination`, `CoincidenceRankFibreTheorems`,
  `StrongCoincidenceFromPDS`) were on no prose status surface, so governance
  could not see drift on them; they now have rows in the claim/source map and,
  for the two repository claims, sections in the conjecture ledger and proof
  ladder. `PDS => G1` and the seedwise bridge were likewise absent from every
  headline surface and are now stated on README, the conjecture ledger, the
  proof ladder and the architecture note. · `tools/make_ledger.py` surfaces;
  `audit-2026-10-04.md` §D.3

  - *Correction 2026-10-05.* That list omitted
    `docs/research-roadmap-2026-09-21.md`, which the same audit counts as a
    headline status surface (§D.5) and which stayed synchronized only through
    2026-10-02. It now carries a 2026-10-05 synchronization block for both
    results, plus the planning consequence that by Corollary 5 the
    strict-zipper branch (#139) alone suffices for G1, so G1b-2 (P2) is the
    least load-bearing of the three routes. The dated
    `completion-ledger-2026-10-02.md` snapshot stays frozen by design. ·
    `audit-2026-10-04.md` §D.5 correction

- 2026-10-05 · **Theorem E proved**: on the catch-up-free `|det M| = 2` class,
  any two distinct letters fixed by the first-letter map are eventually
  coincident, so case (i) of #138's aligned template is eliminated on the whole
  class. Three things worth not rediscovering. (1) `p, q, r` sit only in the
  bottom row of `M`, so `det M`, `f(1)` and `f(-1)` are all **affine** in them,
  and `|det M| = 2` is a linear Diophantine condition that fixes one
  parameter. (2) The Pisot necessary conditions `f(1) < 0`, `f(-1) < 0`
  (Lemma P1) predict every line's PIP range *exactly* — e.g. B's line
  `(n, 0, 1)` has `f(-1) = n - 12`, which is why it stops at `n = 11` — so no
  witness lemma is needed on the lines, only on the 2-dimensional bulk. (3) The
  bulk falls to three explicit witness lemmas, each a one-step cancellation of
  a small Parikh discrepancy by offsets that differ by one inside the next
  blocks. The remainder is 27 explicit substitutions, all decided coincident
  at levels 3-7. · `p1a-a1-prime-2026-10-05.md` §3b;
  `kernel/tests/test_a1_normal_form.mojo`

- 2026-10-06 · Prefix transfer: `sigma^(n+1)(i)` begins with
  `sigma^n(h(i))`, so coincidence propagates *backwards* along the pair map
  `H({i,j}) = {h(i),h(j)}`, and all-pairs strong coincidence holds iff every
  `H`-cycle of distinct pairs contains a coincident pair. Do not re-derive the
  per-pair cases by search: on the catch-up-free `|det M| = 2`, `|O| = 2`
  class the `H`-cycles are a seven-row table, and only the swap family
  (`h` swaps the odd letters) is not closed by Theorem E, Lemma T,
  Barge–Diamond, or the two-lemma Proposition Y. Its sweep needs level-4
  witnesses on infinite lines (`(n+1,0,n)` in ending `(x,x,x,c)`), so Theorem
  E's level-2/3 lemma style will not suffice there. Reversal preserves `M` but
  not coincidence levels (swap ending `(x,c,x,x)` is class D reversed, with
  different levels). · `p1a-a1-prime-2026-10-05.md` §3c;
  `kernel/tests/test_a1_normal_form.mojo`

- 2026-10-06 · **Theorem H / Corollary H1 proved**: strong coincidence for
  every pair on the catch-up-free `|det M| = 2` two-odd-letter class. Worth
  not rediscovering: (1) *constant-offset* witness paths suffice — every
  `gamma_l` along the path is a parameter-free vector, so `M gamma` is affine
  and validity on a whole cone is affine identities plus coefficient-sign
  inequalities (`psc.cone_witness`); (2) with that, every bulk quadrant of the
  swap family is **one** cone, and the level-4 infinite lines are cones too —
  hand-found lemmas were the bottleneck, not the mathematics; (3) the search
  re-finds Theorem E's L_D with the lemma's own position `p + 3`, so the
  machinery should be tried first on any new linear-exponent family. It does
  not reach the `|O| = 1` sub-class as it stands: there the images `o w o`
  carry arbitrary two-letter words `w`, not one run. ·
  `p1a-a1-prime-2026-10-05.md` §3d;
  `kernel/tests/test_swap_family_certificate.mojo`;
  `p1a-swap-family-literature-gate-2026-10-06.md`

- 2026-10-06 · One odd letter needs no new machinery except in one row: the
  images are a non-`o` letter or `o w o`, so `h` is `o` on every long image and
  prefix transfer closes every pair unless `sigma(o)` is a single letter (or
  two images are short, which forces a letter 3-cycle and Barge–Diamond). None
  of the 18 one-odd-letter corpus specimens is in that row, so the open family
  of Theorem K has **no corpus member**; a census of it must be built from
  scratch, over patterns of runs in `w_1, w_2`. · `p1a-a1-prime-2026-10-05.md`
  §3e; `kernel/tests/test_swap_family_certificate.mojo`

- 2026-10-06 · Theorem K's family (`sigma(o) = y`, `o w_1 o`, `o w_2 o`):
  `det M = 2(Z_1 − Z_2)`, and every witness found starts
  `(o, y) -> (y, w_1[0], −e_o)`. When `w_1` begins with `z` the crossing of the
  Parikh walks of `w_1` and `w_2 + e_y` gives level 3 through the two final
  `o`s (Lemma Φ2), so only non-crossing pairs remain. **Do not retry the
  letter-by-letter pattern tree** on them: with opaque tails and relational
  splits its open leaves still grow (34, 237, 969, 4,083 at depths 6, 9, 11,
  13); the non-crossing witnesses depend on `delta = pi(w_1) − pi(w_2)`, so
  the next decomposition should split on `delta` and on the walk. ·
  `p1a-a1-prime-2026-10-05.md` §3f;
  `kernel/tests/test_odd_letter_family_certificate.mojo`

- 2026-10-06 · Delta split of Theorem K's family: `f(−1) = (1 + Z_2)(Y_2 − Y_1 − 1)`
  when `Z_1 = Z_2 + 1` and `f(1) = (Z_2 − 1)(Y_1 − Y_2 − 1)` when
  `Z_1 = Z_2 − 1` (exact), so the sign of `Y_1 − Y_2` is fixed by `s`. Most
  witnesses sit at **common points** of the walks of `w_1` and `w_2 + e_z`
  (`t = 1` always is one): a matched step needs a factor of Parikh `±delta`, an
  unmatched one a meeting of `w_2` with `w_1 + delta`. That closes
  `delta = e_z` (Theorem Φ) but leaves a growing residue elsewhere (87 at
  length 7, 265 at 8). The parametric cone search on residue run families
  works only with `Delta` fixed. Next: split on `Delta` together with
  relational run-length splits. · `p1a-a1-prime-2026-10-05.md` §3g;
  `kernel/tests/test_odd_letter_family_certificate.mojo`

- 2026-10-06 · Run-shape cover of Theorem K's residue: whole shape families
  close (Theorem Ψ; 29 cells at length 8) once three things are in place —
  exact `Delta` cells (with `Delta` free, `delta` is not constant), the
  quadratic Pisot forms `f(1) = Z_2(Delta − 1) − 2Y_2 − Delta − 3` /
  `f(−1) = Z_2(|Delta| − 1) − 2Y_1 − |Delta| + 3` as cuts (they kill the
  `Delta`-tails), and a **line mode** allowing offsets affine along
  `e_z − e_y` (some witnesses pass through `(b + 1)(e_z − e_y)`). Value
  splits alone just push an open region outward (`a >= 11`): when a cell
  will not close, look for a non-constant offset, not a deeper split.
  Many-run shapes still exceed a 600-region budget. Tooling: never
  `pkill -f` / `pgrep -f` a pattern that also appears in the running shell's
  own command line — it kills that shell (happened twice). ·
  `p1a-a1-prime-2026-10-05.md` §3h; `kernel/tests/test_odd_letter_family_certificate.mojo`

- 2026-10-06 · Induction on runs for Theorem K's residue: run patterns with
  an opaque tail close as whole infinite families (unboundedly many runs);
  over six `delta` cells 60 of 84 run-tree leaves close, and the cell
  `(s, Delta) = (+1, 1)` is settled up to `zyz* | zyz*`, `zyz* | yzy*`
  (Theorem Ξ). **Refining a doubly open pattern does not converge**: one
  revealed run moves the openness to the other word (open regions 104, 74,
  96, 44, 107 down the chain in cell `(+1, 1)`), so do not spend more budget
  or depth there. The residue is mostly **single excursions**: only common
  point `t = 1` (51 of 87 at length 7, 170 of 265 at 8). Next: a witness
  argument inside an excursion. Tooling: a scratch driver `kernel/_*.mojo`
  was once committed by mistake; check `git status` for it. ·
  `p1a-a1-prime-2026-10-05.md` §3i; `kernel/tests/test_odd_letter_family_certificate.mojo`

- 2026-10-06 · Excursion route for Theorem K's residue. **A lockstep
  one-counter reading is the wrong model**: the level-2 state is
  `(w_1[t], w_2[t−1], (1−h)(e_z−e_y))`, but closures compare the walks at a
  lag `c (Delta + s)` (`M(e_z − e_y) = −delta`). What works is **Lemma X**
  (monotone paths crossing at their endpoints meet; weak end allowed when a
  letter follows), which reads endpoints only and so crosses opaque tails,
  plus **Lemma Φ5′** (`s = −1`: `w_2` ends in an explicit suffix of length
  `2 − Delta` with two `z`). Ablations (exploratory): without the Φ5/Φ5′
  suffix the revealed runs a certificate needs grow with length (to 7 at
  30–40); without lagged cuts `s = −1` climbs to 5–6; extremum cuts of `h`
  are a marginal aid. With them (kernel `reveal_census`) the need is at most
  2 runs through length 10 exhaustively and at most 4 in seeded samples at
  lengths 40–60. **Blind splitting does
  not uniformize** the per-point certificates: open regions 44 → 533 → 994 as
  the budget grows 300 → 3,000 → 20,000, while every one of 11,664 tested
  points has an opaque-tail certificate. Next: a certificate-guided
  partition (lift a point certificate, carve its validity polyhedron). Do not
  spend more budget on relational/value splits. Tooling: `grep` without
  `--line-buffered` hides a long driver's progress until it exits. ·
  `p1a-a1-prime-2026-10-05.md` §3j; `p1a-excursion-route-literature-gate-2026-10-06.md`;
  `kernel/tests/test_odd_letter_family_certificate.mojo`

- 2026-10-06 · Certificate-guided partition (exact integer decomposition
  `impose_nonneg` + lifted base-point certificates) closes what blind
  splitting could not: Theorem Λ, the whole cell `(+1, 1)`. **Base points
  must be generic**: from the origin, certificates carve slices
  (`n_0 = 0`) and the cover peels one value at a time; with every variable 2,
  they exploit accidental equalities (`2 n_0 = n_3 + n_6`), and one carve split
  into 8,307 + 35,040 regions. Distinct primes `2, 3, 5, …` fixed both
  (`zyz* +y | yzy*`: 18,396 regions → 2,833). Drop duplicate carving forms.
  Tooling: never `pkill -f` a scratch binary; kill by the PID that `ps`
  lists. · `p1a-a1-prime-2026-10-05.md` §3k;
  `kernel/tests/test_odd_letter_family_certificate.mojo`

- 2026-10-06 · Regions that carry their own inequalities (`GuidedRegion`,
  `Prover` in `psc/cone_witness.mojo`) replace decomposition in the guided
  cover. Pitfalls met on the way, each now a regression: the verifiers' end
  tests asked the offset to be *identically* zero, which a carved region
  never makes it (they now ask the prover for `= 0` on the region); a form
  tightened by its gcd (`tighten`, Chvátal–Gomory, same integer points) is
  only re-provable with a multiplier (`f − 2 T >= 0`), so the prover reads
  multipliers off coefficient ratios; the base-point walk into a region
  overflowed `Int` and lifted a certificate at a garbage point (now capped,
  and a carve whose inside misses its own base point raises). Complements of
  carves are mostly *empty*, and often only through three assumptions at
  once; pairwise sums missed them and the raise-only walk found no point, so
  they were reported open (412 of them in `zyz* +y | yzy*`). Sums of up to
  three assumptions, integer bound propagation (`propagate_bounds`) and a
  local search on total violation took that pattern to 0 open (3,536
  regions). **Finite observation, not to repeat:** in the symbolic tail cell
  `s = +1`, `Delta = 1 + e`, point-wise McCormick quadrants do not converge:
  with `a_0 = 2, b_0 = b(p)` the base points climb `e ≈ 23, 701, 22397,
  716669` (×32 per step), and once points are walked into regions the cuts
  step `e` by one (slopes 23, 24, 25, …). For fixed `Z_2` the non-PIP set
  `(Z_2 − 1) e >= 2 Y_2 + 4` is a half-space, but over all `Z_2` it is not
  polyhedral, so finitely many cuts always leave wedges holding non-PIP
  points with `Z_2, e` both unbounded: a finite tail cover needs
  certificates valid on those non-PIP points too, not finer cuts.
  Certificate-before-cut (`cut_first = False`) does not converge at 5,000
  regions either (PIP-side base points reach `n ≈ 400`, beyond the offset
  bound). · `p1a-a1-prime-2026-10-05.md` §3k;
  `kernel/tests/test_odd_letter_family_certificate.mojo`

- 2026-10-06 · Theorem K's tail cells, what the obstruction is and is not.
  **Not the mathematics:** in a seeded sample (seed 1, 400 draws,
  `|w_2| <= 10`, `Delta <= 12`; `xlev`, scratch) of `s = +1` non-crossing
  members, every coincidence level is `<= 5`, and `<= 4` for `Delta >= 4`;
  members per `Delta` settle at about 63. Past a threshold depending on
  `(u, w_2)`, the shared tile's path is the same for every `Delta`, its
  `o`-side digit counted from the *end* of `y^Delta` (e.g. `zyzy y^Delta |
  zyy` at level 3 for all `Delta >= 2`), so the certificate is affine in
  `Delta`. **Not hidden Pisot constraints:** for `s = +1`, `f(1) < 0` is the
  whole Pisot condition (exact `pisot`, 5,680 of 5,680 points of
  `Y_2, Z_2 < 30`, `Delta < 30`), and 3,100 of them have `Z_2, Delta >= 2`.
  **It is the cover:** line mode works in fixed-`Delta` cells because
  `M (e_z − e_y) = (0, −Delta, −s)` is constant there; with `Delta = 1 + e`
  symbolic a variable line coefficient makes `M gamma` quadratic, which line
  mode refuses, and point-wise lifting from small-`e` base points carves
  `e`-bounded slices. Uniform McCormick corners `(k, 0)` cut `{Z_2 >= k,
  (k − 1) e >= 2 Y_2 + 4}` with no staircase but leave wedges. Also: the
  non-tail cells never fell back to a non-member base point (now they do),
  and carve complements were mostly empty (dropping implied forms and empty
  complements took `zyz* | yzy* +zzz` from 15,612 regions to 3,441). ·
  `p1a-a1-prime-2026-10-05.md` §3l.5; `kernel/odd_letter_family_certificate.mojo`
  (`search_point`, `mccormick_forms`, `_new_forms`)

- 2026-10-06 · Polynomial line mode (`psc/poly_line.mojo`) for the tail
  cells. Pitfall: lifting a point path by the *search's* candidate menu (run
  offsets anchored 0–2 from either end) found no candidate in all 15
  quadratic cases (s = +1 tail, 3,000 regions): states agreed, offsets did
  not. Building candidates from the point's own step (its offsets anchored at
  either end, or solved to hold a coordinate) gives polynomial certificates,
  some on a whole region uncarved. Open: most lifts end with an offset whose
  degree-2 part does not vanish, i.e. the certificate holds on a slice, which
  a finite cover cannot use. Also: the fixed cell `(+1, 2)` does not close
  (15 of 20 leaves, 8 revealed runs), so fixed `Delta` is not a way around
  the tail either. · `kernel/tests/test_poly_line.mojo`

- 2026-10-06 · Lifting is linear algebra once the segments are fixed: the
  letters are then determined and the end offset is linear in the run
  offsets, so "affine offsets with `gamma_L = 0` identically, agreeing with
  the point" is one exact system over Q (`solve_lift`). It answers
  definitively where candidate menus only fail to find: in `zyz +yy | zyz`
  (cell `(+1, 2)`, every run revealed) the base point's first path has
  **no** such offsets, while other paths at the same point do
  (`enumerate_point_paths`); open regions 2 → 1, one certificate covering a
  whole region uncarved. The remaining one is a boundary slice (`n4 = 0`)
  whose 40 enumerated point paths all fail; Lemma X closures are not yet
  solved linearly. · `kernel/psc/poly_line.mojo`; `kernel/tests/test_poly_line.mojo`

- 2026-10-06 · Two cover leaks, each closing `zyz +yy | zyz` (cell
  `(+1, 2)`, every run revealed: 2 open → 0, 81 regions → 51, 62 s → 4 s).
  (1) With `Delta` fixed, Lemma P1's form is *affine*, and the cover never
  split by it: it certified member base points and cut only at non-member
  points, so a region whose members are finite (here 3 points,
  `f = n3 + n5 − 1`) ran out of peels. Now `{f >= 0}` is cut once and the
  rest carries `f <= −1`. (2) A region whose assumptions pin every
  occurring variable is one substitution, but counted as live and never
  reached exact decision; propagated bounds with `lo = hi` are now
  substituted. Also: Lemma X closures solve linearly too
  (`solve_crossing_lift`). Tooling: an unset shell variable sent a build to
  `/olf20` and four logs to `~` (left for the user to delete; the safety
  check blocks the removal). · `kernel/odd_letter_family_certificate.mojo`
  (`_affine_pisot_form`, `_pin_fixed`); `kernel/psc/poly_line.mojo`

- 2026-10-06 · s = −1 tail cell, `zy* | zy* +[z*]` at 1,500–3,000 regions,
  never closing. The McCormick cut at corner `(2, b(p))` walks `b` down one
  unit per cut (69, 68, 67, …): 636 of 1,500 regions were cuts. Uniform
  corners `(k, 0)` did not help (1,001 cuts, 359 open), certificate-before-
  cut was worse (996 open). Descending from a feasible point to a member
  (coordinate descent on Lemma P1's `f`) cut the cuts to 63 but left 464
  regions with no certificate. Their base points have one y-run in the
  thousands (n2 = 2,134), forced by large constants that earlier cuts left
  in the region's inequalities, beyond the search's offset bound; smaller
  candidate points change nothing there. Not reached by point heuristics:
  the tail needs certificates (or cuts) that do not inherit those
  constants. · scratch `xt m`; `kernel/odd_letter_family_certificate.mojo`
  (`pisot_carve_forms`, `_descend_to_member`, `_base_candidates`)

- 2026-10-06 · Witness shapes of `s = +1` non-crossing members at large
  `Delta` (scratch census, digits read structurally: in `u` from its start,
  in `y^Delta` from its end, in `w_2` from its start). **Sampling pitfall:**
  rejection sampling repeats members; a "dominant" level-4 shape inside
  `y^Delta` (72% of 300 draws at every `Delta` in 6..20) is one family:
  its Parikh condition is `(M^4 − Delta M^3 − 3 M^2 + (Delta − 4) M − 2) e_y = 0`,
  i.e. `chi` divides that quartic, i.e. `w_2 = z`, `u = zz`. Counting
  *distinct* members (all with `|w_2| <= 6`, `Delta = 8`): 37 members, 15
  shapes, no shape a majority. The leading ones are uniform in `Delta` and
  affine in run lengths, e.g. `u = zzy^k z`, `w_2 = zy^k z` at level 3 with
  the `o`-side position `k − 1` from the end of `y^Delta`, which is the
  form `solve_lift` finds; so the tail's obstacle is the cover, not missing
  certificates. For `s = −1`, `Delta = −6`, `|w_1| <= 5`: Lemma P1 forces
  `Y_1 >= 4`, so all 28 members have `w_1 = zyyyy` and `w_2` = two `z` in
  `y^10`; 11 shapes, all level 4, reading `w_2`'s `z` by position from its
  end (the x-block), again affine. · scratch `shapes2.py`, `shapes3.py`

- 2026-10-06 · Tooling, measured: the guided cover's tail regions cost
  ~2 s each (300 regions: 9m51s), and neither the candidate search's
  degree, nor its node budget, nor string-keyed polynomials were the cause
  (each change: same 9m40s–10m13s, identical results). A stack sample with
  `gdb -p PID -batch -ex bt` showed it at once: exact RREF over `BigZ`
  rationals (a gcd per product) in the linear lift, on systems that are
  mostly inconsistent. Screening mod two primes below 2^31 first: 42 s,
  identical results. Sample before optimizing. · `kernel/psc/poly_line.mojo`
  (`_consistent_mod`)

- 2026-10-05 · Tooling: a test pinned an unscreened parameter tuple and the
  exact `coincidence_level` refused it ("the powered characteristic polynomial
  is reducible"). Screen before deciding; the refusal is the procedure failing
  closed correctly, not a bug. · `kernel/tests/test_a1_normal_form.mojo`

- 2026-10-05 · On the catch-up-free `|det M| = 2` class the surviving aligned
  template is an explicit normal form: the odd set of Proposition C is exactly
  the bad edge, `O = {x, c}`, so `sigma(x) = x y^p s_x`, `sigma(c) = c y^q s_c`,
  `sigma(y) = t y^r s_y` with the four endings in `{x, c}`. The lemma behind it
  is worth keeping: `|O| <= 2`, because all three letters odd forces every
  image to have length exactly two, hence every column sum 2, hence Perron root
  the rational number 2, contradicting irreducibility (checked independently:
  no nonnegative 3x3 matrix with all column sums 2 is PIP). Two consequences:
  the 18 catch-up-free corpus specimens with `|O| = 1` cannot carry case (i) of
  the template at all, and the alternating template forces `sigma(a) = b` or
  `sigma(b) = a` as a single even letter, landing in the §5.6g one-E-letter
  sub-class. · `p1a-a1-prime-2026-10-05.md` §3a

- 2026-10-05 · Exploratory sweep of that normal form at three budgets,
  `p, q, r <= 5`, `<= 8`, `<= 11`: 174, 420 and 766 PIP members with
  `|det M| = 2`, A1′ witnessed on **every** one, coincidence level at most 7
  throughout. The finding worth not recomputing: **the tail does not move.**
  The level-4 to level-7 counts are identical at all three budgets (8, 2, 2, 2)
  while only levels 2 and 3 grow, so the hard cases do not scale with the
  parameters. The 14 members of level >= 4 are the same 14 every time, form 7
  mirror pairs under `x <-> c`, and all have `p, q, r <= 3`; the deepest has
  `sigma(x) = xyc`, `sigma(c) = cx`, `sigma(y) = cyc` with its first shared
  tile at position 311. The method is cheap because equal Parikh prefixes have
  equal length, so the search is one pass with two integer counters. Not a
  verdict: a member outside the range is uncovered, and the cap column is
  reported separately (zero on all three). Now ported:
  `kernel/a1_normal_form_census.mojo` decides each member with the canonical
  exact `coincidence_level`, so a negative is a verdict and the driver raises
  on one, and it reproduces the probe cell for cell at bounds 5 and 8. The
  regression pins **two** bounds on purpose, so that the tail claim itself is
  guarded. The probe is kept as provenance with its output and digests. ·
  `p1a-a1-prime-2026-10-05.md` §3a; `kernel/tests/test_a1_normal_form.mojo`;
  `archive/2026-10-05/session-probes/`

- 2026-10-05 · A1′, the obligation Theorem C leaves, is the **residual** half
  of all-pairs strong coincidence: under its hypothesis `h^n(x) = x != c =
  h^n(c)` for every `n`, so the pair is never merged and its witness is
  strictly interior. So A1′ inherits the strong-coincidence census: **0
  failures on all 408,798 PIP specimens**, residual level at most 15. Worth not
  attempting: there is no sharper finite test, because A1′'s hypothesis
  presupposes a bad edge and no verified specimen has one — a specimen
  satisfying it non-vacuously would refute SC_all and PSC. ·
  `p1a-a1-prime-2026-10-05.md` §2

- 2026-10-05 · On the catch-up-free `|det M| = 2` class, **A1′ and T2 are the
  same statement**, so #138's aligned branch and #139's strict-zipper branch
  converge. Mechanism: Theorem C's template gives `h(x) = x`, `h(c) = c`, hence
  `h(x) != h(c)`, so Lemma A's contrapositive forbids any offset-zero child of
  `(x, c, 0)` other than its leftmost, which is itself; a coincidence must
  therefore arrive through a nonzero-offset return, and by Lemma P every such
  return is a simultaneous birth, which is T2's object. Covers all 210
  catch-up-free corpus members (all of determinant 2) and 570 of 654 at total
  length <= 8. · same §3

- 2026-10-05 · Why A1′ is not a corollary of the Barge-Diamond import, in one
  line to stop the question being reopened: BD Theorem 1 produces **one** of
  the `d(d-1)/2` pairs, and neither of its two cases can be aimed at a
  prescribed pair. For `d = 2` there is only one pair, which is exactly why the
  two-letter case is a theorem; for `d = 3` the two bad edges are left open and
  A1′ asks for the aimed version on one of them. · same §4

- 2026-10-05 · #138's aligned branch has **one** surviving obligation, not
  two. Theorem C: passing to `sigma^2` squares the first-letter map, a fixed
  bad edge is permuted by it so the square fixes the edge pointwise, and in the
  alternating-E template the square is the identity — so all three
  sub-templates become the case where both letters of a bad edge are
  `h`-fixed. Every hypothesis transfers (`sigma^2` is PIP because `beta^2` is
  still cubic; the good pair survives by raising the level; a `sigma^2`-child
  is a `sigma`-grandchild). Certificate: 36/36 viable endpoint/good-edge
  placements, with `h o h` fixing at least two letters always. The surviving
  statement in classical form: two distinct one-sided fixed points of a PIP
  substitution, anchored at a common point, share a tile. ·
  `p1a-template-collapse-2026-10-05.md`; `kernel/psc/hub_selector.mojo`

- 2026-10-05 · Stop/go on that surviving obligation: it is a **special case of
  the open ternary strong coincidence problem**, not a corollary of the
  Barge-Diamond import. BD 2002's Case 1 (maximality) produces two eventually
  coincident segments that start at the same point — exactly the aligned
  configuration — but the pair it hands over is whichever maximality gives, and
  the argument cannot be aimed at a prescribed pair; that is why `d >= 3` is
  open. Negative control worth keeping: eventual coincidence is stable under
  raising the level but is **not** transitive (two witnesses decompose
  `sigma^n(j)` at unrelated positions), so any proposed proof that would also
  give transitivity is wrong or is a major result. Also recorded:
  Akiyama-Gaehler-Lee settle PSC by exhaustive search for every three-letter
  substitution of incidence trace at most 2 — a finite-domain fact worth
  pairing with this repository's own trace condition
  (`kernel/psc/degree2_sieve.mojo`), not a mechanism. ·
  same note §4

- 2026-10-05 · Proposition LC verified exactly on the whole standing corpus:
  10,584 terminal leftmost cycles over 4,554 specimens, every one sign-constant
  and prefix-vs-interior, no capped box graph, no failed replay, longest
  `r = 39`; 10,128 cycle equations replayed over Z and 456 past the exact
  integer range, reported uncomputed. Two sharpened corollaries: terminal
  cycles come in **mirror pairs** of opposite sign, so their number is even
  (LC4 — the catch-up-free counts are 2, 4, 6, 8, 10, never odd); and a box
  graph with **no** terminal cycle has `Z(s) = ∅` for every seed, giving
  finiteness for that substitution by Proposition 5.47 (LC5), which covers
  1,794 of the 4,554. LC5 is a cheaper certificate, not a new finite-domain
  result — the Proposition V census already certifies the whole corpus — and
  it is one-directional and useless for the uniform statement, since all 210
  catch-up-free specimens have cycles. ·
  `p1b-leftmost-chain-periodic-pair-2026-10-05.md` §§8–8a;
  `kernel/leftmost_chain_census.mojo`

- 2026-10-05 · The leftmost child is a *function* on nonzero-offset vertices,
  so `CU` is the complement of the basins of its terminal cycles, and every
  such cycle is a prefix-vs-interior periodic pair with constant offset sign
  (Proposition LC). Worth not rederiving: the sign is preserved by every
  leftmost step, so the catching side's child index is always 0 and its letters
  follow the first-letter map `a -> sigma(a)[0]`; at most three letters are
  periodic for it, so the prefix side of every cycle is one of at most three
  tilings. This gives Lemma P back in one line. It does **not** give T1: the
  reachability half is still a pointwise hitting problem. ·
  `p1b-leftmost-chain-periodic-pair-2026-10-05.md`;
  `kernel/psc/leftmost_chain.mojo`

- 2026-10-05 · Stop/go on the leftmost-cycle route: Siegel-Thuswaldner's
  zero-expansion graph (Def. 5.1 of *Topological properties of Rauzy
  fractals*) is the same principle — a finite graph whose nodes all lie on
  infinite paths decides whether 0 lies in a tile — so claim no novelty for it.
  The decisive hypothesis boundary: their Proposition 5.2 is for primitive
  **unit** Pisot substitutions and its proof uses unimodularity at the step
  "`gamma_{l+1} ∈ pi(Z^n)` by the unimodularity of `M`", which is exactly the
  `M^{-1}`-integrality that Proposition LC(4) must carry explicitly as
  `ab(Q) ∈ (I - M^r) Z^A`. Their graphs are in the contracting representation
  and are not functional, so no sign invariant and no prefix-vs-interior
  dichotomy there. Geometric property (F) is the right dictionary entry for a
  resolved carry. · same note §5

- 2026-10-05 · Finite observation worth not recomputing: Tribonacci
  `0 -> 01, 1 -> 02, 2 -> 0` has **no** terminal leftmost cycle at all — every
  nonzero-offset vertex reaches a catch-up — which is the expected unimodular
  behaviour (Lemma P is void). The smallest witness in the other direction is
  `0 -> 1, 1 -> 12, 2 -> 022`, with two cycles of length `r = 1`,
  `ab(Q) = e_0` and `w_0 = (0, 1, -1)`; it is checkable by hand and is pinned.
  The catch-up-free `1 -> 22, 2 -> 012` specimen's cycles have `r = 15`, where
  `M^r` is already past the exact 64-bit integer range, so its offsets are
  reported as uncomputed rather than assumed. · `kernel/tests/test_leftmost_chain.mojo`

- 2026-10-05 · The closure behind `PDSImpliesRepoG1` tracked only the Barge
  import; its five repository inputs were named in the record `source` field
  but were not ledger nodes. Three are now nodes — `ReturnModuleFullRank`
  (Theorem R), `PeriodicPairOneFibre` (Proposition F) and
  `StrictZipperPeriodicPairForm` (Theorem B with Lemma C and Corollary B′) —
  and the closure stays complete. The trap worth not re-finding: manuscript
  Proposition 5.47 must **not** be added as a dependency, because the existing
  `G1HalfCoincidenceRoute` node bundles the half-coincidence bound with its
  open all-seed premise, so requiring it would make an unconditional
  implication read as conditional on an open gate. Splitting that node into
  premise and mechanism is the only way to model 5.47's role, and it was not
  attempted here. · `tools/make_ledger.py`; `audit-2026-10-04.md` §D.4
  resolution

- 2026-10-05 · The three manuscript statements tagged
  `\Status{Theorem}, conditional only on its hypothesis` (Theorem 5.38,
  Propositions 5.46/5.47) now read `\Status{Conditional}` with the open
  hypothesis named. Carried as audit debt since 2026-09-20; it was always only
  a taxonomy inconsistency, since every generated surface already classified
  them as conditional. · `audit-2026-09-20.md` §5, `audit-2026-09-27.md` §G.1,
  `audit-2026-10-04.md` §D.6

- 2026-10-05 · Tooling pitfall: `claim_governance`'s promotion check reads a
  proving phrase within 120 characters of any claim alias, and its
  `negating_context` list does not contain "none". A section-closing
  disclaimer of the form "None of the above is proved" therefore *triggers* a
  promotion finding against a claim name a few lines above it. Write the
  disclaimer without a proving phrase ("nothing here discharges an open
  premise; X remains open") rather than relying on the negation list. ·
  `tools/claim_governance/checks/promotion.py`, `claim_governance.toml`
  `[promotion]`

- 2026-10-04 · Independent adversarial audit (no counterexample found) of
  Lemma C, Theorem B, Corollary B′, Proposition F, Theorem R, Proposition V,
  Theorem S, the mass lemma, Lemmas E, VT, B, the Barge-class lever,
  Proposition FP, Corollary FP′ and the region argument. All hold as
  corrected; fifteen findings applied in the notes (dated corrections). The
  one open item: the hypotheses of the imports behind Theorem S (Barge 2013
  Thm 4(5),(6); Barge 2015 item (3)) are recorded but not audited in any gate.
  Do not cite "Barge 2013 Thm 4(3)" (not recorded) or BK Lemma 5.12 for
  "no common tile ⇒ cr ≥ 2" (wrong direction). Theorem S implies "PDS ⇒ G1 for
  the all-seed automaton", which manuscript Open Problem 4.24 declines to
  assert; flag it at review. · `p1b-vertex-coincidence-box-2026-10-02.md`
  §5.1, §7; `p1b-strict-zipper-periodic-pair-2026-10-02.md`;
  `p1b-periodic-pair-fibre-literature-gate-2026-10-02.md` §6
- 2026-10-04 · The Theorem S import gap is closed: Barge 2013 Thm 4 (Pisot
  family) and Barge 2015 §1 items (2)–(3) (primitive, non-periodic, Pisot
  inflation) assume neither unimodularity nor irreducibility, so every PIP
  substitution qualifies. Do not re-audit. ·
  `coincidence-rank-imports-literature-gate-2026-10-04.md`
- 2026-10-04 · `PDSImpliesRepoG1` promoted to repository-proved (Theorem S
  route; audited; human review pending) and manuscript Proposition
  `prop:PDS-implies-G1` added; the coincidence half of Open Problem 4.24
  stays open. · `tools/make_ledger.py`; manuscript §4.8
- 2026-10-04 · Pre-existing false positive on `main`: `tools/audit_manuscript.py`
  flags `docs/psc-motivation-2026-10-02.md:58`, where "PSC is closed" appears
  in a list of formulations to *avoid*. Not caused by this branch. ·
  `tools/audit_manuscript.py` (psc-closed-premise rule)
  *Fixed 2026-10-04:* the rule now reads a Markdown list together with its
  colon-terminated lead-in paragraph and accepts "avoid" as negation; an
  affirmative list ("Results:" / "- PSC is closed.") still fails. ·
  `tests/test_audit_manuscript.py`
- 2026-10-04 · Former manuscript Open Problem 4.24 answered in full: pure
  discrete spectrum gives termination with coincidence from every seed,
  legal or not (Theorem `thm:seedwise`; ledger `PDSImpliesSeedwiseTermination`,
  with imported `StrongCoincidenceFromPDS`). Dated notes that still call 4.24
  open (`audit-2026-09-20.md`, `bsw-import-literature-gate-2026-09-21.md`,
  `overlap-finiteness-and-coincidence-density-2026-09-13.md`) are history, not
  status. · manuscript §4.8; `formal-productivity-reduction-2026-10-04.md`

- 2026-10-05 · Vendoring review caught shared machine-integer and governance
  defects beyond green consumer CI. FMK #63 repairs checked products and
  signed-minimum GCD refusal, exact support-based primitivity, alternative-route
  closure and executable-source coverage. All twelve packages now match landed
  commit `360bc90c27893900d30718e42d61d14ce255e530`; the boundary-synchronization
  wrapper propagates upstream refusal. ·
  <https://github.com/larsbx/finite-math-kernels/pull/63>; `vendored.toml`;
  `kernel/psc/boundary_sync.mojo`
- 2026-10-06 · PSC's substitution application and powers now come from the
  vendored `Substitution.apply` / `apply_n`: the second `apply_substitution`
  in `oa_overlap_types` and `one_tile._power` are deleted, and
  `legal_tower.apply_substitution_n` and `dumont_thomas.power_substitution`
  delegate. The alphabet-generic callers keep the trusted (unvalidated)
  constructor; the alphabet-3 callers keep `bpa.sigma3`'s abort, at depth 0
  still unconsulted. `periodic_pair._image` stays: its word cap refuses
  mid-construction, which `apply_n` cannot. Claim receipts and the full Mojo
  test log are byte-identical before and after. · `kernel/psc/legal_tower.mojo`;
  `kernel/run_tests.sh`
- 2026-10-06 · `pisot.is_primitive(Mat3)` now delegates to the vendored
  `integer_matrix.is_primitive` (Boolean support powers). The old body
  multiplied real powers `M^1..M^5` with unchecked `Mat3.__mul__`, so a
  matrix with entries large enough to wrap could be misjudged; on every
  matrix whose fifth power fits a machine integer (all incidence matrices
  here) the verdicts agree, as `test_boundary_sync` already pinned. The
  vendored test raises only on a dimension mismatch, impossible for a
  `Mat3`, so the view aborts there. `periodic_pair._checked_mat_mul` is
  replaced by the checked `integer_matrix.matmul`: it raises exactly when
  the old one did, though in a contrived case with two overflowing entries
  the message may name addition where the old named multiplication, or the
  reverse (loop order i,k,j against i,j,k). · `kernel/psc/pisot.mojo`;
  `kernel/psc/periodic_pair.mojo`
- 2026-10-06 · The 2026-10-04 session-probe replay pointed `MOJO_DIR` at the
  retired `mojo/`; repointed to `kernel/`. All five Mojo probes compile
  unchanged against the current APIs and reproduce the archived results
  (vc_try radii 29,17,18 / 61,337 states / 716 recurrent; closure 276 + 72;
  diagonal 1,080,828 / 1,153,308 of 1,154,040, 180/30; direct 4170 of 4344,
  29,712 vertices), compared against the README index (the archived
  `rerun_*.out` files were never committed; the fresh ones carry new
  timings and were not written back). ·
  `archive/2026-10-04/session-probes/probes/rerun.sh`
- 2026-10-06 · `psc.real_root_sign` now builds its Tarski query on the
  vendored `qpoly` (`normalize`, `derivative`, `mul`, `remainder`, `neg`,
  `evaluate`, `variation_difference`); its `poly_trim`, `poly_deriv`,
  `poly_mul` and `poly_rem` are deleted. `tarski_query`, `count_real_roots`,
  `isolate_real_roots` and `sign_at_isolated_root` stay: `qpoly` has no Tarski
  query and isolates only the largest root. One semantic difference: the old
  helpers raised on a rejected rational, `qpoly` aborts (via `q_is_zero`), so
  `tarski_query` now checks its inputs are accepted and raises first; accepted
  rationals stay accepted under every operation used. Runtime unchanged:
  13,530 `sign_at_isolated_root` calls take 15.7 s on each side;
  `overlap_contracting_census` 615/615 s before, 647/614 s after;
  `vertex_coincidence_census` 791/647 s before, 855/700 s after (run-to-run
  noise is about 20%), output byte-identical. · `kernel/psc/real_root_sign.mojo`;
  `kernel/tests/test_overlap_contracting.mojo`
- 2026-10-06 · `psc.pisot` and `psc.pisot_screen` take the derivative,
  negation, gcd and Cauchy root bound from the vendored `qpoly`;
  `poly_derivative`, `cauchy_bound` (`3 + max floor|p_k/p_n|`, a looser
  bound than `qpoly.root_bound`'s `1 + max |p_k|/|p_n|`; only ever an
  enclosing interval, so no count changes), `pisot_screen.poly_gcd` and
  `int_cauchy_bound` are deleted. Kept local after measurement: `poly_eval`
  (unrolled; `qpoly.evaluate` is the reference algorithm, about 15% slower
  in `pisot_polynomial_bench`), `poly_degree` (`qpoly.degree` copies),
  `poly_rem` (keeps length, returns the dividend for a zero divisor where
  `qpoly.remainder` aborts; `test_pisot_polynomials` pins it) and
  `sturm_chain` of `p` itself: `qpoly.sturm_chain` passes to the squarefree
  part first, and an all-`qpoly` `is_pisot_charpoly` ran about 17% slower on
  the 3,375 monic cubics with `|c_i| <= 7`. The two chains differ only for
  non-squarefree `p` with a root at a count endpoint, outside Sturm's
  hypothesis: the plain chain gives `-1` on `(-1, 1]` for `(x - 1)(x + 1)^2`.
  `is_pip` tests irreducibility first, and the `is_pisot_charpoly` verdicts
  agree on all 3,375 cubics. The chain is now built once per cubic rather
  than once per count: `test_census_library` 13.3/14.0 s to 8.5/8.2 s,
  `census.mojo` 91/98 s to 84/88 s. Claim receipts and the full Mojo test log
  are byte-identical before and after. · `kernel/psc/pisot.mojo`;
  `kernel/psc/pisot_screen.mojo`
- 2026-10-06 · Tooling pitfall: `tools/verify_all.sh` and a `uv tool`
  `pytest` fail `manuscript source integrity` when `pypdf` is missing from
  that interpreter. That is the pinned dev dependency (`pyproject.toml`), not a
  manuscript defect; install `pypdf==6.19.0` into the interpreter that runs
  it. · `tests/test_check_manuscript_source.py`
- 2026-10-06 · Symmetry, endpoint maps, Barge class, bounded BPA, Dumont-Thomas,
  return lattices and the strong-coincidence automaton moved to the vendored
  `substitution_dynamics` over an explicit alphabet; only the Perron-field
  reserve and the C4 A..G names stay here. Pitfalls met: `psc.symmetry.word_key`
  renders arbitrary integer lists (cycle lengths, counts), so it stays the
  plain decimal concatenation rather than the package's bracketed letter key;
  pruning-independence makes the shortest coincidence witness, minimised
  sizes and coaccessible counts reproducible under any sound bound, which is
  how the package regressions pin this repository's outputs. Two orbits of a
  self-map of d letters that meet do so within d - 1 steps (exhaustive,
  d <= 6). · finite-math-kernels `tests/substitution_dynamics/`
- 2026-10-06 · Owner decision: the vendored `prolongable_points`
  (`substitution_dynamics/dumont_thomas.mojo`, finite-math-kernels
  `d61bcf8`) reports each letter at its minimal prolongable power only (its
  first return under the first-letter map), as its docstring says, not again
  at every multiple of its period up to `|A|`. Tribonacci now has one
  prolongable point `(1, 0)` instead of `(1, 0), (2, 0), (3, 0)`;
  `test_oa_overlap_types` pins that. In `oa_type_inclusion_census` and
  `oa_failures_probe` only the `"points"` field of 17 of the 22 per-specimen
  JSON lines drops (3 -> 1, 5 -> 3, 6 -> 2), where the dropped powers were
  duplicates giving the same fixed-point word; union types, witnesses, every
  CI-pinned summary line and the claim receipts are byte-identical. The
  per-specimen lines are recorded nowhere in the repository. ·
  `kernel/tests/test_oa_overlap_types.mojo`; `kernel/oa_failures_probe.mojo`

- 2026-10-06 · Repository-wide PSC research audit confirms the canonical
  status is coherent after #153: PSC and `OP_seed`/#84 remain open, and no
  accidental PSC promotion was found. Highest-priority review debt is the
  October 4 PDS => PPVC/G1 => all-seed-termination chain, whose live surfaces
  still say human review pending. Research priority is narrowed to seed-strength
  #84 plus an occurrence-compatible adelic coverage/alignment theorem for #139;
  #9 should supply only portable ordered-factorization lemmas. PR #223's
  Dumont–Thomas streaming regression is resolved at the current FMK pin;
  PR #221 should not merge unchanged because its side-notes entry is missing
  and its base predates the current vendoring state. No claim status changes. ·
  `audit-2026-10-06.md`
- 2026-10-07 · Dated correction to the October 6 PSC audit entry: PR #221 was
  rebased, supplied its required benchmark/ledger locator, revalidated, and
  merged at 00:45:58 UTC as `f09627e377abae49e5a4bf13694cb0e15f11ed36` after
  green current-head workflows and a no-findings review. Its tooling finding
  is resolved; the October 6 snapshot and prior ledger entry remain intact.
  No mathematical claim or review status changes. ·
  [October 7 follow-up](audit-2026-10-06.md#7-follow-up-2026-10-07);
  [PR #221 evidence](https://github.com/larsbx/pisot-substitution-conjecture-research/pull/221)
- 2026-10-07 · Specimens already settled by the literature: Tribonacci,
  Kol(3,1), the two Sirvent–Solomyak ternary examples, the Arnoux–Rauzy
  product `σ₁σ₂σ₃`, and the three circulated Rauzy-fractal examples
  `12,31,1` / `12,23,312` / `123,1,31` all terminate with coincidence on the
  all-seed `B_sigma`; six of them lie inside the 145,806-specimen
  finite domain. The circulated `123,1,1132` has `det M = 0` and is not PIP.
  The Sirvent–Solomyak count of 260 pairs of length 194 is not reproduced
  under the `(ab,ba)` seed convention (257 / 137); it stays unconfirmed until
  checked against the paper's full text. No claim status changes. ·
  [motivations note](motivations/ternary-literature-context-2026-10-07.md);
  `kernel/tests/test_ternary_literature_specimens.mojo`
- 2026-10-07 · Adversarial audit of Proposition V and Theorem E found no
  disproof and no failing proof step. An independent oracle reproduced every
  computational input: the Theorem E class enumerated to image length 5 stays
  in the normal form and is coincident; the 27-member residue was reproduced;
  the Proposition V radii hold with margin ≥ 2. Four presentation fixes were
  applied to the A1′ note: "position" means prefix length, L_BC's dead
  `r = q = 0` clause was removed, two endings have det divisible by 4, and
  §3b.7 line ranges are now explicit. The dead clause stays in the kernel's
  `lemma_witness`, where it is unreachable. No claim status changes. ·
  `audit-adversarial-prop-v-theorem-e-2026-10-07.md`,
  `archive/2026-10-07/session-probes/`
- 2026-10-07 · Correction to the entry above: the dead L_BC clause is now also
  removed from `lemma_witness` in `kernel/a1_normal_form_census.mojo`.
  `tests/test_a1_normal_form.mojo` passes unchanged (453 named witnesses,
  27-point residue), which confirms the clause never fired. ·
  `kernel/a1_normal_form_census.mojo`
- 2026-10-07 · The 145,806-specimen PDS statement does not need Theorem B,
  Lemma C, Proposition F, Theorem R, Theorem S or Proposition V(2): step 1 of
  Proposition V (cycle vertices lie in the box, a geometric series) with
  Proposition FP turns the recorded box verdicts and SC_all into formal
  productivity, and FP gives PDS both through Lee–Moody–Solomyak overlap
  coincidence and through Theorem 5.38. It also certifies termination with
  coincidence from every swap seed, so the 120 budget-exhausting cube-family
  specimens need no direct `B_sigma` build. The swap-seed graph misses box
  cycle vertices (38 on the cube specimen), so it cannot replace the box on the
  literature route. A fresh re-derivation of Lemma C, Theorem B, Proposition F,
  Theorem R and depth-note Propositions 1/4 found no error. ·
  `pds-certificate-from-the-box-automaton-2026-10-07.md`
- 2026-10-08 · The 145,806-specimen PDS statement is promoted to the claim
  ledger as the finite-domain theorem `BoundedPureDiscreteSpectrum` (claim
  map row "Finite-domain pure discrete spectrum"). The proof-dependency
  ledger is unchanged, because the claim is finite-domain, not a universal
  implication. ·
  `pds-certificate-from-the-box-automaton-2026-10-07.md` §§5, 9;
  `claim_governance.toml`
- 2026-10-08 · PR #228's Python oracle `_poly_rem` now caches the exact
  leading reciprocal and nonzero divisor terms for degree >= 4; small divisors
  retain dense division after setup overhead was measured. Independent dense
  quotient/convolution checks cover 4,800 rational pairs (324 cached-path
  cases); all 3,375 cubic caller results agree. Recorded sparse degree-12/32
  workloads improve 3.19×/7.43× in elapsed time; no uniform dense or whole-screen
  speedup is claimed. The unrecorded "14s to 8s" figure is withdrawn and the
  PR's incorrectly dated `2024-05-18` `.jules/bolt.md` entry is removed.
  The tracked Markdown-link guard requires a removed file's deletion to be
  staged before replay. No mathematical claim status changes. ·
  [scope, regression and replay](poly-rem-sparse-rational-2026-10-08.md);
  [pinned benchmark](../evidence/poly-rem-sparse-2026-10-08/benchmark.json)
- 2026-10-08 · Seed strength buys no slack in truth: for each PIP `sigma`,
  one productive swap seed ⟺ every seed ⟺ FP ⟺ PDS (Theorem 5.38 forward,
  Corollary FP″ back), so do not look for a seed that avoids an obstruction.
  The object does depend on the seed: on 444 of 4,554 standing specimens the
  three seeds reach different recurrent parts, and none is ever empty. The
  census domains are closed under reversal, so the prefix SC census already
  gives two-sided SC on 408,798 specimens. Class B lines with slope 3 and
  `r = q − 1` leave PIP (a second eigenvalue of modulus 1, or above it). ·
  `p1-seed-strength-2026-10-08.md`
- 2026-10-08 · Class B swap-seed graphs are constant on sectors of the
  `(q, p)` plane bounded by slopes `1, 3/2, 2, 5/2, …` (74 / 226 vertices for
  `r = q + 1`; 123 / 171 / 217 for `r = q − 1`), with sectors accumulating at
  slope 3; along `p = 3q + 11 − d`, `d` fixed, the graph grows linearly in `q`
  (`d = 0`: 2,655 → 4,893 vertices for `q = 8 → 28`). Do not look for a finite
  symbolic graph on the top layer: it needs an index variable. Scans are
  scratch exact-kernel runs at `q = 12, 20, 21, 28, 40`. ·
  [cone note §1, §5](p1b-symbolic-cone-2026-10-08.md)
- 2026-10-08 · Retired for two parameters: the parametric Sturm–Tarski sign
  reader of `psc.symbolic_line`. Its sequence entries need not keep one sign
  on a 2D region even when the query does; the cone engine brackets `beta`
  between certified rational functions instead. On Theorem L's line the
  bracket method certifies from `q >= 6`, where Sturm needed `q >= 52`. ·
  `kernel/psc/symbolic_cone.mojo`
- 2026-10-08 · Tooling pitfall: Pólya's multiplier cannot certify a
  polynomial whose top form vanishes on a ray of the orthant (e.g.
  `(s1 − s2)^2 + s1 + 1`, or a one-variable polynomial lifted by
  `1 + u + v`); the region reader lifts only by the coordinates that occur. ·
  `kernel/tests/test_symbolic_cone.mojo`
- 2026-10-08 · Rauzy representability of the closed claims: of the 47
  closed repository-proved claims (44 ledger nodes with complete closure plus
  three hand-ledger claims), 11 are natively statements about adelic Rauzy
  pieces, 2 partly, and 34 not: they use degree ≥ 2 subword or free-Lie
  invariants that the Parikh map erases, or stay on `Z^A` without reaching
  the projection (factoring through ℓ is necessary, not sufficient). The shortest PDS route and
  the #139 frontier lie on the Rauzy side. This is an interpretive map; it
  moves no claim status. · `rauzy-representability-2026-10-08.html`
- 2026-10-08 · Correction to the 2026-10-08 `BoundedPureDiscreteSpectrum`
  entry above ("the proof-dependency ledger is unchanged"): the two notes' proved results are
  now proof-dependency (TLA+) nodes. Box note: `BoxCycleContainment` (Lemma Ω1),
  `BoxAutomatonCertificate` (Theorem Ω), the open gate `FormalProductivity`,
  the import `OverlapCoincidenceCriterion` (LMS 2003 Lemma 6.9 + Thm 4.7, LS
  2012 Thm 4.3), and consequences (a), (b), (c) as `PDSFormalProductivityRoute`,
  `PDSFormalProductivitySeedRoute` and `G1FormalProductivityRoute`; the last
  is a fourth alternative establishment of canonical G1. Leftmost note:
  `LeftmostChainCycleStructure` (Lemma S, Proposition LC, Corollary LC4) and
  `LeftmostChainG1Certificate` (Corollary LC5). Routes (b), (c) and LC5 cite
  Theorem 5.38 and Propositions 5.46/5.47 for their mechanism but do not depend
  on those nodes, which bundle the weaker open seed gates (the D.4
  resolution). New model `MCLedgerFormalProductivityGateAssumed`: FP with the
  two imports reaches G1 and both PDS routes, and leaves PDS, SCC Producer and
  every seed gate unestablished; all 15 TLC models hold. No status of PSC, G1
  or any gate changes. ·
  `tools/make_ledger.py`; claim-map rows from "Cycle vertices lie in the box
  automaton" and "Leftmost-chain cycles are prefix-vs-interior pairs"
- 2026-10-08 · Review of the two notes before promotion, from the statements:
  Lemma Ω1(1) needs the map `w -> (<ell, w>, (sigma_k <ell, w>)_k)` to be
  invertible over `R`, not only injective on `Z^3`; it is, since it factors as
  a Vandermonde matrix of the distinct conjugates of `beta` times the rational
  coordinate matrix of `ell`, which is invertible by `Q`-independence. Ω1(2)'s
  bound uses `|1 - sigma_k(beta)^p| >= 1 - mu_k^p` and
  `sum_{n<p} mu_k^n <= (1 - mu_k^p)/(1 - mu_k)`. Theorem Ω's descent needs every
  non-coincident overlap to have a child, which holds because the sub-tiles
  of each image cover their tile up to finitely many points. In Proposition LC
  claim 5, "the composite fixes `c = 0`" follows directly from the definition of
  the leftmost child (each edge maps the parent's left region end to the
  child's), so Lemma C step 1 is not needed, and the M-adic-centre remark
  (Proposition P″(a)) is not load-bearing. `LeftmostChainCycleStructure` thus
  has no ledger dependency. Corollary LC4's involution maps the leftmost child
  to the leftmost child because it translates the region by `-t`. Corollary
  LC5 uses Lemma Ω1(2) for "terminal-SCC vertices lie in the box", and needs
  each `Z(s)` vertex to have a child, which holds because it is not a
  coincidence. No error found. ·
  `pds-certificate-from-the-box-automaton-2026-10-07.md` §§3–4;
  `p1b-leftmost-chain-periodic-pair-2026-10-05.md` §§3–4, 8a
- 2026-10-08 · Two two-parameter engines agree on class B's wedge `q < p < 2q`:
  `psc.symbolic_cone` (Theorem C) and the line engine generalised to
  `Q[s, d]` (commit `5ee3f0f`, not merged). They were written separately
  but share `psc.symbolic_line`'s primitives: support primitivity, offset-zero
  reachability, and the exact Sturm reads at sample points. Every shared
  vertex count matches. The second engine also showed where the Sturm chains break
  inside a region:
  - along `d^2 ≈ 8s`, where the conjugate pair turns from real to complex;
  - along the irrational ray `d/s = (1 + sqrt 5)/2`, through a leading
    coefficient.

  Rouché (`|c_2| > 1 + |c_1| + |c_0|`) decides PIP there with three sign reads
  and no bracket. ·
  `p1b-symbolic-cone-2026-10-08.md` §4;
  `archive/2026-10-08/class-b-wedge-crosscheck/`


- 2026-10-08 · Reconcile #236/#237 after #241 merged at `33a1b8b`: keep
  its Ω1/Ω/LC grouping and formal-productivity model, retain both independent
  review notes, add separate Meyer/import and per-specimen box-PDS evidence,
  and preserve the open uniform gates. LC's prefix object is a right-infinite
  ray; zero child indices are on the later-starting side. The census completion
  gate now raises on caps and refuted sign/shape or integral replays; 456 long
  offsets remain uncomputed. Source-inventory and compiled Lean audit are
  separate: root `PscVerif.lean` proofs must be inventoried, and a dependency
  at its pinned HEAD with tracked edits must refuse verification. Seven added
  negative cases reproduce these P2 defects on #237 and pass after repair. ·
  [reconciliation and source mapping](proof-ledger-reconciliation-2026-10-08.md);
  `tests/test_proof_bank.py`; `kernel/tests/test_leftmost_chain.mojo`
- 2026-10-08 · LC claim 5 fixes the region end directly by the definition of
  each leftmost child; its prose proof now states this, matching #241's review
  and dependency-free cycle-structure node, without invoking Lemma C. ·
  `p1b-leftmost-chain-periodic-pair-2026-10-05.md`, Proposition LC proof step 5
- 2026-10-08 · Current-head review of the reconciliation found an additional
  dependency gap: hiding untracked files lets an injected Lean source pass at
  the correct HEAD. Pin verification now rejects nonignored untracked files;
  two additional negative controls reproduce the gap before repair, while
  ignored build-cache artifacts remain usable. · `tests/test_proof_bank.py`;
  `tools/make_proof_bank.py`
- 2026-10-08 · The ignored-file review extends dependency refusal beyond
  ordinary Git status: a local Git exclusion can hide an injected Lean source.
  Ignored files are now enumerated separately; source/configuration inputs and
  ignored files outside the declared build-artifact paths refuse verification.
  Four new negative controls cover ignored Lean and cache-adjacent TOML inputs
  in both pin-check modes. The thirteen root/pin negative cases pass. ·
  `tests/test_proof_bank.py`; `tools/make_proof_bank.py`
- 2026-10-08 · Git status alone also hides tracked edits marked
  assume-unchanged or skip-worktree. Dependency verification now compares
  actual tracked bytes, file types and executable modes with HEAD's tree,
  without changing the index. Four negative controls reproduce these flag
  bypasses; all seventeen root/pin cases pass, as do the real nine manifest
  checkouts. This is source/pin verification, not a compiler or proof receipt. ·
  `tests/test_proof_bank.py`; `tools/make_proof_bank.py`

- 2026-10-08 — A fresh pinned Lake build exposed normal ignored outputs outside the initial cache allowance: `.lake/build/ir/**/*.setup.json`, `.lake/build.barrel`, and `.lake/build.barrel.trace`. Permit only those generated paths in addition to the existing caches; dependency regressions now carry these real output shapes while still refusing all source/configuration injections. Local Lean startup required a scratch-only shim mapping its own numeric `/proc/<pid>/exe` lookup to the identical permitted `/proc/self/exe`; no compiler, kernel, or dependency source was changed.
- 2026-10-08 — During integration validation, #236 was independently rebased to `3eb62008d39aa3a531b27980615972e0d5b80a44`. Compare that current head as well: retain its two added vertex-test claim declarations and reconciled-baseline metadata, keep the explicit Meyer import and partial Lean spectral locators, and preserve #241's direct leftmost-child fixed-end proof. No new mathematical premise is discharged. Evidence: `docs/proof-ledger-reconciliation-2026-10-08.md`, `kernel/tests/test_vertex_coincidence.mojo`, and `tests/test_ledger_generation.py`.
- 2026-10-08 — Current-head review reproduced another source-integrity bypass: Git replacement refs make a pinned HEAD and clean status expose an altered tree. Disable replacement objects for every dependency inspection. Two real replacement-commit controls fail before the repair and pass afterward; nineteen root/dependency negative cases now cover the original P2s and follow-up findings. Evidence: PR #237 discussion 4225106073, `tests/test_proof_bank.py`, and `tools/make_proof_bank.py`.
- 2026-10-08 — The root-module repair did not alone make all valid Lean headers visible: `nonrec`, `public`, other pinned declaration modifiers and multiline headers/attributes could omit named proofs. Inventory the complete pinned modifier vocabulary and balanced attributes across line breaks. Six failing-before/passing-after controls require each proof in the source bank and reject its omission from an audit receipt; all twenty-five inventory/dependency negative controls pass. Evidence: PR #237 discussion 4225149030, Lean v4.34.0-rc2 `Parser.Command.declModifiers`, and `tests/test_proof_bank.py`.
- 2026-10-08 — Compact scoped Lean commands can put a theorem after `open ... in` or `set_option ... in`, beyond the supported source-header grammar. Detect every otherwise unaccounted theorem/lemma header and refuse inventory rather than silently omit it. Two additional negative controls reproduce the omission before this guard; twenty-seven inventory/dependency controls now pass. Evidence: `tests/test_proof_bank.py`, `tools/make_proof_bank.py`.
- 2026-10-08 — Private Lean proof names are internally mangled, so direct source-name comparison rejected valid private theorems/lemmas. Audit replay now emits Lean's native `privateToUserName` normalization alongside the unique compiled name and origin module. Reconcile source proofs by module/name while retaining raw declaration/theorem counts; support identical private helper names in distinct modules and refuse ambiguous claim bindings. Reproduced the original missing-name failure and added private theorem/lemma compatibility plus missing-module controls. Evidence: PR #237 discussion 4225196994, `proof/PscVerif/ProofBankAudit.lean`, and `tests/test_proof_bank.py`.
- 2026-10-08 — Final review raced with main's merge of #244 at `d98e027f8f22400fd827fbce8635d3f6a8ea2e6d`. Integrate its class-B cross-check documentation and archived logs byte-for-byte, preserve both independent append-only side findings, and regenerate the source inventory. Its shared-primitives and provenance-versus-proof boundary stays explicit; no PSC/G1/PDS premise changes. Evidence: `docs/proof-ledger-reconciliation-2026-10-08.md`, `archive/2026-10-08/class-b-wedge-crosscheck/README.md`.

2026-10-08 — Current-head cache review: source pins do not attest ignored compiled dependencies. Lean verification now discards caller compiled caches/configuration, clones and byte-checks fresh pinned dependencies, and uses a fixed upstream Mathlib source-hash cache in an empty temporary directory before compiling PSC and replaying its axiom audit. A forged-artifact/metadata and environment-override regression fails against the prior dispatcher; compiler and upstream cache trust remain explicit. No mathematical claim status changes.

2026-10-09 — Current-head compiler-selection review: inherited Elan environment/directory overrides outrank lean-toolchain files. Verification now invokes every Lake command through the explicit checked-in Elan toolchain and refuses mismatched Lean/Lake executable versions before building. Four negative controls reproduce the override/version mechanisms; no mathematical claim status changes.

2026-10-09 — Main advanced to 8d91e48 through #245 during final review. Reconciliation retains its Rouche-first symbolic-cone certificate, Jury fallback and regression, with the changed Mojo test rerun and its actual receipt refreshed. Canonical ledger nodes and Lean sources are unchanged; governed inventories are regenerated on the new main.

2026-10-09 — Current-head review found compiler overrides also affected provisioning. Setup now forces the exact checked-in Elan toolchain, refuses Lean/Lake version mismatches and clears inherited Lean/Lake/cache configuration before cache preparation. Four failing-before/passing-after setup controls cover both overrides and version probes. Development setup grants no formal audit credit; the Lean README routes verification to the isolated complete audit and preserves partial formalization boundaries.
- 2026-10-08 · The line certificate is not class-B specific: on 32 lines of
  Theorem E's classes A (slope 2), C and D it certifies boundary hitting from
  every seed (Theorem L″), and every refusal met was a line outside the
  Pisot class. Class A at slope 1 is different: its seed graph grows linearly
  in `n` (235 → 915 vertices for `n = 3 → 20` at `p = n + 1`), so the
  constant-graph method cannot reach it. Do not rerun it there with a larger
  budget; it needs vertex families indexed by a run position. ·
  `p1b-boundary-hitting-progress-2026-10-08.md` §§3–4
- 2026-10-08 · Two-parameter certificates need three changes from the line
  method, each forced by a concrete failure on class D. (1) Per-entry Sturm
  signs fail: the PIP test's last Sturm entry is the discriminant, which
  changes sign on a parabolic region `b ≲ √(2a)` along an edge. Use instead
  `χ(−1), χ(1), χ(2) < 0`, which is equivalent to Pisot when `|det M| = 2`.
  (2) Sturm–Tarski entries for realness signs change sign along irrational
  rays (slopes `2√2`, `(3 ± √17)/2`), which no rational split avoids. Read
  `sign h(β)` from a nonvanishing norm `det h(M)` plus one sample point. (3)
  Coefficient positivity alone misses forms like `a² − ab + b²`, so add a
  Pólya multiplier. Separately, a whole class-D cone cannot be one wedge,
  because a run-position bound changes regime along `3r = 4q`. Split it at
  the Farey directions `(1,1), (3,4), (2,3), (1,2)`. The same norm reading
  also helps lines that lie beside such a ray. A boundary line on
  `3r − 4q = −9` has threshold 196 by Sturm entries (about 5 h of exact
  finite part) but 4 by norm. Certify wedge edges in norm mode. ·
  `p1b-boundary-hitting-progress-2026-10-08.md` §4b

2026-10-09 — Isolated #247's parameter-algebra refactor (`a3f1b15`) against
#246's pinned pre-refactoring head (`e068c4c`). Both earlier engines inherited
noncanonical `t`-polynomial keys for trailing zero terms; the shared module's
key contract now strips that padding, with a failing-before regression.
Independent monomial evaluation, specialized Euclidean division, denominator
boundaries and three killed coordinate-reversal controls guard the conversion
`(s1, s2) = (b, a)`. Direct replay agrees on the asymmetric 74-vertex class-B
graph (including edges and hitting decisions) and the 105-vertex class-D wedge
(corner `(1, 0)`, 1818 sign reads). This records computational preservation;
#246's separate mathematical review and Corollary W1 acceptance boundary are
unchanged. Evidence: `kernel/tests/test_param_poly.mojo`,
`kernel/tests/test_symbolic_cone.mojo`, `kernel/tests/test_symbolic_line.mojo`,
and the scoped review on PR #247.

