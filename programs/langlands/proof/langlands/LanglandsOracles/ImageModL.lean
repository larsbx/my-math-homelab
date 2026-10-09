import LanglandsOracles.ImageMod2
import LanglandsOracles.Data

/-!
# Mod-ℓ image certificates by words: ρ̄_ℓ of the Cremona curves is surjective, ℓ ≤ 13.

A class pair (A, B) of GL₂(𝔽_ℓ) (characteristic polynomials with distinct roots, so single
conjugacy classes without scalars) is *certified* when every subgroup meeting both is the whole
group.  Instead of closing ⟨g, h⟩ for each pair — 480- or 2016-element closures — the certificate is:
1. S = {E₁₂(1), E₂₁(1), diag(1, ζ)} generates GL₂(𝔽_ℓ): a THEOREM (`gl2_generated`, row reduction by
   elementary matrices, each step undone by the inverse elementary matrix), given only that ζ generates
   𝔽_ℓ^× (`zetaGen`, an ℓ² kernel check); no closure is enumerated;
2. for the fixed representative gRep of A and every h ∈ B, three short words in {gRep, h} whose
   values are the elements of S (`wordsB`, verified by a few dozen products each);
3. for every g ∈ A a conjugator C with C·gRep·C⁻¹ = g (`witnessesA`).
Soundness (`pair_sound`, PROVED): a multiplicatively closed H containing g ∈ A and h ∈ B is
conjugated by C⁻¹ to H′ ∋ gRep, C⁻¹hC; C⁻¹hC is again in B (B is cut out by tr and tr², which are
conjugation-invariant); the words put S inside H′, the closure of S is GL₂(𝔽_ℓ), and conjugating back
gives GL₂(𝔽_ℓ) ⊆ H, using that conjugation by a unit preserves the enumerated GL₂(𝔽_ℓ) (a left-invertible
matrix kills no nonzero vector, `det_ne_zero_of_left_inverse`).  Everything specific to ℓ is packaged in
`FieldFacts ℓ` (decided or kernel-checked per ℓ in `ModLImages`).

Arithmetic input: for each curve, Lean's own point counts give a_{p₁}, a_{p₂} mod ℓ (`curves_ok`),
so ρ̄_ℓ(Frob_{p₁}) ∈ A and ρ̄_ℓ(Frob_{p₂}) ∈ B by Eichler–Shimura, the only imported step.  Results:
mod 5 for the 14 curves other than 11a1 (rational 5-torsion); mod 7, 11 and 13 for all 15.
Kernel bookkeeping that made this feasible: every arithmetic step on codes is a `Nat.*` call on literals (an
operator's instance chain is unfolded and cached link by link at every call, and that triples the kernel's
work); a class is enumerated in ℓ² + ℓ elements (`classMats`, PROVED complete) rather than found by scanning
ℓ⁴ codes, so nothing of size ℓ⁴ is evaluated; and the ℓ ≥ 11 checks lift the default heartbeat limit.  The per-ℓ instances and the headlines are in `ModLImages`.
-/
namespace Oracles

namespace Mat2

variable {n : Nat} [NeZero n]

-- ---------------------------------------------------------------- raw products --

/-- Raw product of base-n encoded matrices, mirroring `Fin` arithmetic digit by digit, through `Nat.*`
directly: an operator's instance chain is unfolded and cached link by link at every call, and that
triples the kernel's work. -/
def mulNat (n i j : Nat) : Nat :=
  let a := Nat.mod i n; let i1 := Nat.div i n; let b := Nat.mod i1 n; let i2 := Nat.div i1 n
  let c := Nat.mod i2 n; let d := Nat.mod (Nat.div i2 n) n
  let a' := Nat.mod j n; let j1 := Nat.div j n; let b' := Nat.mod j1 n; let j2 := Nat.div j1 n
  let c' := Nat.mod j2 n; let d' := Nat.mod (Nat.div j2 n) n
  Nat.add (Nat.mod (Nat.add (Nat.mul a a') (Nat.mul b c')) n)
    (Nat.mul n (Nat.add (Nat.mod (Nat.add (Nat.mul a b') (Nat.mul b d')) n)
      (Nat.mul n (Nat.add (Nat.mod (Nat.add (Nat.mul c a') (Nat.mul d c')) n)
        (Nat.mul n (Nat.mod (Nat.add (Nat.mul c b') (Nat.mul d d')) n))))))

theorem mulNat_eq (n : Nat) [NeZero n] (i j : Nat) : mulNat n i j = mulIdx n i j := by
  simp only [mulNat, mulIdx, encode, decode, M2.mul, finN, Fin.val_add, Fin.val_mul, ← Nat.add_mod]
  rfl

theorem mulNat_codes (x y : Mat2 n) : mulNat n (encode x) (encode y) = encode (M2.mul x y) := by
  rw [mulNat_eq]; simp only [mulIdx, decode_encode]

theorem decode_zero : decode n 0 = ⟨0, 0, 0, 0⟩ := by
  simp only [decode, Nat.zero_div]; rfl

theorem mulNat_zero_left (j : Nat) : mulNat n 0 j = 0 := by
  rw [mulNat_eq]
  show encode (M2.mul (decode n 0) (decode n j)) = 0
  rw [decode_zero]
  simp only [M2.mul, (isCSR_fin n).zero_mul, (isCSR_fin n).add_zero, encode, Fin.val_zero, Nat.mul_zero, Nat.add_zero]

/-- Words in two generators packed in a natural: 1 b₀ … b_{k−1} in binary (the leading 1 marks the length,
0 ↦ g, 1 ↦ h), evaluated left to right, so the last letter is the lowest bit; the fuel is the word itself.
Without the marker (w < 2) or out of fuel the value is 0. -/
def evalW (n g h : Nat) : Nat → Nat → Nat
  | 0, _ => 0
  | k + 1, w =>
    if Nat.blt w 2 then 0
    else if Nat.blt w 4 then (if Nat.beq (Nat.mod w 2) 1 then h else g)
    else mulNat n (evalW n g h k (Nat.div w 2)) (if Nat.beq (Nat.mod w 2) 1 then h else g)

def evalWord (n g h w : Nat) : Nat := evalW n g h w w

/-- A word's value is 0 or the code of an element of H when g, h are. -/
theorem evalW_codes (H : List (Mat2 n)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Nat}
    (hg : Codes H g) (hh : Codes H h) : ∀ k w, evalW n g h k w = 0 ∨ Codes H (evalW n g h k w)
  | 0, _ => Or.inl rfl
  | k + 1, w => by
    have hl : Codes H (if Nat.beq (Nat.mod w 2) 1 then h else g) := by split <;> assumption
    unfold evalW
    split
    · exact Or.inl rfl
    · split
      · exact Or.inr hl
      · rcases evalW_codes H hmul hg hh k (Nat.div w 2) with h0 | ⟨x, hx, hx'⟩
        · left; rw [h0, mulNat_zero_left]
        · obtain ⟨y, hy, hy'⟩ := hl
          exact Or.inr ⟨M2.mul x y, hmul x hx y hy, by rw [hx', hy', mulNat_codes]⟩

-- ---------------------------------------------------------------- group algebra in M₂(ℤ/n) --

local notation "R" => isCSR_fin n

theorem mul_inv_cancel_left' {C C' : Mat2 n} (h : M2.mul C C' = M2.one) (t : Mat2 n) :
    M2.mul C (M2.mul C' t) = t := by
  rw [← M2.mul_assoc R, h, M2.one_mul R]

theorem conj_mul' {C C' : Mat2 n} (h : M2.mul C C' = M2.one) (x y : Mat2 n) :
    M2.mul (M2.mul (M2.mul C' x) C) (M2.mul (M2.mul C' y) C) = M2.mul (M2.mul C' (M2.mul x y)) C := by
  simp only [M2.mul_assoc R, mul_inv_cancel_left' h]

theorem conj_conj' {C C' : Mat2 n} (h : M2.mul C' C = M2.one) (g : Mat2 n) :
    M2.mul (M2.mul C' (M2.mul (M2.mul C g) C')) C = g := by
  simp only [M2.mul_assoc R, mul_inv_cancel_left' h]
  rw [h, M2.mul_one R]

theorem conj_cancel' {C C' : Mat2 n} (h : M2.mul C C' = M2.one) (z : Mat2 n) :
    M2.mul (M2.mul C (M2.mul (M2.mul C' z) C)) C' = z := by
  simp only [M2.mul_assoc R, mul_inv_cancel_left' h]
  rw [h, M2.mul_one R]

theorem trace_conj' {C C' : Mat2 n} (h : M2.mul C C' = M2.one) (x : Mat2 n) :
    (M2.mul (M2.mul C' x) C).trace = x.trace := by
  rw [M2.trace_mul_comm R, ← M2.mul_assoc R, h, M2.one_mul R]

def applyV (w : Mat2 n) (v : Fin n × Fin n) : Fin n × Fin n := (w.a * v.1 + w.b * v.2, w.c * v.1 + w.d * v.2)

theorem apply_mul (w w' : Mat2 n) (v : Fin n × Fin n) : applyV (M2.mul w w') v = applyV w (applyV w' v) := by
  haveI : Std.Associative (α := Fin n) (· + ·) := ⟨(R).add_assoc⟩
  haveI : Std.Commutative (α := Fin n) (· + ·) := ⟨(R).add_comm⟩
  simp only [applyV, M2.mul, (R).add_mul, (R).mul_add, (R).mul_assoc, Prod.mk.injEq]
  exact ⟨by ac_rfl, by ac_rfl⟩

theorem apply_one (v : Fin n × Fin n) : applyV (M2.one : Mat2 n) v = v := by
  obtain ⟨v1, v2⟩ := v
  simp only [applyV, M2.one, (R).one_mul, (R).zero_mul, (R).add_zero, (R).zero_add]

theorem apply_zero (w : Mat2 n) : applyV w (0, 0) = (0, 0) := by
  simp only [applyV, (R).mul_zero, (R).add_zero]

theorem mul_zero_mat (w : Mat2 n) : M2.mul w ⟨0, 0, 0, 0⟩ = ⟨0, 0, 0, 0⟩ := by
  simp only [M2.mul, (R).mul_zero, (R).add_zero]

/-- A scalar inverse by search (kernel-evaluable; `invOf_spec` from the inverse table). -/
def invOf (n : Nat) [NeZero n] (b : Fin n) : Fin n :=
  finN (((List.range n).find? fun u => b.val * u % n == 1).getD 0)

/-- The facts about ℤ/n that the certificate needs, decided or kernel-checked per n. -/
structure FieldFacts (n : Nat) [NeZero n] : Prop where
  trace_sq : ∀ x : Mat2 n, (M2.mul x x).trace = x.trace * x.trace - 2 * x.det
  kernel_vectors : ∀ a b c d : Fin n, a * d - b * c = 0 →
    applyV ⟨a, b, c, d⟩ (d, 0 - c) = (0, 0) ∧ applyV ⟨a, b, c, d⟩ (0 - b, a) = (0, 0)
  neg_eq_zero : ∀ c : Fin n, 0 - c = 0 → c = 0
  one_ne_zero : (1 : Fin n) ≠ 0
  two_ne_zero : (2 : Fin n) ≠ 0
  sub_eq : ∀ x y : Fin n, x - y = x + (0 - y)
  invOf_spec : ∀ b : Fin n, b ≠ 0 → b * invOf n b = 1
  inv : ∀ z ∈ gl n, ∃ z' : Mat2 n, M2.mul z' z = M2.one

section withFieldFacts

variable (ff : FieldFacts n)
include ff

theorem det_ne_zero_of_left_inverse (w w' : Mat2 n) (h : M2.mul w' w = M2.one) : w.det.val ≠ 0 := by
  intro hz
  obtain ⟨a, b, c, d⟩ := w
  have hd : a * d - b * c = 0 := Fin.ext hz
  obtain ⟨k1, k2⟩ := ff.kernel_vectors a b c d hd
  have fix : ∀ v, applyV ⟨a, b, c, d⟩ v = (0, 0) → v = (0, 0) := by
    intro v hv
    have e : applyV (M2.mul w' ⟨a, b, c, d⟩) v = v := by rw [h, apply_one]
    rw [apply_mul, hv, apply_zero] at e
    exact e.symm
  have e1 := fix _ k1
  have e2 := fix _ k2
  obtain ⟨hd0, hc0⟩ := Prod.mk.inj e1
  obtain ⟨hb0, ha0⟩ := Prod.mk.inj e2
  have hc : c = 0 := ff.neg_eq_zero c hc0
  have hb : b = 0 := ff.neg_eq_zero b hb0
  subst hd0 ha0 hc hb
  have : M2.mul w' ⟨0, 0, 0, 0⟩ = M2.one := h
  rw [mul_zero_mat] at this
  exact ff.one_ne_zero (congrArg M2.a this).symm

theorem conj_mem_gl {C C' : Mat2 n} (hCC' : M2.mul C C' = M2.one) (hC'C : M2.mul C' C = M2.one)
    {z : Mat2 n} (hz : z ∈ gl n) : M2.mul (M2.mul C' z) C ∈ gl n := by
  obtain ⟨z', hz'⟩ := ff.inv z hz
  refine mem_gl _ (det_ne_zero_of_left_inverse ff _ (M2.mul (M2.mul C' z') C) ?_)
  rw [conj_mul' hCC', hz', M2.mul_one R, hC'C]

end withFieldFacts

-- ---------------------------------------------------------------- the certificate --

-- ---------------------------------------------------------------- generation of GL₂(𝔽_ℓ) by elementary matrices --

/-- Elementary and diagonal matrices. -/
def E12 (u : Fin n) : Mat2 n := ⟨1, u, 0, 1⟩
def E21 (u : Fin n) : Mat2 n := ⟨1, 0, u, 1⟩
def diag (u : Fin n) : Mat2 n := ⟨1, 0, 0, u⟩

theorem E12_mul (u v : Fin n) : M2.mul (E12 u) (E12 v) = E12 (u + v) := by
  simp only [M2.mul, E12, (R).one_mul, (R).mul_one, (R).mul_zero, (R).zero_mul, (R).add_zero, (R).zero_add, (R).add_comm v u]

theorem E21_mul (u v : Fin n) : M2.mul (E21 u) (E21 v) = E21 (u + v) := by
  simp only [M2.mul, E21, (R).one_mul, (R).mul_one, (R).mul_zero, (R).zero_mul, (R).add_zero, (R).zero_add]

theorem diag_mul (u v : Fin n) : M2.mul (diag u) (diag v) = diag (u * v) := by
  simp only [M2.mul, diag, (R).one_mul, (R).mul_one, (R).mul_zero, (R).zero_mul, (R).add_zero, (R).zero_add]

/-- Powers in M₂(ℤ/n) and in ℤ/n. -/
def M2pow (x : Mat2 n) : Nat → Mat2 n
  | 0 => M2.one
  | k + 1 => M2.mul (M2pow x k) x

def finPow (z : Fin n) : Nat → Fin n
  | 0 => 1
  | k + 1 => finPow z k * z

theorem E12_pow (k : Nat) : M2pow (E12 (1 : Fin n)) k = E12 (finN k) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    show M2.mul (M2pow (E12 1) k) (E12 1) = _
    rw [ih, E12_mul]
    exact congrArg E12 (Fin.ext (Nat.add_mod k 1 n).symm)

theorem E21_pow (k : Nat) : M2pow (E21 (1 : Fin n)) k = E21 (finN k) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    show M2.mul (M2pow (E21 1) k) (E21 1) = _
    rw [ih, E21_mul]
    exact congrArg E21 (Fin.ext (Nat.add_mod k 1 n).symm)

theorem diag_pow (z : Fin n) (k : Nat) : M2pow (diag z) k = diag (finPow z k) := by
  induction k with
  | zero => rfl
  | succ k ih => show M2.mul (M2pow (diag z) k) (diag z) = diag (finPow z k * z); rw [ih, diag_mul]

theorem finPow_val (z k : Nat) : (finPow (finN z : Fin n) k).val = z ^ k % n := by
  induction k with
  | zero => rfl
  | succ k ih =>
    show (finPow (finN z) k * finN z).val = _
    rw [Fin.val_mul, ih, Nat.pow_succ]
    exact (Nat.mul_mod _ _ _).symm

/-- ζ generates (ℤ/n)^×: every nonzero residue is a power of ζ (n² operations, decided per n). -/
def zetaGen (n z : Nat) : Bool :=
  (List.range n).all fun d => d == 0 || (List.range n).any fun k => z ^ k % n == d

theorem zetaGen_sound {z : Nat} (h : zetaGen n z = true) (d : Fin n) (hd : d ≠ 0) : ∃ k, finPow (finN z) k = d := by
  have hd' := List.all_eq_true.mp h d.val (List.mem_range.mpr d.isLt)
  have hne : (d.val == 0) = false := by
    cases hb : d.val == 0
    · rfl
    · exact absurd (Fin.ext (beq_iff_eq.mp hb)) hd
  rw [hne, Bool.false_or] at hd'
  obtain ⟨k, _, hk⟩ := List.any_eq_true.mp hd'
  exact ⟨k, Fin.ext (by rw [finPow_val]; exact beq_iff_eq.mp hk)⟩

section cancel

variable (hs : ∀ x y : Fin n, x - y = x + (0 - y))
include hs

theorem neg_add_cancel (x : Fin n) : (0 - x) + x = 0 := by
  rw [(R).add_comm, ← hs, Fin.sub_self]

theorem add_neg_cancel (x : Fin n) : x + (0 - x) = 0 := by
  rw [← hs, Fin.sub_self]

theorem add_sub_cancel' (a b : Fin n) : a + (b - a) = b := by
  rw [hs, (R).add_comm b, ← (R).add_assoc, add_neg_cancel hs, (R).zero_add]

theorem sub_zero' (x : Fin n) : x - 0 = x := by
  rw [hs, Fin.sub_self, (R).add_zero]

theorem neg_unique {u v : Fin n} (h : u + v = 0) : u = 0 - v :=
  calc u = u + (v + (0 - v)) := by rw [add_neg_cancel hs, (R).add_zero]
    _ = (u + v) + (0 - v) := by rw [(R).add_assoc]
    _ = 0 - v := by rw [h, (R).zero_add]

theorem sub_sub_cancel (x y : Fin n) : x - (x - y) = y := by
  have h1 : ((0 - x) + y) + (x + (0 - y)) = 0 := by
    rw [(R).add_assoc, ← (R).add_assoc y, (R).add_comm y x, (R).add_assoc x, add_neg_cancel hs, (R).add_zero, neg_add_cancel hs]
  rw [hs x (x - y), hs x y, ← neg_unique hs h1, ← (R).add_assoc, add_neg_cancel hs, (R).zero_add]

theorem add_sub_cancel_left (a d : Fin n) : (a + d) - a = d := by
  rw [hs, (R).add_comm a d, (R).add_assoc, add_neg_cancel hs, (R).add_zero]

end cancel

section generation

variable (ff : FieldFacts n)
include ff

theorem E12_neg_mul (u : Fin n) : M2.mul (E12 (0 - u)) (E12 u) = M2.one := by
  rw [E12_mul, neg_add_cancel ff.sub_eq]; rfl

theorem E12_mul_neg (u : Fin n) : M2.mul (E12 u) (E12 (0 - u)) = M2.one := by
  rw [E12_mul, add_neg_cancel ff.sub_eq]; rfl

theorem E21_neg_mul (u : Fin n) : M2.mul (E21 (0 - u)) (E21 u) = M2.one := by
  rw [E21_mul, neg_add_cancel ff.sub_eq]; rfl

theorem E21_mul_neg (u : Fin n) : M2.mul (E21 u) (E21 (0 - u)) = M2.one := by
  rw [E21_mul, add_neg_cancel ff.sub_eq]; rfl

theorem mul_mem_gl {x y : Mat2 n} (hx : x ∈ gl n) (hy : y ∈ gl n) : M2.mul x y ∈ gl n := by
  obtain ⟨x', hx'⟩ := ff.inv x hx
  obtain ⟨y', hy'⟩ := ff.inv y hy
  refine mem_gl _ (det_ne_zero_of_left_inverse ff _ (M2.mul y' x') ?_)
  rw [M2.mul_assoc R, ← M2.mul_assoc R x', hx', M2.one_mul R, hy']

theorem E12_mem_gl (u : Fin n) : E12 u ∈ gl n :=
  mem_gl _ (det_ne_zero_of_left_inverse ff _ (E12 (0 - u)) (E12_neg_mul ff u))

theorem E21_mem_gl (u : Fin n) : E21 u ∈ gl n :=
  mem_gl _ (det_ne_zero_of_left_inverse ff _ (E21 (0 - u)) (E21_neg_mul ff u))

variable (H : List (Mat2 n)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H)
include hmul

omit ff in
theorem pow_mem {x : Mat2 n} (hx : x ∈ H) : ∀ k, M2pow x (k + 1) ∈ H
  | 0 => by show M2.mul M2.one x ∈ H; rw [M2.one_mul R]; exact hx
  | k + 1 => hmul _ (pow_mem hx k) x hx

omit ff in
theorem E12_mem (hE : E12 (1 : Fin n) ∈ H) (u : Fin n) : E12 u ∈ H := by
  have h := pow_mem H hmul hE (u.val + n - 1)
  rw [E12_pow] at h
  have e : finN (u.val + n - 1 + 1) = u := Fin.ext (by
    show (u.val + n - 1 + 1) % n = u.val
    rw [Nat.sub_add_cancel (Nat.le_trans (Nat.pos_of_neZero n) (Nat.le_add_left n u.val)), Nat.add_mod_right,
      Nat.mod_eq_of_lt u.isLt])
  rwa [e] at h

omit ff in
theorem E21_mem (hE : E21 (1 : Fin n) ∈ H) (u : Fin n) : E21 u ∈ H := by
  have h := pow_mem H hmul hE (u.val + n - 1)
  rw [E21_pow] at h
  have e : finN (u.val + n - 1 + 1) = u := Fin.ext (by
    show (u.val + n - 1 + 1) % n = u.val
    rw [Nat.sub_add_cancel (Nat.le_trans (Nat.pos_of_neZero n) (Nat.le_add_left n u.val)), Nat.add_mod_right,
      Nat.mod_eq_of_lt u.isLt])
  rwa [e] at h

omit ff in
theorem diag_mem (hE : E12 (1 : Fin n) ∈ H) {z : Nat} (hz : zetaGen n z = true) (hD : diag (finN z) ∈ H)
    (d : Fin n) (hd : d ≠ 0) : diag d ∈ H := by
  obtain ⟨k, hk⟩ := zetaGen_sound hz d hd
  rw [← hk, ← diag_pow]
  cases k with
  | zero => exact E12_mem H hmul hE 0
  | succ k => exact pow_mem H hmul hD k

omit ff in
theorem descent_left {x x' g : Mat2 n} (hxx' : M2.mul x' x = M2.one) (hx' : x' ∈ H) (h : M2.mul x g ∈ H) : g ∈ H := by
  have := hmul _ hx' _ h
  rwa [← M2.mul_assoc R, hxx', M2.one_mul R] at this

omit ff in
theorem descent_right {y y' g : Mat2 n} (hyy' : M2.mul y y' = M2.one) (hy' : y' ∈ H) (h : M2.mul g y ∈ H) : g ∈ H := by
  have := hmul _ h _ hy'
  rwa [M2.mul_assoc R, hyy', M2.mul_one R] at this

variable (hE12 : E12 (1 : Fin n) ∈ H) (hE21 : E21 (1 : Fin n) ∈ H) {z : Nat} (hz : zetaGen n z = true) (hD : diag (finN z) ∈ H)
include hE12 hE21 hz hD

/-- Row reduction: for c ≠ 0, E₂₁(−c)·E₁₂(t)·g·E₁₂(−b₁) = diag(1, δ) with t = (1 − a)c⁻¹, so g is a
product of elements of H, each step undone by the inverse elementary matrix. -/
theorem generated_of_c_ne (g : Mat2 n) (hg : g ∈ gl n) (hc : g.c ≠ 0) : g ∈ H := by
  obtain ⟨a, b, c, d⟩ := g
  simp only at hc
  obtain ⟨ci, hci⟩ : ∃ ci, c * ci = 1 := ⟨_, ff.invOf_spec c hc⟩
  have h1 : M2.mul (E12 ((1 - a) * ci)) ⟨a, b, c, d⟩ = ⟨1, b + (1 - a) * ci * d, c, d⟩ := by
    have ha : a + (1 - a) * ci * c = 1 := by
      rw [(R).mul_assoc, (R).mul_comm ci c, hci, (R).mul_one, add_sub_cancel' ff.sub_eq a 1]
    simp only [M2.mul, E12, (R).one_mul, (R).zero_mul, (R).zero_add, ha]
  generalize (1 - a) * ci = t at h1
  generalize b + t * d = b₁ at h1
  have h2 : M2.mul (E21 (0 - c)) ⟨1, b₁, c, d⟩ = ⟨1, b₁, 0, (0 - c) * b₁ + d⟩ := by
    simp only [M2.mul, E21, (R).one_mul, (R).mul_one, (R).zero_mul, (R).add_zero, neg_add_cancel ff.sub_eq c]
  generalize (0 - c) * b₁ + d = δ at h2
  have h3 : M2.mul ⟨1, b₁, 0, δ⟩ (E12 (0 - b₁)) = diag δ := by
    simp only [M2.mul, E12, diag, (R).one_mul, (R).mul_one, (R).zero_mul, (R).mul_zero, (R).zero_add, (R).add_zero,
      neg_add_cancel ff.sub_eq b₁]
  have hg1 : (⟨1, b₁, c, d⟩ : Mat2 n) ∈ gl n := h1 ▸ mul_mem_gl ff (E12_mem_gl ff t) hg
  have hg2 : (⟨1, b₁, 0, δ⟩ : Mat2 n) ∈ gl n := h2 ▸ mul_mem_gl ff (E21_mem_gl ff (0 - c)) hg1
  have hg3 : diag δ ∈ gl n := h3 ▸ mul_mem_gl ff hg2 (E12_mem_gl ff (0 - b₁))
  have hδ : δ ≠ 0 := by
    intro h0
    have := bne_iff_ne.mp (List.mem_filter.mp hg3).2
    apply this
    show (1 * δ - 0 * 0).val = 0
    rw [(R).one_mul, (R).zero_mul, sub_zero' ff.sub_eq, h0]; rfl
  have hH3 : M2.mul ⟨1, b₁, 0, δ⟩ (E12 (0 - b₁)) ∈ H := by rw [h3]; exact diag_mem H hmul hE12 hz hD δ hδ
  have hH2 : M2.mul (E21 (0 - c)) ⟨1, b₁, c, d⟩ ∈ H := by
    rw [h2]; exact descent_right H hmul (E12_neg_mul ff b₁) (E12_mem H hmul hE12 b₁) hH3
  have hH1 : M2.mul (E12 t) ⟨a, b, c, d⟩ ∈ H := by
    rw [h1]; exact descent_left H hmul (E21_mul_neg ff c) (E21_mem H hmul hE21 c) hH2
  exact descent_left H hmul (E12_neg_mul ff t) (E12_mem H hmul hE12 (0 - t)) hH1

/-- **E₁₂(1), E₂₁(1), diag(1, ζ) generate GL₂(ℤ/n)** when ζ generates (ℤ/n)^× (for n prime, with the field
facts): any multiplicatively closed set containing them contains every invertible matrix. -/
theorem gl2_generated : ∀ g ∈ gl n, g ∈ H := by
  intro g hg
  by_cases hc : g.c = 0
  · have hdet : g.det.val ≠ 0 := bne_iff_ne.mp (List.mem_filter.mp hg).2
    have ha : g.a ≠ 0 := fun h0 => hdet (by
      show (g.a * g.d - g.b * g.c).val = 0
      rw [h0, hc, (R).zero_mul, (R).mul_zero, Fin.sub_self]; rfl)
    have hc' : (M2.mul (E21 1) g).c ≠ 0 := by
      show 1 * g.a + 1 * g.c ≠ 0
      rw [(R).one_mul, (R).one_mul, hc, (R).add_zero]; exact ha
    have := generated_of_c_ne ff H hmul hE12 hE21 hz hD _ (mul_mem_gl ff (E21_mem_gl ff 1) hg) hc'
    exact descent_left H hmul (E21_neg_mul ff 1) (E21_mem H hmul hE21 (0 - 1)) this
  · exact generated_of_c_ne ff H hmul hE12 hE21 hz hD g hg hc

end generation

-- ---------------------------------------------------------------- the classes --

/-- The matrices with trace t and determinant d, enumerated in at most n² + n elements: the (2,2) entry is
t − a, and for b ≠ 0 the entry c = (a(t − a) − d)·b⁻¹ is determined, while for b = 0 the entry c is free and
a(t − a) = d. -/
def classMats (n : Nat) [NeZero n] (t d : Fin n) : List (Mat2 n) :=
  (fins n).flatMap fun a => (fins n).flatMap fun b =>
    if b = 0 then (if a * (t - a) = d then (fins n).map fun c => ⟨a, 0, c, t - a⟩ else [])
    else [⟨a, b, (a * (t - a) - d) * invOf n b, t - a⟩]

/-- **The enumeration is complete.** -/
theorem mem_classMats (ff : FieldFacts n) {t d : Fin n} (g : Mat2 n) (ht : g.trace = t) (hd : g.det = d) :
    g ∈ classMats n t d := by
  obtain ⟨a, b, c, d'⟩ := g
  have ht : a + d' = t := ht
  have hd : a * d' - b * c = d := hd
  have hd' : d' = t - a := by rw [← ht, add_sub_cancel_left ff.sub_eq]
  subst hd'
  unfold classMats
  refine List.mem_flatMap.mpr ⟨a, mem_fins a, List.mem_flatMap.mpr ⟨b, mem_fins b, ?_⟩⟩
  by_cases hb : b = 0
  · subst hb
    rw [ite_eq_left rfl]
    have : a * (t - a) = d := by rw [← hd, (R).zero_mul, sub_zero' ff.sub_eq]
    rw [ite_eq_left this]
    exact List.mem_map.mpr ⟨c, mem_fins c, rfl⟩
  · rw [ite_eq_right hb]
    have hbc : b * c = a * (t - a) - d := by rw [← hd, sub_sub_cancel ff.sub_eq]
    have hc : c = (a * (t - a) - d) * invOf n b := by
      rw [← hbc, (R).mul_comm b c, (R).mul_assoc, ff.invOf_spec b hb, (R).mul_one]
    rw [hc]
    exact List.mem_cons_self ..

/-- 2·det x = tr(x)² − tr(x²) (Cayley–Hamilton), so the determinant is conjugation-invariant when 2 is
invertible — without determinant multiplicativity. -/
theorem two_mul_det (ff : FieldFacts n) (x : Mat2 n) : 2 * x.det = x.trace * x.trace - (M2.mul x x).trace := by
  rw [ff.trace_sq, sub_sub_cancel ff.sub_eq]

theorem det_conj (ff : FieldFacts n) {C C' : Mat2 n} (h : M2.mul C C' = M2.one) (x : Mat2 n) :
    Mat2.det (M2.mul (M2.mul C' x) C) = x.det := by
  have e : 2 * Mat2.det (M2.mul (M2.mul C' x) C) = 2 * x.det := by
    rw [two_mul_det ff, two_mul_det ff, conj_mul' h, trace_conj' h, trace_conj' h]
  have h2 := ff.invOf_spec 2 ff.two_ne_zero
  rw [← (R).one_mul (Mat2.det (M2.mul (M2.mul C' x) C)), ← (R).one_mul x.det, ← h2, (R).mul_comm 2, (R).mul_assoc,
    (R).mul_assoc, e]

/-- S is [E₁₂(1), E₂₁(1), diag(1, ζ)] and ζ generates (ℤ/n)^×: with `gl2_generated`, S generates GL₂. -/
def S_generates (n : Nat) [NeZero n] (z : Nat) (S : List Nat) : Bool :=
  S == [encode (E12 (1 : Fin n)), encode (E21 (1 : Fin n)), encode (diag (finN z) : Mat2 n)] && zetaGen n z

/-- A predicate checked pointwise along two lists of the same length (the certificate lists its data in
the enumeration order of the class, so no search is needed). -/
def pointwise (p : α → β → Bool) : List α → List β → Bool
  | [], [] => true
  | a :: as, b :: bs => p a b && pointwise p as bs
  | _, _ => false

theorem pointwise_sound {p : α → β → Bool} : ∀ {l₁ : List α} {l₂ : List β}, pointwise p l₁ l₂ = true →
    ∀ a ∈ l₁, ∃ b ∈ l₂, p a b = true
  | [], _, _, _, ha => absurd ha List.not_mem_nil
  | _ :: _, [], h, _, _ => absurd h Bool.false_ne_true
  | a :: as, b :: bs, h, x, hx => by
    have h1 := (Bool.and_eq_true _ _ |>.mp h).1
    have h2 := (Bool.and_eq_true _ _ |>.mp h).2
    rcases List.mem_cons.mp hx with rfl | hx
    · exact ⟨b, List.mem_cons_self .., h1⟩
    · obtain ⟨y, hy, hp⟩ := pointwise_sound h2 x hx
      exact ⟨y, List.mem_cons_of_mem _ hy, hp⟩

def pairOk (n : Nat) [NeZero n] (S : List Nat) (pr : PairCert) : Bool :=
  encode (decode n pr.gRep) == pr.gRep &&
  pointwise (fun (g : Mat2 n) w =>
    Nat.beq w.1 (encode g) && Nat.beq (mulNat n (mulNat n w.2.1 pr.gRep) w.2.2) (encode g)
      && Nat.beq (mulNat n w.2.1 w.2.2) (encode (M2.one : Mat2 n)) && Nat.beq (mulNat n w.2.2 w.2.1) (encode (M2.one : Mat2 n)))
    (classMats n (finN pr.tA) (finN pr.dA)) pr.witnessesA &&
  pointwise (fun (h : Mat2 n) e =>
    Nat.beq e.1 (encode h) && S.all fun s => e.2.any fun sw => Nat.beq sw.1 s && Nat.beq (evalWord n pr.gRep e.1 sw.2) s)
    (classMats n (finN pr.tB) (finN pr.dB)) pr.wordsB

/-- A matrix with (1,1) entry 1 has a nonzero code (1 ≠ 0 in ℤ/n). -/
theorem encode_ne_zero (ff : FieldFacts n) {x : Mat2 n} (hx : x.a = 1) : encode x ≠ 0 := by
  intro h
  unfold encode at h
  exact ff.one_ne_zero (Fin.ext (hx ▸ (Nat.eq_zero_of_add_eq_zero h).1))

theorem code_eq {i j : Nat} {m : Mat2 n} (e : Nat.beq (mulNat n i j) (encode m) = true) :
    M2.mul (decode n i) (decode n j) = m := by
  have := Nat.eq_of_beq_eq_true e
  rw [mulNat_eq] at this
  exact encode_inj this

set_option maxRecDepth 8192 in
/-- **Soundness of a certified pair.** -/
theorem pair_sound (ff : FieldFacts n) (z : Nat) (S : List Nat) (hS : S_generates n z S = true) (pr : PairCert) (hok : pairOk n S pr = true)
    (H : List (Mat2 n)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H)
    {g h : Mat2 n} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN pr.tA ∧ g.det = finN pr.dA) (hB : h.trace = finN pr.tB ∧ h.det = finN pr.dB) :
    ∀ z ∈ gl n, z ∈ H := by
  unfold pairOk at hok
  have h4 := (Bool.and_eq_true _ _ |>.mp hok).2
  have h3 := (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hok).1).2
  have hgRep : encode (decode n pr.gRep) = pr.gRep := beq_iff_eq.mp (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hok).1).1
  -- the conjugator of g
  obtain ⟨w, _, hw⟩ := pointwise_sound h3 g (mem_classMats ff g hA.1 hA.2)
  have hw4 := (Bool.and_eq_true _ _ |>.mp hw).2
  have hw3 := (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hw).1).2
  have hw2 := (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hw).1).1).2
  have hCg : M2.mul (M2.mul (decode n w.2.1) (decode n pr.gRep)) (decode n w.2.2) = g := by
    have := code_eq hw2
    rw [mulNat_eq] at this
    simp only [mulIdx, decode_encode] at this
    exact this
  have hCC' : M2.mul (decode n w.2.1) (decode n w.2.2) = M2.one := code_eq hw3
  have hC'C : M2.mul (decode n w.2.2) (decode n w.2.1) = M2.one := code_eq hw4
  generalize decode n w.2.1 = C at hCg hCC' hC'C
  generalize decode n w.2.2 = C' at hCg hCC' hC'C
  -- conjugate H
  let H' := H.map fun x => M2.mul (M2.mul C' x) C
  have hmul' : ∀ x ∈ H', ∀ y ∈ H', M2.mul x y ∈ H' := by
    intro x hx y hy
    obtain ⟨x0, hx0, rfl⟩ := List.mem_map.mp hx
    obtain ⟨y0, hy0, rfl⟩ := List.mem_map.mp hy
    exact List.mem_map.mpr ⟨M2.mul x0 y0, hmul x0 hx0 y0 hy0, (conj_mul' hCC' x0 y0).symm⟩
  have hgRep' : decode n pr.gRep ∈ H' := List.mem_map.mpr ⟨g, hg, by rw [← hCg, conj_conj' hC'C]⟩
  have hh' : M2.mul (M2.mul C' h) C ∈ H' := List.mem_map.mpr ⟨h, hh, rfl⟩
  have hB' : (M2.mul (M2.mul C' h) C).trace = finN pr.tB ∧ Mat2.det (M2.mul (M2.mul C' h) C) = finN pr.dB :=
    ⟨by rw [trace_conj' hCC', hB.1], by rw [det_conj ff hCC', hB.2]⟩
  -- the words put S inside H′
  obtain ⟨e, _, he⟩ := pointwise_sound h4 _ (mem_classMats ff _ hB'.1 hB'.2)
  have he1 : e.1 = encode (M2.mul (M2.mul C' h) C) := Nat.eq_of_beq_eq_true (Bool.and_eq_true _ _ |>.mp he).1
  have hwords := (Bool.and_eq_true _ _ |>.mp he).2
  unfold S_generates at hS
  have hSeq : S = [encode (E12 (1 : Fin n)), encode (E21 (1 : Fin n)), encode (diag (finN z) : Mat2 n)] :=
    beq_iff_eq.mp (Bool.and_eq_true _ _ |>.mp hS).1
  have hz : zetaGen n z = true := (Bool.and_eq_true _ _ |>.mp hS).2
  have hs0 : ∀ s ∈ S, s ≠ 0 := by
    rw [hSeq]
    intro s hs
    rcases List.mem_cons.mp hs with rfl | hs
    · exact encode_ne_zero ff rfl
    rcases List.mem_cons.mp hs with rfl | hs
    · exact encode_ne_zero ff rfl
    rcases List.mem_cons.mp hs with rfl | hs
    · exact encode_ne_zero ff rfl
    exact absurd hs List.not_mem_nil
  have hSH : ∀ s ∈ S, Codes H' s := by
    intro s hs
    obtain ⟨sw, _, hsw⟩ := List.any_eq_true.mp (List.all_eq_true.mp hwords s hs)
    have hev : evalWord n pr.gRep e.1 sw.2 = s := Nat.eq_of_beq_eq_true (Bool.and_eq_true _ _ |>.mp hsw).2
    rcases evalW_codes H' hmul' ⟨decode n pr.gRep, hgRep', hgRep.symm⟩ ⟨_, hh', he1⟩ sw.2 sw.2 with h0 | hc
    · exact absurd (hev ▸ h0) (hs0 s hs)
    · exact hev ▸ hc
  have hmem : ∀ s : Mat2 n, encode s ∈ S → s ∈ H' := fun s hs => by
    obtain ⟨t, ht, e⟩ := hSH _ hs
    exact encode_inj e ▸ ht
  have hE12 : E12 1 ∈ H' := hmem _ (hSeq ▸ List.mem_cons_self ..)
  have hE21 : E21 1 ∈ H' := hmem _ (hSeq ▸ List.mem_cons_of_mem _ (List.mem_cons_self ..))
  have hD : diag (finN z) ∈ H' := hmem _ (hSeq ▸ List.mem_cons_of_mem _ (List.mem_cons_of_mem _ (List.mem_cons_self ..)))
  -- conjugate back
  intro w hw
  have hw' := conj_mem_gl ff hCC' hC'C hw
  obtain ⟨y, hy, e⟩ := List.mem_map.mp (gl2_generated ff H' hmul' hE12 hE21 hz hD _ hw')
  have h2 : M2.mul (M2.mul C (M2.mul (M2.mul C' w) C)) C' = M2.mul (M2.mul C (M2.mul (M2.mul C' y) C)) C' := by
    rw [e]
  rw [conj_cancel' hCC', conj_cancel' hCC'] at h2
  exact h2 ▸ hy

-- ---------------------------------------------------------------- per-curve arithmetic --

/-- a_p mod n as a natural, from Lean's point count of the Weierstrass model. -/
def apMod (n : Nat) (a : List Int) (p : Nat) : Nat := ((apGeneral a p % n + n) % n).toNat

def curveOk (n : Nat) (d : ModLData) (c : CurveCert) : Bool :=
  match d.pairs[c.pair]? with
  | some pr => apMod n c.ainvs c.p1 == pr.tA && c.p1 % n == pr.dA && apMod n c.ainvs c.p2 == pr.tB && c.p2 % n == pr.dB
  | none => false

/-- **Soundness of a whole data set**: for every listed curve, any multiplicatively closed subset of
GL₂(𝔽_ℓ) containing an element with the characteristic polynomial of ρ̄_ℓ(Frob_{p₁}) and one with that
of ρ̄_ℓ(Frob_{p₂}) — traces a_{p₁}, a_{p₂} from Lean's point counts, determinants p₁, p₂ — is all of GL₂(𝔽_ℓ). -/
theorem data_sound (ff : FieldFacts n) (d : ModLData) (hS : S_generates n d.zeta d.S = true)
    (hpairs : d.pairs.all (pairOk n d.S) = true) (hcurves : d.curves.all (curveOk n d) = true)
    {c : CurveCert} (hc : c ∈ d.curves)
    (H : List (Mat2 n)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 n} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod n c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod n c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl n, z ∈ H := by
  have hok := List.all_eq_true.mp hcurves c hc
  unfold curveOk at hok
  split at hok
  · next pr hpr =>
    have hprm : pr ∈ d.pairs := List.mem_of_getElem? hpr
    have e1 := beq_iff_eq.mp (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hok).1).1).1
    have e2 := beq_iff_eq.mp (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hok).1).1).2
    have e3 := beq_iff_eq.mp (Bool.and_eq_true _ _ |>.mp (Bool.and_eq_true _ _ |>.mp hok).1).2
    have e4 := beq_iff_eq.mp (Bool.and_eq_true _ _ |>.mp hok).2
    have hmod : ∀ k : Nat, (finN (k % n) : Fin n) = finN k := fun k => Fin.ext (Nat.mod_mod k n)
    refine pair_sound ff d.zeta d.S hS pr (List.all_eq_true.mp hpairs pr hprm) H hmul hg hh ⟨?_, ?_⟩ ⟨?_, ?_⟩
    · rw [hA.1, e1]
    · rw [hA.2, ← e2, hmod]
    · rw [hB.1, e3]
    · rw [hB.2, ← e4, hmod]
  · exact absurd hok Bool.false_ne_true

/-- The negation facts about ℤ/n that the vector argument needs (n² cases each, decided per n). -/
structure NegFacts (n : Nat) [NeZero n] : Prop where
  mul_neg : ∀ b c : Fin n, b * (0 - c) = 0 - b * c
  sub_eq : ∀ x y : Fin n, x - y = x + (0 - y)
  neg_eq_zero : ∀ c : Fin n, 0 - c = 0 → c = 0
  one_ne_zero : (1 : Fin n) ≠ 0
  two_ne_zero : (2 : Fin n) ≠ 0

/-- A singular matrix kills (d, −c) and (−b, a): from `NegFacts` and the semiring laws, no n⁴-case decide. -/
theorem kernel_vectors_of (nf : NegFacts n) : ∀ a b c d : Fin n, a * d - b * c = 0 →
    applyV ⟨a, b, c, d⟩ (d, 0 - c) = (0, 0) ∧ applyV ⟨a, b, c, d⟩ (0 - b, a) = (0, 0) := by
  intro a b c d h
  simp only [applyV]
  rw [nf.mul_neg, nf.mul_neg, nf.mul_neg, nf.mul_neg, ← nf.sub_eq, ← nf.sub_eq, h,
    (R).mul_comm d c, Fin.sub_self, (R).add_comm (0 - a * b), (R).add_comm (0 - c * b), ← nf.sub_eq, ← nf.sub_eq,
    (R).mul_comm b a, Fin.sub_self, (R).mul_comm d a, (R).mul_comm c b, h]
  exact ⟨rfl, rfl⟩

/-- Every nonzero scalar has an inverse (n² operations, decided per n). -/
def invTable (n : Nat) : Bool :=
  (List.range n).all fun c => c == 0 || (List.range n).any fun u => c * u % n == 1

theorem invTable_sound (h : invTable n = true) (c : Fin n) (hc : c ≠ 0) : ∃ u : Fin n, c * u = 1 := by
  have hc' := List.all_eq_true.mp h c.val (List.mem_range.mpr c.isLt)
  have hne : (c.val == 0) = false := by
    cases hb : c.val == 0
    · rfl
    · exact absurd (Fin.ext (beq_iff_eq.mp hb)) hc
  rw [hne, Bool.false_or] at hc'
  obtain ⟨u, hu, e⟩ := List.any_eq_true.mp hc'
  have e := beq_iff_eq.mp e
  have hn : 1 < n := e ▸ Nat.mod_lt _ (Nat.pos_of_neZero n)
  exact ⟨finN u, Fin.ext (by
    show c.val * (u % n) % n = 1 % n
    rw [Nat.mod_eq_of_lt (List.mem_range.mp hu), Nat.mod_eq_of_lt hn, e])⟩

/-- **The adjugate over an inverse of the determinant is a left inverse**: u·adj(z)·z = 1 when u·det z = 1
(a ring identity from the semiring laws and the negation facts). -/
theorem adj_left_inverse (nf : NegFacts n) (z : Mat2 n) {u : Fin n} (hu : u * z.det = 1) :
    M2.mul ⟨u * z.d, u * (0 - z.b), u * (0 - z.c), u * z.a⟩ z = M2.one := by
  obtain ⟨a, b, c, d⟩ := z
  have hu : u * (a * d - b * c) = 1 := hu
  have nb : ∀ x y : Fin n, (0 - x) * y = 0 - x * y := fun x y => by rw [(R).mul_comm, nf.mul_neg, (R).mul_comm]
  have e11 : u * d * a + u * (0 - b) * c = 1 := by
    rw [(R).mul_assoc, (R).mul_assoc, nb, ← (R).mul_add, (R).mul_comm d a, ← nf.sub_eq]; exact hu
  have e12 : u * d * b + u * (0 - b) * d = 0 := by
    rw [(R).mul_assoc, (R).mul_assoc, nb, ← (R).mul_add, (R).mul_comm d b, add_neg_cancel nf.sub_eq, (R).mul_zero]
  have e21 : u * (0 - c) * a + u * a * c = 0 := by
    rw [(R).mul_assoc, (R).mul_assoc, nb, ← (R).mul_add, (R).mul_comm c a, neg_add_cancel nf.sub_eq, (R).mul_zero]
  have e22 : u * (0 - c) * b + u * a * d = 1 := by
    rw [(R).mul_assoc, (R).mul_assoc, nb, ← (R).mul_add, (R).mul_comm c b, (R).add_comm, ← nf.sub_eq]; exact hu
  show (⟨u * d * a + u * (0 - b) * c, u * d * b + u * (0 - b) * d, u * (0 - c) * a + u * a * c, u * (0 - c) * b + u * a * d⟩ : Mat2 n)
    = ⟨1, 0, 0, 1⟩
  rw [e11, e12, e21, e22]

/-- The searched inverse is one, from the table. -/
theorem invOf_spec_of (h : invTable n = true) (b : Fin n) (hb : b ≠ 0) : b * invOf n b = 1 := by
  obtain ⟨u, hu⟩ := invTable_sound h b hb
  have hn : 1 < n := Nat.lt_of_le_of_lt (Nat.pos_of_ne_zero fun e => hb (Fin.ext e)) b.isLt
  have hex : ∃ v, (List.range n).find? (fun u => b.val * u % n == 1) = some v := by
    cases hf : (List.range n).find? (fun u => b.val * u % n == 1) with
    | some v => exact ⟨v, rfl⟩
    | none =>
      have e := congrArg Fin.val hu
      rw [Fin.val_mul] at e
      exact absurd (show (b.val * u.val % n == 1) = true by rw [e]; exact beq_iff_eq.mpr (Nat.mod_eq_of_lt hn))
        (List.find?_eq_none.mp hf u.val (List.mem_range.mpr u.isLt))
  obtain ⟨v, hv⟩ := hex
  have hpv := List.find?_some hv
  have hvn : v < n := List.mem_range.mp (List.mem_of_find?_eq_some hv)
  show b * finN (((List.range n).find? fun u => b.val * u % n == 1).getD 0) = 1
  rw [hv]
  exact Fin.ext (by
    show b.val * (v % n) % n = 1 % n
    rw [Nat.mod_eq_of_lt hvn, Nat.mod_eq_of_lt hn]
    exact beq_iff_eq.mp hpv)

/-- Every invertible matrix has a left inverse: the adjugate over the scalar inverse of its determinant. -/
theorem inv_of_invTable (nf : NegFacts n) (h : invTable n = true) : ∀ z ∈ gl n, ∃ z' : Mat2 n, M2.mul z' z = M2.one := by
  intro z hz
  have hdet : z.det ≠ 0 := fun h0 => bne_iff_ne.mp (List.mem_filter.mp hz).2 (by rw [h0]; rfl)
  obtain ⟨u, hu⟩ := invTable_sound h z.det hdet
  exact ⟨_, adj_left_inverse nf z (by rw [(R).mul_comm]; exact hu)⟩

/-- `FieldFacts n` from Cayley–Hamilton for tr², the negation facts, and the scalar inverse table. -/
theorem FieldFacts.of (hsq : ∀ a b c d : Fin n, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c))
    (nf : NegFacts n) (hinv : invTable n = true) : FieldFacts n where
  trace_sq := fun x => by obtain ⟨a, b, c, d⟩ := x; exact hsq a b c d
  kernel_vectors := kernel_vectors_of nf
  neg_eq_zero := nf.neg_eq_zero
  one_ne_zero := nf.one_ne_zero
  two_ne_zero := nf.two_ne_zero
  sub_eq := nf.sub_eq
  invOf_spec := invOf_spec_of hinv
  inv := inv_of_invTable nf hinv

/-- Cayley–Hamilton for the trace of the square, over ℤ/n for a literal n: expand with the semiring laws,
name the four products, and let `omega` settle the additive identity in ℤ/n. -/
macro "trace_sq_tac" : tactic => `(tactic| (
  intro a b c d
  rw [(isCSR_fin _).mul_add, (isCSR_fin _).add_mul, (isCSR_fin _).add_mul, (isCSR_fin _).mul_comm d a, (isCSR_fin _).mul_comm c b]
  generalize a * a = P
  generalize a * d = T
  generalize d * d = U
  generalize b * c = Q
  omega))

/-- The 15 Cremona curves of prime level ≤ 101. -/
def allLabels : List String :=
  ["11a1", "17a1", "19a1", "37a1", "37b1", "43a1", "53a1", "61a1", "67a1", "73a1", "79a1", "83a1", "89a1", "89b1", "101a1"]

end Mat2

end Oracles
