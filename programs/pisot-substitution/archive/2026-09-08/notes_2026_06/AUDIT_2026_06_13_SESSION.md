# Adversarial audit — session 2026-06-13 (BD inheritance / consolidation)

Audited all new and edited load-bearing claims. One real gap found and fixed; everything
else sound. Detail below, by target.

## FIXED (real gap)

**`cor:cr-floor` / the "primitive Σ_C" assertion in v14 §`sec:cohomology-companion`.**
The insert asserted "the abelianization of a primitive substitution Σ_C" as a flat claim.
But N_C is only IRREDUCIBLE (C recurrent), not necessarily primitive: a direct measurement
found **26 of 214 recurrent SCCs (12.1%) have imprimitive N_C** (imprimitivity index h=2).
The cr-criterion (cr=1 ⟺ PDS, B15/BBK) and homological-Pisot machinery presume a primitive
substitution. **Fix applied:** the insert now carries the power-normalization explicitly —
pass to σ^p (again primitive Pisot with irreducible char poly, since β^p has the same
Q-degree as β) to make N_C primitive without changing Ω_σ up to conjugacy or the
coincidence rank. This is the companion's Thm 6.7 normalization, which the v13 merge had
dropped. v14 recompiled clean (19 pp, 0 unresolved).

## SOUND (verified, no change needed)

**Target 6 — χ_{M_σ} | χ_{N_C} ⟺ closed-nonproductive (the gcd=1 finding).** Verified
sound and consistent with `lem:alg-structure`, not contradictory. β>0 is the spectral
radius of M, so β∈spec(N_C) ⟹ PF(N_C)≥β; producing means PF<β, hence β∉spec(N_C), hence
χ_{M_σ} (root β) does not divide χ_{N_C}. Measured: 0/201 specimens with PF≥β, 0 impossible
(β-eigenvalue-not-PF) cases. The corpus simply contains no closed-nonproductive SCC, by
construction. The "spectral isolation" reconciliation stands.

**Target 1 — `lem:redproj` π₁ rewrite.** Sound. Free-group reduction is consecutive-only;
the basepoint seam is irrelevant for a single based loop; π₁ of a graph is free so
reduced+nonempty ⟹ nontrivial ⟹ not a tree ⟹ b₁≥1. Unit-step i-determinacy kills
consecutive backtracks at shared vertices (distinct chain-neighbors ⟹ distinct i-letters).
The earlier self-caught H₁-orientation error is genuinely replaced by a valid argument.

**Target 4 — `prop:qa-crc` (second conditional route).** Sound. The norm of the dilatation
is a property of β's MINIMAL polynomial (χ_{M_σ}, irreducible degree k), shared between σ
and Σ_C, NOT of N_C's reducible char poly; under unimodularity norm(β)=±det(M_σ)=±1, so
CRC forces cr(Σ_C)=1. Applicability of CRC to the reducible Σ_C is exactly hypothesis Q-A,
correctly labeled conditional.

**Target 8 — triple instrument (`triple_overlap.py`) and Q-B verdict.** Sound. Mass-balance
gate β·w=Σw held exactly (0/1,600). Every triple state has all three pair projections
genuine, nonempty common interior, and (sampled) projects to extant pair states. The
closed-triple detection partitions nc-SCCs cleanly into trapped (0), open-noncoincident
(371), leaky (16) — not masking via over-aggressive open-marking. The 0-trapped-triple
result is genuine elimination, parallel to the 0-trapped-pair pair census.

**Target 7 — Barge–Olimb closure.** Confirmed at source (Sadun survey read in full): a d≥2
paper whose branch-locus object is trivial in 1D; the 1D content reduces to the
Barge–Diamond asymptotic composants already captured by BBJS. No 1D cr-extension theorem
exists. Closure stands.

## Standing caveats reaffirmed (not defects)
- Census is elimination throughout; no closed-nonproductive SCC / trapped triple in the
  corpus by construction.
- BD08/Sa14 read one step removed (via BBJS + Sadun survey); flagged in v14.
- v14 remains conditional (two routes, both ≥2 conjectures deep on the hard cases). The
  open core — the positional avoidance residue under the no-coarse-quotient meta-theorem —
  is untouched.
- Q-A condition (1) residual (nonzero roots of q forced onto roots of unity) remains the
  sole genuinely-open arithmetic item; no census purchase.

## Net
One substantive correction (primitivity normalization in v14), one recompile. All other
new theorems and the Q-B/Barge–Olimb verdicts survive adversarial scrutiny. Manuscript
v14 status unchanged in kind.
