import LanglandsOracles.Excursion

/-!
# Lafforgue's converse for GL₁, proved from the excursion relations.

Let φ : Ĝ → k be multiplicative into a commutative monoid k (for Ĝ = GL₁ = k^×, φ = id), and
f_φ(x₀, x₁) = φ(x₀ x₁⁻¹) the Hecke function of φ.  For *any* excursion data D satisfying (E0)–(E3),
        χ(γ) := Θ_{Bool}(f_φ)(γ, 1)
is a character: χ(γγ') = χ(γ)χ(γ') and χ(1) = 1.  Proof: (E3) turns χ(γγ') into Θ(f̃)(γ, γ', 1);
f̃ factors pointwise as (f_φ ∘ pr₁)·(f_φ ∘ pr₂)·(f_φ^swap ∘ pr₃) because φ is multiplicative and k is
commutative; (E2) and (E1) split it into χ(γ)·χ(γ')·Θ(f_φ^swap)(1, 1), and (E0) evaluates the last
factor to φ(1) = 1.  So for GL₁ the excursion algebra determines the parameter: this is the abelian
case of "excursion data ⇒ Langlands parameter", with no invariant theory needed.
-/
set_option linter.unusedSectionVars false

namespace Oracles

section GL1

variable {Γ Ĝ k : Type} {gΓ : Grp Γ} {gĜ : Grp Ĝ} [Mul k] [Add k] [OfNat k 1]
variable (hassoc : ∀ a b c : k, a * b * c = a * (b * c)) (hcomm : ∀ a b : k, a * b = b * a)
variable (hone : ∀ a : k, 1 * a = a)
variable (φ : Ĝ → k) (hφ : ∀ a b, φ (gĜ.mul a b) = φ a * φ b) (hφ1 : φ gĜ.one = 1)

/-- f_φ^swap(x₀, x₁) = φ(x₁ x₀⁻¹). -/
def heckeSwap (g : Grp Ĝ) (φ : Ĝ → k) : (Bool → Ĝ) → k :=
  fun x => φ (g.mul (x false) (g.inv (x true)))

include hcomm hassoc hone hφ hφ1

theorem phi_inv_mul (a : Ĝ) : φ (gĜ.inv a) * φ a = 1 := by
  rw [← hφ, gĜ.inv_mul, hφ1]

theorem phi_class_function (h x : Ĝ) : φ (gĜ.mul (gĜ.mul h x) (gĜ.inv h)) = φ x := by
  rw [hφ, hφ, hcomm (φ h), hassoc, hcomm (φ h), phi_inv_mul hassoc hcomm hone φ hφ hφ1, hcomm, hone]

theorem heckeFun_lr : LRInvariant gĜ (heckeFun gĜ φ) :=
  lrInvariant_heckeFun gĜ φ (phi_class_function hassoc hcomm hone φ hφ hφ1)

theorem heckeSwap_lr : LRInvariant gĜ (heckeSwap gĜ φ) := by
  intro h h' x
  unfold heckeSwap
  rw [gĜ.conj_of_lr, phi_class_function hassoc hcomm hone φ hφ hφ1]

/-- The pointwise factorisation of f̃ for f = f_φ. -/
theorem tilde_hecke_factors (x : Bool ⊕ Bool ⊕ Bool → Ĝ) :
    tilde gĜ (heckeFun gĜ φ) x
      = pullback Sum.inl (heckeFun gĜ φ) x
        * (pullback (fun b => Sum.inr (Sum.inl b)) (heckeFun gĜ φ) x
          * pullback (fun b => Sum.inr (Sum.inr b)) (heckeSwap gĜ φ) x) := by
  unfold tilde pullback heckeFun heckeSwap
  -- group side: (a c⁻¹ b)(a' c'⁻¹ b')⁻¹ = a · (c⁻¹ · (b · (b'⁻¹ · (c' · a'⁻¹))))
  have grp : ∀ a b c a' b' c' : Ĝ,
      gĜ.mul (gĜ.mul (gĜ.mul a (gĜ.inv c)) b) (gĜ.inv (gĜ.mul (gĜ.mul a' (gĜ.inv c')) b'))
        = gĜ.mul a (gĜ.mul (gĜ.inv c) (gĜ.mul b (gĜ.mul (gĜ.inv b') (gĜ.mul c' (gĜ.inv a'))))) := by
    intro a b c a' b' c'
    simp only [gĜ.inv_mul_rev, gĜ.inv_inv, gĜ.mul_assoc]
  rw [grp]
  simp only [hφ]
  -- k side: a * (c * (b * (b' * (c' * a')))) = (a * a') * ((b * b') * (c' * c))
  haveI : Std.Associative (α := k) (· * ·) := ⟨hassoc⟩
  haveI : Std.Commutative (α := k) (· * ·) := ⟨hcomm⟩
  ac_rfl

/-- The GL₁ converse: χ(γ) = Θ(f_φ)(γ, 1) is multiplicative. -/
theorem gl1_character (D : ExcursionData gΓ gĜ k) (γ γ' : Γ) :
    D.Θ (heckeFun gĜ φ) (pair gΓ (gΓ.mul γ γ'))
      = D.Θ (heckeFun gĜ φ) (pair gΓ γ) * D.Θ (heckeFun gĜ φ) (pair gΓ γ') := by
  have hf := heckeFun_lr hassoc hcomm hone φ hφ hφ1
  have hs := heckeSwap_lr hassoc hcomm hone φ hφ hφ1
  rw [pair_mul, D.compose _ hf]
  have hfac : tilde gĜ (heckeFun gĜ φ)
      = fun x => pullback Sum.inl (heckeFun gĜ φ) x
        * (pullback (fun b => Sum.inr (Sum.inl b)) (heckeFun gĜ φ) x
          * pullback (fun b => Sum.inr (Sum.inr b)) (heckeSwap gĜ φ) x) := by
    funext x
    exact tilde_hecke_factors hassoc hcomm hone φ hφ hφ1 x
  rw [hfac]
  have l1 := lrInvariant_pullback gĜ (Sum.inl : Bool → Bool ⊕ Bool ⊕ Bool) _ hf
  have l2 := lrInvariant_pullback gĜ (fun b : Bool => Sum.inr (Sum.inl b) : Bool → Bool ⊕ Bool ⊕ Bool) _ hf
  have l3 := lrInvariant_pullback gĜ (fun b : Bool => Sum.inr (Sum.inr b) : Bool → Bool ⊕ Bool ⊕ Bool) _ hs
  have l23 : LRInvariant gĜ (fun x : Bool ⊕ Bool ⊕ Bool → Ĝ =>
      pullback (fun b : Bool => (Sum.inr (Sum.inl b) : Bool ⊕ Bool ⊕ Bool)) (heckeFun gĜ φ) x
      * pullback (fun b : Bool => (Sum.inr (Sum.inr b) : Bool ⊕ Bool ⊕ Bool)) (heckeSwap gĜ φ) x) := by
    intro h h' x
    show pullback _ (heckeFun gĜ φ) (fun i => gĜ.mul (gĜ.mul h (x i)) h') * pullback _ (heckeSwap gĜ φ) (fun i => gĜ.mul (gĜ.mul h (x i)) h')
      = pullback _ (heckeFun gĜ φ) x * pullback _ (heckeSwap gĜ φ) x
    rw [l2 h h' x, l3 h h' x]
  rw [D.map_mul _ _ l1 l23, D.map_mul _ _ l2 l3]
  rw [D.functorial _ _ hf, D.functorial _ _ hf, D.functorial _ _ hs]
  -- the three restricted tuples are (γ, 1), (γ', 1) and (1, 1)
  have t1 : (fun i => triple gΓ (pair gΓ γ) (pair gΓ γ') (Sum.inl i)) = pair gΓ γ := rfl
  have t2 : (fun i => triple gΓ (pair gΓ γ) (pair gΓ γ') (Sum.inr (Sum.inl i))) = pair gΓ γ' := rfl
  have t3 : (fun i : Bool => triple gΓ (pair gΓ γ) (pair gΓ γ') (Sum.inr (Sum.inr i))) = fun _ => gΓ.one := rfl
  rw [t1, t2, t3, D.map_unit _ hs]
  have hsw1 : heckeSwap gĜ φ (fun _ => gĜ.one) = 1 := by
    unfold heckeSwap
    rw [gĜ.inv_one, gĜ.mul_one, hφ1]
  rw [hsw1, hcomm _ 1, hone]

/-- χ(1) = 1. -/
theorem gl1_character_one (D : ExcursionData gΓ gĜ k) :
    D.Θ (heckeFun gĜ φ) (pair gΓ gΓ.one) = 1 := by
  have hf := heckeFun_lr hassoc hcomm hone φ hφ hφ1
  rw [pair_one, D.map_unit _ hf]
  unfold heckeFun
  rw [gĜ.inv_one, gĜ.mul_one, hφ1]

end GL1

end Oracles
