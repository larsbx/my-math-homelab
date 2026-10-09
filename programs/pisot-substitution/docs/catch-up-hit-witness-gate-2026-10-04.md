# Catch-up hit-witness enumeration: stop/go check — 2026-10-04

**Decision: proceed with certificate export and regression of the existing
finite-box Q1 contract.** Main at `3344a6b` already contains #199–#202:
`psc.one_tile`, its regressions, and a CI-pinned standing census. Do not redo
that discovery or propose Q1 as an untested universal invariant. The missing
work is occurrence-address witnesses and stable per-vertex failure records.

## Exact experiment

On the complete Proposition V box graph, inspect every child occurrence,
including descendants beyond an earlier common vertex. Decide whether each
recurrent nonzero-offset vertex reaches any new common boundary whose birth
levels differ. Check both endpoints. Export occurrence paths and replayable
forward-closure certificates for vertices for which every new hit is
simultaneous. A capped graph gives no verdict.

## Prior art and boundaries

Primary sources inspected on October 4 (the indicated portions only):

| Source | Relevant construction or boundary |
| --- | --- |
| Akiyama–Lee, [Algorithm for determining pure pointedness of self-affine tilings](https://arxiv.org/abs/1003.2898), abstract and introduction; repository's existing [strict-zipper gate §5](p1b-strict-zipper-literature-gate-2026-09-21.md) | Finite overlap graphs and coincidence reachability are existing machinery. A vertex-boundary hit is a different target from a tile coincidence. |
| Barge, [Factors of Pisot tiling spaces and the coincidence rank conjecture](https://arxiv.org/html/1301.7094v1), preliminaries and Theorem 4 | Coincidence rank belongs to the legal tiling space and its maximal equicontinuous factor. Local Q1 failures do not imply failure of pure discrete spectrum. |
| Barge, [The Pisot conjecture for beta-substitutions](https://arxiv.org/pdf/1505.04408), Properties 1–3 and their use in the configuration argument | The beta-language monotonicity assumptions do not transfer to arbitrary PIP substitutions; see the existing [configuration gate](p1b-barge-diamond-configuration-gate-2026-10-02.md). |

The box completeness and finiteness argument is the repository's Proposition
V. This export depends on it; it does not supply a new uniform finiteness
theorem. The catch-up locus is already stated in §5.6b. Inspecting outgoing
occurrences directly gives another executable check of that same contract:
a new left hit has child offset zero and at least one nonzero child index;
it is catch-up exactly when one index is zero. The right-endpoint version
uses last-child indices. Repeated paths are handled by reverse reachability,
not a depth cutoff or one selected shortest path.

## Negative controls and resulting scope

- `1/012/010`: all 694 recurrent nonzero vertices are catch-up-free, but
  PPVC holds with depth 14. This is a Q1 counterexample, not a PSC one.
- `1/12/022`: two of 14 vertices fail Q1; failure need not be explained by
  the specimen-wide arithmetic obstruction.
- A first simultaneous hit does not exclude another shortest catch-up hit
  or a later one. Regressions must pin these distinctions.
- Coincident equal-letter tiles are absorbing in the canonical graph. Their
  subdivisions agree at every level and cannot introduce a catch-up; this
  pruning is valid for this target too.

Proceed with stable labels, occurrence-level replay and finite-domain
evidence. Keep #139, UH, G1, general PPVC and PSC open. No ledger claim or
manuscript theorem is promoted by this work.
