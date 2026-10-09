import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL29

/-!
# ρ̄₂₉ for the Cremona curves of prime level: the mod-29 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq29 : ∀ a b c d : Fin 29, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts29 : NegFacts 29 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff29 : FieldFacts 29 := FieldFacts.of traceSq29 negFacts29 (by decide +kernel)
theorem S29_generates : S_generates 29 mod29Cert.zeta mod29Cert.S = true := by decide +kernel
set_option maxHeartbeats 0 in
set_option maxHeartbeats 0 in
theorem pair29_0 : pairOk 29 mod29Cert.S mod29Pair0 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair29_1 : pairOk 29 mod29Cert.S mod29Pair1 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair29_2 : pairOk 29 mod29Cert.S mod29Pair2 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair29_3 : pairOk 29 mod29Cert.S mod29Pair3 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair29_4 : pairOk 29 mod29Cert.S mod29Pair4 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair29_5 : pairOk 29 mod29Cert.S mod29Pair5 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair29_6 : pairOk 29 mod29Cert.S mod29Pair6 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair29_7 : pairOk 29 mod29Cert.S mod29Pair7 = true := by decide +kernel
theorem pairs29_ok : mod29Cert.pairs.all (pairOk 29 mod29Cert.S) = true := by
  show mod29Pairs.all _ = true
  unfold mod29Pairs
  simp only [List.all_cons, List.all_nil, pair29_0, pair29_1, pair29_2, pair29_3, pair29_4, pair29_5, pair29_6, pair29_7, Bool.true_and]
set_option maxHeartbeats 0 in
theorem curves29_ok : mod29Cert.curves.all (curveOk 29 mod29Cert) = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem mod29_curve_labels : mod29Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₂₉ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod29_images_full {c : CurveCert} (hc : c ∈ mod29Cert.curves)
    (H : List (Mat2 29)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 29} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 29 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 29 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 29, z ∈ H :=
  data_sound ff29 mod29Cert S29_generates pairs29_ok curves29_ok hc H hmul hg hh hA hB

end Oracles
