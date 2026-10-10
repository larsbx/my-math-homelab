import LanglandsOracles.TraceFormula
import LanglandsOracles.Matrix
import LanglandsOracles.Data

/-!
# Certificates on exported Brandt data (Python computes B(ell); Lean recomputes the class-number side).

For every (p, w, [(ell, B(ell))]) in `brandtData`:
  * row sums of B(ell) are ell + 1;
  * B(ell) B(ell') = B(ell') B(ell);
  * B(ell) · diag(w) is symmetric (dual isogeny);
  * 12 · tr B(n) = eichlerBrandt12 p n for n = 1, each ell, ell², and each product ell ell'
    (Hecke relations B(ell²) = B(ell)² − ell, B(ell ell') = B(ell) B(ell')).
-/
namespace Oracles

def lookup (ms : List (Nat × IMat)) (ell : Nat) : Option IMat :=
  (ms.find? (fun m => m.1 == ell)).map (·.2)

def heckeOf (ms : List (Nat × IMat)) (n : Nat) (size : Nat) : Option IMat :=
  if n == 1 then some (IMat.identity size) else
  match ms.find? (fun m => m.1 == n) with
  | some m => some m.2
  | none =>
    -- n = ell^2 or n = ell * ell' for ells present
    (ms.findSome? (fun m =>
      if n == m.1 * m.1 then some ((m.2.mul m.2).sub (IMat.scale m.1 (IMat.identity size)))
      else (ms.findSome? (fun m' => if m'.1 > m.1 && n == m.1 * m'.1 then some (m.2.mul m'.2) else none))))

def traceCertified (p : Nat) (ms : List (Nat × IMat)) (size : Nat) (n : Nat) : Bool :=
  match heckeOf ms n size with
  | some B => 12 * B.trace == eichlerBrandt12 p n
  | none => false

def brandtCertified (entry : Nat × List Nat × List (Nat × IMat)) : Bool :=
  let (p, w, ms) := entry
  let size := w.length
  let ells := ms.map (·.1)
  let ns := [1] ++ ells ++ ells.map (fun l => l * l) ++
    (ells.flatMap (fun l => ells.filterMap (fun l' => if l < l' then some (l * l') else none)))
  ms.all (fun m => m.2.rowSums.all (· == (m.1 : Int) + 1)) &&
  ms.all (fun m => ms.all (fun m' => m.2.mul m'.2 == m'.2.mul m.2)) &&
  ms.all (fun m => (m.2.scaleCols w) == (m.2.scaleCols w).transpose) &&
  ns.all (fun n => n % p != 0 → traceCertified p ms size n)

theorem brandt_certificates : brandtData.all brandtCertified = true := by decide +kernel

end Oracles
