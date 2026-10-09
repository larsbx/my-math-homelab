# #84 at seed strength: what the seed buys, and fourteen new lines — 2026-10-08

**Status:** research note for issue #84, following the 2026-10-06 audit's
recommendation to "attack #84 at seed strength". It contains four results:

- Proposition SA, elementary and proved here;
- Theorem SC, an assembly of existing statements at their recorded review
  status;
- Lemma RC with its census consequence, an exact finite check;
- Theorem L′, computer-assisted with the Theorem L method and unreviewed.

It changes no ledger node. #84, #138 and #139 stay open, and PSC stays open.

## 1. The question

Issue #84 asks, for every PIP substitution on three letters, for **one** swap
seed `(ab, ba)` whose reachable overlaps are all productive (`OP_seed`). The
audit (`audit-2026-10-06.md` §2) proposed working at this strength, because it
asks less than all-pairs strong coincidence (#138) or productivity of every
vertex (`OP_all`). It also proposed a stepping stone:

- **the bi-good seed-pair target**: some pair `{a, b}` is eventually
  coincident for both `sigma` and its reversal.

This note asks what the freedom to choose the seed actually buys. The answer
has two parts.

- **No room in what is true.** For each substitution, one seed is productive
  exactly when every seed is, and exactly when `sigma` has pure discrete
  spectrum (§3).
- **Some room in how it is proved.** The seed changes the object to be
  controlled (§4). The useful attack at seed strength is therefore a
  family-uniform certificate on the seed graph. §5 adds fourteen infinite
  families by that method.

## 2. Proposition SA (anatomy of one seed)

*For PIP `sigma` and letters `a ≠ b` with `ell_b < ell_a`, the seed
`(ab, ba)` has exactly three seed overlaps:*

- *`(a, b, 0)`, on `[0, ell_b)`;*
- *`(a, a, ell_b)`, on `[ell_b, ell_a)`;*
- *`(b, a, ell_b − ell_a)`, on `[ell_a, ell_a + ell_b)`.*

*Their regions partition the period. With `ell_a < ell_b` the middle one is
`(b, b, −ell_a)`.*

*Proof.* In the first period the top tiling has `a` on `[0, ell_a)` and `b` on
`[ell_a, ell_a + ell_b)`. The bottom has `b` on `[0, ell_b)` and `a` on
`[ell_b, ell_a + ell_b)`. Of the four tile pairs, three meet in an open
interval when `ell_b < ell_a`. The fourth, top `b` against bottom `b`, does
not, since `ell_b < ell_a`. The lengths are never equal, because `ell` has
`Q`-independent coordinates. `square`

The first and third overlaps are manuscript Proposition 5.39 (i)–(ii).
`OP_seed(ab, ba)` therefore forces `{a, b}` to be eventually coincident for
`sigma` and for its reversal. A productive seed always has a bi-good pair: its
own. What this proposition adds is the count, and the middle overlap. That
overlap is a tile against **its own translate** by `ell_b`. Its depth-`n`
descendants compare the word `sigma^n(a)` with itself shifted by
`beta^n ell_b`.

`kernel/tests/test_seed_strength.mojo` checks the anatomy on all 13,662
pairs of the 4,554 standing specimens.

## 3. Theorem SC (seed collapse)

*For PIP `sigma` the following are equivalent:*

1. *`OP(s)` for **some** swap seed `s`;*
2. *`OP(s)` for **every** swap seed `s`;*
3. *formal productivity, FP;*
4. *every vertex of the box automaton is productive;*
5. *pure discrete spectrum.*

*Proof.*

- (1) ⇒ (5) is Theorem 5.38 (`thm:main-density`: Lemma 5.36 and the
  imported Barge–Štimac–Williams theorem).
- (5) ⇒ (3) is Corollary FP″ (`formal-productivity-reduction-2026-10-04.md`).
  The manuscript says the same after Theorem 5.38: "the converse now holds
  for every PIP `sigma` … by the proof of Theorem `thm:seedwise`".
- (3) ⇔ (4) is Theorem Ω (`pds-certificate-from-the-box-automaton-2026-10-07.md`).
- (3) ⇒ (2), because every seed-reachable overlap is a potential overlap.
- (2) ⇒ (1) is trivial. `square`

*Dependencies.* The direction (5) ⇒ (3) rests on the October 4 chain at its
recorded review status:

- Theorem S, through Proposition V, Theorem B, Lemma C, Proposition F and
  Theorem R;
- the Barge coincidence-rank imports;
- Akiyama–Lee 2014 Corollary 4.5.

The chain was re-derived independently in the Theorem Ω note §6, with no
error found. Human review is still pending. The other directions are
elementary, or rest on Theorem 5.38.

**Consequences.**

- *A one-seed-to-every-seed implication now holds, through PDS.* It holds
  at the review status above. `README.md` and `proof-ladder.md` said that
  none was claimed; both now carry a dated correction pointing here.
- *#84 at seed strength is the ternary Pisot conjecture, one substitution at a
  time.* Proving `OP_seed` for a family proves PDS for that family, and
  nothing weaker would do.
- *The bi-good target is necessary, and the strongest form of it is forced.*
  By (5) ⇒ (2) and Proposition SA, PDS makes **every** pair eventually
  coincident for `sigma` and for its reversal. So a PIP substitution without
  a bi-good pair would refute PSC. This is a falsification target, not a
  relaxation.

## 4. What the choice of seed does buy

**The object.** Theorem SC says nothing about the graphs. On 444 of the 4,554
standing specimens the three seeds reach **different** recurrent parts, and no
seed's recurrent part is ever empty (`test_the_recurrent_part_depends_on_the_seed`).
A proof may choose the seed whose closed sets are easiest to control. It
cannot choose one whose closed sets are absent.

**Lemma RC (reversal closure).** *Reversing all three images maps each census
domain onto itself: the standing corpus, total length ≤ 8, images ≤ 4 and
total length ≤ 10.* Reversal preserves image lengths and the incidence
matrix, hence PIP. It is checked on the first two domains in
`test_the_census_domains_are_closed_under_reversal`.

*Consequence.* The prefix strong-coincidence census of
`strong-coincidence-census-2026-10-04.md` has no failure on any of the four
domains. Suffix strong coincidence for `sigma` is prefix strong coincidence
for its reversal. So **every pair of every member of all four domains is
eventually coincident from both ends**: 408,798 specimens at total length
≤ 10, with no new run. The bi-good target holds there in its strongest form.

## 5. Theorem L′: fourteen more lines of class B

The method of Theorem L (`p1b-symbolic-line-2026-10-07.md`) decides one
class-B line from its **seed** graph, symbolically in `q`. Class B is
`sigma(x) = x y^p x`, `sigma(c) = c y^q x`, `sigma(y) = c y^r x`, with
`|r − q| = 1` and `p > q`. It needs no trapping region and no box. Each line
it certifies is an infinite family with pure discrete spectrum, proved at
seed strength. This is the seed-strength attack in its only productive form
(§3).

`kernel/symbolic_line_certificate.mojo` now takes any line
`p = slope·q + k`, `r = q + branch` (`... SLOPE K BRANCH`, or `lines` for the
committed list). The default is still Theorem L's line, unchanged. For each
line the driver:

- certifies the PIP property and a constant determinant symbolically;
- requires `|det M| = 2`;
- decides every member below the threshold `q0` with the exact kernel,
  skipping parameters outside class B;
- cross-checks the symbolic graph against the exact graph at `q0` and
  `q0 + 5`.

*Theorem L′.* For each line in the table below, every PIP member is
catch-up-free with `|det M| = 2`, and every overlap reachable from any of its
three swap seeds has an offset-zero descendant. Consequently every member has:

- strong coincidence for every pair (Corollary E2);
- productivity of every seed-reachable overlap (Corollary
  `cor:scc-reduction`(ii));
- **pure discrete spectrum** (Theorem `thm:main-density`);
- a **finite balanced-pair automaton** (Proposition
  `prop:G1-from-half-coincidences`).

The status matches Theorem L: computer-assisted, unreviewed, and resting on
Theorem E (unreviewed) and the imported Barge–Štimac–Williams theorem.

| line | `p` | `r` | symbolic vertices | threshold `q0` | members below `q0`: PIP, all hitting / not PIP / outside class B | sign reads | wall-clock |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Theorem L | `2q + 2` | `q + 1` | 119 | 52 | 52 / 0 / 0 | 3,729 | 228 s |
| new | `q + 1` | `q + 1` | 121 | 14 | 14 / 0 / 0 | 3,328 | 44 s |
| new | `q + 2` | `q + 1` | 77 | 11 | 11 / 0 / 0 | 2,288 | 32 s |
| new | `q + 3` | `q + 1` | 79 | 22 | 22 / 0 / 0 | 2,442 | 34 s |
| new | `q + 1` | `q − 1` | 166 | 20 | 19 / 0 / 1 | 4,472 | 60 s |
| new | `q + 2` | `q − 1` | 144 | 16 | 14 / 1 / 1 | 4,110 | 58 s |
| new | `q + 3` | `q − 1` | 131 | 32 | 30 / 1 / 1 | 4,048 | 65 s |
| new | `2q` | `q + 1` | 76 | 20 | 19 / 0 / 1 | 2,576 | 23 s |
| new | `2q + 1` | `q + 1` | 84 | 17 | 17 / 0 / 0 | 2,726 | 42 s |
| new | `2q + 3` | `q + 1` | 123 | 14 | 14 / 0 / 0 | 3,999 | 58 s |
| new | `2q + 4` | `q + 1` | 123 | 15 | 15 / 0 / 0 | 3,971 | 74 s |
| new | `2q` | `q − 1` | 124 | 34 | 33 / 0 / 1 | 3,955 | 98 s |
| new | `2q + 1` | `q − 1` | 274 | 87 | 85 / 1 / 1 | 8,615 | 831 s |
| new | `2q + 2` | `q − 1` | 255 | 107 | 104 / 2 / 1 | 8,304 | 1221 s |
| new | `2q + 3` | `q − 1` | 248 | 128 | 124 / 3 / 1 | 8,107 | 1773 s |

Every line was run through the committed driver
(`symbolic_line_certificate.mojo SLOPE K BRANCH`, one core each). Every cross-check
passed. The list is `certified_lines()` in the driver, and each entry pins its
verdict: the threshold, the vertex count, and the member counts. Certifying a
listed line raises unless it reproduces that pin.
`.github/workflows/class-b-lines-evidence.yml` re-certifies every listed line,
one job each, on pull requests that touch the driver's import closure, weekly,
and on demand.

**Where the method stops.**

- *Slope 3 with `r = q − 1` leaves the class.* With `k = 0` the matrix has an
  eigenvalue of modulus 1. With `k = 1` a second eigenvalue lies outside the
  unit disc. The certificate refuses both at the PIP step, correctly.
- *Slope 3 with `r = q + 1` stays PIP.* Its second eigenvalue's modulus tends
  to 1 (0.86 at `q = 80`), which is the `p ≫ q` corner where Theorem L's §5
  predicts Puiseux expansions are needed.

On slope 3 with `r = q + 1`, the method fails rather than refuses:

- `k = 0` raises "a run-position bound is not affine in q at the samples";
- `k = 1` printed nothing within a 50-minute budget, which is an exhausted
  budget and not a verdict.

Both are limits of the one-parameter affine method, not counterexamples.

## 6. What this does not establish

- #84 itself. By Theorem SC it is PSC, and the lines above are finitely many
  one-parameter slices of class B. Class B is a two-parameter cone, and
  class B is itself one class of Theorem E.
- That the choice of seed can make any obstruction disappear. Theorem SC
  rules that out. The 444-specimen dependence only measures the object.
- Anything outside the stated lines and domains. The direction (5) ⇒ (3)
  inherits the review status of the October 4 chain.

## 7. Next

1. **`k` symbolic.** The vertex counts stabilise along each line. A
   two-parameter version of `psc.symbolic_line` (polynomials in `q` and `k`
   on the regime `p ≤ 2q + K`) would cover a whole wedge of class B at once.
   *Update 2026-10-08:* done, and further: Theorem C of
   [`p1b-symbolic-cone-2026-10-08.md`](p1b-symbolic-cone-2026-10-08.md)
   certifies class B below slope `5/2` by symbolic cones. An independent
   second engine agrees on the wedge `q < p < 2q`; see that note §4.
   **Follow-up (2026-10-08):** done, with `beta` bracketed rather than
   Sturm queries, as Theorem C of
   [`p1b-symbolic-cone-2026-10-08.md`](p1b-symbolic-cone-2026-10-08.md):
   class B below slope `5/2` on both branches, containing every line above.
   The `p ≫ q` corner does not occur (Lemma P1: `p < 3q + 12`); what stays open
   is the layer near slope 3.
2. **The `p ≫ q` corner** needs expansions in `sqrt(p)`, as Theorem L's §5
   already says.
3. **The self-overlap of Proposition SA** is a single-tiling object: `sigma^n(a)`
   against its own translate by `beta^n ell_b`. Its coincidence density is
   the quantity in the Lee–Moody–Solomyak criterion, at the one translation
   `ell_b`. A theorem that controls that one translation uniformly would be
   the first seed-specific mechanism. None is claimed here.
