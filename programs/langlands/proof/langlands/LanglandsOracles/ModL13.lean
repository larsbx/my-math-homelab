import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL13

/-!
# ρ̄₁₃ for the Cremona curves of prime level: the mod-13 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq13 : ∀ a b c d : Fin 13, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts13 : NegFacts 13 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff13 : FieldFacts 13 := FieldFacts.of traceSq13 negFacts13 (by decide +kernel)
theorem S13_generates : S_generates 13 mod13Cert.zeta mod13Cert.S = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_0 : pairOk 13 mod13Cert.S mod13Pair0 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_1 : pairOk 13 mod13Cert.S mod13Pair1 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_2 : pairOk 13 mod13Cert.S mod13Pair2 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_3 : pairOk 13 mod13Cert.S mod13Pair3 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_4 : pairOk 13 mod13Cert.S mod13Pair4 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_5 : pairOk 13 mod13Cert.S mod13Pair5 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_6 : pairOk 13 mod13Cert.S mod13Pair6 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair13_7 : pairOk 13 mod13Cert.S mod13Pair7 = true := by decide +kernel
theorem pairs13_ok : mod13Cert.pairs.all (pairOk 13 mod13Cert.S) = true := by
  show mod13Pairs.all _ = true
  unfold mod13Pairs
  simp only [List.all_cons, List.all_nil, pair13_0, pair13_1, pair13_2, pair13_3, pair13_4, pair13_5, pair13_6, pair13_7, Bool.true_and]
set_option maxHeartbeats 0 in
theorem curves13_ok : mod13Cert.curves.all (curveOk 13 mod13Cert) = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem mod13_curve_labels : mod13Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₁₃ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod13_images_full {c : CurveCert} (hc : c ∈ mod13Cert.curves)
    (H : List (Mat2 13)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 13} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 13 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 13 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 13, z ∈ H :=
  data_sound ff13 mod13Cert S13_generates pairs13_ok curves13_ok hc H hmul hg hh hA hB

end Oracles
