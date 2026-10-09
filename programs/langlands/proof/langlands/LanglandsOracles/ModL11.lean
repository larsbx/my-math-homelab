import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL11

/-!
# ρ̄₁₁ for the Cremona curves of prime level: the mod-11 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq11 : ∀ a b c d : Fin 11, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts11 : NegFacts 11 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff11 : FieldFacts 11 := FieldFacts.of traceSq11 negFacts11 (by decide +kernel)
theorem S11_generates : S_generates 11 mod11Cert.zeta mod11Cert.S = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair11_0 : pairOk 11 mod11Cert.S mod11Pair0 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair11_1 : pairOk 11 mod11Cert.S mod11Pair1 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair11_2 : pairOk 11 mod11Cert.S mod11Pair2 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair11_3 : pairOk 11 mod11Cert.S mod11Pair3 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair11_4 : pairOk 11 mod11Cert.S mod11Pair4 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair11_5 : pairOk 11 mod11Cert.S mod11Pair5 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair11_6 : pairOk 11 mod11Cert.S mod11Pair6 = true := by decide +kernel
theorem pairs11_ok : mod11Cert.pairs.all (pairOk 11 mod11Cert.S) = true := by
  show mod11Pairs.all _ = true
  unfold mod11Pairs
  simp only [List.all_cons, List.all_nil, pair11_0, pair11_1, pair11_2, pair11_3, pair11_4, pair11_5, pair11_6, Bool.true_and]
set_option maxHeartbeats 0 in
theorem curves11_ok : mod11Cert.curves.all (curveOk 11 mod11Cert) = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem mod11_curve_labels : mod11Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₁₁ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod11_images_full {c : CurveCert} (hc : c ∈ mod11Cert.curves)
    (H : List (Mat2 11)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 11} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 11 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 11 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 11, z ∈ H :=
  data_sound ff11 mod11Cert S11_generates pairs11_ok curves11_ok hc H hmul hg hh hA hB

end Oracles
