# P1b: boundary hitting on a whole line, by a symbolic overlap graph — 2026-10-07

**Status:** one theorem, computer-assisted, repository-proved and unreviewed
(Theorem L, §3), and the method that proves it (§2). It is the first step of
the digit-cycle certificate planned in
[`p1b-catch-up-free-ppvc-2026-10-07.md`](p1b-catch-up-free-ppvc-2026-10-07.md)
§5, specialised to one line of Theorem E's class B. The literature gate of
that note governs. No ledger node or manuscript statement changes.

Canonical implementation: `kernel/psc/symbolic_line.mojo`, driver
`kernel/symbolic_line_certificate.mojo` (`pixi run symbolic-line-certificate`),
regression `kernel/tests/test_symbolic_line.mojo`. The Python series
prototype that found the method, written independently, is archived with its
output in `archive/2026-10-07/symbolic-line-probes/`.

## 1. What the data said

Class B of Theorem E is `sigma(x) = x y^p x`, `sigma(c) = c y^q x`,
`sigma(y) = c y^r x`, with `|r − q| = 1` and `p > q` (Lemma P1). Along the
line `p = 2q + 2`, `r = q + 1` the exact kernel's swap-seed overlap graph is
**the same 119 vertices for every q from 3 to 20 tested** (same letter pairs,
same offset vectors `w ∈ Z^3`), and the recurrent part of the box graph is
the same 120 vertices from `q = 3` on (float prototype, then exact kernel).
The mechanism: with `r = q + 1`, the left Perron vector satisfies
`ell_c = ell_y (1 − 1/beta)`, `ell_x = ell_y (beta − 1 − r + 1/beta)` and
`(beta − 2)(beta − 1 − r + 1/beta) = p`, so on this line
`beta = q + 4 − 3/q + O(q^-2)` and the tile-length ratios converge
(`ell_x / ell_y → 2`, `ell_c / ell_y → 1`): the geometry stops changing,
while the runs only lengthen.

Off the line it does change. For `p ≫ q`, `beta ~ sqrt(p)` and
`ell_x / ell_y` grows, so the recurrent set grows with `p`, and the method of
§2 needs Puiseux expansions there (§5).

## 2. The method: the overlap graph as a function of q

Only overlaps **reachable from the swap seeds** are needed (§3), not the box
graph, so no trapping region has to be proved. They are computed for all large
`q` at once:

- **Vertices** are `(a, b, w)` with `w` a vector of integer polynomials in `q`.
- **Children** follow the images' segments: first letter, the `y`-run, last
  letter. A child inside a run sits at offset `base + m e_y` with
  `m = k_b − k_a` the difference of run positions, `base` the offset of the
  segment pair. Children with equal letters and offset are one vertex.
- **Realness** of a child, `−ell_B < <ell, w'> < ell_A`, is two signs at
  `beta(q)` of elements of `Q[q][t] / (chi)`.
- **Run positions.** The admissible `m` form an open real interval of bounded
  length. Its integer endpoints are guessed by exact evaluation at
  `q = 200, 400`, fitted as affine functions of `q`, and **certified** by two
  sign queries each. The intersection with the run ranges
  `[−(n_a − 1), n_b − 1]` is decided by eventual signs of affine differences.
  A range whose width grows with `q` raises.
- **Signs** are parametric Sturm–Tarski queries: the signed pseudo-remainder
  sequence of `(chi, chi' G)` over `Q[q]`, read at `t = 1` and `t = ∞`, with
  pseudo-division by even powers of leading coefficients so that each term is
  a positive multiple of the classical one. Every entry is a polynomial in
  `q`; its sign for `q` above its largest real root (isolated exactly,
  `largest_root_bracket`) is that of its leading coefficient. The maximum of
  those roots over every query of the run is the threshold.
- **The line is PIP** for every `q` above the threshold, by the same queries:
  the support of `M` is fixed and primitive; `chi` has no rational root (the
  determinant is the constant 2, so only `±1, ±2` are candidates); one root
  lies in `(1, ∞)`; and the other two lie in the open unit disc.

*Lemma S (soundness).* If the run finishes with threshold `T`, then for every
integer `q > T` the exact swap-seed overlap graph of `sigma_q` is the
symbolic graph with `q` substituted.

*Proof.* Induction along the breadth-first closure. The seeds are decided by
realness signs, each valid for `q > T`. For a vertex, each child of the exact
graph comes from one segment pair and one position pair, and its presence is
decided by the same signs and by the certified integer range of `m`, all
valid for `q > T`. Sign queries are exact for `q > T` because there every
entry of every sequence has the sign of its leading coefficient, every
pseudo-division multiplier is a nonzero even power, so Sturm–Tarski applies.
Under the certified PIP property `chi` has exactly one root in `(1, ∞)`, so
the query is the sign at `beta`. `square`

The search part (the sample fits) only proposes. A wrong guess fails
certification and raises; it cannot certify a false range.

## 3. Theorem L

**Theorem L.** For every `q >= 0`, the substitution

    sigma_q(x) = x y^(2q+2) x,   sigma_q(c) = c y^q x,   sigma_q(y) = c y^(q+1) x

is PIP with `|det M| = 2`, and every overlap reachable from any of its three
swap seeds has an offset-zero descendant. Consequently `sigma_q` has **pure
discrete spectrum** and its balanced-pair automaton is **finite** (G1).
Status: repository-proved, computer-assisted, unreviewed.

*Proof.* `symbolic_line_certificate.mojo`, about 4 minutes:

| part | result |
| --- | --- |
| PIP of the line, every `q >= 52` | certified (support primitive; `chi(±1), chi(±2) ≠ 0`; one root in `(1, ∞)`; the other two in the unit disc) |
| symbolic swap-seed graph, every `q >= 52` | **119 vertices**, every offset a constant vector, **every vertex with an offset-zero descendant**; 3,729 distinct parametric sign queries, threshold `52239/1024 ≈ 51.01` |
| `q = 0, …, 51` | all 52 members PIP; each exact seed-reachable graph has every vertex hitting |
| cross-check at `q = 52, 57` | the symbolic graph with `q` substituted equals the exact graph |

By Lemma S the exact swap-seed graph of every `sigma_q` with `q >= 52` is
the symbolic one, so in every case every seed-reachable overlap has an
offset-zero descendant.

*Consequences.* `sigma_q` is in Theorem E's class B (`h` fixes `x` and `c`),
so Corollary E2 gives the strong coincidence condition for every pair. By
manuscript Corollary `cor:scc-reduction`(ii), every overlap reachable from a
seed is then productive, and Theorem `thm:main-density` gives pure discrete
spectrum. Hitting from every seed is hypothesis (a) of Proposition
`prop:G1-from-half-coincidences`, which gives G1. `square`

This is the Pisot substitution conjecture for an infinite non-unimodular
family, on top of the repository's unreviewed inputs (Theorem E for strong
coincidence, the imported Barge–Štimac–Williams theorem behind
`thm:main-density`). The novelty claim is narrow: no source in the gate
proves pure discrete spectrum for this family. Barge (2018) could reach it
only through a conjugacy to a β-substitution, which is not checked here.

## 4. What is trusted

- **Proved by hand:** Lemma S; the reduction in §3.
- **Trusted:** the Mojo implementation of the parametric pseudo-remainder
  sequence and the eventual-sign reader (`psc.symbolic_line`); the exact
  kernel for the finite range; the vendored exact root isolation.
- **Cross-checks, not part of the proof:** at `q0` and `q0 + 5` the
  symbolic graph with `q` substituted equals the exact kernel's graph vertex
  for vertex; the independent Python series prototype (Laurent expansions of
  `beta` in `1/q`, a different decision method) produces the same 119
  vertices; the exact kernel gives the same 119 vertices at
  `q = 3, 4, 6, 9, 14, 20`.

## 5. What it does not establish, and next

- One line, not the class. Class B is a two-parameter cone with two branches
  `r = q ± 1`. For fixed `k`, the lines `p = 2q + k` behave like this one.
  The data shows the seed and recurrent sets stabilising in `q` for each `k`.
  But `k` is unbounded, and for `p ≫ q` the expansions are in `sqrt(p)`. The
  next steps are a second parameter (`k` symbolic on the regime where
  `ell_x / ell_y` stays bounded) and Puiseux expansions for the `p ≫ q`
  corner.
- Nothing about the other classes, the swap family or Theorem K's family.
- No review beyond its author.

**Follow-up (2026-10-08).** The second parameter is done for class B below
slope `5/2`: Theorem C of
[`p1b-symbolic-cone-2026-10-08.md`](p1b-symbolic-cone-2026-10-08.md). The
`p ≫ q` corner above does not occur in class B (Lemma P1 gives `p < 3q + 12`);
the real obstruction is the layer near slope 3, recorded there in §5.
