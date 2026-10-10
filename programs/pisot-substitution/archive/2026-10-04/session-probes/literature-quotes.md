# Passages relied on in the literature gates — quoted

The vertex-coincidence note (`docs/p1b-vertex-coincidence-box-2026-10-02.md`,
§5.6b and §5.7) and the Barge–Diamond gate
(`docs/p1b-barge-diamond-configuration-gate-2026-10-02.md`) rely on the
statements below. Each is quoted verbatim from the text extracted during the
session, with its section and page. Only the notation was restored from the
PDF extraction: superscripts and subscripts, the angle brackets ⟨ , ⟩ in
place of `h…i`, and fraktur and script letters spelled as in the source.
Nothing else was changed. The full papers are cited, not reproduced.

## Baker, Barge, Kwapisz — *Geometric realization and coincidence for reducible non-unimodular Pisot tiling spaces with an application to β-shifts*, Ann. Inst. Fourier 56 (2006), no. 7, 2213–2248

Read for the route check of 2026-10-04 (§5.6b, Proposition P″).

- §1, p. 2214: "Here we extend the theory to cover all primitive
  substitutions of Pisot type."
- §1, p. 2215, Conjecture 1.1 (Pisot Conjecture): "The tiling flow
  associated with an irreducible Pisot substitution has pure discrete
  spectrum."
- §4, p. 2222: "Two labeled strands γ, η are coincident, denoted γ ∼ η, iff
  Φ^k(γ) and Φ^k(η) share a labeled edge for some k ⩾ 0."
- §4, p. 2222, Definition 4.1: "The coincidence rank of φ, denoted by cr_φ,
  is the maximal number of strands in F that lie over the same point of
  V/Σ and no two of which are coincident with each other. We say that the
  Geometric Coincidence Condition (GCC) holds for φ iff cr_φ = 1."
- §4, p. 2222, Theorem 4.2 (Coincidence Theorem): "The geometric
  realization map h_φ is uniformly finite-to-one (i.e., ∃C>0 ∀p∈T_A
  #h_φ^{−1}(p) ⩽ C) and almost everywhere cr_φ-to-1."
- §4, p. 2222: "It is conjectured that h_φ is an isomorphism for all Pisot
  φ that are irreducible (i.e., deg(p_min) = n) or arise from β-expansions."
- §5, p. 2226, Theorem 5.1: "The eigenvalues of the tiling flow T^t consist
  of numbers ⟨u|ω⟩ where u ∈ Σ*_∞, and χ_u ∘ h_φ serves as an eigenfunction
  corresponding to the eigenvalue ⟨u|ω⟩." Corollary 5.2: "The tiling flow
  T^t has pure discrete spectrum iff cr_φ = 1."
- §6, p. 2230, Theorem 6.1: "Suppose that cr_φ > 1. For any ε > 0 there is
  D > 0 such that if K, L ∈ S_p, p ∈ V/Σ, and K ∼_{tω} L for a dense G_δ set
  of t ∈ [−ε, ε], then dist(K, L) < D."
- §7, p. 2235, hypotheses and Theorem 7.1: "(i) a_1 > 0 and a_n > 0; (ii)
  the largest modulus root β of t^n − a_1 t^{n−1} − · · · − a_{n−1} t − a_n
  is a Pisot number. We will also require the following hypothesis: (iii)
  the algebraic degree d := deg β satisfies d > n/p where p > 1 is the
  smallest prime divisor of n. Theorem 7.1. — Under the above hypotheses
  (i), (ii) and (iii) the substitution φ satisfies GCC, i.e., cr_φ = 1."

*Use in the note.* GCC is labelled-edge coincidence, decidable per
substitution and equivalent to pure discrete spectrum (Theorem 4.2,
Corollary 5.2). It is proved unconditionally only under (i)–(iii) of §7.
The realisation space T_A is the inverse limit carrying the
non-Archimedean coordinate used in Propositions P′ and P″.

## Barge — *The Pisot conjecture for β-substitutions*, arXiv:1505.04408v2 (2015)

Read for the route check of 2026-10-03 (§5.7, property (W)).

- §3, p. 7: "the Pisot number β is said to be finitary if Z[1/β] ∩ R+ ⊂
  Fin(β) and is said to be weakly finitary if for all z ∈ Z[1/β] ∩ R+ there
  are x, y ∈ Fin(β), with y as small as desired, such that z = x − y. The
  so-called Property (W) is that β is weakly finitary."
- §3, p. 7: "Akiyama proves in [A1] that β satisfies Property (W) if and ony
  if (Ω_{ψβ}, R) has pure discrete spectrum".
- §4, pp. 7–8: "Property 1: If ab is a two letter word in L(ψβ) and
  b ∈ {2, . . . , m + p}, then a = b − 1. Property 2: If ab and ac are two
  letter words in L(ψβ) and b ≠ c, then either b = 1 or c = 1. Property 3:
  If ac and bc are two letter words in L(ψβ) and a ≠ b, then c = 1."
- §4, p. 14, Theorem 15: "If β is Pisot, then (Ω_{ψβ}, R) has pure discrete
  spectrum."
- §4, p. 15, Corollary 17: "All Pisot numbers are weakly finitary."
- §5, p. 23, Proposition 31: "If β is Pisot, then (Ω_{ψβ}, R) has pure
  discrete spectrum if and only if for all t ∈ Z[1/β] ∩ R+ the set
  {t′ ∈ Fin(β) : t + t′ ∈ Fin(β)} is dense in R+."
- §5, p. 23: "It follows from Theorem 15 and Proposition 31 that all Pisot β
  are weakly finitary, proving Corollary 17."

*Use in the note.* (W) is deduced from pure discrete spectrum, and pure
discrete spectrum from the monotonicity Properties 1–3. So (W) offers no
route to PPVC that bypasses pure discrete spectrum.

## Barge, Diamond — *Coincidence for substitutions of Pisot type*, Bull. Soc. Math. France 130 (2002), no. 4, 619–626

Read for the Barge–Diamond configuration gate.

- Abstract, p. 619: "ϕ satisfies the strong coincidence condition if for
  every i, j ∈ A, there are integers k, n such that ϕ^n(i) and ϕ^n(j) have
  the same k-th letter, and the prefixes of length k − 1 of ϕ^n(i) and
  ϕ^n(j) have the same image under the abelianization map. We prove that the
  strong coincidence condition is satisfied if d = 2 and provide a partial
  result for d ≥ 2."
- §1, Theorem 1: "Let ϕ be a Pisot substitution on an alphabet
  A = {1, 2, . . . , d}. There are distinct letters i, j ∈ A for which there
  are integers k, n such that ϕ^n(i) and ϕ^n(j) have the same k-th letter,
  and the prefixes of length k − 1 of ϕ^n(i) and ϕ^n(j) have the same image
  under the abelianization map."
- Coincidence Conjecture, as stated there: "For 1 ≤ j, r ≤ d, I_j and I_r
  are eventually coincident."

*Use.* Strong coincidence is proved for two letters, and only for *some*
pair of letters when d ≥ 3. This is the configuration argument whose
extension the Barge–Diamond gate examined.
