# The seed-patch overlap automaton is finite, and Level 3 without G1

**Status:** theorems with complete proofs (Sections 2–4), an exact finite
census (Section 5), and one precisely stated open bridge (Section 6). Nothing
here proves G1, SCC Producer, or PSC. The results reorganise the programme:
the geometric (overlap) form of Level 3 no longer depends on Hypothesis G1.

Notation follows `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`
("the manuscript"): `sigma` is PIP on `A`, `|A| = d`, `M` its incidence
matrix, `beta` the Perron root, `l > 0` the left Perron eigenvector
(`l^T M = beta l^T`), `g(w) = <l, pi(w)>` the geometric length of a word, so
`g(sigma(w)) = beta g(w)`. A word `w` tiles `[0, g(w))` by the intervals
`[g(w[k]), g(w[k+1]))` of type `w_{k+1}`; a vertex is an endpoint of a tile.
`D_sigma` is the constant of the manuscript's Theorem 4.4 (bounded
discrepancy): the swap walk `Delta(j) = pi(sigma^N(ab)[j]) - pi(sigma^N(ba)[j])`
satisfies `||Delta(j)||_inf <= D_sigma` for all seeds, levels and `j`.

## 1. The seed-patch overlap graph

Fix a seed `(ab, ba)` and a level `N >= 0`. Put `U = sigma^N(ab)`,
`V = sigma^N(ba)`; both tile `[0, L_N)`, `L_N = beta^N (l_a + l_b)`. An
*overlap at level N* is a pair (top tile of `U`, bottom tile of `V`) whose
interiors intersect; its *type* is `(i, j, t)` with `i, j` the tile types
and `t` = start of the bottom tile minus start of the top tile. Inflating
both tiles and keeping the overlapping pairs of their sub-tiles gives the
*children* of an overlap; the type of a child is `(i', j', beta t + q - p)`
with `p, q` the prefix translations of the chosen sub-tiles. A *coincidence*
is a type `(i, i, 0)`; coincidences are terminal.

The *seed-patch overlap graph* `O_sigma` (manuscript Computation 6.7;
canonical implementation `kernel/psc/overlap_seed_patch.mojo`) is the graph on
the types reachable from the level-0 overlaps of the three seeds under the
child relation.

**Lemma 1.1 (occurrence).** Every vertex of `O_sigma` is the type of an
overlap occurring at some level of some swap pair, and every occurring
non-coincidence overlap type is a vertex. (The occurring coincidences that
`O_sigma` omits are exactly the descendants of coincidences, since
coincidences are terminal and every descendant of a coincidence is a
coincidence.)

*Proof.* Level-0 overlaps are the seeds. If an overlap occurs at level `N`,
its children are overlaps at level `N+1` (they are pairs of sub-tiles of the
two inflated tiles). Conversely an overlap at level `N+1` has as parent the
overlap of the level-`N` supertiles containing its two tiles, which overlap
because their sub-tiles do; if the overlap is not a coincidence, neither is
any ancestor, so it descends from a seed through non-coincidence vertices. ∎

## 2. Finiteness

**Theorem 2.1 (finiteness of the seed-patch overlap graph).** Let `sigma` be
primitive with every non-Perron eigenvalue of `M` inside the unit circle
(true for PIP). Every overlap type `(i, j, t)` occurring in a swap pair has
`t = <l, w>` for an integer vector `w` with

```text
||w||_inf <= B_sigma := D_sigma + (l_max + ||l||_1 D_sigma) / l_min .
```

Consequently there are at most `d^2 (2 B_sigma + 1)^d` occurring types, and
`O_sigma` has at most that many vertices, for every such `sigma`, with no
finiteness hypothesis.

*Proof.* Let the overlap consist of the top tile starting at `x = g(U[i])`
(the `i`-th vertex of the `U`-tiling) and the bottom tile starting at
`y = g(V[j])`. Then `t = y - x = <l, w>` with `w := pi(V[j]) - pi(U[i])`,
an integer vector. Write `w = (pi(V[j]) - pi(V[i])) - Delta(i)`. The second
term has `||Delta(i)||_inf <= D_sigma`. For the first, the `i`-th vertex of
the `V`-tiling is at `y_i = g(V[i]) = x - <l, Delta(i)>`, so
`|x - y_i| <= ||l||_1 D_sigma`; interior overlap gives `|x - y| < l_max`;
hence `|y - y_i| < l_max + ||l||_1 D_sigma`. Between the `i`-th and `j`-th
vertices of the `V`-tiling lie `|j - i|` tiles of length at least `l_min`,
so `|j - i| < (l_max + ||l||_1 D_sigma) / l_min`, and
`||pi(V[j]) - pi(V[i])||_inf <= |j - i|`. Adding the two bounds gives the
claim; the vertex count follows from Lemma 1.1 since `i, j` range over `A`
and `w` over a box. ∎

*Remarks.* (i) Only primitivity and the Pisot spectrum enter, through
`D_sigma`; unimodularity, irreducibility and legality of `ab` are not used.
(ii) The manuscript's Section 4.7 obtained finiteness of *realized* overlaps
of two tilings in one fibre from finite local complexity and the Meyer
property; Theorem 2.1 gives it for the seed-patch graph directly and
elementarily, and it removes the theorem target "finite-type consequence"
(item 5) of `docs/p1b-overlap-realization-bridge.md`. (iii) The state cap
in the canonical implementation is now only a fail-closed guard; it can never
bind for a correct implementation, and the census of Section 5 confirms it
never does on the corpus.

## 3. Geometry of coincidence

The following two lemmas are the dictionary between blocks and tiles. They use
the manuscript's Lemma 2.3 (`Q`-independence of the `l_a`, which needs
irreducibility of `chi_M`).

**Lemma 3.1 (zero returns are common vertices).** Let `(u, v)` be a balanced
pair, both words tiling `[0, g(u))`. A point is a vertex of both tilings if
and only if it equals `g(u[k]) = g(v[k])` for a zero return `k` of `(u, v)`.

*Proof.* If `g(u[i]) = g(v[j])` then `<l, pi(u[i]) - pi(v[j])> = 0` with an
integer vector, so `pi(u[i]) = pi(v[j])` by `Q`-independence; applying
`<1, .>` gives `i = j`, and then `D(i) = 0`. The converse is immediate. ∎

**Lemma 3.2 (common tiles are coincidence blocks).** A tile belongs to both
tilings of a balanced pair `(u, v)` if and only if it is the tile of a
coincidence block `(c, c)` of `red(u, v)`.

*Proof.* A common tile `[x, x + l_c)` has both endpoints common vertices,
hence (Lemma 3.1) zero returns `k, k+1` with `u_{k+1} = v_{k+1} = c`, i.e. a
block `(c, c)`. Conversely a coincidence block is a common tile. ∎

By the manuscript's Lemma 2.12 the depth-`m` descendants of a state
`T = (u, v)` are the blocks of `red(sigma^m(u), sigma^m(v))`, and they tile
`[0, beta^m g(T))`. Hence: **`T` is productive iff for some `m` the tilings by
`sigma^m(u)` and `sigma^m(v)` share a tile; `T` is nonproductive iff they
never do.**

## 4. Coincidence density and Level 3 without G1

For a balanced pair `T = (u, v)` and `m >= 0` let `C_m(T)` be the total
length of the common tiles of the tilings by `sigma^m(u)` and `sigma^m(v)`,
and `f_m(T) := C_m(T) / (beta^m g(T))` the *common fraction*. For a reachable
state `T` its *overlaps* are the overlaps of the pair `(u, v)` (top tiles from
`u`); they are vertices of `O_sigma` (Lemma 1.1). An overlap is *productive*
if some descendant is a coincidence.

**Theorem 4.1.** Let `sigma` be PIP, `s` a swap seed and `T` a state
reachable from `s`.

1. (monotonicity) `f_{m+1}(T) >= f_m(T)`; the limit `delta(T) := lim f_m(T)`
   exists in `[0, 1]`.
2. (productivity) `T` is productive iff `delta(T) > 0` iff some overlap of
   `T` is productive.
3. (density one) If every vertex of `O_sigma` reachable from the seed
   overlaps of `s` is productive, then `delta(T) = 1` for every `T` reachable
   from `s`. Conversely, if `delta(s) = 1` then every such overlap is
   productive.
4. (Level 3 without G1) If `delta(s) = 1` then every state reachable from
   `s` is productive. In particular, if every vertex of `O_sigma` is
   productive then every reachable state of `B_sigma` is productive, whether
   or not `B_sigma` is finite.
5. (under finiteness) If the set of states reachable from `s` is finite, then
   `delta(s) = 1` iff every state reachable from `s` is productive iff the
   balanced-pair algorithm terminates with coincidence from `s`.

*Proof.* (1) A common tile of type `c` at level `m` inflates to the supertile
`sigma(c)` at level `m+1`, all of whose tiles are common; so
`C_{m+1} >= beta C_m`.

(2) By Lemma 3.2, `T` productive iff some level `m` has a common tile iff
`C_m > 0` for some `m` iff `delta > 0` (by (1)). A common tile at level `m`
inside `[0, beta^m g(T))` is a coincidence overlap; its ancestors at level 0
are the two level-0 tiles containing it, which overlap, so it descends from an
overlap of `T`. Conversely a coincidence descending from an overlap of `T` is
a common tile inside the interval of `T` at that level.

(3) Let `S` be the set of vertices of `O_sigma` reachable from the seed
overlaps of `s`; it is finite by Theorem 2.1. If all are productive there is
`K` such that every non-coincidence vertex of `S` has a coincidence
descendant within `K` levels. Fix a level and a non-common top tile `tau`
(length `l_tau`). Its interior is covered by bottom tiles, so `tau` belongs
to some overlap `O`, which is not a coincidence; `O` has a coincidence
descendant within `k <= K` levels, a common tile `c` inside `beta^k tau`, and
`K - k` further inflations make it a common supertile of length
`>= l_min` inside `beta^K tau`. So the non-common length inside `beta^K tau`
is at most `beta^K l_tau - l_min <= (1 - eps) beta^K l_tau` with
`eps := l_min / (beta^K l_max) > 0`. Non-common tiles at level `m + K` lie in
inflations of non-common tiles at level `m` (common tiles stay common), so
the non-common length `NC` satisfies `NC_{m+K} <= (1 - eps) beta^K NC_m`, and
`1 - f_{m+jK}(T) <= (1 - eps)^j (1 - f_m(T)) -> 0`. Conversely, let `O` be a
nonproductive overlap occurring at level `N` of `s`, with intersection of
length `lambda > 0`. At level `N + m`, no tile of `U` inside
`beta^m (top ∩ bottom)` is common: a common tile there would be a coincidence
overlap descending from `O`. Hence
`1 - f_{N+m}(s) >= (beta^m lambda - 2 l_max) / (beta^{N+m} g(s))`, whose limit
`lambda / (beta^N g(s))` is positive, so `delta(s) < 1`.

(4) If `T` is a nonproductive state at depth `j` below `s`, then at depth
`j + m` all top tiles inside the interval of `T` are non-common (Lemma 3.2),
so `1 - f_{j+m}(s) >= beta^m g(T) / (beta^{j+m} g(s)) = g(T) / (beta^j g(s))`
for all `m`, and `delta(s) < 1`. The second sentence combines this with (3).

(5) By (4), `delta(s) = 1` forces productivity of all reachable states. If
the reachable set is finite and every state is productive, there are `K` and
`eps > 0` such that every noncoincident state has, among its depth-`K`
descendants, coincidence blocks of total length `>= eps beta^K g(T)` (finitely
many states, each with a coincidence descendant at some depth `<= K`, whose
inflation to depth `K` has length `>= l_min`). Then `NC_{m+K} <= (1 - eps)
beta^K NC_m` as in (3) and `delta(s) = 1`. Termination with coincidence is,
by definition, finiteness plus productivity of all reachable states. ∎

**Corollary 4.2 (mass balance on overlaps).** For an overlap `O` of type
`(i, j, t)`, `t = <l, w>`, the intersection length is `lambda(O) = <l, v(O)>`
with `v(O) in {e_i, e_j, e_j + w, e_i - w}` (top inside bottom, bottom inside
top, bottom starts before the top, top starts before the bottom). The
geometric children of `O` (all overlapping pairs of sub-tiles; for a
non-coincidence these are its children in `O_sigma`) partition the inflated
intersection, so `sum v(child) = M v(O)` over them (by `Q`-independence).
Hence for any nonempty set `S` of non-coincidence overlaps closed under
children, the child-count matrix
`N_S` satisfies `N_S lambda_S = beta lambda_S` with `lambda_S > 0`, so
`rho(N_S) = beta`, and `N_S V_S = V_S M^T` for the matrix `V_S` with rows
`v(O)^T`. This is the overlap analogue of the manuscript's Theorem 5.2.

**Corollary 4.2' (full rank on closed overlap sets).** Let `S` be a nonempty
set of non-coincidence overlaps closed under children. Then the row space of
`V_S` is an `M`-invariant rational subspace (each `M v(O)` is a sum of rows),
nonzero because `lambda(O) > 0`; irreducibility of `chi_M` forces it to be
`Q^d`. Hence `rank V_S = d`, `|S| >= d`, and `spec(M) subset of spec(N_S)`:
every Galois conjugate of `beta` is an eigenvalue of the nonnegative integer
matrix `N_S`. This is the overlap analogue of the manuscript's Theorem 5.2
(Parikh intertwiner) and, like it, gives no contradiction by itself. (My
earlier suggestion that a closed nonproductive set forces a rank-*deficient*
`V_S` was wrong for exactly this reason.) Boundary synchronization also
transfers: an overlap `(c, c', 0)` has `(sigma_+^m(c), sigma_+^m(c'), 0)` among
its depth-`m` descendants, so it is productive whenever `(c, c')` is
`sigma_+`-synchronizing, and symmetrically for right-aligned overlaps.

**Corollary 4.3 (sink reduction on overlaps).** Since `O_sigma` is finite,
some overlap is nonproductive iff `O_sigma` contains a closed nonproductive
strongly connected component (the manuscript's Theorem 5.1 applied verbatim
to the finite graph `O_sigma`).

## 5. Exact census (finite evidence)

Canonical run `kernel/swap_overlap_census.mojo` (exact Sturm-sequence PIP
screening; shifts in `Z[beta]`; every sign decided exactly), independent
Python oracle `oracles/python/swap_overlap_census.py` (`reference/psc_research/overlap_graph.py`,
elements of `Q(beta)` as polynomials modulo the irreducible cubic, signs by
certified interval refinement):

| quantity | value |
| --- | --- |
| PIP specimens (images of length `<= 3`) | 4,554 |
| seed-patch overlap graphs built / capped (cap 20,000) / failed | 4,554 / 0 / 0 |
| largest seed-patch overlap graph | 2,640 vertices |
| total vertices over the corpus | 1,118,850 |
| specimens with a nonproductive overlap | 0 |
| largest first-coincidence depth over all vertices | 18 |
| specimens by maximal first-coincidence depth `3..18` | 402, 828, 696, 648, 444, 396, 276, 300, 168, 84, 36, 24, 108, 84, 36, 24 |

The first-coincidence depth is the uniform `K` of Theorem 4.1(3) computed
exactly per specimen; it is the quantity a uniform local-coincidence theorem
would have to bound. By Theorem 4.1(5) and the automaton census (every `B_sigma` in the corpus is
finite and productive), `delta(s) = 1` for every seed of every specimen, so
by Theorem 4.1(3) every overlap must be productive; the census confirms this
independently. Exact common fractions (common tiles over all tiles, a
normalisation-free surrogate for `f_m`) for the seed `(12, 21)` at levels
`0..10`: Tribonacci `0/2, 1/4, 3/7, 7/13, 16/24, 33/44, 65/81, 127/149,
244/274, 461/504, 867/927`; the non-unimodular example `tau` of the
manuscript `0/2, 1/4, 4/10, 11/22, 26/50, 62/114, 145/258, 335/586,
775/1330, 1799/3018, 4166/6850`. None of this is evidence about substitutions
outside the corpus.

## 6. Consequences for the programme, and the one open bridge

1. **Level 3 in G1-free form.** Define *Level 3'*: every vertex of `O_sigma`
   is productive. By Theorem 4.1(4), Level 3' implies that every reachable
   state of `B_sigma` is productive, hence SCC Producer, with no finiteness
   hypothesis; under G1 the two are equivalent (Theorem 4.1(3),(5)). The
   block-level tools of the manuscript (Parikh intertwiner, orientation
   cocycle, defect sieves) presuppose a finite strict component; Level 3'
   asks the same question on a graph that is finite unconditionally
   (Theorem 2.1), with the mass balance of Corollary 4.2 available.
2. **G1 is exactly bounded chain length.** A reachable state of length `n` is
   a chain of between `n` and `2n - 1` consecutive overlaps with no common
   vertex inside. Theorem 2.1 bounds the number of overlap *types*; G1 asks
   that only finitely many *chains* occur, i.e. that common vertices are
   uniformly relatively dense in every swap pair (the swap-pair form of the
   manuscript's Conjecture 4.21).
3. **The bridge (resolved on 2026-09-14 by import; see Section 8).** The
   manuscript's Imported Theorem 2.16 gives PDS from *termination*
   (finiteness plus productivity). The question below, as originally posed,
   is answered positively by Barge–Štimac–Williams Theorem 3.1:

   > **Question 6.1.** Let `sigma` be PIP and `ab` a legal factor. Does
   > `delta((ab, ba)) = 1` (equivalently, productivity of every overlap
   > reachable from the seed overlaps of `(ab, ba)`) imply pure discrete
   > spectrum, without assuming that `B_sigma` is finite?

   The exact source audit is
   `docs/seed-patch-to-literature-overlap-audit-2026-09-13.md`; it posed as
   the remaining step a global transfer of productivity from the finite
   swapped-patch graph to the complete Sirvent–Solomyak graph
   `G_O(T,x(W))` for one prefix translation. That transfer is not supplied
   here and is no longer needed for sufficiency: the periodic-patch form of
   Barge–Štimac–Williams Theorem 3.1 applies to the swap pair directly
   (Section 8), so PDS follows from Level 3' for one legal seed with no
   finiteness hypothesis. This does not settle G1: the converse of Imported
   Theorem 2.16 (PDS implies termination for a legal seed) is only recorded
   in the literature and not used here, and G1 concerns all seeds, legal or
   not (the manuscript's Open Problem 4.24). The bridge changes the role of
   G1 in the route to PDS, not its status.

In the manuscript these results are Theorem 4.22 (finiteness), Lemmas 5.30–5.31, Theorem 5.32 (coincidence density), Corollary 5.33, Corollary 5.34 (full rank on closed overlap sets), Open Problem 5.35 (overlap productivity), Lemma 5.36 (three forms of the density condition), Imported Theorem 5.37 and Theorem 5.38 (Section 8).

## 7. The transfer as a type-inclusion question (exploratory data)

Before the import of Section 8,
`docs/seed-patch-to-literature-overlap-audit-2026-09-13.md` reduced the
density bridge to one transfer, which is now superseded for sufficiency and
recorded here only as data: for a prolongable power `tau = sigma^q` with
one-sided fixed point `u` and a prefix `W` of `u`, productivity of every
overlap of the Sirvent–Solomyak family `(T, T - beta^{qn} g(W))`, `n >= 0`
(their graph `G_O(T, x(W))`), gives PDS by their Theorem 4.1(b). Because the
children of an overlap depend only on its type, the transfer holds for `W`
whenever

```text
every non-coincidence type of G_O(T, x(W)) is a vertex type of O_sigma.   (TI_W)
```

`(TI_W)` is a finite question for each `sigma` and `W`: both type sets are
finite (Theorem 2.1 for `O_sigma`; `G_O` is finite in the Pisot setting).

**Exploratory computation (not a certificate;
`kernel/oa_type_inclusion_census.mojo`, canonical since 2026-09-16; the figures
below were first produced by the retired Python explorer and are reproduced
exactly by the Mojo driver, which CI pins).** The level-0 types of
`(u, S^{|W|} u)` were read off a prefix of `u` of length at least 6,000
(an uncertified factor set) with the exact enumeration window (the least
`n` with `n * l_min > g(W) + l_max`, decided in `Q(beta)`; a first run with
a fixed heuristic window was withdrawn after referee finding 23 and
recomputed, which reproduced the figures below exactly), closed under exact
inflation, and compared with the vertex types of `O_sigma`, for
`W = u[:k]`, `k = 1, ..., 8`, on every tenth specimen of the corpus (456
specimens), with `u` the fixed point of the least prolongable power at the
least letter on a first-letter cycle.

| least `k` with `(TI_W)` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | none up to 8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| specimens | 256 | 109 | 41 | 8 | 12 | 6 | 1 | 1 | 22 |

Every `G_O` type encountered was productive (as it must be on this corpus,
where PDS is certified by termination). For Tribonacci `(TI_W)` holds with
`W = 1` and the two type sets coincide (29 types); for the non-unimodular
example `tau`, `W = 1` misses two non-coincidence types and `W = 13` gives
inclusion. The 22 failures show that `(TI_W)` with a short prefix of one
fixed point is not a uniform mechanism; a proof of the transfer will need
either longer prefixes, other fixed points, or the collar/occurrence
argument described in the audit. No conclusion about the bridge for
substitutions outside the corpus follows from this table.

**Addendum (2026-09-14; exploratory, not a certificate;
`kernel/oa_failures_probe.mojo`, canonical since 2026-09-16; the Mojo driver
reproduces every figure below, including all nine least witnesses, and CI
pins them).** For the 22 failures above, every
prolongable pair `(q, c)` (power `q <= 3`, letter `c` with
`sigma^q(c)` beginning with `c`) was tried with the fixed point of `sigma^q`
at `c` and prefixes `W = u[:k]`, `k = 1, ..., 24` (level-0 types read off a
prefix of length at least 6,000 with the exact enumeration window, closed
under exact inflation; the recomputation after finding 23 reproduced the
figures of the heuristic-window run exactly). Inclusion
`(TI_W)` was found for 9 of the 22 (least witnesses `(q, c, k)`: `(1,3,2)`
twice, `(2,1,6)`, `(1,1,9)`, `(1,2,9)`, `(1,2,16)` twice, `(1,3,16)`,
`(1,2,19)`) and for none of the other 13. The union over all probed families
of non-coincidence types has 58 to 132 elements against 15 to 48 seed-patch
vertex types, with 43 to 85 types outside `O_sigma` and 0 to 15 seed-patch
types not met by any probed family; every type in every union is
productive. The transfer by type inclusion is therefore not uniform even
with long prefixes and all fixed points of low powers; since the bridge is
now a theorem (Section 8) this is recorded as data only.

## 8. The density bridge is a theorem (Barge–Štimac–Williams)

For a seed `s = (ab, ba)` let `G_m(s)` be the union of the interiors of the
intervals `beta^{-m} I`, `I` a common tile of the level-`m` pair, and
`G(s) = union_m G_m(s)` the *good set*: points at which the two tilings are,
after some inflations, covered by a common tile. `G_m(s)` is open of
measure `C_m(s)/beta^m`. The sets are not nested: a common tile at level
`m` inflates to common tiles at level `m+1` whose interiors cover the
rescaled parent interior except at the finitely many subdivision points, so
`G_m(s) \ G_{m'}(s)` is finite for every `m' >= m`.

**Lemma 8.1 (three forms; manuscript Lemma 5.36).** For PIP `sigma` and a
seed `s` the following are equivalent: (a) every vertex of `O_sigma`
reachable from the seed overlaps of `s` is productive; (b) `delta(s) = 1`;
(c) `G(s)` is dense.

*Proof.* (a) iff (b) is Theorem 4.1(3). (b) => (c): `G(s)` contains every
`G_m(s)`, so it is open of full measure, and its complement has empty
interior. (c) => (a): an overlap at level `N` reachable from `s` has an
intersection `J` of positive length; the nonempty open set
`U = beta^{-N} J°` meets some `G_m(s)`, `U ∩ G_m(s)` is open and nonempty,
hence infinite, and `G_m(s) \ G_{m'}(s)` is finite for `m' = max(m, N)`, so
`U` meets `G_{m'}(s)` at a point `t`. The level-`m'` tiles of both tilings
whose interiors contain `beta^{m'} t` are one common tile; since
`beta^{m'} t` lies in `beta^{m'-N} J°` and the level-`m'` tilings refine the
`(m'-N)`-fold inflations of the level-`N` tilings, that tile lies inside both
inflated tiles of the overlap, hence is a coincidence descending from it. ∎

**Imported theorem (Barge–Štimac–Williams, *Pure discrete spectrum in
substitution tiling spaces*, arXiv:1107.3598, Theorem 3.1 and the proof of
Theorem 3.2).** Let `Phi` be a substitution of Pisot family type (standing
assumptions: primitive, aperiodic, finite local complexity), `Q` a finite
patch (not necessarily allowed) whose translates by a lattice `L` tile
`R^n`, and `v` completely rationally independent of `L`. If the periodic
tiling `Q̄` and `Q̄ - v` are *densely eventually coincident* (eventually
coincident at a dense set of points, where "eventually coincident at `x`"
means that for some `k` the tiles containing `0` of `Phi^k(Q̄ - x)` and of
`Phi^k(Q̄ - v - x)` agree), then the `R^n`-action on `Omega_Phi` has pure
discrete spectrum. Their Theorem 3.2 is the one-dimensional case `Q = uv`,
`L = (g(u) + g(v)) Z`, `v = g(u)` with `g(u), g(v)` linearly independent
over `Q`, where dense eventual coincidence is obtained from termination of
the balanced-pair algorithm for `(uv, vu)`; their Corollary 3.3 is the
letter case `u = a`, `v = b` for irreducible Pisot `sigma`, any `a != b`.

For PIP `sigma` and letters `a != b`: `l_a, l_b` are `Q`-independent
(manuscript Lemma 2.3), aperiodicity is Lemma 2.4, finite local complexity
is automatic. `Q̄ - l_a` is the periodic tiling by `ba` with a vertex at `0`,
so on each period the pair `(Q̄, Q̄ - l_a)` is the swap pair `(ab, ba)` and
`Phi^k` of it is `(sigma^k(ab), sigma^k(ba))` repeated; hence
`(Q̄, Q̄ - l_a)` is eventually coincident at every `x` whose residue modulo
`l_a + l_b` lies in `G((ab, ba))`. Therefore:

**Theorem 8.2 (manuscript Theorem 5.38, main theorem without finiteness).**
Let `sigma` be PIP and `a != b`. If every vertex of `O_sigma` reachable from
the seed overlaps of `(ab, ba)` is productive (equivalently `delta = 1`,
equivalently `G((ab, ba))` dense), then `(Omega_sigma, R)` has pure discrete
spectrum. No finiteness hypothesis is used. The manuscript's conditional
main theorem (G1 plus SCC Producer) is the special case in which `B_sigma` is
finite and every state is productive (Theorem 4.1(5)).

**Consequences.** Level 3' (Open Problem 5.35) for one seed implies PDS;
PSC would follow from overlap productivity for all PIP substitutions; the
finiteness hypothesis G1 has left the sufficiency route entirely. G1's own
status is unchanged (open), as is Open Problem 4.24 (whether PDS forces
termination from every seed). The seed-to-literature transfer of Section 7
is no longer needed for sufficiency; the exploratory data there stand as
evidence that a type-inclusion proof of that transfer would not have been
uniform. For unimodular `sigma` a converse (PDS implies productivity of every
vertex of `O_sigma`) can be read off Barge–Kwapisz Corollary 9.4 and
Proposition 17.2, whose proofs do not pass through their Theorem 16.3 (the
result Barge–Štimac–Williams report as gapped); it is not used and not
recorded as imported.

Nothing in this note proves Level 3', G1, or PSC.

## 9. Endpoint-aligned overlaps are strong coincidence; the hitting form (2026-09-14)

Call a pair of distinct letters `{i, j}` *eventually coincident* if
`sigma^n(i) = p c s`, `sigma^n(j) = p' c s'` with `pi(p) = pi(p')` for some
`n` (the manuscript's Imported Theorem 2.x of Barge–Diamond); the strong
coincidence condition of Arnoux–Ito is that every pair is eventually
coincident. The reversed substitution gives the suffix form.

**Proposition 9.1 (manuscript Proposition 5.39).** Exchanging the two
tilings sends `(a, b, t)` to `(b, a, -t)`, commutes with inflation and
preserves coincidences, so the graph is generated from one orientation of
each unordered pair (the canonical graph uses `a < b`). For `i != j`,
`(i, j, 0)` and `(j, i, l_j - l_i)` are seed overlaps of `(ij, ji)`; the
first is productive iff `{i, j}` is eventually coincident (and so is
`(j, i, 0)`), the second iff it is eventually coincident for the reversal
(reflection sends `(a, b, t)` to `(a, b, l_a - l_b - t)` and commutes with
inflation). Hence Open Problem 5.35
implies the two-sided strong coincidence condition, which is open for
`d >= 3`.

**Proposition 9.2 (manuscript Proposition 5.40).** Write the offset as
`t = <w, l>`, `w` in `Z^d`, and let `P_m(a)` be the Parikh vectors of the
proper prefixes of `sigma^m(a)`. For an overlap `O = (i, j, t)` and `m >= 0`
the following are equivalent: `M^m w` lies in `P_m(i) - P_m(j)`; a sub-tile
of the level-`m` tiling of the top tile and a sub-tile of the level-`m`
tiling of the bottom tile have the same left endpoint (a common boundary
other than the right endpoint of either inflated tile); `O` has a level-`m`
descendant of offset zero. Consequently a productive overlap satisfies the
hitting condition at some level; under strong coincidence the converse
holds (the offset-zero descendant is a coincidence or productive by 9.1);
and in a closed nonproductive set every boundary coincidence produces an
offset-zero member whose letters are a non-eventually-coincident pair.

**Corollary 9.3 (manuscript Corollary 5.41).** Under strong coincidence:
every noncoincident state of `B_sigma` is productive (a common first letter
would split off; otherwise eventual coincidence of the first letters gives a
zero return followed by a coincidence block), so G1 alone gives PDS (the
two-letter argument of Hollander–Solomyak with Barge–Diamond); Open Problem
5.35 is equivalent to the hitting statement for every vertex; and in a closed
nonproductive set no sub-tile of the top tile ever starts where a sub-tile
of the bottom tile starts, at any level.

**Exact census (Mojo canonical, Python oracle agrees; asserted in CI).**
Over the 4,554-specimen corpus, with exact `Q(beta)` signs: the largest
first left-aligned depth (least `m` with an offset-zero descendant) over all
vertices of all graphs is 17 (specimens by maximum:
2:300 3:996 4:870 5:594 6:312 7:300 8:414 9:288 10:132 11:60 12:36 13:48
14:84 15:72 16:36 17:12); the largest strong-coincidence depth of a letter
pair is 15 for the prefix form and 15 for the suffix form (specimens by
value, identical for the two forms because the corpus is closed under
reversal; the depth of a pair is the same for its two orientations: 1:576 2:1416 3:654 4:858 5:666 6:252 7:102 8:18 14:6 15:6). For
every vertex of every graph the first-coincidence depth is at most the first
left-aligned depth plus the largest prefix strong-coincidence depth of the
substitution, as Corollary 9.3 predicts. Every corpus specimen satisfies
two-sided strong coincidence; this is finite evidence for nothing beyond
the corpus.

**What this changes.** Open Problem 5.35 now has a known lower bound in
difficulty (it contains strong coincidence) and, under strong coincidence,
a purely combinatorial form: for every vertex `(i, j, w)` some `M^m w` is a
difference of proper-prefix Parikh vectors of `sigma^m(i)` and `sigma^m(j)`.
In the contracting embedding this is the meeting of Rauzy-fractal pieces at
the prescribed expanding offset, the geometric coincidence problem of
Ito–Rao, Barge–Kwapisz and Minervino–Thuswaldner; nothing here resolves it.

## 10. The hitting level against the contracting size of the offset (2026-09-15)

**Proposition 10.1 (manuscript Proposition 5.42, contracting lower bound).**
Let `F` be the finite set of single-inflation offset increments `q - p`. If
an overlap `(i, j, t)` has a level-`m` descendant of offset zero then
`t = -sum_{s<m} beta^{-(s+1)} c_s` with `c_s` in `F`, so for every
contracting embedding `varsigma` (`|varsigma(beta)| < 1`)
`|varsigma(t)| <= C_varsigma * sum_{s=1}^{m} |varsigma(beta)|^{-s}`,
`C_varsigma = max_F |varsigma(c)|`. The first left-aligned depth is therefore
at least `m_0(t)`, which is `0` for `t = 0` and otherwise the least `m >= 1`
satisfying these inequalities. For a complex contracting pair and `t != 0`,
`|varsigma(t)|^2 = N(t)/t`, `|varsigma(beta)|^{-2} = rho := beta/D`, and
`C^2 = K = max over F minus {0} of N(c)/c` (the zero increment contributes
nothing). With `n_k = min(k-1, 2m+1-k)`, `A_m = sum_j n_{2j} rho^j` and
`B_m = sum_j n_{2j+1} rho^j`, elements of `Q(beta)` with `A_m > 0` and
`B_m >= 0` at `beta` (`B_1 = 0`), the condition is equivalent to `N(t)/t <= K (A_m + rho^{1/2} B_m)`, which holds
iff `N(t)/t <= K A_m`, or `N(t)/t > K A_m` and
`(N(t)/t - K A_m)^2 <= K^2 rho B_m^2`: at most two exact sign tests at
`beta`, no relaxation (an earlier draft tested the Cauchy–Schwarz relaxation
`N(t)/t <= K m sum_{s<=m} rho^s`, which is one-way and undershoots `m_0`;
the referee's example `1->2, 2->33, 3->213`, offset `(-8, -2, 5/2)`, has
`m_0 = 6` while the relaxation gives `5`). For two real contracting
conjugates the test is the defining inequality at each isolated root.

**Exact census (Mojo canonical, `kernel/psc/overlap_contracting.mojo` with the
Sturm–Tarski module `kernel/psc/real_root_sign.mojo` and the driver
`kernel/overlap_contracting_census.mojo`, asserted line by line in CI; Python
oracle `reference/psc_research/overlap_contracting.py`,
`oracles/python/overlap_contracting_census.py`, prints the same nine summary lines, without the specimen-count header).** Over all
1,118,850 vertices of the 4,554 corpus graphs, `m_0` never exceeds the first
left-aligned depth `b`; the largest `m_0` is 8 (vertices by `m_0`:
0:34702 1:338684 2:429036 3:206232 4:77748 5:26496 6:5424 7:516 8:12); the excess
`b - m_0` reaches 14 (vertices by excess: 0:116542 1:144998 2:199672
3:207832 4:174120 5:119662 6:77088 7:44568 8:21036 9:8988 10:2856 11:1008
12:360 13:96 14:24; specimens by maximal excess: 1:378 2:990 3:912 4:612
5:390 6:516 7:330 8:120 9:96 10:60 11:78 12:42 13:24 14:6). The 648
specimens with two real contracting conjugates have `m_0 <= 2` and excess
`<= 4`.

**Reading (what the executable result supports).** This magnitude bound,
built from the triangle inequality over the increments, accounts for at
most 8 of the up to 17 inflations before a common sub-tile left endpoint
appears and leaves a gap of up to 14 inflations unexplained. The gap
includes the slack of that inequality; whether a sharper contracting-space argument (digit
correlations, the two embeddings jointly, cancellation among increments)
explains part of it is not decided here, and no conclusion about what a
proof of Open Problem 5.35 must or cannot use is drawn. Nothing here proves
Level 3', G1, or PSC.
