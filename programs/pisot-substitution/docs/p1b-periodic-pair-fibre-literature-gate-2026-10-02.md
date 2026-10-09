# Literature gate: the fibre identification for strict-zipper periodic pairs — 2026-10-02

**Status:** stop/go literature gate for §5 of
`p1b-strict-zipper-periodic-pair-2026-10-02.md`. **Decision: proceed.**
Proposition F below, proved here, puts the two tilings of Theorem B in one
fibre of the maximal equicontinuous factor. It was first proved under a
hypothesis (R), the return module is all of `Z^3`. §5 now proves (R) for
every primitive substitution whose frequency vector has `Q`-independent
coordinates, in particular for every PIP substitution (Theorem R), so
Proposition F holds without hypothesis. Nothing here excludes a strict zipper
or proves PeriodicPairVertexCoincidence, AdelicPeriodicOffsetHitting, G1 or
the Pisot substitution conjecture.

## 1. Exact claim under review

For a primitive irreducible Pisot `sigma` on three letters, take interior
occurrences `sigma^r(i) = P i U` and `sigma^r(j) = Q j V` with
`w_0 = (M^r − I)^{−1}(pi(P) − pi(Q)) ∈ Z^3`. Let `T_A = T(i, P)` and
`T_B = T(j, Q) + <ell, w_0>`, the two `Phi^r`-fixed tilings with common centre
`c` (Theorem B). The claim is:

> (F) `g(T_A) = g(T_B)`, where `g: X_sigma → X_max` is the factor map onto
> the maximal equicontinuous factor of the translation action.

The note's §5 stated (F) as a reading resting on "the standard description of
`g` through Rauzy addresses". This gate replaces that reading with a proof
that uses only the eigenvalue criterion, and records the one hypothesis it
needs.

## 2. Sources inspected

| Source | Statement used | Read |
| --- | --- | --- |
| M. Barge, J. Kellendonk, *Proximality and pure point spectrum for tiling dynamical systems* (arXiv:1108.4065) | Thm 3.4 and Cor 3.5: for Meyer tilings, proximal means strongly proximal, and pairs in one fibre come in finitely many local configurations. Thm 5.1 (citing Solomyak): every eigenfunction of a substitution tiling space can be chosen continuous. Lemma 5.12: two tilings in one fibre that are not proximal share no tile. Thm 5.10 and Cor 5.11: the factor `X_max` is a solenoid of dimension equal to the degree, a torus in the unit case. | §§2.2, 3, 5 |
| M. Barge, *Factors of Pisot tiling spaces and the Coincidence Rank Conjecture* (arXiv:1301.7094) | Thm 4, collected from BK: (1) `g` is a.e. `cr`-to-one; (2) each fibre holds `cr` tilings sharing no tile under any `Phi^k`; (5) pure discrete spectrum iff `cr = 1`; (6) `g(T) = g(T')` iff `T` and `T'` are strongly regionally proximal. Proof of Thm 5: without pure discrete spectrum there are `Phi`-periodic `T` and `T'` with `g(T) = g(T')` and no common tile. | §§1–3 |
| M. Barge, J.-M. Gambaudo, *Geometric realization for substitution tilings* (arXiv:1111.6641) | §3: global shadowing, meaning lifts to an abelian cover of the Anderson–Putnam complex with deck group `GR(Phi)`, the generalized return vectors. Prop 24: global shadowing implies regional proximality. Prop 25 and Thm 4: they are equal when `D(Lambda) = D(GR)`. Thm 8: the realization is `g` in the `(m, d)`-Pisot-family case. **Unimodular only.** | §§2–4, 8 |
| M. Barge, *The Pisot conjecture for beta-substitutions* (arXiv:1505.04408) | Item (3) of §1, citing BKw, BBK, BK and Barge: `g(T) = g(T')` iff strong regional proximality, and pairwise strongly regionally proximal, pairwise tile-disjoint `T_1, …, T_r` exist iff `r <= cr`. Lemma 2: a configuration argument (after Barge–Diamond 2002) on `Psi`-fixed, pairwise tile-disjoint tilings in one fibre. | §§1–3 |
| J.-Y. Lee, B. Solomyak, *Pisot family self-affine tilings, discrete spectrum, and the Meyer property* (arXiv:1002.0039) | Proof of Prop 4.1, restating Solomyak (1997), Thm 3.13: `gamma` is an eigenvalue iff `e^{2 pi i <phi^n x, gamma>} → 1` for every return vector `x ∈ Ξ = {x : T + x ∈ T for some tile T}`. | §§2, 4 |

Not read directly, used only through the restatements above: Solomyak,
*Dynamics of self-similar tilings* (ETDS 17, 1997); Barge–Diamond, *Proximality in Pisot
tiling spaces* (2007); Barge–Kwapisz (2006); Barge–Bruin–Jones–Sadun. Pisot's
theorem on `||theta beta^n|| → 0` is classical (Cassels, *An introduction to
Diophantine approximation*, Ch. VIII). Barge–Diamond, *Coincidence for
substitutions of Pisot type* (2002), is now read in full; see
`p1b-barge-diamond-configuration-gate-2026-10-02.md`.

## 3. What the literature gives and what it does not

- **No off-the-shelf statement covers (F).** Barge–Gambaudo's global
  shadowing is the right notion. It is stated for unimodular substitutions
  only, and its lifts live in the cover with deck group `GR(Phi)`. The overlap
  offset `w_0` lives in `Z⟨ell⟩ = Z^3`. When `GR(Phi)` is a proper
  finite-index subgroup, bounded lift discrepancy in `Z^3` does not give
  global shadowing.
- **Strong regional proximality** (Barge 2013 Thm 4(6); Barge 2015 (3)) needs,
  for each radius, two tilings containing the two patches that agree on a
  large ball somewhere. For a reachable overlap the patches descend from a
  swap seed `(ab)^Z` against `(ba)^Z`, which need not be legal, so this
  criterion cannot be checked directly.
- **The eigenvalue route works without unimodularity** (§4). It needs the
  return module to be all of `Z^3`, which Theorem R (§5) supplies.

## 4. Proposition F (proved here)

*Hypothesis (R).* The **return module**
`Λ_ret = <pi(w) : w nonempty and legal, w w_1 legal>_Z` is all of `Z^3`.
Here `pi(w)` is the lifted displacement from an occurrence of the letter
`w_1` to the next occurrence of `w_1`. (The first version of this note wrote
`pi(u)` for a legal `a u a`. That is the displacement between the two
copies of `a` with the first copy left out; the displacement itself is
`pi(a u)`.) Equivalently, the uncollared return vectors span `Z⟨ell⟩`.
Theorem R (§5) proves (R) for every PIP substitution.

*Proposition F.* `g(T_A) = g(T_B)` for every PIP `sigma`.

*Proof.*

1. **The eigenvalue criterion on `Z^3`.** By (R), the return vectors `Ξ`
   generate `Z⟨ell⟩` (Theorem R). By Solomyak's criterion each eigenvalue `b` has
   `e^{2 pi i b beta^n x} → 1` for `x ∈ Ξ`, hence for the group they
   generate. So `||b beta^n <ell, z>|| → 0` for every `z ∈ Z^3`. Steps 3 and
   4 use this for all bounded prefix vectors, not only for `w_0`, which is
   why (R) is needed for the whole module.
2. **Exponential rate.** Fix `z` and put `theta = b <ell, z>`. By Pisot's
   theorem `theta ∈ Q(beta)`. Pick `D` with `D theta ∈ Z[beta]`. Then
   `Tr(D theta beta^n) ∈ Z`, so `||D theta beta^n|| <= C rho^n`, where
   `rho < 1` is the largest conjugate modulus. Hence
   `theta beta^n ≡ (m_n + eps_n)/D (mod 1)` with `m_n ∈ Z` and
   `|eps_n| <= C rho^n`. Since `||theta beta^n|| → 0`, eventually
   `m_n ≡ 0 (mod D)`, so `||theta beta^n|| <= C rho^n / D`.
3. **A continuous eigenfunction.**
   - For `T ∈ X_sigma`, let `y_n(T)` be the left endpoint of the level-`n`
     supertile containing `0`. The supertile is unique by recognizability:
     `sigma` is primitive and aperiodic, so `Phi` is a homeomorphism. If `0`
     lies on a supertile boundary, the two choices differ by
     `<ell, M^n e_a>`, which step 1 sends to zero, so the limit below is
     unchanged.
   - Consecutive differences are `y_n − y_{n+1} = <ell, M^n z_n>` with
     `z_n = pi(p_n)` the Parikh vector of a proper prefix, so `z_n` is
     bounded.
   - By step 2, `F_b(T) := lim_n e^{2 pi i b y_n(T)}` converges uniformly.
     It is continuous, and `F_b(T − t) = e^{−2 pi i b t} F_b(T)`, since
     `y_n(T − t) = y_n(T) − t` while `0` stays inside the same supertile.
   - So `F_b` is a continuous eigenfunction for `b`. By minimality it is the
     eigenfunction for `b`, up to a constant.
4. **Evaluating on the pair.** `T_A − c` and `T_B − c` are `Phi^r`-fixed
   about `0`. Their level-`rn` supertiles at `0` are the inflated tiles `i`
   and `j`, with left endpoints `−beta^{rn} c` and `beta^{rn}(<ell, w_0> − c)`.
   Hence
   `F_b(T_A − c) / F_b(T_B − c) = lim_n e^{−2 pi i b <ell, M^{rn} w_0>} = 1`
   by (R), since `w_0 ∈ Z^3`.
5. **Same fibre.** Every eigenfunction can be chosen continuous (BK Thm 5.1).
   For a minimal action, `X_max` is the dual of the group of continuous
   eigenvalues, and `g(T) = g(T')` iff every continuous eigenfunction agrees
   on `T` and `T'`. So `g(T_A − c) = g(T_B − c)`, and translating by `c`
   gives `g(T_A) = g(T_B)`.

`square`

Neither unimodularity nor reachability from a swap seed is used. Only the
integrality of `w_0` and (R) are, and (R) is Theorem R.

## 5. Theorem R (hypothesis (R) holds)

**Theorem R.** *Let `sigma` be primitive on a finite alphabet `A`, and suppose
the coordinates of its frequency vector `r` (the right Perron eigenvector,
`r > 0`) are linearly independent over `Q`. Then `Λ_ret = Z^A`. In particular
`Λ_ret = Z^3` for every PIP substitution on three letters.*

*Proof.*

1. **Coboundary form.** Let `chi: Z^A → Q/Z` be a homomorphism that vanishes
   on `Λ_ret`. Fix a two-sided sequence `x` in the subshift of `sigma`.
   Primitivity makes the subshift minimal, so every legal word occurs in `x`.
   Put `G(n) = chi(pi(x_[0,n)))` for `n >= 0` and `G(n) = −chi(pi(x_[n,0)))`
   for `n < 0`. If `n < m` and `x_n = x_m`, then `x_[n,m)` is a generator of
   `Λ_ret`, so `G(m) = G(n)`. Hence `G(n) = H(x_n)` for a function
   `H: A → Q/Z`. Then `chi(e_{x_n}) = G(n+1) − G(n) = H(x_{n+1}) − H(x_n)`.
   Since every legal two-letter word occurs in `x`, this gives
   `chi(e_a) = H(c) − H(a)` for every legal `ac`. Put
   `K(a) = H(a) + chi(e_a)`. Then every letter `c` that can follow `a` has
   `H(c) = K(a)`.
2. **Counting.** Fix `h ∈ Q/Z` and `N >= 1`. By step 1,
   `H(x_{n+1}) = K(x_n)`, so
   `#{0 <= n < N : H(x_n) = h} − #{0 <= n < N : K(x_n) = h}`
   `= [H(x_0) = h] − [H(x_N) = h]`, which lies in `{−1, 0, 1}`. Divide by `N`.
   Letter frequencies exist (primitivity implies unique ergodicity), so
   `sum_{H(a) = h} r_a = sum_{K(a) = h} r_a`, that is,
   `<1_{H = h} − 1_{K = h}, r> = 0`.
3. **Independence.** The vector `1_{H = h} − 1_{K = h}` is an integer vector
   orthogonal to `r`, so by hypothesis it is zero: `H(a) = h` iff `K(a) = h`.
   This holds for every `h`, so `H = K`, so `chi(e_a) = 0` for every `a`,
   and `chi = 0`.
4. **Conclusion.** If `L` is a proper subgroup of `Z^A`, then `Z^A / L` is a
   nonzero finitely generated abelian group, so it has a quotient `Z` or
   `Z/n` with `n >= 2`. Either maps nontrivially to `Q/Z` (`1 ↦ 1/2`,
   respectively `1 ↦ 1/n`). Composing gives a nonzero `chi` vanishing on
   `L`. By step 3 no such `chi` exists for
   `L = Λ_ret`, so `Λ_ret = Z^A`.
5. **PIP substitutions.** If the characteristic polynomial of `M` is
   irreducible, take `r ∈ Q(beta)^A`. If `<v, r> = 0` for some `v ∈ Q^A`,
   then applying the field embeddings gives `<v, r^tau> = 0` for the
   eigenvectors `r^tau` of all conjugates of `beta`. These form a basis of
   `C^A`, so `v = 0`. This is the same fact as the `Q`-independence of `ell`
   used throughout the repository.

`square`

**Remarks.**

- *The two-letter graph.* Step 1 holds in both directions: `chi` vanishes on
  `Λ_ret` iff `chi` is a coboundary on the edges of the two-letter graph `G`
  (edge `a -> c` when `ac` is legal). For the converse, a return word
  `w w_1` telescopes to `H(w_1) − H(w_1) = 0`. A coboundary is the same as a
  character vanishing on the cycle lattice of `G`, because `G` is strongly
  connected (primitivity) and a closed walk is a sum of simple cycles. So `Λ_ret` and the cycle
  lattice of `G` have the same annihilator in `(Q/Z)^A`, and they are equal.
  This is `Lambda_1` of `kernel/psc/return_lattice.mojo`, computed there by
  the same identification (`return-lattice-literature-gate-2026-10-02.md`,
  which credits it to Barge–Gambaudo Lemma 15). That gate certifies
  `Lambda_1 = Z^3` on the 4,554 corpus specimens; Theorem R proves it for
  every PIP substitution. Its finding that `Lambda_n` for `n > 1` has index
  `> 1` when `abs(det M) = 2` does not touch Proposition F, whose step 1 uses
  only tile returns, `Lambda_1`.
- *A second proof on three letters.* `M Λ_ret ⊆ Λ_ret`, because `sigma`
  maps a return word of `a` to a return word of the first letter of
  `sigma(a)`. So `Λ_ret ⊗ Q` is a nonzero `M`-invariant rational subspace,
  and irreducibility makes its rank 3. The regression
  `test_every_digraph_on_three_letters_has_index_zero_or_one` checks all 512
  digraphs on three vertices: the cycle lattice has rank below 3 (303 of
  them) or is all of `Z^3` (209). There is no index `>= 2`, so rank 3 already
  means index 1.
- *Where the hypothesis is used.* Height-type cocycles are real. Dekking's
  `0 -> 010, 1 -> 201, 2 -> 102` has height 2: letter `0` occupies every
  other position, and `r_0 = r_1 + r_2` is a rational relation. Its
  incidence matrix is singular, so its return module has rank 2
  (`test_dekkings_height_two_substitution_has_rank_two`). Step 3 is exactly
  where an irreducible characteristic polynomial excludes this.
- *Finite-domain regression.* `kernel/tests/test_return_module.mojo` checks
  that the index is 1 on all 4,554 corpus specimens and on all 24,486
  specimens with total image length at most 8. A scratch sweep (not
  committed) found index 1 on all 135,990 PIP substitutions with images of
  length at most 4. It found no index `>= 2` among the 1,042,188 primitive
  substitutions with nonsingular incidence and images of length at most 4.
  These checks calibrate the implementation. The theorem does not rest on
  them.

## 6. Consequences and decision

By Theorem R, Proposition F holds for every PIP `sigma`. With Theorem B this
gives:

1. A reachable strict zipper gives a `Phi^r`-periodic pair in one fibre with
   **no common vertex**, hence no common tile.
2. Barge 2015, item (3) (pairwise strongly regionally proximal, pairwise
   tile-disjoint tilings exist in number at most `cr`), with Barge 2013
   Thm 4(6) (one fibre iff strongly regionally proximal), then gives
   `cr >= 2`, hence no pure discrete spectrum (Barge 2013 Thm 4(5)).
   *Correction 2026-10-04:* an earlier version cited BK Lemma 5.12 here,
   which as recorded runs the other way (not proximal ⇒ no common tile).
   Their hypotheses are audited in
   `coincidence-rank-imports-literature-gate-2026-10-04.md` (no unimodularity).

Within the repository, pure discrete spectrum excludes strict zippers only
through Theorem S of `p1b-vertex-coincidence-box-2026-10-02.md`; the
manuscript does not import a "PDS ⇒ productivity" chain (see the remark after
its Theorem 5.38). *Correction 2026-10-04:* an earlier version called this "the
known chain". With (R) removed it is an
unconditional implication (strict zipper ⇒ `cr >= 2`), but it does not
exclude anything new. The table in §5 of the note holds for every PIP
substitution:

| Periodic pair in one fibre | Equivalent to |
| --- | --- |
| no common tile | `cr >= 2` (known) |
| no common vertex | failure of PPVC, i.e. a formal strict zipper (Theorem B with Proposition F); a strict zipper reachable from a swap seed is a special case |

**Decision: proceed.**

1. Record Proposition F in the note as proved, with Theorem R and the
   sources above.
2. Promote no ledger node. PeriodicPairVertexCoincidence stays open.
3. **Stop list.** None of the following may be offered as closing #139:
   - `cr = 1`-type statements, since they are pure discrete spectrum itself;
   - density or counting, since a hypothetical `cr = 2` substitution with
     measure-disjoint subtiles has vertex-disjoint generic pairs;
   - Barge–Gambaudo global shadowing without a proof that `GR(Phi) = Z⟨ell⟩`;
   - the Barge–Diamond configuration argument in vertex form, for the
     reason recorded in `p1b-barge-diamond-configuration-gate-2026-10-02.md`.
4. The candidate route of the first version of this note, the Barge–Diamond
   2002 configuration argument as run in Barge 2015 Lemma 2, has been read in
   full. Its gate is `p1b-barge-diamond-configuration-gate-2026-10-02.md`.
   Decision there: stop as a closing argument.
