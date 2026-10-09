# All-depth overlap types from bounded-gap balanced anchors

**Status:** repository-proved elementary Lemmas M and G, and conditional
Theorem W. The all-depth target under BST19 Theorem 3.1 alone remains open.
This note uses the swap-pair and level-0 length conventions of
[`t1-uniform-overlap-finiteness.md`](t1-uniform-overlap-finiteness.md).

The useful additional condition is a bounded gap between **balanced
positive-suffix anchors**, rather than between the growing PRICE returns.
Lemma G explains why that distinction matters. No novelty claim is made
for these elementary derivations.

## Lemma M (morphic image balance)

**Status:** repository-proved.

Let `L` be a factor-closed `C`-balanced language over `d` source letters,
and let `η` be a non-erasing morphism whose images have lengths at most
`J ≥ 1`. The output alphabet may differ from the source alphabet. Then
`Fact(η(L))` is `F(d,C,J)`-balanced, where

`F(d,C,J) := 2J(dC + 2)`.

*Proof.* Let `A, B` be two equal-length output factors. Write each as the
image of its completely contained source letters, together with the
possibly clipped first and last images. Thus their Parikh vectors are
`π(A) = M_η π(a) + e_A` and `π(B) = M_η π(b) + e_B`, where `a, b` are
source factors and the nonnegative boundary vectors have coordinate sum
at most `2J`. Empty internal factors are allowed.

After exchanging the two factors if necessary, write `a = a₀ r` with
`|a₀| = |b|`. Balance gives `‖π(a₀) − π(b)‖∞ ≤ C`. Consequently,

- each coordinate of `M_η(π(a₀) − π(b))` has absolute value at most `dCJ`;
- the length difference `|η(a₀)| − |η(b)|` has absolute value at most `dCJ`;
- equality of the output-factor lengths gives
  `||η(a)| − |η(b)|| ≤ 2J`.

It follows that `|η(r)| ≤ dCJ + 2J`. Each coordinate of `π(η(r))` is
bounded by that length, and each coordinate of `e_A − e_B` has absolute
value at most `2J`. Adding these three bounds gives
`‖π(A) − π(B)‖∞ ≤ dCJ + (dCJ + 2J) + 2J = F(d,C,J)`. ∎

The estimate is deliberately coarse. It certifies propagation of a
*supplied* balance bound through a finite morphism, not balance of an
infinite language from finite samples.

## Theorem W (bounded-anchor all-depth type pool)

**Status:** conditional theorem; the additional anchor condition below is
not inferred from BST19 Theorem 3.1.

Let `σ` be a primitive non-erasing directive sequence on `d` letters. Assume:

- every substitution image has length at most `L ≥ 1`;
- there are increasing anchor depths `r₀ < r₁ < …` and a single `C ≥ 0`
  such that every `L^{(r_m)}` is `C`-balanced;
- the prefix product at every anchor ends in the same strictly positive
  matrix `B` (with a fixed suffix length `h` and `r₀ ≥ h`);
- `r₀ ≤ D` and `r_{m+1} − r_m ≤ D` for a finite `D`.

These anchors need not repeat growing prefixes. Put

`J := L^D`, `C_* := 2J(dC + 2)`, and `R_* := R_B J`,

where `R_B` is Lemma P's row-ratio bound. Then at every depth `k` the
language is `C_*`-balanced and its level-0 length ratio is at most `R_*`.
Every swap-pair overlap type therefore satisfies

`‖v‖∞ ≤ C_* + R_*(1 + dC_*) ≤ b_* := C_* + ⌈R_*(1 + dC_*)⌉`.

The pool of type triples over **all** depths and later swap levels has
cardinality at most `d²(2b_* + 1)^d`.

*Proof.* Fix a depth `k` and choose the first anchor `r ≥ k`. The initial
gap and consecutive-gap assumptions imply `r − k ≤ D`. The block
`η = σ_{[k,r)}` has nonempty images of length at most `J`. By primitivity,
every factor at depth `k` occurs in the image of a factor at depth `r`:
any earlier image can be embedded into a later image once its source
letter occurs, and later images factor through `σ_{[k,r)}`. The converse
inclusion follows directly from composition. Hence
`L^{(k)} = Fact(η(L^{(r)}))`. Lemma M gives the common balance bound `C_*`.

For lengths, let `s` be the last anchor at or before `k`, or depth zero
if there is no such anchor. The gap assumptions give `k − s ≤ D`.
At an anchor, Lemma P gives `ℓ_max^{(s)}/ℓ_min^{(s)} ≤ R_B`; at depth
zero the ratio is `1 ≤ R_B`. Each column sum of `M_{[s,k)}` is between
`1` and `J`, so

`ℓ_min^{(s)} ≤ ℓ_a^{(k)} ≤ J ℓ_max^{(s)}` for every letter `a`.

The length ratio at `k` is therefore at most `R_B J`. Applying T1 with
the two common bounds gives the asserted box and cardinality. ∎

This supplies a sufficient condition for an all-depth finite type pool.
It does not certify the anchor assumptions for a particular infinite
sequence, establish a finite presentation of every transition, or prove
balanced-pair termination or pure discrete spectrum.

## Lemma G (bounded gaps in growing prefix returns force periodicity)

**Status:** repository-proved.

Let an infinite directive word have strictly increasing prefix lengths
`ℓ_k → ∞` and strictly increasing return positions `n_k` satisfying
`σ_{[n_k,n_k+ℓ_k)} = σ_{[0,ℓ_k)}`. If the gaps between
`t_k := n_k + ℓ_k` are bounded by `D`, the directive word is periodic
with a period at most `D`.

*Proof.* Put `p_k := n_{k+1} − n_k`. Then `1 ≤ p_k ≤ D`, because both
sequences increase and `t_{k+1} − t_k ≤ D`. For large `k`, `ℓ_k > p_k`.
The two returned prefixes overlap, and for `0 ≤ j < ℓ_k − p_k` their
identities give

`σ_{j+p_k} = σ_{n_k+j+p_k} = σ_{n_{k+1}+j} = σ_j`.

One value `p ∈ {1,…,D}` occurs infinitely often among the `p_k`.
Since the corresponding prefix lengths tend to infinity,
`σ_{j+p} = σ_j` for every `j ≥ 0`. ∎

PRICE's (R) has precisely the growing-prefix form used here. Requiring
bounded gaps in that selected subsequence would thus restrict the route
to periodic directives. Theorem W instead permits other balanced
positive-suffix depths as anchors. Existence of those additional anchors
with bounded gaps is an extra condition that remains to be verified for
any intended nonperiodic class.

## Corollary A (a nonperiodic Arnoux–Rauzy example)

**Status:** repository-proved using the verified BST19 Proposition 9.3
import. It is a calibration example, with no novelty claim.

Let `t` be the binary Thue–Morse word, defined by `t₀ = 0`,
`t_{2n} = t_n` and `t_{2n+1} = 1 − t_n`. Replace its bits by the directive
blocks `0 ↦ 012`, `1 ↦ 021`, where `i` denotes the repository's zero-based
Arnoux–Rauzy substitution `α_i` on three letters. This directive is
nonperiodic and meets Theorem W's anchor hypotheses with

`C = 3`, `L = 2`, `D = 9`, and
`B = M_{012} = ((4,3,2), (2,2,1), (1,1,1))`, `R_B = 2`.

Hence its swap-overlap type pool is finite at every depth. The conservative
Theorem W box has `J = 512`, `C_* = 11264`, and `b_* = 34615296`.

*Proof.* Every aligned block contains all three labels and has positive
incidence product, so the directive is primitive. Adjacent labels are
always different, including across block boundaries. BST19 Proposition
9.3 with `h = 1` therefore supplies uniform `3`-balance at every depth.

Every triple of consecutive Thue–Morse bits contains an aligned pair
`t_{2n}, t_{2n+1}` of opposite bits. Thus there is no run of three identical
bits. Choose anchors at the ends of blocks encoding a zero bit. The first
anchor is depth `3`, every anchor ends in `012`, and successive anchors
are at most three blocks, or nine depths, apart. The positive matrix and
its ratio are the exact incidence computation above. Theorem W applies.

For completeness, `t` is not periodic: an even period can be divided by
two using `t_{2n} = t_n`. An odd period `p = 2a+1` would give
`t_{n+a} = 1 − t_n = t_{n+a+1}` for all `n`, making `t` eventually
constant, which its opposite adjacent aligned pairs exclude. In the
encoded directive, label zero occurs exactly at multiples of three; any
period must be a multiple of three and would induce a period of `t`. ∎

The imported balance bound, rather than a finite word census, justifies
the infinite anchor property. The example verifies that the weaker anchor
condition admits nonperiodic directives; it does not extend the theorem
to all BST19 instances.

## Exact finite guards and the remaining target

`kernel/sadic/overlap.mojo` computes `F` and `b_*` in checked arithmetic;
the independent Python oracle groups the proof's error terms differently
and uses arbitrary-precision integers and `Fraction`. Window powers use
logarithmic work in the kernel; overflow raises and is inconclusive.

The Python and Mojo tests enumerate short binary morphic images and
overlapping finite prefix returns. Negative controls demonstrate that
balance can grow through a morphism, length ratios can grow after a
positive anchor, and a finite pair of returns does not prove periodicity
of the whole word. These finite controls are not counterexamples in the
BST19 regime. Cross-language vectors compare both bound formulas.

The open all-depth target under BST19 Theorem 3.1 is unchanged. A next
route must derive additional balanced anchors, control transitions over
unbounded gaps, or change the state representation; it cannot merely add
a bounded-gap requirement to growing PRICE returns and retain the
nonperiodic setting. T2 and the S-adic Pisot conjecture receive no promotion.
