import LanglandsOracles.TraceFormula
import LanglandsOracles.Data

/-!
# Eichler–Selberg at level N, kernel-checked against exported modular-symbol traces.

`traceData` holds (N, k, n, tr T_n on cuspidal weight-k Manin symbols) computed in Python; that
trace is 2·tr T_n | S_k(Γ₀(N)).  Lean recomputes the geometric side `eichlerSelbergN24` (index,
class numbers, local factors μ, φ(gcd(c, N/c)), the weight-2 correction) and checks
24·tr = 12·(cuspidal trace) on every row.
-/
namespace Oracles

theorem psi_values : [1, 2, 3, 4, 6, 8, 9, 12, 30, 36].map psi = [1, 3, 4, 6, 12, 12, 12, 24, 72, 72] := by
  decide +kernel

theorem eichler_selberg_level_N :
    traceData.all (fun r => let (N, k, n, tr) := r; eichlerSelbergN24 N k n == 12 * tr) = true := by
  decide +kernel

end Oracles
