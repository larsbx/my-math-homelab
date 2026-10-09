import LanglandsOracles.CommSemiring

/-!
# GL_2-pseudocharacters: the Frobenius–Procesi identity, proved over every commutative semiring
and independently kernel-checked on GL_2(𝔽_2).

For a 2-dimensional representation the trace T satisfies, for all g_1, g_2, g_3,
   T(g_1)T(g_2)T(g_3) − T(g_1g_2)T(g_3) − T(g_1g_3)T(g_2) − T(g_2g_3)T(g_1) + T(g_1g_2g_3) + T(g_1g_3g_2) = 0
(Σ_{σ ∈ S_3} sgn(σ) T_σ = 0).  This is the defining relation of a 2-dimensional pseudocharacter
(Taylor), and the excursion data of a GL_2-parameter factor through it (`ExcursionGL2.lean`).

`M2.procesi` proves it (in the subtraction-free form even terms = odd terms) for 2×2 matrices over
any commutative semiring R: both sides distribute to the same multiset of 24 monomials in the twelve
entries.  Independently, `procesi_GL2_F2` verifies the signed form by kernel evaluation for every
triple in GL_2(𝔽_2) (6³).  `procesi_GL2_F3` derives the same finite Boolean statement from
`M2.procesi` and `isCSR_fin 3`, with only a small scalar check converting to the signed form.
-/
namespace Oracles

/-- 2×2 matrices over R as 4-tuples. -/
structure M2 (R : Type) where
  a : R
  b : R
  c : R
  d : R
deriving DecidableEq, Repr

namespace M2

variable {R : Type} [Add R] [Mul R] [OfNat R 0] [OfNat R 1]

def mul (x y : M2 R) : M2 R :=
  ⟨x.a * y.a + x.b * y.c, x.a * y.b + x.b * y.d, x.c * y.a + x.d * y.c, x.c * y.b + x.d * y.d⟩

def trace (x : M2 R) : R := x.a + x.d

def one : M2 R := ⟨1, 0, 0, 1⟩

section laws

variable (h : IsCSR R)
include h

theorem mul_assoc (x y z : M2 R) : mul (mul x y) z = mul x (mul y z) := by
  haveI : Std.Associative (α := R) (· + ·) := ⟨h.add_assoc⟩
  haveI : Std.Commutative (α := R) (· + ·) := ⟨h.add_comm⟩
  simp only [mul, h.mul_add, h.add_mul, h.mul_assoc, M2.mk.injEq]
  refine ⟨?_, ?_, ?_, ?_⟩ <;> ac_rfl

theorem one_mul (x : M2 R) : mul one x = x := by
  simp only [mul, one, h.one_mul, h.zero_mul, h.zero_add, h.add_zero]

theorem mul_one (x : M2 R) : mul x one = x := by
  simp only [mul, one, h.mul_one, h.mul_zero, h.zero_add, h.add_zero]

theorem trace_mul_comm (x y : M2 R) : trace (mul x y) = trace (mul y x) := by
  haveI : Std.Associative (α := R) (· + ·) := ⟨h.add_assoc⟩
  haveI : Std.Commutative (α := R) (· + ·) := ⟨h.add_comm⟩
  haveI : Std.Associative (α := R) (· * ·) := ⟨h.mul_assoc⟩
  haveI : Std.Commutative (α := R) (· * ·) := ⟨h.mul_comm⟩
  simp only [trace, mul]
  ac_rfl

/-- **The Frobenius–Procesi identity** for 2×2 matrices over a commutative semiring:
T(x)T(y)T(z) + T(xyz) + T(xzy) = T(xy)T(z) + T(xz)T(y) + T(yz)T(x). -/
theorem procesi (x y z : M2 R) :
    trace x * trace y * trace z + trace (mul (mul x y) z) + trace (mul (mul x z) y)
      = trace (mul x y) * trace z + trace (mul x z) * trace y + trace (mul y z) * trace x := by
  haveI : Std.Associative (α := R) (· + ·) := ⟨h.add_assoc⟩
  haveI : Std.Commutative (α := R) (· + ·) := ⟨h.add_comm⟩
  haveI : Std.Associative (α := R) (· * ·) := ⟨h.mul_assoc⟩
  haveI : Std.Commutative (α := R) (· * ·) := ⟨h.mul_comm⟩
  simp only [trace, mul, h.mul_add, h.add_mul, h.mul_assoc]
  ac_rfl

end laws

end M2

/-- 2×2 matrices over ℤ/n. -/
abbrev Mat2 (n : Nat) := M2 (Fin n)

namespace Mat2

variable {n : Nat}

def det (x : Mat2 n) : Fin n := x.a * x.d - x.b * x.c

/-- All elements of Fin n, structurally (kernel-reducible). -/
def fins (n : Nat) : List (Fin n) :=
  (List.range n).filterMap fun i => if h : i < n then some ⟨i, h⟩ else none

def all (n : Nat) : List (Mat2 n) :=
  (fins n).flatMap fun a => (fins n).flatMap fun b =>
    (fins n).flatMap fun c => (fins n).map fun d => ⟨a, b, c, d⟩

def gl (n : Nat) : List (Mat2 n) := (all n).filter fun x => x.det.val != 0

/-- Σ_{σ ∈ S_3} sgn(σ) T_σ(g_1, g_2, g_3) for T = trace. -/
def procesi (g1 g2 g3 : Mat2 n) : Fin n :=
  let T := M2.trace
  T g1 * T g2 * T g3 - T (M2.mul g1 g2) * T g3 - T (M2.mul g1 g3) * T g2 - T (M2.mul g2 g3) * T g1
    + T (M2.mul (M2.mul g1 g2) g3) + T (M2.mul (M2.mul g1 g3) g2)

def procesiHolds (n : Nat) : Bool :=
  (gl n).all fun g1 => (gl n).all fun g2 => (gl n).all fun g3 => (procesi g1 g2 g3).val == 0

end Mat2

theorem gl2_F2_order : (Mat2.gl 2).length = 6 := by decide +kernel
theorem gl2_F3_order : (Mat2.gl 3).length = 48 := by decide +kernel

theorem procesi_GL2_F2 : Mat2.procesiHolds 2 = true := by decide +kernel
theorem procesi_GL2_F3 : Mat2.procesiHolds 3 = true := by
  -- Convert the subtraction-free identity to the signed form: 3⁶ scalar tuples,
  -- rather than 48³ matrix triples.  The matrix identity itself is algebraic.
  have signed : ∀ a b c d e f : Fin 3,
      a + e + f = b + c + d → a - b - c - d + e + f = 0 := by decide +kernel
  unfold Mat2.procesiHolds
  apply List.all_eq_true.mpr
  intro x _
  apply List.all_eq_true.mpr
  intro y _
  apply List.all_eq_true.mpr
  intro z _
  have hz : Mat2.procesi x y z = 0 :=
    signed _ _ _ _ _ _ (M2.procesi (isCSR_fin 3) x y z)
  exact beq_iff_eq.mpr (congrArg Fin.val hz)

end Oracles
