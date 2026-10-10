import LanglandsOracles.QForms
/-!
# Two trace formulas with geometric side = class numbers, recomputed in Lean.

`traceLevel1 k n` = tr T_n | S_k(SL₂(ℤ)) (Zagier's form of Eichler–Selberg).
`eichlerBrandt12 p n` = 12 · tr B(n) on the definite quaternion algebra B_{p,∞}.
`tau n` from Δ = q ∏ (1 − qⁿ)²⁴, an independent spectral side.
-/
namespace Oracles

/-- (ρ^{k−1} − ρ̄^{k−1}) / (ρ − ρ̄) with ρ + ρ̄ = t, ρ ρ̄ = n. -/
def chebP (k : Nat) (t n : Int) : Int :=
  let rec go : Nat → Int → Int → Int
    | 0, _, b => b
    | m + 1, a, b => go m b (t * b - n * a)
  go (k - 2) 0 1

/-- 24 · tr T_n | S_k(SL₂(ℤ)) as an integer, before the exact division by 24. -/
def traceLevel1x24 (k n : Nat) : Int :=
  let tmax := isqrt (4 * n)
  let ts := (List.range (2 * tmax + 1)).map (fun (i : Nat) => (i : Int) - (tmax : Int))
  let elliptic := ts.foldl (fun acc t =>
    acc + chebP k t n * hurwitz12 (4 * n - (t * t).toNat)) 0
  let hyperbolic := (List.range' 1 n).foldl (fun acc d =>
    if n % d == 0 then acc + (Nat.pow (min d (n / d)) (k - 1) : Int) else acc) 0
  Int.neg (elliptic + 12 * hyperbolic)

def traceLevel1 (k n : Nat) : Int := traceLevel1x24 k n / 24

def traceLevel1Exact (k n : Nat) : Bool := traceLevel1x24 k n % 24 == 0

/-- Multiply a truncated series (coefficients low → high) by (1 − q^m). -/
def timesOneMinusQm (s : List Int) (m : Nat) : List Int :=
  List.zipWith (· - ·) s (List.replicate m 0 ++ s)

/-- τ(1..nmax) from Δ = q ∏_{m ≥ 1} (1 − q^m)^{24}, all structural recursion. -/
def tau (nmax : Nat) : List Int :=
  let one : List Int := 1 :: List.replicate nmax 0
  let s := (List.range' 1 nmax).foldl (fun s m =>
    (List.range 24).foldl (fun s _ => timesOneMinusQm s m) s) one
  s.take nmax

def isSquare (n : Nat) : Bool := isqrt n * isqrt n == n

/-- 12 · tr B(n) on B_{p,∞}:
  [n = □] (p−1) + 12 Σ_{s² < 4n} Σ_{f : p ∤ f} h(d)/w(d) · (1 − (d/p)),  d = (s²−4n)/f². -/
def eichlerBrandt12 (p n : Nat) : Int :=
  let base : Int := if isSquare n then (p : Int) - 1 else 0
  let smax := isqrt (4 * n - 1)
  let ss := (List.range (2 * smax + 1)).map (fun (i : Nat) => (i : Int) - (smax : Int))
  ss.foldl (fun acc s =>
    (squareDivisors (s * s - 4 * n)).foldl (fun acc fd =>
      if fd.1 % p == 0 then acc
      else acc + (12 * classNumber fd.2 / unitCount fd.2 : Nat) * (1 - kronecker fd.2 p)) acc) base

end Oracles

namespace Oracles

/-- ψ(N) = N ∏_{p | N} (1 + 1/p), the index of Γ₀(N) in SL₂(ℤ), by trial division. -/
def psi (N : Nat) : Nat :=
  let rec go (m acc p fuel : Nat) : Nat :=
    match fuel with
    | 0 => if m > 1 then acc * (m + 1) / m else acc
    | fuel + 1 =>
      if p * p > m then (if m > 1 then acc * (m + 1) / m else acc)
      else if m % p == 0 then
        let rec strip (m fuel : Nat) : Nat :=
          match fuel with
          | 0 => m
          | fuel + 1 => if m % p == 0 then strip (m / p) fuel else m
        go (strip m m) (acc * (p + 1) / p) (p + 1) fuel
      else go m acc (p + 1) fuel
  go N N 2 N

def phiNat (n : Nat) : Nat := ((List.range' 1 n).filter (fun k => Nat.gcd k n == 1)).length

def divisors (n : Nat) : List Nat := (List.range' 1 n).filter (fun d => n % d == 0)

/-- μ(t, f, n) = ψ(N)/ψ(N/N_f) · #{x mod N : x² − t x + n ≡ 0 (mod N N_f)}, N_f = gcd(N, f). -/
def muLocal (N : Nat) (t : Int) (f n : Nat) : Int :=
  let Nf := Nat.gcd N f
  let modulus : Int := (N * Nf : Nat)
  let count := ((List.range N).filter (fun (x : Nat) => ((x : Int) * (x : Int) - t * (x : Int) + (n : Int)) % modulus == 0)).length
  ((psi N / psi (N / Nf) : Nat) : Int) * count

/-- 24 · tr T_n | S_k(Γ₀(N)) for gcd(n, N) = 1, trivial character:
  24 A₁ = 2 [n = □] n^{k/2−1} (k−1) ψ(N),
  24 A₂ = −Σ_{t² < 4n} P_k(t, n) Σ_f (24 h(d)/w(d)) μ(t, f, n),   d = (t² − 4n)/f²,
  24 A₃ = −12 Σ_{d | n} min(d, n/d)^{k−1} Σ_{c | N, gcd(c, N/c) | (n/d − d)} φ(gcd(c, N/c)),
  24 A₄ = 24 [k = 2] Σ_{t | n, gcd(N, n/t) = 1} t. -/
def eichlerSelbergN24 (N k n : Nat) : Int :=
  let a1 : Int := if isSquare n then 2 * ((Nat.pow (isqrt n) (k - 2) * (k - 1) * psi N : Nat) : Int) else 0
  let tmax := isqrt (4 * n - 1)
  let ts := (List.range (2 * tmax + 1)).map (fun (i : Nat) => (i : Int) - (tmax : Int))
  let a2 : Int := ts.foldl (fun acc t =>
    acc - chebP k t n * ((squareDivisors (t * t - 4 * n)).foldl (fun s fd =>
      s + ((24 * classNumber fd.2 / unitCount fd.2 : Nat) : Int) * muLocal N t fd.1 n) 0)) 0
  let a3 : Int := (divisors n).foldl (fun acc d =>
    let inner := ((divisors N).filter (fun c =>
      let g := Nat.gcd c (N / c)
      (((n / d : Nat) : Int) - (d : Int)) % (g : Int) == 0)).foldl (fun s c => s + phiNat (Nat.gcd c (N / c))) 0
    acc - 12 * ((Nat.pow (min d (n / d)) (k - 1) * inner : Nat) : Int)) 0
  let a4 : Int := if k == 2 then 24 * (((divisors n).filter (fun t => Nat.gcd N (n / t) == 1)).foldl (· + ·) 0 : Nat) else 0
  a1 + a2 + a3 + a4

end Oracles
