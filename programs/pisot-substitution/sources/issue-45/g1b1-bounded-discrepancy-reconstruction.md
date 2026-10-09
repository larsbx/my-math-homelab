# G1b-1 bounded discrepancy — independent reconstruction

**Status:** independent reconstruction with a complete proof; not a recovered
v16 file. The reachable-history audit
(`docs/source-provenance-v16-later-audit-2026-09-12.md`) found no detailed
source for the reported estimate `Disc(sigma w) <= c Disc(w) + 2 E_sigma`.
That estimate is *not* reconstructed here and is not needed. The proof below
bounds the discrepancy of every reachable state of `B_sigma` directly, by a
global argument on inflated swap seeds, under hypotheses weaker than PIP.

This note proves what the merged manuscript
`manuscripts/PSC_balanced_pair_state_2026-09-13.tex` stated as Hypothesis 4.4
(now its Theorem 4.4) and is the source for that theorem. It proves nothing about G1, G1b-2, SCC Producer, or
PSC.

## 1. Statement

Let `sigma` be a substitution on `A`, `|A| = d`, with incidence matrix `M`
(`M e_a = pi(sigma(a))`, so `pi(sigma(w)) = M pi(w)` for the Parikh map `pi`).

**Hypothesis (H).** `M` is primitive, and every eigenvalue of `M` other than
its Perron eigenvalue `beta` has modulus `< 1`.

(H) holds for every primitive irreducible Pisot substitution: the other
eigenvalues are the Galois conjugates of `beta`. Unimodularity, unique
decodability, and `|A| = 3` are not used. Irreducibility is used only through
(H).

For a balanced pair `s = (u, v)` of length `n` write `D_s(k) = pi(u[k]) -
pi(v[k])` (`0 <= k <= n`) and `Disc(s) = max_k ||D_s(k)||_inf`, as in
Definition 4.3 of the manuscript.

**Theorem (G1b-1).** Under (H) there is an explicit constant `D_sigma` such
that every reachable state `T` of `B_sigma` satisfies `Disc(T) <= D_sigma`.
One may take `D_sigma = 4 (d + 1) C_sigma` with `C_sigma` as in Lemma 3.

**Corollary (collapse of the two-gate decomposition).** Under (H), G1 holds if
and only if only finitely many reachable irreducible states have discrepancy at
most `D_sigma`. Consequently the earlier form of G1b-2 ("for every `R_0`") is
equivalent to G1 itself: for `R_0 >= D_sigma` the finiteness asked for is
literally G1, and for `R_0 < D_sigma` it is implied by G1. The manuscript now
states G1b-2 with `R_0 = D_sigma` (Open Problem 4.10) and the equivalence as
Proposition 4.11.

## 2. Notation

By Perron–Frobenius, `beta` is a simple eigenvalue with right eigenvector
`r > 0` and left eigenvector `l > 0`; normalise `<l, r> = 1`. Then
`P_u := r l^T` is the spectral projection onto `R r`, it commutes with `M`, and
`P_s := I - P_u` is the projection onto

```text
E_s := ker l^T = { x in R^d : <l, x> = 0 }
```

along `R r`. `E_s` is `M`-invariant, and the spectrum of `M|E_s` is the
spectrum of `M` with `beta` removed; under (H) its spectral radius
`lambda_s` is `< 1`. Norms are `||.||_inf` on `R^d` and the induced operator
norm. `1` denotes the all-ones vector, so `<1, pi(w)> = |w|`.

## 3. Lemmas

**Lemma 1 (summable decay).** `kappa_i := ||M^i P_s||` satisfies
`K_sigma := sum_{i >= 0} kappa_i < infinity`.

*Proof.* `M^i P_s = (M P_s)^i` for `i >= 1`, and the spectrum of `M P_s` is
that of `M|E_s` together with `0`, so `rho(M P_s) = lambda_s < 1`. By Gelfand's
formula `kappa_i^{1/i} -> lambda_s`, hence `kappa_i <= c mu^i` for any
`lambda_s < mu < 1` and the series converges. ∎

**Lemma 2 (prefix decomposition).** Let `n >= 0`, `a in A`, and let `p` be a
prefix of `sigma^n(a)`. There are letters `c_0, ..., c_n` with `c_n = a`,
words `p_0, ..., p_{n-1}` with `p_i c_i` a prefix of `sigma(c_{i+1})` (so each
`p_i` is a proper prefix of an image of a letter), and `e in {epsilon, c_0}`,
such that

```text
p = sigma^{n-1}(p_{n-1}) sigma^{n-2}(p_{n-2}) ... sigma^0(p_0) e.
```

*Proof.* Induction on `n`. For `n = 0`, `p in {epsilon, a}`; take `e = p`,
`c_0 = a`. For `n >= 1` write `sigma(a) = b_1 ... b_m`, so
`sigma^n(a) = sigma^{n-1}(b_1) ... sigma^{n-1}(b_m)`. Let `t` be the largest
index with `|sigma^{n-1}(b_1 ... b_t)| <= |p|` and `t <= m - 1`; then
`p = sigma^{n-1}(b_1 ... b_t) p'` with `p'` a prefix of `sigma^{n-1}(b_{t+1})`
(if `p = sigma^n(a)` then `t = m - 1` and `p' = sigma^{n-1}(b_m)`). Put
`p_{n-1} = b_1 ... b_t`, `c_{n-1} = b_{t+1}`, and apply the induction
hypothesis to `p'` as a prefix of `sigma^{n-1}(c_{n-1})`. ∎

**Lemma 3 (boundedness of the contracting component; Adamczewski, Rauzy).**
Let

```text
B_sigma := max { ||P_s pi(q)||, ||P_s e_c|| : c in A, q a prefix of sigma(c) },
C_sigma := B_sigma (1 + K_sigma).
```

Then `||P_s pi(p)|| <= C_sigma` for every `n >= 0`, `a in A`, and every prefix
`p` of `sigma^n(a)`.

*Proof.* With the decomposition of Lemma 2 and `pi(sigma^i(w)) = M^i pi(w)`,

```text
P_s pi(p) = sum_{i=0}^{n-1} M^i P_s pi(p_i) + P_s pi(e),
```

using `P_s M = M P_s`. Each `||P_s pi(p_i)|| <= B_sigma` and
`||P_s pi(e)|| <= B_sigma`, so `||P_s pi(p)|| <= B_sigma (sum_{i<n} kappa_i + 1)
<= C_sigma`. ∎

This is the boundedness of the Rauzy fractal, equivalently Adamczewski's
theorem that fixed points of primitive substitutions with `|theta_2| < 1` are
balanced (B. Adamczewski, *Balances for fixed points of primitive
substitutions*, Theoret. Comput. Sci. 307 (2003), 47–75). The argument is
included so that the hypotheses used are visible: only (H) enters, through
Lemma 1. Adamczewski also shows that (H) cannot simply be dropped: with a
second eigenvalue of modulus larger than one the fixed points are unbalanced.

**Lemma 4 (prefixes of inflated seeds).** For `a, b in A`, `n >= 0`, and
`0 <= j <= |sigma^n(ab)|`, the prefix `w` of length `j` of `sigma^n(ab)`
satisfies `||P_s pi(w)|| <= 2 C_sigma`.

*Proof.* Either `w` is a prefix of `sigma^n(a)`, or `w = sigma^n(a) w'` with
`w'` a prefix of `sigma^n(b)`; apply Lemma 3 to each piece. ∎

Note that `sigma^n(ab)` need not be a legal word (Remark 2.13 of the
manuscript); Lemma 4 does not need legality, only that each piece is a prefix
of an iterated image of a letter.

**Lemma 5 (zero symbolic length controls the Perron component).** If
`x in R^d` and `<1, x> = 0`, then `||x|| <= (d + 1) ||P_s x||`.

*Proof.* `x = <l, x> r + P_s x`. Applying `<1, .>`:
`0 = <l, x> <1, r> + <1, P_s x>`, so `|<l, x>| <= d ||P_s x|| / <1, r>`.
Since `r > 0`, `||r|| <= <1, r>`, hence
`||x|| <= |<l, x>| ||r|| + ||P_s x|| <= (d + 1) ||P_s x||`. ∎

## 4. Proof of the theorem

Fix a seed `(ab, ba)` and `n >= 0`, and write `U = sigma^n(ab)`,
`V = sigma^n(ba)`, `N = |U| = |V|`. The *swap walk* is

```text
Delta(j) := pi(U[j]) - pi(V[j]),    0 <= j <= N.
```

Both prefixes have `j` letters, so `<1, Delta(j)> = 0`; by Lemma 4,
`||P_s Delta(j)|| <= 4 C_sigma`; by Lemma 5,

```text
||Delta(j)|| <= 4 (d + 1) C_sigma = D_sigma    for all j and all n.
```

Now let `T` be a reachable state. By the depth-`n` descendant lemma (Lemma
2.12 of the manuscript) `T` is, up to side swap, a block of
`red(U, V)` for some seed `(ab, ba)` and some `n`: `T = (U[i..i'), V[i..i'))`
with `i < i'` consecutive zero returns of `(U, V)`. Its prefix-difference walk
is

```text
D_T(k) = (pi(U[i+k]) - pi(U[i])) - (pi(V[i+k]) - pi(V[i]))
       = Delta(i + k) - Delta(i) = Delta(i + k),
```

since `Delta(i) = 0`. Hence `Disc(T) <= max_j ||Delta(j)|| <= D_sigma`.
Side swap negates `D_T` and does not change `Disc`. ∎

## 5. What the theorem does and does not give

- **It gives the box.** Every reachable state's difference walk lives in the
  finite set `{x in Z^d : ||x|| <= D_sigma, <1, x> = 0}`. In particular the
  set of *difference vertices* met by reachable states is finite a priori;
  this was previously only observed in computations.
- **It does not give finiteness.** Retired route (ii) of the manuscript
  (Section 4.9) stays retired: a bounded box contains arbitrarily long
  `0`-avoiding walks, and the exact computations of Section 6.2 exhibit
  reachable states of length in the tens of thousands with discrepancy
  `<= 14`. G1 is exactly the statement that only finitely many *labelled*
  excursions in the box are realized by the substitutive hierarchy.
- **It is not a contraction estimate.** No child-versus-parent inequality is
  proved or used. Route (iii) of Section 4.9 (the zero-sum hyperplane does not
  contract under `M` in a fixed norm) is untouched; the proof instead
  separates the Perron and contracting components of a vector of zero
  symbolic length (Lemma 5).
- **Hypotheses.** Primitivity and (H). Nothing about `det M`, about
  `pi_s(Z^A)` being a lattice, or about legality of seeds.

## 6. Exact finite cross-check

The claim being checked is only that per-substitution suprema are finite and
small, and that the reduction step (a block's walk is a segment of the swap
walk) is exact. No computation can verify `D_sigma` itself, and none is
claimed to.

**Corpus census.** Over all `4,554` primitive irreducible Pisot substitutions
on three letters with image lengths at most three, with the reachable graph
built from all three swap seeds under a cap of `20,000` states (never
reached):

| quantity | value |
| --- | --- |
| maximum `Disc(T)` over all reachable states of all `4,554` automata | `14` |
| longest reachable state | `48,020` letters |
| substitutions with maximum discrepancy `1 / 2 / 3 / 4` | `1554 / 1356 / 474 / 330` |
| substitutions with maximum discrepancy `5 / 6 / 7 / 8` | `240 / 240 / 84 / 108` |
| substitutions with maximum discrepancy `9 / 10 / 11 / 12 / 14` | `36 / 60 / 24 / 36 / 12` |

The value `14` agrees with the per-state imbalance bound reported in the
2026-09-11 ledger. The pair (maximum discrepancy `14`, maximum length
`48,020`) is the finite illustration of the second bullet of Section 5.

**Swap-walk profiles.** `max_j ||Delta(j)||` over the three seeds at level
`n`:

| substitution | levels `0..18` |
| --- | --- |
| Tribonacci `1->12, 2->13, 3->1` | `1` at every level |
| flipped Tribonacci `1->21, 2->31, 3->1` | `1` at every level |
| `tau: 1->2, 2->132, 3->112` | `1,1,2,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5` |

A swap walk splits at its zero returns into reachable states (Section 4), so
the level-`n` supremum is the largest discrepancy of a depth-`n` descendant
and can never exceed the maximum over the automaton. For `tau`, whose
automaton is finite with maximal reachable discrepancy `5`, the profile
attains `5` at level `15` and stays at or below `5` forever; the exact test
`test_tau_profile_and_reachable_maximum` pins both facts. The sharp value is
far below the analytic constant: floating-point evaluation (not a
certificate) gives `C_sigma ~ 6.6`, `D_sigma ~ 105` for Tribonacci and
`C_sigma ~ 48`, `D_sigma ~ 763` for `tau`, against sharp maxima `1` and `5`;
for `tau` the series of Lemma 1 converges slowly because the second
eigenvalue has modulus `sqrt(2/beta) ~ 0.94`.

The canonical exact implementation is the Mojo kernel
`kernel/psc/swap_discrepancy.mojo` with census driver
`kernel/swap_discrepancy_census.mojo` (PIP screening by the repository's exact
Sturm-sequence procedure in `kernel/psc/pisot.mojo`; no floating point anywhere)
and regression `kernel/tests/test_swap_discrepancy.mojo`, which pins the
reduction step and the example values above. `reference/psc_research/swap_discrepancy.py`,
`oracles/python/swap_discrepancy_census.py` (exact screening by rational-root test
and Sturm sequences over `Q`) and `tests/test_swap_discrepancy.py` are the
independent Python oracle; both layers report the same corpus size and the
same discrepancy statistics.

## 7. Ledger consequences

- `G1b1BoundedDiscrepancy` moves into `ProvedDef` in `proof/tla/Ledger.tla` with
  no repository prerequisites (it does not use `UniqueDecodability`).
- `G1b2RenewalFiniteness` remains outside `ProvedDef`; `G1` remains
  conditional on it. `RenewalFinitenessRemainsOpen` must continue to hold.
- The manuscript's former Hypothesis 4.4 becomes Theorem 4.4 (with Lemmas
  4.5–4.8), its former Lemma 4.6 becomes Proposition 4.11, the equivalence
  `G1 <=> G1b-2`, and the abstract, headline status, Section 8
  list, and Section 9 discussion are adjusted accordingly.
