/-!
# Data shapes for the mod-ℓ image certificates (filled by tools/export_lean_data.py, verified by kernel).
-/
namespace Oracles

/-- A certified pair of conjugacy classes of GL₂(𝔽_ℓ), given by characteristic polynomials
x² − t_A x + d_A and x² − t_B x + d_B: a representative gRep of A (as a base-ℓ code), for every g in A
a conjugator (g, C, C⁻¹) with C·gRep·C⁻¹ = g, and for every h in B, for each element s of the fixed generating set S, a word in {gRep, h}
with value s, stored as (s, word); the word b₀ … b_{k−1} (0 ↦ gRep, 1 ↦ h, evaluated left to right) is
packed as the natural 1 b₀ … b_{k−1} in binary, the leading 1 marking its length. -/
structure PairCert where
  tA : Nat
  dA : Nat
  tB : Nat
  dB : Nat
  gRep : Nat
  witnessesA : List (Nat × Nat × Nat)
  wordsB : List (Nat × List (Nat × Nat))

/-- A curve with the index of the pair it uses and the primes p₁, p₂ whose Frobenius classes are A and B. -/
structure CurveCert where
  label : String
  ainvs : List Int
  pair : Nat
  p1 : Nat
  p2 : Nat

/-- The data for one ℓ: ζ (a generator of 𝔽_ℓ^×), the codes of S = {E₁₂(1), [[1,0],[1,ζ]]}, the certified
pairs and the curves. -/
structure ModLData where
  ell : Nat
  zeta : Nat
  S : List Nat
  pairs : List PairCert
  curves : List CurveCert

end Oracles
