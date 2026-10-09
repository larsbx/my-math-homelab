import Lean

/-!
# A reflective normalizer for commutative rings, within the audit's axioms

`grind` and core's own ring normalizer (`Lean.Grind.CommRing.Expr.denote_toPoly`) both depend on
`Classical.choice`, which the axiom audit rejects.  This module is a small replacement.  A ring
expression (`RExpr`: atoms, 0, 1, +, −, ·, negation) is normalized to a sum of monomials with integer
coefficients, monomials as sorted lists of atom indices and the sum sorted with like terms merged
(`norm`).  `denote_norm` (PROVED, propext / Quot.sound) says normalization preserves the value in every
commutative ring, so `eq_of_norm` turns an equality of normal forms — a closed computation that
`decide +kernel` evaluates — into an equality in the ring.  Normal forms need not be unique for the
argument to be sound: a false identity can never produce equal normal forms.

The tactic `ring_eq` reifies the two sides of a goal over a `Lean.Grind.CommRing` (the meta code is
not part of the proof term) and closes it this way; `eq_of_sub_eq_zero` and `lin_comb` turn an
identity "a − b equals a combination of hypotheses" into a = b, with `lc_add` assembling the
combination from the hypotheses' statements.
-/
namespace Oracles.RingNorm

open Lean.Grind

inductive RExpr where
  | atom (i : Nat)
  | zero
  | one
  | add (a b : RExpr)
  | sub (a b : RExpr)
  | mul (a b : RExpr)
  | neg (a : RExpr)

/-- Monomials (sorted atom indices) and polynomials (integer coefficients, sorted, merged). -/
abbrev Mon := List Nat
abbrev Poly := List (Int × Mon)

def insM (i : Nat) : Mon → Mon
  | [] => [i]
  | j :: m => if Nat.ble i j then i :: j :: m else j :: insM i m

def mulM : Mon → Mon → Mon
  | [], m => m
  | i :: m, m' => insM i (mulM m m')

def eqM : Mon → Mon → Bool
  | [], [] => true
  | i :: m, j :: m' => Nat.beq i j && eqM m m'
  | _, _ => false

def ltM : Mon → Mon → Bool
  | [], [] => false
  | [], _ :: _ => true
  | _ :: _, [] => false
  | i :: m, j :: m' => Nat.blt i j || (Nat.beq i j && ltM m m')

def insT (c : Int) (m : Mon) : Poly → Poly
  | [] => [(c, m)]
  | (c', m') :: p =>
    if eqM m m' then (if c + c' = 0 then p else (c + c', m') :: p)
    else if ltM m m' then (c, m) :: (c', m') :: p
    else (c', m') :: insT c m p

def addT (c : Int) (m : Mon) (p : Poly) : Poly := if c = 0 then p else insT c m p

def addP : Poly → Poly → Poly
  | [], q => q
  | (c, m) :: p, q => addT c m (addP p q)

def mulTP (c : Int) (m : Mon) : Poly → Poly
  | [] => []
  | (c', m') :: q => addT (c * c') (mulM m m') (mulTP c m q)

def mulP : Poly → Poly → Poly
  | [], _ => []
  | (c, m) :: p, q => addP (mulTP c m q) (mulP p q)

def negP : Poly → Poly
  | [] => []
  | (c, m) :: p => (-c, m) :: negP p

def norm : RExpr → Poly
  | .atom i => [(1, [i])]
  | .zero => []
  | .one => [(1, [])]
  | .add a b => addP (norm a) (norm b)
  | .sub a b => addP (norm a) (negP (norm b))
  | .mul a b => mulP (norm a) (norm b)
  | .neg a => negP (norm a)

section denote

variable {R : Type} [CommRing R]

attribute [local instance] Ring.intCast

def atomD (ctx : List R) (i : Nat) : R := ctx.getD i 0

def RExpr.denote (ctx : List R) : RExpr → R
  | .atom i => atomD ctx i
  | .zero => 0
  | .one => 1
  | .add a b => a.denote ctx + b.denote ctx
  | .sub a b => a.denote ctx - b.denote ctx
  | .mul a b => a.denote ctx * b.denote ctx
  | .neg a => -(a.denote ctx)

def monD (ctx : List R) : Mon → R
  | [] => 1
  | i :: m => atomD ctx i * monD ctx m

def polyD (ctx : List R) : Poly → R
  | [] => 0
  | (c, m) :: p => (Int.cast c : R) * monD ctx m + polyD ctx p

-- the commutative-ring facts used below, from core's `Lean.Grind` axioms (no `Classical`)
theorem zero_add' (a : R) : 0 + a = a := by rw [Semiring.add_comm, Semiring.add_zero]

theorem add_left_comm' (a b c : R) : a + (b + c) = b + (a + c) := by
  rw [← Semiring.add_assoc, Semiring.add_comm a b, Semiring.add_assoc]

theorem mul_left_comm' (a b c : R) : a * (b * c) = b * (a * c) := by
  rw [← Semiring.mul_assoc, CommSemiring.mul_comm a b, Semiring.mul_assoc]

theorem add_neg_cancel' (a : R) : a + -a = 0 := by
  rw [Semiring.add_comm]; exact Ring.neg_add_cancel a

theorem neg_add' (a b : R) : -(a + b) = -a + -b := by
  have h : (a + b) + (-a + -b) = 0 := by
    rw [Semiring.add_assoc, add_left_comm' b, ← Semiring.add_assoc, add_neg_cancel', add_neg_cancel',
      Semiring.add_zero]
  calc -(a + b) = -(a + b) + ((a + b) + (-a + -b)) := by rw [h, Semiring.add_zero]
    _ = (-(a + b) + (a + b)) + (-a + -b) := (Semiring.add_assoc (-(a + b)) (a + b) (-a + -b)).symm
    _ = -a + -b := by rw [Ring.neg_add_cancel, zero_add']

theorem neg_zero' : -(0 : R) = 0 :=
  calc -(0 : R) = -0 + 0 := (Semiring.add_zero _).symm
    _ = 0 := Ring.neg_add_cancel 0

theorem monD_insM (ctx : List R) (i : Nat) : ∀ m, monD ctx (insM i m) = atomD ctx i * monD ctx m
  | [] => rfl
  | j :: m => by
    unfold insM
    split
    · rfl
    · show atomD ctx j * monD ctx (insM i m) = _
      rw [monD_insM ctx i m]
      exact mul_left_comm' _ _ _

theorem monD_mulM (ctx : List R) : ∀ m m', monD ctx (mulM m m') = monD ctx m * monD ctx m'
  | [], m' => (Semiring.one_mul _).symm
  | i :: m, m' => by
    show monD ctx (insM i (mulM m m')) = atomD ctx i * monD ctx m * monD ctx m'
    rw [monD_insM, monD_mulM ctx m m', Semiring.mul_assoc]

theorem eqM_sound : ∀ {m m' : Mon}, eqM m m' = true → m = m'
  | [], [], _ => rfl
  | i :: m, j :: m', h => by
    have h1 := (Bool.and_eq_true _ _).mp h
    rw [Nat.eq_of_beq_eq_true h1.1, eqM_sound h1.2]
  | [], _ :: _, h => absurd h Bool.false_ne_true
  | _ :: _, [], h => absurd h Bool.false_ne_true

theorem polyD_insT (ctx : List R) (c : Int) (m : Mon) : ∀ p, polyD ctx (insT c m p) = (Int.cast c : R) * monD ctx m + polyD ctx p
  | [] => rfl
  | (c', m') :: p => by
    unfold insT
    split
    · next he =>
      rw [eqM_sound he]
      split
      · next hz =>
        show polyD ctx p = (Int.cast c : R) * monD ctx m' + ((Int.cast c' : R) * monD ctx m' + polyD ctx p)
        rw [← Semiring.add_assoc, ← Semiring.right_distrib, ← Ring.intCast_add, hz, Ring.intCast_zero,
          Semiring.zero_mul, zero_add']
      · show (Int.cast (c + c') : R) * monD ctx m' + polyD ctx p = _
        rw [Ring.intCast_add, Semiring.right_distrib, Semiring.add_assoc]; rfl
    · split
      · rfl
      · show (Int.cast c' : R) * monD ctx m' + polyD ctx (insT c m p) = _
        rw [polyD_insT ctx c m p]
        exact add_left_comm' _ _ _

theorem polyD_addT (ctx : List R) (c : Int) (m : Mon) (p : Poly) :
    polyD ctx (addT c m p) = (Int.cast c : R) * monD ctx m + polyD ctx p := by
  unfold addT
  split
  · next hz => rw [hz, Ring.intCast_zero, Semiring.zero_mul, zero_add']
  · exact polyD_insT ctx c m p

theorem polyD_addP (ctx : List R) : ∀ p q, polyD ctx (addP p q) = polyD ctx p + polyD ctx q
  | [], q => (zero_add' _).symm
  | (c, m) :: p, q => by
    show polyD ctx (addT c m (addP p q)) = _
    rw [polyD_addT, polyD_addP ctx p q, ← Semiring.add_assoc]; rfl

theorem polyD_mulTP (ctx : List R) (c : Int) (m : Mon) : ∀ q, polyD ctx (mulTP c m q) = (Int.cast c : R) * monD ctx m * polyD ctx q
  | [] => (Semiring.mul_zero _).symm
  | (c', m') :: q => by
    show polyD ctx (addT (c * c') (mulM m m') (mulTP c m q)) = (Int.cast c : R) * monD ctx m * ((Int.cast c' : R) * monD ctx m' + polyD ctx q)
    rw [polyD_addT, polyD_mulTP ctx c m q, Semiring.left_distrib, Ring.intCast_mul, monD_mulM]
    congr 1
    rw [Semiring.mul_assoc, Semiring.mul_assoc, mul_left_comm' (monD ctx m) (Int.cast c' : R), ← Semiring.mul_assoc]

theorem polyD_mulP (ctx : List R) : ∀ p q, polyD ctx (mulP p q) = polyD ctx p * polyD ctx q
  | [], q => (Semiring.zero_mul _).symm
  | (c, m) :: p, q => by
    show polyD ctx (addP (mulTP c m q) (mulP p q)) = ((Int.cast c : R) * monD ctx m + polyD ctx p) * polyD ctx q
    rw [polyD_addP, polyD_mulTP, polyD_mulP ctx p q, Semiring.right_distrib]

theorem polyD_negP (ctx : List R) : ∀ p, polyD ctx (negP p) = -polyD ctx p
  | [] => neg_zero'.symm
  | (c, m) :: p => by
    show (Int.cast (-c) : R) * monD ctx m + polyD ctx (negP p) = -((Int.cast c : R) * monD ctx m + polyD ctx p)
    rw [polyD_negP ctx p, Ring.intCast_neg, Ring.neg_mul, neg_add']

/-- **Normalization preserves the value**, in every commutative ring. -/
theorem denote_norm (ctx : List R) : ∀ e : RExpr, polyD ctx (norm e) = e.denote ctx
  | .atom i => by
    show (Int.cast (1 : Int) : R) * (atomD ctx i * 1) + 0 = atomD ctx i
    rw [Ring.intCast_one, Semiring.one_mul, Semiring.mul_one, Semiring.add_zero]
  | .zero => rfl
  | .one => by
    show (Int.cast (1 : Int) : R) * 1 + 0 = 1
    rw [Ring.intCast_one, Semiring.one_mul, Semiring.add_zero]
  | .add a b => by
    show polyD ctx (addP (norm a) (norm b)) = _
    rw [polyD_addP, denote_norm ctx a, denote_norm ctx b]; rfl
  | .sub a b => by
    show polyD ctx (addP (norm a) (negP (norm b))) = a.denote ctx - b.denote ctx
    rw [polyD_addP, polyD_negP, denote_norm ctx a, denote_norm ctx b, Ring.sub_eq_add_neg]
  | .mul a b => by
    show polyD ctx (mulP (norm a) (norm b)) = _
    rw [polyD_mulP, denote_norm ctx a, denote_norm ctx b]; rfl
  | .neg a => by
    show polyD ctx (negP (norm a)) = _
    rw [polyD_negP, denote_norm ctx a]; rfl

theorem eq_of_norm (ctx : List R) (a b : RExpr) (h : norm a = norm b) : a.denote ctx = b.denote ctx := by
  rw [← denote_norm ctx a, ← denote_norm ctx b, h]

/-- a − b = 0 ⇒ a = b. -/
theorem eq_of_sub_eq_zero {a b : R} (h : a - b = 0) : a = b := by
  calc a = (a - b) + b := by rw [Ring.sub_eq_add_neg, Semiring.add_assoc, Ring.neg_add_cancel, Semiring.add_zero]
    _ = b := by rw [h, zero_add']

/-- a = b ⇒ a − b = 0. -/
theorem sub_eq_zero_of_eq {a b : R} (h : a = b) : a - b = 0 := by
  rw [h, Ring.sub_eq_add_neg, add_neg_cancel']

/-- The linear-combination step: if a − b equals c, and c vanishes, then a = b. -/
theorem lin_comb {a b c : R} (h : a - b = c) (hc : c = 0) : a = b := eq_of_sub_eq_zero (h.trans hc)

/-- Accumulating a linear combination of hypotheses: unification reads l and r off `h`, so the
combination `c` in `lin_comb` is built from the hypotheses' own statements. -/
theorem lc_add {c l r : R} (hc : c = 0) (k : R) (h : l = r) : c + k * (l - r) = 0 := by
  rw [hc, sub_eq_zero_of_eq h, Semiring.mul_zero, Semiring.add_zero]

theorem lc_zero : (0 : R) = 0 := rfl

end denote

open Lean Meta Elab Tactic in
/-- Reify a ring expression, collecting atoms (compared syntactically after instantiating
metavariables). -/
partial def reify (atoms : IO.Ref (Array Expr)) (e : Expr) : MetaM Expr := do
  let e ← instantiateMVars e
  let atom : MetaM Expr := do
    let as ← atoms.get
    match as.findIdx? (· == e) with
    | some i => return mkApp (mkConst ``RExpr.atom) (mkNatLit i)
    | none => atoms.set (as.push e); return mkApp (mkConst ``RExpr.atom) (mkNatLit as.size)
  match e.getAppFnArgs with
  | (``HAdd.hAdd, #[_, _, _, _, a, b]) => return mkApp2 (mkConst ``RExpr.add) (← reify atoms a) (← reify atoms b)
  | (``HSub.hSub, #[_, _, _, _, a, b]) => return mkApp2 (mkConst ``RExpr.sub) (← reify atoms a) (← reify atoms b)
  | (``HMul.hMul, #[_, _, _, _, a, b]) => return mkApp2 (mkConst ``RExpr.mul) (← reify atoms a) (← reify atoms b)
  | (``Neg.neg, #[_, _, a]) => return mkApp (mkConst ``RExpr.neg) (← reify atoms a)
  | (``OfNat.ofNat, #[_, n, _]) =>
    match n.rawNatLit? with
    | some 0 => return mkConst ``RExpr.zero
    | some 1 => return mkConst ``RExpr.one
    | _ => atom
  | _ => atom

open Lean Meta Elab Tactic in
/-- Turn a goal `lhs = rhs` over a `Lean.Grind.CommRing` into `norm e₁ = norm e₂`. -/
elab "ring_reify" : tactic => withMainContext do
  let goal ← getMainGoal
  let ty ← whnfR (← instantiateMVars (← goal.getType))
  let some (α, lhs, rhs) := ty.cleanupAnnotations.eq? | throwError m!"ring_reify: the goal is not an equality: {ty}"
  let atoms ← IO.mkRef #[]
  let el ← reify atoms lhs
  let er ← reify atoms rhs
  let ctx ← mkListLit α (← atoms.get).toList
  let thm ← mkAppM ``eq_of_norm #[ctx, el, er]
  let gs ← goal.apply thm
  replaceMainGoal gs

/-- Close an identity of commutative rings by normal forms evaluated in the kernel. -/
macro "ring_eq" : tactic => `(tactic| (ring_reify; decide +kernel))

end Oracles.RingNorm
