# Stop/go: strong coincidence on the swap family, by parametric witness paths — 2026-10-06

Targeted literature check (AGENTS.md review gate) before writing proof code
for the one family that
[`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md) §3c leaves open.

## 1. The proposed claim and experiment

*Claim.* Every PIP substitution with `|det M| = 2` of the **swap family**

    sigma(x) = c y^p s_x,   sigma(c) = x y^q s_c,   sigma(y) = t y^r s_y

(`p, q, r >= 0`, endings in `{x, c}`) has the pair `{x, c}` eventually
coincident. With Theorem G of that note this would give the strong coincidence
condition for every pair on the whole catch-up-free `|det M| = 2` class with
two odd letters.

*Experiment.* Replace Theorem E's hand-checked witness lemmas by **parametric
witness paths**: a cone of parameters `(p, q, r) = b + sum_k n_k g_k`
(`n_k >= 0`) together with a path in the prefix/coincidence graph from
`(x, c, 0)` to a state `(a, a, 0)`, whose positions and Parikh offsets are
polynomials in the `n_k`. Every validity condition of the path — a position
lies in a given `y`-run, an offset vector is what the path says — is then a
polynomial identity or a polynomial inequality on `Z_{>=0}^m`, which is checked
exactly by coefficient signs. One such check proves the witness for the whole
cone at once. The certificate is the list of cones and paths; the residue is
finite and decided by `coincidence_level`, as in Theorem E.

## 2. Prior art and terminology

| Source | What it gives | Transfers? |
| --- | --- | --- |
| V. Berthé, J. Bourdon, T. Jolivet, A. Siegel, *A combinatorial approach to products of Pisot substitutions*, ETDS 36 (2016), 1757–1794, [arXiv:1401.0704](https://arxiv.org/abs/1401.0704) | the **closest construction**: a generic algorithmic framework proving coincidence conditions and pure discrete spectrum for *infinite* families — arbitrary finite products of the Brun and Jacobi–Perron substitutions on three letters — by discrete-plane generation with dual substitutions | the idea that a finite certificate can cover an infinite family transfers; the machinery does not: their families are products of a fixed generating set and unimodular, ours have parametric exponents and `|det M| = 2` |
| M. Barge, *The Pisot conjecture for beta-substitutions*, ETDS 38 (2018), 2009–2034, [arXiv:1505.04408](https://arxiv.org/abs/1505.04408) | the **strongest theorem on a parametric-exponent family**, non-unimodular members included: pure discrete spectrum, hence strong coincidence, for every Pisot beta-substitution | the normal form `i -> 1^{a_i}(i+1)` is not ours; no swap-family member was found to be one (§3b of the A1′ note already records this for Theorem E) |
| S. Akiyama, F. Gähler, J.-Y. Lee, three-letter Pisot conjecture for incidence trace at most 2 (as recorded in [`p1a-template-collapse-2026-10-05.md`](p1a-template-collapse-2026-10-05.md) §4) | settles the low-trace range | the swap family has trace `r + [s_x = x] + [s_c = c]`, so only its `r <= 2` slices can be in range; whether their members fall inside that search was **not checked**, and nothing here relies on it |
| M. Barge, B. Diamond, *Coincidence for substitutions of Pisot type*, Bull. SMF 130 (2002), 619–626 | **one** strongly coincident pair for every Pisot substitution | used in §3c's 3-cycle row; cannot be aimed at `{x, c}` (A1′ note §4) |
| S. Akiyama, *Strong coincidence and overlap coincidence*, [arXiv:1509.04471](https://arxiv.org/abs/1509.04471) | strong coincidence for *many choices of control points* is equivalent to overlap coincidence | **negative control on the payoff**: the ordinary strong coincidence condition, which is what the claim gives, is the weaker statement and does not by itself give pure discrete spectrum |

Terminology: the field's *strong coincidence condition* (Arnoux–Ito) is the
repository's all-pairs SC; a *coincidence* for a pair is the repository's
eventual coincidence (shared tile at equal Parikh prefix).

## 3. Hypotheses that transfer, and those that do not

- **Transfers:** Pisot type (PIP members only), which is all Barge–Diamond
  and the exact `coincidence_level` need; the parametric exponents, which make
  positions and Parikh vectors polynomial in the parameters, as in Theorem E.
- **Does not transfer:** unimodularity (BBJS, dual-substitution geometry),
  the beta-substitution normal form (Barge), and low trace (AGL).

## 4. Known negative controls

- *Reversal does not preserve coincidence.* Swap ending `(x, c, x, x)` is
  Theorem E's class D reversed: same incidence matrices, different levels. A
  proof that transported Theorem E by reversal would be wrong.
- *Level-2 and level-3 lemmas do not suffice.* The sweep has infinite lines at
  level 4 (`(n + 1, 0, n)` in ending `(x, x, x, c)`), so a certificate limited
  to Theorem E's lemma depths would leave an infinite residue.
- *Strong coincidence is not PDS* (Akiyama, above), so no claim about spectrum
  may be drawn from the result.

## 5. Decision

**Proceed, narrowed.** No source found proves strong coincidence for this
family or for any non-unimodular family with parametric exponents of this
shape, and the closest generic framework (BBJS) does not apply to it. The
novelty claimed is limited to (i) the theorem on this explicit class and (ii)
the parametric witness-path certificate as the means of checking it. The
idea of a finite certificate for an infinite family is BBJS's, and is cited as
such. If the certificate cannot cover a region, the region stays in the
residue or stays open; nothing is promoted on the strength of the sweep.

## 6. Addendum, same day: Theorem K's open family

*Proposed.* Strong coincidence for `{o, y}` on `sigma(o) = y`,
`sigma(y) = o w_1 o`, `sigma(z) = o w_2 o` (A1′ note §3f), first by explicit
witness lemmas and then by the same parametric witness paths, extended to
runs of any letter and to opaque word tails.

*Prior art.* The sources of §2 apply unchanged: none treats a family whose
images carry arbitrary words; BBJS's products are a different, unimodular
setting, and Barge's beta-substitutions have `sigma(1) = 1^{a_1} 2`-type
images, not `o w o`. No further source was found that settles this family.

*Decision.* **Proceed, narrowed** to the two lemmas the witness structure
suggests (Φ1, and the crossing Lemma Φ2) and an exact census of the rest.
The letter-by-letter pattern tree was tried and recorded as not converging
(A1′ note §3f); it is kept as an instrument, not cited as a cover.

*Same day, the delta split (A1′ note §3g).* Lemmas Φ4–Φ8 and Theorem Φ refine
the same target with the same tools; no new prior art was found or needed.
The decision stands: proceed, narrowed.

*Same day, run-shape cover (A1′ note §3h).* Same target and tools, plus a line
mode of the witness search; no new prior art. Decision unchanged.

*Same day, induction on runs (A1′ note §3i).* Same target; the run patterns
add opaque tails, which the opaque segments of §3f already support. No new
prior art. Decision unchanged. Redirect recorded for the next step: the
residue is mostly single excursions, so the next experiment is a witness
argument inside an excursion, and a further literature check is due before
it if it brings in non-intersecting lattice-path machinery.
