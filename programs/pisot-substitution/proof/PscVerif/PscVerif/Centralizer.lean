/-
# The Seed-Centralizer Lemma and PIP-Locus Target 1

`PROOF_CERTIFICATE.md` §7 proves that `K₃(s_k)` never lies in the determinant
eigenspace of `Φ₃`, by transporting that membership through `Θ` into the
statement `[M, A_k] = 0` and contradicting irreducibility of `χ_M`.

The contradiction step is isolated here as `no_commuting_of_no_eigenvalue`,
which is stated over an arbitrary field and proved in full.  The seed-specific
input it needs -- that the `λ_k`-eigenspace of `A_k` is exactly the line spanned
by `(1,1,1)ᵀ` -- is discharged for each of the six seeds by linear arithmetic.

The PIP hypothesis enters as `NoEigenvalue M`: `M` has no eigenvector with
eigenvalue in the base field.  For a `3 × 3` rational matrix that is exactly
irreducibility of the characteristic cubic over `ℚ`, since a cubic is reducible
over `ℚ` iff it has a rational root.
-/
import PscVerif.Seeds

namespace Psc

open Matrix

variable {K : Type*} [Field K]

/-- `M` has no eigenvector defined over the base field. -/
def NoEigenvalue (M : Matrix (Fin 3) (Fin 3) K) : Prop :=
  ∀ (c : K) (w : Fin 3 → K), M *ᵥ w = c • w → w = 0

/-- **The centralizer contradiction, in the abstract.**

If `A` has an eigenvector `v ≠ 0` whose eigenspace is exactly the line `K ∙ v`,
and `M` commutes with `A`, then `v` is an eigenvector of `M` too -- so `M` has an
eigenvalue in the base field.  Under `NoEigenvalue M` that is impossible. -/
theorem no_commuting_of_no_eigenvalue
    (M A : Matrix (Fin 3) (Fin 3) K) (l : K) (v : Fin 3 → K)
    (hv : v ≠ 0)
    (heig : A *ᵥ v = l • v)
    (hker : ∀ w : Fin 3 → K, A *ᵥ w = l • w → ∃ c : K, w = c • v)
    (hM : NoEigenvalue M)
    (hcomm : M * A = A * M) : False := by
  have hstep : A *ᵥ (M *ᵥ v) = l • (M *ᵥ v) := by
    rw [Matrix.mulVec_mulVec, ← hcomm, ← Matrix.mulVec_mulVec, heig, Matrix.mulVec_smul]
  obtain ⟨c, hc⟩ := hker _ hstep
  exact hv (hM c v hc)

/-- The universal eigenvector `(1,1,1)ᵀ` of §6 property 6. -/
def ones : Fin 3 → ℚ := fun _ => 1

theorem ones_ne_zero : (ones : Fin 3 → ℚ) ≠ 0 := by
  intro h
  have := congrFun h 0
  simp [ones] at this

/-- The seed matrices over `ℚ`. -/
def Aq (k : Fin 6) : Matrix (Fin 3) (Fin 3) ℚ := (Atab k).map (fun n => (n : ℚ))

set_option linter.unnecessarySeqFocus false in
/-- **§6 property 6, first half.**  `(1,1,1)ᵀ` is an eigenvector of every `A_k`. -/
theorem Aq_mulVec_ones (k : Fin 6) : (Aq k) *ᵥ ones = ((lam k : ℚ)) • ones := by
  fin_cases k <;>
    · funext i
      fin_cases i <;>
        simp [Aq, Atab, lam, ones, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;>
        norm_num

/-- **§6 property 6, second half.**  The `λ_k`-eigenspace of `A_k` is exactly the
line spanned by `(1,1,1)ᵀ`.  This is what makes the centralizer argument bite:
`M` must preserve a *rational* line, hence has a rational eigenvalue. -/
theorem Aq_eigenspace (k : Fin 6) (w : Fin 3 → ℚ)
    (h : (Aq k) *ᵥ w = ((lam k : ℚ)) • w) : ∃ c : ℚ, w = c • ones := by
  refine ⟨w 0, ?_⟩
  have h0 := congrFun h 0
  have h1 := congrFun h 1
  have h2 := congrFun h 2
  fin_cases k <;>
    · simp [Aq, Atab, lam, Matrix.mulVec, dotProduct, Fin.sum_univ_three] at h0 h1 h2
      funext i
      fin_cases i <;> simp [ones] <;> linarith

/-- **PIP-Locus Target 1, contradiction form.**

No matrix without a rational eigenvalue commutes with any of the six seed
matrices.  Via the `Θ`-intertwining of §5 this is exactly
`K₃(s_k) ∉ W_det(σ)`, i.e. `(Φ₃ - det M)² K₃(s_k) ≠ 0`. -/
theorem target1 (M : Matrix (Fin 3) (Fin 3) ℚ) (hM : NoEigenvalue M) (k : Fin 6)
    (hcomm : M * Aq k = Aq k * M) : False :=
  no_commuting_of_no_eigenvalue M (Aq k) ((lam k : ℚ)) ones
    ones_ne_zero (Aq_mulVec_ones k) (Aq_eigenspace k) hM hcomm

/-- **§7, concrete corollary.**  A PIP incidence matrix cannot have all row sums
equal: `(1,1,1)ᵀ` would be a rational eigenvector, contradicting irreducibility
of the characteristic cubic. -/
theorem no_equal_row_sums (M : Matrix (Fin 3) (Fin 3) ℚ) (hM : NoEigenvalue M)
    (r : ℚ) (hrows : ∀ i, ∑ j, M i j = r) : False := by
  refine ones_ne_zero (hM r ones ?_)
  funext i
  have h := hrows i
  rw [Fin.sum_univ_three] at h
  simp [Matrix.mulVec, dotProduct, ones, Fin.sum_univ_three]
  linarith

end Psc
