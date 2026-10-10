# N6 Cartesian calculus — literature stop/go gate

## Proposed claim or experiment

Audit N6-Q1–Q5 before standalone research resumes. Conventions: finite simple
undirected loopless graphs; disjoint union adds, Cartesian product multiplies,
unit $K_1$; integer counts. Connected patterns have at least one edge and
are counted by ordinary injective embeddings divided by their automorphisms.
No proof code, experiment or mathematical promotion is added here.

## Sources

Read **2026-10-08**; exact full-text locators:

1. **Imrich–Klep–Smertnig**, *Monoid algebras and graph products* (2025),
   [arXiv v2](https://arxiv.org/html/2407.02615v2), Definition 3.1,
   Proposition 3.2, §3.1, Corollary 3.14: graph semirings and rings of
   differences as monoid algebras.
2. **Klavžar–Lipovec–Petkovšek**, *On subgraphs of Cartesian product graphs*
   (2002), [author PDF](https://users.fmf.uni-lj.si/klavzar/preprints/MarkoAlenka.pdf),
   §1 (PDF p. 2), Theorem 1 (pp. 3–4): S-prime is precisely no
   mixed-coordinate ordinary embedding; path-coloring characterization.
3. **Klavžar–Peterin**, *Characterizing subgraphs of Hamming graphs* (2005),
   [author PDF](https://users.fmf.uni-lj.si/klavzar/preprints/20084-scan.pdf),
   Lemma 2.1, Theorem 2.2, Corollary 2.3 (printed pp. 304–305): two
   complete factors suffice, with an equivalent two-edge-label criterion.
4. **Hellmuth**, *On the complexity of recognizing S-composite and S-prime
   graphs* (2013), [full arXiv v5](https://arxiv.org/html/1205.0991v5),
   Theorems 2.12 and 2.15: NP-complete complement recognition and
   coNP-complete S-prime recognition.
5. **Brouwer–Haemers**, *Spectra of Graphs* (2012),
   [author text](https://homepages.cwi.nl/~aeb/math/ipm/ipm.pdf),
   Proposition 1.3.1 (p. 14), §1.4.6 (p. 19): trace/walk identity
   and Cartesian Kronecker sum.
6. **Stacks Project**, [§10.131, tag 00RM](https://stacks.math.columbia.edu/tag/00RM)
   (universal differentials, Lemma 10.131.14 and colimits), and
   [§10.133, tag 09CH](https://stacks.math.columbia.edu/tag/09CH),
   Definition 10.133.1: generic derivations and differential operators.

Supplementary sources and access limits are in the
[comparison](n6-prior-art-2026-10-08.md); exact searches are in the
[log](n6-search-log-2026-10-08.md).

## Terminology

Fiber-captured = **Cartesian S-prime** under these conventions; its complement
is S-composite. Historical *quasiprime* is a useful search term.
Chastand's *fiber-complemented* and local *quasi Cartesian products* denote
different properties. Product-prime does not imply S-prime.

## Hypotheses

Finite connected Cartesian factorization and ordinary S-prime embedding
results transfer. Abstract polynomial-ring derivations transfer at any
ring character, with a product of coordinate modules, not a direct sum.
Induced/isometric embeddings, infinite-graph results, modular cancellation
and the other graph-algebra multiplications do not transfer automatically.
For $\Gamma=K_1$, fiber containment holds but its count is
$\varepsilon$, so the stated derivation equivalence fails.

## Negative controls

$P_3\subset K_2\square K_2$ is product-prime with a mixed embedding.
Small products cannot certify universal S-primeness. $C_5,C_7$ disprove
“triangle-free implies odd walks vanish.” Trace counts are not simple cycle
counts. First-order differential operators also include scalar multiples of
$\varepsilon$; derivations additionally vanish on the unit.

## Decision

**Redirect.** Stop new-class, unrestricted characterization/complexity,
abstract ring/module and routine walk-convolution headlines: positive prior
art or standard algebra covers them. The narrowed next target is an exact
ordinary-cycle formula, with collision corrections and a specified symbol
convention, subjected to its own gate in the standalone repository.
Restricted recognition and compatible algebraic maps remain possible
research targets only after precise statements. The scaffold lacks the full
$C_6$ formula and triangle-free theorem, so those are held for comparison.
This decision is literature calibration, not certification of novelty.
