# v14 → v15: response to external review (2026-06-13)

The external assessment of PSC_PROOF_v14.pdf was correct on every substantive point. v15
applies all required fixes. The review independently re-derived the finiteness break that this
session's v5-Thm-5.1 verification had already found, and additionally caught a genuine internal
contradiction in the §6.5 cohomology section that the session's own audit had missed.

## Fix 1 (MAJOR — the blocker): Theorem 4.8/finiteness demoted to Hypothesis G1
The reviewer: "Theorem 4.8's finiteness proof does not follow from the padding bound. The
predecessor-contraction inequality β·L(s′) ≤ L(s)+D is not justified." Correct, and confirmed
empirically this session (worst ratio 8.0, excess 133k, unbounded scaling).
- `thm:finiteness` is now a **Hypothesis (G1)**, with a remark explaining precisely why the
  predecessor contraction fails (padding bounds individual coincidence runs, not total deletion
  mass; a child may carry a small fraction of βL(s′)).
- Main theorem restated in the reviewer's recommended boxed form:
  **B_σ finite + SCC Producer ⟹ PDS**, with finiteness unconditional only for |A|=2 and
  verified families.
- Abstract, intro proof-chain, the Level-2 outline, and the §1 contraction bullet all updated
  to carry finiteness as a hypothesis rather than a result.

## Fix 2 (MAJOR — internal contradiction the session audit missed): §6.5 ¬PDS step
The reviewer: "the claim that a closed nonproductive SCC 'certifies σ pure discrete spectrum'
[¬PDS] is not something v14 has established." This is sharper than the reviewer stated: v14
line 97 *explicitly disclaims the BSW converse* ("not used and not claimed"), yet §6.5
`cor:cr-floor` *used exactly that converse* to conclude ¬PDS for σ. A genuine internal
contradiction, introduced by this session's cohomology merge and missed in the session audit.
- `cor:cr-floor` retitled "conditional on the bridge converse" and its ¬PDS step made explicitly
  conditional on the Akiyama–Lee overlap-coincidence criterion (PDS ⟺ overlap coincidence for
  irreducible Pisot), which supplies the converse direction thm:BSW omits.
- `rem:two-faces` corrected: leg-factor and triple-ceiling are unconditional; the cr floor holds
  under the converse.

## Fix 3 (MINOR): Theorem 6.4 / thm:v34 demoted to conditional
The reviewer: "§6.4 is now behind the actual state of the research; do not claim an
unconditional alphabet-3 lower bound." Applied:
- `thm:v34` retitled "conditional", now states the G1 hypothesis (its proof uses finiteness)
  and notes Case A is theorem-grade while Case B is conditional on one of two auxiliary lemmas.
- Abstract softened to "conditional alphabet-3 spectral observation".

## Fix 4 (consistency): all prose references
Every "Theorem~\ref{thm:finiteness}" → "Hypothesis~\ref{thm:finiteness} (G1)"; the §6 proof of
thm:v34 and the assembly both now cite finiteness as the G1 hypothesis; the withdrawn
predecessor contraction is flagged wherever it appeared.

## Items the reviewer raised that were already correct
- BSW used forward-only in the MAIN assembly (line 97 disclaimer) — correct; the issue was only
  that §6.5 violated it, now fixed.
- The main theorem was already conditional on the SCC Producer Theorem — kept, now also
  conditional on G1.
- UD via defect theorem, phase-automaton padding bound, mass-balance Lemmas 6.1–6.2, local
  witness injectivity — all kept unchanged (reviewer endorsed these).

## Compile
PSC_PROOF_v15.tex → 19 pp, 0 unresolved references, 0 undefined citations/environments.

## Net status
v15 is now a credible CONDITIONAL framework: B_σ finite (G1) + SCC Producer ⟹ PDS, with the
finiteness step honestly a hypothesis (unconditional for |A|=2 and verified families) and the
cohomological §6.5 development explicitly conditional on the bridge converse. The two overclaims
the reviewer flagged (finiteness-as-theorem, ¬PDS-certification) are removed. This also closes
the propagation defect from the session's v5-Thm-5.1 verification: the canonical line no longer
asserts finiteness as proved.

## Deliverables
PSC_PROOF_v15.tex/.pdf, this changelog. Supersedes v14 as the canonical manuscript.
The v34 auxiliary-document patch (V34_CERTIFICATE_PATCH) still applies to PROOF_CERTIFICATE.md /
V34_CLOSURE.md / DOMINANT_K2_SOURCE_V34.md, which are separate from the v13/v14/v15 line.
