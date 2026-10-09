import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL17

/-!
# ρ̄₁₇ for the Cremona curves of prime level: the mod-17 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq17 : ∀ a b c d : Fin 17, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts17 : NegFacts 17 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff17 : FieldFacts 17 := FieldFacts.of traceSq17 negFacts17 (by decide +kernel)
theorem S17_generates : S_generates 17 mod17Cert.zeta mod17Cert.S = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_0 : pairOk 17 mod17Cert.S mod17Pair0 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_1 : pairOk 17 mod17Cert.S mod17Pair1 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_2 : pairOk 17 mod17Cert.S mod17Pair2 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_3 : pairOk 17 mod17Cert.S mod17Pair3 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_4 : pairOk 17 mod17Cert.S mod17Pair4 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_5 : pairOk 17 mod17Cert.S mod17Pair5 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_6 : pairOk 17 mod17Cert.S mod17Pair6 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair17_7 : pairOk 17 mod17Cert.S mod17Pair7 = true := by decide +kernel
theorem pairs17_ok : mod17Cert.pairs.all (pairOk 17 mod17Cert.S) = true := by
  show mod17Pairs.all _ = true
  unfold mod17Pairs
  simp only [List.all_cons, List.all_nil, pair17_0, pair17_1, pair17_2, pair17_3, pair17_4, pair17_5, pair17_6, pair17_7, Bool.true_and]
set_option maxHeartbeats 0 in
theorem curves17_ok : mod17Cert.curves.all (curveOk 17 mod17Cert) = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem mod17_curve_labels : mod17Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₁₇ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod17_images_full {c : CurveCert} (hc : c ∈ mod17Cert.curves)
    (H : List (Mat2 17)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 17} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 17 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 17 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 17, z ∈ H :=
  data_sound ff17 mod17Cert S17_generates pairs17_ok curves17_ok hc H hmul hg hh hA hB

end Oracles
