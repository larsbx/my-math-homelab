# P1b: the strict zipper on the catch-up-free determinant-2 class — 2026-10-07

**Status:** stop/go literature check (AGENTS.md review gate), one reduction
assembled from existing results (§2), and an exact bounded family survey (§4). No
claim, ledger node or manuscript status changes. PSC, G1, #84 and #139 stay
open.

Canonical implementation: `kernel/catch_up_free_ppvc_census.mojo`
(`pixi run catch-up-free-ppvc-census [bound]`), regression
`kernel/tests/test_catch_up_free_ppvc.mojo`.

## 1. Why this, and why now

After October 5–7 the aligned (coincidence) half of overlap productivity is
settled on an infinite non-unimodular class: Theorems E, H and K of
[`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md) give all-pairs
strong coincidence (SC_all) on every PIP catch-up-free substitution with
`|det M| = 2`, except possibly on the non-crossing members of Theorem K's
family `F` outside the cells already closed. The other half — case (b) of
manuscript Proposition `prop:zipper-dichotomy`, the **strict zipper** — is
the next obligation for both headline targets:

- for **G1**: strict-zipper exclusion from every seed alone gives G1
  (manuscript Proposition `prop:G1-from-half-coincidences`);
- for **PSC**: with SC_all, boundary hitting is the whole remaining content
  of productivity (Corollary `cor:scc-reduction`(ii)).

The class is the natural place to attack it first, because there the
coincidence half is done and the arithmetic is the most rigid available: by
Lemma P every return to offset zero is a simultaneous birth, and by
Proposition P′ a vertex's level is the `M`-adic valuation of its position
([`p1b-vertex-coincidence-box-2026-10-02.md`](p1b-vertex-coincidence-box-2026-10-02.md)
§5.6b).

## 2. The reduction: PPVC is the single obligation on the class

*Proposition Z (assembled; every input already recorded).* Let `sigma` be PIP,
catch-up-free, with `|det M| = 2`, and outside the open part of Theorem K's
family `F`. Then

    sigma has pure discrete spectrum  ⟸  PPVC(sigma),

and `G1(sigma) ⟸ PPVC(sigma)` for every PIP `sigma` (in or out of the class).

*Proof.* PPVC ⟺ BH is Proposition V(1)–(2) with the table in
[`formal-productivity-reduction-2026-10-04.md`](formal-productivity-reduction-2026-10-04.md)
§5 (rests on Theorem B, independently audited, human review pending).
Theorem K and its closed cells give SC_all. Proposition FP gives
FP ⟺ SC_all ∧ BH, so every potential overlap is productive, in particular
those reachable from one swap seed, and manuscript Theorem `thm:main-density`
gives pure discrete spectrum. For G1: BH gives an offset-zero descendant to
every reachable vertex, which is strict-zipper exclusion from every seed, and
Proposition `prop:G1-from-half-coincidences` applies. `square`

The converse direction also holds (PDS ⇒ PPVC is Theorem S), so on the class
**PSC is equivalent to PPVC**, outside the open part of `F`. The strict
zipper is no longer one of two problems there; it is the problem.

## 3. Stop/go: prior art

| Source | What it gives | Transfers? |
| --- | --- | --- |
| M. Barge, *The Pisot conjecture for β-substitutions*, ETDS 38 (2018), [arXiv:1505.04408](https://arxiv.org/abs/1505.04408) | pure discrete spectrum for the β-substitution of **every** Pisot β, unit or not: the strongest theorem on a non-unimodular parametric family | Only through a conjugacy of tiling spaces. A necessary condition is that `chi_M` be the polynomial of a three-letter simple-Parry β-substitution, `x^3 − t_1 x^2 − t_2 x − t_3` with the Parry ordering. Among the 383 PIP members of Theorem E's classes with `p, q, r <= 11`, **313 fail it** (scratch check, exact); the other 70 are not shown conjugate, and nothing below relies on them. |
| T. Sellami, *Balanced pair algorithm for a class of cubic substitutions*, Turkish J. Math. 39 (2015) 91–102 | the balanced-pair algorithm run **uniformly** over a parametric family (`x^3 − a x^2 − b x − 1`, two substitutions with one matrix) | The idea — a symbolic BPA over parameters — transfers; the family is unimodular and different. A scratch BPA on Theorem E's classes argues **against** this route here: maximal state length grows exponentially along lines (class A `(n, n−1, n)`: 480, 2,124, 27,768 letters at `n = 4, 5, 6`), so the states are not parametric words. Redirect to the overlap graph, whose vertices are bounded. |
| V. Berthé, J. Bourdon, T. Jolivet, A. Siegel, ETDS 36 (2016), [arXiv:1401.0704](https://arxiv.org/abs/1401.0704) | a finite certificate for an infinite family (Brun / Jacobi–Perron products) | The idea, as for Theorem H; their families are unimodular. |
| Barge–Štimac–Williams, DCDS 33 (2013) | termination from one swap seed (or dense coincidence) ⇒ PDS | Used as imported (manuscript `thm:bsw`). |
| Akiyama–Gähler–Lee, DMTCS (2014), [arXiv:1403.0362](https://arxiv.org/abs/1403.0362) | PSC for three-letter substitutions of trace at most 2, by exhaustive search | Finite; Theorem E's class A has trace at least 3. No mechanism. |
| Siegel–Thuswaldner, zero-expansion graph | a finite graph deciding whether 0 lies in a tile | Same principle as the box graph (no novelty claimed for it); unit-only proof, recorded 2026-10-05. |

Hypotheses that do **not** transfer: unimodularity (every source using
`M^{-1}`-integrality or the contracting plane alone); the β-language
monotonicity of Barge's proof, which general members lack (§7 of
[`p1b-strict-zipper-periodic-pair-2026-10-02.md`](p1b-strict-zipper-periodic-pair-2026-10-02.md)).
Negative controls that any proposed lemma must respect are those of the
side-notes ledger §1 (one-step valuation ascent fails on all 210 corpus
catch-up-free specimens; adelic coverage needs the PDS multiplicity-one
property; endpoint hitting fails on the golden pump).

**Decision: proceed, narrowed** to PPVC on the explicit parametric families
of the class (Theorem E's classes A–D, the swap family, Proposition Y's two
families, small members of `F`), by an exact family survey first and, if the survey
supports it, a parametric certificate on the overlap graph. No source
inspected proves PPVC, balanced-pair termination or pure discrete spectrum
for these families.

## 4. Family survey (exact)

A bounded survey of parameter presentations, not a corpus census in the sense
of AGENTS.md: it enumerates the families' presentations at a bound and screens
each, and most members lie outside the standing corpus. The class's 210 corpus
members are covered by the standing PPVC census.

`decide_vertex_coincidence` (Proposition V) decides PPVC for every `r` at
once on one finite box graph per member, so a failure is a verdict and the
driver raises on one; a capped graph is an exhausted budget and also raises.
The exact Perron kernel is certified for images of length at most 6, so
members with a longer image are counted as skipped, never decided.

`deepest` is the largest first offset-zero depth over the recurrent box
vertices of a member.

| family (bound 4; `bound 2` in brackets) | decided | skipped | deepest | `deepest` histogram |
| --- | --- | --- | --- | --- |
| Theorem E classes A–D, `p, q, r <= 4` | 58 (17) | 0 | 13 (13) | `3:1 4:19 5:23 6:7 7:5 8:1 10:1 13:1` |
| swap family, ten endings | 150 (40) | 0 | 14 (14) | `3:6 4:44 5:50 6:18 7:14 8:6 9:4 10:4 13:2 14:2` |
| Proposition Y, F1 and F2 | 20 (6) | 0 | 14 (14) | `3:3 4:8 5:5 7:2 9:1 14:1` |
| Theorem K's family, `|w_1|, |w_2| <= 4` | 130 (5) | 0 | 14 (14) | `3:15 4:53 5:30 6:20 7:6 8:2 9:1 14:3` |

**358 members decided, PPVC holds on every one**, none capped, none skipped.
Run: `pixi run catch-up-free-ppvc-census 4`, about 10 minutes; bound 2 is
pinned by the regression. The deepest member of Theorem E's classes is class
D `(1, 0, 0)` at depth 13. These members have images of length up to 6, past
the image-length-4 and total-length-8 PPVC censuses. For the 228 members
outside `F`, Theorem K supplies SC_all, so by Proposition Z each is a new
finite certificate of pure discrete spectrum (resting on the unreviewed
inputs listed in §6). For the 130 members of `F` this survey gives G1; their
SC_all is proved only where Theorem K's cells reach and is not re-checked
here.

**What the numbers say.** PPVC holds on every decided member. The depth is
largest at the smallest parameters and falls to 4–5 in the bulk; it does not
grow with the parameters. The recurrent vertex count grows slowly along lines
(class B `(n, 0, 1)`: 124, 138, 156, 186 for `n = 1..4`), so the recurrent
set is not parameter-independent but is plausibly a finite union of
parametric families.

## 5. What a proof needs, and the first obstacle

A parametric certificate in the style of Theorem H needs, for a cone of
parameters, (i) a parametric description of a superset of the recurrent
vertices `(i, j, w)` and (ii) for each, an offset-zero witness path —
Lemma W of the A1′ note without its last letter condition: positions with
`gamma_n = 0`. Part (ii) is the Theorem H machinery verbatim. Part (i) is the
obstacle: membership of `(i, j, w)` in the overlap graph is a real condition,
`−ell_j < <ell, w> < ell_i` together with the contracting box, and `ell`
depends on `beta`, hence on the parameters, transcendentally in no sense but
algebraically of degree 3. Two ways forward, in order:

1. **Cycle addresses instead of geometry.** A recurrent vertex lies on a
   cycle, and manuscript Lemma `lem:ordered-cycle` determines its offset from
   the ordered digit address alone: `w_0 = (I − M^r)^{−1} sum M^{r−1−k} d_k`
   with digits `d_k` in the one-step prefix-difference set. On the class the
   proper nonempty prefixes are `o y^k`, so every digit lies in
   `{0, ±(e_o + k e_y), e_{o'} − e_o + k e_y}` with `k` in a run range — an
   affine family in the parameters, and integrality of `w_0` is exact.
   **But the geometry cannot be dropped**: a digit cycle chosen without the
   interval condition is a *formal* cycle, and formal coincidence-free cycles
   are ubiquitous (13,260 on the standing corpus,
   [`formal-overlap-carriers-2026-10-04.md`](formal-overlap-carriers-2026-10-04.md)).
   Each step must keep the chosen sub-tiles overlapping, a sign condition on
   an element of `Z[beta]`. Those signs are decidable per member but not
   affine in the parameters. The workable form is to bracket `beta` on a cone
   between explicit rational functions of the parameters (from `f(t)` at
   two rational points, as Lemma P1 does at `±1`) and decide each sign on the
   bracket, cutting the cone where the bracket is too wide.
2. **Bound the depth uniformly first.** §4 says the depth is small in the
   bulk. A uniform bound `K` on the class would reduce PPVC to a finite
   statement about `M^K w ∈ D_K(i, j)` on that digit family.

The next step is (1) on one class: enumerate, per cone, the ordered digit
cycles of length at most the observed cycle lengths whose centre offset is
integral and whose interval conditions hold on a `beta` bracket, and test
whether each has an offset-zero witness path that verifies on the whole cone.
The survey of §4 is the negative control: the cover must find every
recurrent vertex the box graph finds, member by member.

## 5a. Follow-up (same day)

The certificate was built on one line instead of a digit-cycle cover: the
swap-seed closure removes the need for a trapping region, and along
`p = 2q + 2`, `r = q + 1` in class B it is a finite symbolic graph with
constant offsets.
[`p1b-symbolic-line-2026-10-07.md`](p1b-symbolic-line-2026-10-07.md) proves
**Theorem L**: pure discrete spectrum and G1 for every member of that line.
On 2026-10-08 the same closure in two parameters, with `beta` bracketed
between certified rational functions, gave **Theorem C** of
[`p1b-symbolic-cone-2026-10-08.md`](p1b-symbolic-cone-2026-10-08.md): pure
discrete spectrum and G1 on every member of class B below slope `5/2`; the
layer near slope 3 stays open.

## 6. What this does not establish

- No strict zipper is excluded on any infinite family; PPVC is decided only
  on the finite list of §4.
- Proposition Z is an assembly of recorded results. Its inputs Theorem B,
  Proposition FP and Theorem K are repository-proved and not yet
  independently reviewed, and Theorem K leaves part of `F` open.
- The β-polynomial count of §3 is a scratch exact check of a necessary
  condition, not a conjugacy test.
