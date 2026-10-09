# T1: a uniform overlap bound from uniform balance

**Status:** repository-proved statements (Lemma S, Lemma P, Theorems T1 and
T1′) under explicitly named hypotheses. The repository owner waived a separate
human review on 2026-10-09; the proofs stand as written. T1′
bounds the types at selected return depths; the all-depth extension remains
open. This is the methodology's G4 target T1: the S-adic lift of
PSC `docs/overlap-finiteness-and-coincidence-density-2026-09-13.md`,
Theorem 2.1 (PSC PR #72). Nothing here proves finiteness of a balanced-pair
graph, productivity, or the S-adic Pisot conjecture.

## Setting

- `σ = (σ_n)` is a directive sequence of non-erasing substitutions on `d`
  letters.
- `L^{(k)}` is the language of the shifted sequence `(σ_{k+n})_n` (BST19 §2.2).
- `π` is the Parikh map.
- A **swap pair at depth `k` and level `N > k`** is `U = σ_{[k,N)}(ab)`,
  `V = σ_{[k,N)}(ba)` for letters `a ≠ b`. Its **swap walk** is
  `Δ(j) = π(U[:j]) − π(V[:j])`.

In PSC the recursion between levels is inflation by the single substitution.
Here it is the identity `σ_{[k,N)} = σ_k ∘ σ_{[k+1,N)}`, so depth `k` and depth
`k+1` are related by inflation under `σ_k`, and the overlap graph lives over
the shift orbit.

Tiles at depth `k` are measured by the **level-0 letter lengths**
`ℓ^{(k)}_a = |σ_{[0,k)}(a)|`, which satisfy `ℓ^{(k)ᵀ} = ℓ^{(k−1)ᵀ} M_{k−1}`. A
depth-`k` word `w` then tiles `[0, ⟨ℓ^{(k)}, π(w)⟩)`, and inflation by `σ_k`
preserves these lengths. An **overlap type at depth `k`** is `(i, j, v)`:
- `i`, `j` are the letters of a top tile of `U` and a bottom tile of `V` whose
  interiors meet;
- `v = π(V[:q]) − π(U[:p])` is the integer vector between their starting
  vertices, at positions `p` and `q`.

The finite object counted below is the pool of triples `(i, j, v)` arising
from these swap pairs. The depth is an occurrence label, not an extra
coordinate in that pool. Finitely many such triples do not by themselves
give a finite graph with its directive base or transition data included.

## Lemma S (swap-walk bound)

If `L^{(k)}` is `C`-balanced, then `‖Δ(j)‖_∞ ≤ C` for every swap pair at depth
`k`, every level `N` and every `j`.

*Proof.* Put `x = σ_{[k,N)}(a)` and `y = σ_{[k,N)}(b)`. Both lie in `L^{(k)}`,
and so do their factors.
- If `j ≤ min(|x|, |y|)`: `Δ(j) = π(x[:j]) − π(y[:j])`, the difference of two
  factors of length `j`.
- If `|y| < j ≤ |x|`: `Δ(j) = π(x[j−|y|:j]) − π(y)`, two factors of length `|y|`.
- If `|x| < j ≤ |y|`: `Δ(j) = π(x) − π(y[j−|x|:j])`, symmetrically.
- If `j > max(|x|, |y|)`: `Δ(j) = π(x[j−|y|:]) − π(y[j−|x|:])`, two suffixes of
  length `|x| + |y| − j`.

In every case each coordinate of `Δ(j)` is a difference of letter counts in
two equal-length factors of `L^{(k)}`, so it is at most `C` in absolute value. ∎

Lemma S does not use legality of `ab`, the Pisot condition, or unimodularity.
It replaces PSC's bounded-discrepancy theorem (G1b-1), where the bound came
from the Pisot spectrum of one matrix.

## Theorem T1 (uniform overlap bound)

Assume:
- **(H2) uniform balance:** every `L^{(k)}` is `C`-balanced, the "uniformly
  balanced" condition of BST19 §3.2 and [DHS13];
- **(H3) bounded length ratio:** `ℓ^{(k)}_a ≤ R · ℓ^{(k)}_b` for all `k` and
  all letters `a, b`.

Then every overlap type `(i, j, v)` of the swap pairs occurring at any depth satisfies
`‖v‖_∞ ≤ B := C + R(1 + dC)`. So at most `d²(2B + 1)^d` overlap types occur
over the whole shift orbit.

*Proof.* This is PSC Theorem 2.1 with Lemma S in place of bounded discrepancy,
using the depth-`k` lengths `ℓ = ℓ^{(k)}`.
1. Let the top tile start at `x = ⟨ℓ, π(U[:p])⟩` and the bottom tile at
   `y = ⟨ℓ, π(V[:q])⟩`. Then `v = (π(V[:q]) − π(V[:p])) − Δ(p)`.
2. The `p`-th vertex of `V` lies at `y_p = x − ⟨ℓ, Δ(p)⟩`, so
   `|x − y_p| ≤ ‖ℓ‖₁ C`.
3. The interiors meet, so `|x − y| < ℓ_max`. Hence
   `|y − y_p| < ℓ_max + ‖ℓ‖₁ C`.
4. Every tile between those two vertices has length at least `ℓ_min`, so
   `|q − p| < (ℓ_max + ‖ℓ‖₁ C)/ℓ_min ≤ R + dRC`, using
   `‖ℓ‖₁ ≤ d ℓ_max ≤ dRℓ_min`.
5. `‖π(V[:q]) − π(V[:p])‖_∞ ≤ |q − p|` and `‖Δ(p)‖_∞ ≤ C`. Adding gives
   `‖v‖_∞ ≤ B`.
6. The count follows: `i, j` range over `d` letters each and `v` over the box
   `[−B, B]^d`. ∎

*Remarks.*
1. For a periodic sequence `w^∞` with `M_w` primitive and Pisot, (H2) holds
   (Adamczewski 2003) and (H3) holds by Perron–Frobenius. T1 then contains
   PSC Theorem 2.1 for the substitution `σ_w`, up to the choice of length
   functional.
2. (H3) fails for Arnoux–Rauzy sequences with arbitrarily long runs of a
   single `α_i`: during a run of length `m`, the `i`-th image length stays
   fixed and every other image length increases by `m` times that length.
   Hence the ratio is at least `m`. Such sequences have unbounded weak partial quotients,
   so they lie outside the every-sequence class of BST19 Theorem 3.8.
3. BST19 Theorem 3.1 assumes C-balance only along recurring return times,
   which is weaker than (H2).

## Lemma P (positive-suffix length ratio)

**Status:** repository-proved.

For a strictly positive `d × d` matrix `B`, define

`R_B := max_{r,a,b} B_{ra}/B_{rb} = max_r (max_a B_{ra})/(min_b B_{rb})`.

If `w` is a nonzero nonnegative row, then every coordinate of `wB` is
positive and `(wB)_a ≤ R_B (wB)_b` for all letters `a, b`.

*Proof.* The entrywise inequalities `B_{ra} ≤ R_B B_{rb}` survive
multiplication by `w_r ≥ 0` and summation over `r`. Positivity follows from
one `w_r > 0` and all `B_{rb} > 0`. The bound is sharp over such rows: choose
the coordinate row supported at an `r` attaining `R_B`. ∎

For the level-0 lengths, a prefix product ending in `B` has
`ℓ^{(t)ᵀ} = (1ᵀ M_{[0,t−h)}) B`. Thus its length ratio is bounded by
`R_B`, regardless of the preceding product. A positive block at the
*beginning* of the product has no such consequence.

## Theorem T1′ (overlap finiteness along selected return times)

**Status:** repository-proved. This is the return-time
version of T1′, with no extra hypothesis beyond BST19 Theorem 3.1.

Assume precisely the hypotheses of BST19 Theorem 3.1: a primitive,
algebraically irreducible directive sequence over a finite or infinite set
of unimodular substitutions on `d` letters, and a constant `C` for the
balanced recurring-prefix condition. Replace `C` by its integer ceiling
if necessary. Then there exist strictly increasing sequences `(n_k)` and
`(ℓ_k)`, an integer `h`, and a single positive matrix `B` such that, at
`t_k := n_k + ℓ_k`, every swap-pair overlap type obeys

`‖v‖_∞ ≤ C + R_B(1 + dC) ≤ b := C + ⌈R_B(1 + dC)⌉`.

Consequently, the union of type triples over all these depths and all
levels `N > t_k` has cardinality at most `d²(2b + 1)^d`.

*Proof.* BST19 Lemma 5.9 supplies PRICE subsequences. We use just the
following parts of Definition 5.8:

- (P): `M_{[ℓ_k−h,ℓ_k)} = B > 0`, independently of `k`;
- (R): `σ_{n_k+r} = σ_r` for every `0 ≤ r < ℓ_k`, that is, equality
  of the directive tuples, not merely equality of their composed morphisms;
- (C): `L^{(n_k+ℓ_k)}` is `C`-balanced.

By (R), the terminal `h` matrices of the repeated prefix at `t_k` have
product `M_{ℓ_k−h} ⋯ M_{ℓ_k−1} = B`, so

`M_{[t_k−h,t_k)} = B`, and
`ℓ^{(t_k)ᵀ} = ℓ^{(t_k−h)ᵀ} B`.

The left row is positive because all substitutions are non-erasing.
Lemma P therefore gives `ℓ_max^{(t_k)}/ℓ_min^{(t_k)} ≤ R_B`.
Property (C) gives Lemma S at the same depth. Steps 1–5 of T1's proof use
only these two bounds at the depth being considered, and yield
`‖v‖_∞ ≤ C + R_B(1 + dC)`. The constant is independent of `k` and `N`.
The integer box and its cardinality give the conclusion. ∎

Tuple equality matters for locating this suffix. For example, if `e` is
the identity substitution and `β` has positive incidence matrix `B`, the
blocks `(e, β)` and `(β, e)` have equal composites but different final
matrices (`B` and the identity). Composite equality alone does not justify
the displayed terminal-block identity.

Unimodularity and algebraic irreducibility enter through the stated BST19
regime and its PRICE import. The bound itself needs only (P), (R), and (C);
it uses neither geometric coincidence nor pure discrete spectrum.

**Source and novelty boundary.** This is an elementary consequence in the
repository's swap-type encoding, not a novelty claim. BST19 already uses
the fixed positive suffix to compare image sizes in the proof of Lemma
5.11. The verified import is recorded in
[`literature-gate-2026-10-09.md`](literature-gate-2026-10-09.md) §6.

## All-depth overlap finiteness (open theorem target)

**Status:** open. T1′ gives a common finite type pool at selected depths,
not a closed finite transition graph across the intervening depths. PRICE
does not assert uniform balance or uniformly bounded gaps there. Nor does
prefix recurrence identify the inflation from `t_k` to `t_{k+1}` with a
single fixed block: that product is `σ_{[t_k,t_{k+1})}` and may vary with
`k`. Extending the bound to every depth, or constructing a finite
presentation for return transitions, requires a further argument.

[`all-depth-bounded-anchors.md`](all-depth-bounded-anchors.md) gives a
conditional all-depth type bound from bounded-gap balanced positive-suffix
anchors. Those are additional depths, not necessarily growing PRICE
prefix returns: bounded gaps in the latter force periodicity (Lemma G).
The unrestricted target above remains open.

## Executable checks

`kernel/sadic/overlap.mojo` computes `R_B` and the integer bound `b` in
checked arithmetic. The independent oracle in
`reference/sadic_reference/overlap.py` enumerates column-pair ratios with
`Fraction`; the Mojo implementation instead compares row extrema.

`tests/test_return_overlap.py` and `kernel/tests/test_return_overlap.mojo`
check the suffix inequality on every positive two-by-two matrix with
entries in `{1,2,3}` and nonzero left rows in `{0,1,2,3,4}²`, then enumerate
literal tile overlaps for short words, unequal image lengths, and skew
left rows. The Python tests also cover Arnoux–Rauzy and Brun images.
A prefix/suffix order negative control and refusal tests guard the precise
hypotheses and arithmetic. `kernel/vectors.mojo` and
`tools/cross_check.py` compare ratios and boxes on positive AR and Brun
products. These finite checks guard the ingredients; the theorem is the
proof above. No finite run certifies balance or PRICE for an infinite
directive sequence.

The endpoint and composite-equality controls, independent mathematical
review, and reconciliation of PR #4's tree reference with its final commit
are recorded in [`t1-prime-audit-2026-10-09.md`](t1-prime-audit-2026-10-09.md).
