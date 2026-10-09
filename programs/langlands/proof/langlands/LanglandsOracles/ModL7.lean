import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL7

/-!
# ρ̄₇ for the Cremona curves of prime level: the mod-7 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq7 : ∀ a b c d : Fin 7, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts7 : NegFacts 7 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff7 : FieldFacts 7 := FieldFacts.of traceSq7 negFacts7 (by decide +kernel)
theorem S7_generates : S_generates 7 mod7Cert.zeta mod7Cert.S = true := by decide +kernel
theorem pair7_0 : pairOk 7 mod7Cert.S mod7Pair0 = true := by decide +kernel
theorem pair7_1 : pairOk 7 mod7Cert.S mod7Pair1 = true := by decide +kernel
theorem pair7_2 : pairOk 7 mod7Cert.S mod7Pair2 = true := by decide +kernel
theorem pair7_3 : pairOk 7 mod7Cert.S mod7Pair3 = true := by decide +kernel
theorem pairs7_ok : mod7Cert.pairs.all (pairOk 7 mod7Cert.S) = true := by
  show mod7Pairs.all _ = true
  unfold mod7Pairs
  simp only [List.all_cons, List.all_nil, pair7_0, pair7_1, pair7_2, pair7_3, Bool.true_and]
theorem curves7_ok : mod7Cert.curves.all (curveOk 7 mod7Cert) = true := by decide +kernel
theorem mod7_curve_labels : mod7Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₇ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod7_images_full {c : CurveCert} (hc : c ∈ mod7Cert.curves)
    (H : List (Mat2 7)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 7} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 7 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 7 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 7, z ∈ H :=
  data_sound ff7 mod7Cert S7_generates pairs7_ok curves7_ok hc H hmul hg hh hA hB

end Oracles
