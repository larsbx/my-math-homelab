import LanglandsOracles.Pseudocharacter

/-!
# Generation certificates in GL₂(ℤ/n): breadth-first multiplicative closure on machine naturals.

Matrices over ℤ/n are encoded as base-n indices i < n⁴, closures keep the set of seen elements as
a bitmask and the frontier as a list of codes, and every step is a GMP operation in the kernel.  `generatedIdx_sub` proves soundness:
each index whose bit is set decodes to a product of the generators, so a kernel evaluation
"`generatedIdx gens` has every bit of GL₂ set" certifies that any multiplicatively closed subset
containing the generators is all of GL₂(ℤ/n).  `mem_gl`: the enumeration `gl n` is complete.
-/
namespace Oracles

namespace Mat2

/-- Elements enumerated by `gl n` are exactly the matrices with nonzero determinant. -/
theorem mem_fins {n : Nat} (a : Fin n) : a ∈ fins n := by
  unfold fins
  rw [List.mem_filterMap]
  exact ⟨a.val, List.mem_range.mpr a.isLt, by simp [a.isLt]⟩

theorem mem_all {n : Nat} (x : Mat2 n) : x ∈ all n := by
  unfold all
  simp only [List.mem_flatMap, List.mem_map]
  exact ⟨x.a, mem_fins _, x.b, mem_fins _, x.c, mem_fins _, x.d, mem_fins _, rfl⟩

theorem mem_gl {n : Nat} (x : Mat2 n) (hx : x.det.val ≠ 0) : x ∈ gl n := by
  unfold gl
  rw [List.mem_filter]
  exact ⟨mem_all x, bne_iff_ne.mpr hx⟩

variable {n : Nat} [NeZero n]

/-- Matrices as indices 0 ≤ i < n⁴ (base n), so that closures run on machine naturals in the kernel. -/
def finN (k : Nat) : Fin n := ⟨k % n, Nat.mod_lt k (Nat.pos_of_neZero n)⟩
def encode (x : Mat2 n) : Nat := x.a.val + n * (x.b.val + n * (x.c.val + n * x.d.val))
def decode (n : Nat) [NeZero n] (i : Nat) : Mat2 n := ⟨finN i, finN (i / n), finN (i / n / n), finN (i / n / n / n)⟩
def mulIdx (n : Nat) [NeZero n] (i j : Nat) : Nat := encode (M2.mul (decode n i) (decode n j))

theorem decode_encode (x : Mat2 n) : decode n (encode x) = x := by
  obtain ⟨⟨a, ha⟩, ⟨b, hb⟩, ⟨c, hc⟩, ⟨d, hd⟩⟩ := x
  have h1 : ∀ u k : Nat, u < n → (u + n * k) % n = u := fun u k hu => by
    rw [Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt hu]
  have h2 : ∀ u k : Nat, u < n → (u + n * k) / n = k := fun u k hu => by
    rw [Nat.add_mul_div_left _ _ (Nat.pos_of_neZero n), Nat.div_eq_of_lt hu, Nat.zero_add]
  simp only [decode, encode, finN, M2.mk.injEq, Fin.mk.injEq]
  rw [h1 a _ ha, h2 a _ ha, h1 b _ hb, h2 b _ hb, h1 c _ hc, h2 c _ hc, Nat.mod_eq_of_lt hd]
  exact ⟨rfl, rfl, rfl, rfl⟩

omit [NeZero n] in
theorem encode_lt (x : Mat2 n) : encode x < n ^ 4 := by
  obtain ⟨⟨a, ha⟩, ⟨b, hb⟩, ⟨c, hc⟩, ⟨d, hd⟩⟩ := x
  have step : ∀ u k m : Nat, u < n → k < m → u + n * k < n * m := fun u k m hu hk =>
    calc u + n * k < n + n * k := Nat.add_lt_add_right hu _
      _ = n * (k + 1) := by rw [Nat.mul_succ, Nat.add_comm]
      _ ≤ n * m := Nat.mul_le_mul_left n hk
  have e : n ^ 4 = n * (n * (n * n)) := by
    show (((1 * n) * n) * n) * n = n * (n * (n * n))
    rw [Nat.one_mul]
    ac_rfl
  show a + n * (b + n * (c + n * d)) < n ^ 4
  rw [e]
  exact step a _ _ ha (step b _ _ hb (step c d n hc hd))

theorem encode_inj {g h : Mat2 n} (e : encode g = encode h) : g = h := by
  have := congrArg (decode n) e
  rwa [decode_encode, decode_encode] at this

/-- Bitmask of a list of indices. -/
def mask (m : Nat) (l : List Nat) : Nat := l.foldl (fun m j => m ||| 2 ^ j) m

theorem testBit_mask {m : Nat} {l : List Nat} {i : Nat} (h : (mask m l).testBit i = true) :
    m.testBit i = true ∨ i ∈ l := by
  induction l generalizing m with
  | nil => exact Or.inl h
  | cons j l ih =>
    rcases ih h with h' | h'
    · rw [Nat.testBit_or] at h'
      rcases Bool.or_eq_true _ _ |>.mp h' with h'' | h''
      · exact Or.inl h''
      · rw [Nat.testBit_two_pow] at h''
        exact Or.inr (List.mem_cons.mpr (Or.inl (of_decide_eq_true h'').symm))
    · exact Or.inr (List.mem_cons_of_mem _ h')

/-- One bit of a machine natural through accelerated operations only: `Nat.testBit` unfolds a chain of
instances at every call, and the kernel caches every link. -/
def bit (m i : Nat) : Bool := Nat.beq (Nat.mod (Nat.shiftRight m i) 2) 1

theorem bit_eq (m i : Nat) : bit m i = m.testBit i := by
  rw [Nat.testBit_eq_decide_div_mod_eq]
  show Nat.beq (m >>> i % 2) 1 = _
  rw [Nat.shiftRight_eq_div_pow]
  cases h : Nat.beq (m / 2 ^ i % 2) 1
  · exact (decide_eq_false (Nat.ne_of_beq_eq_false h)).symm
  · exact (decide_eq_true (Nat.eq_of_beq_eq_true h)).symm

/-- The products of one frontier code with the generators: each unseen product is marked in `seen` and
listed.  Every intermediate mask is forced to a literal by a cheap GMP test, so no chain of unevaluated
operations is ever carried (that chain is what hits the kernel's recursion limit). -/
def addList (x : Nat) : List (Nat → Nat) → Nat → List Nat → Nat × List Nat
  | [], seen, new => (seen, new)
  | f :: fs, seen, new =>
    let j := f x
    if bit seen j then addList x fs seen new
    else
      let s := Nat.lor seen (Nat.pow 2 j)
      if Nat.beq (Nat.mod s 2) 2 then addList x fs 0 [] else addList x fs s (j :: new)

/-- One breadth-first layer: the frontier's products with the generators (given as maps on codes:
right multiplication by each generator, specialised when the generator is known). -/
def growList (gens : List (Nat → Nat)) : List Nat → Nat → List Nat → Nat × List Nat
  | [], seen, new => (seen, new)
  | x :: xs, seen, new =>
    match addList x gens seen new with
    | (s, n) => growList gens xs s n

/-- Breadth-first multiplicative closure: the seen set as a bitmask, the frontier as a list of codes, with
fuel.  Nothing scans the code range, so the cost is one product per (element, generator). -/
def closureList (gens : List (Nat → Nat)) : Nat → Nat → List Nat → Nat
  | 0, seen, _ => seen
  | _ + 1, seen, [] => seen
  | k + 1, seen, x :: xs =>
    match growList gens (x :: xs) seen [] with
    | (s, n) => closureList gens k s n

/-- The semigroup generated by a list of encoded matrices (its closure under multiplication; in a
finite group, the subgroup). -/
def generatedIdx (n : Nat) [NeZero n] (gens : List Nat) : Nat :=
  closureList (gens.map fun g x => mulIdx n x g) (n ^ 4) (mask 0 gens) gens

section soundness

variable (H : List (Mat2 n)) (gens : List (Nat → Nat))
-- each generator map sends the code of an element of H to the code of an element of H
variable (hm : ∀ x ∈ H, ∀ f ∈ gens, ∃ y ∈ H, f (encode x) = encode y)
include hm

/-- Every index produced is the code of an element of H: the invariant of the closure. -/
def Codes (H : List (Mat2 n)) (i : Nat) : Prop := ∃ x ∈ H, i = encode x

/-- The invariant on a (seen mask, frontier list) pair. -/
def Inv (H : List (Mat2 n)) (p : Nat × List Nat) : Prop :=
  (∀ i, p.1.testBit i = true → Codes H i) ∧ ∀ i ∈ p.2, Codes H i

omit [NeZero n] hm in
theorem inv_zero_nil : Inv H (0, []) :=
  ⟨fun i h => by rw [Nat.zero_testBit] at h; exact absurd h Bool.false_ne_true, fun _ h => absurd h List.not_mem_nil⟩

omit [NeZero n] in
theorem addList_inv (x : Nat) (hx : Codes H x) :
    ∀ (fs : List (Nat → Nat)), (∀ f ∈ fs, f ∈ gens) → ∀ (seen : Nat) (new : List Nat), Inv H (seen, new) →
      Inv H (addList x fs seen new)
  | [], _, _, _, h => h
  | f :: fs, hfs, seen, new, ⟨hs, hn⟩ => by
    have hf : f ∈ gens := hfs f (List.mem_cons_self ..)
    have hfs' : ∀ f' ∈ fs, f' ∈ gens := fun f' h => hfs f' (List.mem_cons_of_mem _ h)
    have hj : Codes H (f x) := by
      obtain ⟨y, hy, rfl⟩ := hx
      obtain ⟨z, hz, e⟩ := hm y hy f hf
      exact ⟨z, hz, e⟩
    unfold addList
    dsimp only
    split
    · exact addList_inv x hx fs hfs' seen new ⟨hs, hn⟩
    · split
      · exact addList_inv x hx fs hfs' 0 [] (inv_zero_nil H)
      · refine addList_inv x hx fs hfs' _ _ ⟨fun i hi => ?_, fun i hi => ?_⟩
        · have hi' : (seen ||| 2 ^ (f x)).testBit i = true := hi
          rw [Nat.testBit_or, Nat.testBit_two_pow] at hi'
          rcases Bool.or_eq_true _ _ |>.mp hi' with h | h
          · exact hs i h
          · exact (of_decide_eq_true h) ▸ hj
        · rcases List.mem_cons.mp hi with rfl | hi
          · exact hj
          · exact hn i hi

omit [NeZero n] in
theorem growList_inv : ∀ (fr : List Nat), (∀ x ∈ fr, Codes H x) → ∀ (seen : Nat) (new : List Nat),
    Inv H (seen, new) → Inv H (growList gens fr seen new)
  | [], _, _, _, h => h
  | x :: xs, hfr, seen, new, h => by
    have hx : Codes H x := hfr x (List.mem_cons_self ..)
    have hxs : ∀ y ∈ xs, Codes H y := fun y hy => hfr y (List.mem_cons_of_mem _ hy)
    unfold growList
    split
    · next s n heq => exact growList_inv xs hxs s n (heq ▸ addList_inv H gens hm x hx gens (fun _ h => h) seen new h)

omit [NeZero n] in
theorem closureList_sub : ∀ (k seen : Nat) (frontier : List Nat), (∀ i, seen.testBit i = true → Codes H i) →
    (∀ x ∈ frontier, Codes H x) → ∀ i, (closureList gens k seen frontier).testBit i = true → Codes H i
  | 0, _, _, hs, _ => hs
  | _ + 1, _, [], hs, _ => hs
  | k + 1, seen, x :: xs, hs, hf => by
    unfold closureList
    split
    · next s n heq =>
      have hinv : Inv H (s, n) := heq ▸ growList_inv H gens hm (x :: xs) hf seen [] ⟨hs, fun _ h => absurd h List.not_mem_nil⟩
      exact closureList_sub k s n hinv.1 hinv.2

/-- Starting from codes of elements of H, every bit set by the closure is the code of an element of H. -/
theorem closureList_mem (init : List Nat) (hinit : ∀ i ∈ init, Codes H i) (k : Nat) :
    ∀ x : Mat2 n, (closureList gens k (mask 0 init) init).testBit (encode x) = true → x ∈ H := by
  intro x hx
  have hmask : ∀ i, (mask 0 init).testBit i = true → Codes H i := fun i hi =>
    (testBit_mask hi).elim (fun h => by rw [Nat.zero_testBit] at h; exact absurd h Bool.false_ne_true) (hinit i)
  obtain ⟨y, hy, e⟩ := closureList_sub H gens hm k _ _ hmask hinit _ hx
  rw [encode_inj e]
  exact hy

end soundness

/-- `generatedIdx` for generators given by codes, through `mulIdx`. -/
theorem generatedIdx_mem (H : List (Mat2 n)) (gens : List Nat) (hinit : ∀ i ∈ gens, Codes H i)
    (hm : ∀ y ∈ H, ∀ i ∈ gens, ∃ z ∈ H, mulIdx n (encode y) i = encode z) :
    ∀ x : Mat2 n, (generatedIdx n gens).testBit (encode x) = true → x ∈ H := by
  refine closureList_mem H _ ?_ gens hinit (n ^ 4)
  intro y hy f hf
  obtain ⟨i, hi, rfl⟩ := List.mem_map.mp hf
  exact hm y hy i hi

/-- The generic generation certificate: if every (P, Q)-pair generates GL₂(ℤ/n) (a kernel fact
`hpairs`, closures through `mulIdx`), then any multiplicatively closed subset containing a P-element
and a Q-element is all of GL₂(ℤ/n). -/
theorem generated_of_pairs (n : Nat) [NeZero n] (P Q : Mat2 n → Bool)
    (hP : ∀ g, P g = true → g ∈ gl n) (hQ : ∀ h, Q h = true → h ∈ gl n)
    (hpairs : ((gl n).filter P).all (fun g => ((gl n).filter Q).all fun h =>
      (gl n).all fun x => (generatedIdx n [encode g, encode h]).testBit (encode x)) = true)
    (H : List (Mat2 n)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H)
    {g h : Mat2 n} (hg : g ∈ H) (hh : h ∈ H) (hPg : P g = true) (hQh : Q h = true) :
    ∀ x ∈ gl n, x ∈ H := by
  intro x hx
  have hg' : g ∈ (gl n).filter P := List.mem_filter.mpr ⟨hP g hPg, hPg⟩
  have hh' : h ∈ (gl n).filter Q := List.mem_filter.mpr ⟨hQ h hQh, hQh⟩
  have hx' := List.all_eq_true.mp (List.all_eq_true.mp (List.all_eq_true.mp hpairs g hg') h hh') x hx
  have hgens : ∀ i ∈ [encode g, encode h], Codes H i := by
    intro i hi
    rcases List.mem_cons.mp hi with rfl | hi
    · exact ⟨g, hg, rfl⟩
    rcases List.mem_cons.mp hi with rfl | hi
    · exact ⟨h, hh, rfl⟩
    exact absurd hi List.not_mem_nil
  have hm : ∀ y ∈ H, ∀ i ∈ [encode g, encode h], ∃ z ∈ H, mulIdx n (encode y) i = encode z := by
    intro y hy i hi
    obtain ⟨w, hw, rfl⟩ := hgens i hi
    exact ⟨M2.mul y w, hmul y hy w hw, by simp only [mulIdx, decode_encode]⟩
  exact generatedIdx_mem H _ hgens hm x hx'

end Mat2

end Oracles
