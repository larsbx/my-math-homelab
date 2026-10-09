/-
# The trace obstruction of the reducible-`P₆` branch

`PROOF_CERTIFICATE.md` §9 handles the case `Gal(χ_M) = A₃`, where `P₆^σ` splits
into two rational cubics corresponding to the two `A₃`-orbits of off-diagonal
index pairs.  In `M`'s eigenbasis those orbits span

  `W₊ = ⟨E₁₂, E₂₃, E₃₁⟩`   and   `W₋ = ⟨E₁₃, E₂₁, E₃₂⟩`,

and the branch is closed by the observation that `tr(A²) = 0` on each of them,
while `tr(A_k²) = 6` for every seed.

Both halves are proved here: the trace vanishing on `W±` by direct computation,
and the consequence that no `A_k` is conjugate into either sector.
-/
import PscVerif.Centralizer

namespace Psc

open Matrix

variable {K : Type*} [CommRing K]

/-- A general element of `W₊ = ⟨E₁₂, E₂₃, E₃₁⟩` in the eigenbasis. -/
def cyclicPlus (a b c : K) : Matrix (Fin 3) (Fin 3) K := !![0, a, 0; 0, 0, b; c, 0, 0]

/-- A general element of `W₋ = ⟨E₁₃, E₂₁, E₃₂⟩` in the eigenbasis. -/
def cyclicMinus (a b c : K) : Matrix (Fin 3) (Fin 3) K := !![0, 0, a; b, 0, 0; 0, c, 0]

/-- **§9 Lemma, `W₊` case.**  Squaring shifts every index pair to the other orbit,
so the diagonal stays empty and the trace vanishes. -/
theorem trace_sq_cyclicPlus (a b c : K) :
    ((cyclicPlus a b c) * (cyclicPlus a b c)).trace = 0 := by
  simp [cyclicPlus, Matrix.trace_fin_three]

/-- **§9 Lemma, `W₋` case.** -/
theorem trace_sq_cyclicMinus (a b c : K) :
    ((cyclicMinus a b c) * (cyclicMinus a b c)).trace = 0 := by
  simp [cyclicMinus, Matrix.trace_fin_three]

/-- `tr(A_k²) = 6` over `ℚ`, transported from the integer computation. -/
theorem trace_sq_Aq (k : Fin 6) : ((Aq k) * (Aq k)).trace = 6 := by
  fin_cases k <;>
    simp [Aq, Atab, Matrix.trace_fin_three, Matrix.mul_apply, Fin.sum_univ_three] <;> norm_num

/-- Conjugation preserves the trace of a square: if `Q * P = 1` then
`tr((P X Q)²) = tr(X²)`.  Written with a two-sided inverse pair rather than
`Matrix.inv`, so no invertibility side conditions leak into the statements. -/
theorem trace_sq_conj (P Q X : Matrix (Fin 3) (Fin 3) ℚ) (hQP : Q * P = 1) :
    ((P * X * Q) * (P * X * Q)).trace = (X * X).trace := by
  have hcyc : (P * X * Q) * (P * X * Q) = P * (X * X) * Q := by
    simp only [Matrix.mul_assoc]
    rw [← Matrix.mul_assoc Q P, hQP, Matrix.one_mul]
  rw [hcyc, Matrix.trace_mul_comm, ← Matrix.mul_assoc, hQP, Matrix.one_mul]

/-- **§9 Dominant Cubic Capture, `W₊` case.**  No seed matrix is similar to an
element of `W₊`: conjugation preserves the trace of the square, and `tr` separates
`6` from `0`. -/
theorem Aq_not_conj_cyclicPlus (k : Fin 6) (P Q : Matrix (Fin 3) (Fin 3) ℚ)
    (hQP : Q * P = 1) (a b c : ℚ) : Aq k ≠ P * (cyclicPlus a b c) * Q := by
  intro h
  have h6 := trace_sq_Aq k
  rw [h, trace_sq_conj P Q _ hQP, trace_sq_cyclicPlus] at h6
  norm_num at h6

/-- **§9 Dominant Cubic Capture, `W₋` case.** -/
theorem Aq_not_conj_cyclicMinus (k : Fin 6) (P Q : Matrix (Fin 3) (Fin 3) ℚ)
    (hQP : Q * P = 1) (a b c : ℚ) : Aq k ≠ P * (cyclicMinus a b c) * Q := by
  intro h
  have h6 := trace_sq_Aq k
  rw [h, trace_sq_conj P Q _ hQP, trace_sq_cyclicMinus] at h6
  norm_num at h6

end Psc
