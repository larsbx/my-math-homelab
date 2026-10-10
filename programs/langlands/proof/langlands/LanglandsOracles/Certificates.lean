import LanglandsOracles.TraceFormula
import LanglandsOracles.Carlitz

namespace Oracles

/-- Gauss's table. -/
theorem class_numbers :
    [(-3 : Int), -4, -7, -8, -11, -15, -19, -20, -23, -24, -31, -35, -39, -40, -43, -47, -71, -163, -12, -16, -27, -32, -36].map classNumber
      = [1, 1, 1, 1, 1, 2, 1, 2, 3, 2, 3, 2, 4, 2, 1, 5, 7, 1, 1, 1, 1, 2, 2] := by decide

/-- Eichler–Selberg at weight 12 reproduces τ(n), n ≤ 20, with the division by 24 exact. -/
theorem eichler_selberg_tau :
    ((List.range' 1 20).map (fun n => traceLevel1 12 n) = tau 20) ∧
    ((List.range' 1 20).all (fun n => traceLevel1Exact 12 n) = true) := by decide +kernel

theorem eichler_selberg_dims :
    [4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26].map (fun k => traceLevel1 k 1)
      = [0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 2, 1] := by decide

theorem fermat_carlitz_small :
    ([(3, [0, 1]), (3, [1, 1]), (3, [1, 0, 1]), (3, [2, 2, 1]), (2, [1, 1, 1]), (2, [1, 1, 0, 1]), (5, [2, 1]), (5, [2, 0, 1])] :
      List (Nat × FpPoly)).all (fun pP => fermatCarlitz pP.1 pP.2) = true := by decide

end Oracles
