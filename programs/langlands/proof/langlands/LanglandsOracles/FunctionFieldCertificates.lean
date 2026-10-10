import LanglandsOracles.Data

/-!
# Certificates on exported local data of elliptic curves over F_q(t) (branch 3, Drinfeld side).

L(E, T) = ∏_v L_v(T)^{-1} with L_v = 1 − a_v T^{d} + q^{d} T^{2d} (good), 1 − a_v T^{d} (multiplicative),
1 (additive).  Grothendieck: L is a polynomial of degree deg(conductor) − 4.  Lean multiplies the
exported local factors out to the given order and checks the polynomial identity.
-/
namespace Oracles

/-- Multiply a truncated series by 1 / (1 + Σ_k f_k T^k), f given as (k, coefficient) pairs, k ≥ 1. -/
def divideByFactor (s : List Int) (f : List (Nat × Int)) : List Int :=
  (List.range s.length).foldl (fun (acc : List Int) n =>
    let corr := f.foldl (fun c kc => if kc.1 ≥ 1 && kc.1 ≤ n then c + kc.2 * acc[n - kc.1]! else c) 0
    acc ++ [s[n]! - corr]) []

def eulerProduct (q order : Nat) (places : List (Nat × Nat × Int)) : List Int :=
  places.foldl (fun s dka =>
    let (d, kind, a) := dka
    let factor : List (Nat × Int) :=
      if kind == 0 then [(d, -a), (2 * d, (q ^ d : Nat))]
      else if kind == 1 then [(d, -a)] else []
    divideByFactor s factor) (1 :: List.replicate order 0)

def functionFieldLCertified (entry : Nat × Nat × List (Nat × Nat × Int)) (expected : List Int) : Bool :=
  let (q, order, places) := entry
  eulerProduct q order places == expected ++ List.replicate (order + 1 - expected.length) 0

/-- E_t3 / F_2(t): L = 1 (conductor t^3 oo, degree 4); E_t4: L = 1 + 2T (degree 5);
    E3_A, E3_B / F_3(t): L = 1 (conductor t^3 oo). -/
theorem function_field_l_functions :
    (functionFieldLocalData.zip [[1], [1, 2], [1], [1]]).all (fun e => functionFieldLCertified e.1 e.2) = true := by
  decide +kernel

end Oracles
