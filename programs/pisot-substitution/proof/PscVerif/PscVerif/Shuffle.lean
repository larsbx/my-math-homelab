/-
# The degree-3 shuffle relation, and the shuffle-kernel sector `W₃`

`PROOF_CERTIFICATE.md` §3 asserts as "certified fact 3" that `K₂(s) = 0` implies
`K₃(s) ∈ W₃`, where `W₃` is cut out by the degree-3 shuffle relations.  Here that
implication is *proved*, from the underlying identity on words.

The identity itself is not quite the naive shuffle product `a ⧢ bc = abc + bac +
bca`: when letters coincide, a position can be shared between the two factors,
which contributes the two correction terms below.  Those corrections are
multiples of degree-2 counts, so they cancel exactly when `K₂ = 0` -- which is
why the certificate's conclusion is nevertheless correct.
-/
import PscVerif.Basic

namespace Psc

/-- Degree-2 shuffle: `N a · N c = N₂ a c + N₂ c a + [a = c] · N a`.

The correction term counts the positions shared by the two factors, which can
happen exactly when the two letters coincide. -/
theorem N_mul_N (a c : Letter) (w : Word) :
    N a w * N c w = N₂ a c w + N₂ c a w + ind a c * N a w := by
  induction w with
  | nil => simp [N, N₂]
  | cons x t ih =>
    simp only [N, N₂]
    linear_combination ih + ind_mul x a c

/-- Degree-3 shuffle: `N a · N₂ b c = N₃ a b c + N₃ b a c + N₃ b c a` plus the two
coincidence corrections.  This is the word-level identity behind the sector `W₃`. -/
theorem N_mul_N₂ (a b c : Letter) (w : Word) :
    N a w * N₂ b c w
      = N₃ a b c w + N₃ b a c w + N₃ b c a w
        + ind a b * N₂ a c w + ind a c * N₂ b a w := by
  induction w with
  | nil => simp [N, N₂, N₃]
  | cons x t ih =>
    have key := N_mul_N a c t
    simp only [N, N₂, N₃]
    linear_combination ih + (ind x b) * key + (N c t) * ind_mul x a b

namespace BalancedPair

/-- **Certified fact 3, proved.**  On a balanced pair with vanishing `K₂`, the
degree-3 invariant satisfies the shuffle relations: `K₃` lies in `W₃ = ker S`,
where `S x` has coordinates `x_{abc} + x_{bac} + x_{bca}`.

Note the coordinate form of `S`.  §3 of the certificate writes `S` by its action
on basis vectors, `e_a ⊗ e_b ⊗ e_c ↦ e_{abc} + e_{bac} + e_{bca}`, which is the
*transpose* of this; the printed basis `b₁, …, b₈` and the seed vectors satisfy
the coordinate form, not the basis-vector form. -/
theorem K₃_shuffle_zero (s : BalancedPair) (h₂ : ∀ i j, s.K₂ i j = 0)
    (a b c : Letter) : s.K₃ a b c + s.K₃ b a c + s.K₃ b c a = 0 := by
  have hu := N_mul_N₂ a b c s.u
  have hv := N_mul_N₂ a b c s.v
  have hN : N a s.u = N a s.v := s.parikh a
  have h2 : ∀ i j, N₂ i j s.u = N₂ i j s.v := by
    intro i j; have := h₂ i j; simp only [K₂] at this; linarith
  simp only [K₃]
  linear_combination hv - hu + (N₂ b c s.u) * hN + (N a s.v) * (h2 b c)
    - (ind a b) * (h2 a c) - (ind a c) * (h2 b a)

end BalancedPair

end Psc
