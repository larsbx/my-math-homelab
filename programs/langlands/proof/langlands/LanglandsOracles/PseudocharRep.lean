import LanglandsOracles.ExcursionGL2Ring
import LanglandsOracles.RingNorm

/-!
# Pseudocharacter ⇒ representation for GL₂, for every group (Rouquier's construction)

Let Γ be a group, R a commutative ring in which 2 is invertible, and T : Γ → R a 2-dimensional
pseudocharacter: T(1) = 1 + 1, T(xy) = T(yx) and the Frobenius–Procesi identity
   T(x)T(y)T(z) + T(xyz) + T(xzy) = T(xy)T(z) + T(xz)T(y) + T(yz)T(x).
Suppose some g ∈ Γ has its "characteristic polynomial" X² − T(g)X + D(g), D(g) = (T(g)² − T(g²))/2, split
with distinct roots λ, μ (λ − μ a unit), and suppose the off-diagonal pairing B(x₀, y₀) defined below is a
unit for some x₀, y₀ (absolute irreducibility).  Then `pseudochar_rep` (PROVED, propext / Quot.sound)
gives ρ : Γ → M₂(R) with ρ(1) = 1, ρ(xy) = ρ(x)ρ(y) and tr ρ = T, every entry an explicit polynomial in
values of T (and κ = (λ − μ)⁻¹, B(x₀, y₀)⁻¹).

Construction, in the formal group ring R[Γ] (finite formal sums `FS`, with `tr` the linear extension of
T and `fmul` the product): e = κ(g − μ) and f = −κ(g − λ), so e + f = 1 under `tr`; then
   a(x) = tr(e x),  d(x) = T(x) − a(x),  B(x, y) = tr(e x f y),
   ρ(x) = [[a(x), B(x, y₀)], [B(x₀, x)·u⁻¹, d(x)]],  u = B(x₀, y₀).
Everything follows from one identity, the **rank-one property** of e and f,
   tr(e z e w) = tr(e z)·tr(e w)  for all z, w ∈ R[Γ]   (`qe`),
which for group elements z, w is a linear combination of four Procesi instances (`rank1`), and extends
bilinearly; together with linearity, cyclicity (`tr_rot`) and e + f = 1 it gives each matrix entry of
ρ(xy) = ρ(x)ρ(y).  Ring identities are closed by the reflective normalizer `ring_eq` (`RingNorm`).

`excursion_rep_Zmod` composes this with `gl2_Zmod_pseudocharacter`: the pseudocharacter of any excursion
datum for GL₂(ℤ/n) is the trace of the representation built from it, under the same hypotheses.
-/
namespace Oracles.PseudocharRep

open Lean.Grind RingNorm

set_option linter.unusedSectionVars false

section rank

variable {Γ R : Type} [CommRing R] (gΓ : Grp Γ) (T : Γ → R)

/-- The rank-one identity at the level of group elements, from four Procesi instances. -/
theorem rank1
    (hcomm : ∀ x y, T (gΓ.mul x y) = T (gΓ.mul y x))
    (hP : ∀ x y z, T x * T y * T z + T (gΓ.mul (gΓ.mul x y) z) + T (gΓ.mul (gΓ.mul x z) y)
      = T (gΓ.mul x y) * T z + T (gΓ.mul x z) * T y + T (gΓ.mul y z) * T x)
    (g : Γ) (lam mu half : R) (hsum : lam + mu = T g) (hprod : lam * mu + lam * mu = T g * T g - T (gΓ.mul g g))
    (hhalf : half + half = 1) (x y : Γ) :
    T (gΓ.mul g (gΓ.mul x (gΓ.mul g y))) - mu * (T (gΓ.mul g (gΓ.mul x y)) + T (gΓ.mul x (gΓ.mul g y)))
      + mu * mu * T (gΓ.mul x y) = (T (gΓ.mul g x) - mu * T x) * (T (gΓ.mul g y) - mu * T y) := by
  have A := gΓ.mul_assoc
  -- the four Procesi instances, right-associated
  have P1 := hP (gΓ.mul g x) g y
  have P2 := hP g g x
  have P3 := hP g g (gΓ.mul x y)
  have P4 := hP g x y
  simp only [A] at P1 P2 P3 P4
  -- centrality, to identify rotated words
  have C1 : T (gΓ.mul g (gΓ.mul x g)) = T (gΓ.mul g (gΓ.mul g x)) := by
    rw [← A, hcomm]
  have C2 : T (gΓ.mul g (gΓ.mul x (gΓ.mul y g))) = T (gΓ.mul g (gΓ.mul g (gΓ.mul x y))) := by
    rw [← A, ← A, hcomm, A]
  have C3 : T (gΓ.mul x (gΓ.mul g y)) = T (gΓ.mul g (gΓ.mul y x)) := by
    rw [hcomm, A]
  -- Cayley–Hamilton for g against x and against xy (2 is invertible)
  have hGGX : T (gΓ.mul g (gΓ.mul g x)) = T g * T (gΓ.mul g x) - lam * mu * T x :=
    lin_comb (by ring_eq) (lc_add (lc_add (lc_add (lc_add lc_zero half P2) (half * T x) hprod)
      (-half) C1) (-(T (gΓ.mul g (gΓ.mul g x)) - (T g * T (gΓ.mul g x) - lam * mu * T x))) hhalf)
  have hGGXY : T (gΓ.mul g (gΓ.mul g (gΓ.mul x y))) = T g * T (gΓ.mul g (gΓ.mul x y)) - lam * mu * T (gΓ.mul x y) :=
    lin_comb (by ring_eq) (lc_add (lc_add (lc_add (lc_add lc_zero half P3) (half * T (gΓ.mul x y)) hprod)
      (-half) C2) (-(T (gΓ.mul g (gΓ.mul g (gΓ.mul x y))) - (T g * T (gΓ.mul g (gΓ.mul x y)) - lam * mu * T (gΓ.mul x y)))) hhalf)
  exact lin_comb (by ring_eq)
    (lc_add (lc_add (lc_add (lc_add (lc_add (lc_add (lc_add (lc_add lc_zero 1 P1) (-1) C2) (-1) hGGXY)
      (T y) C1) (T y) hGGX) (-mu) C3) (-mu) P4) (mu * (T (gΓ.mul x y) - T x * T y)) hsum)

end rank

/-- Finite formal sums Σ cᵢ·γᵢ: the group ring R[Γ], unnormalized. -/
abbrev FS (R Γ : Type) := List (R × Γ)

section defs

variable {Γ R : Type} [CommRing R] (gΓ : Grp Γ) (T : Γ → R)

/-- The linear extension of T. -/
def tr : FS R Γ → R
  | [] => 0
  | p :: l => p.1 * T p.2 + tr l

def smulL (p : R × Γ) : FS R Γ → FS R Γ
  | [] => []
  | q :: m => (p.1 * q.1, gΓ.mul p.2 q.2) :: smulL p m

/-- The product of formal sums. -/
def fmul : FS R Γ → FS R Γ → FS R Γ
  | [], _ => []
  | p :: l, m => smulL gΓ p m ++ fmul l m

/-- The product of a list of formal sums. -/
def pr : List (FS R Γ) → FS R Γ
  | [] => [(1, gΓ.one)]
  | a :: as => fmul gΓ a (pr as)

/-- The group element x as a formal sum. -/
def sing (x : Γ) : FS R Γ := [(1, x)]

/-- κ(g − μ): with κ = (λ − μ)⁻¹ the idempotent e, with κ ↦ −κ, μ ↦ λ the complementary f. -/
def idem (κ μ : R) (g : Γ) : FS R Γ := [(κ, g), (-(κ * μ), gΓ.one)]

end defs

section fs

variable {Γ R : Type} [CommRing R] {gΓ : Grp Γ} {T : Γ → R}

theorem tr_append (l m : FS R Γ) : tr T (l ++ m) = tr T l + tr T m := by
  induction l with
  | nil => exact (zero_add' _).symm
  | cons p l ih =>
    show p.1 * T p.2 + tr T (l ++ m) = (p.1 * T p.2 + tr T l) + tr T m
    rw [ih, Semiring.add_assoc]

theorem fmul_append_left (l l' m : FS R Γ) : fmul gΓ (l ++ l') m = fmul gΓ l m ++ fmul gΓ l' m := by
  induction l with
  | nil => rfl
  | cons p l ih =>
    show smulL gΓ p m ++ fmul gΓ (l ++ l') m = (smulL gΓ p m ++ fmul gΓ l m) ++ fmul gΓ l' m
    rw [ih, List.append_assoc]

theorem smulL_append (p : R × Γ) (m m' : FS R Γ) : smulL gΓ p (m ++ m') = smulL gΓ p m ++ smulL gΓ p m' := by
  induction m with
  | nil => rfl
  | cons q m ih => exact congrArg (List.cons _) ih

theorem smulL_smulL (p q : R × Γ) (m : FS R Γ) :
    smulL gΓ p (smulL gΓ q m) = smulL gΓ (p.1 * q.1, gΓ.mul p.2 q.2) m := by
  induction m with
  | nil => rfl
  | cons r m ih =>
    show (p.1 * (q.1 * r.1), gΓ.mul p.2 (gΓ.mul q.2 r.2)) :: smulL gΓ p (smulL gΓ q m)
      = (p.1 * q.1 * r.1, gΓ.mul (gΓ.mul p.2 q.2) r.2) :: smulL gΓ (p.1 * q.1, gΓ.mul p.2 q.2) m
    rw [ih, Semiring.mul_assoc, gΓ.mul_assoc]

theorem smulL_fmul (p : R × Γ) (m n : FS R Γ) : smulL gΓ p (fmul gΓ m n) = fmul gΓ (smulL gΓ p m) n := by
  induction m with
  | nil => rfl
  | cons q m ih =>
    show smulL gΓ p (smulL gΓ q n ++ fmul gΓ m n) = smulL gΓ (p.1 * q.1, gΓ.mul p.2 q.2) n ++ fmul gΓ (smulL gΓ p m) n
    rw [smulL_append, smulL_smulL, ih]

theorem fmul_assoc (l m n : FS R Γ) : fmul gΓ (fmul gΓ l m) n = fmul gΓ l (fmul gΓ m n) := by
  induction l with
  | nil => rfl
  | cons p l ih =>
    show fmul gΓ (smulL gΓ p m ++ fmul gΓ l m) n = smulL gΓ p (fmul gΓ m n) ++ fmul gΓ l (fmul gΓ m n)
    rw [fmul_append_left, ih, smulL_fmul]

theorem fmul_single (p : R × Γ) (m : FS R Γ) : fmul gΓ [p] m = smulL gΓ p m := List.append_nil _

theorem fmul_nil_right (l : FS R Γ) : fmul gΓ l [] = [] := by
  induction l with
  | nil => rfl
  | cons p l ih => exact ih

theorem tr_fmul_append_right (l m m' : FS R Γ) :
    tr T (fmul gΓ l (m ++ m')) = tr T (fmul gΓ l m) + tr T (fmul gΓ l m') := by
  induction l with
  | nil => exact (Semiring.add_zero 0).symm
  | cons p l ih =>
    show tr T (smulL gΓ p (m ++ m') ++ fmul gΓ l (m ++ m'))
      = tr T (smulL gΓ p m ++ fmul gΓ l m) + tr T (smulL gΓ p m' ++ fmul gΓ l m')
    rw [smulL_append, tr_append, tr_append, tr_append, tr_append, ih]
    ring_eq

theorem smulL_one (m : FS R Γ) : smulL gΓ (1, gΓ.one) m = m := by
  induction m with
  | nil => rfl
  | cons q m ih =>
    show (1 * q.1, gΓ.mul gΓ.one q.2) :: smulL gΓ (1, gΓ.one) m = q :: m
    rw [ih, Semiring.one_mul, gΓ.one_mul]

theorem fmul_one_left (m : FS R Γ) : fmul gΓ [(1, gΓ.one)] m = m := by
  show smulL gΓ (1, gΓ.one) m ++ [] = m
  rw [List.append_nil, smulL_one]

theorem fmul_one_right (l : FS R Γ) : fmul gΓ l [(1, gΓ.one)] = l := by
  induction l with
  | nil => rfl
  | cons p l ih =>
    show (p.1 * 1, gΓ.mul p.2 gΓ.one) :: fmul gΓ l [(1, gΓ.one)] = p :: l
    rw [ih, Semiring.mul_one, gΓ.mul_one]

section comm

variable (hcomm : ∀ x y, T (gΓ.mul x y) = T (gΓ.mul y x))
include hcomm

theorem tr_smulL_eq (p : R × Γ) (m : FS R Γ) : tr T (smulL gΓ p m) = tr T (fmul gΓ m [p]) := by
  induction m with
  | nil => rfl
  | cons q m ih =>
    show p.1 * q.1 * T (gΓ.mul p.2 q.2) + tr T (smulL gΓ p m) = tr T (smulL gΓ q [p] ++ fmul gΓ m [p])
    rw [tr_append, ← ih]
    show _ = (q.1 * p.1 * T (gΓ.mul q.2 p.2) + 0) + _
    rw [hcomm]
    ring_eq

/-- Cyclicity of the linear extension. -/
theorem tr_fmul_comm (l m : FS R Γ) : tr T (fmul gΓ l m) = tr T (fmul gΓ m l) := by
  induction l with
  | nil => rw [fmul_nil_right]; rfl
  | cons p l ih =>
    show tr T (smulL gΓ p m ++ fmul gΓ l m) = tr T (fmul gΓ m ([p] ++ l))
    rw [tr_append, ih, tr_smulL_eq hcomm, tr_fmul_append_right]

theorem pr_append (u v : List (FS R Γ)) : pr gΓ (u ++ v) = fmul gΓ (pr gΓ u) (pr gΓ v) := by
  induction u with
  | nil => exact (fmul_one_left _).symm
  | cons a u ih =>
    show fmul gΓ a (pr gΓ (u ++ v)) = fmul gΓ (fmul gΓ a (pr gΓ u)) (pr gΓ v)
    rw [ih, fmul_assoc]

/-- Rotating the factors of a product does not change its trace. -/
theorem tr_rot (u v : List (FS R Γ)) : tr T (pr gΓ (u ++ v)) = tr T (pr gΓ (v ++ u)) := by
  rw [pr_append hcomm, pr_append hcomm, tr_fmul_comm hcomm]

end comm

theorem tr_split_front (a b : FS R Γ) (v : List (FS R Γ)) :
    tr T (pr gΓ ((a ++ b) :: v)) = tr T (pr gΓ (a :: v)) + tr T (pr gΓ (b :: v)) := by
  show tr T (fmul gΓ (a ++ b) (pr gΓ v)) = tr T (fmul gΓ a (pr gΓ v)) + tr T (fmul gΓ b (pr gΓ v))
  rw [fmul_append_left, tr_append]

theorem tr_scale_front (c : R) (x : Γ) (v : List (FS R Γ)) :
    tr T (pr gΓ ([(c, x)] :: v)) = c * tr T (pr gΓ (sing x :: v)) := by
  show tr T (smulL gΓ (c, x) (pr gΓ v) ++ []) = c * tr T (smulL gΓ (1, x) (pr gΓ v) ++ [])
  rw [List.append_nil, List.append_nil]
  generalize pr gΓ v = P
  induction P with
  | nil => exact (Semiring.mul_zero c).symm
  | cons q P ih =>
    show c * q.1 * T (gΓ.mul x q.2) + tr T (smulL gΓ (c, x) P) = c * (1 * q.1 * T (gΓ.mul x q.2) + tr T (smulL gΓ (1, x) P))
    rw [ih]
    ring_eq

theorem tr_unit_front (v : List (FS R Γ)) : tr T (pr gΓ (sing gΓ.one :: v)) = tr T (pr gΓ v) := by
  show tr T (fmul gΓ [(1, gΓ.one)] (pr gΓ v)) = _
  rw [fmul_one_left]

theorem tr_merge_front (x y : Γ) (v : List (FS R Γ)) :
    tr T (pr gΓ (sing x :: sing y :: v)) = tr T (pr gΓ (sing (gΓ.mul x y) :: v)) := by
  show tr T (fmul gΓ [(1, x)] (fmul gΓ [(1, y)] (pr gΓ v))) = tr T (fmul gΓ [(1, gΓ.mul x y)] (pr gΓ v))
  rw [← fmul_assoc]
  show tr T (fmul gΓ [((1 : R) * 1, gΓ.mul x y)] (pr gΓ v)) = _
  rw [Semiring.mul_one]

theorem tr_idem_front (κ μ : R) (g : Γ) (v : List (FS R Γ)) :
    tr T (pr gΓ (idem gΓ κ μ g :: v)) = κ * tr T (pr gΓ (sing g :: v)) + -(κ * μ) * tr T (pr gΓ v) := by
  show tr T (pr gΓ (([(κ, g)] ++ [(-(κ * μ), gΓ.one)]) :: v)) = _
  rw [tr_split_front, tr_scale_front, tr_scale_front, tr_unit_front]

end fs

section rep

variable {Γ R : Type} [CommRing R] {gΓ : Grp Γ} {T : Γ → R}
  (hcomm : ∀ x y, T (gΓ.mul x y) = T (gΓ.mul y x))
  (hP : ∀ x y z, T x * T y * T z + T (gΓ.mul (gΓ.mul x y) z) + T (gΓ.mul (gΓ.mul x z) y)
    = T (gΓ.mul x y) * T z + T (gΓ.mul x z) * T y + T (gΓ.mul y z) * T x)
  {g : Γ} {lam mu half : R} (hsum : lam + mu = T g)
  (hprod : lam * mu + lam * mu = T g * T g - T (gΓ.mul g g)) (hhalf : half + half = 1)

include hcomm hP hsum hprod hhalf

/-- The rank-one identity for single terms. -/
theorem qe_base (κ c d : R) (x y : Γ) :
    tr T (fmul gΓ (fmul gΓ (fmul gΓ (idem gΓ κ mu g) [(c, x)]) (idem gΓ κ mu g)) [(d, y)])
      = tr T (fmul gΓ (idem gΓ κ mu g) [(c, x)]) * tr T (fmul gΓ (idem gΓ κ mu g) [(d, y)]) := by
  simp only [idem, fmul, smulL, tr, List.cons_append, List.nil_append, gΓ.one_mul, gΓ.mul_assoc]
  exact lin_comb (by ring_eq) (lc_add lc_zero (κ * κ * c * d) (rank1 gΓ T hcomm hP g lam mu half hsum hprod hhalf x y))

/-- **The rank-one property** tr(e z e w) = tr(e z)·tr(e w), for all formal sums z, w. -/
theorem qe (κ : R) (Z W : FS R Γ) :
    tr T (fmul gΓ (idem gΓ κ mu g) (fmul gΓ Z (fmul gΓ (idem gΓ κ mu g) W)))
      = tr T (fmul gΓ (idem gΓ κ mu g) Z) * tr T (fmul gΓ (idem gΓ κ mu g) W) := by
  -- single terms on the left, all W
  have single : ∀ (c : R) (x : Γ), tr T (fmul gΓ (idem gΓ κ mu g) (fmul gΓ [(c, x)] (fmul gΓ (idem gΓ κ mu g) W)))
      = tr T (fmul gΓ (idem gΓ κ mu g) [(c, x)]) * tr T (fmul gΓ (idem gΓ κ mu g) W) := by
    intro c x
    induction W with
    | nil => rw [fmul_nil_right, fmul_nil_right, fmul_nil_right]; exact (Semiring.mul_zero _).symm
    | cons q W ih =>
      obtain ⟨d, y⟩ := q
      rw [← fmul_assoc, ← fmul_assoc]
      rw [← fmul_assoc, ← fmul_assoc] at ih
      show tr T (fmul gΓ _ ([(d, y)] ++ W)) = _ * tr T (fmul gΓ _ ([(d, y)] ++ W))
      rw [tr_fmul_append_right, tr_fmul_append_right, ih, qe_base hcomm hP hsum hprod hhalf, Semiring.left_distrib]
  induction Z with
  | nil => show tr T (fmul gΓ _ []) = tr T (fmul gΓ _ []) * _; rw [fmul_nil_right]; exact (Semiring.zero_mul _).symm
  | cons p Z ih =>
    obtain ⟨c, x⟩ := p
    show tr T (fmul gΓ _ (smulL gΓ (c, x) _ ++ fmul gΓ Z _)) = tr T (fmul gΓ _ ([(c, x)] ++ Z)) * _
    rw [tr_fmul_append_right, tr_fmul_append_right, ih, ← fmul_single, single, Semiring.right_distrib]

/-- The rank-one property on products of factors. -/
theorem qe_pr (κ : R) (z w : List (FS R Γ)) :
    tr T (pr gΓ (idem gΓ κ mu g :: (z ++ idem gΓ κ mu g :: w)))
      = tr T (pr gΓ (idem gΓ κ mu g :: z)) * tr T (pr gΓ (idem gΓ κ mu g :: w)) := by
  show tr T (fmul gΓ _ (pr gΓ (z ++ idem gΓ κ mu g :: w))) = tr T (fmul gΓ _ (pr gΓ z)) * tr T (fmul gΓ _ (pr gΓ w))
  rw [pr_append hcomm]
  exact qe hcomm hP hsum hprod hhalf κ (pr gΓ z) (pr gΓ w)

end rep

section construction

variable {Γ R : Type} [CommRing R] (gΓ : Grp Γ) (T : Γ → R) (g x₀ y₀ : Γ) (lam mu κ uinv : R)

/-- a(x) = tr(e x). -/
def aF (x : Γ) : R := tr T (pr gΓ [idem gΓ κ mu g, sing x])

/-- B(x, y) = tr(e x f y): the product of the (1,2) entry of x and the (2,1) entry of y. -/
def BF (x y : Γ) : R := tr T (pr gΓ [idem gΓ κ mu g, sing x, idem gΓ (-κ) lam g, sing y])

/-- **The representation built from T**: [[a(x), B(x, y₀)], [B(x₀, x)·u⁻¹, T(x) − a(x)]]. -/
def rho (x : Γ) : M2 R :=
  ⟨aF gΓ T g mu κ x, BF gΓ T g lam mu κ x y₀, BF gΓ T g lam mu κ x₀ x * uinv, T x - aF gΓ T g mu κ x⟩

end construction

section theorems

variable {Γ R : Type} [CommRing R] {gΓ : Grp Γ} {T : Γ → R}
  (hone : T gΓ.one = 1 + 1)
  (hcomm : ∀ x y, T (gΓ.mul x y) = T (gΓ.mul y x))
  (hP : ∀ x y z, T x * T y * T z + T (gΓ.mul (gΓ.mul x y) z) + T (gΓ.mul (gΓ.mul x z) y)
    = T (gΓ.mul x y) * T z + T (gΓ.mul x z) * T y + T (gΓ.mul y z) * T x)
  {g x₀ y₀ : Γ} {lam mu κ half uinv : R} (hsum : lam + mu = T g)
  (hprod : lam * mu + lam * mu = T g * T g - T (gΓ.mul g g)) (hhalf : half + half = 1)
  (hκ : κ * (lam - mu) = 1)

local notation "𝐞" => idem gΓ κ mu g
local notation "𝐟" => idem gΓ (-κ) lam g
local notation "tP " l => tr T (pr gΓ l)

include hcomm in
theorem at_front (u : List (FS R Γ)) (c : FS R Γ) (v : List (FS R Γ)) :
    (tP (u ++ c :: v)) = tP (c :: (v ++ u)) := tr_rot hcomm u (c :: v)

include hκ in
/-- e + f = 1 under the trace. -/
theorem ef_front (v : List (FS R Γ)) : (tP ((𝐞 ++ 𝐟) :: v)) = tP v := by
  rw [tr_split_front, tr_idem_front, tr_idem_front]
  exact lin_comb (by ring_eq) (lc_add lc_zero (tr T (pr gΓ v)) hκ)

include hcomm hκ in
theorem ins_ef (u v : List (FS R Γ)) : (tP (u ++ v)) = tP (u ++ (𝐞 ++ 𝐟) :: v) := by
  rw [at_front hcomm, ef_front hκ]; exact tr_rot hcomm u v

include hcomm in
theorem split_at (u : List (FS R Γ)) (a b : FS R Γ) (v : List (FS R Γ)) :
    (tP (u ++ (a ++ b) :: v)) = (tP (u ++ a :: v)) + tP (u ++ b :: v) := by
  rw [at_front hcomm, tr_split_front, ← at_front hcomm, ← at_front hcomm]

include hcomm in
theorem merge_at (u : List (FS R Γ)) (x y : Γ) (v : List (FS R Γ)) :
    (tP (u ++ sing x :: sing y :: v)) = tP (u ++ sing (gΓ.mul x y) :: v) :=
  (at_front hcomm u (sing x) (sing y :: v)).trans ((tr_merge_front x y (v ++ u)).trans (at_front hcomm u _ v).symm)

include hcomm in
theorem unit_at (u v : List (FS R Γ)) : (tP (u ++ sing gΓ.one :: v)) = tP (u ++ v) :=
  (at_front hcomm u _ v).trans ((tr_unit_front (v ++ u)).trans (tr_rot hcomm v u))

include hone hsum hκ in
theorem tr_e : (tP [𝐞]) = 1 := by
  show tr T (fmul gΓ 𝐞 [(1, gΓ.one)]) = 1
  rw [fmul_one_right]
  show κ * T g + (-(κ * mu) * T gΓ.one + 0) = 1
  exact lin_comb (by ring_eq) (lc_add (lc_add (lc_add lc_zero (-κ) hsum) (-(κ * mu)) hone) 1 hκ)

include hone hsum hκ in
theorem tr_f : (tP [𝐟]) = 1 := by
  show tr T (fmul gΓ 𝐟 [(1, gΓ.one)]) = 1
  rw [fmul_one_right]
  show -κ * T g + (-(-κ * lam) * T gΓ.one + 0) = 1
  exact lin_comb (by ring_eq) (lc_add (lc_add (lc_add lc_zero κ hsum) (κ * lam) hone) 1 hκ)

include hsum hprod in
theorem hsum' : mu + lam = T g := by rw [Semiring.add_comm]; exact hsum

include hsum hprod in
theorem hprod' : mu * lam + mu * lam = T g * T g - T (gΓ.mul g g) := by
  rw [CommSemiring.mul_comm mu lam]; exact hprod

include hcomm hP hsum hprod hhalf in
/-- The rank-one property for f = −κ(g − λ): the same theorem with λ and μ exchanged. -/
theorem qf_pr (z w : List (FS R Γ)) :
    (tP (𝐟 :: (z ++ 𝐟 :: w))) = (tP (𝐟 :: z)) * tP (𝐟 :: w) :=
  qe_pr hcomm hP (hsum' hsum hprod) (hprod' hsum hprod) hhalf (-κ) z w

include hone hcomm hP hsum hprod hhalf hκ

theorem ee (v : List (FS R Γ)) : (tP (𝐞 :: 𝐞 :: v)) = tP (𝐞 :: v) := by
  have h := qe_pr hcomm hP hsum hprod hhalf κ [] v
  rw [tr_e hone hsum hκ, Semiring.one_mul] at h
  exact h

theorem ff (v : List (FS R Γ)) : (tP (𝐟 :: 𝐟 :: v)) = tP (𝐟 :: v) := by
  have h : (tP (𝐟 :: ([] ++ 𝐟 :: v))) = (tP [𝐟]) * tP (𝐟 :: v) := qf_pr hcomm hP hsum hprod hhalf [] v
  rw [tr_f hone hsum hκ, Semiring.one_mul] at h
  exact h

/-- ef = 0 under the trace. -/
theorem ef_zero (v : List (FS R Γ)) : (tP (𝐞 :: 𝐟 :: v)) = 0 := by
  have h : (tP (𝐞 :: v)) = (tP (𝐞 :: 𝐞 :: v)) + tP (𝐞 :: 𝐟 :: v) :=
    (ins_ef hcomm hκ [𝐞] v).trans (split_at hcomm [𝐞] 𝐞 𝐟 v)
  rw [ee hone hcomm hP hsum hprod hhalf hκ v] at h
  exact lin_comb (by ring_eq) (lc_add lc_zero (-1) h)

/-- fe = 0 under the trace. -/
theorem fe_zero (v : List (FS R Γ)) : (tP (𝐟 :: 𝐞 :: v)) = 0 := by
  have h : (tP (𝐟 :: v)) = (tP (𝐟 :: 𝐞 :: v)) + tP (𝐟 :: 𝐟 :: v) :=
    (ins_ef hcomm hκ [𝐟] v).trans (split_at hcomm [𝐟] 𝐞 𝐟 v)
  rw [ff hone hcomm hP hsum hprod hhalf hκ v] at h
  exact lin_comb (by ring_eq) (lc_add lc_zero (-1) h)

/-- d(x) = tr(f x) = T(x) − a(x). -/
theorem d_eq (x : Γ) : (tP [𝐟, sing x]) = T x - aF gΓ T g mu κ x := by
  have h : (tP [sing x]) = aF gΓ T g mu κ x + tP [𝐟, sing x] :=
    (ins_ef hcomm hκ [] [sing x]).trans (split_at hcomm [] 𝐞 𝐟 [sing x])
  have hx : (tP [sing x]) = T x := by
    show tr T (fmul gΓ [(1, x)] [(1, gΓ.one)]) = T x
    rw [fmul_one_right]; show 1 * T x + 0 = T x; ring_eq
  rw [hx] at h
  exact lin_comb (by ring_eq) (lc_add lc_zero (-1) h)

/-- a(x) = κ·T(gx) − κμ·T(x): the diagonal entry from T alone. -/
theorem aF_eq (x : Γ) : aF gΓ T g mu κ x = κ * T (gΓ.mul g x) - κ * mu * T x := by
  have hx : (tP [sing x]) = T x := by
    show tr T (fmul gΓ [(1, x)] [(1, gΓ.one)]) = T x
    rw [fmul_one_right]; show 1 * T x + 0 = T x; ring_eq
  have hgx : (tP [sing g, sing x]) = T (gΓ.mul g x) := by
    rw [show [sing g, sing x] = ([] : List (FS R Γ)) ++ sing g :: sing x :: [] from rfl, merge_at hcomm]
    show tr T (fmul gΓ [(1, gΓ.mul g x)] [(1, gΓ.one)]) = _
    rw [fmul_one_right]; show 1 * T (gΓ.mul g x) + 0 = _; ring_eq
  show (tP (𝐞 :: [sing x])) = _
  rw [tr_idem_front, hgx, hx]
  ring_eq

/-- B(x, y₀)·B(x₀, y) = B(x, y)·B(x₀, y₀): the pairing has rank one. -/
theorem B_rank_one (x y : Γ) :
    BF gΓ T g lam mu κ x y₀ * BF gΓ T g lam mu κ x₀ y = BF gΓ T g lam mu κ x y * BF gΓ T g lam mu κ x₀ y₀ :=
  calc BF gΓ T g lam mu κ x y₀ * BF gΓ T g lam mu κ x₀ y
      = tP [𝐞, sing x, 𝐟, sing y₀, 𝐞, sing x₀, 𝐟, sing y] :=
        (qe_pr hcomm hP hsum hprod hhalf κ [sing x, 𝐟, sing y₀] [sing x₀, 𝐟, sing y]).symm
    _ = tP [𝐟, sing y, 𝐞, sing x, 𝐟, sing y₀, 𝐞, sing x₀] := tr_rot hcomm [𝐞, sing x, 𝐟, sing y₀, 𝐞, sing x₀] [𝐟, sing y]
    _ = (tP [𝐟, sing y, 𝐞, sing x]) * tP [𝐟, sing y₀, 𝐞, sing x₀] :=
        qf_pr hcomm hP hsum hprod hhalf [sing y, 𝐞, sing x] [sing y₀, 𝐞, sing x₀]
    _ = BF gΓ T g lam mu κ x y * BF gΓ T g lam mu κ x₀ y₀ :=
        congr (congrArg (· * ·) (tr_rot hcomm [𝐟, sing y] [𝐞, sing x])) (tr_rot hcomm [𝐟, sing y₀] [𝐞, sing x₀])

variable (hu : BF gΓ T g lam mu κ x₀ y₀ * uinv = 1)
include hu

/-- (1,1) entry of ρ(xy) = ρ(x)ρ(y). -/
theorem entry_a (x y : Γ) : aF gΓ T g mu κ (gΓ.mul x y)
    = aF gΓ T g mu κ x * aF gΓ T g mu κ y + BF gΓ T g lam mu κ x y₀ * (BF gΓ T g lam mu κ x₀ y * uinv) := by
  have h1 : aF gΓ T g mu κ (gΓ.mul x y) = aF gΓ T g mu κ x * aF gΓ T g mu κ y + BF gΓ T g lam mu κ x y :=
    calc aF gΓ T g mu κ (gΓ.mul x y) = tP [𝐞, sing x, sing y] := (merge_at hcomm [𝐞] x y []).symm
      _ = tP [𝐞, sing x, 𝐞 ++ 𝐟, sing y] := ins_ef hcomm hκ [𝐞, sing x] [sing y]
      _ = (tP [𝐞, sing x, 𝐞, sing y]) + tP [𝐞, sing x, 𝐟, sing y] := split_at hcomm [𝐞, sing x] 𝐞 𝐟 [sing y]
      _ = _ := congrArg (· + tP [𝐞, sing x, 𝐟, sing y]) (qe_pr hcomm hP hsum hprod hhalf κ [sing x] [sing y])
  exact lin_comb (by ring_eq) (lc_add (lc_add (lc_add lc_zero 1 h1) (-uinv)
    (B_rank_one (x₀ := x₀) (y₀ := y₀) hone hcomm hP hsum hprod hhalf hκ x y)) (-BF gΓ T g lam mu κ x y) hu)

/-- (1,2) entry. -/
theorem entry_b (x y : Γ) : BF gΓ T g lam mu κ (gΓ.mul x y) y₀
    = aF gΓ T g mu κ x * BF gΓ T g lam mu κ y y₀ + BF gΓ T g lam mu κ x y₀ * (T y - aF gΓ T g mu κ y) := by
  have h : BF gΓ T g lam mu κ (gΓ.mul x y) y₀ = aF gΓ T g mu κ x * BF gΓ T g lam mu κ y y₀ + (tP [𝐟, sing y]) * BF gΓ T g lam mu κ x y₀ :=
    calc BF gΓ T g lam mu κ (gΓ.mul x y) y₀ = tP [𝐞, sing x, sing y, 𝐟, sing y₀] := (merge_at hcomm [𝐞] x y [𝐟, sing y₀]).symm
      _ = tP [𝐞, sing x, 𝐞 ++ 𝐟, sing y, 𝐟, sing y₀] := ins_ef hcomm hκ [𝐞, sing x] [sing y, 𝐟, sing y₀]
      _ = (tP [𝐞, sing x, 𝐞, sing y, 𝐟, sing y₀]) + tP [𝐞, sing x, 𝐟, sing y, 𝐟, sing y₀] :=
          split_at hcomm [𝐞, sing x] 𝐞 𝐟 [sing y, 𝐟, sing y₀]
      _ = _ := congr (congrArg (· + ·) (qe_pr hcomm hP hsum hprod hhalf κ [sing x] [sing y, 𝐟, sing y₀]))
          ((tr_rot hcomm [𝐞, sing x] [𝐟, sing y, 𝐟, sing y₀]).trans
            ((qf_pr hcomm hP hsum hprod hhalf [sing y] [sing y₀, 𝐞, sing x]).trans
              (congrArg ((tP [𝐟, sing y]) * ·) (tr_rot hcomm [𝐟, sing y₀] [𝐞, sing x]))))
  rw [h, d_eq hone hcomm hP hsum hprod hhalf hκ y]
  ring_eq

/-- (2,1) entry. -/
theorem entry_c (x y : Γ) : BF gΓ T g lam mu κ x₀ (gΓ.mul x y) * uinv
    = BF gΓ T g lam mu κ x₀ x * uinv * aF gΓ T g mu κ y + (T x - aF gΓ T g mu κ x) * (BF gΓ T g lam mu κ x₀ y * uinv) := by
  have h : BF gΓ T g lam mu κ x₀ (gΓ.mul x y) = BF gΓ T g lam mu κ x₀ x * aF gΓ T g mu κ y + (tP [𝐟, sing x]) * BF gΓ T g lam mu κ x₀ y :=
    calc BF gΓ T g lam mu κ x₀ (gΓ.mul x y) = tP [𝐞, sing x₀, 𝐟, sing x, sing y] := (merge_at hcomm [𝐞, sing x₀, 𝐟] x y []).symm
      _ = tP [𝐞, sing x₀, 𝐟, sing x, 𝐞 ++ 𝐟, sing y] := ins_ef hcomm hκ [𝐞, sing x₀, 𝐟, sing x] [sing y]
      _ = (tP [𝐞, sing x₀, 𝐟, sing x, 𝐞, sing y]) + tP [𝐞, sing x₀, 𝐟, sing x, 𝐟, sing y] :=
          split_at hcomm [𝐞, sing x₀, 𝐟, sing x] 𝐞 𝐟 [sing y]
      _ = _ := congr (congrArg (· + ·) (qe_pr hcomm hP hsum hprod hhalf κ [sing x₀, 𝐟, sing x] [sing y]))
          ((tr_rot hcomm [𝐞, sing x₀] [𝐟, sing x, 𝐟, sing y]).trans
            ((qf_pr hcomm hP hsum hprod hhalf [sing x] [sing y, 𝐞, sing x₀]).trans
              (congrArg ((tP [𝐟, sing x]) * ·) (tr_rot hcomm [𝐟, sing y] [𝐞, sing x₀]))))
  rw [h, d_eq hone hcomm hP hsum hprod hhalf hκ x]
  ring_eq

/-- (2,2) entry. -/
theorem entry_d (x y : Γ) : T (gΓ.mul x y) - aF gΓ T g mu κ (gΓ.mul x y)
    = BF gΓ T g lam mu κ x₀ x * uinv * BF gΓ T g lam mu κ y y₀ + (T x - aF gΓ T g mu κ x) * (T y - aF gΓ T g mu κ y) := by
  have hmain : T (gΓ.mul x y) - aF gΓ T g mu κ (gΓ.mul x y) = (tP [𝐟, sing x, 𝐞, sing y]) + (tP [𝐟, sing x]) * tP [𝐟, sing y] :=
    calc T (gΓ.mul x y) - aF gΓ T g mu κ (gΓ.mul x y) = tP [𝐟, sing (gΓ.mul x y)] := (d_eq hone hcomm hP hsum hprod hhalf hκ _).symm
      _ = tP [𝐟, sing x, sing y] := (merge_at hcomm [𝐟] x y []).symm
      _ = tP [𝐟, sing x, 𝐞 ++ 𝐟, sing y] := ins_ef hcomm hκ [𝐟, sing x] [sing y]
      _ = (tP [𝐟, sing x, 𝐞, sing y]) + tP [𝐟, sing x, 𝐟, sing y] := split_at hcomm [𝐟, sing x] 𝐞 𝐟 [sing y]
      _ = _ := congrArg ((tP [𝐟, sing x, 𝐞, sing y]) + ·) (qf_pr hcomm hP hsum hprod hhalf [sing x] [sing y])
  have hB : BF gΓ T g lam mu κ x₀ x * BF gΓ T g lam mu κ y y₀ = (tP [𝐟, sing x, 𝐞, sing y]) * BF gΓ T g lam mu κ x₀ y₀ :=
    calc BF gΓ T g lam mu κ x₀ x * BF gΓ T g lam mu κ y y₀
        = tP [𝐞, sing x₀, 𝐟, sing x, 𝐞, sing y, 𝐟, sing y₀] :=
          (qe_pr hcomm hP hsum hprod hhalf κ [sing x₀, 𝐟, sing x] [sing y, 𝐟, sing y₀]).symm
      _ = tP [𝐟, sing x, 𝐞, sing y, 𝐟, sing y₀, 𝐞, sing x₀] := tr_rot hcomm [𝐞, sing x₀] [𝐟, sing x, 𝐞, sing y, 𝐟, sing y₀]
      _ = (tP [𝐟, sing x, 𝐞, sing y]) * tP [𝐟, sing y₀, 𝐞, sing x₀] :=
          qf_pr hcomm hP hsum hprod hhalf [sing x, 𝐞, sing y] [sing y₀, 𝐞, sing x₀]
      _ = _ := congrArg ((tP [𝐟, sing x, 𝐞, sing y]) * ·) (tr_rot hcomm [𝐟, sing y₀] [𝐞, sing x₀])
  rw [d_eq hone hcomm hP hsum hprod hhalf hκ x, d_eq hone hcomm hP hsum hprod hhalf hκ y] at hmain
  exact lin_comb (by ring_eq) (lc_add (lc_add (lc_add lc_zero 1 hmain) (-uinv) hB)
    (-(tP [𝐟, sing x, 𝐞, sing y])) hu)

/-- **Pseudocharacter ⇒ representation** (PROVED): for every group Γ, every commutative ring R with 2
invertible and every 2-dimensional pseudocharacter T : Γ → R, if g ∈ Γ has λ + μ = T(g),
2λμ = T(g)² − T(g²) with λ − μ a unit, and the pairing B(x₀, y₀) is a unit, then ρ is a representation of Γ
in M₂(R) with trace T. -/
theorem pseudochar_rep :
    rho gΓ T g x₀ y₀ lam mu κ uinv gΓ.one = M2.one ∧
    (∀ x y, rho gΓ T g x₀ y₀ lam mu κ uinv (gΓ.mul x y)
      = M2.mul (rho gΓ T g x₀ y₀ lam mu κ uinv x) (rho gΓ T g x₀ y₀ lam mu κ uinv y)) ∧
    (∀ x, M2.trace (rho gΓ T g x₀ y₀ lam mu κ uinv x) = T x) := by
  have a1 : aF gΓ T g mu κ gΓ.one = 1 := (unit_at hcomm [𝐞] []).trans (tr_e hone hsum hκ)
  have b1 : BF gΓ T g lam mu κ gΓ.one y₀ = 0 :=
    (unit_at hcomm [𝐞] [𝐟, sing y₀]).trans (ef_zero hone hcomm hP hsum hprod hhalf hκ [sing y₀])
  have c1 : BF gΓ T g lam mu κ x₀ gΓ.one = 0 :=
    (unit_at hcomm [𝐞, sing x₀, 𝐟] []).trans ((tr_rot hcomm [𝐞, sing x₀] [𝐟]).trans
      (fe_zero hone hcomm hP hsum hprod hhalf hκ [sing x₀]))
  refine ⟨?_, ?_, ?_⟩
  · simp only [rho, M2.one, M2.mk.injEq]
    refine ⟨a1, b1, by rw [c1, Semiring.zero_mul], ?_⟩
    rw [hone, a1]; ring_eq
  · intro x y
    simp only [rho, M2.mul, M2.mk.injEq]
    exact ⟨entry_a hone hcomm hP hsum hprod hhalf hκ hu x y, entry_b hone hcomm hP hsum hprod hhalf hκ hu x y,
      entry_c hone hcomm hP hsum hprod hhalf hκ hu x y, entry_d hone hcomm hP hsum hprod hhalf hκ hu x y⟩
  · intro x
    show aF gΓ T g mu κ x + (T x - aF gΓ T g mu κ x) = T x
    ring_eq

end theorems

/-- **Excursion data ⇒ representation, for GL₂(ℤ/n)** (PROVED): the pseudocharacter χ = Θ(f_tr)(·, 1) of any
excursion datum D (`gl2_Zmod_pseudocharacter`) is the trace of the representation ρ built from χ alone,
as soon as some g has λ + μ = χ(g), 2λμ = χ(g)² − χ(g²) with λ − μ a unit, 2 is a unit, and B(x₀, y₀) is a unit.
This is the step "pseudocharacter ⇒ parameter" of V. Lafforgue's construction, for GL₂, in the absolutely
irreducible case with an element of distinct eigenvalues in the coefficients. -/
theorem excursion_rep_Zmod (n : Nat) [NeZero n] {Γ : Type} {gΓ : Grp Γ}
    (D : ExcursionData gΓ (grpGL2 (isCSR_fin n)) (Fin n))
    {g x₀ y₀ : Γ} {lam mu κ half uinv : Fin n}
    (hsum : lam + mu = exChar D traceGL2 g)
    (hprod : lam * mu + lam * mu = exChar D traceGL2 g * exChar D traceGL2 g - exChar D traceGL2 (gΓ.mul g g))
    (hhalf : half + half = 1) (hκ : κ * (lam - mu) = 1)
    (hu : BF gΓ (exChar D traceGL2) g lam mu κ x₀ y₀ * uinv = 1) :
    rho gΓ (exChar D traceGL2) g x₀ y₀ lam mu κ uinv gΓ.one = M2.one ∧
    (∀ x y, rho gΓ (exChar D traceGL2) g x₀ y₀ lam mu κ uinv (gΓ.mul x y)
      = M2.mul (rho gΓ (exChar D traceGL2) g x₀ y₀ lam mu κ uinv x) (rho gΓ (exChar D traceGL2) g x₀ y₀ lam mu κ uinv y)) ∧
    (∀ x, M2.trace (rho gΓ (exChar D traceGL2) g x₀ y₀ lam mu κ uinv x) = exChar D traceGL2 x) :=
  pseudochar_rep (gl2_ring_pseudocharacter_one (isCSR_fin n) D) (gl2_ring_pseudocharacter_comm (isCSR_fin n) D)
    (gl2_Zmod_pseudocharacter n D) hsum hprod hhalf hκ hu

end Oracles.PseudocharRep
