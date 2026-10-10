import Std

namespace NoveltyLab.Oracle

abbrev Vec := Array Nat
abbrev MulTable := Array (Array (Array Nat))

def wellSized (n : Nat) (t : MulTable) : Bool :=
  t.size == n &&
  t.all (fun row => row.size == n && row.all (fun cell => cell.size == n))

def vecSized (n : Nat) (x : Vec) : Bool := x.size == n

def add (p : Nat) (x y : Vec) : Vec :=
  (Array.range x.size).map (fun i => (x[i]! + y[i]!) % p)

def neg (p : Nat) (x : Vec) : Vec :=
  x.map (fun a => (p - (a % p)) % p)

def sub (p : Nat) (x y : Vec) : Vec := add p x (neg p y)

def mul (p : Nat) (t : MulTable) (x y : Vec) : Vec :=
  let n := x.size
  (Array.range n).map fun k =>
    (List.range n).foldl (fun acc i =>
      (List.range n).foldl (fun acc' j =>
        (acc' + x[i]! * y[j]! * t[i]![j]![k]!) % p) acc) 0

def assoc (p : Nat) (t : MulTable) (x y z : Vec) : Vec :=
  sub p (mul p t x (mul p t y z)) (mul p t (mul p t x y) z)

def zeroVec (n : Nat) : Vec := Array.replicate n 0

def sumVecs (p n : Nat) (vs : Array Vec) : Vec := vs.foldl (add p) (zeroVec n)

/-- The five binary parenthesizations of `abcd`, in pentagon order. -/
def vertices (p : Nat) (t : MulTable) (a b c d : Vec) : Array Vec :=
  let m := mul p t
  #[m (m (m a b) c) d, m (m a (m b c)) d, m a (m (m b c) d), m a (m b (m c d)), m (m a b) (m c d)]

/-- The signed associator edges of the pentagon; edge `i` runs from vertex `i` to vertex `i + 1`. -/
def pentagonEdges (p : Nat) (t : MulTable) (a b c d : Vec) : Array Vec :=
  #[mul p t (assoc p t a b c) d,
    assoc p t a (mul p t b c) d,
    mul p t a (assoc p t b c d),
    neg p (assoc p t a b (mul p t c d)),
    neg p (assoc p t (mul p t a b) c d)]

def pentagonBoundary (p : Nat) (t : MulTable) (a b c d : Vec) : Vec :=
  sumVecs p a.size (pentagonEdges p t a b c d)

def isZero (x : Vec) : Bool := x.all (fun a => a == 0)

def checkPentagon (p : Nat) (t : MulTable) (a b c d : Vec) : Bool :=
  let n := t.size
  p > 1 && wellSized n t &&
  vecSized n a && vecSized n b && vecSized n c && vecSized n d &&
  isZero (pentagonBoundary p t a b c d)

/-- Each edge term equals the difference of the vertices it joins, independently of the boundary sum. -/
def edgesMatchVertices (p : Nat) (t : MulTable) (a b c d : Vec) : Bool :=
  let v := vertices p t a b c d
  let e := pentagonEdges p t a b c d
  (List.range 5).all fun i => e[i]! == sub p v[(i + 1) % 5]! v[i]!

/-- Mutation control: negating edge `i` must break the boundary exactly when edge `i` is nonzero (p odd). -/
def killsSignFlips (p : Nat) (t : MulTable) (a b c d : Vec) : Bool :=
  let e := pentagonEdges p t a b c d
  (List.range 5).all fun i =>
    isZero (sumVecs p a.size (e.modify i (neg p))) == isZero e[i]!

/-- Mutation control: multiplying the outer factor on the wrong side must break the boundary. -/
def killsOrderSwaps (p : Nat) (t : MulTable) (a b c d : Vec) : Bool :=
  let e := pentagonEdges p t a b c d
  let swapped := #[e.set! 0 (mul p t d (assoc p t a b c)), e.set! 2 (mul p t (assoc p t b c d) a)]
  swapped.all fun terms => !isZero (sumVecs p a.size terms)

def scalarTable : MulTable := #[#[#[1]]]

def scalarSelfCheck : Bool :=
  checkPentagon 5 scalarTable #[2] #[3] #[4] #[1]

end NoveltyLab.Oracle
