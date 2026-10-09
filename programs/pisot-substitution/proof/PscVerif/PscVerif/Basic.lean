/-
# Horizontal invariants of balanced pairs

Scattered-subword counts on words over a 3-letter alphabet, and the horizontal
invariants `K₁`, `K₂`, `K₃` of a balanced pair.  These are the objects of
`PROOF_CERTIFICATE.md` §2.

Everything is over `ℤ`, and every definition is by structural recursion on the
word, so the identities of `PscVerif.Shuffle` are proved by list induction.
-/
import Mathlib

namespace Psc

/-- The alphabet `{1, 2, 3}`, zero-indexed. -/
abbrev Letter := Fin 3

/-- A word over the alphabet. -/
abbrev Word := List Letter

/-- The indicator `⟦x = a⟧`, as an integer.  Writing the recursions with an
explicit indicator keeps every unfolded goal polynomial, so the shuffle
identities can be closed by `linear_combination`. -/
def ind (x a : Letter) : ℤ := if x = a then 1 else 0

@[simp] theorem ind_self (a : Letter) : ind a a = 1 := by simp [ind]

theorem ind_eq_zero {x a : Letter} (h : x ≠ a) : ind x a = 0 := by simp [ind, h]

/-- `ind x a * ind x b = ind a b * ind x a`: a position can match two letters
only when those letters agree. -/
theorem ind_mul (x a b : Letter) : ind x a * ind x b = ind a b * ind x a := by
  by_cases h1 : x = a <;> by_cases h2 : x = b <;> by_cases h3 : a = b <;>
    simp_all [ind]

/-- `N i w`: the number of occurrences of the letter `i` in `w`. -/
def N : Letter → Word → ℤ
  | _, [] => 0
  | a, x :: t => ind x a + N a t

/-- `N₂ i j w`: the number of pairs of positions `p < q` with `w p = i` and `w q = j`,
i.e. the number of occurrences of `ij` as a scattered subword. -/
def N₂ : Letter → Letter → Word → ℤ
  | _, _, [] => 0
  | a, b, x :: t => ind x a * N b t + N₂ a b t

/-- `N₃ i j k w`: the number of occurrences of `ijk` as a scattered subword. -/
def N₃ : Letter → Letter → Letter → Word → ℤ
  | _, _, _, [] => 0
  | a, b, c, x :: t => ind x a * N₂ b c t + N₃ a b c t

/-- A balanced pair: two words with matching letter counts.  `K₁` then vanishes
by definition, which is why the certificate calls it tautological. -/
structure BalancedPair where
  u : Word
  v : Word
  len : u.length = v.length
  parikh : ∀ a, N a u = N a v

namespace BalancedPair

variable (s : BalancedPair)

/-- `K₁(s) i = N i u - N i v`.  Zero for every balanced pair. -/
def K₁ (a : Letter) : ℤ := N a s.u - N a s.v

/-- `K₂(s) i j = N₂ i j u - N₂ i j v`. -/
def K₂ (a b : Letter) : ℤ := N₂ a b s.u - N₂ a b s.v

/-- `K₃(s) i j k = N₃ i j k u - N₃ i j k v`. -/
def K₃ (a b c : Letter) : ℤ := N₃ a b c s.u - N₃ a b c s.v

@[simp] theorem K₁_eq_zero (a : Letter) : s.K₁ a = 0 := by
  simp [K₁, s.parikh a]

end BalancedPair

end Psc
