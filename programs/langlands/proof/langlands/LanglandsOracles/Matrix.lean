/-! Integer matrices as lists of rows: the little algebra the Brandt certificates need. -/
namespace Oracles

abbrev IMat := List (List Int)

def IMat.trace (m : IMat) : Int :=
  (m.zipIdx.map (fun r => r.1[r.2]!)).foldl (· + ·) 0

def IMat.rowSums (m : IMat) : List Int := m.map (fun r => r.foldl (· + ·) 0)

def IMat.transpose (m : IMat) : IMat :=
  match m with
  | [] => []
  | r :: _ => (List.range r.length).map (fun j => m.map (fun row => row[j]!))

def IMat.mul (a b : IMat) : IMat :=
  let bt := b.transpose
  a.map (fun row => bt.map (fun col => (List.zipWith (· * ·) row col).foldl (· + ·) 0))

def IMat.scale (c : Int) (a : IMat) : IMat := a.map (fun r => r.map (c * ·))

def IMat.add (a b : IMat) : IMat := List.zipWith (List.zipWith (· + ·)) a b

def IMat.sub (a b : IMat) : IMat := List.zipWith (List.zipWith (· - ·)) a b

def IMat.identity (n : Nat) : IMat :=
  (List.range n).map (fun i => (List.range n).map (fun j => if i == j then 1 else 0))

def IMat.scaleRows (w : List Nat) (a : IMat) : IMat :=
  List.zipWith (fun wi r => r.map ((wi : Int) * ·)) w a

def IMat.scaleCols (w : List Nat) (a : IMat) : IMat :=
  a.map (fun r => List.zipWith (fun (x : Int) (wj : Nat) => x * (wj : Int)) r w)

end Oracles
