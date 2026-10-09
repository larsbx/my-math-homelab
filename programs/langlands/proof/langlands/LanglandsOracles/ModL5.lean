import LanglandsOracles.ImageModL
import LanglandsOracles.DataModL5

/-!
# ρ̄₅ for the Cremona curves of prime level: the mod-5 instance of `ImageModL`.
-/
namespace Oracles

namespace Mat2

theorem traceSq5 : ∀ a b c d : Fin 5, (a * a + b * c) + (c * b + d * d) = (a + d) * (a + d) - 2 * (a * d - b * c) := by trace_sq_tac
theorem negFacts5 : NegFacts 5 := ⟨by decide, by decide, by decide, by decide, by decide⟩
theorem ff5 : FieldFacts 5 := FieldFacts.of traceSq5 negFacts5 (by decide +kernel)
theorem S5_generates : S_generates 5 mod5Cert.zeta mod5Cert.S = true := by decide +kernel
theorem pair5_0 : pairOk 5 mod5Cert.S mod5Pair0 = true := by decide +kernel
theorem pair5_1 : pairOk 5 mod5Cert.S mod5Pair1 = true := by decide +kernel
theorem pair5_2 : pairOk 5 mod5Cert.S mod5Pair2 = true := by decide +kernel
theorem pairs5_ok : mod5Cert.pairs.all (pairOk 5 mod5Cert.S) = true := by
  show mod5Pairs.all _ = true
  unfold mod5Pairs
  simp only [List.all_cons, List.all_nil, pair5_0, pair5_1, pair5_2, Bool.true_and]
theorem curves5_ok : mod5Cert.curves.all (curveOk 5 mod5Cert) = true := by decide +kernel
theorem mod5_curve_labels : mod5Cert.curves.map (·.label) = allLabels.filter (· != "11a1") := by decide +kernel

end Mat2

open Mat2 in
/-- **ρ̄₅ is surjective for the 14 Cremona curves of prime level other than 11a1** (which has a rational 5-torsion point) -/
theorem mod5_images_full {c : CurveCert} (hc : c ∈ mod5Cert.curves)
    (H : List (Mat2 5)) (hmul : ∀ x ∈ H, ∀ y ∈ H, M2.mul x y ∈ H) {g h : Mat2 5} (hg : g ∈ H) (hh : h ∈ H)
    (hA : g.trace = finN (apMod 5 c.ainvs c.p1) ∧ g.det = finN c.p1)
    (hB : h.trace = finN (apMod 5 c.ainvs c.p2) ∧ h.det = finN c.p2) : ∀ z ∈ gl 5, z ∈ H :=
  data_sound ff5 mod5Cert S5_generates pairs5_ok curves5_ok hc H hmul hg hh hA hB

end Oracles
