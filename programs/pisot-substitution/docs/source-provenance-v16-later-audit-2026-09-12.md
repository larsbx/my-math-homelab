# v16/later source-provenance audit — issue #45

**Status:** authoritative repository audit of reachable Git history as of 2026-09-12, with claim-status resolution updated through 2026-09-13. This record imports surviving sources and distinguishes reconstructed theorems, historical restricted results, and open mathematical obligations. The current summary is `docs/claim-status-and-source-map-2026-09-13.md`.

## Audit scope and method

Repository: `larsbx/pisot-substitution-conjecture-research`.

Audit base: `main@ebe53e2cef40d5dff60dc39f14696137da77e1ac`.

The audit examined all 68 named remote branches (69 remote refs including `origin/HEAD`) and all 319 commits reachable from those refs. It searched:

- every reachable object path for manuscript versions `v16` and later and for Galois, wedge, concentration/aux-B, realization, and coincidence-rank names;
- every reachable text revision for the corresponding theorem phrases;
- commit messages, additions, and deletion history;
- Issue #45, PR #47, the two-gate audit branches, the P1-A branch, and the preserved 2026-09-08 archive.

No reachable branch or commit contains a `PSC_PROOF_v16` (or later) source, and no deletion record identifies such a file. Commit `013fbedc3b799934fc9eca9ef8b64c0e680ed26b`, an ancestor of `main`, already imports the 2026-09-08 audit's references to the purported v16 and explicitly records that the file was not found. Commit `1009dccba6bd802c80e989ace1508572c06bfdda` is the later status ledger that attaches the reported v16-track theorem statuses to G1b-1, Galois propagation, aux-B, and realization/rank. It is not the first textual occurrence of “v16” and is not a detailed proof source.

This is a negative result about the accessible repository record, not a claim that no source ever existed outside GitHub.

## Imported source map

| Claim or obligation | Reachable authoritative material | Imported location | Audit status |
| --- | --- | --- | --- |
| G1b-1 bounded discrepancy | The 2026-09-11 ledger at `1009dcc` records the estimate `Disc(sigma w) <= c Disc(w) + 2 E_sigma`, but supplies no detailed proof; v15 predates this rung. Independently reconstructed on 2026-09-13 by a global argument (no contraction estimate) | `sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md`; `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`, Theorem 4.4 | **RESOLVED BY RECONSTRUCTION**; the reported contraction estimate itself remains unrecovered and unused |
| Galois wedge-nonvanishing propagation | The preserved certificate at `013fbedc` proves a degree-three dominant-capture theorem for six explicit seed defects. The degree-two carrier implication was independently reconstructed in the audited manuscript at `318370f` as the wedge dichotomy: nonzero `K2` has full rational wedge span by irreducibility of `chi_(Lambda^2 M)` | archived certificate §§8–12; `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`, Theorem 5.16(i) and Proposition 5.20; `docs/galois-aux-b-source-resolution-2026-09-13.md` | **RESOLVED BY RECONSTRUCTION** for the carrier span implication; the seed-specific degree-three source is preserved separately |
| concentration / aux-B | Exact research target introduced at `af46a0e`; sharpened v34 inheritance/escape audit at `1297174` | `sources/issue-45/p1a-concentration-aux-b-program.md`; `sources/issue-45/p1a-v34-concentration-audit.md` | **OPEN CONJECTURAL GATE**; formulation imported, no proof claimed |
| realization / coincidence-rank equivalence | The equivalence first occurs in reachable history as a status-level assertion at `1009dcc`; no detailed proof source occurs on any reachable ref; the 2026-09-13 audit `sources/issue-45/realization-coincidence-rank-audit.md` lists the seven unreconstructed obligations G0–G6 (definition of global realization, reachability from swap seeds, window existence/density, cofinal coverage, collar completeness, transfer of non-coincidence, recurrence) | ledger, corrected source-audit manuscript, and the audit note | **CONJECTURAL BRIDGE, NOT SOURCE-PENDING**: each gap is an independently recorded open problem, so no file recovery would close it; formal recurrence, global realization, and collar evidence remain distinct |
| v15 theorem/citation baseline | Preserved on `main` by commit `013fbedc3b799934fc9eca9ef8b64c0e680ed26b`; archive provenance identifies v15 as the last imported canonical manuscript | `archive/2026-09-08/manuscripts/PSC_PROOF_v15.tex` | historical baseline; known P0 defects retained only in the immutable archive |
| P0 corrections | Checklist introduced at `cb2de9f`, incorporated in the two-gate ledger at `1009dcc` | `docs/manuscript-p0-corrections-2026-09-11.md`; `manuscripts/PSC_PROOF_next_source_audit.tex` | repaired in the new working manuscript without theorem promotion |

## File-level provenance

The two files under `sources/issue-45/` are source snapshots imported byte-for-byte:

- `p1a-concentration-aux-b-program.md` from branch `research/p1a-concentration-aux-b`, commit `af46a0eb4c3bd70ae02686a0974cade152e4be85`, original path `docs/p1a-concentration-aux-b-program.md`;
- `p1a-v34-concentration-audit.md` from the same branch, commit `1297174db56e9d3aa5d0334e25783c58323b5794`, original path `docs/p1a-v34-concentration-audit.md`.

A default or single-branch checkout need not contain those side-branch commits. The original full-index `git format-patch` records are therefore preserved as `0001-Seed-P1-A-concentration-program.patch` and `0002-Audit-v34-against-the-concentration-gate.patch`. Their `From` lines identify commits `af46a0eb4c3bd70ae02686a0974cade152e4be85` and `1297174db56e9d3aa5d0334e25783c58323b5794`; their diffs independently reconstruct the original source files rather than deriving provenance only from the imported snapshots.

| Repository-contained file | Git blob on `main` | SHA-256 of file bytes |
| --- | --- | --- |
| `sources/issue-45/p1a-concentration-aux-b-program.md` | `63661af49a272ff3ed4a4eaa164d1d745c374226` | `13ddaac5950e9fc85849bbdd74f19b6995bbc55c3602320e68f40262b831cdf6` |
| `sources/issue-45/p1a-v34-concentration-audit.md` | `3c425352378885ae3af734d524e393cf3bb8f191` | `a4316dec77d5912d02c9e861055e06776527a13ab5c42cdb789f221013ca2de1` |
| `archive/2026-09-08/manuscripts/PSC_PROOF_v15.tex` | `36f810d3540ee5cf677f7b704429f15d679b24c2` | `0b28c23aa8f4d006e6de3823b1c953626dad20ce58c77afa76717bd91abee6df` |
| `archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md` | `88ef54c8b3a67cb7dc4c5110f369d815c1c5f4a7` | `c318edd7b55aacddf4a3f980eea22b183b7161249dbc0ff42d74ef93faf13b3e` |

The full source commit identifiers above are historical locators and object identities. The full-index patch records are the durable verification anchor for these two source additions: they remain sufficient to reconstruct and inspect the original file bytes even if the side branch is later deleted.

The checksums are committed in `sources/issue-45/SHA256SUMS`. `tools/verify_all.sh` and the `source-provenance` CI job also apply the preserved patch series in an empty temporary repository and compare the reconstructed bytes to the imported snapshots. Thus changing a snapshot together with its checksum manifest still fails unless it matches the independently preserved source record.

The new manuscript `manuscripts/PSC_PROOF_next_source_audit.tex` is derived from the archived v15 source and therefore is not represented as the missing v16 manuscript. Its front-page notice identifies that fact and freezes the four source boundaries above.

## Claim-status rules

1. “Theorem-grade in the v16 track” is historical status metadata until the detailed proof is imported; it is not `RepositoryProved`.
2. The v34 Galois calculations may be cited only for their exact degree-three seed rational-factor/transitivity statements. The carrier-level degree-two span implication is now sourced instead to the merged manuscript's self-contained wedge dichotomy.
3. Concentration/aux-B is an open implication from a closed recurrent nonproductive carrier to nonzero dominant wedge projection.
4. Span-rich/productivity conclusions that use concentration remain explicitly conditional.
5. The realization/coincidence-rank chain is a **conjectural bridge**, not a source-pending theorem: `sources/issue-45/realization-coincidence-rank-audit.md` records seven open obligations G0–G6, none of which a recovered file would close. A formal BPA cycle, a globally realized component, and finite collar survival are not interchangeable.
6. G1b-1 remains distinct from G1b-2: bounded discrepancy does not imply finite BPA state space.
7. No source here assumes unimodularity, finite injectivity, or discreteness of `pi_s(Z^A)`.

## Manuscript repairs applied

The new working manuscript:

- removes the false primitivity-alone aperiodicity assertion;
- separates primitive+aperiodic Mossé recognizability from Pisot-specific inputs;
- distinguishes Barge–Diamond strong coincidence, Hollander–Solomyak balanced-pair/two-symbol PDS, and Sirvent–Solomyak symbolic/tiling-action algorithm results;
- restricts mass-balance language to closed nonproductive carriers where no leakage is used;
- keeps concentration-dependent span-rich conclusions conditional;
- derives UD from nonzero determinant/full incidence rank rather than assuming it;
- retracts the phase-state-to-total-padding inference;
- preserves the non-unimodular and realization/computational-completeness firewalls.

## Residual historical-source status

No reachable `PSC_PROOF_v16` file has been found. That negative provenance
finding remains valid, but it no longer blocks the current proof architecture:

- G1b-1 is repository-proved by the independent reconstruction merged in PR #69;
- the degree-two carrier-span implication is repository-proved by the self-contained wedge dichotomy resolved in PR #68;
- concentration/aux-B is an open conjectural gate, not a theorem waiting for a source;
- realization/coincidence-rank is an open bridge decomposed into G0–G6, not a theorem waiting for a source;
- the historical degree-three seed theorem is already preserved and remains restricted to its six explicit seeds.

If a v16 document is later recovered, preserve its version identity and authorship metadata, compare every theorem against the reconstructed statements and present hypotheses, and archive the result. Do not automatically upgrade any live claim merely because the file exists.

Current status vocabulary and maintenance rules are centralized in `docs/claim-status-and-source-map-2026-09-13.md`.
