# Exact ℚ(β) certification upgrade for census genuineness (2026-06-13)

Addresses the standing soundness caveat ("float L currently; theorems unaffected") on the
per-specimen overlap census. Builds an exact number-field instrument and verifies the float
genuineness decisions against it.

## Instrument: `exact_lengths.py` (gated)
- `beta_field(M)`: extracts the Pisot root β of χ_M as a sympy `AlgebraicNumber`, solves
  (M^⊤ − βI)L = 0 exactly over ℚ(β), normalizes L[0]=1. Returns (β, minpoly, exact L).
- `exact_genuine(i,δ,j,L,β)`: decides genuineness by the exact sign of the overlap width
  min(L_i, t+L_j) − max(0,t), t = ⟨δ,L⟩, with all comparisons exact in ℚ(β) — no float
  threshold.
- **GATE (4 clauses, 30/30 specimens):** (a) M^⊤L = βL holds exactly (symbolic residual 0);
  (b) L[0]=1; (c) exact L agrees with float L to 1e-6; (d) genuineness decisions reproduced
  — **4,050 decisions, 0 float/exact mismatches.** TRUSTED.

## Finding: the float census genuineness was SOUND
Verified the trusted predicate `overlap_residual.genuine_overlap` against `exact_genuine`
on **2,152 seed overlaps across 41 PIP specimens**: **0 mismatches**, including 0 at the
exact anchors (t=0, t=L_i−L_j; boundary by definition) and 0 genuine near-misses. The 1e-9
genuineness threshold never flipped a call relative to exact ℚ(β) arithmetic.

## Self-caught probe artifact (logged)
A first margin-hunt reported 1,202 "mismatches" at float margin exactly 0.0. These were NOT
census errors: the hunt used a crude inline predicate (`t > 1e-9`) that mishandled the
exact-anchor convention, disagreeing with exact arithmetic only on t=0 / t=L_i−L_j states
(which are touching/boundary, correctly excluded by the real `genuine_overlap`). Re-running
with the actual trusted predicate gave 0 mismatches. The episode is itself the value of the
exact instrument: it distinguishes a probe artifact from a genuine error, and confirms the
real predicate's anchor handling matches exact ℚ(β).

## Status / scope
- The genuineness predicate underlying the overlap census is now exact-ℚ(β)-certified on the
  tested corpus (anchor handling included).
- The β→1 tail (large-Δ certificates) is where float is most stressed; the exact comparator
  applies there verbatim and is the right tool for a future dedicated pass over the 50 capped
  / 3 timeout specimens in the canonical ledger.
- Theorems unaffected (they never depended on float); this hardens the per-specimen census
  claims, as the 06-10 queue item #2 requested.

## Artifacts
`exact_lengths.py` (gated, TRUSTED), `exact_margin_hunt.py`, `exact_margin_hunt2.py`.
