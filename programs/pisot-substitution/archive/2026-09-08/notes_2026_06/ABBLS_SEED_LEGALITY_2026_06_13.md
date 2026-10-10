# ABBLS seed-legality verification (2026-06-13)

Discharges the standing refutation-bar item: "ABBLS seed-legality hypothesis must be verified
before any refutation-grade claim." Verdict: the hypothesis is **benign for termination (G1)
and for the refutation bar**, with one **actionable correction for G2-style SCC censusing**.

## What the hypothesis is
ABBLS Thm 5.3: an irreducible Pisot σ has PDS ⟺ the balanced-pair algorithm terminates with
coincidence from the (ab,ba) swap seeds. The seed-legality hypothesis is that the swap seeds
actually used are LEGAL balanced pairs — both ab and ba are length-2 factors of L(σ), so the
algorithm is seeded with genuine elements of the subshift's balanced-pair graph.

## Verification (exhaustive k=3 corpus, gated `legal_two_words` from bd_exact)
Of 13,662 standard swap seeds across 4,554 PIP specimens:
- **8,154 (60%) both-legal** (genuine balanced-pair seeds).
- **4,728 (35%) asymmetric** — exactly one of ab/ba is a legal factor; the swap is NOT a
  balanced pair of the subshift.
- **780 (5.7%) neither legal.**
- Only **546 (12%) of specimens** have all swap seeds both-legal.

So `balanced_pair.standard_seeds()` (which emits every a<b swap) and `build_bpa` (which filters
seeds only by Parikh-balance, NOT by language-legality) seed from many pairs that are not in
the subshift.

## Impact (all-swap seeding vs legal-swap-only seeding, 400 specimens)
- **Termination: identical (0/400 differ).** Finiteness of B_σ is unaffected by illegal seeds.
  **G1 and the non-termination refutation bar are unaffected** — a non-terminating PIP would
  still refute PSC regardless of seed legality, since termination is seed-legality-invariant.
- **Recurrent noncoincident SCC count: differs in 8/400 (2%).** All-swap seeding produces
  EXTRA recurrent SCCs (e.g. 2 vs 1, 3 vs 2) reachable only from illegal seeds. These are
  SPURIOUS — they correspond to balanced pairs not present in the subshift. **A G2 census
  seeded from all swaps OVER-COUNTS noncoincident SCCs.** (Conservative for a
  "no-closed-nonproductive-SCC" claim, since extra SCCs can only add candidates to rule out,
  but wrong for structural counts and for any SCC-spectrum statistics.)
- **19/400 (4.75%) specimens have NO legal swap seed.** Verified these have NO legal length-2
  balanced pair at all (every legal 2-word has a unique Parikh vector among legal 2-words).
  The length-2 swap-seed bridge is vacuous for them — the degenerate-but-valid case where each
  factor is its own balanced class. Not a gap: Thm 5.3's content concerns nontrivial balanced
  pairs; with none at length 2 there is nothing to seed or terminate.

## Verdict
- **Refutation bar SOUND.** Termination is seed-legality-invariant, so a non-terminating PIP
  specimen refutes PSC irrespective of the hypothesis. The standing caveat is discharged for
  the refutation use.
- **G1 (termination) SOUND** under either seeding.
- **ACTIONABLE for G2:** SCC censuses should seed `build_bpa` from LEGAL swaps only (both ab,
  ba in legal_two_words), or post-filter recurrent SCCs to those reachable from legal seeds,
  to avoid ~2% spurious-SCC over-counting. The prior G2 census ("0 closed-nonproductive SCCs")
  is UNAFFECTED in its conclusion (over-counting only adds candidates that were all ruled out),
  but its SCC-count and spectrum statistics inherit the spurious components and should be noted
  as upper bounds unless re-run with legal seeds.

## Recommended instrument change
Add `legal_swaps(s)` (both-legal filter) and make it the default seed set for any G2/structural
BPA run; keep all-swaps only where a deliberately conservative over-seeding is wanted. Gate:
legal_swaps ⊆ standard_seeds, and termination(legal) == termination(all) on the corpus (verified
0/400 differ).

## Artifacts
`seed_legality.py` (census), `seed_legality_impact.py` (all-vs-legal comparison),
`no_legal_swap.py` (degenerate-case characterization). Reuses gated `bd_exact.legal_two_words`.
