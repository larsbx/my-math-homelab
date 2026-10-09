# P1b: the leftmost chain is functional, and its cycles are prefix-vs-interior pairs — 2026-10-05

**Status:** Proposition LC and Corollaries LC1–LC5 are proved here. The dated
internal review is
[`review-box-leftmost-ledger-2026-10-08.md`](review-box-leftmost-ledger-2026-10-08.md);
human review remains pending. The proof-dependency nodes are
`LeftmostChainCycleStructure` (Lemma S, LC, LC4) and
`LeftmostChainG1Certificate` (LC5), retaining the merged canonical names.
On the standing corpus, claims 1–3 are checked on all 10,584 terminal leftmost
cycles of all 4,554 specimens, none capped, none failing. Claim 4 is replayed
over `Z` on 10,128 cycles; the other 456 offsets are uncomputed, and their
integrality rests on the proof. Corollary LC5 gives **G1 outright for the 1,794 specimens whose box
graph has no terminal cycle**, by a route needing only the leftmost function —
though G1 is already certified on that whole corpus by the Proposition V
census, so this is a cheaper certificate, not a new finite-domain result. It
settles neither T1 nor T2 of
[`p1b-vertex-coincidence-box-2026-10-02.md`](p1b-vertex-coincidence-box-2026-10-02.md)
§5.6c, neither PPVC, nor #139, G1 or PSC. What it does is replace the
combinatorial condition "this vertex is not in `CU`" by an arithmetic witness:
a `Φ^r`-fixed ray/tiling pair built from one **prefix** occurrence and one
**interior** occurrence, with an explicit integrality condition.

Ledger (2026-10-08): Lemma S, Proposition LC and Corollary LC4 are the
repository-proved node `LeftmostChainCycleStructure`; Corollary LC5 is the
repository-proved node `LeftmostChainG1Certificate`, a per-specimen statement
that is not an alternative establishment of uniform G1 (§9).

Canonical implementation: `kernel/psc/leftmost_chain.mojo`, driver
`kernel/leftmost_chain_census.mojo`, regression `kernel/tests/test_leftmost_chain.mojo`.

## 1. Why this, and why now

The closing target of the P1b programme is the trichotomy of §5.6c, which
reduces PPVC — hence, through Corollary B′ and manuscript Proposition 5.47,
hypothesis G1 — to two unproved statements:

- **T1 (catch-up reachability).** If `sigma` is not catch-up-free, every
  recurrent vertex that is not short periodic reaches `CU`.
- **T2 (simultaneous birth).** If `sigma` is catch-up-free, every recurrent
  vertex has a descendant with an offset-zero child through two positive
  indices.

The side-notes ledger records four attacks on T2, all stopped: one-step M-adic
valuation ascent, adelic coverage, vertex-sheet alignment, and Barge-class
conjugacy. T1 had been stated and never attacked. This note attacks the object
T1 is about — the set `CU` — rather than T1's reachability claim, and proves a
structure theorem for it.

The first observation is the one that makes the rest work, and it is in the
definition rather than in any argument: **the leftmost child is a function.**
Each vertex of nonzero offset has exactly one child whose region contains the
parent's left region endpoint. So the leftmost chain is the orbit of a self-map
on a finite set, and

> `CU` = the vertices whose leftmost orbit leaves the nonzero offsets,

whose complement is the basin of the map's **terminal cycles**. Those cycles
are therefore the whole obstruction, and there are few of them.

## 2. Conventions

Those of [`p1b-strict-zipper-periodic-pair-2026-10-02.md`](p1b-strict-zipper-periodic-pair-2026-10-02.md)
§1. An overlap `v = (i, j, w)` places tile `i` on `[0, ell_i)` in tiling A and
tile `j` on `[x, x + ell_j)` in tiling B, with `x = <ell, w>`; its region is
`R_v = (0, ell_i) ∩ (x, x + ell_j)`. A child through indices `(p, q)` has offset
vector `M w + ab(P_j(q)) − ab(P_i(p))`, where `P_a(k)` is the length-`k` prefix
of `sigma(a)`; it is **left-aligned** (offset zero) when both tiles start
together. `f(a) = sigma(a)[0]` is the **first-letter map**.

For `r >= 1`, following Theorem B, an **interior occurrence** is a
factorisation `sigma^r(a) = P a U` with `P` and `U` both nonempty; it determines
the `Phi^r`-fixed tiling `T(a, P)` whose centre `c = <ell, ab(P)>/(beta^r − 1)`
lies in `(0, ell_a)`. A **prefix occurrence** is the degenerate case `P` empty,
`sigma^r(a) = a U` with `U` nonempty: then `c = 0`, the tile's own start, and
`T(a, ∅)` is the one-sided fixed point of `sigma^r` beginning with `a`.
Theorem B excludes this case; Proposition LC is exactly about it.

## 3. The leftmost step keeps its sign

*Lemma S.* Let `v` have offset `x != 0` and let `v'` be its leftmost child.
Then `x'` has the same strict sign as `x`, or `x' = 0`. If `x < 0` the leftmost
child's **top** index is `0`; if `x > 0` its **bottom** index is `0`.

*Proof.* Suppose `x < 0`, so tiling B's tile starts strictly left of tiling A's
and the left end of `R_v` is `0`, the start of the `i`-tile. Inflating, the
left end of `beta R_v` is still `0`, and `0` is the start of the first tile of
`sigma(i)`: the child containing it has top index `0`. Its bottom index `q` is
the tile of `sigma(j)` whose half-open interval contains `0`, so that tile
starts at or left of `0`, i.e. the child's offset `beta x + <ell, ab(P_j(q))>`
is `<= 0`. It is `0` exactly when that tile starts at `0`, which is a
catch-up hit. The case `x > 0` is the mirror image, with the roles of the two
tilings exchanged. `square`

So the chain never crosses zero: it either lands on zero and stops, or keeps
one strict sign forever. Both facts are already encoded in the `psc.one_tile`
step, which selects the child of sign `<= 0` (resp. `>= 0`); Lemma S is the
statement that this is a lemma and not a convention.

Two immediate consequences. First, along an `x < 0` chain the top letters
satisfy `i_{n+1} = f(i_n)`, so they are eventually `f`-periodic — at most
`|A| = 3` letters can occur in the limit. Second, a hit along the chain needs
`M w_n = ab(P)` for a proper nonempty prefix `P`, so `ab(P) ∈ M Z^A`; that is
Lemma P of §5.6b, recovered in one line.

## 4. Proposition LC

*Proposition LC.* Let `v` be a vertex of nonzero offset whose leftmost chain
never reaches offset zero, and let `y_0 -> y_1 -> … -> y_r = y_0` be the
terminal cycle its orbit enters, `r >= 1`. Put `sign = sign(x_{y_0})`, and let
A be the tiling whose tile starts later (A when `sign < 0`, B when `sign > 0`).
Then, writing `i` for A's letter at `y_0` and `j` for B's:

1. the offset keeps the sign `sign` at every vertex of the cycle;
2. composed over the cycle, A's index in `sigma^r(i)` is `0`, and
   `|sigma^r(i)| >= 2`: `sigma^r(i) = i U` is a **prefix occurrence**, so `i`
   lies on a cycle of `f` whose length divides `r`;
3. composed over the cycle, B's index in `sigma^r(j)` is strictly interior:
   `sigma^r(j) = Q j V` with `Q` and `V` nonempty — an **interior occurrence**;
4. the offset vector satisfies the cycle equation `(I − M^r) w_0 = ab(Q)`
   (up to the sign exchange), so `w_0 = (I − M^r)^{-1} ab(Q) ∈ Z^A` and
   `ab(Q) ∈ (I − M^r) Z^A`;
5. `T_A = T(i, ∅)` is a right-infinite fixed point and
   `T_B = T(j, Q) + <ell, w_0>` is a two-sided `Phi_c^r`-fixed tiling. The
   pair is compared on `[0, ∞)` with common centre `c = 0`; `c` is a vertex of
   `T_A` of infinite level, `c` is interior to every level tile of `T_B`, and
   `c` is never a common vertex of the pair.

*Proof.* Take `sign < 0`; the other case is the mirror image.

1. Lemma S, iterated: no vertex of the chain has offset zero, so the sign is
   constant from `v` onwards, in particular on the cycle.

2. By Lemma S each step of the cycle uses top index `0`. Composing `r` steps,
   the position of A's level-`r` tile inside `sigma^r(i)` is the sum over
   levels of the lengths of the preceding level tiles, each of which is empty;
   so the composite index is `0`, and the cycle's letter satisfies
   `sigma^r(i)[0] = i`. Hence `f^r(i) = i`, so `i` is `f`-periodic with period
   dividing `r`. If `|sigma^r(i)| = 1` then that one letter is `i`, so
   `sigma^r(i) = i` and `M^r e_i = e_i`; iterating, `M^{rk} e_i = e_i` for
   every `k`, while primitivity makes `M^{rk}` strictly positive for `rk`
   large, so `M^{rk} e_i` has all three coordinates positive — and `e_i` does
   not. So `|sigma^r(i)| >= 2` and `U != ∅`.

3. Write `q_n` for the bottom index used at step `n` and `Q` for the composite
   prefix, so that `ab(Q) = Σ_{n<r} M^{r−1−n} ab(P_{j_n}(q_n))`. The offset
   recursion of Lemma S is `w_{n+1} = M w_n + ab(P_{j_n}(q_n))`; over the cycle
   it closes, giving `w_0 = M^r w_0 + ab(Q)`, that is
   `(I − M^r) w_0 = ab(Q)`, which is claim 4. Pairing with `ell` and using
   `ell M = beta ell`,

       <ell, ab(Q)> = (1 − beta^r) x_0 > 0,

   because `x_0 < 0` and `beta > 1`. So `Q != ∅`. For `V`, the two tiles of
   `y_0` overlap, so `0 ∈ (x_0, x_0 + ell_j)`, i.e. `−x_0 < ell_j`. Then

       <ell, ab(Q)> = (beta^r − 1)(−x_0) < (beta^r − 1) ell_j
                    = <ell, M^r e_j − e_j> = <ell, ab(Q) + ab(V)>,

   so `<ell, ab(V)> > 0` and `V != ∅`. Hence `sigma^r(j) = Q j V` is an
   interior occurrence, and its composite index `|Q|` is strictly between `0`
   and `|sigma^r(j)| − 1`.

4. Proved in 3. The matrix `I − M^r` is invertible: its eigenvalues are
   `1 − beta^r` and `1 − beta_k^r` at the contracting conjugates, none zero.
   The initial cycle offset is already integral; the inverse equation
   identifies it rather than assuming integrality of an arbitrary occurrence.

5. The cycle's composite contraction `E` is a composition of `r` leftmost
   edges. By definition each maps the parent's left region end to the child's,
   so the composite fixes the left end of `R_{y_0}`, which is
   `c = 0`. The two occurrences of 2 and 3 are exactly the data of the Theorem B
   construction, read with `P = ∅` on the A side: `T(i, ∅)` has centre
   `<ell, ab(∅)>/(beta^r − 1) = 0`, and `T(j, Q)` has centre
   `<ell, ab(Q)>/(beta^r − 1) = −x_0` by the identity of 3, so translating
   `T(j, Q)` by `<ell, w_0> = x_0` puts its centre at `0` too. Both are legal,
   every patch lying inside some `sigma^{rn}` of its letter, and both are fixed
   by `Phi_0^r`. One asymmetry is worth stating rather than glossing: expanding
   about `c = 0` by `beta^r` grows the A-patch only to the right, because `c`
   is the *left* end of the region, so `T_A` is the **right-infinite** fixed
   point of `sigma^r` beginning with `i`, while `T(j, Q)` is two-sided; the
   pair, and the claim below, live on `[0, ∞)`, which is where the region is.
   `c = 0` is the start of A's tile at every level `rn`, hence a vertex of
   `T_A` of level `>= rn` for every `n`, i.e. of infinite level in the ray's
   displayed substitution hierarchy. On
   the B side `c` is interior to the level-`rn` tile `j` for every `n`, by 3,
   so `c` is not a vertex of `T_B`; a point that is not a vertex of `T_B` is
   not a common vertex. `square`

### The smallest witness, by hand

`sigma: 0 -> 1, 1 -> 12, 2 -> 022` has two terminal leftmost cycles, both of
length `r = 1`, and everything in Proposition LC can be checked without a
computer.

The first-letter map is `0 -> 1`, `1 -> 1`, `2 -> 0`, so `1` is its unique
fixed point; `sigma(1) = 1 . 2` is a prefix occurrence with `U = "2"`
nonempty, which is claim 2 at `r = 1`. `sigma(2) = 0 . 2 . 2` has `2` at index
`1`, strictly interior, with `Q = "0"` and `V = "2"` — claim 3 — so
`ab(Q) = e_0`. With `M[a][b] = |sigma(b)|_a`,

    M = [[0, 0, 1], [1, 1, 0], [0, 1, 2]],   char. poly  x^3 - 3x^2 + 2x - 1,

so `beta ≈ 2.3247` and `det(I - M) = -1`. The cycle equation of claim 4 is
`(I - M) w_0 = e_0`, whose exact solution is

    w_0 = (0, 1, -1),   <ell, w_0> = ell_1 - ell_2.

From `ell M = beta ell`: `ell_1 = beta ell_0` and `ell_2 = (beta^2 - beta)
ell_0`, so `<ell, w_0> = (2 beta - beta^2) ell_0 < 0` because `beta > 2`. So
the cycle vertex is `(1, 2, w_0)` with negative offset, the top tile starts
later, and the catching side is the top — claim 1, and the sign the exact
census reports. Its mirror `(2, 1, -w_0)` is the second cycle. Claim 5 then
reads: `T(1, ∅)` is the one-sided fixed point of `sigma` beginning with `1`,
`0` is a vertex of it of infinite level, and `0` is interior to the level-`n`
tile `2` of `T(2, "0") + <ell, w_0>` for every `n`, so it is never a common
vertex.

`det(I - M) = -1` makes the integrality of claim 4 automatic here. That is the
degenerate case: for larger `r` the condition `ab(Q) ∈ (I - M^r) Z^A` is a
real restriction, since `|det(I - M^r)| = |prod_k (1 - beta_k^r)|` grows like
`beta^r`.

*What is and is not new here.* The idea that non-terminating expansions are
classified by the cycles of a finite graph is the standard one: it is
Siegel–Thuswaldner's **zero-expansion graph** `G(0)` (Definition 5.1 of
*Topological properties of Rauzy fractals*), whose nodes are by construction
those lying on infinite paths and which decides `0 ∈ T(i) + gamma`; the
geometric property (F) is the statement that only the trivial node occurs. §5
below records the gate. What this proposition adds is specific to the real,
one-dimensional representation and to the standing non-unit regime: the
leftmost chain is **functional**, which `G(0)` is not, so its recurrent part is
a union of cycles rather than a graph; those cycles carry a **constant offset
sign**; and each is a **prefix-vs-interior** occurrence pair with the
integrality condition `ab(Q) ∈ (I − M^r) Z^A`. That condition is the exact
analogue of Theorem B's `w_0 ∈ Z^A`, and it is the point at which the
unimodularity used in the prior art is replaced by an explicit hypothesis
rather than an assumption.

## 5. Literature gate (stop/go, 2026-10-05)

*Proposed claim under review.* Proposition LC above, and the use of its cycle
enumeration as a route to T1.

| Source | What it gives | Where it stops |
| --- | --- | --- |
| A. Siegel, J. M. Thuswaldner, *Topological properties of Rauzy fractals*, Mém. SMF 118 (2009), Def. 5.1, Prop. 5.2, §5.2, §5.4, §6.3 | the **zero-expansion graph** `G(0)`, whose nodes are exactly the `[gamma, i] ∈ Γ_srs` with `0 ∈ T(i) + gamma`, and which is built as the *largest* graph all of whose nodes lie on infinite paths; **boundary** and **contact graphs** for the intersections `T(i) ∩ (T(j) + gamma)`, which are the internal-representation form of this programme's overlap vertices; the **geometric property (F)** as "0 lies in only one subtile", i.e. the finiteness of the Dumont–Thomas expansion | Prop. 5.2 is stated for a primitive **unit** Pisot substitution, and its proof uses that hypothesis at the decisive step — "`gamma_{l+1} ∈ pi(Z^n)` by the unimodularity of `M`" — which is exactly the `M^{-1}`-integrality that Proposition LC(4) has to carry as the explicit condition `ab(Q) ∈ (I − M^r) Z^A`. The graphs are in the contracting representation and are not functional, so there is no sign invariant and no prefix-vs-interior dichotomy |
| M. Minervino, J. M. Thuswaldner, *The geometry of non-unit Pisot substitutions*, Ann. Inst. Fourier 64 (2014) | the correct representation space for the non-unit case, with finite-place coordinates | it supplies the space, not a distinguished pointwise hit; already recorded as unengaged by `audit-2026-09-20.md` §246 and `audit-2026-09-27.md`, and this note does not close that gap either |
| S. Akiyama, property (F)/(W) for `beta`-numeration; M. Barge, arXiv:1505.04408, Cor. 17 | the dictionary: a resolved carry is a finite expansion, and (W) is equivalent to pure discrete spectrum | the route check of `p1b-vertex-coincidence-box-2026-10-02.md` §5.7 already stopped this: Barge's (W) is a *consequence* of pure discrete spectrum, so it cannot be used to reach PPVC independently of it. Proposition LC does not use (F) or (W) |
| J.-M. Dumont, A. Thomas, *Systèmes de numération et fonctions fractales relatifs aux substitutions* (1989) | the numeration whose carry automaton the box graph is; the prefix–suffix walk | a numeration, not a finiteness theorem |

*Hypotheses that transfer.* Primitivity, and the identification of the overlap
graph with a boundary graph. *Hypotheses that do not.* Unimodularity, used in
the prior art's zero-expansion proposition and void for the 210 catch-up-free
corpus specimens, all of which have `|det M| >= 2` (Lemma P is empty when
`Λ = Z^A`).

*Known negative controls.* Tribonacci `0 -> 01, 1 -> 02, 2 -> 0` has **no**
terminal leftmost cycle: every nonzero-offset vertex reaches a catch-up, so
`CU` is everything and Proposition LC is vacuous there — the expected
behaviour for a unimodular specimen. At the other extreme the catch-up-free
specimens have no vertex in `CU` at all (Lemma P), so every nonzero-offset
vertex must run into a cycle; the census checks both extremes.

*Decision: **proceed with a narrowed target.*** Do not claim novelty for
"cycles of a finite graph classify non-resolving expansions" — cite
Siegel–Thuswaldner Def. 5.1 for it. Claim only the functional/sign/
prefix-vs-interior structure and the integrality condition, in the non-unit
regime. Do **not** attempt T1's reachability half from here: §6 states why it
does not follow.

## 6. What this gives for T1, and what it does not

Write `D` for the set of vertices with no descendant in `CU` — the Q1-failing
set — and `D_0` for its nonzero-offset part.

*Corollary LC1 (the failure set is leftmost-stable).* `D` is closed under
children, and the leftmost step maps `D_0` into `D_0`. Hence every vertex of
`D_0` runs into one of the cycles of Proposition LC, and `D_0` is contained in
their basins.

*Proof.* If a child of `v` reached `CU` so would `v`. If the leftmost child of
`v ∈ D_0` had offset zero then `v ∈ CU`; so it is in `D` and nonzero. `square`

*Corollary LC2 ("reaches `CU`" is an SCC invariant).* Vertices in one strongly
connected component of the box graph are mutual descendants, so either all of
them reach `CU` or none does. Therefore T1 is equivalent to an SCC-level
statement: *if `sigma` is not catch-up-free, every recurrent nonzero-offset
SCC either reaches `CU` or is terminal, of size at most two, with every child
outside it offset zero* — the second case being exactly where the mass lemma
of §5.6c already applies.

*Corollary LC3 (the obstruction is finitely parameterised).* The cycles of
Proposition LC are indexed by tuples `(r, i, j, Q)` with `f^r(i) = i`,
`sigma^r(j) = Q j V` interior, and `ab(Q) ∈ (I − M^r) Z^A`. At most three
letters are `f`-periodic, so the prefix side contributes at most three
fixed rays, one per periodic starting letter of `f`.

**What does not follow.** Proposition LC says what a failure of `CU` looks
like; it says nothing about which vertices are in the basin of such a cycle.
T1's content is the *reachability* claim — that one catch-up hit anywhere
forces a catch-up hit reachable from every non-short-periodic recurrent
vertex — and that is a hitting statement of the same kind as
`AdelicPeriodicOffsetHitting`: a descendant must land on one of the finitely
many specific offsets `M^{-1} ab(P)`, not merely in a coset. Nothing here
makes that easier, and this note does not claim progress on it. What it does
change is the shape of the target: by LC2 the question is about SCCs, not
vertices, and by LC3 the witnesses to avoid are an explicitly enumerable
finite list.

## 7. Exact certificate

`kernel/psc/leftmost_chain.mojo` reads every terminal leftmost cycle off a box
graph and certifies, per cycle:

- **claims 1–3, at every `r`.** The sign is checked at every vertex of the
  cycle in the exact Perron field, and the two composite indices in `sigma^r`
  are computed from the child indices the walk recorded. This is integer
  combinatorics and needs no large arithmetic.
- **claim 4, only for `r <= max_integral_r` (12 by default).** The cycle
  equation `(I − M^r) w_0 = ab(Q)` is solved and then replayed over `Z`
  against the cycle vertex's own offset, through
  `psc.periodic_pair.centre_offset` and the exact position map. `M^r` leaves
  the 64-bit range well before the longest cycles observed, so beyond that
  bound the offset is left uncomputed.

Two failure modes are reported rather than absorbed:

- a cycle with `r` beyond the exact integer range for `M^r` has its offset
  **not computed** and is counted in its own column; an uncomputed offset is
  never read as a pass;
- a **capped** box graph makes the whole verdict inconclusive.

The census results and the corpus figures are in §8.

## 8. Census

`pixi run leftmost-chain-census` on the standing corpus of 4,554 PIP
specimens, exact, no capped box graph.

| | count |
| --- | --- |
| specimens | 4,554 |
| terminal leftmost cycles | 10,584 |
| sign kept along the cycle (claim 1) | **10,584 / 10,584** |
| prefix-vs-interior shape (claims 2–3) | **10,584 / 10,584** |
| cycle equation replayed over `Z` (claim 4) | 10,128 |
| beyond the exact integer range (`r > 12`) | 456 |
| failed replays | **0** |
| longest cycle | `r = 39` |
| specimens with no terminal cycle | 1,794 |
| catch-up-free specimens with a terminal cycle | 210 / 210 |

An earlier stride-7 slice of 651 specimens gave 1,478 cycles with the same
verdict and `r <= 30`.

**Pinned specimens** (`kernel/tests/test_leftmost_chain.mojo`):

| `sigma` | catch-up-free | cycles | `r` | offsets |
| --- | --- | --- | --- | --- |
| `0 -> 01, 1 -> 02, 2 -> 0` (Tribonacci) | no | **0** | — | — |
| `0 -> 1, 1 -> 12, 2 -> 022` | no | 2 | 1 | both over Z, `w_0 = (0, 1, -1)` |
| `0 -> 1, 1 -> 012, 2 -> 010` | yes | 2 | 6 | both over Z |
| `0 -> 1, 1 -> 22, 2 -> 012` | yes | 2 | 15 | past the integer range, uncomputed |

The two extremes are the controls of §5, and both come out as they must: all
210 catch-up-free specimens have a cycle, because Lemma P puts none of their
vertices in `CU`; and 1,794 specimens have none at all.

**Cycle counts in the catch-up-free class** (all 210, exact): 2 cycles on 120
specimens, 4 on 48, 6 on 18, 8 on 12, 10 on 6, more on 6. Never odd — which is
Corollary LC4.

## 8a. Two corollaries the census sharpened

*Corollary LC4 (cycles come in mirror pairs).* Terminal leftmost cycles are
exchanged in pairs of opposite sign by the tiling swap, so their number is
even.

*Proof.* Proposition `prop:aligned-overlaps` of the manuscript exchanges the
roles of the two tilings by `(a, b, t) -> (b, a, −t)`, a bijection on vertices
commuting with inflation. It translates the region by `−t`, so it carries the
child containing the parent's left end to the child containing the parent's
left end: leftmost chains go to leftmost chains, and terminal cycles to
terminal cycles. It negates the offset, so by claim 1 it reverses a cycle's
sign. The whole original cycle has one strict sign and its image has the
opposite strict sign, so the two cycles cannot coincide even as unbased
cycles. Thus the involution is free on cycles and they pair off.
`square`

This is why the catch-up-free counts above are 2, 4, 6, 8, 10 and never 1, 3,
5, and why the corpus total 10,584 is even. It also halves the work: one cycle
per mirror pair carries all the information.

*Corollary LC5 (a sufficient condition for G1).* If the box graph of `sigma`
has **no** terminal leftmost cycle, then `Z(s) = ∅` for every swap seed `s`, so
all-seed strict-zipper exclusion holds for `sigma` and **G1 holds for
`sigma`** by manuscript Proposition 5.47.

*Proof.* No terminal cycle means every nonzero-offset vertex of the box graph
lies in `CU`, i.e. its leftmost chain reaches offset zero, so it has a
left-aligned descendant. Suppose `Z(s) != ∅`. It is finite and closed under
children, so it contains a terminal strongly connected component, whose
vertices lie on cycles of the overlap graph and therefore inside the box graph
(`box_radii`, Proposition V step 1, bounds the offset of every overlap on a
cycle). Those vertices have no left-aligned descendant by the definition of
`Z(s)`, contradicting the previous sentence. So `Z(s) = ∅`, which is Corollary
5 of the depth note's hypothesis. `square`

**This covers 1,794 of the 4,554 standing specimens — 39%.** It is not a new
finite-domain result: G1 is already certified on the whole standing corpus by
the Proposition V census (§4 and the finite-domain statement of
`p1b-vertex-coincidence-box-2026-10-02.md`), and the balanced-pair builds
certify it there directly. What LC5 adds is a *cheaper and more structural*
certificate on those 1,794: it needs only the leftmost **function** — one walk
per vertex, no descendant-closure analysis and no depth bound — and its
hypothesis is a statement about occurrences, by LC3. It is one-directional: a
terminal cycle does not make G1 fail, because a cycle vertex may still have a
left-aligned descendant through a non-leftmost child.

## 8b. Why the one-tile route could not have worked, in terms of objects

§5.6b of the box note established by census that "the cross-letter rigidity is
not a one-tile question": Q1 fails on 360 of 4,554 specimens. Proposition LC
says *why*, in terms of the objects rather than the counts, and the two
families separate cleanly:

| | Theorem B pair | Proposition LC pair |
| --- | --- | --- |
| occurrences | interior **and** interior | **prefix** and interior |
| the centre `c` is | a vertex of neither tiling, at any level | a vertex of one of infinite level, interior to every level tile of the other |
| is `c` ever a common vertex? | **open** — that is PPVC | **never**, by construction |
| how many on the corpus | the ones PPVC decides | 10,584, on 2,760 specimens |
| obstructs G1? | yes, when no vertex is shared | **no** |

The one-tile question asks whether the left endpoint of a region — the centre
of a Proposition LC pair — is an eventual subdivision boundary of the other
tiling. By claim 5 it never is: that centre is interior to every level tile of
the other tiling, for all time. So `CU`-failures are not accidents to be
excluded; they are a structurally forced, abundant family, and they cost
nothing — G1 holds on the whole standing corpus regardless, by the Proposition
V census, while 10,584 of these pairs sit in it.

The consequence for where to spend effort is the useful part. **The genuine
obstruction to #139 is the interior-vs-interior pair**, where the centre is a
vertex of neither tiling and whether the pair shares a vertex *elsewhere* is
open. That is exactly what `psc.periodic_pair` certifies and what PPVC asks.
Work on #139 belongs there, not on the leftmost chain. What the leftmost chain
is good for is Corollary LC5: a cheap sufficient condition that discharges
finiteness for 1,794 specimens without any closure analysis.

This also places T1 precisely. T1 asks for catch-up *reachability*, which is a
statement about which vertices fall into the basins of this harmless family.
Proving it would complete the §5.6c trichotomy and hence PPVC — so T1 is not
wasted effort — but its content is a pointwise hitting problem (§6), and the
route to it does not run through the structure of the cycles, which is now
known.

## 9. What this does not establish

- **Not T1, and not T2.** §6 states exactly which half of T1 is untouched —
  the reachability half, which is the hard one. T2 is not addressed at all.
- **Not PPVC, #139, G1 or PSC for the family.** Proposition LC is a structure
  theorem for the witnesses of `CU`-failure, not an exclusion of them. The
  catch-up-free class is where witnesses provably exist, and nothing here
  shrinks it. The ledger's `G1` is the **uniform** hypothesis, for every PIP
  `sigma`, and it remains open: Corollary LC5 discharges finiteness only for
  an individual substitution whose hypothesis it has verified — 1,794 of the
  standing corpus — and says nothing about the other 2,760, nor about any
  infinite family. The uniform statement would need LC5's hypothesis for all
  PIP `sigma`, and that is false: the 210 catch-up-free specimens all have
  cycles. So LC5 is a decision procedure with a wide sufficient condition, not
  a route to uniform G1 on its own.
- **No novelty is claimed for the cycle principle.** That is
  Siegel–Thuswaldner's zero-expansion graph (§5). The narrowed claim is the
  functional/sign/prefix-vs-interior structure and the integrality condition,
  in the non-unit regime their Proposition 5.2 excludes.
- **The census is a finite-domain statement.** It certifies the proposition on
  the specimens it covers, by exact certificate, and says nothing outside
  them. Proposition LC's proof is what covers the rest; the census is there to
  refute it if the proof is wrong.
- **The Minervino–Thuswaldner gap is still open.** This note cites the
  non-unit representation space without engaging it, as the 09-20 and 09-27
  audits record.
