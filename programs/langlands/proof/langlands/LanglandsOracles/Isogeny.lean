import LanglandsOracles.TraceFormula
import LanglandsOracles.Matrix
import LanglandsOracles.Data

/-!
# Lean recomputes the supersingular isogeny graphs.

F_{p²} = F_p[s]/(s² − c) with c the least quadratic non-residue; the supersingular λ are the roots
of the Hasse polynomial H_p(λ) = Σ C(m,i)² λ^i (m = (p−1)/2, Deuring), pushed to j = 256(λ²−λ+1)³/(λ²(λ−1)²);
B(ℓ)_{ij} = multiplicity of j_j as a root of Φ_ℓ(j_i, Y).  The kernel checks that the matrices so
obtained are the exported ones up to a simultaneous relabelling of the supersingular curves, and
that their number is tr B(1) = Eichler's mass.  Nothing about the graphs is imported from Python
except the data being certified.
-/
namespace Oracles

structure Fp2 (p : Nat) where
  a : Nat
  b : Nat
deriving DecidableEq, Repr

namespace Fp2

variable {p : Nat}

def nonResidue (p : Nat) : Nat :=
  ((List.range p).filter (fun c => c ≥ 2 && Nat.pow c ((p - 1) / 2) % p == p - 1)).headD 0

def ofNat (n : Nat) : Fp2 p := ⟨n % p, 0⟩
def ofInt (z : Int) : Fp2 p := ⟨((z % (p : Int) + p) % p).toNat, 0⟩

def zero : Fp2 p := ⟨0, 0⟩
def one : Fp2 p := ⟨1 % p, 0⟩

def add (x y : Fp2 p) : Fp2 p := ⟨(x.a + y.a) % p, (x.b + y.b) % p⟩
def sub (x y : Fp2 p) : Fp2 p := ⟨(x.a + p - y.a % p) % p, (x.b + p - y.b % p) % p⟩
def mul (c : Nat) (x y : Fp2 p) : Fp2 p :=
  ⟨(x.a * y.a + c * (x.b * y.b)) % p, (x.a * y.b + x.b * y.a) % p⟩

def powAux (c : Nat) (x : Fp2 p) : Nat → Nat → Fp2 p
  | _, 0 => one
  | n, fuel + 1 =>
    if n == 0 then one else
    let h := powAux c (mul c x x) (n / 2) fuel
    if n % 2 == 1 then mul c x h else h

def pow (c : Nat) (x : Fp2 p) (n : Nat) : Fp2 p := powAux c x n 64

def inv (c : Nat) (x : Fp2 p) : Fp2 p := pow c x (p * p - 2)

def elements (p : Nat) : List (Fp2 p) :=
  (List.range p).flatMap fun a => (List.range p).map fun b => ⟨a, b⟩

/-- Horner evaluation, coefficients low → high. -/
def evalPoly (c : Nat) (coeffs : List (Fp2 p)) (x : Fp2 p) : Fp2 p :=
  coeffs.foldr (fun co acc => add co (mul c acc x)) zero

/-- Synthetic division by (Y − r): (quotient, remainder). -/
def divLinear (c : Nat) (coeffs : List (Fp2 p)) (r : Fp2 p) : List (Fp2 p) × Fp2 p :=
  let rev := coeffs.reverse
  let step := rev.foldl (fun (st : List (Fp2 p) × Fp2 p) co =>
    let acc := add (mul c st.2 r) co
    (acc :: st.1, acc)) ([], zero)
  match step.1 with
  | [] => ([], zero)
  | rem :: qs => (qs, rem)

/-- Multiplicity of r as a root (repeated deflation, fuel = degree). -/
def multiplicity (c : Nat) (coeffs : List (Fp2 p)) (r : Fp2 p) : Nat :=
  let rec go (f : List (Fp2 p)) (fuel acc : Nat) : Nat :=
    match fuel with
    | 0 => acc
    | fuel + 1 =>
      let (q, rem) := divLinear c f r
      if rem == zero && f.length > 1 then go q fuel (acc + 1) else acc
  go coeffs coeffs.length 0

end Fp2

/-- Row m of Pascal's triangle. -/
def pascalRow : Nat → List Nat
  | 0 => [1]
  | m + 1 =>
    let prev := pascalRow m
    List.zipWith (· + ·) (0 :: prev) (prev ++ [0])

/-- Hasse polynomial coefficients C(m, i)² mod p, m = (p − 1)/2. -/
def hassePoly (p : Nat) : List (Fp2 p) :=
  (pascalRow ((p - 1) / 2)).map fun b => Fp2.ofNat (b * b)

def legendreToJ (p c : Nat) (lam : Fp2 p) : Fp2 p :=
  let l2 := Fp2.mul c lam lam
  let num := Fp2.pow c (Fp2.add (Fp2.sub l2 lam) Fp2.one) 3
  let den := Fp2.mul c l2 (Fp2.pow c (Fp2.sub lam Fp2.one) 2)
  Fp2.mul c (Fp2.mul c (Fp2.ofNat 256) num) (Fp2.inv c den)

/-- The supersingular j-invariants in F_{p²} (each once, in order of first appearance). -/
def supersingularJ (p : Nat) : List (Fp2 p) :=
  let c := Fp2.nonResidue p
  let H := hassePoly p
  let lams := (Fp2.elements p).filter fun x => Fp2.evalPoly c H x == Fp2.zero
  (lams.map (legendreToJ p c)).eraseDups

/-- Φ_ℓ as (i, k, coefficient) monomials X^i Y^k. -/
def phi2 : List (Nat × Nat × Int) :=
  [(3, 0, 1), (0, 3, 1), (2, 2, -1), (2, 1, 1488), (1, 2, 1488), (2, 0, -162000), (0, 2, -162000),
   (1, 1, 40773375), (1, 0, 8748000000), (0, 1, 8748000000), (0, 0, -157464000000000)]

def phi3 : List (Nat × Nat × Int) :=
  [(4, 0, 1), (0, 4, 1), (3, 3, -1), (3, 2, 2232), (2, 3, 2232), (3, 1, -1069956), (1, 3, -1069956),
   (3, 0, 36864000), (0, 3, 36864000), (2, 2, 2587918086), (2, 1, 8900222976000), (1, 2, 8900222976000),
   (2, 0, 452984832000000), (0, 2, 452984832000000), (1, 1, -770845966336000000),
   (1, 0, 1855425871872000000000), (0, 1, 1855425871872000000000)]

/-- Φ_ℓ(j, Y) as a polynomial in Y over F_{p²} (coefficients low → high, degree ℓ + 1). -/
def phiAt (p c ell : Nat) (phi : List (Nat × Nat × Int)) (j : Fp2 p) : List (Fp2 p) :=
  (List.range (ell + 2)).map fun k =>
    phi.foldl (fun acc m =>
      let (i, kk, co) := m
      if kk == k then Fp2.add acc (Fp2.mul c (Fp2.ofInt co) (Fp2.pow c j i)) else acc) Fp2.zero

/-- B(ℓ) computed in Lean: B_{ij} = multiplicity of j_j in Φ_ℓ(j_i, Y).  `none` if a root is not supersingular
    or the multiplicities do not add up to ℓ + 1. -/
def brandtLean (p ell : Nat) : Option IMat :=
  let c := Fp2.nonResidue p
  let js := supersingularJ p
  let phi := if ell == 2 then phi2 else phi3
  let rows := js.map fun ji =>
    let f := phiAt p c ell phi ji
    js.map fun jj => (Fp2.multiplicity c f jj : Int)
  if rows.all (fun r => r.foldl (· + ·) 0 == (ell : Int) + 1) then some rows else none

def insertEverywhere (x : Nat) : List Nat → List (List Nat)
  | [] => [[x]]
  | y :: ys => (x :: y :: ys) :: (insertEverywhere x ys).map (fun l => y :: l)

def permutations : List Nat → List (List Nat)
  | [] => [[]]
  | x :: xs => (permutations xs).flatMap (insertEverywhere x)

def relabel (σ : List Nat) (m : IMat) : IMat :=
  σ.map fun i => σ.map fun j => (m[i]!)[j]!

/-- Some relabelling of Lean's supersingular curves carries Lean's B(2) and B(3) to the exported ones.
    Both degrees must be present in the exported entry: a locus missing either is rejected, so the
    check cannot pass vacuously. -/
def isogenyGraphCertified (entry : Nat × List Nat × List (Nat × IMat)) : Bool :=
  let (p, w, ms) := entry
  let n := w.length
  let js := supersingularJ p
  js.length == n && ((12 : Int) * n == eichlerBrandt12 p 1) &&
  ms.any (fun m => m.1 == 2) && ms.any (fun m => m.1 == 3) &&
  (permutations (List.range n)).any fun σ =>
    ms.all fun m =>
      if m.1 == 2 || m.1 == 3 then
        match brandtLean p m.1 with
        | some B => relabel σ B == m.2
        | none => false
      else true

/-- Negative control: the p = 11 locus with its ℓ = 3 entry removed is not certified. -/
theorem missing_degree_is_rejected :
    isogenyGraphCertified (11, [6, 4], [(2, [[0, 3], [2, 1]])]) = false := by decide +kernel

/-- Non-vacuity: at p = 13 there is one supersingular curve and B(2) = [3], B(3) = [4]; at p = 11 two curves
    (j = 0, 1728) with row sums 3 and 4. -/
theorem isogeny_small_cases :
    (supersingularJ 13).length = 1 ∧ brandtLean 13 2 = some [[3]] ∧ brandtLean 13 3 = some [[4]] ∧
    (supersingularJ 11).length = 2 ∧
    (brandtLean 11 2).map (fun B => B.map (fun r => r.foldl (· + ·) 0)) = some [3, 3] := by decide +kernel

/-- Every exported locus (p = 11 … 37): Lean's isogeny graphs at ℓ = 2, 3 are the exported Brandt matrices
    up to a simultaneous relabelling, and the number of curves is Eichler's mass tr B(1). -/
theorem isogeny_graphs_recomputed : brandtData.all isogenyGraphCertified = true := by decide +kernel

end Oracles
