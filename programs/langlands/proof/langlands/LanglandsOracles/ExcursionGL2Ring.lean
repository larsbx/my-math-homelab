import LanglandsOracles.Pseudocharacter
import LanglandsOracles.ExcursionGL2

/-!
# The rank-2 converse over every commutative semiring: excursion data for Ĝ = GL₂(R) with values
in R are 2-dimensional pseudocharacters Γ → R.

GL₂(R) is taken as the group of pairs (x, y) of 2×2 matrices with xy = yx = 1 (the inverse carried
as a witness, so no determinants or subtraction are needed): multiplication (x,y)(x',y') = (xx', y'y),
inverse (x,y)⁻¹ = (y,x).  The trace of the first component is a class function by `M2.trace_mul_comm`
and satisfies the Procesi identity by `M2.procesi`, so `gl2_pseudocharacter` applies to every
excursion datum.  Instances: R = ℤ/n for every n ≥ 1 (`gl2_Zmod_pseudocharacter`), hence the field
𝔽_p for prime p (`gl2_Fp_pseudocharacter`, gated by `IsPrime p`), and ℤ, ℕ.  This is the setting of Lafforgue's theorem
for GL₂ with k = R (there k = ℚ̄_ℓ; here R may be any commutative semiring, e.g. 𝔽₃ as in the mod-3
instance of 37a1, `ExcursionInstance.lean`).
-/
namespace Oracles

section Ring

variable {R : Type} [Add R] [Mul R] [OfNat R 0] [OfNat R 1]

/-- GL₂(R): matrices with a two-sided inverse witness. -/
def GL2 (R : Type) [Add R] [Mul R] [OfNat R 0] [OfNat R 1] : Type :=
  {p : M2 R × M2 R // M2.mul p.1 p.2 = M2.one ∧ M2.mul p.2 p.1 = M2.one}

variable (h : IsCSR R)
include h

theorem GL2.mul_inv_witness {x y x' y' : M2 R} (hx : M2.mul x y = M2.one) (hx' : M2.mul x' y' = M2.one) :
    M2.mul (M2.mul x x') (M2.mul y' y) = M2.one := by
  rw [M2.mul_assoc h, ← M2.mul_assoc h x', hx', M2.one_mul h, hx]

/-- GL₂(R) as a group. -/
def grpGL2 : Grp (GL2 R) where
  mul p q := ⟨(M2.mul p.1.1 q.1.1, M2.mul q.1.2 p.1.2),
    GL2.mul_inv_witness h p.2.1 q.2.1, GL2.mul_inv_witness h q.2.2 p.2.2⟩
  one := ⟨(M2.one, M2.one), M2.one_mul h _, M2.one_mul h _⟩
  inv p := ⟨(p.1.2, p.1.1), p.2.2, p.2.1⟩
  mul_assoc _ _ _ := Subtype.ext (Prod.ext (M2.mul_assoc h _ _ _) (M2.mul_assoc h _ _ _).symm)
  one_mul _ := Subtype.ext (Prod.ext (M2.one_mul h _) (M2.mul_one h _))
  mul_one _ := Subtype.ext (Prod.ext (M2.mul_one h _) (M2.one_mul h _))
  inv_mul p := Subtype.ext (Prod.ext p.2.2 p.2.2)

/-- The trace on GL₂(R). -/
def traceGL2 (p : GL2 R) : R := M2.trace p.1.1

theorem traceGL2_comm (p q : GL2 R) : traceGL2 ((grpGL2 h).mul p q) = traceGL2 ((grpGL2 h).mul q p) :=
  M2.trace_mul_comm h _ _

theorem procesiGL2 (x y z : GL2 R) :
    traceGL2 x * traceGL2 y * traceGL2 z + traceGL2 ((grpGL2 h).mul ((grpGL2 h).mul x y) z)
        + traceGL2 ((grpGL2 h).mul ((grpGL2 h).mul x z) y)
      = traceGL2 ((grpGL2 h).mul x y) * traceGL2 z + traceGL2 ((grpGL2 h).mul x z) * traceGL2 y
        + traceGL2 ((grpGL2 h).mul y z) * traceGL2 x :=
  M2.procesi h _ _ _

variable {Γ : Type} {gΓ : Grp Γ}

/-- **Every excursion datum for GL₂(R) with values in R is a 2-dimensional pseudocharacter of Γ.** -/
theorem gl2_ring_pseudocharacter (D : ExcursionData gΓ (grpGL2 h) R) (γ₁ γ₂ γ₃ : Γ) :
    exChar D traceGL2 γ₁ * exChar D traceGL2 γ₂ * exChar D traceGL2 γ₃
        + exChar D traceGL2 (gΓ.mul (gΓ.mul γ₁ γ₂) γ₃) + exChar D traceGL2 (gΓ.mul (gΓ.mul γ₁ γ₃) γ₂)
      = exChar D traceGL2 (gΓ.mul γ₁ γ₂) * exChar D traceGL2 γ₃
        + exChar D traceGL2 (gΓ.mul γ₁ γ₃) * exChar D traceGL2 γ₂
        + exChar D traceGL2 (gΓ.mul γ₂ γ₃) * exChar D traceGL2 γ₁ :=
  gl2_pseudocharacter traceGL2 (traceGL2_comm h) D γ₁ γ₂ γ₃ (procesiGL2 h)

/-- χ(1) = tr(1) = 1 + 1: the pseudocharacter has dimension 2. -/
theorem gl2_ring_pseudocharacter_one (D : ExcursionData gΓ (grpGL2 h) R) :
    exChar D traceGL2 gΓ.one = 1 + 1 :=
  exChar_one traceGL2 (traceGL2_comm h) D

theorem gl2_ring_pseudocharacter_comm (D : ExcursionData gΓ (grpGL2 h) R) (γ γ' : Γ) :
    exChar D traceGL2 (gΓ.mul γ γ') = exChar D traceGL2 (gΓ.mul γ' γ) :=
  exChar_comm traceGL2 (traceGL2_comm h) D γ γ'

end Ring

/-- The case Ĝ = GL₂(ℤ/n), k = ℤ/n, for every n ≥ 1 (a ring, not a field, when n is composite). -/
theorem gl2_Zmod_pseudocharacter (n : Nat) [NeZero n] {Γ : Type} {gΓ : Grp Γ}
    (D : ExcursionData gΓ (grpGL2 (isCSR_fin n)) (Fin n)) (γ₁ γ₂ γ₃ : Γ) :
    exChar D traceGL2 γ₁ * exChar D traceGL2 γ₂ * exChar D traceGL2 γ₃
        + exChar D traceGL2 (gΓ.mul (gΓ.mul γ₁ γ₂) γ₃) + exChar D traceGL2 (gΓ.mul (gΓ.mul γ₁ γ₃) γ₂)
      = exChar D traceGL2 (gΓ.mul γ₁ γ₂) * exChar D traceGL2 γ₃
        + exChar D traceGL2 (gΓ.mul γ₁ γ₃) * exChar D traceGL2 γ₂
        + exChar D traceGL2 (gΓ.mul γ₂ γ₃) * exChar D traceGL2 γ₁ :=
  gl2_ring_pseudocharacter (isCSR_fin n) D γ₁ γ₂ γ₃

/-- The finite-field case Ĝ = GL₂(𝔽_p), k = 𝔽_p, for prime p (the mod-ℓ parameters of Branch 1):
the primality hypothesis is what makes `Fin p` the field 𝔽_p rather than the ring ℤ/p. -/
theorem gl2_Fp_pseudocharacter (p : Nat) [IsPrime p] {Γ : Type} {gΓ : Grp Γ}
    (D : ExcursionData gΓ (grpGL2 (isCSR_fin p)) (Fin p)) (γ₁ γ₂ γ₃ : Γ) :
    exChar D traceGL2 γ₁ * exChar D traceGL2 γ₂ * exChar D traceGL2 γ₃
        + exChar D traceGL2 (gΓ.mul (gΓ.mul γ₁ γ₂) γ₃) + exChar D traceGL2 (gΓ.mul (gΓ.mul γ₁ γ₃) γ₂)
      = exChar D traceGL2 (gΓ.mul γ₁ γ₂) * exChar D traceGL2 γ₃
        + exChar D traceGL2 (gΓ.mul γ₁ γ₃) * exChar D traceGL2 γ₂
        + exChar D traceGL2 (gΓ.mul γ₂ γ₃) * exChar D traceGL2 γ₁ :=
  gl2_Zmod_pseudocharacter p D γ₁ γ₂ γ₃

end Oracles
