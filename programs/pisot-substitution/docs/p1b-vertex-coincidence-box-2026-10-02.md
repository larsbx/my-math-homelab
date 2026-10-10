# P1b: PeriodicPairVertexCoincidence is decidable per substitution — 2026-10-02

**Status:** research note for issue #139, proved here and not yet reviewed.
Proposition V reduces PeriodicPairVertexCoincidence, for one substitution and
**every** `r` at once, to a property of one finite graph, and
`kernel/psc/vertex_coincidence.mojo` decides it exactly. The general statement,
for every PIP substitution, is **not** proved. §6 explains why it carries the
weight of an open problem. Nothing here is promoted to the ledger or the
manuscript.

Dependencies: `p1b-strict-zipper-periodic-pair-2026-10-02.md` (Lemma C,
Theorem B, Corollary B′); manuscript Theorem 4.22, Lemma 5.45 and Proposition
5.47.

## 1. The statement

*PeriodicPairVertexCoincidence for `sigma`* (PPVC(`sigma`)). For every
`r >= 1` and every pair of interior occurrences `sigma^r(i) = P i U`,
`sigma^r(j) = Q j V` whose centre offset
`w_0 = (M^r − I)^{−1}(pi(P) − pi(Q))` is integral, the `Phi^r`-fixed tilings
`T(i, P)` and `T(j, Q) + <ell, w_0>` share a vertex. By Proposition F and
Theorem R of `p1b-periodic-pair-fibre-literature-gate-2026-10-02.md`, each
such pair lies in one fibre of the maximal equicontinuous factor (the forward
direction of Proposition F; the centre is interior to a tile in both tilings).

By Corollary B′, PPVC(`sigma`) excludes strict zippers from every swap seed,
so by manuscript Proposition 5.47 it gives G1 for `sigma`.

## 2. Proposition V (the box graph)

Notation: overlaps `(i, j, t)` with `t = <ell, w>`, `w ∈ Z^3`, and children as
in the manuscript. `F` is the set of single-inflation increments
`c = <ell, pi(q) − pi(p)>`. For each contracting conjugate `sigma_k` (two real
ones, or one complex `varsigma` counted twice):

- `mu_k = |sigma_k(beta)| < 1`;
- `C_k = max_{c ∈ F} |sigma_k(c)|`;
- `B_k = C_k / (1 − mu_k)`.

Let `theta_0, theta_1, theta_2 ∈ Q(beta)` be the trace-dual basis of the tile
lengths, `Tr(theta_m ell_a) = delta_{ma}`. Let `R_m` be an integer with

`R_m >= |theta_m| ell_max + sum_k |sigma_k(theta_m)| B_k`.

*Proposition V.* Let `sigma` be PIP and let `𝔅` be the closure under
inflation of a finite set of overlaps that contains every overlap with
`|w_m| <= R_m` (`m = 0, 1, 2`). Then:

1. every overlap lying on a cycle of the overlap graph belongs to `𝔅`;
2. PPVC(`sigma`) holds iff every vertex of `𝔅` has an offset-zero descendant
   (the vertex itself included).

*Proof.*

1. **Cycle vertices are in the box.** Along a cycle
   `t_{s+1} = beta t_s + c_s` with `c_s ∈ F`, so
   `sigma_k(t_{s+1}) = sigma_k(beta) sigma_k(t_s) + sigma_k(c_s)`. The
   sequence is periodic, so
   `sigma_k(t_0) = sum_{n >= 0} sigma_k(beta)^n sigma_k(c_{−n−1})` (indices
   mod the period). Hence `|sigma_k(t_0)| <= B_k`. Also `|t_0| < ell_max`,
   since an overlap's tiles meet. Finally,
   `w_m = Tr(theta_m t) = sum_sigma sigma(theta_m) sigma(t)` over all three
   embeddings, which gives `|w_m| <= R_m`.
2. **(⇐).** Given `r` and a pair with integral `w_0`, Theorem B(2) puts
   `v_0 = (i, j, w_0)` on an `r`-cycle. By step 1, `v_0 ∈ 𝔅`, so `v_0` has
   an offset-zero descendant. By Theorem B(3), (a) fails, so (b) fails: the
   two tilings share a vertex.
3. **(⇒).** Let `Y` be the set of vertices of `𝔅` with no offset-zero
   descendant. A child of a vertex of `Y` is in `Y`, and `𝔅` is finite, so
   `Y` is a finite set closed under children. If `Y ≠ ∅`, Lemma C gives a
   cycle in `Y` with interior centre. The converse of Theorem B turns it into
   interior occurrences with integral `w_0` satisfying (a), hence (b): two
   tilings with no common vertex. So PPVC(`sigma`) fails.

`square`

**Remarks.**

- `𝔅` is finite. The offsets with `|w_m| <= R_m` are finitely many.
  Descendants keep `|t| < ell_max`, and by the recursion in step 1 their
  contracting conjugates stay bounded. The points of `Z^3` with all three
  embeddings bounded are finitely many, because the Minkowski image of
  `Z⟨ell⟩` is a lattice.
- A larger start set changes no verdict. Step 3 turns any offset-zero-free
  vertex reached from it into a genuine counterexample. So the start set
  needs only to contain the box, and the implementation enumerates a
  superset.
- The same graph gives a uniform depth. Among the vertices on cycles, let
  `K_V` be the largest first left-aligned depth. Every periodic pair of
  §1, for every `r`, shares a vertex within `K_V` levels of its common
  centre's overlap.
- The finite-graph principle is that of the Akiyama–Lee overlap algorithm.
  It decides overlap coincidence (hence pure discrete spectrum) on the
  overlaps of legal tilings. Proposition V applies the same principle to a
  weaker target, offset zero rather than coincidence. Its vertices are the
  integral offsets, and its equivalence with the periodic-pair statement goes
  through Theorem B. No new literature is relied on; see
  `p1b-strict-zipper-literature-gate-2026-09-21.md` §5 for Akiyama–Lee.

## 3. Exact certificate (`psc.vertex_coincidence`)

- **Radii.** Every bound is a rational upper bound of a real algebraic
  number, certified by exact sign tests at isolated roots of the
  characteristic polynomial (`psc.real_root_sign`):
  - at a real root, `|sigma_k(x)| < q` iff `q − x` and `q + x` are positive
    there;
  - for a complex pair, `|varsigma(x)|^2 = N(x)/x`, and `q^2 > N(x)/x` iff
    `q^2 x − N(x)` has the sign of `x` at `beta`.

  `mu_k` is refined until its bound is below 1, and the trace-dual basis is
  solved over `Q`.
- **Start set.** The two coordinates with the smaller radii are looped over.
  The third is solved for: `t` increases with it, so the slab
  `−ell_max < t < ell_max` is an integer interval, found by exact monotone
  sign scans. Each `(i, j)` is kept when the overlap is interior (exact
  test). No floating value is used anywhere.
- **Verdict.** The closure is `build_overlap_graph_from_seeds`, and offset-zero
  reachability is `first_left_aligned_depths`, both the exact kernels of
  `psc.overlap_seed_patch`. A capped closure is reported as capped.
- **Cross-check.** A floating-point oracle (`box2.py` in `archive/2026-10-04/session-probes/`, re-run output saved there) builds the box from
  approximate eigenvectors with a different bound and start set. The
  recurrent part (non-coincidence vertices on cycles) and its deepest first
  left-aligned depth do not depend on the start set. They agree exactly with
  the Mojo values: Tribonacci 14 and 3, the cube specimen
  `0 -> 1, 1 -> 222, 2 -> 0222` 1,166 and 17, the golden pump
  `0 -> 1, 1 -> 021, 2 -> 001` 716 and 15. For the cube specimen `K_V = 17`
  equals the `K'` of its seed-patch graph.
- **Regression.** `kernel/tests/test_vertex_coincidence.mojo` pins these values.
  It also checks every integral centre offset of Tribonacci (`r <= 6`) and the
  golden pump (`r <= 4`) against the radii, which tests step 1 against
  Theorem B. It checks that every cycle vertex of the cube specimen's
  seed-patch graph lies in its box graph, and that a capped run gives no
  verdict.

## 4. Census

`kernel/vertex_coincidence_census.mojo` (pixi task `vertex-coincidence-census`)
runs the exact decision on every specimen. It folds in canonical order on
`parallel_fold`, so the result does not depend on the worker count.

| Domain | specimens | PPVC holds for every `r` | capped | largest box graph | recurrent vertices (max / total) | largest `K_V` |
| --- | --- | --- | --- | --- | --- | --- |
| standing corpus (images of length <= 3) | 4,554 | 4,554 | 0 | 249,385 (`6 11 13`) | 2,676 (`4 11 21`) / 1,174,788 | 17 (`1 23 21`) |
| total image length <= 8 | 24,486 | 24,486 | 0 | 1,342,201 (`1 38 56`) | 14,938 (`1 254 4`) / 7,891,548 | 25 (`1 38 56`) |
| images of length <= 4 | 135,990 | 135,990 | 0 | 1,432,357 (`25 84 41`) | 27,692 (`23 12 97`) / 75,080,616 | 26 (`13 57 12`) |

Wall-clock times on 4 workers were 7 and 49 minutes for the first two rows. The
third row ran in 28 resumable slices (`len4 START END`), 5.8 hours in total;
its labels index `image_words_up_to(4)`. Its deepest specimen,
`0 -> 001, 1 -> 0200, 2 -> 000` (`K_V = 26`), has `mu ≈ 0.9651`, well inside
Conjecture UH's `3.2 / log(1/mu) ≈ 90`. `K_V` by regime over this domain:
unimodular, two real conjugates 1:6 2:2118 3:6948 4:5820 5:2742 6:1410 7:324;
unimodular complex pair 1:48 2:3858 3:13266 4:9912 5:3822 6:960 7:252 8:30
9:36 14:12; `abs(det M) > 1` 2:72 3:2460 4:16332 5:19542 6:14574 7:7110
8:3540 9:2874 10:3744 11:5598 12:3648 13:1242 14:1098 15:1068 16:516 17:156
18:108 19:72 20:24 22:84 23:228 24:180 25:132 26:24. Unimodular specimens
still have `K_V <= 9`, apart from 12 at `K_V = 14`, matching the
plastic-number class of the standing corpus. The
floating-point oracle of §3 (`oracle_total.py`, archived) reproduces the standing-corpus row
independently: no failure, 1,174,788 recurrent vertices in total, at most
2,676 per specimen, deepest recurrent depth 17.

*Guarding, row by row.* Each row is an exact run of the committed driver,
but they are not guarded equally:

- **Standing corpus: CI-pinned.** The `vertex-coincidence-census` job of
  `.github/workflows/ci.yml` reruns it and checks every summary line above
  exactly.
- **Two slices: regression-pinned.** `test_census_slices_are_pinned` in
  `kernel/tests/test_vertex_coincidence.mojo` pins the first 300 standing
  specimens and the first 100 specimens with images of length at most 4,
  without the parallel fold. Every one holds; the recurrent totals, `K_V` and
  box-graph sizes are pinned.
- **Total length at most 8, and images of length at most 4: recorded runs
  only.** Their wall-clock (49 minutes; 5.8 hours) puts them outside CI. They
  are reproducible with `pixi run vertex-coincidence-census total` and with
  the `len4 START END` slices, and they are not guarded by CI.

*Finite-domain statement.* On the standing corpus, as an exact certificate
guarded by CI: for every PIP substitution on three letters with images of
length at most 3 and every `r >= 1`, any two `Phi^r`-fixed tilings with a
common centre interior to a tile of each and integral centre offset share a
vertex. Hence no strict
zipper is reachable from any swap seed (Corollary B′), and G1 holds by
manuscript Proposition 5.47; the balanced-pair builds already certify G1
there directly. The recorded runs give the same statement for total image
length at most 8, where Remark 3 of the depth note already gives G1, and for
images of length at most 4. In the last domain, 121,320 specimens lie in
neither of the other two. That count comes from a floating-point PIP screen,
`len4_rest.py` (archived, re-run: 135,990 PIP specimens, of which 4554 are
standing and 14,670 have total length at most 8). for them the recorded run is, as far as this repository records,
the only evidence of G1, and it is not CI-guarded. Everywhere the census adds
the periodic-pair statement for **all** `r`, not only the seed-reachable
part, and the uniform depth `K_V`.

## 5. What the data says about a general proof

### 5.1 A sandwich (proved; imports audited 2026-10-04)

*Theorem S.* For PIP `sigma`: pure discrete spectrum ⇒ PPVC(`sigma`) ⇒ G1
for `sigma`.

*Proof.*

- **PDS ⇒ PPVC.** A failure of PPVC(`sigma`) is, by definition, a pair
  `T_A = T(i, P)`, `T_B = T(j, Q) + <ell, w_0>` of §1 with no common vertex,
  hence no common tile. It persists under every `Phi^k`: inflation about 0
  and about the common centre `c` differ by one translation, applied to both
  tilings, and `Phi_c^(rj − k)` for `rj >= k` would carry a common vertex of
  `Phi^k T_A` and `Phi^k T_B` back to one of `T_A` and `T_B`. By Proposition F
  with Theorem R the two tilings lie in one fibre of the maximal
  equicontinuous factor, i.e. they are strongly regionally proximal (Barge
  2013, Theorem 4(6), as recorded in
  `p1b-periodic-pair-fibre-literature-gate-2026-10-02.md` §2). Barge 2015
  (arXiv:1505.04408), item (3) of §1 as recorded there, says pairwise strongly
  regionally proximal, pairwise tile-disjoint tilings `T_1, …, T_r` exist iff
  `r <= cr`; with `r = 2` this gives `cr >= 2`, hence no pure discrete
  spectrum (Barge 2013, Theorem 4(5)).
- **PPVC ⇒ G1.** Corollary B′ with manuscript Proposition 5.47.

`square`

*Import status (audit 2026-10-04).* The first bullet rests on Barge 2013
Theorem 4(5),(6) and Barge 2015 item (3). Their hypotheses are audited in
`coincidence-rank-imports-literature-gate-2026-10-04.md`: a primitive,
non-periodic substitution with Pisot inflation (Pisot family), with no
unimodularity or irreducibility assumption, so every PIP substitution
qualifies, non-unit ones included. An earlier version cited "Theorem 4(3)",
which is not among the recorded items.

*Consequence for the manuscript (applied 2026-10-04).* Theorem S with
Corollary B′ and Proposition 5.47 gives "pure discrete spectrum implies G1
for the all-seed automaton", which the manuscript's former Open Problem 4.24
declined to assert. It is now manuscript Proposition `prop:PDS-implies-G1`,
and, with Corollary FP″ of `formal-productivity-reduction-2026-10-04.md`,
Theorem `thm:seedwise`: pure discrete spectrum gives termination with
coincidence from every seed. Ledger nodes `PDSImpliesRepoG1` and
`PDSImpliesSeedwiseTermination`.

So a failure of PPVC, which Proposition V would detect in finite time, is a
counterexample to the Pisot conjecture for that `sigma`. PPVC holds wherever
pure discrete spectrum is known, for example Barge's class of substitutions
injective on initial letters and constant on final letters, and Pisot
`beta`-substitutions; there G1 also follows, but only through Theorem S
itself.

### 5.2 Mechanisms the data rules out (exploratory)

A floating-point miner (`mine.py`, `mine2.py`, archived with outputs) was run on the box graphs of the three
named specimens. It searched for a local reason why every vertex reaches
offset zero, because a provable local reason would close the problem. Three
candidates fail.

- **One-step descent of the contracting size.** Candidate: every
  non-offset-zero recurrent vertex has a child with smaller
  `sum_k |sigma_k(t)|^2` (or smaller `max_k |sigma_k(t)|/B_k`). This fails on
  234 of the 1,166 recurrent vertices of the cube specimen and on 140 of the
  716 of the golden pump. A smaller descendant always exists within 5 levels
  there, but that is implied by reaching offset zero and is no mechanism.
- **Endpoint hitting.** Candidate: the first common vertex is an endpoint of
  the vertex's region, i.e. it is reached along the leftmost or rightmost
  child chain. This holds for all 14 recurrent vertices of Tribonacci and for
  1,053 of the 1,166 of the cube specimen, but only for 8 of the 716 of the
  golden pump. The common vertex is in general interior, consistent with the
  six-edge affine pump on that specimen
  (`p1-overlap-affine-pump-2026-09-15.md`).
- **Magnitude plus a constant.** Candidate: the first-hit depth is at most
  the contracting lower bound `m_0(t)` of manuscript Proposition 5.42 plus a
  uniform constant. On the seed-patch graphs of the corpus the excess
  `b − m_0` already reaches 14
  (`overlap-finiteness-and-coincidence-density-2026-09-13.md`), so no small
  uniform constant is visible.

### 5.3 Where the depth sits (exact census)

`K_V` by specimen over the standing corpus, split by arithmetic regime
(`vertex_coincidence_census.mojo`):

| Regime | `K_V`: specimens |
| --- | --- |
| unimodular, two real conjugates | 2:108 3:198 4:234 5:102 6:6 |
| unimodular, complex pair | 2:210 3:612 4:588 5:336 6:120 7:84 8:18 14:12 |
| `abs(det M) > 1` | 4:24 5:138 6:252 7:288 8:360 9:228 10:192 11:120 12:36 13:48 14:72 15:120 16:36 17:12 |

Unimodular specimens have `K_V <= 8`, apart from one class of 12 with
`K_V = 14`. Non-unimodular specimens reach 17. A first reading put the extra
depth in the `M`-adic coordinates. §§5.4–5.5 show that the contraction rate
explains it better, in both regimes.

### 5.4 Excess over the contracting bound (exact census)

`vertex_excess_census.mojo` compares, on every non-coincidence cycle vertex
of every box graph, the first left-aligned depth `b` with the contracting
lower bound `m_0` of manuscript Proposition 5.42. It checks `m_0 <= b`
everywhere. Specimens by maximal excess `b − m_0`:

| Regime | largest `m_0` | maximal excess: specimens |
| --- | --- | --- |
| unimodular, two real conjugates | 4 | 0:6 1:120 2:270 3:198 4:54 |
| unimodular, complex pair | 3 | 1:246 2:600 3:576 4:324 5:126 6:78 7:18 12:6 13:6 |
| `abs(det M) > 1` | 9 | 2:12 3:108 4:240 5:354 6:432 7:264 8:168 9:108 10:78 11:96 12:42 13:18 14:6 |

The 12 unimodular specimens with excess 12–13, and `K_V = 14`, are one
relabelling and reversal class: `0 -> 1, 1 -> 2, 2 -> 01` and its images, with
characteristic polynomial `x^3 − x − 1`. Their Perron root is the plastic
number, the smallest Pisot number. Their complex conjugates have modulus
`mu ≈ 0.8688`, the slowest contraction in the unimodular corpus.

### 5.5 An empirical law: depth is set by the contraction rate

Let `mu = max_k |sigma_k(beta)|` be the slowest contraction. For a complex
pair, `mu^2 = abs(det M)/beta`, so a determinant above 1 slows contraction.
Over the standing corpus (floating-point oracle `law.py` with `law_stats.py`, archived; it reproduces
the exact `K_V` of every specimen):

- `K_V · log(1/mu)` lies in `[0.441, 3.164]`;
- the correlation of `K_V` with `1/log(1/mu)` is `0.923`;
- every specimen with `K_V >= 15` has `mu ≈ 0.9387`, and every specimen with
  `K_V <= 3` has `mu <= 0.802`.

So the first common vertex of every cycle vertex appears within about three
e-foldings of contraction, `K_V <= 3.2 / log(1/mu)`, in every regime. The
determinant matters only through `mu`, and the plastic-number class is the
unimodular extreme of the same law.

*Conjecture UH (uniform hitting scale).* There is an absolute constant `c`
such that for every PIP `sigma` on three letters,
`K_V(sigma) <= c / log(1/mu(sigma))`. The standing corpus is consistent with
`c = 3.2`.

UH implies PPVC, hence G1, and adds an explicit depth. It is stated so that
it can be refuted by one specimen. Its form says which kind of proof to look
for: a contracting-space argument at a fixed scale relative to the
contraction. Concretely, once a cycle vertex's contracting offset has shrunk
by a fixed factor `e^{−c}`, its region must contain a common vertex. That is
a uniform covering statement for the Rauzy-type sets of the box graph, at
one scale. It is not a statement about arbitrarily fine scales, which is
where the density arguments of the stop list fail.

### 5.5a Depth laws checked exactly on images of length at most 4

`vertex_coincidence_census.mojo len4 START END records` printed the exact
`K_V` of each of the 135,990 specimens with images of length at most 4, in 28
slices (every specimen holds, none capped). `vertex_depth_law.mojo FILE 4`
(kernel `psc.depth_law`) judges each record against a law
`K_V <= a + c / log(1/mu)`, exactly:

- `mu^2` is enclosed in a rational bracket: `abs(det M) / beta` for a complex
  pair, the larger squared real conjugate otherwise. Both come from
  isolating intervals of the characteristic polynomial, refined by exact
  bisection.
- For `K_V > a` the law is `(mu^2)^(K_V − a) >= (e^(−c))^2`, tested against a
  rational bracket of `e^(−c)`.
- A specimen not decided within 80 bisections is reported as undecided and
  counted as neither verdict.
- `tests/test_depth_law.mojo` pins a violator, two holding specimens and a
  hypothetical failure of the affine law.

Result (3 min 48 s):

| law | holds | violates | undecided |
| --- | --- | --- | --- |
| `K_V <= 3.2 / log(1/mu)` | 134,484 | 1,506 | 0 |
| `K_V <= 4 / log(1/mu)` | 135,918 | 72 | 0 |
| `K_V <= 7 + 1/log(1/mu)` | 135,990 | 0 | 0 |

*Reading.*

- Conjecture UH asserts that **some** absolute constant `c` works. These
  counts reject the standing-corpus calibration `c = 3.2` and also `c = 4`,
  but UH itself stays open: no finite domain can refute an existential
  constant.
- `tests/test_depth_law.mojo` pins `0 -> 2220, 1 -> 100, 2 -> 0012`, with
  `K_V = 6` and `mu ≈ 0.51`, as a violator of both ratio laws. Fast
  contraction with a depth floor is what defeats a pure ratio `c / log(1/mu)`.
- The affine form survives on this domain. *Empirical envelope E7*:
  `K_V <= 7 + 1/log(1/mu)` holds on all 135,990 specimens, exactly
  certified.
- E7 is recorded as an observation, **not** as a conjecture. Stating it as
  a universal invariant needs the targeted literature stop/go check of
  `AGENTS.md` first, which has not been done.
- An earlier draft of this section tabulated floating-point estimates of
  the envelope constant for each offset and extrapolated an equality beyond
  the offsets shown. Those estimates came from `uhan.py`, now archived with
  its output, and are withdrawn; the exact counts above replace them.

### 5.5b Targeted search where contraction is slowest (exploratory sample)

A strict zipper, and with it a counterexample to the Pisot substitution
conjecture for its substitution (Theorem S), is most plausible where `mu` is
close to 1. `vertex_coincidence_targeted.mojo 5 39 40 40` selects, exactly,
the PIP substitutions with images of length at most 5, a complex contracting
pair and `mu^2 = abs(det M)/beta > (39/40)^2`. There are 40,680 of them, and
none have `mu > 0.98`. It decides PPVC on a deterministic sample of every
40th candidate in canonical order, 1,017 specimens, with the state cap
4,000,000 per box graph:

```text
decided: 1017  holds for every r: 993  capped: 24  fails: 0
deepest K_V: 39 specimen 17 135 239  largest box graph: 3995093
```

(96 minutes on 4 workers.) No sampled specimen fails. The 24 capped
specimens are inconclusive at this state cap and are not verdicts. The
deepest specimen is `0 -> 012, 1 -> 00120, 2 -> 11102` (labels index
`image_words_up_to(5)`), with `K_V = 39`. `vertex_depth_law.mojo` certifies
exactly that it satisfies all three laws of §5.5a, envelope E7 included.

This is a sample, labelled as such, and not a census. It says nothing about
the other 39,663 candidates or about the 24 capped ones.

### 5.6 Working the argument: cancellation, not shrinkage

*Lemma D (discreteness, proved).* There is `epsilon_0(sigma) > 0` such that
an overlap `(i, j, t)` with `|sigma_k(t)| < epsilon_0` for every contracting
`k` has `t = 0`.

*Proof.* `|t| < ell_max` for every overlap. The Minkowski image of `Z⟨ell⟩` is
a lattice in `R^3`, so only finitely many offsets have all three embeddings
bounded. Take `epsilon_0` below the smallest nonzero contracting size among
them. `square`

So a vertex hits exactly when some descendant enters the
`epsilon_0`-ball in the contracting coordinates. Conjecture UH would follow if
contracting sizes shrank geometrically along some descendant path. That would
give depth about `L = log(B/epsilon_0) / log(1/mu)`, where `B` is the largest
contracting size on the recurrent part.

The data rules this mechanism out. On a stride-7 sample of 651 corpus
specimens (`mine3.py`, archived with output), `K_V − L` ranges from −33.75 to 5.00, and
`K_V / L` from 0.32 to 2.56. For example, `0 -> 22, 1 -> 001, 2 -> 10` has
`L ≈ 49.8` and `K_V = 16`. Hits happen long before the offset is small, by
**exact cancellation**: `beta^m t` lands on a prefix difference
`<ell, pi(q) − pi(p)>` while `|sigma_k(beta^m t)|` is still of order `B`.

The lattice form makes this precise. By Theorem B(3)(c), `(i, j, w)` hits at
depth `m` iff `M^m w ∈ P_m(i) − P_m(j)`. Equivalently, the staircase of
`sigma^m(j)`, translated by `M^m w`, shares a lattice vertex with the
staircase of `sigma^m(i)`. Both staircases lie in strips of `Z^3` along the
expanding line. Their contracting windows differ by
`sigma_k(M^m w) = lambda_k^m sigma_k(w) → 0`.

- **Under pure discrete spectrum.** Each staircase is, up to its boundary,
  every lattice point of its strip whose contracting coordinate lies in its
  window (the model-set property), so two staircases with overlapping
  windows must meet. This is a heuristic picture in the real contracting
  coordinates, not the proof of Theorem S (which goes through fibres and
  coincidence rank); for `|det M| > 1` the true internal space also carries
  an M-adic factor (`p1b-strict-zipper-literature-gate-2026-09-21.md`).
- **Without it.** Each staircase is a proper subset of lattice density
  `1/p` inside the same model set, and meeting is a rigidity question about
  the substitutive hierarchy.

The census says this rigidity holds on every specimen surveyed, and holds
quickly: within about three e-foldings of contraction. A proof has to show
that two such staircases, produced by the same substitution from letters
`i` and `j` and shifted by an integral offset of a cycle vertex, cannot
interleave without a common vertex. That is the strict-zipper exclusion in
its sharpest lattice form. Lemma D and the sample above are what working the
argument has added: the obstruction is exact combinatorial interleaving, not
a size or scale effect.

### 5.6a The plastic-number class and the climb lemma

The 12-specimen outlier class of §5.4 is a model problem. Its box graph has
74 recurrent vertices, and the deepest are all same-letter self-overlaps with
offsets `±beta^{−k}`. For `0 -> 1, 1 -> 2, 2 -> 01`, `(0, 0, (1,1,−1))` has
`t = beta^{−2}` and depth 14, `(1, 1, (−1,0,1))` has `t = beta^{−1}` and depth
13, and `(2, 2, (1,0,0))` has `t = 1` and depth 12 (`plastic.py`, archived
with output; each also appears with the opposite sign).

*Climb lemma (proved).* Let `(a, a, t)` be an overlap and let `c` be a letter
of `sigma(a)`. If `beta |t| < ell_c`, then `(c, c, beta t)` is a child: the
same child on both sides, offset increment `0`. So a same-letter vertex with
`beta^n |t| < ell_min` has a diagonal descendant `(c_n, c_n, beta^n t)`, and
its contracting coordinate is `sigma_k(beta)^n sigma_k(t)`, which shrinks.
Moreover `|N(t)| = |t| prod_k |sigma_k(t)|` takes values in a discrete subset
of `Q`, bounded below on nonzero `t` by some `nu > 0`. On a vertex of the box,
`|sigma_k(t)| <= B_k`, so `|t| >= nu / prod_k B_k`. Hence a same-letter
recurrent vertex climbs to tile scale within
`log(ell_min prod_k B_k / nu) / log beta + 1` levels. For a unimodular complex
pair `log beta = 2 log(1/mu)`, so this is exactly the form of Conjecture UH.
`square`

The climb lemma explains the plastic class: its deep vertices are pure
climbs. It does **not** explain the depth in general. On the stride-7 sample,
the vertex achieving `K_V` is same-letter in only 111 of 651 specimens. The
depth remaining after the climb (`depth − climb`, maximised over recurrent
vertices) has the same distribution as `K_V`. The deepest specimens have
climb 0 or 1, for example `0 -> 210, 1 -> 0, 2 -> 110` with `K_V = 17`. Their
depth comes from cancellation between different letters. So UH has two
parts: a climb part, which is proved, and a cross-letter cancellation part,
which is the open rigidity statement of §5.6.

### 5.6b The rigidity is not a one-tile question (exact census)

Every first common vertex `y` of a recurrent vertex is born in each tiling
at some level, `k_A` and `k_B`. Two cases:

- **catch-up** (`min(k_A, k_B) < max(k_A, k_B)`): one tiling's vertex is
  reached later by the other's subdivision. That is a one-tile question: is
  a given integral offset inside a tile an eventual subdivision boundary?
- **simultaneous birth** (`k_A = k_B`): a genuine two-tile cancellation.

If every recurrent vertex had *some* catch-up hit, at any depth and not
necessarily the first, the cross-letter rigidity of §5.6 would reduce to the
one-tile question (Q1).

*Lemma (catch-up locus, proved).* Take an edge `p -> u` into an offset-zero
child whose common vertex `y` is new. If the top child index is 0, `y` is the
start of `p`'s top tile, so `t_p <= 0` and `y` is `p`'s left region endpoint
(symmetrically for a bottom index 0). Both indices 0 would make `p` itself
offset zero, so `y` would not be new. So a catch-up hit is exactly a step of
`p`'s *leftmost chain* (the child whose region contains `p`'s left end) into
offset zero. With `CU` the set of vertices whose leftmost chain reaches offset
zero, a vertex can reach a catch-up hit iff it has a descendant in `CU`.
`square`

The leftmost chain is a function on vertices, so `CU` and the reachability
are exact finite computations on the box graph (`psc.one_tile`). Right
endpoints are the mirror case. Reversing every image word reverses both
tilings, so a right-endpoint catch-up of `sigma` is a left-endpoint catch-up
of the mirror substitution, read through the vertex map
`(a, b, t) -> (a, b, l_a − l_b − t)`. Mirroring maps edges to edges, so the
two recurrent parts correspond. The counts above exclude offset-zero
vertices, though, and mirroring exchanges left-aligned with right-aligned
vertices. Tribonacci has 14 recurrent vertices on both sides, but 6 of them
are right-aligned and become offset zero in the mirror, which leaves 8 there.
So `two_sided` checks per vertex rather than comparing the two counts.

**Census (exact, standing corpus, `pixi run one-tile-census`).**

| | count |
|---|---|
| specimens | 4554 |
| recurrent vertices (nonzero offset) | 1,154,040 |
| in `CU` | 561,624 |
| reach `CU` | 1,056,816 |
| specimens where Q1 fails | 360 |
| … with no recurrent vertex reaching `CU` | 210 |
| specimens where Q1 fails at both endpoints | 360 |
| … with no recurrent vertex reaching either | 210 |
| catch-up-free (Lemma P) | 210 |
| … of which Q1 fails totally | 210 |
| total failures not catch-up-free | 0 |
| failing vertices outside the catch-up-free class | 348 |
| … short periodic (nonzero closure ≤ 2) | 348 |
| P′ to depth 5 disagrees with catch-up-freeness | 0 |
| Proposition C shape disagrees with catch-up-freeness | 0 |
| … catch-up-free with one odd letter | 18 |

Right endpoints rescue nothing. On every failing specimen the per-vertex
left, right and either counts coincide (116,316 recurrent vertices, 19,092
reaching a catch-up). The first total failure in canonical order is
`0 -> 1, 1 -> 22, 2 -> 012` (label `1 11 17`): none of its 560 recurrent
vertices reaches a catch-up at either endpoint, yet PPVC holds there for
every `r` (§4). Every new common vertex reachable from its recurrent part is
a simultaneous birth. The pinned specimen `0 -> 1, 1 -> 012, 2 -> 010` is
the same (694 recurrent, none in `CU`, none reaching a catch-up at either
endpoint; PPVC holds with `K_V = 14`).
`0 -> 1, 1 -> 12, 2 -> 022` (label `1 8 20`) fails partially: 12 of its 14 recurrent vertices
reach a catch-up, at either endpoint. Both are pinned in
`tests/test_one_tile.mojo`.

The [October 4 occurrence-level enumeration](catch-up-hit-witness-enumeration-2026-10-04.md)
rechecks Q1 directly at both endpoints on every child occurrence. It commits
stable labels for all 97,224 simultaneous-only recurrent nonzero vertices of
the standing domain, with replayable closed-set counterexamples and controls
where a simultaneous first hit conceals another shortest or later catch-up.
The larger-domain runs there are explicitly 1,000-specimen prefix slices.
This supplies inspectable hit witnesses and agrees with the census above;
it does not close #139, UH, G1, general PPVC or PSC.

*Lemma P (arithmetic catch-up obstruction, proved).* Write `ab(u)` for the
abelianisation of a word and `Λ = M Z^3`, a sublattice of index `|det M|`.
If no proper nonempty prefix `u` of an image `sigma(a)` has `ab(u) ∈ Λ`,
then no edge of the overlap graph is a catch-up hit, at either endpoint.
In particular no vertex of nonzero offset lies in `CU`, and Q1 fails on every
recurrent vertex.

*Proof.* Every vertex has an integral offset vector `w`, with
`t = ⟨ell, w⟩`. The child through indices `(i, j)` has offset vector
`M w + ab(P_b(j)) − ab(P_a(i))`, where `P_a(i)` is the length-`i` prefix of
`sigma(a)`. So the child has offset zero iff
`M w = ab(P_a(i)) − ab(P_b(j))`. For a catch-up one index is 0 and the other,
say `j`, satisfies `0 < j < |sigma(b)|`, so `ab(P_b(j)) ∈ Λ`. That is
excluded. For right endpoints, `ab(suffix) = M e_a − ab(prefix)` is in `Λ`
iff the prefix is. `square`

When `M` is unimodular, `Λ = Z^3`, so Lemma P never applies. When
`|det M| = 2` and every proper prefix lies in the nontrivial class of
`Z^3 / Λ ≅ Z/2`, every difference of two proper prefixes lies in `Λ`. Hits are
then possible, but only as simultaneous births.

*Proposition P′ (levels are arithmetic, proved).* Call a vertex of
`sigma^n(a)` of *exact level* `k` if it is a boundary of the level-`k`
supertiles but not of the level-`k + 1` ones, and place it at the
abelianisation `v` of the prefix before it. Then `sigma` is catch-up-free iff
every such vertex has `max{k' : v ∈ M^{k'} Z^3} = k`, for every `n` and `a`.
In other words, the level of a vertex is the M-adic valuation of its position.

*Proof.* (⇒) An exact-level-`k` vertex sits at `v = M^{k+1} u + M^k ab(p)`,
with `p` a proper nonempty prefix of an image. Since `M` is injective,
`v ∈ M^{k+1} Z^3` iff `ab(p) ∈ Λ`, which catch-up-freeness excludes, and
`v ∈ M^k Z^3` always. (⇐) A proper prefix `p` with `ab(p) ∈ Λ` gives a
level-0 vertex of valuation at least 1. `square`

So in the catch-up-free class the hierarchy is read off the non-Archimedean
coordinate of the position. This also gives a second proof that every hit
there is a simultaneous birth. By Theorem B(3)(c), a hit of `(i, j, w)` at
depth `m` is a vertex with position `v` in `sigma^m(i)` and `v − M^m w` in
`sigma^m(j)`. Both levels are below `m`, while `M^m w` has valuation at least
`m`. Since the lattices `M^k Z^3` are nested, the two valuations, which are
the two levels, are equal. The census checks P′ exactly to
depth 5 on every specimen: it holds on exactly the 210 catch-up-free ones.

*Proposition C (the class in words, proved).* Call a nonempty letter set `O`
*odd*. If every image is either a single letter outside `O`, or an `O`-letter,
then letters outside `O`, then an `O`-letter, then `sigma` is catch-up-free.
When `|det M| = 2` the converse holds, and `O` is unique.

*Proof.* Let `f(v) = sum_{c in O} v_c mod 2`. Under the shape, every column
has `f = 0`, so `Λ <= ker f`. Every proper nonempty prefix has `f = 1`, so it
is not in `Λ`. Conversely, if `|det M| = 2` then `Z^3 / Λ ≅ Z/2`, so
`Λ = ker f` for a unique nonzero `f`, which defines `O`. If every proper prefix
has `f = 1`, then in an image `x_1 ... x_L` with `L >= 2`, `f(x_1) = 1`. Each
`f(x_2), ..., f(x_{L−1})` is 0, as a difference of two odd prefixes. Then
`f(x_L) = 1`, because the column is even. An image of length 1 is a column,
so its letter is even. `square`

So in a catch-up-free tiling, odd tiles occur only as the first and last
tiles of level-1 supertiles. A vertex is a level-1 boundary exactly when an
even number of odd tiles separate it from a level-1 reference vertex, which
is P′ at level 1 in combinatorial form. The census finds a unique such `O` on
exactly the 210 catch-up-free specimens, and on no other. In 192 of them
`|O| = 2` (e.g. `0 -> 1, 1 -> 22, 2 -> 012` with `O = {0, 2}`), and in 18
`|O| = 1` (e.g. `0 -> 1, 1 -> 22, 2 -> 202` with `O = {2}`).

*The M-adic completion.* Assume `|det M| >= 2`. This holds throughout the
catch-up-free class, since Lemma P is void when `Λ = Z^3`. When `M` is
unimodular, `M^n Z^3 = Z^3` and what follows degenerates. Let
`v(x) = sup{n : x ∈ M^n Z^3}` for
`x ∈ Z^3`. The lattices `M^n Z^3` are nested, so `v` is ultrametric:
`v(x + y) >= min(v(x), v(y))`, with equality when `v(x) ≠ v(y)`. Since `M`
is injective, `v(M x) = v(x) + 1`. Moreover `∩_n M^n Z^3 = 0`. To see this,
identify `x` with `ξ = ⟨ell, x⟩` in the full-rank module `Z⟨ell⟩ ⊂ Q(beta)`.
Then `M^{−n} x` corresponds to `beta^{−n} ξ`. The norms of nonzero elements
of a finitely generated full-rank module lie in `(1/q) Z \ {0}` for some
fixed `q`. If `x ≠ 0` and `M^{−n} x ∈ Z^3` for every `n`, then
`|N(beta^{−n} ξ)| = |N(ξ)| / |det M|^n` tends to 0, which is a contradiction.
So `v(x) = ∞` iff `x = 0`. Let `Ẑ_M = lim Z^3 / M^n Z^3` be the completion. It is complete
and Hausdorff, `Z^3` embeds in it, and `v` extends to it.

Positions are compared only through differences. Two vertices `y, z` of
one σ-tiling differ by the abelianisation `D(y, z) ∈ Z^3` of the word
between them. If two tilings lie in one fibre (Proposition F), their vertex
positions lie in one coset `x + Z⟨ell⟩`. Since `ell` has rationally
independent entries, every difference of vertex positions across both
tilings is then `⟨ell, D⟩` for a unique `D ∈ Z^3`. So all vertices of both
tilings live in one torsor `A` under `Z^3`, which completes to a torsor `Â`
under `Ẑ_M`. One should not use rational coordinates instead, such as the
rational fixed point `(I − M^r)^{−1} E` of an inflation. Its denominator
`det(I − M^r)` can be even, and `v` is not defined there. The argument below
uses only differences and completeness.

*Proposition P″ (M-adic centres, proved).*
(a) Every σ-tiling `T` has an *M-adic centre* `c_T ∈ Â`: for any vertices
`z_n` of `T` with `level_T(z_n) >= n`, `c_T = lim z_n`. If `σ` is
catch-up-free, then `level_T(y) = v(y − c_T)` for every vertex `y` of finite
level, and a vertex of infinite level equals `c_T`.
(b) If `T, T′` are `Φ^r`-fixed with a common centre and lie in one fibre,
then `c_T = c_{T′}`.
(c) Hence, for catch-up-free `σ`, every common vertex of such a pair has
the same level in both tilings. The M-adic coordinate cannot by itself
exclude a common vertex, so P′ alone does not rule out a strict zipper.

*Proof.* (a) Between two vertices of level `>= n` lie whole level-`n`
supertiles, and each has abelianisation `M^n e_c`. So
`v(z_n − z_m) >= min(n, m)`. The sequence is Cauchy, and any two such
sequences interleave, so the limit does not depend on the choice. Now let
`σ` be catch-up-free and `level_T(y) = k < ∞`. Then `y` is interior to a
level-`(k+1)` supertile starting at some `s`, and `y = s + M^k ab(p)` for a
proper nonempty prefix `p`. So `v(y − s) = k`, as in P′. For `n > k`,
`v(z_n − s) >= k + 1`, hence `v(y − z_n) = k`. Since
`v(z_n − c_T) >= n > k`, we get `v(y − c_T) = k`. If `y` has infinite level,
`v(y − z_n) >= n` for every `n`, so `y = c_T`.
(b) The real map `x -> beta^r x` about the common centre sends vertices of
each tiling to vertices of the same tiling. On the common coset it acts by
the same affine map `F(y) = F(y_0) + M^r (y − y_0)` for both tilings. `F`
extends to `Â` and satisfies `v(F(y) − F(y′)) = v(y − y′) + r`, so it is a
strict contraction of a complete ultrametric space. Its fixed point is
therefore unique. `F` raises levels by `r` (recognizability), so it maps a
sequence `z_n` of increasing level to another such sequence, and `F(c_T) = c_T`.
Likewise `F(c_{T′}) = c_{T′}`, so `c_T = c_{T′}`.
(c) A common vertex `y` has `level_T(y) = v(y − c_T) = v(y − c_{T′}) =
level_{T′}(y)`. `square`

So the tempting route "different M-adic centres force disjoint vertex sets"
is closed. The centres always coincide. Part (c) re-derives the
simultaneous-birth property of the catch-up-free class (Lemma P), and also
shows that the non-Archimedean coordinate carries no further obstruction. A
proof of case 3 has to use the order structure on the real line, not the
M-adic arithmetic alone. Parts (a) and (b) need only `|det M| >= 2`, not
catch-up-freeness.

*Route check (2026-10-04).* I read the M-adic picture against Baker, Barge and
Kwapisz, *Geometric realization and coincidence for reducible
non-unimodular Pisot tiling spaces*, Ann. Inst. Fourier 56 (2006), §§1, 4
and 6. They realise the tiling flow of any Pisot substitution on the
inverse limit `T_A` of the torus under `A`. For `|det A| > 1` that limit
carries exactly the non-Archimedean coordinate in which P′ reads levels.
Their Geometric Coincidence Condition (Def. 4.1: `cr_phi = 1`, where
strands are coincident iff some `Phi^k` images share a labelled edge) is
decidable per substitution and equivalent to pure discrete spectrum
(Thms 4.2 and 5.1). Thm 6.1 is a criterion for it. It is proved
unconditionally only for a class of `beta`-substitutions (Thm 7.1). So the
paper gives the setting for case 3 below, but no unconditional argument. Its
coincidence is labelled-edge coincidence, which implies vertex coincidence,
and reaching it would be stronger than PPVC. Like the (W) check in §5.7,
this is a dictionary entry, not a route that bypasses pure discrete
spectrum. Lemma P and P′ themselves were not found there in this form.

On the standing corpus Lemma P is exact (`catch_up_free`, checked in the
census). It applies to precisely the 210 total failures, all of them with
`|det M| = 2`. Every total failure is catch-up-free, and the census checks
that no catch-up-free specimen has a vertex in `CU`. The converse, that a
total failure must be catch-up-free, is observed, not proved. The 150
partial failures, 102 of them unimodular, are not arithmetic: in each, some
prefix lies in `Λ`. They are instead degenerate. The census finds 348
failing recurrent vertices outside the catch-up-free class, and every one is
a *short periodic vertex*: its forward closure, offset-zero vertices
excluded, is the vertex itself (a fixed point of the inflation) or a 2-cycle.
Its other children all have offset zero, and since PPVC holds, it hits within
two levels. For example, in `0 -> 1, 1 -> 12, 2 -> 022` the two failing
vertices `(1, 2, (0, 2, −1))` and `(2, 1, (0, −2, 1))` each have one nonzero
child, themselves, and one simultaneous-birth child `(2, 2, 0)`. Lemma P also
explains the left–right coincidence for total failures. For partial failures
that coincidence remains unexplained.

So the one-tile reduction is false in general, at either endpoint. On the
corpus every recurrent vertex falls into one of three cases, decided exactly:

1. it reaches a catch-up hit (Q1), so a one-tile argument applies;
2. it is short periodic and hits within two levels;
3. its specimen is catch-up-free (Lemma P), so all of its hits are
   simultaneous births.

Cases 1 and 2 cover every specimen outside the arithmetic class. The
trichotomy is a census fact, not a theorem: nothing yet shows that a
non-short vertex of a non-catch-up-free substitution must reach `CU`. A
proof of PPVC along these lines needs that statement and the case-3
question below. Case 3 is the sharp form of §5.6's interleaving question:
two-tile cancellation, where both tilings acquire the common vertex at the
same level. For the catch-up-free class, the
interleaving question is exactly whether a simultaneous birth
`M w = ab(P_a(i)) − ab(P_b(j))`, with `i, j > 0`, is reachable from every
recurrent vertex.

### 5.6c Case 2 needs no PPVC; the two missing statements (2026-10-04)

*Mass lemma (proved).* Write `|x|` for the length of the overlap interval of
a vertex `x`. The children of `x` partition the inflated overlap, so
`sum_{y child of x} |y| = beta |x|`, children counted with multiplicity.

- On a nonempty finite set `Y` of nonzero-offset vertices closed under
  children, the positive vector `(|x|)` satisfies `N_Y (|x|) = beta (|x|)`,
  so `rho(N_Y) = beta`. Since `beta` has degree 3, `|Y| >= 3` (compare the
  manuscript's overlap-rank corollary).
- Let `x` be short periodic: its forward closure `S`, offset-zero vertices
  excluded, has at most two vertices (self-loops and multiple edges allowed).
  If no vertex of `S` had an offset-zero child, `S` would be such a `Y` with
  `|S| <= 2`, which is impossible. So some vertex of `S` has an offset-zero
  child, and every vertex of `S` reaches it, so `x` hits within two levels.
  For a fixed point with `k` self-loops the offset-zero mass is
  `(beta − k)|x| > 0`, since `beta` is not an integer.

`square`

*Correction 2026-10-04 (audit F8):* an earlier version handled only the
fixed point and the 2-cycle without self-loops or multiplicities; the
degree argument above covers every closure of size at most two.

So case 2 of §5.6b holds unconditionally: a short periodic vertex hits
within two levels by mass alone, not because PPVC holds. The census
trichotomy therefore reduces PPVC to two statements, neither proved. Here,
as in §5.6b, "recurrent vertex" means a vertex on a cycle with **nonzero**
offset (1,154,040 on the standing corpus); §§3–4 count aligned cycle vertices
too (1,174,788).

- **T1 (catch-up reachability).** If `sigma` is not catch-up-free, every
  recurrent vertex that is not short periodic reaches `CU`. A vertex of `CU`
  reaches offset zero along its leftmost chain, so T1 with the mass lemma
  gives BH outside the catch-up-free class.
- **T2 (simultaneous birth).** If `sigma` is catch-up-free, every recurrent
  vertex has a descendant `(i, j, w)` with an offset-zero child through indices
  `(p, q)`, both positive: `M w = ab(P_a(p)) − ab(P_b(q))`.

T1 and T2 together with the mass lemma give PPVC, hence BH
(`formal-productivity-reduction-2026-10-04.md`) and G1.

*Structure of the `CU` failures (2026-10-05).* The leftmost child is a
*function* on nonzero-offset vertices, so `CU` is the set of vertices whose
leftmost orbit leaves the nonzero offsets and its complement is the basin of
that function's terminal cycles. Proposition LC of
[`p1b-leftmost-chain-periodic-pair-2026-10-05.md`](p1b-leftmost-chain-periodic-pair-2026-10-05.md)
proves that every such cycle keeps one offset sign and is a **prefix-vs-interior**
periodic pair: a prefix occurrence `sigma^r(i) = i U` on the side whose tile
starts later, an interior occurrence `sigma^r(j) = Q j V` on the other, and
`w_0 = (I − M^r)^{-1} ab(Q) ∈ Z^A`. It is the half-degenerate companion of
Theorem B, where both occurrences are interior. This restructures T1 — by its
Corollary LC2 "reaches `CU`" is an invariant of the box graph's strongly
connected components, so T1 is an SCC-level statement — but it does **not**
prove T1: the reachability half remains a pointwise hitting problem of the
`AdelicPeriodicOffsetHitting` kind. T2 is untouched.

*Falsification test on a larger domain (exact census).*
`pixi run one-tile-census total` surveys the 24,486 specimens of total image
length at most 8 (104 minutes on 4 workers):

| | count |
| --- | --- |
| recurrent vertices (nonzero offset) | 7,796,496 |
| in `CU` / reach `CU` | 3,129,864 / 7,362,240 |
| specimens failing Q1 / totally | 1,326 / 654 |
| catch-up-free specimens, all failing Q1 totally | 654 |
| total failures not catch-up-free | 0 |
| P′ (to depth 5) iff catch-up-free, mismatches | 0 |
| Q1-failing vertices outside the catch-up-free class / short periodic | 1,572 / 1,572 |
| trichotomy exceptions | 0 |

The trichotomy, and the observation that every total failure is
catch-up-free, survive on a domain about five times the standing corpus.
Right endpoints again rescue nothing: every Q1-failing specimen fails at both
endpoints.

### 5.6d A non-Archimedean local mechanism for T2 fails (exact census)

In the catch-up-free class levels are M-adic valuations (P′), so the
non-Archimedean analogue of §5.2's refuted contracting-size descent is the
natural local candidate. Write `nu(w) = max{k : w in M^k Z^3}` for the
offset vector of a vertex.

*Valuation ascent* (VA): every nonzero-offset descendant of a recurrent
vertex has a child of offset zero or of strictly larger valuation. Nonzero
offsets of the box graph are finitely many, so `nu` is bounded on them by
some `K_0`, and VA would give T2 within `K_0 + 1` levels. When `|det M| = 2`
and every proper prefix is in the nontrivial class, a child through indices
`(p, q)` lies in `M Z^3` exactly when `p, q` are both zero or both positive;
then `nu(w') = 1 + nu(w + e)` with `M e` the prefix difference, so VA is a
cancellation condition modulo `M^(nu(w) + 1)`.

`kernel/valuation_ascent_census.mojo` (kernel `psc.valuation_ascent`) decides
VA exactly on the box graph of every catch-up-free specimen of the standing
corpus:

| | count |
| --- | --- |
| catch-up-free specimens | 210 |
| nonzero-offset descendants of recurrent vertices | 126,396 |
| one-step VA failures | 57,540 |
| specimens where one-step VA holds | 0 |
| failures by valuation | `0:23184 1:15984 2:9456 3:4212 4:2640 5:1488 6:516 7:60` |
| specimens by `K_0` | `3:6 4:72 5:54 6:66 7:12` |
| specimens by largest ascent depth | `3:6 4:24 5:36 6:18 7:6 8:42 9:18 10:24 11:18 12:6 14:12` |

On the 24,486 specimens of total image length at most 8 the class has 654
members, and VA again holds on none: 311,952 of 605,280 vertices fail, at
every valuation 0..7, with ascent depth up to 25.

VA fails on every specimen. The failures at `nu = 0` are vertices with no
child whose two indices are both positive; the rest are spread over every
valuation. The ascent depth (least depth to offset zero or larger valuation)
reaches 14, at the scale of `K_V` itself, so a k-step variant would only
restate PPVC. `tests/test_valuation_ascent.mojo` pins
`0 -> 1, 1 -> 22, 2 -> 012`: 368 of 826 vertices fail, ascent depth 14,
`K_0 = 6`.

So neither Archimedean nor non-Archimedean size decreases locally. With §5.6
this places T2 where the rest of this note places PPVC: in exact interleaving
of the two hierarchies, which needs a non-local argument.

### 5.6e T2 via adelic coverage: an attempt (2026-10-04)

*Lemma E (proved).* Let `|det M| = 2`, so `Z^3 / M Z^3 = Z/2`, and call a
letter `c` an *E letter* if `e_c` is not in `M Z^3` and a *Z letter*
otherwise. Then `sigma` is catch-up-free iff every image of length at least 2
has the form `E Z* E`. (An image of length 1 is automatically a Z letter:
`e_c = M e_a` lies in `M Z^3`.)

*Proof.* The class of a prefix is the number of its E letters mod 2. Write
`s_p` for the class of the length-`p` prefix of `sigma(a)`, `n = |sigma(a)|`:
`s_0 = 0` and `s_n = 0`, since `ab(sigma(a)) = M e_a`. Catch-up-free means
`s_p = 1` for `0 < p < n`. For `n >= 2` this forces the first letter to be E,
the letters at positions `1..n-2` to be Z, and the last to be E; for `n = 1`
it forces `s_1 = 0`, a Z letter. The converse is the same computation.
`square`

*Note (2026-10-04 merge):* Lemma E is Proposition C of §5.6b, found
independently on `main`, with the E letters as the odd set `O`. The two
censuses agree: `|E| = 2` on 192 corpus specimens (`156 + 36`), `|E| = 1` on 18
(`12 + 6`). Proposition C's forward direction needs no determinant hypothesis.

`psc.valuation_ascent.lemma_e_shape` decides the shape, and
`valuation_ascent_census.mojo` checks it against `catch_up_free` on every
`|det M| = 2` specimen: 0 mismatches on the 1,926 of the standing corpus and
the 12,672 of total length at most 8. The class is not
confined to `|det M| = 2`: on the standing corpus all 210 catch-up-free
specimens have it, but of the 654 of total length at most 8 only 570 do, and
Lemma E says nothing about the other 84. On the standing corpus the 210 catch-up-free specimens
split by (number of E letters, number of length-1 images) as `(2, 0): 156`,
`(2, 1): 36`, `(1, 1): 12`, `(1, 0): 6`. With two E letters the hierarchy is
read off a parity: a cut is a level-0 vertex iff an odd number of E letters
precedes it, and its exact level is its M-adic valuation (P′).

*Simultaneous births are explicit.* With Lemma E a hit of `(a, b, w)` through
indices `(p, q)`, both positive, is `M w in Delta_{a,b}`, where `Delta_{a,b}`
is the finite set of differences of the vectors `e_x + z`, `x` the leading E
letter and `z` the abelianisation of a proper prefix of the Z-run. T2 asks
that every recurrent vertex has a descendant with `M w` in such a set.

*The adelic setting.* Let `H` be the internal space of the contracting
embeddings times the M-adic completion `Z_M = lim Z^3 / M^k Z^3`. `M` contracts
both factors, so the child maps `w -> M w + d` form a contracting
graph-directed system on `H`, and the closures of the descaled staircases
`P_m(a)` are its attractors `W_a` (adelic Rauzy pieces). A hit of a recurrent
`w` at depth `m` is a common point of the staircases `P_m(i)` and
`M^m w + P_m(j)`, whose windows in `H` are `W_i` and `W_j` shifted by the image
of `M^m w`, which tends to 0.

*Where the attempt stops.* Coverage needs the two staircases to meet once
their windows overlap. That holds when each staircase is the full model set
of its window, i.e. when the pieces `W_a` tile `H` with multiplicity one.
Heuristically, pure discrete spectrum gives this (coincidence rank 1 in the
Baker–Barge–Kwapisz form recorded in §5.6b; Theorem S itself is proved
through fibres, not through windows); the
converse, multiplicity one ⇒ pure discrete spectrum in the non-unit adelic
setting, is not re-verified here and is not used. On the
catch-up-free class T2 is PPVC itself, since every hit there is a
simultaneous birth, so as set up here adelic coverage proves T2 from pure
discrete spectrum (or multiplicity one) and from nothing weaker. The arithmetic of the class does not lower the bar:

- Lemma E fixes the M-adic coordinate of every vertex (its level and
  parity), but says nothing about the multiplicity of the Archimedean
  windows.
- Recoding cannot move the class to the unimodular case on three letters:
  `|det M| = |N(beta)| = 2` is an invariant of the Perron number.
- One-step size arguments fail in both factors of `H` (§5.2 and §5.6d).

*The precise missing statement.* PPVC needs vertex coincidence, not tile
coincidence. What coverage actually uses is weaker than multiplicity one:

> **Vertex-sheet alignment (open).** For a catch-up-free `sigma`, the vertex
> staircases of two letters, shifted by the offset of a recurrent vertex,
> lie in a common sheet of the multiplicity-`p` self-replicating multi-tiling
> of `H`.

Multiplicity one gives it trivially. §5.6f shows that under all-pairs
aligned strong coincidence it is not weaker than tile coincidence of the §1
periodic pairs.

### 5.6f Vertex-sheet alignment collapses to tile coincidence (2026-10-04)

*Lemma VT (proved).* Let `sigma` be PIP with SC_all: each of the six aligned
pairs `(a, b, 0)`, `a != b`, is productive
(`formal-productivity-reduction-2026-10-04.md`). Let `T`, `T'` be
tilings fixed by `Phi^r` about the **same** centre (for some `r >= 1`;
with different periods use their least common multiple). If `T` and `T'`
share a vertex, they share a tile. The §1 pairs qualify after translating
both by the common centre.

*Proof.* Let `x` be a common vertex, and `a`, `b` the tiles of `T`, `T'` that
start at `x`. If `a = b` they share a tile. Otherwise the overlap `(a, b, 0)`
is productive: for some `n` there are prefixes `p` of `sigma^n(a)` and `q` of
`sigma^n(b)` with `ab(p) = ab(q)`, each followed by the same letter `c`. The
coincidence persists under inflation: `sigma^(m−n)(p)` and `sigma^(m−n)(q)`
have equal abelianisations and are followed by `sigma^(m−n)(c)` for every
`m >= n`. Take `k` with `rk >= n`. Since `Phi^(rk)(T) = T`, the tiling `T`
contains `sigma^(rk)(a)` placed at `beta^(rk) x`, and likewise `T'` contains
`sigma^(rk)(b)` there. So both contain the tiles of `sigma^(rk−n)(c)` at
`beta^(rk) x + <ell, M^(rk−n) ab(p)>`. `square`

The argument is elementary and is not claimed new; it is the tiling-space
reading of Proposition FP (1), `D <= L + S(sigma)`: once offset zero is
reached, coincidence follows within `S(sigma)` levels.

*Consequences.*

- Under SC_all, two tilings fixed about a common centre that share no tile
  share no vertex; for arbitrary tilings the same holds with "never" read as
  "under no `Phi^k`". A vertex staircase cannot cross into another sheet:
  vertex-sheet alignment of §5.6e is equivalent to tile coincidence of the
  pair.
- Hence, under SC_all, PPVC(`sigma`) holds iff every pair of §1 (the
  `Phi^r`-fixed tilings `T(i, P)`, `T(j, Q) + <ell, w_0>`) shares a **tile**.
  By the proof of Theorem S such a pair lies in one fibre of the maximal
  equicontinuous factor, and a pair sharing no tile forces coincidence rank
  at least 2 (Barge 2015 item (3) with Barge 2013 Theorem 4(6), as in the proof of Theorem S). So under SC_all a failure of
  PPVC is a failure of tile coincidence in a fibre, not a weaker
  vertex-level phenomenon.
- SC_all holds on the standing corpus (formal productivity holds there), and
  formal productivity requires it in general (Proposition FP). On this
  route there is therefore no vertex-level slack: T2, PPVC and BH are, under
  SC_all, tile-coincidence statements for periodic fibre pairs.

*Decision: redirect.* Under SC_all, vertex-sheet alignment is not weaker than
tile coincidence of the §1 periodic pairs. Whether that periodic-pair tile
coincidence is equivalent to pure discrete spectrum is **not** shown: the
non-PDS periodic pair of Barge 2013 Thm 5 need not have §1 form (its centre
may be a vertex, and integrality of `w_0` is not known for it). *Correction
2026-10-04 (audit F10):* an earlier version said this closes the route around
pure discrete spectrum. The only room left by the vertex/tile distinction is in
substitutions failing SC_all, where formal productivity fails anyway and the
aligned route (#138) is the obstruction. A proof of T2 must establish tile
coincidence for the periodic fibre pairs of §1 directly, which is the
coincidence-rank problem in its periodic form.

### 5.6g Periodic coincidence rank on the catch-up-free class: what the literature already gives (2026-10-04)

§5.6f leaves T2, on the catch-up-free class, as tile coincidence of the
periodic fibre pairs of §1, i.e. a coincidence-rank statement. Before any new
coincidence-rank argument, one existing theorem reaches part of the class.

*The lever.* Barge (2016) proves pure discrete spectrum for primitive,
non-periodic substitutions with Pisot inflation that are injective on initial
letters and constant on final letters (hypotheses as audited in
`p1b-strict-zipper-literature-gate-2026-09-21.md`); reversing every image
gives the mirror class. Pure discrete spectrum is shared by `sigma`, its
powers, and the conjugates `u^{-1} sigma^n u` or `v sigma^n v^{-1}` by a common
prefix `u` or suffix `v` of the images, which have the same tiling space up to
translation. Indeed, if every `sigma(a)` begins with `u`, then
`tau(w) = u^{-1} sigma(w) u` telescopes to `sigma^k(w) u_k = u_k tau^k(w)` for
the iterates, so `tau` has the same language as `sigma` (primitivity), the
same incidence matrix and tile lengths, hence the same tiling space `Omega`
with the same R-action. Primitivity, non-periodicity, Pisot inflation and
pure discrete spectrum transfer; irreducibility and unimodularity are not
among Barge's recorded hypotheses. Any rotation by a nonempty common prefix is
constant on final letters; it lies in Barge's class when the letters following
the maximal common prefix are pairwise distinct (if an image equals the
prefix, its rotation is the prefix itself and its first letter is the
prefix's first letter). Lemma E bears only on whether a nonempty common prefix
exists. A witness gives pure discrete spectrum, hence PPVC (Theorem S), and
on the catch-up-free class PPVC is T2.

`kernel/barge_class_census.mojo` (kernel `psc.barge_class`) searches `sigma^n`,
`n <= 6`, and its maximal left and right rotations, exactly:

| domain | specimens | with a witness | catch-up-free | catch-up-free with a witness |
| --- | --- | --- | --- | --- |
| standing corpus | 4,554 | 1,248 | 210 | 78 |
| total length ≤ 8 | 24,486 | 6,336 | 654 | 174 |

Every witness occurs at power 1 or 2. By Lemma E stratum (`|det M| = 2`):

| `|E|`, number of length-1 images | standing corpus | total length ≤ 8 |
| --- | --- | --- |
| 1, none | 6 / 6 | 6 / 6 |
| 1, at least one | 0 / 12 | 0 / 264 |
| 2, none | 48 / 156 | 48 / 156 |
| 2, one | 24 / 36 | 84 / 144 |
| (`|det M| != 2`) | — | 36 / 84 |

`tests/test_barge_class.mojo` pins Tribonacci (mirror class), the plastic
substitution (no witness) and `0 -> 1, 1 -> 22, 2 -> 012`, the first total Q1
failure of §5.6b, whose square `(22, 012012, 122012)` lies in Barge's class:
T2 holds for it, by Barge's theorem.

*Lemma B (obstruction, proved).* Let `|det M| = 2` and `sigma` catch-up-free
with one E letter `x`. Then no power `sigma^n` lies in Barge's class or its
mirror. (An earlier version also assumed an image of length 1; the proof
never uses it.)

*Proof.* By Lemma E, every image of length at least 2 begins and ends with
`x`, and every image of length 1 is a single letter. So the first-letter map
`g(a)` and the last-letter map `f(a)` of `sigma` coincide, and so do those of
`sigma^n` (`g^n = f^n`). One map on three letters cannot be both injective and
constant. `square`

Rotations are not covered by Lemma B. With a length-1 image the census finds
no rotation witness on either domain (0 of 264 at total length at most 8).
With no length-1 image, `f = g` is the constant `x`, so every witness must be
a rotation, and a rotation by the common prefix succeeds on every specimen
surveyed.

*Where this leaves the coincidence-rank argument.* On the surveyed domains
Barge's theorem settles T2 for 78 of the 210 catch-up-free corpus specimens
and 174 of 654 of total length at most 8. For the rest no conjugacy route is
known, and in the stratum `|E| = 1` with a length-1 image it is blocked for
powers by Lemma B. Those specimens are where a genuine periodic
coincidence-rank argument is needed. No such argument is given here. These
consequences inherit the review status of Theorem S and the import of
Barge (2016).

*Update 2026-10-04:* the specimens without a witness are not open one by one.
SC_all holds on both surveyed domains and PPVC is recorded there, so Proposition
FP and manuscript Theorem `thm:main-density` give pure discrete spectrum for
every one of them (`strong-coincidence-census-2026-10-04.md` §4). What a
coincidence-rank argument is still needed for is the uniform statement.

### 5.6h Anatomy of the one-tile analysis (exact, `pixi run one-tile-anatomy`)

*Numbering (2026-10-04 merge):* §§5.6h–5.6i were §§5.6c–5.6d when written;
the checksummed archive index in `archive/2026-10-04/session-probes/` still
cites them by the old numbers.

These are the side computations behind §5.6b. Each one is exact on every
standing-corpus specimen and is computed by the committed driver
`kernel/one_tile_anatomy.mojo` with `psc.one_tile`. CI pins the output. An
earlier scratch probe gave each of them first. Those probes are archived with
their outputs in `archive/2026-10-04/session-probes/` (§5.6i) and agree with
the driver line by line.

*Q1 failures by spectral class.*

| class | specimens | Q1 fails partially | Q1 fails totally |
|---|---|---|---|
| `|det M| = 1`, real contracting pair | 648 | 48 | 0 |
| `|det M| = 1`, complex contracting pair | 1980 | 54 | 0 |
| `|det M| = 2`, complex contracting pair | 1926 | 48 | 210 |

Every total failure has `|det M| = 2`, as Lemma P requires. Partial failures
occur in all three classes, 102 of them unimodular.

*Closure sizes of the failing vertices.* Outside the catch-up-free class,
the 348 recurrent vertices that reach no catch-up have nonzero forward
closure of size 1 (276 vertices, fixed points of the inflation) or 2 (72
vertices, 2-cycles). None has a larger closure.

*One-step catch-ups (towards the converse of Lemma P).* Of the 4344
specimens that are not catch-up-free, 4170 have a recurrent vertex whose
leftmost child has offset zero. That is a catch-up taken in one step from
the recurrent part, and there are 29,712 such vertices in all. The other 174
specimens have none. Their recurrent vertices still all reach a catch-up,
because none of the 174 fails Q1, but only through a leftmost chain of two
or more steps, or through non-recurrent descendants. A proof of the converse
of Lemma P therefore cannot rely on the explicit one-step vertex
`(a′, b, −M^{−1} ab(p))` being recurrent. The 174 labels, `i/j/k` indexing
the image words as in the census, are:

```
1/2/9 1/2/33 1/2/36 1/8/0 1/8/6 1/9/30 1/9/36 1/10/33 1/10/36 1/11/36 
1/23/0 1/26/0 1/26/3 1/26/6 1/26/21 1/26/24 1/31/21 2/0/10 2/0/31 2/0/37 
2/3/37 2/6/1 2/9/10 2/9/37 2/21/6 2/24/1 2/24/6 2/24/7 2/24/8 2/27/1 2/27/8 
2/30/23 2/30/37 2/36/37 4/2/0 4/5/0 4/17/3 4/17/5 4/20/5 5/0/1 5/0/4 5/3/19 
5/4/16 5/4/19 6/5/33 6/8/21 6/8/27 6/23/0 6/23/21 6/26/0 6/26/15 6/26/21 
6/26/24 6/27/21 6/29/27 7/2/36 7/8/27 7/23/6 7/26/0 7/26/6 7/26/24 8/4/31 
8/6/1 8/24/1 8/24/7 8/26/0 8/27/7 8/29/0 8/29/27 8/33/29 9/0/31 9/0/37 
9/18/37 9/27/4 9/30/10 9/30/31 9/30/33 9/30/37 9/33/10 9/33/34 9/36/37 
10/0/34 10/0/37 10/2/9 10/2/36 10/11/33 10/11/36 10/23/5 10/33/34 10/34/27 
11/0/37 11/9/31 11/9/37 11/24/1 11/33/10 11/36/37 13/2/0 13/2/3 13/2/4 
13/2/5 13/5/0 13/5/3 13/11/0 13/14/0 13/14/3 13/14/5 13/20/0 13/20/5 
13/32/5 14/0/1 14/0/4 14/0/7 14/0/13 14/0/16 14/3/1 14/3/4 14/3/13 14/4/1 
14/4/13 14/4/16 14/4/22 14/5/1 16/2/4 16/17/4 16/17/5 17/0/1 17/3/4 17/4/1 
17/4/16 17/9/8 17/20/5 19/2/0 19/2/5 19/4/16 19/5/3 19/10/6 19/20/5 20/4/19 
20/5/1 20/5/19 21/17/6 23/6/7 23/6/8 23/16/4 23/21/6 23/21/8 26/24/1 
26/24/7 26/24/8 27/20/0 28/10/36 29/6/8 29/19/1 29/23/8 29/24/1 29/24/8 
29/27/8 30/9/19 31/5/20 31/9/30 31/10/9 31/10/30 31/11/9 33/0/16 34/2/17 
34/2/36 34/10/9 34/10/31 34/10/33 34/10/36 35/24/8 37/2/36 37/10/36 
37/11/36
```

Their first images have length 1 (34 specimens), 2 (62) or 3 (78). The
first few are `0 -> 1` with `1 -> 2, 2 -> 20`, `1 -> 2, 2 -> 210`,
`1 -> 2, 2 -> 220`, `1 -> 12, 2 -> 0` and `1 -> 12, 2 -> 10`.

*Diagonal against off-diagonal hits.* A diagonal offset-zero state
`(c, c, 0)` is an exact tile coincidence and is terminal in the box graph.
An off-diagonal one `(c, d, 0)` with `c ≠ d` is a common vertex without a
common tile, and it is expanded further. Counting only paths through
nonzero offsets, so only the first hit counts:

- 1,080,828 of the 1,154,040 recurrent vertices reach a diagonal hit, and
  1,153,308 reach an off-diagonal one;
- on 180 of the 210 catch-up-free specimens every recurrent vertex reaches a
  diagonal hit; on the other 30, 12,276 recurrent vertices reach none.

So "first hit is a tile coincidence" is not a route to case 3 either. Even
outside that class it fails on specimens where PPVC holds. Tribonacci's 14
recurrent vertices all reach an off-diagonal hit first and no diagonal one,
and `0 -> 1, 1 -> 012, 2 -> 010` (694 vertices) does the same. Both are
pinned in `tests/test_one_tile.mojo`.

### 5.6i The session's scratch probes (archived)

Every scratch probe run for §§3–5.6 is archived in
`archive/2026-10-04/session-probes/` with its saved output and a fresh re-run of each. That covers 34
Python files and 5 Mojo probes, `rerun.sh`, the session's census logs, and
`SHA256SUMS`. The index there lists, for each probe, what it computes, its
result, where the note uses it, and the committed driver that supersedes
it. The Python probes are floating-point oracles, not certificates. The Mojo
probes are exact, and `kernel/one_tile_anatomy.mojo` supersedes them. Every
figure this note cites from a probe reproduces exactly on the re-run, in
particular:

- §3: 14/3, 1166/17 and 716/15;
- §4: 1,174,788 recurrent vertices, at most 2,676 per specimen, deepest 17;
- §5.5: `[0.441, 3.164]` and correlation 0.923;
- §5.6: 651 specimens, `[−33.75, 5.00]` and `[0.32, 2.56]`;
- §5.6a: 111 of 651, and the plastic depths 14/13/12;
- §5.6h: all figures.

Two archived results are not cited elsewhere in this note:

- the withdrawn one-witness birth analysis (`birth3.py`): on the stride-7
  sample, 61,854 of 149,412 recurrent vertices have a simultaneous birth as
  the first hit along one minimal path;
- the float Q1 prototype (`onetile_s.py`): on the same sample, 78,406 of
  149,412 vertices are in `CU`, 135,266 reach it, and Q1 fails on 53 of 651
  specimens. This is consistent with the exact census (360 of 4554).

### 5.7 The closing target, restated

The box graph is the carry automaton of the Dumont–Thomas numeration of
`sigma`: offsets are carries, children are digit pairs, and offset zero is a
resolved carry. PPVC(`sigma`) says every recurrent carry can be resolved.
This is the substitution analogue of Akiyama's weak finiteness property (W)
for `beta`-numeration, which Barge proved for every Pisot `beta` by
`beta`-specific monotonicity (`p1b-barge-diamond-configuration-gate-2026-10-02.md`).
The data above says a general proof cannot be one-step, cannot be
endpoint-based, and cannot use a size bound plus a constant number of levels.
It should instead show that carries resolve within a bounded number of
e-foldings of contraction (Conjecture UH). The determinant enters only
through the contraction rate. No such argument is given here.

*Route check (2026-10-03).* Barge's proof of (W) was read in Barge 2018,
§§1, 4 and the end of §5 (arXiv:1505.04408). Property (W) is Corollary 17
there, deduced from Theorem 15 (pure discrete spectrum for every
`beta`-substitution) through Akiyama's equivalence between (W) and pure
discrete spectrum and Barge's Proposition 31. So it is a consequence of pure
discrete spectrum, not an independent numeration argument. Theorem 15 rests
on the monotonicity Properties 1–3 of the `beta`-language, which the
Barge–Diamond gate already stopped. The (W) analogy therefore offers no route
to PPVC that bypasses pure discrete spectrum. It remains a useful dictionary,
not a proof strategy.

## 6. What this does not establish

- PPVC is not proved for all PIP substitutions. For every PIP `sigma` it
  implies G1 for `sigma`, through Corollary B′ and Proposition 5.47. A proof
  for all PIP `sigma` would therefore settle balanced-pair finiteness for all
  three-letter Pisot substitutions. That is the ledger's open G1; in the
  literature it is known for two letters (Hollander–Solomyak) and open beyond.
- Proposition V is a decision procedure, not a uniform bound. Its radii and
  `K_V` depend on `sigma`. A uniform proof would need a reason why the box
  graph of every PIP substitution has no offset-zero-free closed set, which
  is the strict-zipper exclusion itself.
- The census is a finite-domain theorem about the specimens it covers, by
  exact certificate. It says nothing outside them.

## 7. Citation keys (audit 2026-10-04)

The notes use year keys that collide with the manuscript's bibliography:

| Key in these notes | Paper | Manuscript key |
| --- | --- | --- |
| Barge 2013 | *Factors of Pisot tiling spaces and the Coincidence Rank Conjecture*, arXiv:1301.7094 (Bull. SMF 2015) | `Barge2016` |
| Barge 2015 (fibre gate) = Barge 2018 (§5.7) | *The Pisot conjecture for beta-substitutions*, arXiv:1505.04408 (ETDS 2018) | — |
| Barge (2016) (§5.6g) | *Pure discrete spectrum for a class of one-dimensional substitution tiling systems*, DCDS 2016 | — |

