import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL19

/-!
# ρ̄₁₉ for the Cremona curves of prime level: the mod-19 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq19 : ∀ a b c d : Fin 19, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts19 : NegFacts 19 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff19 : FieldFacts 19 := FieldFacts.of traceSq19 negFacts19 (by decide +kernel)
theorem S19_generates : S_generates 19 mod19Cert.zeta mod19Cert.S = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_0 : pairOk 19 mod19Cert.S mod19Pair0 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_1 : pairOk 19 mod19Cert.S mod19Pair1 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_2 : pairOk 19 mod19Cert.S mod19Pair2 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_3 : pairOk 19 mod19Cert.S mod19Pair3 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_4 : pairOk 19 mod19Cert.S mod19Pair4 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_5 : pairOk 19 mod19Cert.S mod19Pair5 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_6 : pairOk 19 mod19Cert.S mod19Pair6 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_7 : pairOk 19 mod19Cert.S mod19Pair7 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair19_8 : pairOk 19 mod19Cert.S mod19Pair8 = true := by decide +kernel
theorem pairs19_ok : mod19Cert.pairs.all (pairOk 19 mod19Cert.S) = true := by
  show mod19Pairs.all _ = true
  unfold mod19Pairs
  simp only [List.all_cons, List.all_nil, pair19_0, pair19_1, pair19_2, pair19_3, pair19_4, pair19_5, pair19_6, pair19_7, pair19_8, Bool.true_and]
set_option maxHeartbeats 0 in
theorem curves19_ok : mod19Cert.curves.all (curveOk 19 mod19Cert) = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem mod19_curve_labels : mod19Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₁₉ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod19_images_full {c : CurveCert} (hc : c ∈ mod19Cert.curves)
    (H : List (Mat2 19)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 19} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 19 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 19 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 19, z ∈ H :=
  data_sound ff19 mod19Cert S19_generates pairs19_ok curves19_ok hc H hmul hg hh hA hB

end Oracles
