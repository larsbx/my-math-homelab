/-!
# V. Lafforgue's excursion relations, abstractly (core Lean, no Mathlib).

Excursion operators S_{I, f, (γ_i)_{i ∈ I}} are indexed by a finite set I, a function
f ∈ O(Ĝ \ Ĝ^I / Ĝ) (invariant under left and right diagonal multiplication) and γ ∈ Γ^I.
They generate a commutative algebra B acting on cuspidal automorphic forms; a character of B is
"excursion data" with values in a commutative ring k.  The relations (Lafforgue, Chtoucas pour
les groupes réductifs, §10; Introduction to chtoucas, Prop. 3.x) are:

  (E1)  S_{J, f^ζ, (γ_j)} = S_{I, f, (γ_{ζ(i)})}                       for ζ : I → J, f^ζ(x) = f(x ∘ ζ);
  (E2)  f ↦ S_{I, f, (γ_i)} is a unital algebra homomorphism (constants map to constants);
  (E3)  S_{I, f, (γ_i γ'_i)} = S_{I ⊔ I ⊔ I, f̃, (γ_i) ⊔ (γ'_i) ⊔ (1)}   with f̃(x ⊔ x' ⊔ x'') = f(x_i x''_i^{-1} x'_i);
  (E0)  S_{I, f, (1)} = f(1, …, 1)                                      (trivial Galois elements).

Galois side ⇒ excursion data: a homomorphism ρ : Γ → Ĝ gives Θ_I(f)(γ) = f(ρ ∘ γ), and (E1)–(E3)
hold (`ExcursionData.ofHom`).  The unramified Hecke operator for a representation V of Ĝ is the
excursion operator of f_V(g_0, g_1) = χ_V(g_0 g_1^{-1}) at (Frob_v, 1), and on ρ-data its value
is χ_V(ρ(Frob_v)) (`hecke_eq_character`).  The converse (excursion data ⇒ Ĝ-pseudocharacter ⇒
semisimple parameter) is Lafforgue's theorem and is not formalised here.
-/
namespace Oracles

/-- A group structure (core Lean has no `Group` class). -/
structure Grp (G : Type) where
  mul : G → G → G
  one : G
  inv : G → G
  mul_assoc : ∀ a b c, mul (mul a b) c = mul a (mul b c)
  one_mul : ∀ a, mul one a = a
  mul_one : ∀ a, mul a one = a
  inv_mul : ∀ a, mul (inv a) a = one

namespace Grp

variable {G : Type} (g : Grp G)

theorem mul_inv (a : G) : g.mul a (g.inv a) = g.one := by
  have h1 : g.mul (g.inv (g.inv a)) (g.inv a) = g.one := g.inv_mul _
  calc g.mul a (g.inv a) = g.mul g.one (g.mul a (g.inv a)) := (g.one_mul _).symm
    _ = g.mul (g.mul (g.inv (g.inv a)) (g.inv a)) (g.mul a (g.inv a)) := by rw [h1]
    _ = g.mul (g.inv (g.inv a)) (g.mul (g.inv a) (g.mul a (g.inv a))) := g.mul_assoc _ _ _
    _ = g.mul (g.inv (g.inv a)) (g.mul (g.mul (g.inv a) a) (g.inv a)) := by rw [g.mul_assoc]
    _ = g.mul (g.inv (g.inv a)) (g.mul g.one (g.inv a)) := by rw [g.inv_mul]
    _ = g.mul (g.inv (g.inv a)) (g.inv a) := by rw [g.one_mul]
    _ = g.one := h1

theorem inv_unique (w z : G) (h : g.mul w z = g.one) : w = g.inv z := by
  calc w = g.mul w g.one := (g.mul_one w).symm
    _ = g.mul w (g.mul z (g.inv z)) := by rw [g.mul_inv]
    _ = g.mul (g.mul w z) (g.inv z) := (g.mul_assoc _ _ _).symm
    _ = g.mul g.one (g.inv z) := by rw [h]
    _ = g.inv z := g.one_mul _

theorem inv_one : g.inv g.one = g.one :=
  (g.inv_unique g.one g.one (g.one_mul g.one)).symm

theorem inv_mul_rev (u v : G) : g.inv (g.mul u v) = g.mul (g.inv v) (g.inv u) := by
  symm
  apply g.inv_unique
  rw [g.mul_assoc, ← g.mul_assoc (g.inv u), g.inv_mul, g.one_mul, g.inv_mul]

theorem inv_inv (a : G) : g.inv (g.inv a) = a :=
  (g.inv_unique a (g.inv a) (g.mul_inv a)).symm

theorem mul_inv_cancel_left (a b : G) : g.mul a (g.mul (g.inv a) b) = b := by
  rw [← g.mul_assoc, g.mul_inv, g.one_mul]

theorem inv_mul_cancel_left (a b : G) : g.mul (g.inv a) (g.mul a b) = b := by
  rw [← g.mul_assoc, g.inv_mul, g.one_mul]

/-- (h a h') (h b h')⁻¹ = h (a b⁻¹) h⁻¹: left-right translates differ by conjugation. -/
theorem conj_of_lr (h h' a b : G) :
    g.mul (g.mul (g.mul h a) h') (g.inv (g.mul (g.mul h b) h'))
      = g.mul (g.mul h (g.mul a (g.inv b))) (g.inv h) := by
  simp only [g.inv_mul_rev, g.mul_assoc, g.mul_inv_cancel_left]

/-- (h a h⁻¹) (h b h⁻¹) = h (a b) h⁻¹. -/
theorem conj_mul (h a b : G) :
    g.mul (g.mul (g.mul h a) (g.inv h)) (g.mul (g.mul h b) (g.inv h)) = g.mul (g.mul h (g.mul a b)) (g.inv h) := by
  simp only [g.mul_assoc, g.inv_mul_cancel_left]

end Grp

/-- A group homomorphism. -/
structure Hom {Γ Ĝ : Type} (gΓ : Grp Γ) (gĜ : Grp Ĝ) where
  toFun : Γ → Ĝ
  map_mul : ∀ a b, toFun (gΓ.mul a b) = gĜ.mul (toFun a) (toFun b)
  map_one : toFun gΓ.one = gĜ.one

/-- O(Ĝ \ Ĝ^I / Ĝ): functions on Ĝ^I invariant under left and right diagonal multiplication. -/
def LRInvariant {Ĝ k I : Type} (g : Grp Ĝ) (f : (I → Ĝ) → k) : Prop :=
  ∀ (h h' : Ĝ) (x : I → Ĝ), f (fun i => g.mul (g.mul h (x i)) h') = f x

/-- f^ζ(x) = f(x ∘ ζ). -/
def pullback {Ĝ k I J : Type} (ζ : I → J) (f : (I → Ĝ) → k) : (J → Ĝ) → k :=
  fun x => f (fun i => x (ζ i))

/-- f̃(x ⊔ x' ⊔ x'') = f(x_i x''_i^{-1} x'_i). -/
def tilde {Ĝ k I : Type} (g : Grp Ĝ) (f : (I → Ĝ) → k) : (I ⊕ I ⊕ I → Ĝ) → k :=
  fun x => f (fun i => g.mul (g.mul (x (Sum.inl i)) (g.inv (x (Sum.inr (Sum.inr i))))) (x (Sum.inr (Sum.inl i))))

/-- (γ_i) ⊔ (γ'_i) ⊔ (1). -/
def triple {Γ I : Type} (gΓ : Grp Γ) (γ γ' : I → Γ) : I ⊕ I ⊕ I → Γ
  | Sum.inl i => γ i
  | Sum.inr (Sum.inl i) => γ' i
  | Sum.inr (Sum.inr _) => gΓ.one

theorem lrInvariant_pullback {Ĝ k I J : Type} (g : Grp Ĝ) (ζ : I → J) (f : (I → Ĝ) → k)
    (hf : LRInvariant g f) : LRInvariant g (pullback ζ f) := by
  intro h h' x
  exact hf h h' (fun i => x (ζ i))

theorem lrInvariant_mul {Ĝ k I : Type} [Mul k] (g : Grp Ĝ) {f f' : (I → Ĝ) → k}
    (hf : LRInvariant g f) (hf' : LRInvariant g f') : LRInvariant g (fun x => f x * f' x) := by
  intro h h' x
  show f _ * f' _ = f x * f' x
  rw [hf h h' x, hf' h h' x]

theorem lrInvariant_add {Ĝ k I : Type} [Add k] (g : Grp Ĝ) {f f' : (I → Ĝ) → k}
    (hf : LRInvariant g f) (hf' : LRInvariant g f') : LRInvariant g (fun x => f x + f' x) := by
  intro h h' x
  show f _ + f' _ = f x + f' x
  rw [hf h h' x, hf' h h' x]

theorem lrInvariant_tilde {Ĝ k I : Type} (g : Grp Ĝ) (f : (I → Ĝ) → k)
    (hf : LRInvariant g f) : LRInvariant g (tilde g f) := by
  intro h h' x
  unfold tilde
  -- (h a h') (h c h')^{-1} (h b h') = h (a c^{-1} b) h'
  have key : ∀ a b c : Ĝ,
      g.mul (g.mul (g.mul (g.mul h a) h') (g.inv (g.mul (g.mul h c) h'))) (g.mul (g.mul h b) h')
        = g.mul (g.mul h (g.mul (g.mul a (g.inv c)) b)) h' := by
    intro a b c
    simp only [g.inv_mul_rev, g.mul_assoc, g.mul_inv_cancel_left, g.inv_mul_cancel_left]
  simp only [key]
  exact hf h h' _

/-- Excursion data with values in a ring k: a character of the excursion algebra. -/
structure ExcursionData {Γ Ĝ : Type} (gΓ : Grp Γ) (gĜ : Grp Ĝ) (k : Type) [Mul k] [Add k] where
  Θ : ∀ {I : Type}, ((I → Ĝ) → k) → (I → Γ) → k
  /-- k-linearity and unitality of the character: the constant function c ∈ O(Ĝ\Ĝ^I/Ĝ) has value c
  (with `map_mul` this gives Θ(c·f) = c·Θ(f) and Θ(1) = 1; without it Θ ≡ 0 would qualify). -/
  map_const : ∀ {I : Type} (c : k) (γ : I → Γ), Θ (fun _ => c) γ = c
  /-- (E0): on the trivial tuple the excursion value is f(1, …, 1). -/
  map_unit : ∀ {I : Type} (f : (I → Ĝ) → k), LRInvariant gĜ f → Θ f (fun _ => gΓ.one) = f (fun _ => gĜ.one)
  functorial : ∀ {I J : Type} (ζ : I → J) (f : (I → Ĝ) → k), LRInvariant gĜ f →
    ∀ γ : J → Γ, Θ (pullback ζ f) γ = Θ f (fun i => γ (ζ i))
  map_mul : ∀ {I : Type} (f f' : (I → Ĝ) → k), LRInvariant gĜ f → LRInvariant gĜ f' →
    ∀ γ : I → Γ, Θ (fun x => f x * f' x) γ = Θ f γ * Θ f' γ
  map_add : ∀ {I : Type} (f f' : (I → Ĝ) → k), LRInvariant gĜ f → LRInvariant gĜ f' →
    ∀ γ : I → Γ, Θ (fun x => f x + f' x) γ = Θ f γ + Θ f' γ
  compose : ∀ {I : Type} (f : (I → Ĝ) → k), LRInvariant gĜ f → ∀ γ γ' : I → Γ,
    Θ f (fun i => gΓ.mul (γ i) (γ' i)) = Θ (tilde gĜ f) (triple gΓ γ γ')

/-- Galois side ⇒ excursion data: Θ_I(f)(γ) = f(ρ ∘ γ). -/
def ExcursionData.ofHom {Γ Ĝ : Type} {gΓ : Grp Γ} {gĜ : Grp Ĝ} (k : Type) [Mul k] [Add k]
    (ρ : Hom gΓ gĜ) : ExcursionData gΓ gĜ k where
  Θ := fun f γ => f (fun i => ρ.toFun (γ i))
  map_const := by intros; rfl
  map_unit := by
    intro I f _
    show f (fun _ => ρ.toFun gΓ.one) = f (fun _ => gĜ.one)
    rw [ρ.map_one]
  functorial := by intros; rfl
  map_mul := by intros; rfl
  map_add := by intros; rfl
  compose := by
    intro I f _ γ γ'
    show f (fun i => ρ.toFun (gΓ.mul (γ i) (γ' i)))
      = f (fun i => gĜ.mul (gĜ.mul (ρ.toFun (γ i)) (gĜ.inv (ρ.toFun gΓ.one))) (ρ.toFun (γ' i)))
    have : (fun i => ρ.toFun (gΓ.mul (γ i) (γ' i)))
        = (fun i => gĜ.mul (gĜ.mul (ρ.toFun (γ i)) (gĜ.inv (ρ.toFun gΓ.one))) (ρ.toFun (γ' i))) := by
      funext i
      rw [ρ.map_mul, ρ.map_one, gĜ.inv_one, gĜ.mul_one]
    rw [this]

/-- On constant tuples every excursion value of ρ-data is f(1, …, 1): only "differences" of the γ_i matter. -/
theorem ExcursionData.ofHom_const {Γ Ĝ : Type} {gΓ : Grp Γ} {gĜ : Grp Ĝ} (k : Type) [Mul k] [Add k]
    (ρ : Hom gΓ gĜ) {I : Type} (f : (I → Ĝ) → k) (hf : LRInvariant gĜ f) (γ : Γ) :
    (ExcursionData.ofHom k ρ).Θ f (fun _ : I => γ) = f (fun _ => gĜ.one) := by
  show f (fun _ => ρ.toFun γ) = f (fun _ => gĜ.one)
  have := hf (ρ.toFun γ) gĜ.one (fun _ => gĜ.one)
  simp only [gĜ.mul_one] at this
  exact this

/-- The Hecke function of a class function χ_V: f_V(g_0, g_1) = χ_V(g_0 g_1^{-1}) on Ĝ^{Bool}. -/
def heckeFun {Ĝ k : Type} (g : Grp Ĝ) (χ : Ĝ → k) : (Bool → Ĝ) → k :=
  fun x => χ (g.mul (x true) (g.inv (x false)))

theorem lrInvariant_heckeFun {Ĝ k : Type} (g : Grp Ĝ) (χ : Ĝ → k)
    (hχ : ∀ h x, χ (g.mul (g.mul h x) (g.inv h)) = χ x) : LRInvariant g (heckeFun g χ) := by
  intro h h' x
  unfold heckeFun
  rw [g.conj_of_lr]
  exact hχ h _

/-- The pair (γ, 1) indexed by Bool (true ↦ γ). -/
def pair {Γ : Type} (gΓ : Grp Γ) (γ : Γ) : Bool → Γ := fun b => if b then γ else gΓ.one

theorem pair_mul {Γ : Type} (gΓ : Grp Γ) (γ γ' : Γ) :
    pair gΓ (gΓ.mul γ γ') = fun b => gΓ.mul (pair gΓ γ b) (pair gΓ γ' b) := by
  funext b
  cases b <;> simp [pair, gΓ.mul_one]

theorem pair_one {Γ : Type} (gΓ : Grp Γ) : pair gΓ gΓ.one = fun _ => gΓ.one := by
  funext b
  cases b <;> rfl

/-- The unramified Hecke eigenvalue is the excursion value of f_V at (Frob_v, 1): χ_V(ρ(Frob_v)). -/
theorem hecke_eq_character {Γ Ĝ : Type} {gΓ : Grp Γ} {gĜ : Grp Ĝ} (k : Type) [Mul k] [Add k]
    (ρ : Hom gΓ gĜ) (χ : Ĝ → k) (frob : Γ) :
    (ExcursionData.ofHom k ρ).Θ (heckeFun gĜ χ) (pair gΓ frob) = χ (ρ.toFun frob) := by
  show χ (gĜ.mul (ρ.toFun frob) (gĜ.inv (ρ.toFun gΓ.one))) = χ (ρ.toFun frob)
  rw [ρ.map_one, gĜ.inv_one, gĜ.mul_one]

/-- Unitality: Θ_I(1)(γ) = 1 for every excursion datum (a consequence of `map_const`). -/
theorem ExcursionData.map_one {Γ Ĝ : Type} {gΓ : Grp Γ} {gĜ : Grp Ĝ} {k : Type} [Mul k] [Add k] [OfNat k 1]
    (D : ExcursionData gΓ gĜ k) {I : Type} (γ : I → Γ) : D.Θ (fun _ => (1 : k)) γ = 1 :=
  D.map_const 1 γ

/-- Excursion values commute when k does: the excursion algebra is commutative on a character. -/
theorem excursion_comm {Γ Ĝ : Type} {gΓ : Grp Γ} {gĜ : Grp Ĝ} {k : Type} [Mul k] [Add k]
    (hk : ∀ a b : k, a * b = b * a) (D : ExcursionData gΓ gĜ k) {I J : Type}
    (f : (I → Ĝ) → k) (f' : (J → Ĝ) → k) (γ : I → Γ) (γ' : J → Γ) :
    D.Θ f γ * D.Θ f' γ' = D.Θ f' γ' * D.Θ f γ := hk _ _

end Oracles
