/-!
# Commutative semirings, as laws on the ambient `+`, `*`, `0`, `1` (core Lean has no class).

`IsCSR R` is the proposition that the ambient operations on R satisfy the commutative-semiring laws;
no subtraction is assumed, which is all the polynomial identities of §3 (associativity of 2×2
matrix multiplication, tr(xy) = tr(yx), the Frobenius–Procesi identity) need.  Instances: ℕ, ℤ,
and ℤ/n = Fin n for every n ≥ 1 (via `Fin.val` and the modular arithmetic of ℕ); ℤ/n is the field
𝔽_p exactly when n = p is prime, which `IsPrime` records as a decidable class.
-/
namespace Oracles

structure IsCSR (R : Type) [Add R] [Mul R] [OfNat R 0] [OfNat R 1] : Prop where
  add_assoc : ∀ a b c : R, a + b + c = a + (b + c)
  add_comm : ∀ a b : R, a + b = b + a
  zero_add : ∀ a : R, 0 + a = a
  mul_assoc : ∀ a b c : R, a * b * c = a * (b * c)
  mul_comm : ∀ a b : R, a * b = b * a
  one_mul : ∀ a : R, 1 * a = a
  zero_mul : ∀ a : R, 0 * a = 0
  mul_add : ∀ a b c : R, a * (b + c) = a * b + a * c

namespace IsCSR

variable {R : Type} [Add R] [Mul R] [OfNat R 0] [OfNat R 1] (h : IsCSR R)
include h

theorem add_zero (a : R) : a + 0 = a := by rw [h.add_comm, h.zero_add]
theorem mul_one (a : R) : a * 1 = a := by rw [h.mul_comm, h.one_mul]
theorem mul_zero (a : R) : a * 0 = 0 := by rw [h.mul_comm, h.zero_mul]
theorem add_mul (a b c : R) : (a + b) * c = a * c + b * c := by
  rw [h.mul_comm, h.mul_add, h.mul_comm c, h.mul_comm c]

end IsCSR

theorem isCSR_nat : IsCSR Nat where
  add_assoc := Nat.add_assoc
  add_comm := Nat.add_comm
  zero_add := Nat.zero_add
  mul_assoc := Nat.mul_assoc
  mul_comm := Nat.mul_comm
  one_mul := Nat.one_mul
  zero_mul := Nat.zero_mul
  mul_add := Nat.mul_add

theorem isCSR_int : IsCSR Int where
  add_assoc := Int.add_assoc
  add_comm := Int.add_comm
  zero_add := Int.zero_add
  mul_assoc := Int.mul_assoc
  mul_comm := Int.mul_comm
  one_mul := Int.one_mul
  zero_mul := Int.zero_mul
  mul_add := Int.mul_add

/-- Primality, in a form `decide` settles for literals: 2 ≤ p and no d with 2 ≤ d < p divides p.
`Fin p` with its ambient operations is the field 𝔽_p exactly for such p; for composite n it is the
ring ℤ/n (ℤ/4 ≠ 𝔽₄). -/
class IsPrime (p : Nat) : Prop where
  prime : 2 ≤ p ∧ ∀ d, d < p → 2 ≤ d → p % d ≠ 0

instance IsPrime.toNeZero (p : Nat) [hp : IsPrime p] : NeZero p :=
  ⟨fun h => absurd hp.prime.1 (by rw [h]; decide)⟩

instance : IsPrime 2 := ⟨by decide⟩
instance : IsPrime 3 := ⟨by decide⟩
instance : IsPrime 5 := ⟨by decide⟩
instance : IsPrime 7 := ⟨by decide⟩

theorem not_isPrime_four : ¬ IsPrime 4 := fun h => (h.prime.2 2 (by decide) (by decide)) rfl
theorem not_isPrime_one : ¬ IsPrime 1 := fun h => absurd h.prime.1 (by decide)

/-- Inverses exist in ℤ/p for the prime instances (decided); with `isCSR_fin` this is the field
𝔽_p.  The general statement for every `IsPrime p` needs Bézout and is not proved here. -/
theorem fin2_inverses : ∀ a : Fin 2, a ≠ 0 → ∃ b, a * b = 1 := by decide
theorem fin3_inverses : ∀ a : Fin 3, a ≠ 0 → ∃ b, a * b = 1 := by decide
theorem fin5_inverses : ∀ a : Fin 5, a ≠ 0 → ∃ b, a * b = 1 := by decide
theorem fin7_inverses : ∀ a : Fin 7, a ≠ 0 → ∃ b, a * b = 1 := by decide
/-- ℤ/4 is not a field: 2 has no inverse. -/
theorem fin4_not_field : ¬ ∀ a : Fin 4, a ≠ 0 → ∃ b, a * b = 1 := by decide

/-- ℤ/n for every n ≥ 1 (the field 𝔽_p when n = p is prime). -/
theorem isCSR_fin (n : Nat) [NeZero n] : IsCSR (Fin n) where
  add_assoc a b c := Fin.ext (by
    simp only [Fin.val_add]
    rw [Nat.mod_add_mod, Nat.add_mod_mod, Nat.add_assoc])
  add_comm a b := Fin.ext (by simp only [Fin.val_add, Nat.add_comm])
  zero_add := Fin.zero_add
  mul_assoc := Fin.mul_assoc
  mul_comm := Fin.mul_comm
  one_mul := Fin.one_mul
  zero_mul := Fin.zero_mul
  mul_add a b c := Fin.ext (by
    simp only [Fin.val_add, Fin.val_mul]
    rw [Nat.mul_mod, Nat.mod_mod, ← Nat.mul_mod, Nat.mul_add, Nat.add_mod])

end Oracles
