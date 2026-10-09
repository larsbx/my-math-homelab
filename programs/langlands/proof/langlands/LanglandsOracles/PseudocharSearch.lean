import LanglandsOracles.ImageMod3
import LanglandsOracles.ExcursionInstance

/-!
# Pseudocharacter ⇒ representation, for the finite group GL₂(𝔽₃) = Gal(ℚ(37a1[3])/ℚ), by search.

Taylor's theorem (p > 2): a 2-dimensional pseudocharacter T : Γ → 𝔽_p is the trace of a semisimple
representation.  For finite Γ it is a finite search, run here in the kernel: det is determined by T
(det g = (T(g)² − T(g²))/2), the images of the generating pair (g₀, h₀) = (ρ̄₃(Frob₅), ρ̄₃(Frob₇))
(they generate GL₂(𝔽₃): `pairs_generate`) range over the matrices with the prescribed (trace, det),
a candidate is extended along breadth-first words, and it is a representation iff the generator
relations ρ(x g) = ρ(x) ρ(g) hold on all of Γ.  `searchRep` performs the search; `rep_certified`
then checks the multiplicativity of the found table on all 48² pairs and its trace on all 48
elements, so the certificate does not rely on the search's own reasoning.

Instance: T'(g) = det(g)·tr(g), the pseudocharacter of ρ̄₃ ⊗ χ_cyc, which on Frobenius elements
reads p·a_p mod 3 (`Tprime_frobenius`).  PROVED (`Tprime_procesi`): T' satisfies the Procesi
identity, because g ↦ det(g)·g is a homomorphism (kernel on 48² pairs) and `M2.procesi` holds for
its values.  Negative control: T(g) = tr(g) + det(g) − 1 has T(1) = 2 and is central but is not a
pseudocharacter (tr ρ̄ ⊕ (det − 1) is not the character of a genuine 2-dimensional representation),
and the search finds nothing (`bad_not_realised`).
-/
namespace Oracles

namespace Mat2

/-- Twisting by the determinant: g ↦ det(g)·g. -/
def twist (g : Mat2 3) : Mat2 3 := ⟨g.det * g.a, g.det * g.b, g.det * g.c, g.det * g.d⟩

/-- T'(g) = det(g)·tr(g) = tr(twist g). -/
def Tprime (g : Mat2 3) : Fin 3 := g.det * g.trace

theorem Tprime_eq_trace_twist (g : Mat2 3) : Tprime g = M2.trace (twist g) := by
  have hd : ∀ a b : Fin 3, ∀ d, d * (a + b) = d * a + d * b := by decide
  simp only [Tprime, twist, M2.trace, hd]

/-- GL₂(𝔽₃) as indices; all kernel loops run over it. -/
def glIdx : List Nat := (gl 3).map encode

def twistIdx (i : Nat) : Nat := encode (twist (decode 3 i))

theorem mem_glIdx {g : Mat2 3} (hg : g ∈ gl 3) : encode g ∈ glIdx := List.mem_map.mpr ⟨g, hg, rfl⟩

theorem twist_hom_all :
    glIdx.all (fun i => glIdx.all fun j => twistIdx (mulIdx 3 i j) == mulIdx 3 (twistIdx i) (twistIdx j)) = true := by
  decide +kernel

theorem mulDet_all : glIdx.all (fun i => glIdx.all fun j => (det (decode 3 (mulIdx 3 i j))).val != 0) = true := by
  decide +kernel

theorem twist_hom {g h : Mat2 3} (hg : g ∈ gl 3) (hh : h ∈ gl 3) : twist (M2.mul g h) = M2.mul (twist g) (twist h) := by
  have e := beq_iff_eq.mp (List.all_eq_true.mp (List.all_eq_true.mp twist_hom_all _ (mem_glIdx hg)) _ (mem_glIdx hh))
  simp only [twistIdx, mulIdx, decode_encode] at e
  exact encode_inj e

theorem mulMem {g h : Mat2 3} (hg : g ∈ gl 3) (hh : h ∈ gl 3) : M2.mul g h ∈ gl 3 := by
  have e := bne_iff_ne.mp (List.all_eq_true.mp (List.all_eq_true.mp mulDet_all _ (mem_glIdx hg)) _ (mem_glIdx hh))
  simp only [mulIdx, decode_encode] at e
  exact mem_gl _ e

/-- T' is a pseudocharacter: the Procesi identity on GL₂(𝔽₃). -/
theorem Tprime_procesi {x y z : Mat2 3} (hx : x ∈ gl 3) (hy : y ∈ gl 3) (hz : z ∈ gl 3) :
    Tprime x * Tprime y * Tprime z + Tprime (M2.mul (M2.mul x y) z) + Tprime (M2.mul (M2.mul x z) y)
      = Tprime (M2.mul x y) * Tprime z + Tprime (M2.mul x z) * Tprime y + Tprime (M2.mul y z) * Tprime x := by
  simp only [Tprime_eq_trace_twist, twist_hom hx hy, twist_hom hx hz, twist_hom hy hz,
    twist_hom (mulMem hx hy) hz, twist_hom (mulMem hx hz) hy]
  exact M2.procesi (isCSR_fin 3) _ _ _

/-- On Frobenius elements, T' reads p·a_p mod 3: the trace of ρ̄₃ ⊗ χ_cyc. -/
theorem Tprime_frobenius :
    galoisMod3Data.all (fun pm =>
      ((Tprime ((frobMat3 pm.1).getD M2.one)).val : Int) == (((pm.1 : Int) * ap pm.1) % 3 + 3) % 3) = true := by
  decide +kernel

/-- The negative control: tr + det − 1. -/
def Tbad (g : Mat2 3) : Fin 3 := g.trace + g.det + 2

theorem Tbad_one : Tbad M2.one = 2 := by decide
theorem Tbad_central : (gl 3).all (fun g => (gl 3).all fun h => Tbad (M2.mul g h) == Tbad (M2.mul h g)) = true := by
  decide +kernel

-- ---------------------------------------------------------------- the search --

/-- det g = (T(g)² − T(g²))/2, with 1/2 = 2 in 𝔽₃. -/
def detOf (T : Mat2 3 → Fin 3) (g : Mat2 3) : Fin 3 := (T g * T g - T (M2.mul g g)) * 2

def candidates (T : Mat2 3 → Fin 3) (g : Mat2 3) : List Nat :=
  ((gl 3).filter fun m => m.trace == T g && m.det == detOf T g).map encode

/-- A partial map on indices as one natural: digit i in base 128 is ρ(i) + 1, and 0 means undefined. -/
def tget (tbl i : Nat) : Nat := tbl / 128 ^ i % 128
def tset (tbl i v : Nat) : Nat := tbl + (v + 1) * 128 ^ i

/-- Extend a generator assignment along breadth-first words (fuel 48). -/
def extend (gens : List (Nat × Nat)) : Nat → Nat → List Nat → Nat
  | 0, tbl, _ => tbl
  | _ + 1, tbl, [] => tbl
  | k + 1, tbl, frontier =>
    let acc := frontier.foldl (fun (acc : Nat × List Nat) x =>
      gens.foldl (fun (acc : Nat × List Nat) gi =>
        let y := mulIdx 3 x gi.1
        if tget acc.1 y != 0 then acc
        else (tset acc.1 y (mulIdx 3 (tget acc.1 x - 1) gi.2), y :: acc.2)) acc) (tbl, [])
    extend gens k acc.1 acc.2

/-- The generator relations ρ(x g) = ρ(x) ρ(g) on all of GL₂(𝔽₃), and tr ρ = T. -/
def relationsHold (T : Mat2 3 → Fin 3) (gens : List (Nat × Nat)) (tbl : Nat) : Bool :=
  glIdx.all fun i =>
    let d := tget tbl i
    d != 0 && M2.trace (decode 3 (d - 1)) == T (decode 3 i)
      && gens.all fun gi => tget tbl (mulIdx 3 i gi.1) == mulIdx 3 (d - 1) gi.2 + 1

def one3 : Nat := encode (M2.one : Mat2 3)

def searchRep (T : Mat2 3 → Fin 3) (g₀ h₀ : Mat2 3) : Option Nat :=
  (candidates T g₀).findSome? fun A => (candidates T h₀).findSome? fun B =>
    let gens := [(encode g₀, A), (encode h₀, B)]
    let tbl := extend gens 48 (tset 0 one3 one3) [one3]
    if relationsHold T gens tbl then some tbl else none

/-- Independent certificate: multiplicativity on all 48² pairs and the trace on all 48 elements. -/
def certified (T : Mat2 3 → Fin 3) (tbl : Nat) : Bool :=
  glIdx.all (fun i => glIdx.all fun j =>
    tget tbl i != 0 && tget tbl j != 0 && tget tbl (mulIdx 3 i j) == mulIdx 3 (tget tbl i - 1) (tget tbl j - 1) + 1) &&
  glIdx.all fun i => tget tbl i != 0 && M2.trace (decode 3 (tget tbl i - 1)) == T (decode 3 i)

def g₀ : Mat2 3 := (frobMat3 5).getD M2.one
def h₀ : Mat2 3 := (frobMat3 7).getD M2.one

/-- **Lean finds the representation with trace T' and certifies it.** -/
theorem rep_certified :
    (match searchRep Tprime g₀ h₀ with | some tbl => certified Tprime tbl | none => false) = true := by
  decide +kernel

/-- Also for T = tr itself (the search recovers ρ̄₃ up to conjugacy). -/
theorem trace_rep_certified :
    (match searchRep M2.trace g₀ h₀ with | some tbl => certified M2.trace tbl | none => false) = true := by
  decide +kernel

/-- The negative control is not realised: the exhaustive search over generator images finds nothing. -/
theorem bad_not_realised : searchRep Tbad g₀ h₀ = none := by decide +kernel

-- ------------------------------------------------------------- uniqueness --

/-- Every candidate assignment that extends to a representation with trace T. -/
def searchAll (T : Mat2 3 → Fin 3) (g₀ h₀ : Mat2 3) : List Nat :=
  (candidates T g₀).flatMap fun A => (candidates T h₀).filterMap fun B =>
    let gens := [(encode g₀, A), (encode h₀, B)]
    let tbl := extend gens 48 (tset 0 one3 one3) [one3]
    if relationsHold T gens tbl then some tbl else none

/-- A conjugator c with c·ρ₁(g) = ρ₂(g)·c on the two generators, then verified on all 48 elements. -/
def conjugator (tbl₁ tbl₂ : Nat) (g₀ h₀ : Mat2 3) : Option Nat :=
  glIdx.find? fun c => [encode g₀, encode h₀].all fun i =>
    mulIdx 3 c (tget tbl₁ i - 1) == mulIdx 3 (tget tbl₂ i - 1) c

def conjugateAll (tbl₁ tbl₂ : Nat) (g₀ h₀ : Mat2 3) : Bool :=
  match conjugator tbl₁ tbl₂ g₀ h₀ with
  | some c => glIdx.all fun i => mulIdx 3 c (tget tbl₁ i - 1) == mulIdx 3 (tget tbl₂ i - 1) c
  | none => false

def solsTprime : List Nat := searchAll Tprime g₀ h₀
def solsTrace : List Nat := searchAll M2.trace g₀ h₀

/-- **Uniqueness up to conjugacy** (the other half of Taylor's statement, for this instance): the search
finds exactly 24 = |GL₂(𝔽₃)|/|centre| representations with trace T′, all conjugate to the first
(which `rep_certified` certifies; conjugates of a homomorphism are homomorphisms). -/
theorem rep_unique :
    (solsTprime.length == 24 && solsTprime.all fun t => conjugateAll (solsTprime.headD 0) t g₀ h₀) = true := by
  decide +kernel

theorem trace_rep_unique :
    (solsTrace.length == 24 && solsTrace.all fun t => conjugateAll (solsTrace.headD 0) t g₀ h₀) = true := by
  decide +kernel

end Mat2

end Oracles
