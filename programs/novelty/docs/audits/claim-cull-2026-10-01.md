# Claim cull — 2026-10-01

This bounded audit was performed before theorem derivation. Absence from a
bounded search is not evidence of novelty.

## Decisions

Seven fragile claims were retired in
[`research/retired_claims.json`](../../research/retired_claims.json).
The original audit promoted three scope-safe consequences in
[`research/theorems.json`](../../research/theorems.json).

## Evidence checked

- Imaeda and Imaeda, *Sedenions: algebra and analysis* (2000),
  https://doi.org/10.1016/S0096-3003(99)00140-X, studies the standard real
  sedenion construction. It does not support the original arbitrary-field,
  arbitrary-parameter quantifier.
- Moreno, *The zero divisors of the Cayley-Dickson algebras over the real
  numbers*, https://arxiv.org/abs/q-alg/9710013, is explicitly over the reals.
- Moreno, *Constructing zero divisors in the higher dimensional
  Cayley-Dickson algebras*, https://arxiv.org/abs/math/0512517, is likewise
  about the standard real tower.
- Lubotzky–Samuels–Vishne, *Ramanujan Complexes of Type A-tilde*,
  https://arxiv.org/abs/math/0406208, concerns buildings for PGL over local
  fields; it does not supply the proposed octonionic D4 action.
- Lubotzky–Samuels–Vishne, *Explicit Constructions of Ramanujan Complexes of
  Type A-tilde*, https://arxiv.org/abs/math/0406217, again does not identify
  the N2 generators with a D4-building lattice.
- The current mathlib repository has computable quaternion infrastructure at
  `Mathlib/Algebra/Quaternion.lean`, but bounded default-branch searches on
  2026-10-01 returned no code results for `HilbertSymbol`, `Pfister`, or
  `CayleyDickson`. This is a coverage lead, not a proof of absence.

## Search lanes still open

- exact classification of scalar generalized Cayley-Dickson zero divisors
  over number fields;
- trialitarian integral group schemes attached to a selected Cayley order;
- theta series for congruence-pair and higher factorial-moment counts with
  uniformity when (nasympell^3);
- explicit discrepancy constants with compatible normalizations.

## Promotion decision

The original audit promoted N1-T01, N2-T01, and N3-T01 as proved results.
The provenance reconciliation keeps N1-T01 pending: its written deduction
has no recorded independent review, matching `ZeroDivisorCertificateSoundness`.
N2-T01 and N3-T01 retain their existing status. None is a novel result. The N3 shell-to-factorial-moment handoff remains a candidate bridge
for novelty review.
