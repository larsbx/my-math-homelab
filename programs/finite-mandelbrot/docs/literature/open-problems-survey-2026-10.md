<!--
Provenance: external research survey, supplied by the repository owner on
2026-10-05 and stored verbatim below this comment. It is literature input, not
a repository claim: nothing here is a theorem tag, a gated import, or a status
change for any C1 block. Bracketed source labels ([arxiv], [github], ...) are
the survey's own; items it marks "announced", "manuscript" or "not inspected"
stay unverified until a literature gate checks them.

Terminology declaration: external open-problems survey (verbatim)
Genealogy: classical complex-dynamics and arithmetic-dynamics literature as
summarised by the survey's author; no repository term is introduced.
Bridge claim: none. Equivalences stated below (MLC, fiber triviality,
combinatorial rigidity, DH, NILF) are classical statements reported by the
survey, not finite-to-classical bridges of this repository.
Known leaks: the survey cites secondary sources and unpublished manuscripts;
its "equivalent" and "same as" phrasings carry its own citations, not ours.
Use discipline: cite a statement from this file only through a literature gate
or a theorem tag in docs/C1_theorem_tag_import_ledger.md, never directly.

Repository assessment against this survey:
docs/survey-assessment-2026-10-05.md
-->

# Open Problems and Conjectures on the Mandelbrot Set: A Research-Level Survey (status as of October 2026)

MLC, the conjecture that M is locally connected, is still open in October 2026. [arxiv](https://arxiv.org/pdf/2606.27272) [arxiv](https://arxiv.org/pdf/2512.24171) The gap is now much narrower than it was: in 2023–2026, a priori bounds and MLC were proved for every infinitely renormalizable parameter of bounded quadratic-like type, including the classical Feigenbaum point. On the authors' own account, the remaining work reduces to two named problems: the unbounded satellite case, and an "interpolation" problem near the main molecule. [arxiv](https://arxiv.org/pdf/2512.24171) Density of hyperbolicity in the complex quadratic family is open; so are positive area of ∂M and the exact value of area(M). On the arithmetic side, irreducibility of Gleason/Misiurewicz polynomials over ℚ and Poonen's conjecture are open; the dynamical André–Oort conjecture has been proved for curves (Ji–Xie, 2023). [baidu](https://baike.baidu.com/en/item/Andr%C3%A9%E2%80%93Oort%20conjecture/5113091)

## TL;DR

- **MLC is still open, but the problem has narrowed.** It is known at all non-infinitely-renormalizable parameters (Yoccoz). For infinitely renormalizable parameters it is known in the following cases:
  - all bounded-type parameters, primitive and satellite (Kahn; Kahn–Lyubich; Dudko–Lyubich, "MLC at Feigenbaum points", arXiv:2309.02107, accepted to Publ. IHÉS);
  - anti-molecule combinatorics (Kahn–Lyubich);
  - classes of high-type and near-parabolic combinatorics (Lyubich; Cheraghi–Shishikura; Dudko–Lyubich; Kahn–Kapiamba–Lyubich, arXiv:2606.27272, 2026).
  
  By the authors' own accounting, two problems remain open: pseudo-Siegel bounds for unbounded satellite types, and a "virtual molecule" near-degenerate theory.
- **The conjectures are linked by known implications.** MLC ⇔ combinatorial rigidity ⇔ triviality of fibers ⇒ density of hyperbolicity ⇔ no queer components ⇔ no invariant line fields (NILF) on quadratic Julia sets; and density of hyperbolicity ⇒ computability of M (Hertling 2005). [researchgate](https://www.researchgate.net/publication/220082902_Is_the_Mandelbrot_set_computable) Density of hyperbolicity is a theorem on ℝ (Lyubich; Graczyk–Świątek) and open on ℂ.
  - dim_H ∂M = 2 (Shishikura).
  - Whether area(∂M) > 0 is open. Dudko's 2025 survey says "The area of ∂M is expected to be 0", and adds that this likely requires hyperbolicity of Molecule renormalization.
  - The best rigorous interval is Fisher–Hill's 1.50296686 < area(M) < 1.57012937, obtained by quadtree plus Koebe ¼ "up to double precision" and quoted in G. Irving's GitHub README. Pixel counting gives Förstemann's 1.5065918849 ± 0.0000000028; H. Lo's independent October 2025 update gives 1.5065918902(54) from 30.4 trillion points.
- **For an independent researcher, the arithmetic and quantitative questions are the most accessible:**
  - limb sizes O(1/q²): Milnor's conjecture, known only for 1/q-limbs (Kapiamba); [arxiv](https://arxiv.org/pdf/2401.00795)
  - irreducibility of Gleason and Misiurewicz polynomials (known for d=2, n ≤ 3 in the Misiurewicz setting; Gleason G_n false in general for some degrees D); [nsf](https://par.nsf.gov/servlets/purl/10520447)
  - rigorous certified area bounds;
  - core-entropy questions;
  - Poonen's conjecture at period ≥ 6. [arxiv](https://arxiv.org/pdf/1903.08865)

## Executive overview and dependency diagram

Notation:
- p_c(z) = z² + c, M = {c : (p_cⁿ(0)) bounded}, M_d the Multibrot set of z^d + c.
- "IR" = infinitely (quadratic-like) renormalizable.
- "DH" = density of hyperbolicity in the quadratic family.
- "NILF" = no invariant line fields on J_c for c ∈ M.

```
                     Conj. 1.2 (Dudko): every closed hyperbolic component H̄ is a uniform qc disk/cardioid,
                                        diam H ≍ diam M_H
                                               │  (area finiteness + Yoccoz)
                                               ▼
 Uniform a priori bounds (all c ∈ ∂M) ──⇒  MLC  ⇔  combinatorial rigidity  ⇔  triviality of fibers (Schleicher)
         (Dudko Conj. 1.3)                    │      ⇔  M ≅ Thurston pinched disk  D̄/QML
                                              │      ⇒  all parameter rays land (irrational too); M arcwise connected
                                              ▼
                     DH  ⇔  no queer components  ⇔  NILF on J_c for c ∈ M     (Mañé–Sad–Sullivan; McMullen)
                       │         ⇔ topological/qc rigidity (Benini's survey formulations)
                       ▼
           M (and ∂M) computable (Hertling 2005)

 Hyperbolicity of Molecule renormalization (Dudko Conj. 3.6) ⇒ (expected) Conj. 1.2 satellite cases and area(∂M) = 0
 Real slice:  DH on ℝ  — THEOREM (Lyubich 1997; Graczyk–Świątek 1997); real polynomials: Kozlovski–Shen–van Strien 2007
 Arithmetic:  G_n irreducible/ℚ  ⇒  Per_n(0) irreducible/ℂ   (Ramadas, arXiv:2205.07349)
              Poonen's conj. (no rational period ≥ 4) ⇒ ≤ 9 rational preperiodic points, 12 portraits (Poonen 1998)
```

The mechanism behind the main arrows:
- **Yoccoz's reduction.** MLC holds at c iff for every nested sequence of small copies M₁ ⊋ M₂ ⊋ ⋯ containing c, the intersection ⋂ M_n is {c}. [arxiv](https://arxiv.org/pdf/2401.00795) [arxiv](https://arxiv.org/pdf/2512.24171)
- **Conjecture 1.2 ⇒ MLC.** If closed hyperbolic components have uniform geometry, then Σ diam(M_{H_n})² ≍ Σ area(H_n) < ∞. So nested copies shrink, and the singleton property follows. This is Dudko's 2025 formulation, stated explicitly in his survey. [arxiv](https://arxiv.org/pdf/2512.24171)
- **MLC ⇒ DH.** This is Douady–Hubbard. A queer component would produce a nontrivial fiber, contradicting the triviality of fibers.

## Catalogue

Each entry gives: (i) statement, (ii) origin, (iii) status, (iv) partial results, (v) relations, (vi) techniques and obstructions, (vii) recent progress.

### 1. Topology and geometry of M

**1.1 MLC.**
- (i) M is locally connected. [arxiv](https://arxiv.org/html/2512.24171) Equivalently, the Riemann map Φ_M⁻¹ : ℂ̂∖D̄ → ℂ̂∖M extends continuously to the circle.
- (ii) Douady–Hubbard, Orsay notes 1984–85. [arxiv +2](https://arxiv.org/html/2512.24171)
- (iii) Open.
- (iv) The precise known list of parameters c ∈ ∂M where M is locally connected:
  - (a) c not IR, i.e. at most finitely renormalizable, including all parabolic and Misiurewicz parameters. This is Yoccoz, via puzzles and parapuzzles (Hubbard 1993; Milnor 2000). [arxiv](https://ar5iv.labs.arxiv.org/html/1709.09869) [arxiv](https://arxiv.org/pdf/2606.27272)
  - (b) IR c with a priori bounds plus Lyubich's "secondary limbs condition" (Lyubich, Acta Math. 178, 1997). This covers high-type primitive combinatorics. [arxiv](https://arxiv.org/pdf/2606.27272)
  - (c) Bounded primitive combinatorics (Kahn, arXiv:math/0609045). [arxiv](https://arxiv.org/pdf/2606.27272)
  - (d) Combinatorics "ε-away from the main molecule", with decorations and molecules (Kahn–Lyubich, Ann. ENS 41, 2008; Kahn–Lyubich in *Complex Dynamics: Families and Friends*, 2009). Their machinery is the Quasi-Additivity Law and the Covering Lemma (Ann. Math. 169, 2009). [arxiv](https://arxiv.org/pdf/2606.27272) [arxiv](https://arxiv.org/pdf/2512.24171)
  - (e) Some satellite combinatorics of high type, via near-parabolic renormalization (Cheraghi–Shishikura, "Satellite renormalization of quadratic polynomials", arXiv:1509.07843). [Wikipedia](https://en.wikipedia.org/wiki/Mitsuhiro_Shishikura) [arxiv](https://arxiv.org/pdf/2606.27272)
  - (f) Certain bounded satellite parameters near the main cardioid, via pacman renormalization (Dudko–Lyubich, GAFA 33, 2023, pp. 912–1047). [springer](https://link.springer.com/content/pdf/10.1007/s00039-023-00637-8.pdf) [stonybrook](https://researchconnect.stonybrook.edu/en/publications/local-connectivity-of-the-mandelbrot-set-at-some-satellite-parame/) This gave the first examples of locally connected satellite bounded type, with locally connected J_c of positive area. [springer](https://link.springer.com/article/10.1007/s00039-023-00637-8) [arxiv](https://arxiv.org/abs/1808.10425)
  - (g) All IR parameters of bounded type, primitive or satellite, including the period-doubling Feigenbaum point and the complex tripling cases conjectured by Goldberg–Khanin–Sinai (Dudko–Lyubich, "MLC at Feigenbaum points", arXiv:2309.02107, v3 Dec 2025, accepted to Publ. Math. IHÉS). [arxiv](https://arxiv.org/abs/2309.02107) [arxiv](https://arxiv.org/pdf/2512.24171)
  - (h) Parabolically bounded families of prime primitive types, i.e. finite unions of types and "parabolic tails" accumulating on the cusp of limbs M_{1/q}. These are the first quadratic-like a priori bounds outside the secondary limbs condition (Kahn–Kapiamba–Lyubich, arXiv:2606.27272, 2026). [arxiv](https://arxiv.org/pdf/2606.27272)
  - (i) Dudko–Kahn–Lyubich, "Local connectivity of the Mandelbrot set along the real line": MLC along ℝ and along every vein. [arxiv](https://arxiv.org/html/2512.24171) [arxiv](https://arxiv.org/pdf/2512.24171) **Dudko's survey lists it as ref. [14], "Manuscript, 2022", and states that the combination of arguments "yields the MLC along a real line and along any vein of the Mandelbrot set". It is still not a public preprint, so treat it as announced, not verified.**
  - (j) Levin's results for some satellite IR parameters with fast-growing rotation numbers (limsup k_m⁻¹ log|p_m| > 0). [researchgate](https://www.researchgate.net/publication/225361541_On_the_complement_of_the_Mandelbrot_set)
- **What remains unknown.** IR parameters with unbounded satellite combinatorics outside these special classes, and primitive combinatorics accumulating on the main molecule ("virtually satellite": l(𝒞) = ∞; near-neutral: d(𝒞) = ∞; general near-parabolic: h(𝒞) = ∞), in the Kahn–Kapiamba–Lyubich classification. [arxiv](https://arxiv.org/pdf/2606.27272)
- (v) See the diagram above.
- (vi) Techniques and obstructions:
  - Techniques: puzzles and the Grötzsch inequality; the near-degenerate regime (Kahn's "Bad Now, Worse Earlier", extremal-width amplification driven by positive core entropy); waves and the Wave Lemma; pseudo-Siegel disks. [arxiv](https://arxiv.org/pdf/2606.27272) [arxiv](https://arxiv.org/pdf/2512.24171)
  - Obstruction: in zero entropy (the molecule), invariant degenerations can exist in parabolic fjords. Primitive copies near the molecule see entropy blow-up on intermediate scales. [arxiv](https://arxiv.org/pdf/2512.24171)
- (vii) Dudko's survey (arXiv:2512.24171) reduces full MLC to Problem 4.3, "establish pseudo-Siegel a priori bounds in the remaining unbounded satellite ql cases", and Interpolation Problem 4.4, "develop a Virtual Molecule version of the Near-Degenerate Regime". He writes that 4.3 and 4.4, combined with the existing arguments, "should imply the full MLC". [arxiv](https://arxiv.org/pdf/2512.24171) This is a program, not a theorem.

**1.2 Density of hyperbolicity (Fatou conjecture for p_c).**
- (i) Int M = ⋃ hyperbolic components.
- (ii) Fatou, 1920s (general rational maps); in this form, Douady–Hubbard.
- (iii) Real case: theorem (Lyubich, Acta 1997; Graczyk–Świątek, Ann. Math. 146, 1997). Real polynomials of any degree and real-analytic one-dimensional maps: Kozlovski–Shen–van Strien (Ann. Math. 165–166, 2007). [arxiv](https://arxiv.org/pdf/2512.24171) Complex case: open.
- (iv) Hyperbolicity is dense in every region where MLC is known. In particular, every queer component must consist of IR parameters of the unknown types listed under 1.1.
- (v) MLC ⇒ DH. DH ⇔ no queer components ⇔ NILF.
- (vi) Real a priori bounds are unavailable in ℂ. The near-degenerate regime is the substitute. [arxiv](https://arxiv.org/pdf/2512.24171)
- (vii) No direct new proof; progress comes through 1.1.

**1.3 No invariant line fields and queer components.**
- (i) For c ∈ M, J_c carries no measurable p_c-invariant line field on a set of positive area.
- (ii) Mañé–Sad–Sullivan 1983 and McMullen (*Complex Dynamics and Renormalization*, 1994), who proved the equivalence with DH.
- (iii) Open.
- (iv) McMullen: NILF holds for IR maps with a priori bounds and certain combinatorics. Kahn–Kapiamba–Lyubich note that their beau bounds already give NILF for parabolically bounded types. [arxiv](https://arxiv.org/pdf/2606.27272) Julia sets of positive area exist: Buff–Chéritat (Ann. Math. 176, 2012), Cremer/Siegel/IR type; Avila–Lyubich, Feigenbaum type; [arxiv](https://arxiv.org/pdf/2608.24316) [arxiv](https://arxiv.org/abs/1504.02986) Dudko–Lyubich, satellite bounded-type examples. [arxiv](https://arxiv.org/pdf/2512.24171) Benini's survey notes that no invariant line field has been constructed on any quadratic J_c. [arxiv](https://ar5iv.labs.arxiv.org/html/1709.09869)
- (v)–(vi) Positive-area J_c is necessary for a counterexample but not sufficient.

**1.4 Combinatorial rigidity, Thurston's QML, landing of parameter rays.**
- (i) Two maps p_c, p_{c'} with the same rational lamination (same rational rays landing together) and non-hyperbolic dynamics satisfy c = c'. Equivalently, M is homeomorphic to Thurston's pinched-disk model D̄/QML.
- (ii) Douady–Hubbard; Thurston (QML, 1980s preprint, published 2009).
- (iii) Open; equivalent to MLC.
- (iv) Rigidity holds in all MLC cases above. For unicritical maps, Avila–Kahn–Lyubich–Shen (Ann. Math. 170, 2009) proved combinatorial rigidity of finitely renormalizable unicritical polynomials, [arxiv](https://arxiv.org/pdf/2512.24171) so MLC holds at such parameters in M_d. [arxiv](https://arxiv.org/pdf/2512.24171)
- **Ray landing.** All rational parameter rays land (Douady–Hubbard; Schleicher, Astérisque 261, 2000). [arxiv](https://arxiv.org/pdf/1404.7193) Landing of all irrational parameter rays is equivalent in strength to MLC (a Carathéodory consequence) and is open.

**1.5 Area of ∂M and of M.**
- (i) Is area(∂M) = 0? What is area(M)?
- (iii) Both open. Dudko's survey: "The area of ∂M is expected to be 0", and this likely requires hyperbolicity of Molecule renormalization (Conj. 3.6). [arxiv](https://arxiv.org/pdf/2512.24171)
- (iv) dim_H ∂M = 2 (Shishikura, Ann. Math. 147, 1998, via near-parabolic implosion). [arxiv +2](https://arxiv.org/pdf/2204.07880) Lyubich: J_c has zero area if it has no irrationally indifferent cycle and is not IR. [springer](https://link.springer.com/article/10.1007/s00209-019-02319-4) Positive-area Julia sets exist (see 1.3). Positive area of ∂M remains open.
- **Ewing–Schober formula.** area(M) = π(1 − Σ_{m≥1} m|b_m|²), where b_m are the Laurent coefficients of Ψ: ℂ̂∖D̄ → ℂ̂∖M. Each partial sum A_N is a valid upper bound. [arxiv](https://arxiv.org/pdf/1410.1212) Known values:
  - Ewing–Schober (Numer. Math. 61, 1992): A_{240,000} ≈ 1.7274. [arxiv](https://arxiv.org/pdf/1410.1212)
  - Chen–Kawahira–Li–Yuan (IJBC 2011): A_{10⁶} = 1.703927. [arxiv](https://arxiv.org/pdf/1410.1212)
  - Bittner–Cheong–Gates–Nguyen (Involve 10(4), 2017; arXiv:1410.1212): A_{5·10⁶} ≈ 1.68288. [arxiv](https://arxiv.org/pdf/1410.1212) [projecteuclid](https://projecteuclid.org/journals/involve-a-journal-of-mathematics/volume-10/issue-4/New-approximations-for-the-area-of-the-Mandelbrot-set/10.2140/involve.2017.10.555.pdf) This was computed in double precision without error control, so it is not fully certified.
  - G. Irving (GitHub, not peer-reviewed): 2²⁷ terms giving μ(M) ≤ 1.651587035834859. [github](https://github.com/girving/mandelbrot)
  
  The series converges extremely slowly. Irving notes that extrapolation to ≈ 1.59–1.60 "is already contradicted by Fisher and Hill". [github](https://github.com/girving/mandelbrot) This suggests the tail Σ m|b_m|² decays very slowly, consistent with the expected wild boundary behaviour; it is not evidence for positive area of ∂M.
- **Rigorous and heuristic estimates:**
  - Fisher–Hill (quadtree plus Koebe ¼, "rigorous up to double precision"): 1.50296686 < area(M) < 1.57012937. [github](https://github.com/girving/mandelbrot) This was submitted to Numer. Math. but, as far as I could find, never published.
  - Hill's later Root-Solving/Component-Series figures (sci.fractals FAQ): at least 1.506302, below 1.5613027. [stason](https://stason.org/TULARC/science-engineering/sci-fractals/15-What-is-the-area-of-the-Mandelbrot-set.html) These are not certified.
  - Hill's sum over 430,809 hyperbolic components (periods ≤ 16; 1997): 1.506303622, a non-certified lower bound. [mrob](http://mrob.com/pub/math/jay-hill-2003-area-mandelbrot.html)
  - C. Heiland-Allen ("Trustworthy Mandelbrot", 2023; interval arithmetic plus cell mapping): fully certified but weak, 1.4164924… ≤ area ≤ 1.8478164…. [mathr](https://mathr.co.uk/web/m-trustworthy.html)
  - Förstemann pixel counting (2012): 1.5065918849 ± 0.0000000028. [mrob](http://www.mrob.com/pub/muency/pixelcounting.html) [mrob](http://www.mrob.com/pub/muency/areahistory.html) The error bar is statistical, not rigorous.
  
  Conjectured value: Förstemann's 1.5065918849 ± 0.0000000028, from 87 trillion points as cited by H. Lo; Lo's independent October 2025 update gives 1.5065918902(54) from 30.4 trillion points. Note that the best non-certified hyperbolic-component sum (1.50630) is within about 3·10⁻⁴ of the pixel estimate.
- **2-adic arithmetic of b_m.** Zagier's conjecture on ν₂(b_m) was proved for m ≡ 2 mod 4 by Bray–Nguyen (arXiv:1709.00607): −ν(b_m) = ⌊2(m+1)/3⌋ − s(⌊2(m+1)/3⌋) + ε(m). [arxiv](https://arxiv.org/pdf/1709.00607) Shimauchi (Osaka J. Math. 52, 2015) proved −ν(b_m) ≤ ν((2m+2)!), with equality iff m is odd. [arxiv](https://arxiv.org/pdf/1410.1212) The general case is open.

**1.6 Hausdorff dimension, harmonic measure, self-similarity.**
- Shishikura proved dim_H J_c = 2 for a residual set of c ∈ ∂M.
- Tan Lei (Comm. Math. Phys. 134, 1990) proved asymptotic similarity between M and J_c at Misiurewicz points.
- Lyubich (Ann. Math. 149, 1999) proved Milnor's hairiness conjecture at Feigenbaum points via universality. [arxiv](https://arxiv.org/pdf/2204.07880)
- Self-similarity of M at Siegel parameters of periodic type was proved by Dudko–Lyubich–Selinger (JAMS 33, 2020) via pacman renormalization. [arxiv +2](https://arxiv.org/pdf/2512.24171)
- Dudko asks (Question 3.1, Fig. 8) whether Tan-Lei-type similarity holds exactly in the renorm-expanding regime. [arxiv](https://arxiv.org/pdf/2512.24171) This is open.
- Questions of harmonic-measure dimension at ∂M (cf. Makarov-type results), Hölder regularity of Φ_M, and the John property are, to my knowledge, unresolved beyond special points. I did not verify recent literature here.

**1.7 Geometry of limbs and bulbs.**
- (i) For the p/q-limb L_{p/q}, the conjecture is diam L_{p/q} = O(1/q²). This is "Milnor's conjecture" as stated in Kapiamba, arXiv:2401.00795. [arxiv](https://arxiv.org/pdf/2401.00795) The sharper heuristic is that the bulb is close to a disk of radius ≈ sin(πp/q)/q², where the numerics are very good. A 2019 analytic paper, "The size of Mandelbrot bulbs", gives a non-rigorous derivation of this radius. [sciencedirect](https://www.sciencedirect.com/science/article/pii/S259005441930017X)
- (iii) Open in general.
- (iv) The Pommerenke–Levin–Yoccoz inequality gives O(1/q). Improvements are due to Levin (2009, 2011) and Dudko–Lyubich (2018). Kapiamba gave the first infinite family satisfying O(1/q²), namely the limbs L_{1/q} ("An optimal Yoccoz inequality for near-parabolic quadratic polynomials", arXiv:2103.03211), [arxiv](https://arxiv.org/html/2103.03211) using Lavaurs maps and near-parabolic geometry of rays. [arxiv](https://arxiv.org/abs/2103.03211)
- (vi) Obstruction: control of multipliers |log λ − 2πip/q| when p/q has large partial quotients. [researchgate](https://www.researchgate.net/publication/225361541_On_the_complement_of_the_Mandelbrot_set) This is where near-parabolic renormalization with large a_i fails to be uniform.
- (v) Uniform O(1/q²) bounds plus analogous bounds in satellite copies are closely related to Conj. 1.2 (bounded geometry of hyperbolic components).

### 2. Renormalization

**2.1 Feigenbaum universality and hyperbolicity.**
- Sullivan (fixed point and convergence), McMullen (exponential convergence), and Lyubich (Ann. Math. 149, 1999; hyperbolicity with a one-dimensional unstable manifold) settled the bounded-type real case. [arxiv](https://arxiv.org/pdf/2512.24171)
- Dudko's Theorem 3.3: for every period bound p̄ there is a hyperbolic horseshoe with one-dimensional unstable manifolds attracting all IR quadratic-like maps with relative periods ≤ p̄. This uses the 2023 bounds and completes the bounded-type complex program. [arxiv](https://arxiv.org/pdf/2512.24171)
- Open: unbounded combinatorics, and a single operator unifying the (QL), (Neut) and (Puz) regimes (Question 3.1, "uniform hyperbolicity rel ∂M"). [arxiv](https://arxiv.org/pdf/2512.24171)

**2.2 Near-neutral renormalization.**
- Inou–Shishikura (2008 manuscript, computer-assisted): hyperbolicity of near-parabolic renormalization for high type θ ∈ Θ_{>N}. [arxiv](https://arxiv.org/pdf/2512.24171)
- Near-Siegel: hyperbolicity for periodic-type θ (DLS 2020, Theorem 3.4); for golden mean earlier by Gaidashev–Yampolsky, computer-assisted. [arxiv](https://arxiv.org/pdf/2512.24171)
- Dudko–Lyubich, "Uniform a priori bounds for neutral renormalization" (arXiv:2210.09280): pseudo-Siegel bounds for **all** neutral maps e^{2πiθ}z + z². These are the first non-perturbative bounds in the non-locally-connected category. [arxiv](https://arxiv.org/pdf/2512.24171)
- Open: Conj. 3.5 (hyperbolic cylinder renormalization for all θ ∈ Θ̄) and Conj. 3.6 (hyperbolic Molecule renormalization). [arxiv](https://arxiv.org/pdf/2512.24171)

**2.3 Area and dimension of Feigenbaum Julia sets.**
- Avila–Lyubich (JAMS 21, 2008; Ann. Math. 195, 2022): there exist Feigenbaum J_c with dim < 2, and others with positive area. The latter are the first rational maps with hyperbolic dimension < dim_H J. [arxiv](https://arxiv.org/pdf/1712.08638) [arxiv](https://arxiv.org/abs/1504.02986)
- Dudko–Sutherland (Invent. Math. 2020): the period-doubling Feigenbaum Julia set has dim_H < 2, hence zero area. [arxiv](https://arxiv.org/pdf/1712.08638) [arxiv](https://arxiv.org/pdf/2204.07880)
- Open: is there a **real** Feigenbaum map with positive-area (or even dim 2) Julia set? A. Dudko's lists conjecture that all real Feigenbaum Julia sets have dim < 2. Another open problem is to find "sufficiently simple" positive-area examples. [cvut](https://ds.fsv.cvut.cz/21/files/presentations/Dudko.pdf) [semanticscholar](https://www.semanticscholar.org/paper/On-Lebesgue-measure-and-Hausdorff-dimension-of-sets-Dudko/b4a4307e15f589d428dc120ccbd0f5f1b0e06342)

### 3. Julia-set problems

- **Siegel disks (Douady–Sullivan conjecture: every Siegel disk of a rational map is a Jordan domain; Herman's question on the critical point on the boundary).** [nju](http://maths.nju.edu.cn/~yangfei/materials/Siegel-disk-Sanya.pdf) The strongest results, by rotation-number class:
  - Bounded type: quasidisks with the critical point on the boundary (Douady–Ghys; Zhang, Invent. 2011, for all rational maps). [aimspress](https://www.aimspress.com/aimspress-data/math/2025/7/PDF/math-10-07-747.pdf) [researchgate](https://www.researchgate.net/publication/230639456_Polynomial_Siegel_disks_are_typically_Jordan_domains)
  - Almost every θ: Jordan domain through the critical point; J_c locally connected with zero area (Petersen–Zakeri, Ann. Math. 2004). [researchgate](https://www.researchgate.net/publication/230639456_Polynomial_Siegel_disks_are_typically_Jordan_domains)
  - High type: ∂Δ_α is a Jordan curve, containing the critical point iff α is a Herman number (Shishikura–Yang, JEMS 27, 2025, pp. 4501–4562; with related work by Cheraghi, "Topology of irrationally indifferent attractors", to appear in Ann. ENS). [ems +2](https://ems.press/journals/jems/articles/14297861)
  - General Brjuno θ: open.
- **Brjuno optimality.** Yoccoz proved it for quadratics. Douady's conjecture that Brjuno is optimal for all non-Möbius rational/entire maps is still open even for cubic polynomials λz + a₂z² + z³ (F. Yang's survey). [nju](http://maths.nju.edu.cn/~yangfei/materials/Siegel-disk-Sanya.pdf)
- **Local connectivity of J_c.**
  - Known: whenever MLC is known at c via bounds, and for the neutral cases above.
  - Known to fail: Cremer J_c are never locally connected; some IR satellite J_c fail (Milnor, Sørensen; Levin's criteria). [researchgate](https://www.researchgate.net/publication/225361541_On_the_complement_of_the_Mandelbrot_set) [arxiv](https://ar5iv.labs.arxiv.org/html/1709.09869)
  - Open: a complete characterization.

### 4. Computability and complexity

- **Hertling** (Math. Log. Q. 51, 2005): if DH holds, M and ∂M (the two-sided distance function) are computable. Unconditional computability of M is open. [researchgate](https://www.researchgate.net/publication/220082902_Is_the_Mandelbrot_set_computable) [springer](https://link.springer.com/chapter/10.1007/978-3-540-68547-0_6) In the BSS model, M is undecidable (Blum–Shub–Smale), but that model is widely regarded as the wrong lens for this question.
- **Braverman–Yampolsky.**
  - Non-computable J_c exist (JAMS 19, 2006), for Siegel parameters with computable c, and can be constructed explicitly. [springer](https://link.springer.com/chapter/10.1007/978-3-540-68547-0_6) [acm](https://dl.acm.org/doi/10.1145/1250790.1250893)
  - Filled Julia sets are always computable. [acm](https://dl.acm.org/doi/10.1145/1250790.1250893)
  - Hyperbolic, parabolic and Feigenbaum Julia sets are poly-time computable. [arxiv](https://arxiv.org/pdf/1404.1236)
- **Coronel–Rojas–Yampolsky** (arXiv:1703.04668): a non-computable Mandelbrot-like bifurcation locus exists in a one-parameter family. [arxiv](https://ar5iv.labs.arxiv.org/html/1703.04668)
- **Open:** computability of area(M). This is at best upper-semicomputable via the series; a lower-semicomputable route would need certified interior. Also open: complexity of deciding c ∈ M near ∂M.

### 5. Combinatorics and entropy

- **Core entropy.** h(θ) is the entropy of p_c on its Hubbard tree. [semanticscholar](https://www.semanticscholar.org/paper/cb91b1debbd90f7887342707c9aa9732ff129ef2)
  - Continuous in θ: Tiozzo, Invent. Math. 203, 2016, answering Thurston. [toronto +2](https://www.math.toronto.edu/tiozzo/docs/RS.pdf)
  - Continuous in c, with Tiozzo's conjecture on maxima at dyadic angles proved: Dudko–Schleicher, Arnold Math. J. 6, 2020. [arxiv +2](https://arxiv.org/pdf/2607.14933)
  - Higher degree: Gao–Tiozzo, JEMS 24, 2022. [arxiv](https://arxiv.org/pdf/2607.14933)
  - Hölder continuity is known for non-recurrent angles (Bruin–Schleicher). [semanticscholar](https://www.semanticscholar.org/paper/cb91b1debbd90f7887342707c9aa9732ff129ef2)
  - Open: optimal global regularity, the full local Hölder exponent spectrum, and structure of the level sets.
  - A 2026 preprint, "Maximizing Core Entropy" (arXiv:2607.14933), continues the maxima program. Not checked in detail.
- **Core entropy enters MLC directly.** Positive core entropy is the engine of Kahn's bounds. Kahn–Kapiamba–Lyubich use a λ_F-expanding valuation built from Perron–Frobenius data of the Hubbard tree. [arxiv](https://arxiv.org/pdf/2606.27272) [arxiv](https://arxiv.org/pdf/2512.24171)
- **Biaccessibility dimension** equals h/log 2 (Thurston, Tiozzo, Jung's appendix to Dudko–Schleicher). [utexas](https://web.ma.utexas.edu/mp_arc/c/14/14-4.pdf) [semanticscholar](https://www.semanticscholar.org/paper/Core-entropy-and-biaccessibility-of-quadratic-Jung/0d60b331f2cf0632e0aba48e24e02744b83b8885)
- **Thurston's "master teapot" and the entropy spectrum** (Galois conjugates of e^{h}): connectivity and boundary questions remain active. [toronto](https://www.math.toronto.edu/tiozzo/docs/RS.pdf) I could not verify the latest status this session.
- **Internal addresses (Lau–Schleicher)** give admissibility criteria for kneading sequences. These are settled combinatorially. Veins: MLC along veins is claimed in Dudko–Kahn–Lyubich, unverified (see 1.1).

### 6. Arithmetic and algebraic aspects

- **Gleason polynomials** G_n (centers of period-n components, reduced by Möbius inversion).
  - (i) Conjecture: G_n is irreducible over ℚ for d = 2, all n ≥ 1 (Milnor, "Remark 3.5"; origin unknown per Buff–Floyd–Koch–Parry). [umich](https://public.websites.umich.edu/~kochsc/GleasonMod2.pdf)
  - (iii) Open. Ramadas (arXiv:2205.07349) reports that "irreducibility of G_n has been shown for n ≤ 19" by Doyle–Fili–Tobin using Magma (personal communication); her Corollary 1.2 deduces that Per_n(0) is irreducible over ℂ for n ≤ 19.
  - Buff proved that the degree-D analogue G₃ is reducible iff D ≡ 1 mod 6. So the unicritical generalization is false. [univ-toulouse](https://www.math.univ-toulouse.fr/~buff/Preprints/Gleason/Gleason.pdf) [arxiv](https://arxiv.org/pdf/2201.07868)
  - Modulo 2, the number of irreducible factors of G_n has been computed (Buff–Floyd–Koch–Parry, "Factoring Gleason polynomials modulo 2"). [umich](https://public.websites.umich.edu/~kochsc/GleasonMod2.pdf)
  - (v) Ramadas: G_n irreducible over ℚ ⇒ Per_n(0) ⊂ M₂ irreducible over ℂ. [researchgate](https://www.researchgate.net/publication/372729436_Irreducibility_of_periodic_curves_in_cubic_polynomial_moduli_space)
  - Galois groups: conjecturally as large as possible; open.
- **Misiurewicz polynomials** G_{d,m,n}.
  - Conjecture: irreducible over ℚ(ζ) (Benedetto–Goksel's Conjecture 1.1, after Milnor). [nsf +2](https://par.nsf.gov/servlets/purl/10520447)
  - Known: d = 2, n ≤ 3 (Buff–Epstein–Koch; Goksel; Benedetto–Goksel, IJNT 2023 and Res. Number Theory 2024). [nsf](https://par.nsf.gov/servlets/purl/10520447) [arxiv](https://arxiv.org/pdf/2203.14431)
  - Goksel (JTNB 32, 2020): irreducibility of G_{d,0,n} mod d ⇒ irreducibility of G_{d,m,n} over ℚ. [pith](https://pith.science/paper/1908.07361)
  - Buff–Epstein–Koch: Misiurewicz values at Gleason parameters are units unless periods match. [nsf +2](https://par.nsf.gov/servlets/purl/10520447)
  - Recent: the "non-unit conjecture" proved for prime p ≤ 1024, conditional on irreducibility (Benedetto–Goksel, arXiv:2506.05254); iterates of PCF x^d + c (Goksel, arXiv:2508.03308). [arxiv](https://arxiv.org/pdf/2508.03308) [pith](https://pith.science/paper/2506.05254)
- **Poonen / Morton–Silverman.** No z² + c with c ∈ ℚ has a rational point of exact period N ≥ 4. [ox](https://people.maths.ox.ac.uk/flynn/arts/art11.pdf) [arxiv](https://ar5iv.labs.arxiv.org/html/1210.6246)
  - Known: N = 4 (Morton 1998); N = 5 (Flynn–Poonen–Schaefer, Duke 1997); N = 6 conditional on BSD for one Jacobian (Stoll, LMS J. Comput. Math. 11, 2008). [arxiv +2](https://arxiv.org/pdf/1903.08865)
  - Poonen (Math. Z. 228, 1998): the conjecture implies |PrePer(f_c, ℚ)| ≤ 9, with 12 possible graphs. [centre-mersenne](https://jtnb.centre-mersenne.org/item/10.5802/jtnb.1068.pdf) [arxiv](https://ar5iv.labs.arxiv.org/html/1210.6246)
  - Evidence: Hutz–Ingram (arXiv:0909.5050; Rocky Mountain J. Math. 43(1), 2013) "verify this conjecture for c values up to height 10^8", i.e. any counterexample c has numerator or denominator exceeding 10⁸ in absolute value. They also conjecture maximal periods M(1) = 3 and M(2) = 6 over quadratic fields. Quadratic points on dynamical modular curves: Doyle–Krumm, arXiv:2301.00510.
  - N ≥ 7: open. The obstruction is the growing genus of X₁^dyn(N) and Chabauty rank conditions.
- **Equidistribution and unlikely intersections.**
  - PCF parameters (centers and Misiurewicz points) equidistribute to the bifurcation measure μ_M = harmonic measure on ∂M. This is classical (Levin; Favre–Rivera-Letelier; Baker–Hsia).
  - Baker–DeMarco (Duke 2011): infinitely many common preperiodic parameters force a relation. [arxiv](https://arxiv.org/pdf/2602.10310)
  - DeMarco–Krieger–Ye (JMD 18, 2022): there is a uniform B with |PrePer(f_{c₁}) ∩ PrePer(f_{c₂})| ≤ B for all c₁ ≠ c₂ ∈ ℂ. The general degree-d conjecture is open; partial results by DeMarco–Mavraki (Compositio 160, 2024). [aimsciences](https://www.aimsciences.org/article/doi/10.3934/jmd.2022012) [cambridge](https://www.cambridge.org/core/journals/compositio-mathematica/issue/EC983CD5D21FF4E25AC4CE5B2455D713)
  - Dynamical André–Oort: proved for curves in all moduli spaces of rational maps by Ji–Xie (arXiv:2302.02583, 2023; survey arXiv:2511.12111). [arxiv](https://arxiv.org/pdf/2511.12111) [researchgate](https://www.researchgate.net/publication/329375741_A_Dynamical_Variant_of_the_Andre-Oort_Conjecture) Earlier: Baker–DeMarco; Ghioca–Ye; Favre–Gauthier, cubic and polynomial curves. [researchgate](https://www.researchgate.net/publication/329375741_A_Dynamical_Variant_of_the_Andre-Oort_Conjecture) [arxiv](https://arxiv.org/pdf/1603.05303) The higher-dimensional case is open. [emergentmind](https://www.emergentmind.com/topics/dynamical-andre-oort-conjecture)
- **Arboreal Galois representations.**
  - Odoni's conjecture (there is a surjective representation in every degree over every Hilbertian field) is **false** in general (Dittmann–Kadets, PAMS 150, 2022). [arxiv](https://arxiv.org/abs/2012.03076) [springer](https://link.springer.com/article/10.1007/s00208-025-03110-z)
  - It holds over number fields (Specter; Benedetto–Juul; Kadets) and in prime degree over ℚ (Looper). [arxiv](https://arxiv.org/pdf/1609.03398) [researchgate](https://www.researchgate.net/publication/323510475_Polynomials_with_Surjective_Arboreal_Galois_Representations_Exist_in_Every_Degree)
  - For z² + c: finite-index results under conditions. Precise classification of finite index (Jones's conjectures) is open; for PCF c the index is always infinite. [researchgate](https://www.researchgate.net/publication/260366988_Galois_representations_from_pre-image_trees_an_arboreal_survey) [aimath](https://aimath.org/pastworkshops/galarithdynrep.pdf)
- **Non-archimedean and finite-field analogues.** The p-adic Mandelbrot set is trivial (|c|_p ≤ 1) for p odd. Over 𝔽_p, statistics of critical orbit lengths remain heuristic. These are mostly open and computational.

### 7. Generalizations

- **Multibrot M_d.** MLC holds at finitely renormalizable parameters (Kahn–Lyubich, Ann. Math. 170, 2009; AKLS 2009). [arxiv](https://arxiv.org/pdf/2512.24171) The IR case is open as for d = 2. Dudko's survey notes that the near-degenerate regime extends.
- **Cubic connectedness locus.** It is not locally connected (Lavaurs 1986; real cubic case Epstein–Yampolsky 1999). This settled question shows that "MLC-type" statements genuinely fail in higher dimension.
- **Periodic curves.**
  - Arfeux–Kiwi (PLMS 127, 2023): S_p is irreducible for cubics, answering Milnor. [wiley](https://londmathsoc.onlinelibrary.wiley.com/doi/abs/10.1112/plms.12553) [arxiv](https://arxiv.org/pdf/2501.13738)
  - Buff–Epstein–Koch (Amer. J. Math. 144, 2022): prefixed curves S_{k,1} and V_{k,1} are irreducible. [arxiv](https://arxiv.org/pdf/2305.04778) [arxiv](https://arxiv.org/html/2012.14945)
  - S_{k,2} irreducible for cubics (arXiv:2305.19944), with a splitting/merging phenomenon. [arxiv](https://arxiv.org/html/2305.19944)
  - Milnor's irreducibility of Per_n(0) ⊂ M₂: **open**, reduced to Gleason irreducibility over ℚ (Ramadas). [researchgate](https://www.researchgate.net/publication/372729436_Irreducibility_of_periodic_curves_in_cubic_polynomial_moduli_space) [arxiv](https://arxiv.org/pdf/1806.11221)
- **Tricorn and multicorns.** Not path connected (Hubbard–Schleicher 2014). [arxiv](https://arxiv.org/abs/1209.1753) [wikiwand](https://www.wikiwand.com/en/Tricorn_%28mathematics%29) Parameter rays at odd-period components do not land, accumulating on arcs of parabolics (Inou–Mukherjee, Invent. 204, 2016). [springer](https://link.springer.com/article/10.1007/s00222-015-0627-3) Straightening is discontinuous (Inou–Mukherjee, TAMS 2021). [wikiwand](https://www.wikiwand.com/en/Tricorn_%28mathematics%29)
- **Correspondences.** The Bullett–Penrose modular Mandelbrot set M_Γ is homeomorphic to M (Bullett–Lomonaco, Adv. Math. 2024, combined with Petersen–Roesch's M₁ ≅ M). This resolves the 1994 conjecture. [sciencedirect](https://www.sciencedirect.com/science/article/abs/pii/S0001870824004717) [arxiv](https://arxiv.org/abs/2010.04273)
- **Rational maps.**
  - Dudko–Luo (arXiv:2509.25658): Sierpiński carpet hyperbolic components of disjoint type are bounded, confirming McMullen's 1990s conjecture in that case. J. Kahn's MSRI 2022 talks, "Hyperbolic Components and Limits of Extremal Length", give what Dudko calls "an independent approach with a different scope" covering all Sierpiński cases; as far as I found, no preprint has appeared.
  - Lim (Invent. 2025): bounds for Herman curves of bounded type. [arxiv](https://arxiv.org/pdf/2512.24171)
- **Transcendental.** For the exponential family, the analogue of DH/MLC is open; see Benini's survey. Drach–Dudko have a manuscript (2025) on a near-degenerate regime for finite-order maps without asymptotic values, [arxiv](https://arxiv.org/pdf/2512.24171) which is unverified.

### 8. Miscellaneous and folklore

- **Arcwise connectedness.** This follows from MLC (Peano continuum) and is open independently. Hubbard trees and veins are known to be arcs where MLC holds.
- **Non-trivial fibers.** None are known. Their existence is equivalent to failure of MLC.
- **The "n² conjecture".** Mandelbrot observed bulb radii ≈ 1/q²; see 1.7. [sciencedirect](https://www.sciencedirect.com/science/article/pii/S259005441930017X) This is numerically sound and unproven except for the 1/q family.
- **π in the cusp and elephant/seahorse valleys.** The iteration-count asymptotics N(ε)·√ε → π near c = 1/4 (Boll's observation) is proved; I did not re-verify the citation in this session. Asymptotic geometry of parabolic "elephants" is governed by Lavaurs maps and parabolic enrichment (Dudko, Fig. 6). [arxiv](https://arxiv.org/pdf/2512.24171)
- **Counting.** The number of period-n hyperbolic components is ν₂(n), given by explicit Möbius sums: classical and settled. The distribution of their sizes is open and related to 1.5 and 1.7.

## Status table

| Problem | One-line statement | Status | Best partial result | Key references | Latest |
|---|---|---|---|---|---|
| MLC | M locally connected | Open | All non-IR; all bounded-type IR; anti-molecule; parabolically bounded primitive | Yoccoz; Lyubich 97; Kahn 06; KL 08–09; DL 23; DL arXiv:2309.02107; KKL arXiv:2606.27272 | 2026 |
| Combinatorial rigidity / trivial fibers | Same QML ⇒ same c | Open (⇔ MLC) | Same as MLC; AKLS for finitely renormalizable unicritical | AKLS 2009 | 2026 |
| Irrational ray landing | Every parameter ray lands | Open | Rational rays land | Douady–Hubbard; Schleicher 2000 | — |
| DH (complex) | Int M = hyperbolic | Open | Dense in every known-MLC region | MSS; McMullen 94 | 2026 |
| DH (real) | Hyperbolic dense in ℝ | Proved 1997 | KSvS for real polynomials, 2007 | Lyubich; Graczyk–Świątek; KSvS | 2007 |
| NILF | No invariant line field on J_c | Open (⇔ DH) | McMullen for bounded IR | McMullen 94 | 2026 |
| Conj. 1.2 (Dudko) | Hyperbolic components uniformly qc | Open (⇒ MLC) | — | Dudko arXiv:2512.24171 | 2025 |
| Area ∂M | area(∂M) = 0? | Open | dim_H ∂M = 2 | Shishikura 98 | — |
| area(M) | Exact value | Open | 1.50296686 < A < 1.57012937 (Fisher–Hill, unpublished) | Ewing–Schober; Bittner et al. 2017 | 2023 |
| Zagier 2-adic conj. | Formula for ν₂(b_m) | Partly (m ≡ 2 mod 4) | Bray–Nguyen | arXiv:1709.00607 | 2017 |
| Limb sizes O(1/q²) | diam L_{p/q} = O(1/q²) | Open | Proved for L_{1/q} | Kapiamba arXiv:2103.03211, 2401.00795 | 2024 |
| Neutral renormalization hyperbolicity | Conj. 3.5 | Open | Uniform pseudo-Siegel bounds, all θ | DL arXiv:2210.09280 | 2022–25 |
| Molecule renormalization | Conj. 3.6 | Open | Pacman hyperbolicity, periodic type | DLS JAMS 2020 | 2020 |
| Feigenbaum J area | Classify | Partly | Positive-area examples; period-doubling dim < 2 | Avila–Lyubich 2022; Dudko–Sutherland 2020 | 2022 |
| Douady–Sullivan Siegel | ∂Δ Jordan | Open in general | Bounded type, a.e. θ, high type | Zhang 2011; Petersen–Zakeri 2004; Shishikura–Yang 2025 | 2025 |
| Computability of M | M computable | Open (⇐ DH) | Hertling's conditional theorem | Hertling 2005 | 2005 |
| Core entropy | Regularity | Continuity proved | Hölder for non-recurrent | Tiozzo 2016; Dudko–Schleicher 2020; Gao–Tiozzo 2022 | 2026 |
| Gleason irreducibility | G_n irreducible over ℚ (d = 2) | Open | Fails for some D; mod-2 factor counts | Buff; BFKP | — |
| Misiurewicz irreducibility | G^ζ_{d,m,n} irreducible | Open | d = 2, n ≤ 3 | BEK; Goksel; Benedetto–Goksel | 2025 |
| Poonen | No rational period ≥ 4 | Open | N = 4, 5; N = 6 under BSD | Morton; FPS 1997; Stoll 2008 | 2008 |
| Uniform common preperiodic | Uniform bound, degree d | Open (d = 2 proved over ℂ) | DKY 2022 | DKY; DeMarco–Mavraki 2024 | 2024 |
| DAO | Zariski-dense PCF ⇒ special | Curves proved | Ji–Xie | arXiv:2302.02583 | 2023–25 |
| Odoni | Surjective arboreal rep. exists | False in general | True over number fields | Dittmann–Kadets 2022 | 2022 |
| Per_n(0) irreducible | Milnor | Open | ⇐ G_n irreducible over ℚ; cubic S_p irreducible | Ramadas; Arfeux–Kiwi 2023 | 2023 |
| Modular Mandelbrot | M_Γ ≅ M | Proved | — | Bullett–Lomonaco 2024 | 2024 |
| Multicorn path connectivity | Path connected? | Disproved | Non-landing rays | Hubbard–Schleicher; Inou–Mukherjee | 2016 |
| Cubic locus local connectivity | Locally connected? | Disproved | — | Lavaurs; Epstein–Yampolsky | 1999 |

## Recent progress 2020–2026

- **Dudko–Lyubich, "MLC at Feigenbaum points"** (arXiv:2309.02107; v3 29 Dec 2025; accepted to Publ. IHÉS). A priori bounds for all bounded-type IR maps, hence MLC there and local connectivity of the corresponding J_c, plus dynamical and parameter universality. Key new tool: the Wave Lemma. [arxiv](https://arxiv.org/abs/2309.02107) [arxiv](https://arxiv.org/pdf/2512.24171)
- **Dudko–Lyubich, "Uniform a priori bounds for neutral renormalization"** (arXiv:2210.09280). Companion: "Variation I: Sector Renormalization", a 2024 manuscript, unpublished. [arxiv](https://arxiv.org/pdf/2512.24171)
- **Dudko–Lyubich, GAFA 2023.** Satellite bounded-type examples of MLC and of locally connected, positive-area J_c. [arxiv](https://arxiv.org/abs/1808.10425)
- **Kahn–Kapiamba–Lyubich, "MLC for parabolically bounded primitive renormalization"** (arXiv:2606.27272, 2026). Their Theorems A–C give beau bounds plus rigidity for parabolic tails approaching the cusp. Theorem B weakens Lyubich's secondary limbs condition to "bounded puzzle Teichmüller diameter". It relies on [DKLP] (not yet public) for parabolic tails having that property. [arxiv](https://arxiv.org/pdf/2606.27272)
- **Dudko's survey** (arXiv:2512.24171, Dec 2025) gives the clearest current roadmap: Conjectures 1.2, 1.3, 3.5, 3.6 and Problems 3.1, 4.3, 4.4. [arxiv](https://arxiv.org/pdf/2512.24171)
- **Kapiamba** (arXiv:2103.03211; arXiv:2401.00795): O(1/q²) for 1/q-limbs. [arxiv](https://arxiv.org/abs/2103.03211)
- **Shishikura–Yang** (JEMS 2025): high-type Siegel disks are Jordan domains. [ems](https://ems.press/journals/jems/articles/14297861) [arxiv](https://arxiv.org/pdf/2512.24171)
- **Bullett–Lomonaco** (Adv. Math. 2024): M_Γ ≅ M. [sciencedirect](https://www.sciencedirect.com/science/article/abs/pii/S0001870824004717)
- **Arfeux–Kiwi** (PLMS 2023); S_{k,2} irreducibility (arXiv:2305.19944). [wiley](https://londmathsoc.onlinelibrary.wiley.com/doi/abs/10.1112/plms.12553) [arxiv](https://arxiv.org/html/2305.19944)
- **Ji–Xie, DAO for curves** (arXiv:2302.02583); Xie's survey (arXiv:2511.12111). [arxiv](https://arxiv.org/pdf/2511.12111)
- **DeMarco–Krieger–Ye** (Ann. Math. 2020; JMD 2022); DeMarco–Mavraki (Compositio 2024). [cam](https://www.maths.cam.ac.uk/person/hk439) [cambridge](https://www.cambridge.org/core/journals/compositio-mathematica/issue/EC983CD5D21FF4E25AC4CE5B2455D713)
- **Benedetto–Goksel**, parts I/II (2023–24) and arXiv:2506.05254; Goksel arXiv:2508.03308. [arxiv](https://arxiv.org/pdf/2508.03308) [pith](https://pith.science/paper/2506.05254)
- **Dudko–Luo** (arXiv:2509.25658): McMullen's conjecture for disjoint-type Sierpiński components. [arxiv](https://arxiv.org/pdf/2512.24171)
- **Announced but unpublished:**
  - Dudko–Kahn–Lyubich, MLC along ℝ and veins (2022 manuscript); [arxiv](https://arxiv.org/pdf/2512.24171)
  - Dudko–Kahn–Lyubich, "Virtual renormalization" (in preparation); [arxiv](https://arxiv.org/pdf/2606.27272)
  - [DKLP];
  - Kahn's MSRI 2022 approach to McMullen's conjecture;
  - Drach–Dudko on transcendental near-degenerate theory.
  
  Their claims should be regarded as unverified until preprints appear. I found no disputed proofs in this area.
- **Not inspected (titles only):** "Arithmetic conditions for Julia sets to have positive area" (arXiv:2608.24316) and "Maximizing Core Entropy" (arXiv:2607.14933).

## Accessible attack surfaces

1. **Limb asymptotics.** Push Kapiamba's 1/q result to p/q with bounded partial quotients, then to all p/q. Natural intermediate targets:
   - Farey neighbours (p/q ⊕ p'/q');
   - limbs L_{p/q} with continued-fraction height ≤ N, where the near-parabolic Lavaurs analysis applies uniformly.
   
   High-precision numerics of the constant κ(p/q) in diam L_{p/q} ≈ κ·sin(πp/q)/q² would sharpen the conjecture, e.g. by testing whether κ is a continuous function of p/q in the Ford-circle picture.
2. **Certified area bounds.** The gap is 1.503–1.570 (rigorous) versus ≈ 1.5066 (numerical).
   - Lower bound: certify the hyperbolic-component sum with interval arithmetic (Hill's 430,809 components already give a non-certified 1.50630).
   - Upper bound: a certified Koebe/distance-estimator quadtree with interval arithmetic.
   
   This is engineering-heavy but publishable. A certified exterior plus a certified component sum could narrow the interval to about 10⁻³.
3. **Ewing–Schober coefficients.** The remaining cases of Zagier's 2-adic conjecture (m ≢ 2 mod 4) are a pure combinatorics/number theory problem; data exists to 2²⁷ terms.
4. **Gleason and Misiurewicz irreducibility.**
   - Extend Goksel's mod-d criterion. For d = 2, factorization of G_n mod 2 is computed by Buff–Floyd–Koch–Parry; finding primes ℓ where G_n mod ℓ has few factors could give irreducibility for new n.
   - Compute Galois groups of G_n for n ≤ 12.
   - By Ramadas, each new irreducible G_n gives irreducibility of Per_n(0).
   - The Misiurewicz case n = 4, d = 2 is the explicit next open case. Goksel's mod-2 bound predicts at most two factors, which is falsifiable by computation. [pith](https://pith.science/paper/1908.07361)
5. **Poonen at N = 6 unconditionally.** Remove BSD from Stoll's argument: compute the rank of J(X₁^dyn(6)) unconditionally, e.g. by descent or modern Chabauty–Kim tools. N = 7 is also open.
6. **Core entropy.** Hölder exponents at recurrent angles; numerics of the entropy spectrum and the master teapot; combinatorial characterization of level sets.
7. **Finite fields.** Statistics of p_c-critical orbits over 𝔽_p versus random-map heuristics; tie-ins to arboreal index questions for z² + c.

## Caveats

- **Primary sources checked this session:** Dudko's survey, Kahn–Kapiamba–Lyubich, Dudko–Lyubich abstracts, Kapiamba's abstracts, Bullett–Lomonaco, the arithmetic papers' abstracts, and the area literature (via a subagent, partly through secondary repositories such as Irving's README).
- **Stated from standard knowledge without re-verification:** classical attributions (Mañé–Sad–Sullivan, Thurston QML, Blum–Shub–Smale, π-in-the-cusp, equidistribution authorship, the Lavaurs cubic result) and some page numbers.
- **The Fisher–Hill interval** is "rigorous" only up to double-precision arithmetic, [github](https://github.com/girving/mandelbrot) and is unpublished.
- **Items marked "manuscript" or "announced"** are not independently verifiable.
- **Bibliography.** References are given inline (authors, venue, year, arXiv IDs) rather than as a separate list.