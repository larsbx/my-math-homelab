import LanglandsOracles.Generation
import LanglandsOracles.Data

/-!
# The image of ρ̄₂ for the fifteen Cremona curves of prime level: S₃ twelve times, C₂ three times.

GL₂(𝔽₂) = S₃ acts on E[2] ∖ {O} = the three roots of the 2-division polynomial
ψ₂(x) = 4x³ + b₂x² + 2b₄x + b₆.  The exported data (`galoisMod2Data`, Python) give for each
curve its a-invariants, the rational roots of ψ₂, and Frobenius witnesses ρ̄₂(Frob_p) computed on
a basis of E[2] (hence ρ̄₂(Frob_p) up to conjugacy).  Kernel (`mod2_data_certified`), for every
curve: each witness has trace a_p and determinant p mod 2 with a_p from Lean's own point count of
the Weierstrass model; the S₃ curves have an order-3 and an order-2 witness; the C₂ curves
(17a1, 73a1, 89b1) have an order-2 witness and their listed rational root is a root of ψ₂
(a rational 2-torsion point, fixed by the image).

Group theory, PROVED from kernel facts: `generated_by_ord3_ord2` — a multiplicatively closed
subset of GL₂(𝔽₂) meeting the order-3 and order-2 classes is all of GL₂(𝔽₂); `image_C2` — a
multiplicatively closed subset fixing a nonzero vector v and containing an order-2 element is
exactly the stabiliser of v (two elements).  So the image of ρ̄₂ is S₃ for the twelve and C₂ for
the three, with the identification "exported matrix = ρ̄₂(Frob_p) up to conjugacy" and "a rational
2-torsion point is fixed by the image" as the only imported inputs.
-/
namespace Oracles

namespace Mat2

def invariants2 (x : Mat2 2) : Fin 2 × Fin 2 × Bool := (x.trace, x.det, x == M2.one)

/-- Order 3: charpoly x² + x + 1. -/
def ord3 (x : Mat2 2) : Bool := decide (invariants2 x = (1, 1, false))

/-- Order 2: non-identity with charpoly (x + 1)². -/
def ord2 (x : Mat2 2) : Bool := decide (invariants2 x = (0, 1, false))

theorem mem_gl_of_ord3 {g : Mat2 2} (hg : ord3 g = true) : g ∈ gl 2 := by
  have hd : g.det = 1 := (Prod.ext_iff.mp (Prod.ext_iff.mp (of_decide_eq_true hg)).2).1
  exact mem_gl g (by rw [hd]; decide)

theorem mem_gl_of_ord2 {g : Mat2 2} (hg : ord2 g = true) : g ∈ gl 2 := by
  have hd : g.det = 1 := (Prod.ext_iff.mp (Prod.ext_iff.mp (of_decide_eq_true hg)).2).1
  exact mem_gl g (by rw [hd]; decide)

/-- Every (order-3, order-2) pair generates GL₂(𝔽₂) = S₃: 2 × 3 closures, kernel. -/
theorem pairs_generate2 :
    ((gl 2).filter ord3).all (fun g => ((gl 2).filter ord2).all fun h =>
      (gl 2).all fun x => (generatedIdx 2 [encode g, encode h]).testBit (encode x)) = true := by
  decide +kernel

theorem generated_by_ord3_ord2 (H : List (Mat2 2)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H)
    {g h : Mat2 2} (hg : g ∈ H) (hh : h ∈ H) (h3 : ord3 g = true) (h2 : ord2 h = true) :
    ∀ x ∈ gl 2, x ∈ H :=
  generated_of_pairs 2 ord3 ord2 (fun _ => mem_gl_of_ord3) (fun _ => mem_gl_of_ord2) pairs_generate2 H hmul hg hh h3 h2

/-- The action on 𝔽₂². -/
def apply (g : Mat2 2) (v : Fin 2 × Fin 2) : Fin 2 × Fin 2 := (g.a * v.1 + g.b * v.2, g.c * v.1 + g.d * v.2)

def nonzero : List (Fin 2 × Fin 2) := [(1, 0), (0, 1), (1, 1)]

def stab (v : Fin 2 × Fin 2) : List (Mat2 2) := (gl 2).filter fun g => apply g v == v

/-- An order-2 element fixing v generates the stabiliser of v (kernel: 3 vectors × 3 elements). -/
theorem stab_generated :
    nonzero.all (fun v => ((gl 2).filter ord2).all fun h =>
      !(apply h v == v) || (stab v).all fun x => (generatedIdx 2 [encode h]).testBit (encode x)) = true := by
  decide +kernel

/-- A multiplicatively closed H ⊆ GL₂(𝔽₂) fixing v ≠ 0 and containing an order-2 element is Stab(v). -/
theorem image_C2 {v : Fin 2 × Fin 2} (hv : v ∈ nonzero) (H : List (Mat2 2))
    (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) (hH : ∀ x ∈ H, x ∈ gl 2) (hfix : ∀ x ∈ H, apply x v = v)
    {h : Mat2 2} (hh : h ∈ H) (h2 : ord2 h = true) : ∀ x, x ∈ H ↔ x ∈ stab v := by
  intro x
  constructor
  · intro hx
    exact List.mem_filter.mpr ⟨hH x hx, beq_iff_eq.mpr (hfix x hx)⟩
  · intro hx
    have hh' : h ∈ (gl 2).filter ord2 := List.mem_filter.mpr ⟨mem_gl_of_ord2 h2, h2⟩
    have := List.all_eq_true.mp (List.all_eq_true.mp stab_generated v hv) h hh'
    rw [beq_iff_eq.mpr (hfix h hh), Bool.not_true, Bool.false_or] at this
    have hx' := List.all_eq_true.mp this x hx
    have hgens : ∀ i ∈ [encode h], Codes H i := by
      intro i hi
      rcases List.mem_cons.mp hi with rfl | hi
      · exact ⟨h, hh, rfl⟩
      exact absurd hi List.not_mem_nil
    have hm : ∀ y ∈ H, ∀ i ∈ [encode h], ∃ z ∈ H, mulIdx 2 (encode y) i = encode z := by
      intro y hy i hi
      obtain ⟨w, hw, rfl⟩ := hgens i hi
      exact ⟨M2.mul y w, hmul y hy w hw, by simp only [mulIdx, decode_encode]⟩
    exact generatedIdx_mem H _ hgens hm x hx'

theorem stab_length (v : Fin 2 × Fin 2) (hv : v ∈ nonzero) : (stab v).length = 2 := by
  have : nonzero.all (fun v => (stab v).length == 2) = true := by decide +kernel
  exact beq_iff_eq.mp (List.all_eq_true.mp this v hv)

end Mat2

/-- #E(𝔽_p) for a general Weierstrass model [a₁, a₂, a₃, a₄, a₆], by brute force. -/
def pointCountGeneral (a : List Int) (p : Nat) : Int :=
  let a1 := a[0]!; let a2 := a[1]!; let a3 := a[2]!; let a4 := a[3]!; let a6 := a[4]!
  1 + ((List.range p).foldl (fun (acc : Nat) (x : Nat) =>
    let xi : Int := x
    acc + ((List.range p).filter (fun (y : Nat) =>
      let yi : Int := y
      (yi * yi + a1 * xi * yi + a3 * yi - (xi ^ 3 + a2 * xi * xi + a4 * xi + a6)) % (p : Int) == 0)).length) 0 : Nat)

def apGeneral (a : List Int) (p : Nat) : Int := (p : Int) + 1 - pointCountGeneral a p

def ofList2 (m : List Nat) : Mat2 2 :=
  let f : Nat → Fin 2 := fun k => ⟨k % 2, Nat.mod_lt k (by decide)⟩
  ⟨f m[0]!, f m[1]!, f m[2]!, f m[3]!⟩

/-- ψ₂(num/den)·den³ = 4n³ + b₂n²d + 2b₄nd² + b₆d³. -/
def psi2AtRational (a : List Int) (r : Int × Int) : Int :=
  let a1 := a[0]!; let a2 := a[1]!; let a3 := a[2]!; let a4 := a[3]!; let a6 := a[4]!
  let b2 := a1 * a1 + 4 * a2; let b4 := 2 * a4 + a1 * a3; let b6 := a3 * a3 + 4 * a6
  let n := r.1; let d := r.2
  4 * n ^ 3 + b2 * n ^ 2 * d + 2 * b4 * n * d ^ 2 + b6 * d ^ 3

def hasWitness (e : String × List Int × Nat × List (Int × Int) × List (Nat × List Nat)) (P : Mat2 2 → Bool) : Bool :=
  e.2.2.2.2.any fun w => P (ofList2 w.2)

/-- Per curve: witnesses have (tr, det) = (a_p, p) mod 2 with Lean's point counts; S₃ curves carry an
order-3 and an order-2 witness; C₂ curves carry an order-2 witness and a rational root of ψ₂. -/
def mod2Certified (e : String × List Int × Nat × List (Int × Int) × List (Nat × List Nat)) : Bool :=
  let a := e.2.1
  e.2.2.2.2.all (fun w =>
    let m := ofList2 w.2
    (m.trace.val : Int) == (apGeneral a w.1 % 2 + 2) % 2 && (m.det.val : Int) == (w.1 : Int) % 2) &&
  (match e.2.2.1 with
   | 0 => hasWitness e Mat2.ord3 && hasWitness e Mat2.ord2 && e.2.2.2.1.isEmpty
   | 1 => hasWitness e Mat2.ord2 && !hasWitness e Mat2.ord3 && e.2.2.2.1.length == 1
            && e.2.2.2.1.all fun r => psi2AtRational a r == 0
   | _ => false)

theorem mod2_data_certified : galoisMod2Data.all mod2Certified = true := by decide +kernel

theorem mod2_types : galoisMod2Data.map (fun e => e.2.2.1) = [0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0] := by
  decide +kernel

/-- Twelve S₃ curves: the Frobenius witnesses meet the order-3 and order-2 classes, so
`generated_by_ord3_ord2` makes the image all of GL₂(𝔽₂). -/
theorem mod2_image_S3 (e : String × List Int × Nat × List (Int × Int) × List (Nat × List Nat))
    (he : e ∈ galoisMod2Data) (h0 : e.2.2.1 = 0) :
    hasWitness e Mat2.ord3 = true ∧ hasWitness e Mat2.ord2 = true := by
  have h := List.all_eq_true.mp mod2_data_certified e he
  unfold mod2Certified at h
  rw [h0] at h
  have h' := (Bool.and_eq_true _ _ |>.mp h).2
  exact ⟨(Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp h').1).1,
    (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp h').1).2⟩

/-- Three C₂ curves: a rational 2-torsion x-coordinate (so the image fixes a nonzero vector of E[2])
and an order-2 witness, so `image_C2` makes the image the two-element stabiliser. -/
theorem mod2_image_C2 (e : String × List Int × Nat × List (Int × Int) × List (Nat × List Nat))
    (he : e ∈ galoisMod2Data) (h1 : e.2.2.1 = 1) :
    hasWitness e Mat2.ord2 = true ∧ (∀ r ∈ e.2.2.2.1, psi2AtRational e.2.1 r = 0) ∧ e.2.2.2.1.length = 1 := by
  have h := List.all_eq_true.mp mod2_data_certified e he
  unfold mod2Certified at h
  rw [h1] at h
  have h' := (Bool.and_eq_true _ _ |>.mp h).2
  have h2 := (Bool.and_eq_true _ _ |>.mp h').1
  have h3 := (Bool.and_eq_true _ _ |>.mp h').2
  refine ⟨(Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp h2).1).1, ?_,
    beq_iff_eq.mp (Bool.and_eq_true _ _ |>.mp h2).2⟩
  intro r hr
  exact beq_iff_eq.mp (List.all_eq_true.mp h3 r hr)

end Oracles
