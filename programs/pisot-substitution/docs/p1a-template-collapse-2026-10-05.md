# P1a: the two surviving aligned templates are one template at the square — 2026-10-05

**Status:** one theorem proved here (Theorem C), with an exact certificate over
all 81 endpoint/good-edge placements. It reduces the **two** open obligations
A1 and A2 of [`p1a-aligned-cycle-normal-form-2026-10-01.md`](p1a-aligned-cycle-normal-form-2026-10-01.md)
§5 to **one**. It does **not** prove ternary strong coincidence, the aligned
branch of #138, seedwise overlap productivity, G1 or PSC — and §4 records, from
the sources, why the single remaining obligation is not free.

Canonical implementation: `kernel/psc/hub_selector.mojo`
(`template_collapses_at_square`, `pointwise_fixed_bad_edge`, `compose_map`,
`fixed_point_count`), regression `kernel/tests/test_hub_selector.mojo`.

## 1. What was open

Theorem 2.1 of the normal-form note proves that the aligned branch of a closed
nonproductive component leaves exactly two recurrent templates for the
deterministic first-child pair dynamics `H({i,j}) = {h(i), h(j)}`, where
`h = sigma_+` is the first-letter map, `{a,b}` is a fixed Barge–Diamond-good
pair and `c` the complementary hub:

1. **fixed edge** — one of `E_a = {a,c}`, `E_b = {b,c}` is setwise `H`-fixed;
2. **alternating E** — `E_a <-> E_b`, forcing `h(c) = c`, `h(a) = b`,
   `h(b) = a`.

Its §5 then set two separate proof obligations, A1 (fixed-edge forcing) and A2
(alternating-E interior-witness transport), and the roadmap has carried them as
"the two surviving templates" ever since.

The fixed-edge template itself splits, because `H(P) = P` for `P = {x, c}`
means `h` *permutes* `P`:

- **(i)** `h(x) = x` and `h(c) = c`;
- **(ii)** `h(x) = c` and `h(c) = x`.

So there are three surviving sub-templates, not two.

## 2. Theorem C

*Theorem C (template collapse).* Let `sigma` be PIP on three letters, `{a,b}`
an eventually coincident pair, `c` the hub, and suppose a closed nonproductive
set of states has a nonempty aligned branch. Then `sigma^2` is PIP, has the
same good pair and hub, has a closed nonproductive set with a nonempty aligned
branch, and its first-letter map `h o h` fixes **both letters of a bad edge
pointwise**. Moreover `h o h` fixes at least two of the three letters.

*Proof.* Four steps, each elementary.

1. **The endpoint map squares.** The first letter of `sigma^2(x)` is
   `h(h(x))`, so `(sigma^2)_+ = h o h`.

2. **Every sub-template becomes pointwise fixed.** By Theorem 2.1 the
   recurrent bad-pair cycle has period one or two.
   - Period one: `H(P) = P` for a bad edge `P = {x, c}`, so `h` restricted to
     `P` is a permutation of a two-element set. Its square is the identity on
     `P`, so `h o h` fixes `x` and `c`.
   - Period two: `h(c) = c`, `h(a) = b`, `h(b) = a`, so `h o h` is the
     identity on all three letters, and in particular fixes both letters of
     either bad edge.

   In both cases `h o h` fixes at least the two letters of a bad edge, which
   gives the last sentence.

3. **`sigma^2` is PIP.** Primitivity is inherited. The incidence matrix is
   `M^2` with dilation `beta^2 > 1` and conjugates of modulus `|beta_k|^2 < 1`,
   so the Pisot property holds. For irreducibility, `Q(beta^2) <= Q(beta)` has
   degree dividing three, so it is one or three; degree one would put
   `beta^2` in `Q`, impossible for a cubic irrational `beta`. So `beta^2` is
   cubic and the characteristic polynomial of `M^2` is irreducible.

4. **The hypotheses transfer.**
   - *Good pair.* If `sigma^n(a) = p d s` and `sigma^n(b) = p' d s'` with
     `pi(p) = pi(p')`, pick `m` with `2m >= n` and apply `sigma^{2m-n}` to
     both. The prefixes become `sigma^{2m-n}(p)`, `sigma^{2m-n}(p')` with
     `pi` images `M^{2m-n} pi(p) = M^{2m-n} pi(p')`, and the common letter is
     the first letter of `sigma^{2m-n}(d)`. So `{a,b}` is eventually
     coincident for `sigma^2`, with the same hub.
   - *Bad edge stays bad.* An eventual coincidence of `{x,c}` for `sigma^2` at
     level `2m` is one for `sigma` at level `2m`. So a pair that is not
     eventually coincident for `sigma` is not eventually coincident for
     `sigma^2`.
   - *Component.* A `sigma^2`-child is a `sigma`-grandchild, so a set of
     states closed under `sigma`-children is closed under `sigma^2`-children,
     and a set with no coincidence descendant under `sigma` has none under
     `sigma^2`. The aligned branch is the set of offset-zero vertices, which
     is the same set of letter pairs.

   `square`

*Corollary C1 (one obligation, not two).* A2 follows from A1 restricted to
case (i). Proving

> **A1′ (open).** For PIP `sigma` on three letters with an eventually
> coincident pair `{a,b}` and hub `c`: if `h` fixes both letters of a bad edge
> `{x, c}`, then `{x, c}` is eventually coincident,

for every PIP `sigma` kills all three sub-templates, since the other two
become case (i) for `sigma^2` and A1′ applied to `sigma^2` contradicts step 4.

*Where A1′ goes next.* [`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md)
takes it up: A1′ is the residual half of all-pairs strong coincidence, so it
holds on the 408,798 censused specimens; on the catch-up-free `|det M| = 2`
class it coincides with T2 of the box note, so the two open branches of
productivity meet; and the Barge–Diamond import cannot be aimed at it.

*Corollary C2 (A1′ in classical form).* `h(x) = x` and `h(c) = c` mean
`sigma(x) = x X` and `sigma(c) = c Y`, so the right-infinite words
`u = sigma^infinity(x)` and `w = sigma^infinity(c)` are both `sigma`-fixed.
`{x,c}` is eventually coincident exactly when the tilings of `[0, infinity)`
by `u` and by `w`, anchored at the same point, share a tile. So A1′ reads:

> **two distinct one-sided fixed points of a PIP substitution on three
> letters, anchored at a common point, share a tile.**

## 3. Exact certificate

`kernel/psc/hub_selector.mojo` exhausts all 27 endpoint self-maps against all
three choices of good edge. The first three columns reproduce the normal-form
note's table, which is the regression that the classifier and this theorem
agree; the last two are new.

| | placements |
| --- | ---: |
| no viable bad-pair orbit | 45 |
| fixed bad edge | 33 |
| alternating E | 3 |
| mixed recurrent periods | 0 |
| **viable, collapsing at the square** | **36 / 36** |
| of those, `h o h` fixes exactly two letters | 24 |
| of those, `h o h` fixes all three | 12 |

The 12 with all three fixed are the 9 fixed-edge placements where `h` is
already an involution on each bad edge plus the 3 alternating ones, where
`h o h = id`. The count is a regression for the hand proof above, not its
logical basis; an independent Python enumeration written first agreed on every
cell.

## 4. Literature gate (stop/go, 2026-10-05)

*Proposed claim under review.* Theorem C, and the use of A1′ as the single
remaining aligned obligation.

| Source | What it gives | Where it stops |
| --- | --- | --- |
| M. Barge, B. Diamond, *Coincidence for substitutions of Pisot type*, Bull. SMF 130 (2002), 619–626 — already read in full for [`p1b-barge-diamond-configuration-gate-2026-10-02.md`](p1b-barge-diamond-configuration-gate-2026-10-02.md) §3 | Theorem 1: for Pisot `phi` on `d >= 2` letters *some* pair of distinct letters is strongly coincident, and for `d = 2` every pair is. Its Case 1 (maximality) produces two eventually coincident segments **that start at the same point** — exactly an aligned configuration, which is the branch A1′ lives in | the pair it produces is whichever one maximality hands over; the argument cannot be aimed at a prescribed pair. That is precisely why `d >= 3` is open, and it is why A1′ does not follow from the import already in the ledger. Case 2 closes by a lattice argument that says nothing about which pair coincides |
| S. Akiyama, F. Gähler, J.-Y. Lee | the Pisot conjecture is settled by exhaustive search for every three-letter substitution whose incidence matrix has **trace at most 2** | a finite-domain result by trace, not a mechanism. Worth recording against this repository's own trace condition (`kernel/psc/degree2_sieve.mojo`), but it does not supply A1′ |
| P. Arnoux, S. Ito, *Pisot substitutions and Rauzy fractals* | the strong coincidence condition in its standard form, and that it is the hypothesis under which the Rauzy fractal construction gives a.e. one-to-one | states the condition; does not prove it beyond `d = 2` |

*Hypotheses that transfer.* Primitivity, irreducibility and the Pisot property
all pass to `sigma^2` (step 3), and so does the Barge–Diamond input, which is
only the existence of one eventually coincident pair.

*Hypotheses that do not.* Nothing here may use unimodularity, legality of a
swap word, finite `B_sigma`, or strong coincidence itself.

*Known negative control.* A1′ must **not** be provable by transitivity of
eventual coincidence. Eventual coincidence is stable under raising the level
(step 4) but is not transitive: two witnesses for `{i,j}` and `{j,k}` at a
common level decompose `sigma^n(j)` at two unrelated positions. A proposed
proof of A1′ that would also give transitivity would prove ternary strong
coincidence, a known open problem, and is therefore wrong or a major result.

*Decision: **proceed with a narrowed target.*** Theorem C is elementary and is
claimed only as a reduction. A1′ is recorded as a **special case of the open
ternary strong coincidence problem**, with the extra hypothesis that both
letters of the bad edge are `h`-fixed and that a closed nonproductive aligned
component exists. The next attempt should use that extra hypothesis — the
pair of `sigma`-fixed one-sided words of Corollary C2 — and must not route
through transitivity.

## 5. What this does not establish

- **Not #138, not strong coincidence.** Theorem C moves three sub-templates
  onto one. The surviving obligation A1′ is open and, by §4, is a special case
  of a known open problem: it is not a corollary of the Barge–Diamond import.
- **Not a new reduction of the component's structure.** Everything about the
  component comes from Theorem 2.1 and the Barge–Diamond eliminator, both
  already in the repository. The new content is that passing to `sigma^2`
  identifies the templates, and that the identification respects every
  hypothesis in play.
- **The square is not free of cost.** Statements proved for `sigma^2` transfer
  back to `sigma` only where eventual coincidence is level-stable, which step
  4 establishes for the pairs in question and for nothing else. Any later use
  of Theorem C must check that direction itself.
- **The 81-placement table is combinatorics about `h`, not about any
  substitution.** It certifies the endpoint bookkeeping of Theorem C; it says
  nothing about whether a PIP substitution realizes a given placement, and
  nothing about eventual coincidence.
- **Nothing here bears on the strict-zipper branch (#139)** or on T1/T2 of the
  box note. Those are the other half of productivity.
