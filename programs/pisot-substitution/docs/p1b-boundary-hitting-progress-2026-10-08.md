# P1b: boundary hitting at every reachable strict-zipper vertex — progress, 2026-09-21 → 2026-10-08

**Status:** status synchronisation for issue #139. It also adds two
computer-assisted results, both unreviewed: Theorem L″ (§4), 32 one-parameter
families, and Theorem W (§4b), two-parameter families of class D, on which
#139's obligation is proved and so pure discrete spectrum and finite BPA
hold. No ledger node or manuscript statement changes. #84, #138, #139,
G1 and PSC stay open.

Canonical implementation for §4: `kernel/symbolic_line_certificate.mojo`
(now any line of Theorem E's four classes), regression
`kernel/tests/test_symbolic_line.mojo`, evidence workflow
`.github/workflows/class-b-lines-evidence.yml`.

## 0. The obligation, stated once

For PIP `sigma` on three letters, let `Reach(s)` be the overlaps reachable from
the swap seed `s`, and let `L(x)` be the first offset-zero depth of `x`
(`∞` if there is none). Issue #139 asks for

    AllSeedStrictZipperExclusion(sigma):  ∀ s ∀ x ∈ Reach(s).  L(x) < ∞,

which is *boundary hitting at every reachable strict-zipper vertex*. A vertex
with `L(x) = ∞` lies above a closed SCC with no offset-zero vertex. That SCC is
case (b) of manuscript Proposition `prop:zipper-dichotomy`, the strict zipper.
Its realization-free form is

    BH(sigma):  every potential overlap on a cycle has L < ∞.

What it buys (all recorded, with their review status):

| from | to | by |
| --- | --- | --- |
| `AllSeedStrictZipperExclusion` | G1 (finite BPA) | `G1HalfCoincidenceRoute` (Prop. `prop:G1-from-half-coincidences`) |
| `BH ∧ SC_all` | FP, hence PDS | Proposition FP (#211) |
| `BH` | `PPVC` | Proposition V (#211; rests on Theorem B) |
| `PDS` | `BH` | Theorem S + Corollary FP″ (#211) |

So `BH ⟺ PPVC`, and BH and PDS are equivalent wherever `SC_all` is known.

## 1. What the recent PRs did for it

In order of landing. "Advance" means a change in what is proved, what is
reduced, or what is excluded as a route. Census-only rows are labelled as
such.

| PR | Date | What it does for #139 | Kind |
| --- | --- | --- | --- |
| #141 | 09-21 | Literature gate. Names the residual obligation `AdelicPeriodicOffsetHitting`. Compactness, multiple tiling, Perron-criticality and the Archimedean projection alone are excluded. | scoping |
| #181 | 10-01 | M-adic carry theorem. Descaled zero-class candidates obey `z' = M z + pi(q) − pi(p)`, the overlap affine update itself. So quotient-depth sieving cannot close #139 on its own. | stop result |
| #211 | 10-04 | Proposition V / Theorem B: `BH ⟺ PPVC` on a finite box automaton. Proposition FP: `FP ⟺ SC_all ∧ BH`. Corollary FP″: `FP ⟺ PDS`. #139 becomes realization-free, and decidable per specimen. | reduction |
| #227 | 10-07 | Theorems E, H, K: `SC_all` on the catch-up-free `\|det M\| = 2` class, outside part of Theorem K's family `F`. Corollary C3: there, #138's A1′ and #139's T2 are **the same** boundary-hitting statement. Proposition LC: the leftmost-chain (`CU`) route cannot reach #139, whose obstruction is interior-vs-interior (Theorem B). | reduction, redirect |
| #231 | 10-07 | Adversarial audit of Proposition V and Theorem E. No disproof, no failing step. | review |
| #232 | 10-08 | Proposition Z: on the class (outside `F`'s open part) `PSC ⟺ PPVC`, so the strict zipper is *the* problem there. Survey: PPVC on 358 parametric members, depth ≤ 14, not growing. **Theorem L:** BH from every seed on the infinite class-B line `p = 2q + 2, r = q + 1`, so PDS and G1 for all of it. This is the first infinite family on which #139's obligation is proved. | **theorem on an infinite family** |
| #233 | 10-08 | Theorem Ω: BH plus `SC_all` on the box gives PDS through Lee–Moody–Solomyak plus Proposition V step 1, which is elementary. So the finite-domain BH verdicts no longer rest on Theorem B. `BoundedPureDiscreteSpectrum` holds on 145,806 specimens. | finite-domain theorem |
| #234 (open) | 10-08 | Theorem SC: one productive seed ⟺ every seed ⟺ FP ⟺ PDS. Choosing the seed gives no slack, only a different object. **Theorem L′:** fourteen more class-B lines. | theorem on 14 families |
| this note | 10-08 | **Theorem L″:** the same certificate on 32 lines of classes A, C and D. **Theorem W:** two-parameter certificates on six wedges of class D, independent of the class-B sectors of Theorem C (`p1b-symbolic-cone-2026-10-08.md`, landed meanwhile); with the lines, every PIP member of class D with `r ≥ q − 1` (Corollary W1). Class A at slope 1 is recorded as out of reach of the constant-graph method. | theorems on new one- and two-parameter families |

Summarised: on 2026-09-21 #139 was an adelic hitting problem with no
decision procedure. Today it is:

1. **decidable per specimen** (PPVC on the box, #211). The decision rests on
   elementary facts and an import (#233).
2. **the whole of PSC** on the catch-up-free `|det M| = 2` class, outside
   `F`'s open part (#232).
3. **proved on infinitely many infinite families**: lines of Theorem E's classes
   (#232, #234, §4), and two-parameter wedges covering every PIP member of
   class D with `r ≥ q − 1` (§4b).

The universal statement is untouched. No uniform-in-`|S|` mechanism has been
found, and the acceptance criterion of #139 is not met.

## 2. What stays settled negatively

Do not re-attempt any of these. Each is recorded with its evidence.

- Cycle algebra, affine pumps, bounded collars, generic Perron growth, the
  contracting lower bound (issue body; side-notes ledger §1).
- Quotient-depth (M-adic) sieving without a coverage theorem (#181).
- The `CU` / leftmost-chain route (#227, Proposition LC). Its obstructions
  are prefix-vs-interior and harmless.
- Picking a better seed (#234, Theorem SC). It changes the object, not the
  truth.
- A parametric BPA. Its states grow exponentially along lines (#232 §3).
  Use the overlap graph, whose vertices are bounded.

## 3. Where the line method stands

The method of `p1b-symbolic-line-2026-10-07.md` §2 decides one line from its
**seed** graph, symbolically in the line parameter. It needs a seed graph of
constant size along the line, with constant offsets. That held on every line
of Theorems L and L′. Where it fails, the method raises or exhausts its
budget. It never certifies a false graph (Lemma S).

Exact seed-graph sizes (scratch probe through `exact_hits`, not pinned) show
which lines the method can reach:

| line (`p`, `q`, `r`) | exact seed-graph size at the sampled `n` |
| --- | --- |
| B `(n + 1, n, n + 1)` | 121 at `n = 3, 6, 10, 14, 20` |
| A `(n + 1, n, n + 1)` | 235, 355, 515, 675, 915 at `n = 3, 6, 10, 14, 20` |
| A `(n + 1, n, n − 1)` | 300, 458, 618, 778 at `n = 4, 8, 12, 16` |
| A `(n + 3, n, n + 1)` | 138, 178, 254, 294 at `n = 4, 8, 12, 16` |
| A `(3n, n, n + 1)` | 276, 324, 294, 302 at `n = 4, 8, 12, 16` |
| A `(2n + 1, n, n + 1)` | 198, 194, 194, 194 at `n = 4, 8, 12, 16` |
| C `(n + 1, n, n)` | 169 at `n = 4, 8, 12, 16` |
| D `(n + 1, n, n)` | 246 at `n = 4, 8, 12, 16` |
| D `(n + 1, n, 2n)` | 93 at `n = 4, 8, 12, 16` |

In **class A at slope 1** the seed graph grows linearly in `n`. At
`p = n + 1` it grows by about 40 vertices per unit of `n` on both branches,
and at `p = n + 3` more slowly. The one-parameter method needs a symbolic
graph of constant size, so it cannot certify these lines. The four lines
`p = n + 1, n + 2`, `r = n ± 1` were stopped after 12 CPU-minutes each
without output. That is an exhausted budget, not a verdict. At slope 2, and
in classes C and D, the graph is constant from small `n` on, and §4
certifies those lines.

## 4. Theorem L″: lines of classes A, C and D

The driver took class-B lines only. It now takes any line of Theorem E's
normal form,

    sigma(x) = x y^p s_x,   sigma(c) = c y^q s_c,   sigma(y) = t y^r s_y,

in class A, B, C or D (endings from `class_ending`), with `p, q, r` affine
in `n`:

    mojo run -I . symbolic_line_certificate.mojo CLASS AP BP AQ BQ AR BR

Here `p = AP·n + BP`, and likewise for `q` and `r`. Old invocations and pins
are unchanged: no argument runs Theorem L, `SLOPE K BRANCH` runs a class-B
line, and `lines` runs every pinned line. Below the threshold, the parameters
counted as outside are those leaving the normal form (`p, q, r ≥ 0`), and, in
classes A–C, those violating Lemma P1's necessary PIP condition `p > q`.
These are the same parameters the class-B driver already skipped.

*Theorem L″.* For each line below, every PIP member is catch-up-free with
`|det M| = 2`, and every overlap reachable from any of its three swap seeds has
an offset-zero descendant. So every member has all-pairs strong coincidence
(Corollary E2, which covers all four classes), productivity of every
seed-reachable overlap (Corollary `cor:scc-reduction`(ii)), **pure discrete
spectrum** (Theorem `thm:main-density`), and a **finite balanced-pair
automaton** (Proposition `prop:G1-from-half-coincidences`). Status as for
Theorem L: computer-assisted, unreviewed, resting on Theorem E (unreviewed)
and on the imported Barge–Štimac–Williams theorem. The literature gate of
`p1b-catch-up-free-ppvc-2026-10-07.md` §3 governs, and the novelty claim is
as narrow as Theorem L's: no source in that gate proves pure discrete
spectrum for these families. Barge (2018) could reach a member only through a
conjugacy to a β-substitution, which is not checked here.

| class | `p` | `q` | `r` | symbolic vertices | threshold `q0` | below `q0`: PIP, all hitting / not PIP / outside | sign reads | wall-clock (four lines at a time on four cores) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A | `2n` | `n` | `n − 1` | 281 | 39 | 38 / 0 / 1 | 7,722 | 184 s |
| A | `2n` | `n` | `n + 1` | 210 | 20 | 19 / 0 / 1 | 6,356 | 80 s |
| A | `2n + 1` | `n` | `n − 1` | 365 | 87 | 85 / 1 / 1 | 10,590 | 829 s |
| A | `2n + 1` | `n` | `n + 1` | 194 | 19 | 19 / 0 / 0 | 5,808 | 110 s |
| A | `2n + 2` | `n` | `n − 1` | 325 | 107 | 104 / 2 / 1 | 9,846 | 1107 s |
| A | `2n + 2` | `n` | `n + 1` | 230 | 52 | 52 / 0 / 0 | 6,590 | 294 s |
| A | `2n + 3` | `n` | `n − 1` | 303 | 128 | 124 / 3 / 1 | 9,418 | 1674 s |
| A | `2n + 3` | `n` | `n + 1` | 260 | 14 | 14 / 0 / 0 | 7,370 | 110 s |
| C | `n + 1` | `n` | `n − 2` | 279 | 36 | 33 / 1 / 2 | 6,792 | 101 s |
| C | `n + 1` | `n` | `n` | 169 | 17 | 17 / 0 / 0 | 4,026 | 64 s |
| C | `n + 2` | `n` | `n − 3` | 238 | 37 | 32 / 2 / 3 | 6,276 | 112 s |
| C | `n + 2` | `n` | `n − 1` | 182 | 23 | 22 / 0 / 1 | 4,572 | 64 s |
| C | `n + 3` | `n` | `n − 4` | 229 | 39 | 32 / 3 / 4 | 6,376 | 124 s |
| C | `n + 3` | `n` | `n − 2` | 188 | 36 | 34 / 0 / 2 | 5,184 | 96 s |
| D | `n − 1` | `n` | `n − 1` | 150 | 22 | 19 / 2 / 1 | 3,782 | 41 s |
| D | `n − 1` | `n` | `n` | 128 | 17 | 15 / 1 / 1 | 3,066 | 34 s |
| D | `n − 1` | `n` | `n + 1` | 111 | 26 | 23 / 2 / 1 | 2,958 | 32 s |
| D | `n − 1` | `n` | `n + 2` | 105 | 38 | 34 / 3 / 1 | 3,018 | 42 s |
| D | `n − 1` | `n` | `n + 3` | 105 | 43 | 38 / 4 / 1 | 3,130 | 51 s |
| D | `n − 1` | `n` | `n + 4` | 105 | 97 | 91 / 5 / 1 | 3,130 | 212 s |
| D | `n − 1` | `n` | `2n − 3` | 105 | 14 | 11 / 1 / 2 | 3,160 | 47 s |
| D | `n − 1` | `n` | `2n − 2` | 113 | 12 | 10 / 1 / 1 | 3,256 | 40 s |
| D | `n + 1` | `n` | `n − 1` | 250 | 24 | 23 / 0 / 1 | 5,718 | 58 s |
| D | `n + 1` | `n` | `n` | 246 | 19 | 19 / 0 / 0 | 5,402 | 66 s |
| D | `n + 1` | `n` | `n + 1` | 181 | 21 | 21 / 0 / 0 | 4,198 | 54 s |
| D | `n + 1` | `n` | `n + 2` | 132 | 22 | 22 / 0 / 0 | 3,418 | 34 s |
| D | `n + 1` | `n` | `n + 3` | 97 | 18 | 17 / 1 / 0 | 2,870 | 22 s |
| D | `n + 1` | `n` | `n + 4` | 93 | 49 | 47 / 2 / 0 | 2,886 | 62 s |
| D | `n + 1` | `n` | `2n − 1` | 93 | 22 | 21 / 0 / 1 | 2,944 | 47 s |
| D | `n + 1` | `n` | `2n` | 93 | 15 | 15 / 0 / 0 | 2,912 | 63 s |
| D | `n + 1` | `n` | `2n + 1` | 113 | 14 | 14 / 0 / 0 | 3,416 | 49 s |
| D | `n + 1` | `n` | `2n + 2` | 193 | 10 | 10 / 0 / 0 | 5,882 | 76 s |

**32 new lines**: 8 in class A, 6 in class C, 18 in class D. With the 15 class-B lines of Theorems L and L′, 47 lines are pinned in `certified_lines()`. Each was run once through the committed driver, one core each, and every cross-check passed. Each row is pinned in `certified_lines()` and re-run by the evidence workflow; `tests/test_line_certificate_workflow.py` keeps the workflow matrix equal to the pin list. The regression `test_a_class_d_line_is_certified` re-certifies the class-D line `(n + 1, n, n + 3)` on every test run.

**Refusals, all correct.** The certificate refused five more lines at the PIP step, and each is outside the Pisot class:

- class D, `p = n − 1`, `q = n`, `r = 2n + b` for `b = 0, 1, 2`: a second eigenvalue of modulus above 1 (exactly 1 at `b = −1`);
- class D, `p = n + 1`, `q = n`, `r = 2n + 3`: a second eigenvalue of modulus 1;
- class D, `p = n + 1`, `q = n`, `r = 3n` and `3n + 1`: a second eigenvalue of modulus about 1.3.

(Float spectra at `n = 20, 80`, as a scratch diagnosis of the refusals; the refusal itself is the exact certificate's.) No PIP line of classes C or D that was tried failed to certify.

## 4b. Theorem W: two-parameter wedges of class D

Class D (`sigma(x) = x y^p c`, `sigma(c) = c y^q x`, `sigma(y) = c y^r c`) has
`|det M| = 2` exactly when `p = q ± 1`, so each branch is a two-parameter
family in `(q, r)`. Lemma P1's `f(1) = −2p + r − 1 < 0` bounds it by `r ≤ 2p`,
and `f(−1) = −2p + 4q − 3r − 3 < 0` by roughly `r > 2q/3`.

**The data.** On a grid (`q = 8, 12, …, 40`, every admissible `r`; scratch
probe through the exact kernel), the exact seed graph is **the same graph**,
with the same letters and the same integer offsets, on a whole cone of each
branch:

| branch | cone with one seed graph | vertices | outside it, toward `r = 2p` | below it |
| --- | --- | --- | --- | --- |
| `p = q − 1` | `q + 2 ≤ r ≤ 2q − 3` | 105 | the line `r = 2q − 2` (certified, §4) | lines `r = q − 1, q, q + 1` (certified), then a second constant cone, then a Pisot-boundary fringe |
| `p = q + 1` | `q + 4 ≤ r ≤ 2q` | 93 | lines `r = 2q + 1, 2q + 2` (certified) | lines `r = q − 1 … q + 3` (certified), then likewise |

So the symbolic object is a finite graph that does not depend on the
parameters at all. Only the sign decisions do.

**The method.** `psc.symbolic_line` now works over `Q[a, b]`. A wedge is
`(p, q, r)` affine in `(a, b) ∈ Z_{≥0}^2` along a unimodular pair of
directions, so the integer points `(a, b)` are exactly the integer points of
a cone in the `(q, r)` plane. Three changes make the decisions sound in two
variables. A line has no `b`, so none of them touches a line, and every line
pin is reproduced unchanged.

1. *Quadrant signs.* A polynomial in `a, b` is read on `a ≥ A, b ≥ B` by
   substituting `a → A + a′, b → B + b′` and asking for one coefficient sign
   with a nonzero constant term, after multiplying by `(1 + a′ + b′)^N` if
   needed (Pólya). The certificate holds for all **real** `a′, b′ ≥ 0`. If no
   corner works up to a cap, it raises.
2. *A discriminant-free PIP test.* With `|det M| = 2`, a real monic cubic has
   one root in `(2, ∞)` and two in the open unit disc **iff**
   `χ(−1) < 0`, `χ(1) < 0` and `χ(2) < 0`. (Given a root `β > 2`, the other
   two are the roots of `x² + ux + v = χ(x)/(x − β)` with `|v| = 2/β < 1`, and
   Jury's test asks `χ(±1)/(±1 − β) > 0`. Conversely `β > 2` because the other
   two have product of modulus `< 1`.) With `χ(−2) ≠ 0` there is no rational
   root. The Sturm-count test of the line method fails here: its last entry
   is the discriminant, which changes sign where the two small roots switch
   between real and complex, and on the `p = q + 1` branch it does so on a
   parabolic region `b ≲ √(2a)` that no set of boundary lines removes.
3. *Signs at β by norm.* By item 2, at every real point of the region β is
   the unique root above 1 and depends continuously on `(a, b)`. So `h(β)`
   keeps one sign wherever it does not vanish. If the norm
   `det h(M) = Π h(θᵢ)` has a certified nonzero sign on the region, `h(β)`
   never vanishes, and its sign is read exactly at one integer point. The
   Sturm–Tarski query of the line method fails here too, because its
   intermediate entries change sign along curves with **irrational**
   asymptotes (slopes `2√2`, `(3 ± √17)/2` were met), which no rational split
   avoids. The norm only has to avoid zeros, not sign changes of subresultants.

The integer points outside the certified quadrant lie on finitely many
boundary lines `a = i < A` and `b = j < B`. A wedge is therefore pinned as its
**core** (`wedge …` reproduces `a0`, `b0` and the vertex count) together with
its boundary lines. Each boundary line is certified as a line, which also
decides its finite part exactly, and is pinned in `certified_norm_lines()`.
`test_every_wedge_edge_is_a_pinned_line` checks that no edge is missing and
that the edges cover the wedge outside its quadrant.

The boundary lines are certified in **norm mode**: as lines, but with items
2 and 3 in place of the Sturm-entry readings. This is not cosmetic. The
boundary lines include those beside the asymptote, and there the line
method's Sturm entries have large real roots. The line `a = 10` of the first
`p = q − 1` sub-wedge (`3r − 4q = −9`) gets threshold `q0 = 196` read by
Sturm entries. Its exact finite part then costs about 5 hours, with members
growing like `n^1.6` (78 s at `n = 100`). Read by norm, the threshold is
`q0 = 4`, and all 89 boundary lines certify in at most 125 s each. The 47
lines of Theorems L, L′ and L″ keep their Sturm-mode pins, so their recorded
thresholds stay reproducible.

One more obstruction forces a split. On a whole cone a run-position bound is
not one affine function: it changes regime along the ray `3r = 4q`, and the
fitted bound fails certification. Each branch is therefore cut into three
unimodular sub-wedges along the Farey directions `(1,1)`, `(3,4)`, `(2,3)`,
`(1,2)`, which tile the cone exactly.

*Theorem W.* For each sub-wedge below, every PIP member is catch-up-free with
`|det M| = 2`, and every overlap reachable from any of its three swap seeds
has an offset-zero descendant. So every member has pure discrete spectrum
and a finite balanced-pair automaton (as for Theorem L″). Status:
computer-assisted, unreviewed. It rests on Theorem E and the
Barge–Štimac–Williams import as Theorem L does, and on the soundness of items
1–3 above (proved here, unreviewed).

| branch | sub-wedge `(q, r)` | symbolic vertices | quadrant `a ≥ a0, b ≥ b0` | boundary lines | their parts below threshold: PIP, all hitting / not PIP / outside | sign reads (core) |
| --- | --- | --- | --- | --- | --- | --- |
| `p = q − 1` | `(5, 7) + a(1, 1) + b(3, 4)` | 105 | `15, 7` | 22 | 200 / 0 / 0 | 1,818 |
| `p = q − 1` | `(13, 18) + a(3, 4) + b(2, 3)` | 105 | `1, 0` | 1 | 1 / 0 / 0 | 1,818 |
| `p = q − 1` | `(4, 5) + a(2, 3) + b(1, 2)` | 105 | `7, 7` | 14 | 65 / 0 / 0 | 1,818 |
| `p = q + 1` | `(11, 15) + a(1, 1) + b(3, 4)` | 93 | `1, 3` | 4 | 5 / 0 / 0 | 1,619 |
| `p = q + 1` | `(13, 18) + a(3, 4) + b(2, 3)` | 93 | `15, 15` | 30 | 197 / 0 / 0 | 1,619 |
| `p = q + 1` | `(-2, -4) + a(2, 3) + b(1, 2)` | 93 | `3, 15` | 18 | 124 / 0 / 6 | 1,619 |

*Corollary W1.* **Every PIP member of class D with `r ≥ q − 1` has pure
discrete spectrum and a finite balanced-pair automaton.** On the branch
`p = q − 1`, the certified lines `r = q − 1, q, q + 1`, the three sub-wedges
(`q + 2 ≤ r ≤ 2q − 3`) and the certified line `r = 2q − 2` cover
`q − 1 ≤ r ≤ 2q − 2`. On the branch `p = q + 1`, the lines `r = q − 1, …,
q + 3`, the sub-wedges (`q + 4 ≤ r ≤ 2q`) and the lines `r = 2q + 1, 2q + 2`
cover `q − 1 ≤ r ≤ 2q + 2`. Above that, `r ≥ 2p + 1` and Lemma P1
(`f(1) = −2p + r − 1 < 0`) rules out PIP. With Theorem C of
`p1b-symbolic-cone-2026-10-08.md` (class B below slope `5/2`), these are the
two-parameter families on which #139's obligation is proved so far.

## 4c. Two two-parameter engines

Theorem C's engine (`psc/symbolic_cone.mojo`, class B) and Theorem W's
(`psc/symbolic_line.mojo` in two-parameter mode, class D) were written
independently and landed on the same day. They agree on the parts that must
agree:

- Pólya-certified signs on a shifted quadrant;
- unimodular cones;
- run positions fitted at the same three samples and certified;
- boundary strips handled as one-parameter families.

They differ in how a sign at `β` and the PIP property are read:

| | Theorem C (`symbolic_cone`) | Theorem W (`symbolic_line`, norm mode) |
| --- | --- | --- |
| sign of `G(β)` | rational brackets `L(s) < β < U(s)` from a fixed-point iteration; `G` monotone or extremal at the ends | nonvanishing norm `det G(M)` on the region, then one exact sample point (continuity of `β`) |
| PIP | brackets, then Rouché (`\|c₂\| > 1 + \|c₁\| + \|c₀\|`), else Jury on the quotient | `χ(−1), χ(1), χ(2) < 0`, equivalent to Pisot when `\|det M\| = 2` |
| boundary strips | one-parameter cones of the same engine | norm-mode lines of the line driver (`certified_norm_lines()`) |
| what it needs | a bracket for `β` per family | nothing family-specific |

Neither engine is a special case of the other. The bracket method needs a
convergent iteration for `β`, which class B has in closed form. The norm
method needs the norm to avoid zero on the region. A query either method
cannot settle raises in both. **Two engines is DRY debt.** The natural
consolidation is one closure over `Q[s1, s2]` with both sign readers behind
one interface, norm first and brackets as fallback. Its first step is done:
the algebra both engines run on (polynomials in the two parameters, polynomials
in `t` over them, weight vectors) is one module, `psc/param_poly.mojo`, with
the cone's `(s1, s2)` read as `(b, a)`; both engines' tests reproduce their
output byte for byte through it. Still separate: the Pólya certificate (the
cone multiplies by `1 +` the coordinates that occur, cap 24; the line by
`1 + a + b`, cap 40), the sign readers (`Region`, `Eventual`), the two PIP
tests and the two closures. Unifying those needs each theorem's pins
reproduced through the shared code. Until then, the engines are useful
cross-checks of each other: running class D's cones through the bracket
engine, and class B's through the norm engine, is cheap independent evidence.

## 5. Next, in order

1. **The rest of class D.** Below `r = q − 1`, each branch has a second
   constant-graph cone (grid data, §4b) and then a fringe along the Pisot
   boundary `f(−1) = 0`, where the graphs keep changing, like class B at
   slope 3. The second cone is the next wedge. The fringe needs either
   vertex families (item 3) or a proof that its graphs come from finitely
   many patterns.
2. **Wedges of classes A and C.** Class B is covered below slope `5/2` by
   Theorem C (`p1b-symbolic-cone-2026-10-08.md`). Class C's lines
   `p = q + d`, `r = q − d ± 1` form a two-parameter family in `(q, d)`, and
   class A's slope-2 lines suggest a wedge `2q ≤ p ≤ 2q + k`. Each needs the
   grid probe first, because both engines need a constant graph.
3. **Growing seed graphs (class A, slope 1).** The vertices come in families
   indexed by a run position `0 ≤ j ≤ n`. The symbolic object is a vertex
   *family* `(a, b, w_0 + j·u)`, with children decided uniformly in `j`. This
   is Theorem H's parametric witness paths applied to vertices, not only to
   witnesses.
4. **The uniform mechanism.** Every certified line and wedge so far has a
   bounded seed graph and small hitting depth. A uniform depth bound `K` on
   the catch-up-free `|det M| = 2` class would make BH there a finite
   statement about `M^K w ∈ D_K(i, j)` (#232 §5.2). That is the first
   statement in this programme of the uniform kind #139's acceptance
   criterion asks for.
