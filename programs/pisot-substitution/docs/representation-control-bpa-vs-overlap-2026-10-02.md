# BPA versus overlap representation-control audit — 2026-10-02

**Status:** corrected four-specimen finite evidence and research guardrails.
The canonical replay does **not** support this note's original attribution of
the quantitative claims to representation artifacts. It does not change
theorem status, close Open Problem 5.35 / issue #84, or supply a proved claim
for `claim_governance.toml`. The live proof architecture remains the one in
`docs/conjecture-ledger.md`, `docs/p1-two-route-map-2026-10-01.md`, and
`docs/claim-status-and-source-map-2026-09-13.md`.

## 1. Question and correction provenance

A proposed Pisot-substitution / complex-dynamics cross-walk suggested:

- **C1:** a universal productivity-margin lower bound `margin >= 1 - gamma`,
  where `gamma = 1 - |second conjugate modulus|`;
- **C2:** determinant size `|det M|` drives exponential balanced-pair automaton
  state-count growth;
- **C3:** determinant size sets a productivity-margin level.

The original PR #192 note at
`e1ff17c3e27d9e2956399e7ff413444c7f04ed1d` reported BPA counts
`8, 606, 626, 2308` and overlap counts `9, 19, 39, 42`. The P1 review correctly
identified that canonical Tribonacci overlap counts are 29, already pinned in
`kernel/tests/test_oa_overlap_types.mojo` on
`main@4339c0eff04531cf98529c85e8defdecae1a2d03`.

No graph constructor, seed convention, quotient map, equivalence relation,
transition multiplicity, or executable source was supplied for the original
table. The canonical replay below also changes **every BPA count**. There is
no demonstrated legitimate reduced quotient behind the old numbers; they are
excluded from evidence rather than assigned an invented quotient. A future
reduction must define its state equivalence, induced transitions and target
predicate, and test the claimed projection against the canonical graph.

This is a regression repair of already literature-reviewed graph contracts,
not a new universal-invariant experiment. Their literature/hypothesis review
is in `docs/seed-patch-to-literature-overlap-audit-2026-09-13.md` and
`docs/overlap-finiteness-and-coincidence-density-2026-09-13.md`.

## 2. Precisely defined replay

The substitution keys use alphabet `{0,1,2}`; `a/b/c` lists the images of
0, 1, 2 in that order. All four pass `psc.pisot.is_pip`, the exact primitive,
irreducible Pisot incidence screen. Counts include coincidence vertices.

- **BPA types:** `psc.bpa.build`, starting from all unordered two-letter swap
  seeds, decomposing at Parikh zero returns, and normalizing each pair under
  top/bottom exchange. Repeated children remain transition multiplicities;
  only distinct normalized pairs contribute to the vertex count.
- **Swap-seed overlap types:** `build_seed_overlap_graph_from_tables` in
  `psc.overlap_seed_patch`, starting from the aligned finite patches `(ab,ba)`
  for each `a < b`. A vertex is the **ordered** pair of tile types and its exact
  offset in the cubic Perron field. Retain strict interior overlaps and close
  under the canonical exact inflation. No tile-pair-only, SCC, or orientation
  quotient is applied. Coincidences are terminal as in the existing builder.
- **Finite-prefix OA types:** `psc.oa_overlap_types.type_inclusion_report`
  uses the least prolongable `(q,c)` in increasing power/letter order, a prefix
  `u` of the fixed point of `sigma^q` of length **at least 6000**, and `k = 1`.
  Level-zero types come from `(u,S^k u)` inside `oa_window`, whose geometric
  exclusion bound is decided exactly. Their closure uses the same overlap
  inflation kernel. A fixed-point iteration can overshoot the requested length;
  the actual lengths below are part of the reproducible input.

The state cap is 20000 for each graph. Any cap, undersized enumeration prefix,
failed PIP screen, or exact arithmetic failure refuses a completed row.
An uncapped OA closure still starts with an **uncertified finite factor set**:
it is not a certificate that all types of the infinite literature graph
`G_O(T,x(W))` have been found. Nor are swap-seed graphs identified with that
complete graph. The two initial objects must stay distinct even when counts
or sampled type sets agree.

Replay with the pinned `kernel/pixi.lock` toolchain:

```sh
cd kernel
pixi run --locked mojo run -I . representation_control.mojo
pixi run --locked mojo run -I . tests/test_representation_control.mojo
```

The canonical entry point is `kernel/representation_control.mojo`; its thin
adapter is `kernel/psc/representation_control.mojo`. The regression pins every
count and input field below, the noncoincidence type differences, productivity,
and independent BPA, seed-overlap and OA cap refusals. The existing exact
Python oracle independently reproduces the counts and type differences; it
remains secondary to Mojo. The replay uses Mojo `1.1.0.dev2026090805` and the
unchanged overlap/BPA kernels from the review's cited main commit.

## 3. Corrected finite evidence

| substitution key | det | BPA types | swap-seed overlap types | finite-prefix OA types |
| --- | ---: | ---: | ---: | ---: |
| `01/02/0` | `+1` | `6` | `29` | `29` |
| `11/02/002` | `+2` | `305` | `1646` | `1646` |
| `21/22/102` | `+2` | `327` | `1245` | `1246` |
| `022/20/11` | `+2` | `1168` | `1916` | `1914` |

In the next table, the set differences count **noncoincidence** types only,
as defined by `type_inclusion_report`; they are not differences of the total
vertex counts above. Every listed graph is uncapped and every vertex has a
path to a coincidence.

| substitution key | q | c | actual prefix length | window | OA minus seed | seed minus OA | BPA/seed/OA all productive |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `01/02/0` | 1 | 0 | 10609 | 4 | 0 | 0 | True/True/True |
| `11/02/002` | 2 | 0 | 15546 | 3 | 1 | 1 | True/True/True |
| `21/22/102` | 2 | 1 | 8996 | 3 | 0 | 0 | True/True/True |
| `022/20/11` | 1 | 0 | 10791 | 4 | 0 | 2 | True/True/True |

**What follows:** canonical raw graph counts differ between these defined
presentations. The earlier small-overlap explanation is reversed in all four
rows: swap-seed overlap graphs have **more** vertices than the normalized
BPA graphs. For `11/02/002`, even equal overlap counts conceal one missing
noncoincidence type in each direction. No general graph equality or
seed-to-literature coverage theorem follows from the table.

**What does not follow:** the table does not show that determinant correlation
disappears under overlap representation, or that BPA growth is a representation
artifact. All three determinant-2 specimens have larger overlap graphs than
Tribonacci, too. Four selected specimens, only two determinant magnitudes,
and no specified growth family cannot establish or refute an exponential law.
The varying counts at determinant 2 show only that determinant alone does not
determine these raw counts on this sample.

No spectral/productivity-margin calculation is performed by this replay.
The original positive-BPA/zero-OA Tribonacci assertion and the claims of
overlap margins above 1 have no supplied matrix, weights, target deletion,
normalization, or executable provenance. They are excluded from evidence.
The geometric sign margins used to decide strict interior overlaps are a
different object and must not be substituted for the proposed statistic.

## 4. Disposition of the proposed claims

| Claim | Corrected disposition | Permitted use |
| --- | --- | --- |
| C1: `margin >= 1 - gamma` | **Not established or refuted here.** Original representation-artifact rejection unsupported. | Requires a precise statistic and independently replayable counter-calibration before any conclusion. |
| C2: determinant-driven exponential state count | **Not established or refuted here.** Original small-overlap argument fails replication. | The counts are algorithmic diagnostics; no dynamical-invariant or PSC evidence is supplied. |
| C3: determinant-driven margin level | **Not established or refuted here.** No canonical margin comparison supplied. | No theorem or novelty use on this evidence. |
| BPA / Yoccoz-tableau quantitative shadow | **No quantitative correspondence established.** | Structural analogy only, pending defined objects and an invariance/transfer argument. |

These informal C1/C2/C3 labels are local to the cross-walk proposal, not
identifications with other repository claims bearing similar labels. Their
original proposed retirement is withdrawn for lack of verified evidence;
this does not promote them. No governed claim is retired or promoted.

## 5. Relation to the live proof architecture

The correction supplies no new proof-priority evidence. The existing route
and its status boundaries remain:

```text
primitive irreducible Pisot
=> bounded discrepancy                                  [PROVED]
=> finite seed-patch overlap graph                      [PROVED]
=> one swap seed has only productive reachable overlaps [OPEN]
=> coincidence density one / dense good set             [PROVED conditional implication]
=> pure discrete spectrum                               [IMPORTED theorem under its hypotheses]
```

The finite-BPA route, G1b-2, SCC Producer and the overlap-productivity route
remain live research objects. The correction neither closes their forcing
obligations nor supplies a counterexample to them. In the overlap route the
proof-facing obstruction remains a finite child-closed irreducible
nonproductive overlap SCC, split into aligned and strict-zipper branches.
Productivity of these four computed graphs is finite evidence only.

## 6. Cross-walk and future guardrails

Retain the complex-dynamics cross-walk as a structural analogy. Use
"cross-walk", "dictionary", or "analogy schema" unless objects and morphisms
are explicitly defined; no functor or quantitative rigidity correspondence
is constructed here.

1. State the seeds, orientation convention, coincidence treatment, quotient,
   and transition multiplicities for every reported graph statistic.
2. Raw vertex counts compare implementations/presentations. Agreement or
   disagreement is not itself an invariance theorem or a dynamical obstruction.
3. Specify any proposed drainage/spectral margin's matrix, weights, deletion
   rule, normalization, and hypotheses before comparing it across graphs.
4. A finite prefix and an uncapped inflation closure do not certify global
   factor coverage. Productivity comparisons require the appropriate seed and
   realization/transfer statement, not just equal totals.
5. A failed replay invalidates the evidence it was meant to provide. It does
   not automatically refute the proposed mathematical claim or justify its
   retirement.
6. Neither representation diagnostics nor negative/guardrail results change
   the status of Open Problem 5.35, G1b-2, SCC Producer, or PSC.

A useful next investigation would define maps between `B_sigma`, seed-patch
graphs, literature graphs and explicit reduced quotients, and then classify
which specified observables descend through those maps. This note does not
claim that such maps or an invariant margin already exist.
