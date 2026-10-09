# All-pairs strong coincidence beyond the corpus — 2026-10-04

**Status:** research note with an exact census; Lemma A is proved, the rest is
finite evidence. Changes no ledger node. PSC stays open.

## 1. Why this census

SC_all, productivity of the six aligned pairs `(i, j, 0)`, is necessary for
pure discrete spectrum (Akiyama–Lee 2014 Cor. 4.5,
`pds-strong-coincidence-literature-gate-2026-10-04.md`), and with BH it is
formal productivity (Proposition FP,
`formal-productivity-reduction-2026-10-04.md`). A PIP specimen failing SC_all
would refute PSC. Until now it was decided only on the standing corpus
(`kernel/coincidence_formula_census.mojo`), and §6 of the reduction note
recorded the gap.

`kernel/strong_coincidence_census.mojo` (pixi task
`strong-coincidence-census [total [N] | len4]`) decides each pair exactly with
`psc.coincidence_formula`, which is finite by the Pisot property, so a
negative is a verdict, not a budget. It also splits pairs by mechanism. A pair
is *merged* when the first-letter map `h(a) = sigma(a)[0]` satisfies
`h^n(i) = h^n(j)` for some `n` (then `n <= 2`, and the pair coincides at the
left end of `sigma^n`). Every other pair is *residual*, and the aligned route
(#138) concerns residual pairs only.

## 2. Census (exact, 4 workers)

| domain | specimens | SC_all fails | with a residual pair | residual pairs | catch-up-free (with residual) | wall-clock |
| --- | --- | --- | --- | --- | --- | --- |
| standing corpus | 4,554 | 0 | 2,658 | 6,360 | 210 (90) | 14 s |
| total length ≤ 8 | 24,486 | 0 | 14,154 | 33,816 | 654 (396) | 30 s |
| images of length ≤ 4 | 135,990 | 0 | 81,888 | 191,346 | 5,040 (2,202) | 192 s |
| total length ≤ 10 | 408,798 | 0 | 239,484 | 563,490 | 9,804 (6,108) | 650 s |

Residual pairs by coincidence level:

| domain | levels |
| --- | --- |
| standing corpus | `2:828 3:1956 4:1812 5:1200 6:384 7:132 8:18 12:6 13:6 14:12 15:6` |
| total length ≤ 8 | `1:210 2:4290 3:10866 4:9660 5:5154 6:2286 7:990 8:210 9:72 10:42 11:6 12:6 13:6 14:12 15:6` |
| images ≤ 4 | `1:9042 2:54876 3:74574 4:37830 5:11718 6:2430 7:678 8:102 9:42 10:24 12:6 13:6 14:12 15:6` |
| total length ≤ 10 | `1:10512 2:121284 3:215700 4:145686 5:52482 6:13596 7:3354 8:606 9:150 10:84 11:6 12:6 13:6 14:12 15:6` |

In the catch-up-free class the residual levels stay at most 7 on the first
three domains and at most 8 on total length ≤ 10. The deepest residual pair is
level 15 on every domain, on `0 -> 1, 1 -> 2, 2 -> 10`, and the tail at levels
12–15 has the same counts (30 pairs) on every domain: enlarging the domain
adds no deep pairs.

## 3. Lemma A: in the catch-up-free class the aligned route is a hitting statement

*Lemma A (proved).* Let `sigma` be catch-up-free with `|det M| = 2`. If the
aligned pair `(a, b, 0)`, `a != b`, has an offset-zero child other than its
leftmost child `(h(a), h(b), 0)`, then `h(a) = h(b)`.

*Proof.* An offset-zero child other than the leftmost one comes from nonempty
proper prefixes `p`, `q` of `sigma(a)`, `sigma(b)` with `ab(p) = ab(q)`. By
Lemma E (`p1b-vertex-coincidence-box-2026-10-02.md` §5.6e; Proposition C
there), every nonempty proper prefix of an image is an E letter followed by Z
letters, so it contains exactly one E letter, its first. Equal Parikh vectors
then force the same first letter: `h(a) = h(b)`. `square`

The census checks Lemma A directly on every aligned pair of every
catch-up-free `|det M| = 2` specimen: 630, 1,710, 2,700 and 6,246 pairs on the
four domains, with no violation. (`psc.coincidence_formula.balanced_proper_prefix_pairs`
counts the interior offset-zero children; `tests/test_coincidence_formula.mojo`
pins it.)

*Consequence.* On this class the offset-zero part of the aligned dynamics is
exactly the pair map `{i, j} -> {h(i), h(j)}`. A residual pair is never merged,
so its leftmost chain stays on residual aligned pairs forever, and it reaches a
coincidence only through a nonzero-offset descendant that returns to offset
zero. By Lemma P every such return is a simultaneous birth. So on the
catch-up-free `|det M| = 2` class SC_all is a boundary-hitting statement, of
the same kind as T2, about the nonzero-offset children of the residual aligned
pairs on `h`-cycles. These vertices need not be recurrent, so the statement is
not contained in T2 or BH. Proposition FP's split into SC_all and BH stays
genuine, but on this class both halves ask for the same mechanism. Outside the class
interior alignments occur: 192, 720, 26,706 and 28,302 residual pairs have one
on the four domains.

## 4. Finite-domain consequence: pure discrete spectrum

The recorded vertex-coincidence runs decide PPVC for every `r` on the
standing corpus, on total length ≤ 8 and on images ≤ 4
(`p1b-vertex-coincidence-box-2026-10-02.md` §4, no failure, none capped). For
a specimen with PPVC, Proposition V (2) gives an offset-zero descendant to
every box vertex, hence BH (reduction note §6). With SC_all from §2,
Proposition FP gives FP, so every overlap reachable from a swap seed is
productive, and manuscript Theorem `thm:main-density` (with the imported
Barge–Štimac–Williams theorem) gives pure discrete spectrum. Hence:

*Finite-domain statement.* Every PIP substitution on three letters with images
of length at most 4, or of total image length at most 8 (145,806 specimens;
the two domains share 14,670), has pure discrete spectrum. This rests on
Proposition V and Theorem B (unreviewed) and on recorded runs that CI does not
guard (the PPVC rows for the two larger domains and this census).

*Correction 2026-10-07:* the dependency on Proposition V(2) and Theorem B is
not needed. The census verdict, read as a statement about the box automaton,
gives BH through step 1 of Proposition V alone, and pure discrete spectrum
then also follows from Lee–Moody–Solomyak overlap coincidence
(`pds-certificate-from-the-box-automaton-2026-10-07.md`, Theorem Ω and §5).
The two larger rows are guarded by `.github/workflows/box-automaton-evidence.yml`.
*Update 2026-10-08:* the statement is recorded in the claim ledger as the
finite-domain theorem `BoundedPureDiscreteSpectrum`.

In particular the catch-up-free specimens without a Barge-class witness
(132 of 210 on the corpus, 480 of 654 at total length ≤ 8;
§5.6g of the vertex note) are settled one by one. What remains open for them
is a uniform argument, not any specimen.

## 5. What this does not establish

- SC_all for all PIP substitutions (the ternary strong coincidence
  conjecture), or any uniform bound on the residual level.
- PDS on total length ≤ 10: PPVC is not surveyed there.
- Anything about the 84 catch-up-free specimens of total length ≤ 8 (and the
  catch-up-free majority of images ≤ 4) with `|det M| != 2`: Lemma A uses
  Lemma E, which needs `|det M| = 2`.

## 6. Reproduction

```text
cd kernel
pixi run strong-coincidence-census            # standing corpus, 14 s
pixi run strong-coincidence-census total      # total length <= 8, 30 s
pixi run strong-coincidence-census len4       # images <= 4, 192 s
pixi run strong-coincidence-census total 10   # total length <= 10, 650 s
```
