/-!
# The Carlitz module over F_p[t] and the Fermat–Carlitz identity  C_P(x) ≡ x^{p^{deg P}} (mod P).

Polynomials over F_p are lists of coefficients (low → high).  C_a is a p-polynomial
Σ c_i x^{p^i} with c_i ∈ F_p[t]; C_t = t x + x^p and C_{t^{i+1}} = t·C_{t^i} + (C_{t^i})^p.
-/
namespace Oracles

abbrev FpPoly := List Nat

def trimZeros (a : FpPoly) : FpPoly := (a.reverse.dropWhile (· == 0)).reverse

def FpPoly.add (p : Nat) (a b : FpPoly) : FpPoly :=
  let n := max a.length b.length
  let pad (x : FpPoly) := x ++ List.replicate (n - x.length) 0
  trimZeros (List.zipWith (fun x y => (x + y) % p) (pad a) (pad b))

def FpPoly.mul (p : Nat) (a b : FpPoly) : FpPoly :=
  if a.isEmpty || b.isEmpty then [] else
  let n := a.length + b.length - 1
  ((List.range n).map (fun k =>
    ((List.range (k + 1)).foldl (fun acc i =>
      if i < a.length && k - i < b.length then acc + a[i]! * b[k - i]! else acc) 0) % p)) |> trimZeros

def FpPoly.scale (p : Nat) (c : Nat) (a : FpPoly) : FpPoly := (a.map (fun x => c * x % p)) |> trimZeros

/-- c(t)^p = c(t^p) in F_p[t]. -/
def FpPoly.frobenius (p : Nat) (c : FpPoly) : FpPoly :=
  if c.isEmpty then [] else
  ((List.range (p * (c.length - 1) + 1)).map (fun i => if i % p == 0 then c[i / p]! else 0)) |> trimZeros

/-- Remainder of a modulo a monic m. -/
def FpPoly.mod (p : Nat) (a m : FpPoly) : FpPoly :=
  let d := m.length - 1
  let rec go (fuel : Nat) (r : FpPoly) : FpPoly :=
    match fuel with
    | 0 => r
    | fuel + 1 =>
      if r.length ≤ d then r else
      let c := r.getLast!
      let shift := r.length - 1 - d
      let sub := List.replicate shift 0 ++ m.map (fun x => (p - c * x % p) % p)
      go fuel (FpPoly.add p r sub)
  go a.length (trimZeros a)

/-- C_a as a p-polynomial: coefficients of x^{p^i}, i = 0 .. deg a. -/
def carlitz (p : Nat) (a : FpPoly) : List FpPoly :=
  let t : FpPoly := [0, 1]
  let step (prev : List FpPoly) : List FpPoly :=
    (List.range (prev.length + 1)).map (fun i =>
      let fromT := if i < prev.length then FpPoly.mul p t prev[i]! else []
      let fromFrob := if i ≥ 1 then FpPoly.frobenius p prev[i - 1]! else []
      FpPoly.add p fromT fromFrob)
  let powers : List (List FpPoly) := (List.range a.length).foldl (fun acc _ => acc ++ [step acc.getLast!]) [[[1]]]
  (List.range a.length).foldl (fun out i =>
    let ci := powers[i]!
    (List.range a.length).map (fun k =>
      FpPoly.add p out[k]! (if h : k < ci.length then FpPoly.scale p a[i]! ci[k] else []))) (List.replicate a.length ([] : FpPoly))

/-- C_P(x) ≡ x^{p^{deg P}} (mod P): every coefficient is 0 mod P except the top one, which is 1. -/
def fermatCarlitz (p : Nat) (P : FpPoly) : Bool :=
  let d := P.length - 1
  (carlitz p P).zipIdx.all (fun ci =>
    FpPoly.mod p ci.1 P == (if ci.2 == d then [1] else []))

end Oracles
