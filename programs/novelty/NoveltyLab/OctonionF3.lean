import NoveltyLab.Oracle

namespace NoveltyLab.OctonionF3

open NoveltyLab.Oracle

def productIndex : Array (Array Nat) := #[
  #[0,1,2,3,4,5,6,7], #[1,0,3,2,5,4,7,6],
  #[2,3,0,1,6,7,4,5], #[3,2,1,0,7,6,5,4],
  #[4,5,6,7,0,1,2,3], #[5,4,7,6,1,0,3,2],
  #[6,7,4,5,2,3,0,1], #[7,6,5,4,3,2,1,0]
]

def productCoeff : Array (Array Nat) := #[
  #[1,1,1,1,1,1,1,1], #[1,2,1,2,1,2,2,1],
  #[1,2,2,1,1,1,2,2], #[1,1,2,2,1,2,1,2],
  #[1,2,2,2,2,1,1,1], #[1,1,2,1,2,2,2,1],
  #[1,1,1,2,2,1,2,2], #[1,2,1,1,2,2,1,2]
]

def table : MulTable :=
  (Array.range 8).map fun i =>
    (Array.range 8).map fun j =>
      (Array.range 8).map fun k =>
        if k == productIndex[i]![j]! then productCoeff[i]![j]! else 0

def basis (i : Nat) : Vec :=
  (Array.range 8).map fun j => if i == j then 1 else 0

def dot (x y : Vec) : Nat :=
  (List.range 8).foldl (fun acc i => (acc + x[i]! * y[i]!) % 3) 0

def primeTrial (n : Nat) : Bool :=
  n >= 2 && (List.range (n - 2)).all (fun k => n % (k + 2) != 0)

def unitChecks : Bool :=
  (Array.range 8).all fun i =>
    mul 3 table (basis 0) (basis i) == basis i &&
    mul 3 table (basis i) (basis 0) == basis i

/-- The associator is alternating on basis vectors; trilinearity extends this
    certificate to all vectors because 2 is invertible in F_3. -/
def alternativeChecks : Bool :=
  (Array.range 8).all fun i =>
    (Array.range 8).all fun j =>
      (Array.range 8).all fun k =>
        isZero (add 3 (assoc 3 table (basis i) (basis j) (basis k))
                      (assoc 3 table (basis j) (basis i) (basis k))) &&
        isZero (add 3 (assoc 3 table (basis i) (basis j) (basis k))
                      (assoc 3 table (basis i) (basis k) (basis j)))

/-- Coefficients of L_x^T L_x = N(x) I for N(x)=sum x_i^2.
    Diagonal coefficients and polarized cross coefficients are checked. -/
def compositionChecks : Bool :=
  (Array.range 8).all fun i =>
    (Array.range 8).all fun k =>
      (Array.range 8).all fun j =>
        (Array.range 8).all fun l =>
          let a := dot (mul 3 table (basis i) (basis j))
                       (mul 3 table (basis k) (basis l))
          if i == k then
            a == (if j == l then 1 else 0)
          else if i < k then
            let b := dot (mul 3 table (basis k) (basis j))
                         (mul 3 table (basis i) (basis l))
            (a + b) % 3 == 0
          else true

def witnessEdges : Array Vec :=
  pentagonEdges 3 table (basis 0) (basis 1) (basis 2) (basis 4)

def witnessCheck : Bool :=
  checkPentagon 3 table (basis 0) (basis 1) (basis 2) (basis 4) &&
  witnessEdges.any (fun edge => !(isZero edge)) &&
  witnessEdges[2]! == basis 7 &&
  witnessEdges[4]! == neg 3 (basis 7)

/-- Canonical JSON derived from the actual tensor evaluated by this module.
    Python hashes these bytes and compares them with its independent replay. -/
def provenanceSerialization : String :=
  let vector := fun (v : Vec) =>
    "[" ++ String.intercalate "," (v.toList.map toString) ++ "]"
  let rows := table.toList.map fun row =>
    "[" ++ String.intercalate "," (row.toList.map vector) ++ "]"
  "{\"modulus\":3,\"table\":[" ++ String.intercalate "," rows ++ "]}"

def selfCheck : Bool :=
  primeTrial 3 && wellSized 8 table && unitChecks &&
  alternativeChecks && compositionChecks && witnessCheck

end NoveltyLab.OctonionF3
