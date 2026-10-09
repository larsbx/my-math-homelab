import LanglandsOracles.Data

/-!
# Certificates on exported L-series data (37a1 mod p; branch 1).

The coefficient of T^n of L(chi, T) is exported as an integer vector c ∈ Z[Z/N]
(c[r] = number of terms equal to zeta_N^r).  Lean checks:
  * chi ≠ 1: Σ_r c[r] x^r ≡ 0 (mod Φ_N(x)) for every n ≥ 1, i.e. the coefficient is 0 in Z[ζ_N];
  * chi = 1: Σ_r c[r] equals the n-th coefficient of Z(E, T) = (1 − a T + p T²)/((1 − T)(1 − pT)).
Φ_N is computed here as x^N − 1 divided by the product of Φ_d over proper divisors d of N.
-/
namespace Oracles

abbrev IPoly := List Int  -- low → high

def IPoly.trim (a : IPoly) : IPoly := (a.reverse.dropWhile (· == 0)).reverse

def IPoly.sub (a b : IPoly) : IPoly :=
  let n := max a.length b.length
  let pad (x : IPoly) := x ++ List.replicate (n - x.length) 0
  IPoly.trim (List.zipWith (· - ·) (pad a) (pad b))

def IPoly.mul (a b : IPoly) : IPoly :=
  if a.isEmpty || b.isEmpty then [] else
  IPoly.trim ((List.range (a.length + b.length - 1)).map (fun k =>
    (List.range (k + 1)).foldl (fun acc i =>
      if i < a.length && k - i < b.length then acc + a[i]! * b[k - i]! else acc) 0))

/-- Exact division by a monic polynomial: (quotient, remainder). -/
def IPoly.divmodMonic (a m : IPoly) : IPoly × IPoly :=
  let d := m.length - 1
  let rec go (fuel : Nat) (r : IPoly) (q : IPoly) : IPoly × IPoly :=
    match fuel with
    | 0 => (q, r)
    | fuel + 1 =>
      if r.length ≤ d then (q, r) else
      let c := r.getLast!
      let shift := r.length - 1 - d
      let sub := List.replicate shift 0 ++ m.map (c * ·)
      go fuel (IPoly.sub r sub) (IPoly.sub q (List.replicate shift 0 ++ [-c]))
  go a.length (IPoly.trim a) []

def xPowMinusOne (n : Nat) : IPoly := (-1) :: List.replicate (n - 1) 0 ++ [1]

/-- Φ_1, …, Φ_N, built in order: Φ_n = (x^n − 1) / ∏_{d | n, d < n} Φ_d (structural, via foldl). -/
def cyclotomics (N : Nat) : List IPoly :=
  (List.range' 1 N).foldl (fun acc n =>
    let prod := (acc.zipIdx.foldl (fun q pd => if n % (pd.2 + 1) == 0 then IPoly.mul q pd.1 else q) [1])
    acc ++ [(IPoly.divmodMonic (xPowMinusOne n) prod).1]) []

def cyclotomic (N : Nat) : IPoly := (cyclotomics N).getLast!

def isZeroInCyclotomicField (N : Nat) (c : List Int) : Bool :=
  (IPoly.divmodMonic c (cyclotomic N)).2 == []

/-- Coefficients c_0..c_D of Z(E, T) = (1 − a T + p T²) / ((1 − T)(1 − pT)). -/
def zetaCoefficients (p : Nat) (a : Int) (D : Nat) : List Int :=
  let num : List Int := [1, -a, (p : Int)]
  ((List.range (D + 1)).foldl (fun (acc : List Int) n =>
    let prev1 := if n ≥ 1 then acc[n - 1]! else 0
    let prev2 := if n ≥ 2 then acc[n - 2]! else 0
    acc ++ [(if n < 3 then num[n]! else 0) + ((p : Int) + 1) * prev1 - (p : Int) * prev2]) [])

def lSeriesCertified (entry : Nat × Int × Nat × List (Bool × List (List Int))) : Bool :=
  let (p, a, N, chars) := entry
  chars.all (fun ch =>
    let coeffs := ch.2
    if ch.1 then coeffs.map (fun c => c.foldl (· + ·) 0) == zetaCoefficients p a (coeffs.length - 1)
    else (coeffs.drop 1).all (fun c => isZeroInCyclotomicField N c) &&
         !((coeffs.drop 1).all (fun c => c.foldl (· + ·) 0 == 0)))  -- vanishing is in Z[ζ], not termwise

theorem cyclotomic_8_and_9 : cyclotomic 8 = [1, 0, 0, 0, 1] ∧ cyclotomic 9 = [1, 0, 0, 1, 0, 0, 1] := by decide

theorem lseries_certificates : lSeriesData.all lSeriesCertified = true := by decide +kernel

end Oracles
