# PSC weekly completion ledger — 2026-10-02

**Repository baseline:** `main@ff9e5d359ea6ebe7d463f25874335a66ce3a429a`
(mathematical/evidence additions through PR #188; also includes research
references from PRs #154 and #157 and CI/provenance maintenance from PR #191).
**Purpose:** weekly completion/status snapshot. This file is not a proof
source. Claim status is governed by `claim_governance.toml`, the generated
ledger surfaces, `docs/claim-status-and-source-map-2026-09-13.md`, and the
cited manuscript/proof sources.

## Executive status

General PSC remains open. No immutable accepted-proof provenance on `main`
establishes the conjecture, seedwise overlap productivity, the aligned branch,
the strict-zipper branch, or G1. The shortest PDS route still has one open
premise:

```text
primitive irreducible Pisot
=> bounded discrepancy                                  [PROVED]
=> finite seed-patch overlap graph                      [PROVED]
=> one swap seed has only productive reachable overlaps [OPEN: #84]
=> coincidence density one / dense good set             [PROVED]
=> pure discrete spectrum                               [IMPORTED theorem]
```

The week produced two proved reductions and one complete finite
evidence package without crossing that boundary:

1. the aligned obstruction is reduced to a fixed bad hub edge or an
   alternating type-E template;
2. all-seed overlap productivity, and more sharply all-seed strict-zipper
   exclusion, each conditionally imply finite BPA (G1); and
3. the 24,486-member ternary total-image-length-at-most-8 separation sweep completed
   with exact receipts and an independent recomputation.

## Repository-proved or imported results added this cycle

### Two-route obstruction map

PR #181 records the current split of a bad closed irreducible nonproductive
overlap SCC:

- **aligned branch (#138):** the recurrent first-child pair dynamics reduce
  to a fixed bad hub edge or the forced alternating type-E template;
- **strict-zipper branch (#139):** finite-place compatibility and the integral
  carry recursion are exact, but the coverage/forcing step remains open.

These are reductions, not branch closures. `docs/p1-two-route-map-2026-10-01.md`
and `docs/p1b-madic-carry-reduction-2026-10-01.md` state the remaining
obligations and negative controls.

### Conditional routes to finite BPA

PRs #183, #185 and #188 put two overlap-side implications into the manuscript
and generated proof ledger:

```text
all-seed overlap productivity + finite seed overlap graphs
=> finite BPA (G1)                              [CONDITIONAL: Proposition 5.46]

all-seed strict-zipper exclusion + finite seed overlap graphs
=> finite BPA (G1)                              [CONDITIONAL: Proposition 5.47]
```

The second route uses only half-coincidences: an offset-zero descendant gives
the common vertex needed for the bounded-gap proof. It does not exclude strict
zippers. Consequently canonical G1 now has three conditional alternative
establishment routes—renewal finiteness, all-seed productivity, or all-seed
strict-zipper exclusion—but every route retains an open premise. G1 remains
open.

The exact cube-image regression certifies first half-coincidence depth
`K' = 17` on all 1,142 overlap vertices and yields a finite per-specimen state
bound. This is a certified specimen result, not the general theorem.

## Exact finite evidence completed

PRs #182, #184, #186 and #187 reconstruct and certify the
total-image-length-at-most-8 domain of 24,486 ternary primitive irreducible
Pisot substitutions.

The canonical Mojo separation sweep, at a 2,000,000 collared-state cap and
radii through 12, reports:

| Outcome | Count |
| --- | ---: |
| least radius 1 | 2,264 |
| least radius 2 | 13,688 |
| least radius 3 | 6,092 |
| least radius 4 | 1,230 |
| least radius 5 | 288 |
| least radius 6 | 60 |
| least radius 9 | 12 |
| exact proper-power collapse witness by level 6 | 852 |
| inconclusive | 0 |

The 12 radius-9 specimens form one relabelling/reversal orbit. A separately
written driver reproduced the distribution, that orbit, and the 852 collapsing
survivors. The 24 specimens capped by the older 200,000-state collar diagnostic
are decided under the larger canonical budget: 12 at radius 2 and 12 at radius
3.

This evidence is exact on the enumerated domain and stated resource contract.
It supplies no completeness theorem beyond that domain and does not promote
#84, #138, #139, G1, or PSC.

## Research references and maintenance

- **PR #154 — Penrose 2D interface bridge.**
  `docs/bridges/penrose-2d-to-psc-interface-program.md` records non-load-bearing
  analogies for P2/G1b-2 and P4 realization, with a narrower P1b/#139
  comparison. It merits indexing and references only; it supplies no PSC
  theorem or discharge of an open gate.
- **PR #157 — Padovan / Plastic-A conjecture program.**
  `docs/post-proof-padovan-plastic-a-conjectures-2026-09-23.md` and its JSON
  catalogue remain research-only. The historical "post-proof" filename does
  not establish general PSC or promote the benchmark conjectures.
- **PR #191 — CI and provenance repairs.** The estate CI workflow was restored,
  the boundary-sync audit now uses the repository root, the Padovan note's C0
  controls were repaired, and the archived v15 source blob was restored.
  These are verification/source maintenance, not mathematical closures.

None of these merges changes #84, #138, #139, G1, or general PSC from open.
The proof/evidence milestones above and the closure priorities below retain
their existing hypotheses and domains.

## Open mathematical obligations

1. **#84 — seedwise overlap productivity.** Still the only open premise on the
   shortest PDS route.
2. **#138 — aligned strong-coincidence branch.** Exclude the fixed-edge and
   alternating type-E templates uniformly, including reversal.
3. **#139 — strict-zipper hitting.** Prove occurrence-compatible adelic
   coverage: some realized periodic orbit must enter the graph-directed
   reverse zero basin. Finite M-adic quotient survival alone is necessary, not
   sufficient.
4. **#44 — G1b-2 renewal finiteness.** Still an open independent route to G1.
5. **Finite-BPA carrier route.** Concentration (`K2 = 0`), general wedge
   productivity (`K2 != 0`), and SCC Producer remain open.
6. **Realization / MEF.** The G0–G6 interface remains an open bridge; finite
   collar death is evidence only.

## Provenance and status controls

- The September “PSC closed” project-management premise remains withdrawn.
- The canonical manuscript, claim ledger/map, roadmap, proof ladder and README
  all retain PSC and the key gates as open.
- The unrecovered historical `PSC_PROOF_v16` material is archival metadata,
  not a live proof dependency.
- The externally supplied v9 material contributes only the separately audited
  UD/local-hierarchy results; its withdrawn finite-BPA and cycle-exclusion
  claims remain non-load-bearing.
- PR identifiers record review provenance. They do not substitute for the
  mathematical source, hypotheses, or proof.

## Next reviewable milestones

1. Prove or falsify the occurrence-compatible adelic coverage lemma for the
   strict-zipper route, using the known affine pumps and collar collisions as
   mandatory negative controls.
2. Prove the endpoint/occurrence incompatibility of the two surviving aligned
   templates.
3. Keep Propositions 5.46–5.47 explicitly conditional; do not infer G1 from
   their conclusions without discharging an all-seed premise.
4. Use further finite sweeps only to test a named uniform lemma or preserve a
   countermodel, not as a replacement for universal closure.
