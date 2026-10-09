import LanglandsOracles.Excursion

/-!
# Excursion data ⇒ 2-dimensional pseudocharacter, proved from the excursion relations.

Let T : Ĝ → k be a class function (T(xy) = T(yx)) satisfying the Frobenius–Procesi identity of
2×2 matrices on Ĝ,
   T(x)T(y)T(z) + T(xyz) + T(xzy) = T(xy)T(z) + T(xz)T(y) + T(yz)T(x)
(for Ĝ = GL₂(R) and T = trace this is a polynomial identity; `procesi_GL2_F3` checks it on GL₂(𝔽₃)),
and f_T(x₀, x₁) = T(x₀ x₁⁻¹) its Hecke function.  For *any* excursion data D satisfying (E1)–(E3),
        χ(γ) := Θ_{Bool}(f_T)(γ, 1)
satisfies the same identity on Γ: it is a 2-dimensional pseudocharacter in the sense of Taylor,
with χ(1) = T(1) by (E0) and χ(γγ') = χ(γ'γ).  This is the second step of V. Lafforgue's
"excursion data ⇒ Ĝ-pseudocharacter ⇒ semisimple parameter" for Ĝ = GL₂.

Proof.  Fix γ₁, γ₂, γ₃ and put q = (1, γ₁, γ₂, γ₃) on the index set Idx = {o, a, b, c}.  Every
f ∈ 𝒪(Ĝ\Ĝ^Idx/Ĝ) that is a function Φ of the differences h_i = g_i g_o⁻¹ with Φ conjugation-invariant
is LR-invariant (`lrInvariant_ofRel`).  (E1) and (E3) express each of the six terms of the identity
as Θ_Idx of such an f (`theta_t1`, `theta_t2`, `theta_t3`: T(h_i), T(h_i h_j), T(h_i h_j h_l)); (E2)
assembles the two sides into Θ_Idx(F_L)(q) and Θ_Idx(F_R)(q), and F_L = F_R pointwise by the
identity on Ĝ at (h_a, h_b, h_c).
-/
set_option linter.unusedSectionVars false

namespace Oracles

/-- Index set for a base point and three Galois elements: o ↦ 1, a ↦ γ₁, b ↦ γ₂, c ↦ γ₃. -/
inductive Idx | o | a | b | c

/-- (1, γ₁, γ₂, γ₃). -/
def quad {Γ : Type} (gΓ : Grp Γ) (γ₁ γ₂ γ₃ : Γ) : Idx → Γ
  | .o => gΓ.one | .a => γ₁ | .b => γ₂ | .c => γ₃

/-- Bool → Idx, true ↦ i, false ↦ o: the pair (γ_i, 1) inside q. -/
def sel (i : Idx) : Bool → Idx
  | true => i | false => .o

/-- (γ_i, 1) ⊔ (γ_j, 1) ⊔ (1, 1) inside q. -/
def sel₂ (i j : Idx) : Bool ⊕ Bool ⊕ Bool → Idx
  | .inl b => sel i b | .inr (.inl b) => sel j b | .inr (.inr _) => .o

/-- ((γ_i,1) ⊔ (γ_l,1) ⊔ 1) ⊔ ((γ_j,1) ⊔ 1 ⊔ 1) ⊔ 1 inside q: the shape of a doubly iterated (E3). -/
def sel₃ (i j l : Idx) : (Bool ⊕ Bool ⊕ Bool) ⊕ (Bool ⊕ Bool ⊕ Bool) ⊕ (Bool ⊕ Bool ⊕ Bool) → Idx
  | .inl s => sel₂ i l s | .inr (.inl s) => sel₂ j .o s | .inr (.inr _) => .o

section GL2

variable {Γ Ĝ k : Type} {gΓ : Grp Γ} {gĜ : Grp Ĝ} [Mul k] [Add k]

/-- The differences h_i = g_i g_o⁻¹. -/
def rel (g : Grp Ĝ) (x : Idx → Ĝ) (i : Idx) : Ĝ := g.mul (x i) (g.inv (x .o))

/-- Functions of the differences: g ↦ Φ(h). -/
def ofRel (g : Grp Ĝ) (Φ : (Idx → Ĝ) → k) : (Idx → Ĝ) → k := fun x => Φ (rel g x)

def ConjInvariant (g : Grp Ĝ) (Φ : (Idx → Ĝ) → k) : Prop :=
  ∀ (h : Ĝ) (x : Idx → Ĝ), Φ (fun i => g.mul (g.mul h (x i)) (g.inv h)) = Φ x

theorem lrInvariant_ofRel (Φ : (Idx → Ĝ) → k) (hΦ : ConjInvariant gĜ Φ) :
    LRInvariant gĜ (ofRel gĜ Φ) := by
  intro h h' x
  unfold ofRel
  have : rel gĜ (fun i => gĜ.mul (gĜ.mul h (x i)) h')
      = fun i => gĜ.mul (gĜ.mul h (rel gĜ x i)) (gĜ.inv h) := by
    funext i
    exact gĜ.conj_of_lr h h' (x i) (x .o)
  rw [this]
  exact hΦ h _

theorem conjInvariant_mul {Φ Ψ : (Idx → Ĝ) → k} (hΦ : ConjInvariant gĜ Φ) (hΨ : ConjInvariant gĜ Ψ) :
    ConjInvariant gĜ (fun h => Φ h * Ψ h) := by
  intro h x
  show Φ _ * Ψ _ = Φ x * Ψ x
  rw [hΦ, hΨ]

/-- The trace monomials T(h_i), T(h_i h_j), T(h_i h_j h_l). -/
def t1 (T : Ĝ → k) (i : Idx) : (Idx → Ĝ) → k := fun h => T (h i)
def t2 (g : Grp Ĝ) (T : Ĝ → k) (i j : Idx) : (Idx → Ĝ) → k := fun h => T (g.mul (h i) (h j))
def t3 (g : Grp Ĝ) (T : Ĝ → k) (i j l : Idx) : (Idx → Ĝ) → k := fun h => T (g.mul (g.mul (h i) (h j)) (h l))

variable (T : Ĝ → k) (hT : ∀ x y, T (gĜ.mul x y) = T (gĜ.mul y x))
include hT

theorem class_of_comm (h x : Ĝ) : T (gĜ.mul (gĜ.mul h x) (gĜ.inv h)) = T x := by
  rw [hT, ← gĜ.mul_assoc, gĜ.inv_mul, gĜ.one_mul]

theorem conj_t1 (i : Idx) : ConjInvariant gĜ (t1 T i) := fun h x => class_of_comm T hT h (x i)

theorem conj_t2 (i j : Idx) : ConjInvariant gĜ (t2 gĜ T i j) := by
  intro h x
  show T (gĜ.mul (gĜ.mul (gĜ.mul h (x i)) (gĜ.inv h)) (gĜ.mul (gĜ.mul h (x j)) (gĜ.inv h)))
    = T (gĜ.mul (x i) (x j))
  rw [gĜ.conj_mul, class_of_comm T hT]

theorem conj_t3 (i j l : Idx) : ConjInvariant gĜ (t3 gĜ T i j l) := by
  intro h x
  show T (gĜ.mul (gĜ.mul (gĜ.mul (gĜ.mul h (x i)) (gĜ.inv h)) (gĜ.mul (gĜ.mul h (x j)) (gĜ.inv h)))
      (gĜ.mul (gĜ.mul h (x l)) (gĜ.inv h))) = T (gĜ.mul (gĜ.mul (x i) (x j)) (x l))
  rw [gĜ.conj_mul, gĜ.conj_mul, class_of_comm T hT]

theorem heckeFun_lr_of_comm : LRInvariant gĜ (heckeFun gĜ T) :=
  lrInvariant_heckeFun gĜ T (class_of_comm T hT)

/-- The pseudocharacter attached to excursion data: χ(γ) = Θ_{Bool}(f_T)(γ, 1). -/
def exChar (D : ExcursionData gΓ gĜ k) (T : Ĝ → k) (γ : Γ) : k := D.Θ (heckeFun gĜ T) (pair gΓ γ)

variable (D : ExcursionData gΓ gĜ k) (γ₁ γ₂ γ₃ : Γ)

/-- (E1): T(h_i) is the Hecke function at (γ_i, 1). -/
theorem theta_t1 (i : Idx) :
    D.Θ (ofRel gĜ (t1 T i)) (quad gΓ γ₁ γ₂ γ₃) = exChar D T (quad gΓ γ₁ γ₂ γ₃ i) := by
  have e : ofRel gĜ (t1 T i) = pullback (sel i) (heckeFun gĜ T) := rfl
  rw [e, D.functorial _ _ (heckeFun_lr_of_comm T hT)]
  unfold exChar
  congr 1
  funext b
  cases b <;> rfl

/-- The group-side computation behind one (E3). -/
theorem pullback_tilde_hecke (i j : Idx) :
    pullback (sel₂ i j) (tilde gĜ (heckeFun gĜ T)) = ofRel gĜ (t2 gĜ T i j) := by
  funext x
  simp only [pullback, tilde, heckeFun, ofRel, rel, t2, sel₂, sel, gĜ.mul_inv, gĜ.one_mul, gĜ.mul_assoc]

/-- (E3) then (E1): T(h_i h_j) is the Hecke function at (γ_i γ_j, 1). -/
theorem theta_t2 (i j : Idx) :
    D.Θ (ofRel gĜ (t2 gĜ T i j)) (quad gΓ γ₁ γ₂ γ₃)
      = exChar D T (gΓ.mul (quad gΓ γ₁ γ₂ γ₃ i) (quad gΓ γ₁ γ₂ γ₃ j)) := by
  have hf := heckeFun_lr_of_comm T hT
  unfold exChar
  rw [pair_mul, D.compose _ hf]
  have ht : triple gΓ (pair gΓ (quad gΓ γ₁ γ₂ γ₃ i)) (pair gΓ (quad gΓ γ₁ γ₂ γ₃ j))
      = fun s => quad gΓ γ₁ γ₂ γ₃ (sel₂ i j s) := by
    funext s
    rcases s with b | b | b <;> cases b <;> rfl
  rw [ht, ← D.functorial _ _ (lrInvariant_tilde gĜ _ hf), pullback_tilde_hecke T hT]

/-- The group-side computation behind two iterated (E3)s. -/
theorem pullback_tilde_tilde_hecke (i j l : Idx) :
    pullback (sel₃ i j l) (tilde gĜ (tilde gĜ (heckeFun gĜ T))) = ofRel gĜ (t3 gĜ T i j l) := by
  funext x
  simp only [pullback, tilde, heckeFun, ofRel, rel, t3, sel₃, sel₂, sel, gĜ.mul_inv, gĜ.one_mul,
    gĜ.mul_one, gĜ.mul_assoc]

/-- (E3) twice then (E1): T(h_i h_j h_l) is the Hecke function at (γ_i γ_j γ_l, 1). -/
theorem theta_t3 (i j l : Idx) :
    D.Θ (ofRel gĜ (t3 gĜ T i j l)) (quad gΓ γ₁ γ₂ γ₃)
      = exChar D T (gΓ.mul (gΓ.mul (quad gΓ γ₁ γ₂ γ₃ i) (quad gΓ γ₁ γ₂ γ₃ j)) (quad gΓ γ₁ γ₂ γ₃ l)) := by
  have hf := heckeFun_lr_of_comm T hT
  unfold exChar
  rw [pair_mul, D.compose _ hf]
  -- (γ_iγ_j, 1) ⊔ (γ_l, 1) ⊔ 1 = ((γ_i,1) ⊔ (γ_l,1) ⊔ 1) · ((γ_j,1) ⊔ 1 ⊔ 1) pointwise
  have hsplit : triple gΓ (pair gΓ (gΓ.mul (quad gΓ γ₁ γ₂ γ₃ i) (quad gΓ γ₁ γ₂ γ₃ j))) (pair gΓ (quad gΓ γ₁ γ₂ γ₃ l))
      = fun s => gΓ.mul (triple gΓ (pair gΓ (quad gΓ γ₁ γ₂ γ₃ i)) (pair gΓ (quad gΓ γ₁ γ₂ γ₃ l)) s)
          (triple gΓ (pair gΓ (quad gΓ γ₁ γ₂ γ₃ j)) (fun _ => gΓ.one) s) := by
    funext s
    rcases s with b | b | b <;> cases b <;> simp [triple, pair, gΓ.mul_one]
  rw [hsplit, D.compose _ (lrInvariant_tilde gĜ _ hf)]
  have ht : triple gΓ (triple gΓ (pair gΓ (quad gΓ γ₁ γ₂ γ₃ i)) (pair gΓ (quad gΓ γ₁ γ₂ γ₃ l)))
        (triple gΓ (pair gΓ (quad gΓ γ₁ γ₂ γ₃ j)) (fun _ => gΓ.one))
      = fun s => quad gΓ γ₁ γ₂ γ₃ (sel₃ i j l s) := by
    funext s
    rcases s with (b | b | b) | (b | b | b) | (b | b | b) <;> cases b <;> rfl
  rw [ht, ← D.functorial _ _ (lrInvariant_tilde gĜ _ (lrInvariant_tilde gĜ _ hf)),
    pullback_tilde_tilde_hecke T hT]

/-- **Excursion data ⇒ pseudocharacter (rank 2).**  If T satisfies the 2×2 Procesi identity on Ĝ,
then χ = exChar D T satisfies it on Γ, for every excursion datum D. -/
theorem gl2_pseudocharacter
    (hP : ∀ x y z : Ĝ, T x * T y * T z + T (gĜ.mul (gĜ.mul x y) z) + T (gĜ.mul (gĜ.mul x z) y)
      = T (gĜ.mul x y) * T z + T (gĜ.mul x z) * T y + T (gĜ.mul y z) * T x) :
    exChar D T γ₁ * exChar D T γ₂ * exChar D T γ₃
        + exChar D T (gΓ.mul (gΓ.mul γ₁ γ₂) γ₃) + exChar D T (gΓ.mul (gΓ.mul γ₁ γ₃) γ₂)
      = exChar D T (gΓ.mul γ₁ γ₂) * exChar D T γ₃ + exChar D T (gΓ.mul γ₁ γ₃) * exChar D T γ₂
        + exChar D T (gΓ.mul γ₂ γ₃) * exChar D T γ₁ := by
  have ia := lrInvariant_ofRel _ (conj_t1 T hT .a)
  have ib := lrInvariant_ofRel _ (conj_t1 T hT .b)
  have ic := lrInvariant_ofRel _ (conj_t1 T hT .c)
  have iab := lrInvariant_ofRel _ (conj_t2 T hT .a .b)
  have iac := lrInvariant_ofRel _ (conj_t2 T hT .a .c)
  have ibc := lrInvariant_ofRel _ (conj_t2 T hT .b .c)
  have iabc := lrInvariant_ofRel _ (conj_t3 T hT .a .b .c)
  have iacb := lrInvariant_ofRel _ (conj_t3 T hT .a .c .b)
  -- the identity on Ĝ, at (h_a, h_b, h_c), as an equality of functions on Ĝ^Idx
  have key : (fun x => ofRel gĜ (t1 T .a) x * ofRel gĜ (t1 T .b) x * ofRel gĜ (t1 T .c) x
        + ofRel gĜ (t3 gĜ T .a .b .c) x + ofRel gĜ (t3 gĜ T .a .c .b) x)
      = (fun x => ofRel gĜ (t2 gĜ T .a .b) x * ofRel gĜ (t1 T .c) x
        + ofRel gĜ (t2 gĜ T .a .c) x * ofRel gĜ (t1 T .b) x
        + ofRel gĜ (t2 gĜ T .b .c) x * ofRel gĜ (t1 T .a) x) := by
    funext x
    exact hP (rel gĜ x .a) (rel gĜ x .b) (rel gĜ x .c)
  have h := congrArg (fun F => D.Θ F (quad gΓ γ₁ γ₂ γ₃)) key
  -- (E2): split both sides into excursion values of the monomials
  rw [D.map_add _ _ (lrInvariant_add gĜ (lrInvariant_mul gĜ (lrInvariant_mul gĜ ia ib) ic) iabc) iacb,
    D.map_add _ _ (lrInvariant_mul gĜ (lrInvariant_mul gĜ ia ib) ic) iabc,
    D.map_mul _ _ (lrInvariant_mul gĜ ia ib) ic, D.map_mul _ _ ia ib,
    D.map_add _ _ (lrInvariant_add gĜ (lrInvariant_mul gĜ iab ic) (lrInvariant_mul gĜ iac ib))
      (lrInvariant_mul gĜ ibc ia),
    D.map_add _ _ (lrInvariant_mul gĜ iab ic) (lrInvariant_mul gĜ iac ib),
    D.map_mul _ _ iab ic, D.map_mul _ _ iac ib, D.map_mul _ _ ibc ia] at h
  -- (E1), (E3): each monomial is χ at the corresponding product
  rw [theta_t1 T hT D γ₁ γ₂ γ₃ .a, theta_t1 T hT D γ₁ γ₂ γ₃ .b, theta_t1 T hT D γ₁ γ₂ γ₃ .c,
    theta_t2 T hT D γ₁ γ₂ γ₃ .a .b, theta_t2 T hT D γ₁ γ₂ γ₃ .a .c, theta_t2 T hT D γ₁ γ₂ γ₃ .b .c,
    theta_t3 T hT D γ₁ γ₂ γ₃ .a .b .c, theta_t3 T hT D γ₁ γ₂ γ₃ .a .c .b] at h
  exact h

/-- χ(1) = T(1) (= dim for T = trace), by (E0). -/
theorem exChar_one : exChar D T gΓ.one = T gĜ.one := by
  unfold exChar
  rw [pair_one, D.map_unit _ (heckeFun_lr_of_comm T hT)]
  unfold heckeFun
  rw [gĜ.inv_one, gĜ.mul_one]

/-- χ(γγ') = χ(γ'γ): the pseudocharacter is central. -/
theorem exChar_comm (γ γ' : Γ) : exChar D T (gΓ.mul γ γ') = exChar D T (gΓ.mul γ' γ) := by
  have e : ofRel gĜ (t2 gĜ T .a .b) = ofRel gĜ (t2 gĜ T .b .a) := by
    funext x
    exact hT _ _
  have h1 := theta_t2 T hT D γ γ' gΓ.one .a .b
  have h2 := theta_t2 T hT D γ γ' gΓ.one .b .a
  rw [e] at h1
  exact h1.symm.trans h2

end GL2

end Oracles
