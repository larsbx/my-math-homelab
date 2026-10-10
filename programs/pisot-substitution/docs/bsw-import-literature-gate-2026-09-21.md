# Literature gate — the Barge–Štimac–Williams import (Imported Theorem 5.37)

## Proposed step

`docs/audit-2026-09-20.md` §B.1 found that Theorem 5.38 (one-seed overlap
productivity ⟹ PDS) rests entirely on Imported Theorem 5.37, and that none of
the 102 automated referee rounds examined that import's hypotheses. The gate
asked for a reading of Barge, Štimac, Williams, *Pure discrete spectrum in
substitution tiling spaces*, Discrete Contin. Dyn. Syst. 33 (2013) 579–597
(arXiv:1107.3598), Section 3, against the manuscript's statement at
`manuscripts/PSC_balanced_pair_state_2026-09-13.tex` l.778–784, on three
points:

1. whether Theorem 3.1 accepts a periodic patch that is not an allowed
   (legal) patch of `Ω_Φ`;
2. whether "densely eventually coincident" means coincidence on a dense set
   of points, or on a set of positive or full measure;
3. whether the one-dimensional specialization used by the manuscript is the
   argument by which BSW derive their Theorem 3.2 from Theorem 3.1.

The check was made against the arXiv text (v1, 19 Jul 2011) and the
published final version hosted by the second author; both carry the same
Section 3.

## Decision

**Proceed; the import is stated correctly.** All three points are settled in
the manuscript's favour by the source text. No hypothesis was silently
added or weakened. One strengthening is free and is now recorded on the
status surfaces: Lemma 5.36(b) gives the good set full Lebesgue measure, not
only density, so the import would survive a stricter reading of "densely"
than BSW actually use.

## Findings

### 1. Patches need not be allowed

BSW open Section 3 with: "Given patches `Q, Q′` (not necessarily allowed for
`Φ`) and `x ∈ int(spt(Q) ∩ spt(Q′))`, we'll say that `Q` and `Q′` are
coincident at `x` provided `B_0[Q − x] = B_0[Q′ − x]` and eventually
coincident at `x` if there is `k ∈ N` so that
`B_0[Φ^k(Q − x)] = B_0[Φ^k(Q′ − x)]`." Theorem 3.1 then takes "a finite
patch `Q` such that `Q̄ = ∪(Q + Σ k_i v_i)` is a tiling of `R^n`" with no
allowedness condition. The swap word `ab`, which may be an illegal factor
of the substitution language (manuscript Remark 2.12), is therefore within
the theorem's hypotheses. The manuscript's "not necessarily legal" is the
source's own wording.

### 2. "Densely" means a dense set of points

BSW: "We'll say that `Q` and `Q′` are densely eventually coincident on
overlap if `Q` and `Q′` are eventually coincident at a set of `x` that is
dense in `int(spt(Q) ∩ spt(Q′))`, and, if this happens for tilings `Q, Q′`,
we'll say that `Q` and `Q′` are densely eventually coincident." The proof of
Theorem 3.1 uses only that eventual coincidence at a point is an open
condition together with the Baire category theorem, i.e. topological
density. Lemma 5.36(c) supplies exactly this. Lemma 5.36(b) supplies more
(full measure), which is now stated alongside it.

### 3. The one-dimensional specialization is BSW's own

BSW Theorem 3.2 ("Suppose that `φ` is a Pisot substitution with left
Perron–Frobenius eigenvector `ω` and `u, v ∈ A*` are words with
`⟨[u],ω⟩`, `⟨[v],ω⟩` independent over `Q` and the balanced pair algorithm
for `(uv, vu)` terminates with coincidence. Then the `R`-action on `Ω_Φ` has
pure discrete spectrum.") is proved in five lines: "Let `Q` be a patch with
underlying word `uv` … `Q̄ = ∪(Q + nl)` is a periodic tiling of `R` …
the hypotheses imply that `l_u` is completely rationally independent of
`{l}` and that `Q̄` and `Q̄ − l_u` are densely eventually coincident. The
result follows from Theorem 3.1." Imported Theorem 5.37 is this argument
with termination replaced by the dense coincidence it was used to produce,
as the manuscript says. The words `u, v` in Theorem 3.2 carry no
allowedness hypothesis either.

### 4. Standing hypotheses transfer

BSW assume throughout that `Φ` is primitive, aperiodic and has finite local
complexity, and that it is of Pisot family type; they state that a
primitive substitution on letters with Pisot Perron eigenvalue `λ`, realized
with tile lengths `ω`, "is of `(1, d)`-Pisot family type, `d` being the
algebraic degree of `λ`". Unimodularity is not assumed anywhere in
Section 3 (the word occurs only in the introduction's description of the
homological Pisot conjecture and in reference titles). For PIP `σ` the
manuscript checks aperiodicity (Lemma 2.4), FLC (finitely many interval
prototiles) and `Q`-independence of `ℓ_a, ℓ_b` (Lemma 2.3); the non-unit
case is covered by the source as stated.

### 5. Corollary 3.3 and the seedwise question

BSW Corollary 3.3 records the `(ab, ba)` form for irreducible Pisot
substitutions and states that the earlier proof in Barge–Kwapisz "has a gap
that is not easily fixed using the techniques of that paper". This is the
citation the manuscript already uses for Imported Theorem 2.16. Nothing in
Section 3 bears on the converse (PDS ⟹ termination from a given seed), so
Open Problem 4.24 is untouched.

## Terminology

BSW's "eventually coincident at `x`" is the manuscript's membership of `x`
in the good set `G(s)`; their "densely eventually coincident" is
Lemma 5.36(c). The manuscript's "productive overlap" has no BSW
counterpart; it is the repository's finite-graph reformulation and enters
only through Lemma 5.36(a)⟺(c).

## Consequence for the status surfaces

- `docs/claim-status-and-source-map-2026-09-13.md`, row "Density-to-PDS
  bridge": hypotheses now verified against the source text, not only
  against the manuscript's own paragraph.
- `docs/audit-2026-09-20.md` §B.1: discharged.
- No status class changes. `DensityToPDSBridge` remains an imported theorem
  and `PDSOverlapRoute` a conditional theorem.
