# P1b: strict zippers as vertex-disjoint periodic pairs — 2026-10-02

**Status:** research note for issue #139, proved here. Reviewed by the
independent adversarial audit of 2026-10-04, which found no counterexample to
Lemma C, Theorem B or Corollary B′ and applied fifteen dated corrections
across these notes (`docs/side-notes-ledger.md` §7); human review is still
pending.

**Load-bearing as of 2026-10-04.** Theorem B and Corollary B′ are inputs to
manuscript Proposition `prop:PDS-implies-G1` and so to the ledger node
`PDSImpliesRepoG1` (PDS implies G1), which is recorded as repository-proved.
Changing either statement changes that claim. Theorem B was re-derived
independently in `docs/audit-2026-10-04.md` §B.4, which confirms in particular
that its realization step does not breach the firewall on formal recurrence:
it builds `Phi^r`-fixed tilings from *interior* occurrences, whose patches are
allowed for `sigma`, and takes integrality of the centre offset from the cycle
equation rather than by assumption.

Proposition A, Lemma C and Theorem B are elementary statements about the
seed-patch overlap graph and are proved in full below. §5 compares them with
the literature; the fibre identification it uses is Proposition F of the
companion gate, proved there for every PIP substitution (Theorem R of that
gate removes its hypothesis (R)). This note still does
**not** exclude strict zippers, and does not prove AdelicPeriodicOffsetHitting,
G1 unconditionally, or balanced-pair termination.

Dependencies:

- `bpa-termination-by-overlap-depth-2026-10-02.md` §5 (Proposition 4,
  Corollary 5; manuscript Proposition 5.47);
- `p1b-adelic-prefix-difference-cylinder-2026-09-21.md` §§3–6;
- manuscript Proposition 5.44(iii)(b) and Lemma 5.45.

## 1. Conventions

`sigma` is primitive irreducible Pisot on `A`, with `M[a][b] = |sigma(b)|_a`,
`pi(sigma(u)) = M pi(u)`, and tile lengths `ell` (`ell M = beta ell`). Since
the coordinates of `ell` are `Q`-independent, `<ell, z> = <ell, z'>` exactly
when `z = z'` for `z, z'` in `Z^A`.

An overlap `v = (i, j, w)` places tile `i` on `[0, ell_i)` in tiling A and
tile `j` on `[x, x + ell_j)` in tiling B, where `x = <ell, w>` and the two
open intervals meet. Its **region** is `R_v = (0, ell_i) ∩ (x, x + ell_j)`.
Its children are the overlaps of the `sigma`-subdivisions of the two tiles
scaled by `beta`. Their closed regions partition `beta·cl(R_v)` and meet only
at endpoints. A child is **leftmost** (resp. **rightmost**) when its region
contains the left (resp. right) end of `beta R_v`. For an edge `v -> v'` let
`e: cl R_{v'} -> cl R_v` be the increasing affine contraction (ratio
`1/beta`) that maps the child's region onto its place in `R_v`.

`v` is **left-aligned** (offset zero) when both tiles start at the same
point, and **right-aligned** when both end at the same point. A common vertex
of the two level-`m` patches is a point that is a tile endpoint in both.
Writing `D_m(i, j) = P_m(i) − P_m(j)` for the prefix-difference set:

> (H) `v = (i, j, w)` has an offset-zero descendant at depth `m`, i.e. a
> common vertex in the half-open interval `[left end, right end)` of
> `beta^m R_v`, iff `M^m w ∈ D_m(i, j)` (`P_m` is the set of *proper*
> prefixes). Because `M P_m(a) ⊆ P_{m+1}(a)`, this property is monotone in
> `m`. *Correction 2026-10-04:* an earlier version said "in `cl R_v`"; a
> common vertex at the right end alone (e.g. a right-aligned `v` with
> `w != 0`) is not seen by (H). Theorem B(3) is unaffected, since in the
> periodic setting every common vertex is seen at some depth `rn`.

This is the boundary-hitting criterion already used by the P1b notes.

`Z = Z(s)` is the set of vertices reachable from the seed overlaps of `s`
that have no left-aligned descendant (Corollary 5 of the depth note). It is
closed under children.

## 2. Proposition A (alignment at either end)

Let `Z'' ⊆ Z` be the set of reachable vertices that have **neither** a
left-aligned **nor** a right-aligned descendant (depth 0 included).

*Proposition A.* Suppose `Z''(s) = ∅`. Let `K''` be the largest depth, over
reachable vertices, of the first descendant that is aligned at either end.
Then every state reached from `s` at level `n >= K''` has geometric length
at most `2 beta^{K''} ell_max`, so the closure of `s` is finite.

*Proof.* This is the proof of Proposition 4 of the depth note with one change.
Suppose the aligned descendant `O'` of `O` (at depth `k <= K''`) is
right-aligned. Then the common right endpoint `y` of its two tiles is a
common vertex, and it lies in the closure of the region `R` that contains
`t`. Subdivision keeps `y` a common vertex at level `n`, and manuscript Lemma
5.30 makes it a balanced cut within `beta^{K''} ell_max` of `t`. `square`

*Corollary A′ (right-aligned strict zippers are suffix-coincidence
failures).* `Z'' ⊆ Z`, and both sets are closed. If `Z ≠ Z''`, then `Z`
contains a right-aligned vertex `u = (p, q, ·)` with `p ≠ q`, and the pair
`(p, q)` fails **suffix** strong coincidence. That is, there is no `n` with
`sigma^n(p) = u₁ c v₁` and `sigma^n(q) = u₂ c v₂` such that
`pi(v₁) = pi(v₂)`.

*Proof.* Take `v ∈ Z \ Z''`. It has a right-aligned descendant `u`, and `u`
lies in `Z` because `Z` is closed. If `p = q`, then `u` is a coincidence,
which is offset zero. Suppose suffix strong coincidence held for `(p, q)` at
level `n`. The two copies of `c` would end at the same point
`y − <ell, pi(v₁)>` of the level-`n` patches (in level-`n` units). They would therefore
be one tile, lying inside both parent tiles and hence inside `cl R_u`. That
is an offset-zero descendant of `u ∈ Z`, a contradiction. `square`

So the strict-zipper branch splits further:

- **(b1)** closed strict zippers that contain a right-aligned vertex. These
  are the mirror image of case (a), suffix rather than prefix strong
  coincidence, and by Proposition A they do not obstruct finiteness.
- **(b2)** **two-sided strict zippers**: nonempty closed sets with no vertex
  aligned at either end. These are the only obstruction to G1 along this
  route.

When every pair of distinct letters satisfies suffix strong coincidence,
`Z = Z''`, and Proposition A gives nothing beyond Proposition 4. The gain is
confined to substitutions where suffix strong coincidence fails. No such
irreducible Pisot example is known (it would be a counterexample to the strong
coincidence conjecture for the mirror substitution `a -> reverse(sigma(a))`), so the practical content
of Proposition A is structural: it moves (b1) onto the mirror of P1a.

## 3. Lemma C (cycles with interior centre)

*Lemma C.* Let `Y` be a finite nonempty set of non-coincidence vertices that
is closed under children (for example `Z` or `Z''`), so that every vertex of
`Y` has a child in `Y`. Edges are labelled by the child indices (children
counted with multiplicity), so leftmost and rightmost edges are distinct even
between vertices of the same type. Then `Y` contains a cycle
`v_0 -> v_1 -> … -> v_r = v_0` whose composite contraction
`E = e_0 ∘ … ∘ e_{r−1}: cl R_{v_0} -> cl R_{v_0}` has its fixed point `c` in
the **open** region `R_{v_0}`.

*Proof.*

1. **Fixed points on the boundary.** Each `e_k` is increasing with image
   inside `cl R_{v_k}`. Hence `E` fixes the left end of `R_{v_0}` exactly when
   every edge of the cycle is a leftmost child (the child whose region's
   closure contains the left end). It fixes the right end
   exactly when every edge is a rightmost child.
2. **Every cycle has a branching vertex.** If every vertex on a cycle had a
   single child, region lengths would multiply by `beta` at each step, giving
   `|R_{v_0}| = beta^r |R_{v_0}|`. So every cycle passes through a vertex
   `u` with at least two children. At `u` the leftmost and rightmost children
   differ.
3. **Building the cycle.** Let `C` be a terminal strongly connected
   component of `Y`. It exists because `Y` is finite and every vertex has a
   child. Every child of a vertex of `C` lies in `C`. Pick a cycle `γ` in `C`
   through a branching vertex `u`.
   - If `γ` uses neither only leftmost nor only rightmost edges, step 1 puts
     its fixed point in the interior.
   - If `γ` uses only leftmost edges, let `u''` be the rightmost child of
     `u`. It is in `C`, and `C` contains a path from `u''` back to `u`. The
     cycle `(u -> u'' -> … -> u)·γ` contains a non-leftmost edge
     (`u -> u''`). It also contains the leftmost edge of `γ` at `u`, which is
     not rightmost, so step 1 again puts the fixed point in the interior.
   - If `γ` uses only rightmost edges, argue symmetrically.

`square`

## 4. Theorem B (periodic-pair form of a strict zipper)

For `r >= 1` and `a ∈ A`, an **interior occurrence** is a factorisation
`sigma^r(a) = P a U` with `P` and `U` both nonempty. It determines the
`Phi^r`-fixed tiling `T(a, P)`, defined as follows:

- place `a` on `[0, ell_a)`;
- its centre is `c = <ell, pi(P)>/(beta^r − 1)`, which lies in `(0, ell_a)`;
- `T(a, P)` is the increasing union of the inflate-and-subdivide images of
  the tile about `c`.

Every patch of `T(a, P)` lies inside some `sigma^{rn}(a)`, so it is legal,
and `T(a, P) ∈ X_sigma` is fixed by `Phi_c^r`, inflation by `beta^r` about
`c` followed by subdivision. In lifted coordinates the centre is
`gamma(a, P) = (M^r − I)^{−1} pi(P) ∈ Q^A`, and `<ell, gamma> = c`.

*Theorem B.* Let `r`, `i`, `j`, `sigma^r(i) = P i U` and
`sigma^r(j) = Q j V` be interior occurrences, and put
\[
 w_0 = (M^r - I)^{-1}\bigl(\pi(P) - \pi(Q)\bigr). \tag{1}
\]
If `w_0 ∈ Z^A`, then:

1. `T_A = T(i, P)` and `T_B = T(j, Q) + <ell, w_0>` have the same centre `c`,
   and `c` lies in the region of the overlap `v_0 = (i, j, w_0)`;
2. the depth-`r` descendant of `v_0` whose region contains `c` is `v_0`
   itself, so `v_0` lies on an `r`-cycle of the overlap graph;
3. the following are equivalent:
   - (a) `v_0` has no left-aligned descendant;
   - (b) `T_A` and `T_B` have no common vertex;
   - (c) `M^m w_0 ∉ D_m(i, j)` for every `m >= 0`.

Conversely, let `Y` be a nonempty closed set with no left-aligned vertex (in
particular, any `Y = Z(s) ≠ ∅`). Lemma C gives a cycle in `Y` with interior
centre; it lies in a terminal component of `Y`, not necessarily through a
prescribed vertex. Composing its prefixes, `P = sigma^{r−1}(p_0)…p_{r−1}` and
likewise `Q`, gives interior occurrences that satisfy (1) with
`w_0 ∈ Z^A` and (a)–(c).

*Proof.*

1. **Common centre.** `ell (M^r − I)^{−1} = ell/(beta^r − 1)`, so
   `<ell, w_0> = c_A − c_B`, where `c_A` and `c_B` are the centres of
   `T(i, P)` and `T(j, Q)`. Shifting `T(j, Q)` by `<ell, w_0>` moves its
   centre to `c_A`. Both centres are interior to their tiles, so `c ∈ R_{v_0}`.
2. **The `r`-cycle.** Inflating `v_0` about `c` by `beta^r` maps tile `i`
   onto the patch `sigma^r(i)`, and `T_A` is fixed, so the sub-tile containing
   `c` is the original tile `i`. The same holds for `j` in `T_B`. The overlap
   of these two sub-tiles is `v_0` again.
3. **(a) ⇒ (b).** The regions `phi^n(R_{v_0})`, images under the expanding
   map fixing `c`, increase to `R` because `c` is interior. Any common vertex
   `y` of `T_A` and `T_B` lies in some `phi^n(R_{v_0})`. The overlap of the
   level-`rn` patches that starts at `y` is then a left-aligned descendant of
   `v_0`. (If `y` were the left end of `phi^n(R_{v_0})`, enlarge `n`.)
4. **(b) ⇒ (a).** A left-aligned descendant at depth `m` is a common vertex
   of `Phi_c^m T_A` and `Phi_c^m T_B`. Inflation keeps vertices, so its image
   is a common vertex of `Phi_c^{rk} T_A = T_A` and `T_B` for any `rk >= m`.
5. **(b) ⇔ (c).** This is (H), together with step 3's observation that every
   common vertex is seen at some depth `rn`.
6. **Converse.** Iterating the cycle's child steps gives
   `w_r = M^r w_0 + pi(Q) − pi(P)`, so `w_r = w_0` is (1); this is manuscript
   Lemma 5.45. The interior centre from Lemma C makes `P` and `U`, and `Q` and
   `V`, nonempty. Closedness of `Y` gives (a).

`square`

*Corollary B′ (reformulation of #139).* `Z(s) ≠ ∅` iff some interior
occurrence pair `(r, i, j, P, Q)` with `w_0 ∈ Z^A`, whose `v_0` is reachable
from `s`, gives two `Phi^r`-fixed legal tilings with a common centre and no
common vertex. The cycle length `r` may be taken at most twice the size of
the overlap graph. Hence strict-zipper exclusion from every swap seed, and
with it G1 by Proposition 4, follows from:

> **PeriodicPairVertexCoincidence (open).** For every primitive irreducible
> Pisot `sigma`, every `r >= 1` and every pair of interior occurrences with
> `w_0 ∈ Z^A` in (1), the tilings `T(i, P)` and `T(j, Q) + <ell, w_0>` share
> a vertex.

By (c), this is AdelicPeriodicOffsetHitting restricted to centre-difference
offsets. It is equivalent to it on the reachable part, since by Lemma C every
recurrent strict-zipper component contains such an offset. The forcing
digits of the adelic note's §4 become two prefix words `P` and `Q`. In the
internal (adelic) coordinates, `w_0* = xi_B − xi_A`, where
`xi_A = (I − B^r)^{−1} pi(P)*` is the purely periodic point of the Rauzy
subtile `X_i` with address `(P, P, …)`, and likewise `xi_B ∈ X_j`. So the
target asks for one finite-level prefix difference to land exactly on the
difference of two periodic Rauzy points.

## 5. Comparison with the literature

Barge, *Factors of Pisot tiling spaces and the Coincidence Rank Conjecture*
(arXiv:1301.7094), Theorem 4, collects from Barge–Kellendonk the following:
the map `g` to the maximal equicontinuous factor is a.e. `cr`-to-one; `cr = 1`
iff the spectrum is pure discrete; and each fibre contains `cr` tilings that
share no tile under any `Phi^k`. The proof of its Theorem 5 states that
without pure discrete spectrum there are `Phi`-periodic `T` and `T′` with
`g(T) = g(T′)` and **no common tile**.

Theorem B produces `Phi^r`-periodic pairs with **no common vertex**, a
strictly stronger disjointness. That the pair lies in one fibre is
Proposition F of `p1b-periodic-pair-fibre-literature-gate-2026-10-02.md`. It
is proved there from Solomyak's eigenvalue criterion, without unimodularity.
It needs the return module to be all of `Z^3`, and Theorem R of that gate
proves this for every PIP substitution. So, for every PIP `sigma`:

| Obstruction | Periodic pair in one fibre | Known status |
| --- | --- | --- |
| non-PDS | no common **tile** | equivalent to `cr >= 2` (BK, Barge 2013) |
| case (a) aligned | common vertices, no common tile | P1a, open |
| (b1) right-aligned | as (a), mirrored | suffix P1a, open |
| (b2) two-sided strict zipper | no common **vertex** (failure of PPVC; a formal strict zipper, of which a seed-reachable one is a special case) | #139, open |

Consequences:

- A strict zipper forces `cr >= 2` (imports audited in
  `coincidence-rank-imports-literature-gate-2026-10-04.md`). Within the
  repository, pure discrete spectrum excludes strict zippers only through
  that Theorem S; "PDS ⇒ productivity" is not imported (manuscript, remark
  after Theorem 5.38), and PDS ⇒ formal productivity needs SC_all as well.
  *Correction 2026-10-04:* an earlier version called this "the known chain".
- Strict-zipper exclusion asks for a **vertex** analogue of coincidence rank
  one along periodic fibres. It is weaker than the Pisot conjecture but not
  implied by any unconditional result found: balanced-pair termination, its
  equivalent by Sirvent–Solomyak Theorem 5.6, is known for two letters
  (Hollander–Solomyak) and open beyond.
- A density argument does not close it. Generic fibres of a hypothetical
  `cr = 2` substitution with measure-disjoint Rauzy subtiles would contain
  vertex-disjoint pairs. So any proof has to use periodicity, or integrality
  of (1), and not counting.

## 6. Exact certificate (`psc.periodic_pair`)

`kernel/psc/periodic_pair.mojo` is the canonical implementation of Theorem B's
certificate. For an ordered pair of interior occurrences, `certify_pair`:

1. computes `w_0` from (1) over `Z` with the adjugate of `M^r − I` and
   replays `(M^r − I) w_0 = pi(P) − pi(Q)`; a non-integral `w_0` is
   reported as such;
2. checks that `v_0` is an interior overlap and replays the `r`-cycle of
   Theorem B(2) child by child, in the exact Perron field, back to `v_0`;
3. builds the descendant closure of `v_0`, which is finite by manuscript
   Theorem 4.22, and decides (a) on it. A complete closure with no
   offset-zero vertex is a **strict-zipper certificate**. An offset-zero
   vertex at depth `m` is a shared vertex, and `m` is re-derived over `Z` as
   the least `m` with `M^m w_0 ∈ D_m(i, j)` (criterion (c)). The two depths
   must agree, or the certificate is refused;
4. reports a capped closure as capped, never as a verdict.

Acceptance is by exact integer and `Z[beta]` equality. No adelic coordinate
is computed, so the local-field bindings of §8 of the adelic note are neither
needed for these verdicts nor supplied by them.

`kernel/tests/test_periodic_pair.mojo` pins the census over all ordered pairs
of interior occurrences with distinct letters. An independent integer-only
oracle (not committed) gave the same numbers:

| Specimen | `r <=` | pairs | `w_0` integral | share a vertex | strict zipper | deepest `m` |
| --- | --- | --- | --- | --- | --- | --- |
| Tribonacci `0→01, 1→02, 2→0` | 6 | 908 | 18 | 18 | 0 | 3 |
| cube `0→1, 1→222, 2→0222` | 3 | 232 | 8 | 8 | 0 | 1 |
| golden pump `0→1, 1→021, 2→001` (det 2) | 4 | 366 | 20 | 20 | 0 | 7 |

All three are known productive, so these are consistency checks of Theorem
B's bookkeeping. They are not evidence for PeriodicPairVertexCoincidence
beyond the pairs enumerated. No positive strict-zipper control exists in the
standing regime, since none is known.

## 7. What this does not establish, and next steps

- No strict zipper is excluded. PeriodicPairVertexCoincidence is open, and it
  is as hard as the balanced-pair termination conjecture along this route.
- Proposition A is a weakening of the hypothesis of manuscript Proposition
  5.47. Promoting it would mean a manuscript remark and a ledger refinement
  of `AllSeedStrictZipperExclusion` to the two-sided form. That needs review
  first.
- Barge–Diamond 2002 has been read in full
  (`p1b-barge-diamond-configuration-gate-2026-10-02.md`). Its configuration
  argument does not force a common vertex: its maximality step only yields an
  aligned pair, which shares a vertex already. Barge's β-substitution proof
  closes that step with a monotonicity property of the β-language that
  general PIP substitutions lack. Decision there: stop.
- PeriodicPairVertexCoincidence is decidable per substitution, for every `r`
  at once, on one finite box graph
  (`p1b-vertex-coincidence-box-2026-10-02.md`, Proposition V). It holds on
  the finite domains surveyed there. It remains open in general.
