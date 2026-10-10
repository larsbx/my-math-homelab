# PSC weekly completion ledger — 2026-09-14

**Repository baseline:** `main@020ce4fbb088bfb175c4b64ae054af2f6425acad` (through merged PR #82).  
**Purpose:** weekly completion/status ledger. This is a snapshot, not a proof source. The live claim taxonomy remains `docs/claim-status-and-source-map-2026-09-13.md`, and theorem statements live in `manuscripts/PSC_balanced_pair_state_2026-09-13.tex` and their cited proof notes.

## Executive status

The shortest current route to pure discrete spectrum has changed materially from the older two-gate finite-BPA architecture.

The present shortest sufficiency chain is

```text
primitive irreducible Pisot
=> bounded discrepancy                                  [PROVED]
=> finite seed-patch overlap graph                      [PROVED]
=> one swap seed has only productive reachable overlaps [OPEN]
=> coincidence density one / dense good set             [PROVED equivalence]
=> pure discrete spectrum                               [IMPORTED: Barge–Štimac–Williams]
```

Thus **overlap productivity for one swap seed is the only open premise on the current shortest PDS route** (manuscript Theorem 5.38 / Open Problem 5.35).

The forward seed-relative occurrence dictionary is no longer part of that
gap: the path–occurrence lemma in
`docs/p1-overlap-seed-growth-bridge-2026-09-17.md` proves that the
multiple-edge graph counts actual residual overlap occurrences per inherited
seed period, including repeated child types and the proper-power collapse
case. The remaining gap is a rigidity theorem excluding a full-growth closed
nonproductive realized component; the accounting lemma alone does not do so.

The ordered affine-cycle identity is now a proved supporting lemma: actual
prefix-grid occurrences satisfy `w'=Mw+q-p`, with exact replayable pump
certificates. It is not a productivity theorem. The determinant-two golden
regression contains a six-edge zero-shift-free cycle inside a productive graph,
showing that recurrence alone cannot exclude the strict branch. The next open
obligation is context-preserving recognizability plus separation in the full
non-unimodular internal representation. The first one-step prefix-suffix
diagnostic already finds equal affine child states with unequal symbolic
addresses, so affine-state equality alone cannot justify pump deletion. The
radius-`m` periodic-patch collar is now exact (`docs/p1-overlap-collar-2026-09-16.md`):
its recursion is proved, the determinant-two graph has separation radius `1`,
and the golden pump lifts to a collared cycle at every tested radius, so
bounded-context equality cannot by itself exclude zero-shift-free recurrence;
the splicing and tiling-dictionary bridge remains open.

This does **not** prove or obsolete the stronger structural problems:

- G1b-2 renewal finiteness and hence finite BPA (G1) remain open;
- concentration (`K2 == 0`) and general wedge productivity (`K2 != 0`) remain open on the finite-BPA/SCC route;
- the realization/coincidence-rank interface remains an open bridge;
- PSC itself remains open.

These are now best regarded as parallel structural programmes rather than prerequisites of the shortest PDS sufficiency route.

## 1. Current proof architecture

### Primary completion route: finite overlap graph, no G1

The load-bearing path is now:

1. **G1b-1 bounded discrepancy — repository-proved.** PR #69 reconstructs a proof from Pisot contracting-prefix geometry without unimodularity, unique decodability, or the withdrawn child/parent contraction estimate.
2. **Seed-patch overlap graph finiteness — repository-proved.** PR #72 shows that bounded discrepancy gives an explicit finite set of exact overlap types for every swap seed, without assuming finite BPA.
3. **Overlap productivity — OPEN.** It suffices to prove that, for every PIP substitution, there exists a swap seed `(ab,ba)` on distinct tile types (legality of `ab` is not assumed) for which every reachable overlap is productive. Proving all seeds or every overlap in the union graph is stronger than necessary. Only that stronger all-vertex hypothesis has the Proposition 5.39(iii) two-sided strong-coincidence consequence and the cited unimodular equivalence with PDS; no one-seed-to-all-vertices implication is claimed.
4. **Coincidence density / dense-good-set equivalence — repository-proved.** Lemma 5.36 identifies reachable-overlap productivity with coincidence density one and density of the eventual-coincidence good set for the periodic swap tiling.
5. **Density to PDS — imported theorem.** PR #77 imports the precise Barge–Štimac–Williams theorem and checks the PIP hypotheses, yielding manuscript Theorem 5.38 without any finite-BPA hypothesis.

PR #82 further sharpens the open gate:

- endpoint-aligned overlaps are exactly the prefix/suffix strong-coincidence cases;
- an overlap hits an offset-zero descendant exactly when an inflated prefix-Parikh difference gives a common sub-tile left endpoint;
- under strong coincidence, productivity reduces to this boundary-hitting condition.

So the immediate theorem target is no longer “prove G1 first.” It is:

> **Exclude a finite reachable child-closed nonproductive set of exact overlap types, at least for one swap seed.**

The strongest current algebraic constraint on a hypothetical bad set is PR #76: its intersection-vector span is a nonzero rational `M`-invariant subspace and therefore has full rank under irreducibility; equivalently the child-count matrix contains the Galois spectrum of `M`. This is a constraint, not yet a contradiction.

### Secondary route A: finite BPA / SCC Producer

The older route remains mathematically important:

```text
bounded discrepancy
=> [OPEN] G1b-2 renewal finiteness
=> finite BPA (G1)
=> finite closed/sink nonproductive obstruction
=> split K2 == 0 / K2 != 0
=> [OPEN] concentration / [OPEN] wedge productivity
=> SCC Producer
=> PDS.
```

G1b-2 and the two carrier exclusions are still open, but none is required by Theorem 5.38 if overlap productivity is proved directly.

### Secondary route B: realization / MEF

The realization track remains a certificate/reformulation programme. Formal recurrent BPA behaviour, global realization, and finite collar survival are distinct. The audited G0–G6 interface obligations remain open. Do not use the realization equivalence as a shortcut around overlap productivity or G1.

## 2. Level 2 and unique decodability

### Established

- Full incidence rank follows from the standing irreducibility/nonzero-determinant setup.
- Unique decodability of the substitution image code and its powers is repository-proved from the defect theorem plus full incidence rank.
- UD is **derived**, not an extra hypothesis.
- G1b-1 bounded discrepancy is repository-proved by the independent reconstruction in PR #69.
- Seed-patch overlap-graph finiteness is repository-proved from that bounded discrepancy in PR #72.

### Still open

**G1b-2 renewal finiteness** remains the exact BPA-finiteness problem: bounded discrepancy does not bound the length or number of labelled first-return states. Exact corpus work contains extremely long reachable states while discrepancy remains small.

The best current G1b-2 target remains structural rather than another norm bound:

```text
realizable labelled first-return word
=> level-scaled contracting / Rauzy address
=> finite return types / uniform discreteness
=> G1b-2.
```

This route must remain explicitly non-unimodular-safe.

### Retired Level-2 shortcuts

Do not revive without a new theorem:

- `UD => bounded total padding`;
- `bounded discrepancy => finite BPA`;
- naive contraction of the zero-sum hyperplane;
- a uniformly short core inside every long state;
- “two-letter renewal is trivial”;
- unlabelled cumulative difference walks determine balanced states.

## 3. Current central gate: overlap productivity

### The theorem target

For each PIP substitution, prove existence of `a != b` such that every exact overlap reachable from the seed overlaps of `(ab,ba)` is productive.

A natural contradiction programme is:

1. assume a minimal finite reachable child-closed nonproductive overlap set `S`;
2. use Corollary 5.34 / PR #76 to obtain full rational intersection-vector rank and the inherited Galois spectrum in the child-count matrix;
3. use the ordered child structure and PR #82 boundary-hitting criterion to constrain all descendants away from offset zero;
4. combine those constraints with Pisot contraction / exact prefix-Parikh dynamics;
5. derive either a boundary hit or an impossible finite child-closed configuration.

The key correction is that a bad set is **not rank-deficient**. Irreducibility forces it to be algebraically rich. Future attacks should exploit that richness rather than look for rank collapse.

### Strong-coincidence boundary

PR #82 proves that Open Problem 5.35 contains the two-sided strong coincidence condition in its endpoint-aligned cases. This is useful as a boundary theorem, not as a proof of the whole gate: an interior overlap may remain the obstruction even when all endpoint-aligned overlaps are productive.

## 4. Computational evidence

All figures below are exact finite-domain evidence unless explicitly labeled theorem-grade.

### Bounded-discrepancy corpus

On the exact 4,554-member ternary PIP short-image corpus:

- maximum reachable discrepancy: `14`;
- longest reachable balanced-pair state reported by the G1b-1 cross-check: `48,020` letters;
- every computed BPA build terminates below its fail-closed cap.

These data support G1 but do not prove G1b-2.

### Overlap corpus

Canonical Mojo and an independent Python oracle agree over all 4,554 specimens:

- graphs built / capped / failed: `4,554 / 0 / 0`;
- total exact overlap vertices: `1,118,850`;
- largest overlap graph: `2,640` vertices;
- specimens with any nonproductive overlap: `0`;
- largest first-coincidence depth: `18`.

After PR #82:

- maximum first left-aligned depth: `17`;
- maximum prefix strong-coincidence depth: `15`;
- maximum suffix strong-coincidence depth: `15`;
- every specimen in the corpus satisfies the tested two-sided strong-coincidence condition.

This is exceptionally strong finite evidence for Open Problem 5.35 but is not a completeness theorem for arbitrary image lengths or alphabet size.

### Finite closed-carrier certificates

The two exact 4,554-corpus carrier certificates remain valid:

- no strict `K2 = 0`, first-`K3` closed component in the certified domain;
- no closed nonproductive recurrent component with nonzero `K2` in that domain.

These remain finite-domain theorems only and do not close concentration or general wedge productivity.

## 5. Corrections and status changes to preserve

1. **G1 is not a prerequisite of the shortest PDS route.** It remains open and important, but PR #77 removes it from the overlap-density sufficiency theorem.
2. **The density bridge is no longer open.** It is an imported theorem with hypotheses audited against the PIP setting.
3. **The overlap-rank heuristic was reversed.** A child-closed nonproductive overlap set has full rational carrier rank, not deficient rank.
4. **The finite-stage good sets are not nested.** The corrected density proof uses that later stages can lose only finitely many subdivision points from an earlier good set.
5. **Endpoint alignment is a strong-coincidence boundary case, not the whole problem.** Strong coincidence does not by itself silently prove arbitrary interior overlap productivity without the stated hitting argument.
6. **G1b-2 and concentration are no longer completion-critical for the shortest route.** They remain independent, worthwhile theorem targets.
7. **Source status has been resolved claim by claim.** Missing historical v16 is archival metadata; G1b-1 and degree-two carrier span have current repository proofs; concentration and realization are open mathematical obligations, not source-pending theorems.

## 6. Attribution and hypothesis firewall

Every future proof/PR should explicitly check the following.

### Independence assumptions

- Tile-length `Q`/`Z` independence must be **derived from irreducibility/cyclic-vector structure**, not added as a standing assumption.
- Unique decodability must remain **derived from full incidence rank**, not assumed separately.
- Finite injectivity, prefix/suffix permutations, boundary injectivity, or any similar endpoint property is extra structure unless separately derived.

### Unimodularity assumptions

- Do not assume `|det M| = 1` in a general PSC result.
- Do not import a converse or Rauzy theorem whose proof is unit-only without marking the resulting theorem as restricted.
- A G1b-2 internal-space construction may require non-Archimedean/profinite coordinates; a purely Euclidean model may silently restrict the theorem.
- Do not treat the stable projection of `Z^d` as a discrete lattice in general.

### Realization and computation

- Formal recurrence is not global realization.
- A finite collar bound or finite census is not self-certifying; theorem-grade completeness needs an independent bound.
- Capped or incomplete catalogues must fail closed and retain replayable countermodels.

### Literature roles

Keep the two-letter and overlap literature separated by exact statement:

- Barge–Diamond: strong coincidence / eventually coincident pair results in their stated scope;
- Sirvent–Solomyak: balanced-pair / overlap relation and two-symbol spectral results in their stated scope;
- Barge–Štimac–Williams: dense eventual coincidence implies PDS in the imported one-dimensional Pisot-family setting used by Theorem 5.38;
- Hollander–Solomyak: cite only for the exact balanced-pair statement actually imported.

No imported theorem should acquire stronger hypotheses or conclusions merely because adjacent papers use similar terminology.

## 7. Prioritized completion ledger

| Priority | Obligation | Status | Evidence that would close it |
| --- | --- | --- | --- |
| **P0** | Keep claim/status surfaces synchronized | ongoing | claim map, manuscript, proof ladder, conjecture ledger, README and TLA agree on the same dependency boundary |
| **P1** | **Seedwise overlap productivity (Open Problem 5.35)** | **OPEN — current shortest-path gate** | theorem excluding a reachable child-closed nonproductive overlap set for at least one swap seed (legality not assumed) of every PIP substitution |
| **P2** | Minimal bad-set contradiction | **OPEN — best immediate subproblem** | use full rank + child-count spectrum + ordered descendants + boundary-hitting to force coincidence |
| **P3** | G1b-2 renewal finiteness | **OPEN — stronger structural theorem, not required by Theorem 5.38** | non-unimodular-safe finite-return / pump-normal-form theorem for realizable labelled first-return words |
| **P4** | General concentration (`K2=0`) | **OPEN — alternative finite-BPA route** | uniform exclusion of strict zero-wedge carriers |
| **P5** | General wedge productivity (`K2!=0`) | **OPEN — alternative finite-BPA route** | theorem converting the full-wedge carrier constraints into productivity |
| **P6** | SCC Producer assembly | **conditional / secondary** | G1 plus both carrier exclusions, or derive it from the stronger overlap theorem |
| **P7** | Realization/coincidence-rank bridge | **OPEN — secondary certificate route** | discharge audited G0–G6 obligations without assuming the desired realization statement |

## 8. Highest-value next proof tasks

The next research PR should target **P1/P2**, not another fixed-size SCC sieve.

Recommended sequence:

1. define a minimal reachable child-closed nonproductive overlap component/set with exact seed provenance;
2. write the exact child-count/intersection-vector intertwining and identify what full rank forces on a minimal bad set;
3. split endpoint-aligned and genuinely interior overlap types using Proposition 5.40;
4. search for an invariant or monotone obstruction built from ordered prefix-Parikh data that cannot survive in a finite bad set;
5. encode any finite diagnostic or countermodel extractor in canonical Mojo first, with an independent Python oracle only where useful;
6. preserve the independence/unimodularity firewalls above.

A proof at this level would close the **only remaining premise of the current shortest PDS route**. G1b-2, concentration, wedge productivity, and realization should continue in parallel because they explain stronger structure, but they should no longer displace overlap productivity as the completion priority.
