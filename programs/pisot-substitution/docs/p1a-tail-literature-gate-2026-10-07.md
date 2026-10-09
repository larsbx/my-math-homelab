# Stop/go: a direct argument for Theorem K's tail cells — 2026-10-07

Targeted literature check (AGENTS.md review gate) before attempting a
human-readable argument for the members of Theorem K's family with `|Delta|`
large, which the certificate-guided cover
([`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md) §3k–§3l) has
not closed: the tail cells `s = +1, Delta >= 1` and `s = −1, Delta <= 0`.

## 1. The proposed claim

Every non-crossing PIP member of Theorem K's family
(`sigma(o) = y`, `sigma(y) = o w_1 o`, `sigma(z) = o w_2 o`, `|det M| = 2`)
with `|Delta|` beyond a threshold is coincident on `{o, y}`, by an argument
uniform in `Delta`: either a literature theorem whose hypotheses the family
meets, or a named path (as Lemmas Φ6–Φ8 do for the cell `(+1, 0)`).

## 2. Prior art

| Source | What it gives | Transfers? |
| --- | --- | --- |
| M. Barge, *Pure discrete spectrum for a class of one-dimensional substitution tiling systems*, [arXiv:1403.7826](https://arxiv.org/abs/1403.7826) (2014/15); *The Pisot conjecture for β-substitutions*, ETDS 38 (2018), [arXiv:1505.04408](https://arxiv.org/abs/1505.04408) | pure discrete spectrum for primitive non-periodic substitutions with Pisot inflation, **injective on initial letters and constant on final letters** (and the mirror class); powers and rotations preserve the spectrum (`psc/barge_class.mojo`) | **no** (§3): no power or rotation of a member is in either class |
| S. Akiyama, J.-Y. Lee, *Overlap coincidence to strong coincidence in substitution tiling dynamics*, [arXiv:1403.0377](https://arxiv.org/abs/1403.0377) (2014), Cor. 4.5 | pure discrete spectrum ⇒ all-pairs prefix strong coincidence (irreducible Pisot; non-unit step via Theorem R, side-notes ledger §3) | only downstream of a spectral theorem, which §3 rules out by Barge's route |
| M. Hollander, B. Solomyak, *Two-symbol Pisot substitutions have pure discrete spectrum*, ETDS 23 (2003) | termination of the balanced pair algorithm on two letters | **no**: three letters |
| T. Sellami, *Balanced pair algorithm for a class of cubic substitutions*, Turkish J. Math. 39 (2015), [journal page](https://journals.tubitak.gov.tr/math/vol39/iss1/9) | the balanced pair algorithm run **uniformly in a parameter** on the β-substitutions of `x^3 − a x^2 − b x − 1`, with a fixed finite set of minimal pairs for all `a` | **the method** (a finite certificate uniform in a parameter, as in Theorem H) transfers; the family does not |
| V. Berthé, J. Bourdon, T. Jolivet, A. Siegel, ETDS 36 (2016), [arXiv:1401.0704](https://arxiv.org/abs/1401.0704) | finite certificates for infinite families of Pisot products | as before (swap-family gate): the idea, not the theorem |

## 3. Hypotheses that transfer, and those that do not

**Lemma (no Barge witness).** No power `sigma^n` of a member, nor any
rotation of one, is injective on initial letters and constant on final
letters, or the mirror. Status: repository-proved, unreviewed. *Proof.* `sigma(o) = y`, while `sigma(y)` and
`sigma(z)` begin and end with `o`. By induction the initial letters of
`sigma^n(o), sigma^n(y), sigma^n(z)` are `(y, o, o)` for `n` odd and
`(o, y, y)` for `n` even, and the same holds for the final letters. So the
images of `y` and `z` always share their first and last letters (never
injective), the image of `o` differs from them (never constant), and the
three images share no first or last letter, so the maximal common prefix
and suffix are empty and no rotation exists. `square` (Checked by
`barge_witness(sigma, 6)` on four members: none.)

**What the family does give** (Lemma P1, §3h of the note): for `s = +1`,
`f(1) = (Z_2 − 1)(Delta − 1) − 2 Y_2 − 4 < 0`, and this is the whole Pisot
condition (exact `pisot` on `Y_2, Z_2 < 30`, `Delta < 30`: 5,680 of 5,680).
Hence:
- `Z_2 <= 1`: `Delta` is unbounded with the words bounded. With `u` from
  Lemma Φ5 these are two explicit families: `w_2 = y^p`, `w_1 = z y^(p + Delta)`;
  and `w_2 = y^a z y^b`, `w_1 = z y^c z y^(d + Delta)` with `c + d = a + b`.
- `Z_2 >= 2`: `Delta − 1 <= (2 Y_2 + 3) / (Z_2 − 1)`, so `Delta` grows only
  with the `y`-content of `w_2`. For `s = −1`, Lemma Φ4 forces `Z_2 >= 2`
  and the same holds with `Y_1`: no family of bounded words has unbounded
  `|Delta|`.

## 4. Negative controls

- Barge's class: the lemma above.
- A single named path for all large `Delta`: refuted by the census of
  distinct members (side-notes ledger 2026-10-06): 37 members, 15 shapes at
  `s = +1, Delta = 8`; the frequent "dominant" shape of a sampled census is
  the single family `w_2 = z`.

## 5. Decision

**Stop** the literature route (Barge's theorem does not apply, by the
lemma). **Proceed, narrowed:** (a) the `s = +1`, `Z_2 <= 1` families by a
parametric certificate uniform in `Delta` and the run lengths (Sellami's and
Theorem H's method), the only part of the tail with unbounded `Delta` over
bounded words; (b) the regime where `|Delta|` grows with the `y`-content
remains the certificate-guided cover's, whose open regions need
certificates valid on non-PIP points as well (the Pisot boundary is not
polyhedral). No claim beyond what the exact cover or a written proof
establishes.
