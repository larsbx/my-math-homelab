# P1b: boundary hitting on two-parameter sectors of class B — 2026-10-08

**Status:** one theorem, computer-assisted, repository-proved and unreviewed
(Theorem C, §4), the method that proves it (§2), and the obstruction that
stops it short of all of class B (§5). It extends Theorem L of
[`p1b-symbolic-line-2026-10-07.md`](p1b-symbolic-line-2026-10-07.md) from one
line to every member of class B below slope `5/2`. The literature gate of
[`p1b-catch-up-free-ppvc-2026-10-07.md`](p1b-catch-up-free-ppvc-2026-10-07.md)
§3 governs (its decision names exactly this target: "a parametric certificate
on the overlap graph" for Theorem E's classes); §6 adds the method's own prior
art. No ledger node or manuscript statement changes.

Canonical implementation: `kernel/psc/symbolic_cone.mojo`, driver
`kernel/class_b_cone_certificate.mojo` (`pixi run class-b-cone-certificate`),
regression `kernel/tests/test_symbolic_cone.mojo`.

## 1. What the data said

Class B is `sigma(x) = x y^p x`, `sigma(c) = c y^q x`, `sigma(y) = c y^r x`,
`|r − q| = 1`, PIP only for `q < p < 3q + 12` (`r = q + 1`) or `q < p < 3q`
(`r = q − 1`) by Lemma P1. The exact kernel's swap-seed graph, scanned over
`p` at `q = 20, 21, 28, 40` (scratch), is **constant on sectors** of the
`(q, p)` plane bounded by lines of slope `1, 3/2, 2, 5/2, …`, and changes only
on finitely many boundary lines between them:

| branch | sector | vertices |
| --- | --- | --- |
| `r = q + 1` | `q + 5 <= p <= 2q − 1` | 74 |
| `r = q + 1` | `2q + 14 <= p <= (5q + 10)/2` | 226 |
| `r = q − 1` | `q + 5 <= p`, `2p <= 3q − 2` | 123 |
| `r = q − 1` | `q + 4 <= 2(p − q)`, `p <= 2q − 6` | 171 |
| `r = q − 1` | `2q + 8 <= p`, `2p <= 5q − 5` | 217 |

The mechanism is the one of Theorem L in two variables. With `ell_y = 1`,

    ell_c = 1 + (q − r)/beta,   ell_x = p/(beta − 2),   beta = r + 1 + (q − r)/beta + p/(beta − 2),

so `ell_x ≈ p/q`: on a sector the tile ratio moves inside one interval between
the thresholds where a realness condition can flip, while the offsets stay
constant and the runs only lengthen. Near slope 3 (`ell_x → 3`) the sectors
shrink and their graphs grow (§5).

## 2. The method: signs on a region, beta on a bracket

A *cone* is a family `sigma_s`, `s = (s1, s2)` in a shifted orthant
`{s1 >= n1, s2 >= n2}`, with `(p, q, r)` affine in `s`. The closure is the one
of Theorem L (vertices `(a, b, w)`, `w` now in `Q[s1, s2]^3`; children by
segment pairs; run positions fitted and certified), with its decision
procedures replaced:

- **Signs on the region.** `f(s) > 0` on the region is certified when
  `f(n1 + u, n2 + v)` has nonnegative coefficients and positive constant term,
  possibly after multiplying by `(1 + u + v)^k` (Pólya's multiplier; `1 + u`
  or `1 + v` when one coordinate does not occur), `k <= 24`. The sign is
  guessed at one point and then certified; an uncertified sign raises.
- **Signs at beta.** The two-variable Sturm–Tarski sequence has entries whose
  signs need not be constant on a region, so it is not used. Instead the
  driver proposes rational functions `L(s) < beta < U(s)`: the iterates
  `x0 = r + 1`, `x_{k+1} = g(x_k)` of the fixed-point form above, which
  alternate around `beta` (`[x2, x1]`, then `[x2, x3]`). An element `G` of
  `Q[s][t]/(chi)`, reduced to degree `<= 2` (`chi` is monic), has the sign of
  `G(L)` and `G(U)` when they agree and either `G' ` has one sign at both ends
  (monotone) or the leading coefficient has the opposite sign (the extreme of
  `|G|` on the bracket is at an end). Each such sign is a region sign of
  `den^2 G(num/den)`. Undecided on every bracket raises.
- **PIP on the region**, by the same reads: support fixed and primitive;
  `det M = ±2`, `chi(±1), chi(±2) != 0`; for every bracket `|det M| < L`,
  `chi(L) < 0 < chi(U)`; and the Jury conditions `|v| < 1`, `|u| < 1 + v` on
  the quotient `chi(t)/(t − beta) = t^2 + u t + v` (`u = c_2 + beta`,
  `v = det M / beta`), read as `beta^2 + (c_2 + 1) beta + det M > 0` and
  `−beta^2 + (1 − c_2) beta + det M > 0`. Then the two other roots lie in the
  open unit disc, `chi` is irreducible, and `beta` is the root in each bracket.
  *Update 2026-10-08:* the disc condition is now tried first by Rouché
  (`rouche_disc`): `|c_2| > 1 + |c_1| + |c_0|` read as three plain region
  signs, with no sign at `beta`. Jury runs only where those signs are not
  certified. Re-running `class_b_cone_certificate.mojo plus` and `minus`
  with the change reproduces the archived run exactly: the same certified
  regions at the same shifts, and the same totals (32 regions and 198 exact
  members on `+1`; 45 and 292 on `−1`). On `−1` the exact members also
  match one for one; the archived `+1` log does not list them. The port
  simplifies the PIP step and changes no verdict.
- **Run positions.** Before fitting an interval end, the run ends are tried:
  if the first (last) run position already satisfies the lower (upper)
  realness condition, the run end clips the interval and no fit is made;
  empty intervals are recognised the same way. Only an unclipped end is
  fitted, at `n + (200, 200)`, `n + (400, 200)`, `n + (200, 400)`, as an affine
  function of `s`, and certified by two sign reads.

*Lemma S′ (soundness).* If the closure finishes on the region `R`, then at
every integer point of `R` the exact swap-seed overlap graph of `sigma_s` is
the symbolic graph with `s` substituted.

*Proof.* Lemma S of the line note, with "for every `q > T`" replaced by "at
every point of `R`": each decision the closure takes is a sign certified on
all of `R` (a polynomial positive on the real region is positive at its
integer points), the brackets and the PIP property are certified on `R`, so
each sign at `beta` is correct at every point, and the run-position ranges
are exact at every point by their certification. `square`

The cover (`class_b_cone_certificate.cover`) runs the closure on
`{s >= l + (n, n)}` for the least `n` in `0, 1, 2, 3, 4, 6, 8, …` at which it
finishes, recurses on the strips `s1 = l1 + k`, `s2 = l2 + k` (`k < n`) as
one-parameter families, and decides the finitely many points left on a line
by the exact kernel. Every certified region is cross-checked at one integer
point against the exact graph, vertex for vertex (not part of the proof).

## 3. The decomposition

Families, with `j = p − q` (`kernel/class_b_cone_certificate.mojo`,
`plus_branch`, `minus_branch`). The 2D cones use unimodular generators, so
they contain every lattice point of their sector.

`r = q + 1`, region `q < p <= max(2q + 13, ⌊(5q + 10)/2⌋)`:

- `J+j`: `p = q + j`, `j = 1..4`;
- `A+`: `(q, p) = (6, 11) + s1 (1, 2) + s2 (1, 1)` — `5 <= j <= q − 1`;
- `C+c`: `p = 2q + c`, `c = 0..13`;
- `B+`: `(q, p) = (18, 50) + s1 (1, 2) + s2 (2, 5)` — `p >= 2q + 14`, `2p <= 5q + 10`.

`r = q − 1`, region `1 <= q < p` with `p <= 2q + 7` or `2p <= 5q − 5`:

- `J−j`: `j = 1..4`;
- `A−`: `(q, j) = (12, 5) + s1 (2, 1) + s2 (1, 0)` — `j >= 5`, `2j <= q − 2`;
- `M−d`: `2j = q + d`, `d = −1..3`;
- `B−`: `(q, j) = (16, 10) + s1 (1, 1) + s2 (2, 1)` — `2j >= q + 4`, `j <= q − 6`;
- `C−c`: `p = 2q + c`, `c = −5..7`;
- `D−`: `(q, p) = (21, 50) + s1 (1, 2) + s2 (2, 5)` — `p >= 2q + 8`, `2p <= 5q − 5`.

*Coverage.* For `r = q + 1`: `j <= 4` is `J+`; `5 <= j <= q − 1` is `A+`
(`s1 = j − 5`, `s2 = q − 1 − j`); `j >= q` with `p <= 2q + 13` is `C+c`,
`c = j − q`; the rest is `B+`. For `r = q − 1`: `j <= 4`; else `2j <= q − 2`
(`A−`); else `2j <= q + 3` (`M−`); else `j <= q − 6` (`B−`); else
`c = p − 2q >= −5`, and `c <= 7` (`C−`) or `2p <= 5q − 5` (`D−`). The driver
also checks this by enumeration up to `q = 200`, solving each family's affine equations exactly (no gap; a gap appears as soon
as the claimed region is enlarged by one line).

## 4. Theorem C

**Theorem C.** Let `sigma` be in Theorem E's class B with

- `r = q + 1` and `p <= max(2q + 13, (5q + 10)/2)`, or
- `r = q − 1` and `p <= max(2q + 7, (5q − 5)/2)`.

Then every overlap reachable from any of its three swap seeds has an
offset-zero descendant. Consequently `sigma` has **pure discrete spectrum**
and its balanced-pair automaton is **finite** (G1). Status: repository-proved,
computer-assisted, unreviewed.

*Proof.* `class_b_cone_certificate.mojo`, about 80 minutes (logs in
`archive/2026-10-08/class-b-cone-run/`), and Lemma S′:

| branch | families | symbolic regions certified | exact members | not PIP (outside class B) | largest graph |
| --- | --- | --- | --- | --- | --- |
| `r = q + 1` | 20 | 32 | 198 | 4 | 297 (`C+7`) |
| `r = q − 1` | 25 | 45 | 292 | 34 | 274 (`C−1`) |

Every symbolic vertex and every vertex of every exact graph has an
offset-zero descendant, and each of the 77 certified regions agrees with the
exact graph at its cross-check point. The 2D sectors and their vertex counts:
`A+` 74, `B+` 226 (on `s >= (4, 4)` and eight strips), `A−` 123, `B−` 171,
`D−` 217; region shifts are at most 24, the exact members have `q <= 28`, and the
largest exact graph has 1,331 vertices. The
consequences follow exactly as for Theorem L: Corollary E2 gives SC_all on
class B, manuscript Corollary `cor:scc-reduction`(ii) and Theorem
`thm:main-density` give pure discrete spectrum, and Proposition
`prop:G1-from-half-coincidences` gives G1. `square`

Theorem L is the line `C+2`; the cone engine re-proves it from `q >= 6`
(the Sturm engine needed `q >= 52`), two independent decision methods
agreeing.

The fourteen lines of Theorem L′
([`p1-seed-strength-2026-10-08.md`](p1-seed-strength-2026-10-08.md) §5),
certified independently by the Sturm engine, are the families `J±1..3`,
`C+0`, `C+1`, `C+3`, `C+4` and `C−0..3` here, and every symbolic vertex count
agrees (121, 77, 79; 166, 144, 131; 76, 84, 123, 123; 124, 274, 255, 248).
Theorem C contains them; the cone engine's thresholds on them are at most 24,
against Sturm's 11 to 128.

*Independent cross-check, 2026-10-08.* A second engine certified the part of
Theorem C with `q < p <= 2q + 4` (`r = q + 1`) and `q < p <= 2q + 3`
(`r = q − 1`). It was written in parallel, as the line engine generalised to coefficients in
`Q[s, d]`. Its decision procedures are separate from `psc.symbolic_cone`'s:
- region signs by its own Pólya reader;
- PIP by Rouché, `|c_2| > 1 + |c_1| + |c_0|`, instead of Jury;
- `beta` brackets refined by Newton and chord steps.

It is not code-independent, though. Both engines rest on `psc.symbolic_line`'s
primitives: the support-primitivity test `primitive_support`, the offset-zero
reachability that is now `zero_descendants`, and the exact Sturm reads at sample
points. A bug in those would be common to both. The exact kernel's
cross-checks are shared as well.

It cut the wedge `q < p < 2q` into two cones, `s >= d` and `s < d`, plus 54
boundary lines. Every overlapping vertex count agrees with this note:

| branch | families of this note | counts |
| --- | --- | --- |
| `+1` | `J+1..4` | 121, 77, 79, 76 |
| `+1` | `A+` (both cones and 21 lines) | 74 |
| `−1` | `J−1..4` | 166, 144, 131, 125 |
| `−1` | `A−` (cone `s < d`; lines `p = q + j`, `j = 5..8`; lines `2j = q − e`, `e = 2..4`) | 123 |
| `−1` | `M−(−1)..3` (lines `2j = q + d`) | 125, 125, 133, 164, 175 |
| `−1` | `B−` (cone `s >= d`; lines `2j = q + e`, `e = 4..8`; lines `p = 2q − d`, `d = 6..8`) | 171 |
| `−1` | `C−(−5)..(−1)` (lines `p = 2q − d`) | 173, 175, 186, 195, 112 |

Logs: `archive/2026-10-08/class-b-wedge-crosscheck/`. The engine is not
merged, because it duplicates this one. It is reachable at commit `5ee3f0f`.
Two engines with different PIP certificates, sign readers and bracket schemes
agreeing is a cross-check of those decision procedures, not of the shared
primitives, and not part of the proof.

## 5. What it does not establish: the top layer

- **Not all of class B.** Above slope `5/2` the scans show further sectors,
  narrower and with larger graphs (`r = q + 1`, `q = 40`: 226 up to
  `p = 105`, then 242, 258, 256, 418, 422, 390, 368, 356, …), whose slopes
  accumulate at 3; along the lines `p = 3q + 11 − d`, `d` fixed, the graph
  grows linearly in `q` (`d = 0`: 2,655, 3,101, 3,549, 3,997, 4,893 vertices
  at `q = 8, 12, 16, 20, 28`). Each further sector is in reach of the same
  method, but there are infinitely many; the top layer needs vertex families
  indexed by an extra variable and an inductive hitting argument, which this
  method does not provide.
- PIP members of class B left open: those with `r = q + 1`,
  `max(2q + 13, (5q + 10)/2) < p < 3q + 12`, and `r = q − 1`,
  `max(2q + 7, (5q − 5)/2) < p < 3q` (by Lemma P1 nothing else is PIP).
- Nothing about classes A, C, D, the swap family or Theorem K's family.
- No review beyond its author.

## 6. What is trusted, and prior art of the method

- **Proved by hand:** Lemma S′, the coverage argument of §3, the Jury
  criterion for a real quadratic (`|v| < 1`, `|u| < 1 + v`; E. I. Jury,
  *Theory and Application of the z-Transform Method*, 1964) and the sufficiency
  of the shifted-coefficient and Pólya certificates (a positive combination of
  monomials is positive on the open orthant; Pólya's multiplier, G. Pólya
  1928, Hardy–Littlewood–Pólya *Inequalities* §2.24, is used only in that
  direction, never for completeness).
- **Trusted:** the Mojo implementation (`psc.symbolic_cone`), the exact kernel
  for the finite points, the line engine's exact Sturm queries at the sample
  points (search only).
- **Cross-checks, not part of the proof:** one exact comparison per certified
  region; Theorem L reproduced.
- **Prior art.** Bracketing a Perron root between rational functions of the
  parameters is how Lemma P1 and Theorem H's cuts already work in this
  repository, and is standard in parametric Pisot screens. Sellami (2015) runs
  the balanced-pair algorithm uniformly over a one-parameter unimodular
  family; no source in the gate proves pure discrete spectrum for these
  non-unimodular two-parameter families.
