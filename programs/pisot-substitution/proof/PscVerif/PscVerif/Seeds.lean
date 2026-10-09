/-
# The six length-7 seeds and their `sl₃` matrices

`PROOF_CERTIFICATE.md` §4 lists six length-7 balanced pairs with `K₂ = 0`, and
§6 tabulates the matrices `A_k = Θ(K₃(s_k))`.  Here the seeds are the primary
data and the matrices are *derived*: `theta_seed` proves, by kernel computation,
that `Θ` applied to the seed's own `K₃` gives the tabulated matrix.  The
certificate's table is a target, not an input.
-/
import PscVerif.Shuffle

namespace Psc

open Matrix

/-- The Levi-Civita symbol on three indices. -/
def ε (i j k : Letter) : ℤ :=
  if i = 0 ∧ j = 1 ∧ k = 2 then 1
  else if i = 1 ∧ j = 2 ∧ k = 0 then 1
  else if i = 2 ∧ j = 0 ∧ k = 1 then 1
  else if i = 0 ∧ j = 2 ∧ k = 1 then -1
  else if i = 2 ∧ j = 1 ∧ k = 0 then -1
  else if i = 1 ∧ j = 0 ∧ k = 2 then -1
  else 0

/-- The contraction `Θ(x)_{ij} = Σ_{k,l} ε_{jkl} x_{ikl}` of §5.  Restricted to the
shuffle-kernel sector it is the identification `W₃ ≅ sl₃`. -/
def Θ (x : Letter → Letter → Letter → ℤ) : Matrix (Fin 3) (Fin 3) ℤ :=
  Matrix.of fun i j => ∑ k : Fin 3, ∑ l : Fin 3, ε j k l * x i k l

/-- Build a balanced pair from two explicit words, discharging the side
conditions by computation. -/
def mk! (u v : Word) (h₁ : u.length = v.length := by decide)
    (h₂ : ∀ a, N a u = N a v := by decide) : BalancedPair := ⟨u, v, h₁, h₂⟩

/-- The six length-7 `K₂`-zero seeds, zero-indexed. -/
def seed : Fin 6 → BalancedPair
  | 0 => mk! [0,1,1,2,2,0,1] [1,2,0,0,1,1,2]
  | 1 => mk! [0,1,2,2,0,0,1] [2,0,0,1,1,2,0]
  | 2 => mk! [0,2,1,1,0,0,2] [1,0,0,2,2,1,0]
  | 3 => mk! [0,2,2,1,1,0,2] [2,1,0,0,2,2,1]
  | 4 => mk! [1,0,2,2,1,1,0] [2,1,1,0,0,2,1]
  | 5 => mk! [1,2,2,0,0,1,2] [2,0,1,1,2,2,0]

/-- The tabulated matrices of §6, kept as a target for `theta_seed`. -/
def Atab : Fin 6 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![-2, 3, -3; -3, 4, -3; -3, 3, -2]
  | 1 => !![-4, 3,  3; -3, 2,  3; -3, 3,  2]
  | 2 => !![ 4,-3, -3;  3,-2, -3;  3,-3, -2]
  | 3 => !![ 2, 3, -3;  3, 2, -3;  3, 3, -4]
  | 4 => !![-2, 3, -3; -3, 4, -3; -3, 3, -2]
  | 5 => !![-2,-3,  3; -3,-2,  3; -3,-3,  4]

/-- The simple rational eigenvalue of `A_k`, from §6 property 6. -/
def lam : Fin 6 → ℤ
  | 0 => -2 | 1 => 2 | 2 => -2 | 3 => 2 | 4 => -2 | 5 => -2

/-- Every seed has vanishing `K₂`, so §4's description is correct. -/
theorem seed_K₂_zero (k : Fin 6) (i j : Letter) : (seed k).K₂ i j = 0 := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

/-- Every seed has length 7. -/
theorem seed_length (k : Fin 6) : (seed k).u.length = 7 := by fin_cases k <;> rfl

/-- **§6, derived.**  `Θ` applied to the seed's own `K₃` reproduces the
tabulated matrix `A_k`. -/
theorem theta_seed (k : Fin 6) (i j : Fin 3) : Θ (seed k).K₃ i j = Atab k i j := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

/-- The seed matrices lie in `sl₃`: they are traceless. -/
theorem trace_A (k : Fin 6) : (Atab k).trace = 0 := by
  fin_cases k <;> simp [Matrix.trace_fin_three, Atab]

/-- **§6 property 7.**  `tr(A_k²) = 6` for every seed.  This is the `GL₃`-invariant
that rules out `A_k ∈ W₊ ∪ W₋` in the reducible-`P₆` branch (§9). -/
theorem trace_sq_A (k : Fin 6) : ((Atab k) * (Atab k)).trace = 6 := by
  fin_cases k <;> simp [Matrix.trace_fin_three, Atab]

/-- **§6 property 3.**  Each `A_k` has nonzero determinant, hence rank 3. -/
theorem det_A_ne_zero (k : Fin 6) : (Atab k).det ≠ 0 := by
  fin_cases k <;> simp [Matrix.det_fin_three, Atab]

/-- **§6 property 1.**  No seed matrix is zero. -/
theorem A_ne_zero (k : Fin 6) : Atab k ≠ 0 := by
  intro h
  have := det_A_ne_zero k
  rw [h] at this
  simp at this

/-- The seeds satisfy the shuffle relations, so `K₃(s_k) ∈ W₃`.  This is §3's
"certified fact 3" for the actual seed list, obtained from the proved word
identity rather than asserted. -/
theorem seed_K₃_mem_W₃ (k : Fin 6) (a b c : Letter) :
    (seed k).K₃ a b c + (seed k).K₃ b a c + (seed k).K₃ b c a = 0 :=
  BalancedPair.K₃_shuffle_zero _ (seed_K₂_zero k) a b c

end Psc
