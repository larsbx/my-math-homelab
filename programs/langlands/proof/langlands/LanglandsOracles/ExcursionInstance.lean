import LanglandsOracles.Data
import LanglandsOracles.Matrix

/-!
# An arithmetic excursion instance: the mod-3 parameter of 37a1 at Frobenius elements.

Automorphic side: the exported vector v on the supersingular locus at p = 37 is a joint eigenvector
of the Brandt matrices with B(ℓ) v = a_ℓ v, ℓ ∈ {2, 3, 5, 7} (Jacquet–Langlands form of 37a1); for
larger p, a_p = p + 1 − #E(F_p) by point counting on y² = x³ − 1296x + 11664, done here.

Galois side: the 3-division polynomial ψ_3(x) = 3x⁴ + 6a x² + 12b x − a² has an F_p-root iff
ρ̄_3(Frob_p) has an eigenvector in E[3] with eigenvalue ±1, i.e. iff x² − a_p x + p has a root ±1
mod 3.  Lean certifies the equivalence for every good p ≤ 61: the excursion evaluation of the
mod-3 parameter at Frob_p (through the class function "has eigenvalue ±1") agrees with the Hecke
eigenvalue.
-/
namespace Oracles

def E37a : Int := -1296
def E37b : Int := 11664

def pointCount (p : Nat) : Int :=
  1 + ((List.range p).foldl (fun (acc : Nat) (x : Nat) =>
    let rhs : Int := ((x : Int) ^ 3 + E37a * (x : Int) + E37b) % (p : Int)
    acc + ((List.range p).filter (fun (y : Nat) => ((y : Int) * (y : Int)) % (p : Int) == rhs)).length) 0 : Nat)

def ap (p : Nat) : Int := (p : Int) + 1 - pointCount p

def psi3HasRoot (p : Nat) : Bool :=
  (List.range p).any fun (x : Nat) =>
    (3 * (x : Int) ^ 4 + 6 * E37a * (x : Int) ^ 2 + 12 * E37b * (x : Int) - E37a * E37a) % (p : Int) == 0

def charpolyHasRootPm1Mod3 (p : Nat) : Bool :=
  ((1 - ap p + (p : Int)) % 3 == 0) || ((1 + ap p + (p : Int)) % 3 == 0)

def goodPrimes : List Nat := [5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 43, 47, 53, 59, 61]

theorem ap_37a1_table :
    goodPrimes.map ap = [-2, -1, -5, -2, 0, 0, 2, 6, -4, -9, 2, -9, 1, 8, -8] := by decide +kernel

/-- Brandt eigenvector at level 37: B(ℓ) v = a_ℓ v for ℓ = 2, 3, 5, 7 with (a_2, a_3, a_5, a_7) = (−2, −3, −2, −1). -/
def brandt37 : Option (List (Nat × IMat)) :=
  (brandtData.find? (fun e => e.1 == 37)).map (fun e => e.2.2)

theorem brandt_eigenvector_37a1 :
    (match brandt37 with
     | some ms => ms.all fun m =>
         let a : Int := match m.1 with | 2 => -2 | 3 => -3 | 5 => -2 | _ => -1
         m.2.mul (brandt37Eigenvector.map (fun x => [x])) = brandt37Eigenvector.map (fun x => [a * x])
     | none => false) = true := by decide +kernel

theorem brandt_eigenvalues_match_point_counts : ap 5 = -2 ∧ ap 7 = -1 := by decide +kernel

/-- The matrix of Frob_p on 37a1[3] (exported): trace = a_p and det = p mod 3 for every good p ≤ 61,
    i.e. Eichler–Shimura mod 3 as a matrix identity, with a_p from Lean's own point counts. -/
theorem frobenius_matrices_mod3_37a1 :
    galoisMod3Data.all (fun pm =>
      let (p, m) := pm
      ((m[0]! + m[3]! : Nat) : Int) % 3 == (ap p % 3 + 3) % 3 &&
      (((m[0]! * m[3]! : Nat) : Int) - ((m[1]! * m[2]! : Nat) : Int)) % 3 == ((p : Int) % 3)) = true := by
  decide +kernel

/-- Galois side (ψ_3 mod p) ⇔ automorphic side (a_p mod 3) at every good p ≤ 61. -/
theorem mod3_excursion_37a1 :
    goodPrimes.all (fun p => psi3HasRoot p == charpolyHasRootPm1Mod3 p) = true := by decide +kernel

end Oracles
