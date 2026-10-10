import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL31

/-!
# ρ̄₃₁ for the Cremona curves of prime level: the mod-31 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq31 : ∀ a b c d : Fin 31, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts31 : NegFacts 31 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff31 : FieldFacts 31 := FieldFacts.of traceSq31 negFacts31 (by decide +kernel)
theorem S31_generates : S_generates 31 mod31Cert.zeta mod31Cert.S = true := by decide +kernel
set_option maxHeartbeats 0 in
set_option maxHeartbeats 0 in
theorem pair31_0 : pairOk 31 mod31Cert.S mod31Pair0 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair31_1 : pairOk 31 mod31Cert.S mod31Pair1 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair31_2 : pairOk 31 mod31Cert.S mod31Pair2 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair31_3 : pairOk 31 mod31Cert.S mod31Pair3 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair31_4 : pairOk 31 mod31Cert.S mod31Pair4 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair31_5 : pairOk 31 mod31Cert.S mod31Pair5 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair31_6 : pairOk 31 mod31Cert.S mod31Pair6 = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem pair31_7 : pairOk 31 mod31Cert.S mod31Pair7 = true := by decide +kernel
theorem pairs31_ok : mod31Cert.pairs.all (pairOk 31 mod31Cert.S) = true := by
  show mod31Pairs.all _ = true
  unfold mod31Pairs
  simp only [List.all_cons, List.all_nil, pair31_0, pair31_1, pair31_2, pair31_3, pair31_4, pair31_5, pair31_6, pair31_7, Bool.true_and]
set_option maxHeartbeats 0 in
theorem curves31_ok : mod31Cert.curves.all (curveOk 31 mod31Cert) = true := by decide +kernel
set_option maxHeartbeats 0 in
theorem mod31_curve_labels : mod31Cert.curves.map (·.label) = allLabels := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₃₁ is surjective for all 15 Cremona curves of prime level.** -/
theorem mod31_images_full {c : CurveCert} (hc : c ∈ mod31Cert.curves)
    (H : List (Mat2 31)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 31} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 31 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 31 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 31, z ∈ H :=
  data_sound ff31 mod31Cert S31_generates pairs31_ok curves31_ok hc H hmul hg hh hA hB

end Oracles
