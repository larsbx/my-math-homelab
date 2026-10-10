/-!
# The Satake isomorphism for PGL₂, proved for every q.

Let F be a local field with residue field of size q, G = PGL₂(F), K = PGL₂(𝒪), and 𝒯 the
(q+1)-regular Bruhat–Tits tree G/K with origin o = K.  The spherical Hecke algebra H(G, K) has the
ℤ-basis A_n = 1_{K diag(πⁿ,1) K}, acting on functions on 𝒯 by summing over the sphere of radius n.
Fix an end ω of 𝒯 (the Borel B = TN fixing it); its horocycles are the N-orbits, indexed by the
height h ∈ ℤ.  The (unnormalised) Satake transform of A_n is the horocycle profile of the sphere,

        𝒮(A_n) = Σ_h #{v : d(o, v) = n, height(v) = h} · Xʰ   ∈ ℤ[q][X^{±1}],

and δ^{1/2} is the twist X ↦ q^{1/2}X, so that W = S₂ acts by X ↦ qX⁻¹.  Everything in degree n
lives on the monomials X^{n−2j}, 0 ≤ j ≤ n; a degree-n element is a coefficient function
c : ℕ → ℤ, c j = coefficient of X^{n−2j}.  q is an arbitrary integer throughout, so every theorem
is the polynomial identity in ℤ[q].

The tree enters only through its geometry relative to ω (`ray`, `down`): from o a geodesic goes up
toward ω along the ray, then turns down; the first down-step off the ray has q − 1 choices (not
back along the ray), later ones q (not back up), and the first step from o itself has q.  That this
is the tree of PGL₂(𝔽_q((1/t))) is COMPUTED on the lattice model (`satake.py`, heights = the
Iwasawa coordinate k), and so is the Hecke relation A₁A_n = A_{n+1} + q A_{n−1} (n ≥ 2),
A₁A₁ = A₂ + (q+1)A₀, which makes H(G, K) = ℤ[A₁].

PROVED here (no `decide`, no `grind`; axioms propext, Quot.sound):
* `sphere_eq_sat`: the walk count is the closed form 𝒮(A_n) = Xⁿ + Σ_{0<j<n} (q−1)q^{j−1}X^{n−2j} + qⁿX⁻ⁿ;
* `sat_weyl`: W-invariance, twisted: coefficient of X^{−k} = q^k · coefficient of X^k;
* `sat_hecke`, `sat_hecke_one`: 𝒮 carries the Hecke relation to multiplication by χ₁ = X + qX⁻¹,
  so 𝒮 is the ring homomorphism ℤ[A₁] → ℤ[q][X^{±1}] with A₁ ↦ X + qX⁻¹;
* `sat_eq_chi_sub`: 𝒮(A_n) = χ_n − χ_{n−2}, χ_n = Σ_j q^j X^{n−2j} = q^{n/2}·tr Sym^n of the dual
  group Ĝ = SL₂ at diag(q^{−1/2}X, q^{1/2}X⁻¹) — the dominant weights of Ĝ index K\G/K;
* `chi_clebsch_gordan`: χ₁χ_n = χ_{n+1} + qχ_{n−1}, Clebsch–Gordan for SL₂ after the δ^{1/2} twist;
* `ball_eq_chi`: χ_n = 𝒮(A_n + A_{n−2} + ⋯), so the Hecke operator of Sym^n is the sum over the
  vertices at distance ≤ n of the parity of n — classically T(𝔭ⁿ) (index-qⁿ sublattices);
* `invariant_decomposes` with `sat_zero`, `lift_zero`: every twisted-W-invariant element of degree n
  is a ℤ[q]-combination of χ_n, χ_{n−2}, …, and 𝒮(A_n) is unitriangular in them: 𝒮 is an
  isomorphism of H(G, K) onto ℤ[q][X^{±1}]^W;
* `hecke_seq_eq_h`, `power_sum_eq`: at a Satake parameter {α, β} with α + β = a, αβ = q, the
  T(𝔭ⁿ)-eigenvalues are hₙ(α, β) (complete homogeneous), Σ hₙYⁿ = 1/(1 − aY + qY²) (the local
  L-factor), and αⁿ + βⁿ = hₙ − q hₙ₋₂ = tr(Frobⁿ) is what point counts over 𝔽_{qⁿ} see.
-/
namespace Oracles.Satake

-- default simp lemmas whose proofs use `Classical.choice`, erased so that every theorem here stays
-- within propext, Quot.sound (the audit gate rejects Classical.choice)
attribute [-simp] Nat.add_eq_right Nat.add_eq_left Nat.right_eq_add Nat.left_eq_add

/-- Choice-free ring arithmetic over ℤ (`satake_arith` would add `Classical.choice`): split the `if`s,
distribute and AC-normalise the products (powers unfolded one step), and let `omega` close the
goal with the monomials as atoms. -/
syntax "satake_arith" : tactic
macro_rules
  | `(tactic| satake_arith) => `(tactic| (
      repeat' split
      all_goals first
        | omega
        | (simp only [Int.mul_add, Int.add_mul, Int.mul_sub, Int.sub_mul, Int.pow_succ, Int.pow_zero,
            Int.one_mul, Int.mul_one, Int.mul_zero, Int.zero_mul, Int.mul_assoc, Int.mul_comm,
            Int.mul_left_comm] at * <;> omega)))

/-- Degree-n elements of ℤ[q][X^{±1}]: c j = coefficient of X^{n−2j}. -/
abbrev Coeffs := Nat → Int

/-- The same Laurent polynomial read in degree n + 2: X^{n−2j} = X^{(n+2)−2(j+1)}. -/
def lift (f : Coeffs) : Coeffs
  | 0 => 0
  | j + 1 => f j

/-- Multiplication by χ₁ = X + qX⁻¹, from degree n to degree n + 1. -/
def mulChi1 (q : Int) (f : Coeffs) : Coeffs := fun j => f j + q * lift f j

/-! ## The tree seen from an end: spheres by horocycle -/

/-- The vertex of the sphere on the ray toward ω: height n, j = 0. -/
def ray : Coeffs := fun j => if j = 0 then 1 else 0

/-- Vertices of the sphere of radius n reached by at least one down-step, by j (height n − 2j). -/
def down (q : Int) : Nat → Coeffs
  | 0, _ => 0
  | 1, j => if j = 1 then q else 0
  | _ + 2, 0 => 0
  | n + 2, j + 1 => q * down q (n + 1) j + (if j = 0 then q - 1 else 0)

/-- Horocycle profile of the sphere of radius n: 𝒮(A_n) as computed by walking the tree. -/
def sphere (q : Int) : Nat → Coeffs
  | 0 => ray
  | n + 1 => fun j => ray j + down q (n + 1) j

/-- The closed form of 𝒮(A_n). -/
def sat (q : Int) (n j : Nat) : Int :=
  if j = 0 then 1 else if j < n then (q - 1) * q ^ (j - 1) else if j = n then q ^ n else 0

/-- χ_n = Σ_{j ≤ n} q^j X^{n−2j}. -/
def chi (q : Int) (n j : Nat) : Int := if j ≤ n then q ^ j else 0

theorem down_closed (q : Int) (m j : Nat) :
    down q (m + 1) j
      = if j = 0 then 0 else if j < m + 1 then (q - 1) * q ^ (j - 1) else if j = m + 1 then q ^ (m + 1) else 0 := by
  induction m generalizing j with
  | zero => rcases j with _ | j <;> simp [down, Int.pow_one]
  | succ m ih =>
    rcases j with _ | _ | i
    · simp [down]
    · simp [down, ih]
    · simp only [down, ih, Nat.add_sub_cancel]; satake_arith

/-- The walk count is the closed form. -/
theorem sphere_eq_sat (q : Int) (n j : Nat) : sphere q n j = sat q n j := by
  rcases n with _ | m
  · simp [sphere, ray, sat]
  · rcases j with _ | j <;> simp [sphere, ray, down_closed, sat]

/-- Twisted W-invariance: the coefficient of X^{−(n−2j)} is q^{n−2j} times that of X^{n−2j}. -/
theorem sat_weyl (q : Int) (n j : Nat) (h : 2 * j ≤ n) :
    sat q n (n - j) = q ^ (n - 2 * j) * sat q n j := by
  unfold sat
  rcases j with _ | i
  · rcases n with _ | n <;> simp
  · obtain ⟨m, rfl⟩ : ∃ m, n = 2 * (i + 1) + m := ⟨n - 2 * (i + 1), by omega⟩
    have e1 : 2 * (i + 1) + m - (i + 1) = i + m + 1 := by omega
    have e2 : 2 * (i + 1) + m - 2 * (i + 1) = m := by omega
    rw [e1, e2]
    have : i + m + 1 - 1 = m + i := by omega
    simp only [this, Nat.add_sub_cancel, Int.pow_add]; satake_arith

theorem chi_weyl (q : Int) (n j : Nat) (h : 2 * j ≤ n) :
    chi q n (n - j) = q ^ (n - 2 * j) * chi q n j := by
  unfold chi
  have e : n - 2 * j + j = n - j := by omega
  simp only [show n - j ≤ n by omega, show j ≤ n by omega, ite_true]
  rw [← e, Int.pow_add]

/-- 𝒮 carries A₁ · A_{n+1} = A_{n+2} + q · A_n (n ≥ 1) to multiplication by χ₁. -/
theorem sat_hecke (q : Int) (n : Nat) (hn : 1 ≤ n) (j : Nat) :
    mulChi1 q (sat q (n + 1)) j = sat q (n + 2) j + q * lift (sat q n) j := by
  unfold mulChi1 lift
  rcases j with _ | _ | k
  · simp [sat]
  · simp [sat]; satake_arith
  · simp only [sat, Nat.add_sub_cancel]; satake_arith

/-- A₁ · A₁ = A₂ + (q + 1) · A₀. -/
theorem sat_hecke_one (q : Int) (j : Nat) :
    mulChi1 q (sat q 1) j = sat q 2 j + (q + 1) * lift (sat q 0) j := by
  unfold mulChi1 lift sat
  rcases j with _ | _ | _ | j <;> simp [Int.pow_succ, Int.pow_zero] <;> satake_arith

/-- A₀ = χ₀ and A₁ = χ₁. -/
theorem sat_zero_eq (q : Int) (j : Nat) : sat q 0 j = chi q 0 j := by
  unfold sat chi; rcases j with _ | j <;> simp

theorem sat_one_eq (q : Int) (j : Nat) : sat q 1 j = chi q 1 j := by
  unfold sat chi; rcases j with _ | _ | j <;> simp

/-- 𝒮(A_{n+2}) = χ_{n+2} − χ_n (Satake: the character of Sym^{n+2} minus that of Sym^n). -/
theorem sat_eq_chi_sub (q : Int) (n j : Nat) : sat q (n + 2) j = chi q (n + 2) j - lift (chi q n) j := by
  unfold lift
  rcases j with _ | i
  · simp [sat, chi]
  · by_cases hi : i = n + 1
    · subst hi; simp [sat, chi, show ¬ n + 1 ≤ n by omega]
    · simp only [sat, chi, Nat.add_sub_cancel]; satake_arith

/-- q-twisted Clebsch–Gordan: χ₁ χ_{n+1} = χ_{n+2} + q χ_n, and χ₁ χ₀ = χ₁. -/
theorem chi_clebsch_gordan (q : Int) (n j : Nat) :
    mulChi1 q (chi q (n + 1)) j = chi q (n + 2) j + q * lift (chi q n) j := by
  unfold mulChi1 lift
  rcases j with _ | i
  · simp [chi]
  · simp only [chi]; satake_arith

theorem chi_clebsch_gordan_zero (q : Int) (j : Nat) : mulChi1 q (chi q 0) j = chi q 1 j := by
  unfold mulChi1 chi lift; rcases j with _ | _ | j <;> simp [Int.pow_one]

/-- The ball of the parity of n: A_n + A_{n−2} + ⋯ (each lifted to degree n). -/
def ball (q : Int) : Nat → Coeffs
  | 0 => sat q 0
  | 1 => sat q 1
  | n + 2 => fun j => sat q (n + 2) j + lift (ball q n) j

/-- Inverse Satake: χ_n = 𝒮(A_n + A_{n−2} + ⋯), the Hecke operator T(𝔭ⁿ) of Sym^n. -/
theorem ball_eq_chi (q : Int) (n j : Nat) : ball q n j = chi q n j := by
  induction n using Nat.strongRecOn generalizing j with
  | _ n ih =>
    match n with
    | 0 => exact sat_zero_eq q j
    | 1 => exact sat_one_eq q j
    | n + 2 =>
      simp only [ball, sat_eq_chi_sub]
      rcases j with _ | i
      · simp [lift]
      · simp [lift, ih n (by omega)]

/-! ## Unitriangularity and surjectivity onto the W-invariants -/

theorem sat_zero (q : Int) (n : Nat) : sat q n 0 = 1 := by simp [sat]
theorem lift_zero (f : Coeffs) : lift f 0 = 0 := rfl

/-- A degree-n element: supported on j ≤ n, twisted-W-invariant. -/
structure Invariant (q : Int) (n : Nat) (f : Coeffs) : Prop where
  support : ∀ j, n < j → f j = 0
  weyl : ∀ j, 2 * j ≤ n → f (n - j) = q ^ (n - 2 * j) * f j

/-- Σ_i c_i χ_{n−2i}, each lifted to degree n. -/
def combo (q : Int) (c : Nat → Int) : Nat → Coeffs
  | 0 => fun j => c 0 * chi q 0 j
  | 1 => fun j => c 0 * chi q 1 j
  | n + 2 => fun j => c 0 * chi q (n + 2) j + lift (combo q (fun i => c (i + 1)) n) j

/-- Every twisted-W-invariant element of degree n is a ℤ[q]-combination of χ_n, χ_{n−2}, ….
With `ball_eq_chi` (the χ's are images of Hecke operators) and `sat_zero`/`lift_zero` (𝒮(A_n) has
leading coefficient 1 and the lower A's vanish there), 𝒮 : H(G, K) → ℤ[q][X^{±1}]^W is bijective. -/
theorem invariant_decomposes (q : Int) (n : Nat) (f : Coeffs) (hf : Invariant q n f) :
    ∃ c : Nat → Int, ∀ j, f j = combo q c n j := by
  induction n using Nat.strongRecOn generalizing f with
  | _ n ih =>
    match n, hf with
    | 0, hf =>
      refine ⟨fun _ => f 0, fun j => ?_⟩
      rcases j with _ | j
      · simp [combo, chi]
      · simp [combo, chi, hf.support (j + 1) (by omega)]
    | 1, hf =>
      refine ⟨fun _ => f 0, fun j => ?_⟩
      have hw := hf.weyl 0 (by omega)
      rcases j with _ | _ | j
      · simp [combo, chi]
      · simp at hw; simp [combo, chi, hw]; satake_arith
      · simp [combo, chi, hf.support (j + 2) (by omega)]
    | n + 2, hf =>
      -- g = f − f(0)·χ_{n+2}, shifted: it vanishes beyond n and is invariant of degree n
      let g : Coeffs := fun i => f (i + 1) - f 0 * chi q (n + 2) (i + 1)
      have hg : Invariant q n g := by
        constructor
        · intro i hi
          have hw := hf.weyl 0 (by omega)
          simp at hw
          rcases Nat.lt_or_ge (n + 1) i with h | h
          · simp [g, chi, hf.support (i + 1) (by omega), show ¬ i ≤ n + 1 by omega]
          · have : i = n + 1 := by omega
            subst this; simp [g, chi, hw]; satake_arith
        · intro i hi
          have hw := hf.weyl (i + 1) (by omega)
          have hc := chi_weyl q (n + 2) (i + 1) (by omega)
          have e1 : n + 2 - (i + 1) = n - i + 1 := by omega
          have e2 : n + 2 - 2 * (i + 1) = n - 2 * i := by omega
          rw [e1, e2] at hw hc
          show f (n - i + 1) - f 0 * chi q (n + 2) (n - i + 1)
              = q ^ (n - 2 * i) * (f (i + 1) - f 0 * chi q (n + 2) (i + 1))
          rw [hw, hc]; satake_arith
      obtain ⟨c, hc⟩ := ih n (by omega) g hg
      refine ⟨fun i => if i = 0 then f 0 else c (i - 1), fun j => ?_⟩
      have e : (fun i => if i + 1 = 0 then f 0 else c (i + 1 - 1)) = c := by funext i; simp
      simp only [combo, e]
      rcases j with _ | i
      · simp [chi, lift]
      · have := hc i
        simp only [g] at this
        simp only [lift, ite_true]
        rw [← this]; satake_arith

/-! ## At a Satake parameter: Hecke eigenvalues, the local L-factor, power sums -/

/-- h_n(α, β) = Σ_{i+j=n} α^i β^j, the trace of Sym^n at diag(α, β). -/
def h (α β : Int) : Nat → Int
  | 0 => 1
  | n + 1 => α ^ (n + 1) + β * h α β n

/-- T(𝔭ⁿ)-eigenvalues of an eigenform with T(𝔭) = a: the recursion χ₁χ_{n+1} = χ_{n+2} + qχ_n. -/
def heckeSeq (a q : Int) : Nat → Int
  | 0 => 1
  | 1 => a
  | n + 2 => a * heckeSeq a q (n + 1) - q * heckeSeq a q n

theorem h_rec (α β : Int) (n : Nat) : h α β (n + 2) = (α + β) * h α β (n + 1) - α * β * h α β n := by
  induction n with
  | zero => simp [h]; satake_arith
  | succ n ih => simp only [h] at *; rw [Int.pow_succ α (n + 2)]; satake_arith

/-- The Satake parameter determines the eigenvalues: T(𝔭ⁿ) acts by h_n(α, β); equivalently
(1 − aY + qY²) Σ hₙ Yⁿ = 1, the unramified local L-factor. -/
theorem hecke_seq_eq_h (α β : Int) (n : Nat) : heckeSeq (α + β) (α * β) n = h α β n := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    match n with
    | 0 => rfl
    | 1 => simp [heckeSeq, h]; satake_arith
    | n + 2 => rw [heckeSeq, ih n (by omega), ih (n + 1) (by omega), h_rec]

/-- tr(Frobⁿ) = αⁿ + βⁿ = h_n − q h_{n−2}: 𝒮(A_n) evaluated with the δ^{1/2}-twist undone,
i.e. what point counts over 𝔽_{qⁿ} measure. -/
theorem power_sum_eq (α β : Int) (n : Nat) :
    α ^ (n + 2) + β ^ (n + 2) = h α β (n + 2) - α * β * h α β n := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    match n with
    | 0 => simp [h]; satake_arith
    | 1 => simp [h, Int.pow_succ]; satake_arith
    | n + 2 =>
      have h1 : α ^ (n + 2) + β ^ (n + 2) = h α β (n + 2) - α * β * h α β n := ih n (by omega)
      have h2 : α ^ (n + 3) + β ^ (n + 3) = h α β (n + 3) - α * β * h α β (n + 1) := ih (n + 1) (by omega)
      have r2 := h_rec α β n
      have r3 := h_rec α β (n + 1)
      have r4 := h_rec α β (n + 2)
      have p : α ^ (n + 4) + β ^ (n + 4)
          = (α + β) * (α ^ (n + 3) + β ^ (n + 3)) - α * β * (α ^ (n + 2) + β ^ (n + 2)) := by
        simp only [Int.pow_succ]; satake_arith
      clear ih
      show α ^ (n + 4) + β ^ (n + 4) = h α β (n + 4) - α * β * h α β (n + 2)
      rw [p, h1, h2, r4, r3, r2]; satake_arith

end Oracles.Satake
