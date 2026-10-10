import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL23

/-!
# ρ̄₂₃ for the Cremona curves of prime level: the mod-23 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq23 : ∀ a b c d : Fin 23, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts23 : NegFacts 23 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff23 : FieldFacts 23 := FieldFacts.of traceSq23 negFacts23 (by decide +kernel)
theorem S23_generates : S_generates 23 mod23Cert.zeta mod23Cert.S = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_0 : pairOk 23 mod23Cert.S mod23Pair0 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_1 : pairOk 23 mod23Cert.S mod23Pair1 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_2 : pairOk 23 mod23Cert.S mod23Pair2 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_3 : pairOk 23 mod23Cert.S mod23Pair3 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_4 : pairOk 23 mod23Cert.S mod23Pair4 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_5 : pairOk 23 mod23Cert.S mod23Pair5 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_6 : pairOk 23 mod23Cert.S mod23Pair6 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_7 : pairOk 23 mod23Cert.S mod23Pair7 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_8 : pairOk 23 mod23Cert.S mod23Pair8 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair23_9 : pairOk 23 mod23Cert.S mod23Pair9 = true := by decide +kernel
theorem pairs23_ok : mod23Cert.pairs.all (pairOk 23 mod23Cert.S) = true := by
  show mod23Pairs.all _ = true
  unfold mod23Pairs
  simp only [List.all_cons, List.all_nil, pair23_0, pair23_1, pair23_2, pair23_3, pair23_4, pair23_5, pair23_6, pair23_7, pair23_8, pair23_9, Bool.true_and]
set_option maxHeartbeats 0 in
theorem curves23_ok : mod23Cert.curves.all (curveOk 23 mod23Cert) = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem mod23_curve_labels : mod23Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₂₃ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod23_images_full {c : CurveCert} (hc : c ∈ mod23Cert.curves)
    (H : List (Mat2 23)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 23} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 23 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 23 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 23, z ∈ H :=
  data_sound ff23 mod23Cert S23_generates pairs23_ok curves23_ok hc H hmul hg hh hA hB

end Oracles
