import LanglandsOracles.Generation
import LanglandsOracles.Data

/-!
# The image of ρ̄_{37a1,3} is all of GL₂(𝔽₃): a generation certificate.

The exported Frobenius matrices (`galoisMod3Data`, computed by Python on a basis of 37a1[3] over
𝔽_{p^k}) are ρ̄(Frob_p) up to a choice of basis, i.e. up to conjugacy in GL₂(𝔽₃).  The invariants
(trace, det, scalar?) are conjugation-invariant, and

  ρ̄(Frob_5) has (tr, det) = (1, 2): order 8  (charpoly x² − x − 1, irreducible over 𝔽₃);
  ρ̄(Frob_7) has (tr, det) = (2, 1), non-scalar: unipotent, order 3.

`pairs_generate` (kernel): for *every* g of order 8 and *every* non-scalar unipotent h in GL₂(𝔽₃),
the multiplicative closure of {g, h} is all 48 elements (96 pairs, breadth-first closure on
base-3 indices with a bitmask of seen elements).
Hence any multiplicatively closed subset of GL₂(𝔽₃) meeting both classes is the whole group
(`generated_by_ord8_unip`), and the image of ρ̄_{37a1,3} is full (`mod3_image_37a1_full`) — the
classical fact that 37a1 has surjective mod-3 representation, here as a kernel-checked certificate
with the Frobenius classes as the only imported input.  Since Gal(ℚ(E[3])/ℚ) ≅ GL₂(𝔽₃), the mod-3
excursion data of 37a1 are `ExcursionData.ofHom` of an isomorphism, and `gl2_Fp_pseudocharacter`
(p = 3) applies with χ(Frob_p) = a_p mod 3.
-/
namespace Oracles

namespace Mat2

/-- Conjugation invariants: (trace, det, is scalar 1). -/
def invariants (x : Mat2 3) : Fin 3 × Fin 3 × Bool := (x.trace, x.det, x == M2.one)

/-- Order 8: det = −1 and trace = ±1 (charpoly x² ∓ x − 1, irreducible; eigenvalues primitive 8th roots). -/
def ord8 (x : Mat2 3) : Bool := decide (invariants x = (1, 2, false)) || decide (invariants x = (2, 2, false))

/-- Non-scalar unipotent: charpoly (x − 1)², x ≠ 1; order 3. -/
def unip (x : Mat2 3) : Bool := decide (invariants x = (2, 1, false))

theorem mem_gl_of_ord8 {g : Mat2 3} (hg : ord8 g = true) : g ∈ gl 3 := by
  unfold ord8 at hg
  rcases Bool.or_eq_true _ _ |>.mp hg with h | h <;>
  · have h' := of_decide_eq_true h
    have hd : g.det = 2 := (Prod.ext_iff.mp (Prod.ext_iff.mp h').2).1
    exact mem_gl g (by rw [hd]; decide)

theorem mem_gl_of_unip {g : Mat2 3} (hg : unip g = true) : g ∈ gl 3 := by
  have h' := of_decide_eq_true hg
  have hd : g.det = 1 := (Prod.ext_iff.mp (Prod.ext_iff.mp h').2).1
  exact mem_gl g (by rw [hd]; decide)

/-- Every (order-8, non-scalar unipotent) pair generates GL₂(𝔽₃): 12 × 8 closures, kernel. -/
theorem pairs_generate :
    ((gl 3).filter ord8).all (fun g => ((gl 3).filter unip).all fun h =>
      (gl 3).all fun x => (generatedIdx 3 [encode g, encode h]).testBit (encode x)) = true := by
  decide +kernel

/-- A multiplicatively closed subset of GL₂(𝔽₃) containing an element of order 8 and a non-scalar
unipotent is all of GL₂(𝔽₃). -/
theorem generated_by_ord8_unip (H : List (Mat2 3)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H)
    {g h : Mat2 3} (hg : g ∈ H) (hh : h ∈ H) (h8 : ord8 g = true) (h3 : unip h = true) :
    ∀ x ∈ gl 3, x ∈ H :=
  generated_of_pairs 3 ord8 unip (fun _ => mem_gl_of_ord8) (fun _ => mem_gl_of_unip) pairs_generate H hmul hg hh h8 h3

end Mat2

/-- The exported ρ̄_3(Frob_p) as an element of `Mat2 3`. -/
def frobMat3 (p : Nat) : Option (Mat2 3) :=
  (galoisMod3Data.find? (fun e => e.1 == p)).map fun e =>
    let f : Nat → Fin 3 := fun k => ⟨k % 3, Nat.mod_lt k (by decide)⟩
    ⟨f e.2[0]!, f e.2[1]!, f e.2[2]!, f e.2[3]!⟩

theorem frob5_ord8 : (frobMat3 5).map Mat2.ord8 = some true := by decide +kernel
theorem frob7_unip : (frobMat3 7).map Mat2.unip = some true := by decide +kernel

/-- **ρ̄_{37a1,3} is surjective.**  Let H ⊆ GL₂(𝔽₃) be closed under multiplication (the image of a
group homomorphism) and contain elements g, h with the conjugation invariants of the exported
ρ̄(Frob_5), ρ̄(Frob_7).  Then H ⊇ GL₂(𝔽₃). -/
theorem mod3_image_37a1_full (H : List (Mat2 3)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H)
    {F5 F7 g h : Mat2 3} (h5 : frobMat3 5 = some F5) (h7 : frobMat3 7 = some F7)
    (hg : g ∈ H) (hh : h ∈ H)
    (hg5 : Mat2.invariants g = Mat2.invariants F5) (hh7 : Mat2.invariants h = Mat2.invariants F7) :
    ∀ x ∈ Mat2.gl 3, x ∈ H := by
  have e5 : Mat2.ord8 F5 = true := by
    have := frob5_ord8
    rw [h5] at this
    exact Option.some.inj this
  have e7 : Mat2.unip F7 = true := by
    have := frob7_unip
    rw [h7] at this
    exact Option.some.inj this
  have h8 : Mat2.ord8 g = true := by unfold Mat2.ord8; rw [hg5]; exact e5
  have h3 : Mat2.unip h = true := by unfold Mat2.unip; rw [hh7]; exact e7
  exact Mat2.generated_by_ord8_unip H hmul hg hh h8 h3

end Oracles
