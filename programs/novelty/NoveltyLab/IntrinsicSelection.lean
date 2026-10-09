import Std

/-!
Kernel proofs of the cancellation reduction used by the finite intrinsic
selection oracle. Associativity and right cancellation are explicit
hypotheses; this file does not assume a selected octonion placement.
-/
namespace NoveltyLab.IntrinsicSelection

def RowRelated {M : Type} (mul : M → M → M) (perm : M → Prop)
    (x y : M) : Prop :=
  ∃ p, perm p ∧ y = mul p x

variable {M : Type} {mul : M → M → M} {perm : M → Prop}

/-- Right cancellation removes the full invertible configuration matrix. -/
theorem rowRelated_right_iff
    (assoc : ∀ a b c, mul (mul a b) c = mul a (mul b c))
    (cancel : ∀ a b c, mul a c = mul b c → a = b)
    (a b w : M) :
    RowRelated mul perm (mul a w) (mul b w) ↔ RowRelated mul perm a b := by
  constructor
  · rintro ⟨p, hp, h⟩
    refine ⟨p, hp, ?_⟩
    apply cancel b (mul p a) w
    exact h.trans (assoc p a w).symm
  · rintro ⟨p, hp, h⟩
    refine ⟨p, hp, ?_⟩
    rw [h, assoc]

/-- Global row-quotient descent is exactly the finite intertwining condition.
`w₀` supplies one configuration; the same cancellation law applies to all.
-/
theorem descent_iff_intertwining
    (assoc : ∀ a b c, mul (mul a b) c = mul a (mul b c))
    (cancel : ∀ a b c, mul a c = mul b c → a = b)
    (b w₀ : M) :
    (∀ w p, perm p →
      RowRelated mul perm (mul b w) (mul b (mul p w))) ↔
    (∀ p, perm p → ∃ p', perm p' ∧ mul b p = mul p' b) := by
  constructor
  · intro h p hp
    have hw := h w₀ p hp
    rw [← assoc b p w₀] at hw
    exact (rowRelated_right_iff assoc cancel b (mul b p) w₀).mp hw
  · intro h w p hp
    have hw := (rowRelated_right_iff assoc cancel b (mul b p) w).mpr (h p hp)
    rw [assoc b p w] at hw
    exact hw

/-- An indexed bijection retains all edge multiplicities, including loops. -/
def EdgeMatching {I : Type} (mul : M → M → M) (perm : M → Prop)
    (left right : I → M) : Prop :=
  ∃ σ : I → I,
    (∀ i j, σ i = σ j → i = j) ∧
    (∀ j, ∃ i, σ i = j) ∧
    (∀ i, RowRelated mul perm (left i) (right (σ i)))

/-- The adjacency matching at matrix level is equivalent to the matching
at every full configuration, with exactly the same reindexing bijection. -/
theorem edgeMatching_right_iff {I : Type}
    (assoc : ∀ a b c, mul (mul a b) c = mul a (mul b c))
    (cancel : ∀ a b c, mul a c = mul b c → a = b)
    (left right : I → M) (w : M) :
    EdgeMatching mul perm (fun i => mul (left i) w)
      (fun i => mul (right i) w) ↔ EdgeMatching mul perm left right := by
  constructor
  · rintro ⟨σ, hi, hs, hm⟩
    exact ⟨σ, hi, hs, fun i =>
      (rowRelated_right_iff assoc cancel (left i) (right (σ i)) w).mp (hm i)⟩
  · rintro ⟨σ, hi, hs, hm⟩
    exact ⟨σ, hi, hs, fun i =>
      (rowRelated_right_iff assoc cancel (left i) (right (σ i)) w).mpr (hm i)⟩

/-- Uniqueness plus invariant admissibility forces a symmetry-fixed survivor.
This proves a conditional implication, not existence or uniqueness itself. -/
theorem unique_survivor_fixed {B : Type} (admissible : B → Prop)
    (symmetry : B → B) (selected : B)
    (accepted : admissible selected)
    (preserved : ∀ b, admissible b → admissible (symmetry b))
    (unique : ∀ b, admissible b → b = selected) :
    symmetry selected = selected :=
  unique (symmetry selected) (preserved selected accepted)

end NoveltyLab.IntrinsicSelection
