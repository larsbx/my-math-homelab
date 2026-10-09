/-!
# Class numbers of imaginary quadratic orders, by exhaustive reduced-form count.

Core Lean 4 only (no Mathlib).  `classNumber d` counts primitive reduced forms
(a, b, c) with b² − 4ac = d, |b| ≤ a ≤ c, b ≥ 0 when |b| = a or a = c.
`hurwitz12 N` is 12·H(N) (an integer), with H(0) = −1/12.
-/
namespace Oracles

/-- ⌊√n⌋ by structural search (kernel-reducible, unlike `Nat.sqrt`). -/
def isqrt (n : Nat) : Nat :=
  (List.range (n + 2)).foldl (fun acc r => if r * r ≤ n then r else acc) 0

def isDiscriminant (d : Int) : Bool := d < 0 && (d % 4 == 0 || d % 4 == 1)

/-- Number of primitive reduced forms of discriminant `d < 0`. -/
def classNumber (d : Int) : Nat :=
  let D := (-d).toNat
  let aMax := isqrt (D / 3)
  (List.range' 1 aMax).foldl (fun acc a =>
    let bs := (List.range (2 * a + 1)).map (fun (i : Nat) => (i : Int) - (a : Int))
    acc + bs.countP (fun b =>
      let num := b * b - d
      num % (4 * a) == 0 &&
      (let c := num / (4 * a)
       c ≥ a &&
       Nat.gcd (Nat.gcd a b.natAbs) c.toNat == 1 &&
       !(b < 0 && (b.natAbs == a || (a : Int) == c))))) 0

def unitCount (d : Int) : Nat := if d == -3 then 6 else if d == -4 then 4 else 2

/-- All (f, d) with f² ∣ D, d = D / f² a discriminant (D < 0). -/
def squareDivisors (D : Int) : List (Nat × Int) :=
  (List.range' 1 (isqrt (-D).toNat)).filterMap (fun (f : Nat) =>
    let f2 : Int := f * f
    if D % f2 == 0 && isDiscriminant (D / f2) then some ((f : Nat), D / f2) else none)

/-- 12 · H(N):  H(N) = Σ_{d f² = −N} h(d) / (w(d)/2),  H(0) = −1/12. -/
def hurwitz12 (N : Nat) : Int :=
  if N == 0 then -1
  else if N % 4 == 1 || N % 4 == 2 then 0
  else (squareDivisors (-(N : Int))).foldl (fun acc fd =>
    acc + (24 * classNumber fd.2 / unitCount fd.2 : Nat)) 0

/-- Legendre symbol (d / p) for an odd prime p, as −1, 0, 1. -/
def kronecker (d : Int) (p : Nat) : Int :=
  let r := Nat.pow (d % p).toNat ((p - 1) / 2) % p
  if r == 0 then 0 else if r == 1 then 1 else -1

end Oracles
