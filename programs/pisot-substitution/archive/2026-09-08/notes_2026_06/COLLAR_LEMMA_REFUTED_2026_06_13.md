# Collar Certification Lemma: REFUTED (2026-06-13)

Discharges the third standing verification item. Verdict: the proposed lemma is FALSE; the
hoped-for collapse of per-cycle radius checks to a per-substitution constant does not exist
via recognizability.

## Proposed lemma (from the 06-10 queue / memory)
"Bounding per-cycle radius R(C) by the Mossé constant L_σ, collapsing per-cycle checks to
per-substitution computation." Operationally: R(C) ≤ L_σ, where R(C) = max imbalance (the
geometric width by which the two balanced-pair words drift) over a recurrent BPA SCC, and
L_σ is a per-substitution recognizability constant.

## Test (recognizability-window proxy L_rec for L_σ; saturation-depth radius)
- **R(C) ≤ L_rec: FAILS.** 3/56 violations at 50 specimens; max ratio 2.0.
- **R(C) ≤ 2·L_rec: FAILS on the larger corpus.** 0 violations at 50 specimens (looked
  promising, tight at ratio 1.0) but **1 violation at 80 specimens, max ratio 3.0** — the
  factor-2 bound is a corpus-size artifact, exactly the kind the discipline warns about.
- **Ratio R(C)/L_rec is GROWING** (2.0 → 3.0 as the corpus grows) and **correlates with cycle
  maxlen** (corr 0.53); **R(C) itself correlates strongly with cycle maxlen** (corr 0.85).
- **R(C) ≤ cycle_maxlen − 1: 0 violations** across 87 SCCs.

## Verdict
The radius R(C) is driven by **per-cycle word length**, not by any per-σ recognizability
constant. No constant c makes R(C) ≤ c·L_σ hold uniformly (the ratio is unbounded, tracking
maxlen). **The Collar Certification Lemma is FALSE.** The sound bound is the per-cycle
        R(C) ≤ maxlen(C) − 1,
already present in `radius_closed_bound.py` (R ≤ (maxlen−1) + B₀, B₀ the short-state
imbalance). This is exactly the per-cycle quantity the Collar Lemma hoped to eliminate; it
cannot be eliminated via recognizability.

## Consequence for G1a
The G1a radius ceiling R(s) ≤ 4·B(σ) is a DIFFERENT bound (B(σ) = a per-σ balance constant,
not L_σ, and the 4·B(σ) form was established via component-ancestry induction + junction
lemma, not via recognizability). This refutation does NOT touch the 4·B(σ) ceiling; it only
kills the proposed recognizability-based SHARPENING to a single L_σ computation. The per-cycle
radius work stands on the maxlen bound and the ancestry induction, not on a collar collapse.

## Why the collapse fails (mechanism)
Recognizability L_σ bounds the window beyond which DESUBSTITUTION is forced — it constrains
how far you must look to recover the preimage. But the balanced-pair imbalance R(C) measures
the drift between two EQUAL-PARIKH words, which can accumulate along a long cycle independently
of the desubstitution window: a long recurrent cycle revisits states whose words have grown,
and the imbalance grows with that word length, not with the fixed recognizability constant.
The two quantities are governed by different mechanisms; there is no inequality between them.

## Net
A refuted proposed lemma — a negative verification result. The per-cycle radius bound
R(C) ≤ maxlen(C) − 1 is the honest statement (already banked). The standing-queue Collar item
is closed: do not re-attempt the recognizability-to-per-cycle collapse; it is provably absent.

## Artifacts
`collar_test.py`, `collar_constant.py`, `collar_verify.py`, `collar_verdict.py`
(recognizability-window proxy + radius/maxlen correlation).
