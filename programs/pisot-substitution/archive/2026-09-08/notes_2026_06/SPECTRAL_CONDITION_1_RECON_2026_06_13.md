# Q-A spectral condition (1): reconciliation and verified scope (2026-06-13)

## Headline
Condition (1) of Q-A — *every nonzero root of q := χ_{N_C}/χ_A is a root of unity* —
is **not census-testable in isolation**, because its premise (χ_A | χ_{N_C}) is
**equivalent to the defining property of the trapped object** and holds for no
specimen in the corpus. What *is* now proved/verified: the premise's equivalence,
the genericity of roots of unity (so they discriminate nothing), and the
genericity of the *violation* of the exhaustive clause (so condition (1) is a
real, non-vacuous constraint).

## Verified facts (exact integer arithmetic, sympy; 0 errors)

1. **Divisibility ⟺ trapped.** For every recurrent noncoincident SCC in the
   corpus, gcd(χ_A, χ_{N_C}) = 1 and β ∉ spec(N_C) (169 SCCs, sizes 2–120). The
   intertwiner N_C V = V A (Thm floor) holds only when ρ(N_C) = β, i.e. when C is
   **closed and nonproductive** — the conjectural counterexample. Hence
        χ_A | χ_{N_C} ⟺ β ∈ spec(N_C) ⟺ ρ(N_C) = β ⟺ C is the trapped object.
   Condition (1)'s premise cannot be exhibited without exhibiting the G2 object.
   This is the G2 wall, viewed cohomologically.

2. **Roots of unity are generic, hence non-discriminating.** 225/358 productive
   SCCs already carry a root of unity in spec(N_C) (factors x±1, Φ₃, Φ₆, …).
   So `cor:rootofunity`'s "spec(N_C) contains a root of unity" is a weak
   fingerprint, NOT a corpus discriminator. (Corrects an overclaim in the v8
   `cor:rootofunity` remark and in the prior session note calling it a "sharp
   corpus discriminator" — RETRACTED; it is not sharp.)

3. **The exhaustive clause is generically violated, hence condition (1) is
   non-vacuous and restrictive.** 226/245 productive SCCs have a nonzero root of
   χ_{N_C} that is NOT a root of unity (the PF eigenvalue itself, a Perron number
   > 1). Only 19 (tiny permutation-type N_C) satisfy "all nonzero roots are
   roots of unity." The trapped object would have to land in that measure-zero-
   looking class while simultaneously having ρ(N_C) = β > 1 — but β itself is a
   root of χ_A, removed in q, so the constraint is on q only. The tension:
   the trapped object needs ρ(N_C)=β (a non-RoU Perron root, living in χ_A) AND
   q all-roots-of-unity. cor:rootofunity gives ≥ C−1 of q's roots as RoU for free;
   the open residual is the remaining deg q − (C−1) roots.

## Honest placement (no progress on the open core; ledger correction)
- Condition (1) is locked to the trapped object's existence; it is a NECESSARY
  property provable a priori in part (≥ C−1 RoU roots, `cor:rootofunity`), with
  the residual (ALL of q's roots RoU) genuinely open and genuinely arithmetic.
- The ×β / β-expansion lever does NOT get traction here the way hoped: there is
  no corpus specimen carrying the divisibility to run a cut-coordinate orbit
  argument against. The lever's natural home remains cycle-exclusion (now moot,
  item 1 discharged), not spectral condition (1).
- RETRACT: "spec(N_C) must contain a root of unity — new sharp corpus
  discriminator" (SESSION_2026_06_13_NOTES.md item 3). Roots of unity are generic
  among productive SCCs (225/358). The discriminating clause is the EXHAUSTIVE
  one, which is what `cor:QAresidue` already correctly states.

## v8 edit needed
`cor:rootofunity`'s closing phrase "a spectral shape realized … by no recurrent
component in the certified corpus" is FALSE as stated for the weak reading
(RoU-containment) and should be tightened to the exhaustive reading: it is the
property *q entirely root-of-unity* (equivalently dim Ȟ¹(Ω_{Σ_C}) = k) that no
productive component realizes — 226/245 carry an off-unit-circle Perron root.

## Updated queue
1. **Condition (1) residual (open, arithmetic):** are the remaining
   deg q − (C−1) nonzero roots of q forced to roots of unity? This is now the
   sole cohomological-side gap of Q-A, and it is genuinely open — no census
   purchase. Candidate tools: BBJS exact-regularity / the +1 eigenspace structure
   of N_C^q beyond the H̃⁰ injection; Barge–Olimb asymptotic-cycle machinery.
2. **Barge–Olimb at source** (888 unimodular b₁>0 specimens; cr=2 not excluded).
3. **Q-B** triple geometry (1,740-specimen unconditional stratum).
4. v13/v14 consolidation.

## Artifacts
`spectral_q_batch.py`, `reconcile_spec.py`, `cyclofree_check.py`,
`offcircle_full.py` (all in /mnt/project, gated/exact).
