# The programme in context: three-letter PSC, proved and open — 2026-10-07

**Status:** orientation and comparison note. Section 2 is pinned by an exact
Mojo regression; everything else is citation. It promotes nothing, moves no
ledger node, and adds no hypothesis. PSC stays open.

## 1. Where the conjecture stands outside this repository

Write `d` for the alphabet size and PIP for primitive, irreducible, Pisot.

| Scope | Status | Source |
| --- | --- | --- |
| `d = 2`, every PIP substitution | **proved** | Barge–Diamond 2002 (strong coincidence) + Hollander–Solomyak 2003 (coincidence ⇒ PDS) |
| `d = 3`, every PIP substitution | **open**, unimodular case included | ABBLS 2015 survey |
| `d ≥ 3`, β-substitutions | proved | Barge 2018 |
| `d ≥ 3`, substitutive Arnoux–Rauzy | proved | Berthé–Jolivet–Siegel 2012 |
| `d = 3`, S-adic Arnoux–Rauzy, a.e. directive sequence | proved | Avila–Hubert–Skripchenko 2016 (Pisot Lyapunov condition) + Berthé–Steiner–Thuswaldner 2019 |
| one given substitution | decidable when PDS holds; semi-decision only, since a failing run need not stop | balanced pairs (Sirvent–Solomyak 2002; ABBLS Thm 5.3), Rauzy-fractal coincidence (Siegel–Thuswaldner 2009), Akiyama–Lee 2011 |
| ternary strong coincidence, all pairs | **open** for `d ≥ 3` | Arnoux–Ito 2001 framework; ABBLS 2015 |

Two features of the literature fix where this programme can add anything.
The class theorems for `d ≥ 3` are structural families (β-numeration,
Arnoux–Rauzy), not size classes. Most of the geometric machinery is
unimodular. This repository works with all PIP substitutions and never assumes
unimodularity (README, *Generality firewall*). Everything else is specimen-by-specimen
verification.

## 2. The circulated ternary examples, replayed

`B_sigma` is this repository's all-seed balanced-pair automaton: seeds
`(ab, ba)`, pairs identified up to side swap, coincidences terminal
(`bpa-literature-bridge.md` §2). "TwC" means `B_sigma` is finite and every
state reaches a coincidence. With ABBLS Theorem 5.3 (imported), TwC gives PDS
for that specimen. Letters are written `1..3` here and `0..2` in the test.

| σ | χ_M | det | PIP | in §3 domain | states / noncoinc. / longest | TwC | Prior proof |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `12, 223, 11` | x³−3x²+2x−2 | 2 | yes | yes | 562 / 560 / 1676 | yes | Sirvent–Solomyak 2002 |
| `1111112223, 2231111, 311122` | x³−9x²+3x+1 | −1 | yes | no (total 23) | 259 / 257 / 137 | yes | Sirvent–Solomyak 2002 |
| `12, 31, 1` | x³−x²−x−1 | 1 | yes | yes | 11 / 10 / 8 | yes | circulated list |
| `12, 23, 312` | x³−3x²+2x−1 | 1 | yes | yes | 33 / 30 / 16 | yes | circulated list |
| `123, 1, 31` | x³−2x²−x+1 | −1 | yes | yes | 9 / 7 / 5 | yes | circulated list |
| `123, 1, 1132` | x(x²−2x−2) | **0** | **no** | — | — | — | not a PSC instance |
| Tribonacci `12, 13, 1` | x³−x²−x−1 | 1 | yes | yes | 6 / 5 / 4 | yes | Rauzy 1982 |
| Kol(3,1) `123, 12, 2` | x³−2x²−1 | 1 | yes | yes | 7 / 5 / 3 | yes | Baake–Sing 2004 |
| Arnoux–Rauzy `σ₁σ₂σ₃` = `1213121, 213121, 3121` | x³−7x²+5x−1 | 1 | yes | no | 8 / 5 / 4 | yes | Berthé–Jolivet–Siegel 2012 |

Pinned by `kernel/tests/test_ternary_literature_specimens.mojo` and
reproduced independently by `reference/psc_research/bpa.py`.

**Corrections to the circulated list.**

- `123, 1, 1132` has two equal rows in `M`, so `det M = 0` and `χ_M` is
  reducible. It was circulated as a unimodular example. It is neither
  unimodular nor irreducible.
- Sirvent–Solomyak report 559 pairs of maximal length 1673 and 260 pairs of
  maximal length 194 for the first two rows. Their algorithm seeds from
  prefixes of the fixed point, not from `(ab, ba)`, so counts differ by
  construction. The first row agrees up to that: the three single-seed
  closures here have 551, 557 and 554 noncoincident states. The second row's
  gap, 137 against 194, is larger than a seed change obviously explains. It
  is unconfirmed until checked against the paper's full text.
- The single Arnoux–Rauzy maps `σᵢ` are not primitive and are not PSC
  instances; only directive sequences using all three are.

The numbers that do check: `|λ₂| = |λ₃| ≈ 0.891` for `12, 223, 11`, and
`β ≈ 2.2056`, `λ₂,₃ ≈ −0.103 ± 0.665i` for Kol(3,1).

**Consequence.** No listed specimen is new. Six lie in the finite domain of
§3; the other two terminate with coincidence directly.

## 3. Where this programme sits

| This repository | Literature counterpart | Relation |
| --- | --- | --- |
| PDS for all 145,806 ternary PIP substitutions with images of length ≤ 4 or total length ≤ 8 (`strong-coincidence-census-2026-10-04.md` §4) | specimen-by-specimen verifications | an exhaustive size class rather than a family. The statement rests on Proposition V and Theorem B (unreviewed) and on recorded PPVC runs that CI does not guard. |
| SC_all exact on total length ≤ 10: 408,798 specimens, 0 failures | ternary strong coincidence conjecture, open | finite evidence; no counterexample in range |
| finite `B_sigma` on total length ≤ 8 via the overlap sweep and Proposition 1 (`bpa-termination-by-overlap-depth-2026-10-02.md` §4) | BPA termination, decided one specimen at a time | covers the 120 specimens whose direct builds exhaust the state budget (length bound of order 10¹⁰), where a direct BPA run is impractical |
| PDS ⇒ G1, and PDS ⇒ TwC from every seed (`prop:PDS-implies-G1`, `thm:seedwise`) | ABBLS Thm 5.3's "one seed suffices" | repository-proved, independently audited, human review pending; settles the every-seed reading |
| one open premise on the shortest PDS route (seedwise overlap productivity, Open Problem 5.35, #84) | none: general `d = 3` is open | the target |

This note knows of no published exhaustive census of comparable size, but the
literature has not been surveyed systematically for one. Check before making
any novelty claim.

**What the programme is for, in this light.** For `d ≥ 3` the literature has
two kinds of result: theorems for structured families and verifications of
single specimens. This programme sits between them. It proves statements
over exhaustive size classes, and it reduces the general case to one finite,
checkable premise. Only the second could ever reach a general theorem. The
first is how a counterexample would be found if one exists: a PIP specimen
failing SC_all or G1 refutes PSC (`strong-coincidence-census-2026-10-04.md`
§1, `prop:PDS-implies-G1`).

## 4. What this note does not establish

- PDS, G1 or SC_all beyond their stated finite domains.
- Any upgrade of the §3 finite-domain PDS statement: its dependencies on
  Proposition V and Theorem B are unchanged.
- The Sirvent–Solomyak counts: the comparison above uses this repository's
  seed convention throughout.

## 5. Sources

Rows marked † are cited from the literature and the ABBLS survey; they were
not re-read against full text for this note.

- S. Akiyama, M. Barge, V. Berthé, J.-Y. Lee, A. Siegel, *On the Pisot
  substitution conjecture*, in *Mathematics of Aperiodic Order* (2015).
- S. Akiyama, J.-Y. Lee, *Algorithm for determining pure pointedness of
  self-affine tilings*, Adv. Math. 226 (2011). †
- P. Arnoux, S. Ito, *Pisot substitutions and Rauzy fractals*, Bull. Belg.
  Math. Soc. 8 (2001).
- A. Avila, P. Hubert, A. Skripchenko, *Diffusion for chaotic plane sections
  of 3-periodic surfaces*, Invent. Math. 206 (2016). †
- M. Baake, B. Sing, *Kolakoski-(3,1) is a (deformed) model set*, Canad.
  Math. Bull. 47 (2004). †
- M. Barge, *The Pisot conjecture for β-substitutions*, Ergodic Theory
  Dynam. Systems 38 (2018). †
- M. Barge, B. Diamond, *Coincidence for substitutions of Pisot type*, Bull.
  Soc. Math. France 130 (2002).
- V. Berthé, T. Jolivet, A. Siegel, *Substitutive Arnoux–Rauzy sequences have
  pure discrete spectrum*, Unif. Distrib. Theory 7 (2012). †
- V. Berthé, W. Steiner, J. M. Thuswaldner, *Geometry, dynamics, and
  arithmetic of S-adic shifts*, Ann. Inst. Fourier 69 (2019). †
- M. Hollander, B. Solomyak, *Two-symbol Pisot substitutions have pure
  discrete spectrum*, Ergodic Theory Dynam. Systems 23 (2003).
- G. Rauzy, *Nombres algébriques et substitutions*, Bull. Soc. Math. France
  110 (1982).
- A. Siegel, J. M. Thuswaldner, *Topological properties of Rauzy fractals*,
  Mém. Soc. Math. Fr. 118 (2009). †
- V. F. Sirvent, B. Solomyak, *Pure discrete spectrum for one-dimensional
  substitution systems of Pisot type*, Canad. Math. Bull. 45 (2002).

## 6. Reproduction

```text
cd kernel
pixi run mojo run -I . -I tests tests/test_ternary_literature_specimens.mojo
```
