# Conjecture ledger

The machine-checked dependency form is `proof/tla/Ledger.tla`. This prose ledger distinguishes repository proofs, imported theorems, finite-domain theorems, open gates, open bridges, empirical evidence, and retired claims. The concise status/source index is `docs/claim-status-and-source-map-2026-09-13.md`; the current architecture is `docs/current-proof-architecture-2026-09-14.md`; the live completion priorities are `docs/research-roadmap-2026-09-21.md`; the latest merged weekly snapshot is `docs/completion-ledger-2026-10-02.md`.

## Executive status — one shortest-path gate, several stronger parallel programmes

The Pisot Substitution Conjecture remains open.

The **shortest current PDS sufficiency route** has one open premise:

| Route item | Status | Load-bearing statement |
| --- | --- | --- |
| G1b-1 bounded discrepancy | **Repository-proved** | all reachable swap-state prefix-difference walks are uniformly bounded |
| Seed-patch overlap graph finiteness | **Repository-proved** | every swap seed has a finite exact overlap graph |
| **Seedwise overlap productivity** | **OPEN — current critical gate** | for every PIP substitution, one swap seed on distinct tile types has only productive reachable overlaps |
| Coincidence-density / dense-good-set equivalence | **Repository-proved** | productivity gives density one / dense eventual coincidence |
| Dense eventual coincidence to PDS | **Imported theorem** | Barge–Štimac–Williams, hypotheses audited in the manuscript |

The periodic word `ab` used in this route need not be a legal substitution-language factor. Therefore manuscript Theorem 5.38 proves PDS from overlap productivity **without G1 and without a seed-legality hypothesis**.

Three stronger programmes remain open in parallel:

1. **G1 / BPA finiteness:** G1b-2 renewal finiteness.
2. **Finite-BPA SCC route:** concentration (`K2 == 0`) and wedge productivity (`K2 != 0`).
3. **Realization / coincidence-rank route:** audited open bridge obligations G0–G6.

These are not hidden assumptions of the primary overlap route.

## A. Stable base

### Full incidence rank and unique decodability

**Status: repository-proved.** Full incidence rank follows from the standing irreducible/nonzero-determinant setup. The defect theorem gives unique decodability of substitution images, and the same holds for powers because `det M_{sigma^r} != 0`.

UD is derived, not assumed.

### G1b-1 bounded discrepancy

**Status: repository-proved by reconstruction (PR #69).** Every reachable state has bounded prefix-difference discrepancy, using primitivity and the Pisot spectrum only. It does not assume unimodularity or UD and does not imply finite BPA.

Finite calibration over the 4,554-member corpus reports maximum discrepancy `14` and a reachable state of length `48,020`.

## B. Primary open gate — overlap productivity

### Seed-patch overlap finiteness

**Status: repository-proved (PR #72).** Bounded discrepancy yields an explicit finite coordinate bound on exact overlap types reachable from the swap seeds. This does not require G1.

### Overlap productivity / Open Problem 5.35

**Status: OPEN.** It is sufficient to prove the one-seed form:

> For every PIP substitution there exist distinct letters `a != b` such that every exact overlap reachable from the seed overlaps of `(ab,ba)` is productive.

All-seed or all-vertex productivity is stronger than manuscript Theorem 5.38 requires. (Manuscript Open Problem 5.35 is stated in the all-vertex form; the surfaces use its number for the one-seed form.)

**Keep the gates distinct.** The one-seed statement above is sufficient for Theorem 5.38. The stronger all-vertex Open Problem 5.35 contains the two-sided strong coincidence condition of Arnoux–Ito (Proposition 5.39(iii)); under strong coincidence its every-vertex form is the Corollary 5.41 prefix-Parikh hitting problem; and for unimodular `sigma` the Barge–Kwapisz converse (Cor. 9.4 / Prop. 17.2, cited in the manuscript, not imported) makes all-vertex productivity equivalent to PDS. No one-seed-to-all-vertices implication is claimed.

**Latest supporting lemma.** Ordered child occurrences satisfy the exact
affine recurrence `w'=Mw+q-p`, and every replayed occurrence-labelled cycle
satisfies its iterated pump identity. This is a finite algebraic certificate,
not an exclusion theorem. A productive non-unimodular regression graph has a
six-edge zero-shift-free pump, so the open step must use child closure,
nonproductivity, recognizability context, and the complete (possibly
non-Archimedean) internal representation.

The first context checkpoint is also finite and negative: one affine child
state in the determinant-two regression has two unequal one-step paired
prefix-suffix addresses. This rules out treating `(top,bottom,w)` as a
complete symbolic pump state. The radius-`m` collar is now exact
(`docs/p1-overlap-collar-2026-09-16.md`): on that graph one letter of context
resolves every occurrence's ancestry, and the golden pump lifts to a collared
cycle at every tested radius, so bounded-context equality alone cannot exclude
such pumps. Neither supplies a recognizability radius for the periodic patches
nor the splicing/dictionary bridge to the tiling, which remain open.

### Full-rank constraint on a bad set

**Status: repository-proved (PR #76).** For a nonempty child-closed set `S` of noncoincidence overlaps, the intersection-vector row span is a nonzero rational `M_sigma`-invariant subspace. Irreducibility therefore forces full rank; the child-count matrix inherits the Galois spectrum of `M_sigma`.

This corrects the former rank-deficiency heuristic. Full rank is a constraint, not a contradiction.

### Closed irreducible bad-overlap normal form

**Status: repository-proved supporting reduction (PR #88; manuscript Proposition 5.43).** If a reachable overlap is nonproductive, finiteness and forward closure of nonproductivity allow passage to a finite child-closed irreducible recurrent SCC `S`. Existing mass balance and the full-rank theorem then give

```text
PF(N_S) = beta,
N_S V_S = V_S M^T,
rank_Q(V_S) = |A|,
spec(M) subset spec(N_S).
```

The graph-theoretic residual-SCC extraction is standard overlap-algorithm machinery; the useful repository-specific normal form is its combination with unconditional swap-overlap finiteness and the full-rank/boundary constraints.

### Endpoint, boundary hitting, and the zipper dichotomy

**Status: repository-proved supporting structure (PRs #82 and #88; manuscript Propositions 5.39–5.41 and 5.44, Lemma 5.45).** PR #82 proves the endpoint strong-coincidence dictionary and exact boundary-hitting criterion. PR #88 adds:

- if a bad SCC contains `(i,j,0)`, the pair `{i,j}` is explicitly not eventually coincident;
- otherwise no top substituted child start ever equals a shifted bottom child start, and each child refinement is a strict monotone prefix-grid **zipper** in which only one side advances at each boundary.

Thus the open gate has two precise branches:

1. **aligned obstruction:** eliminate/propagate the exposed non-eventually-coincident pair;
2. **strict-zipper obstruction:** use the ordered boundary-source sequence, full rank, and Pisot prefix geometry to force a hit or contradiction.

Do not collapse the zipper immediately to the unordered child-count matrix: that discards exactly the order information not constrained by full rank.

**Contracting lower bound (2026-09-15, PR #87, Proposition 5.42).** A hit at level `m` forces `|varsigma(t)| <= C_varsigma sum_{s<=m} |varsigma(beta)|^{-s}` for every contracting embedding, decided exactly in `Q(beta)`; on the corpus this bound is at most 8 while the hitting depth reaches 17, leaving a gap of up to 14 inflations that this magnitude bound does not explain (the gap includes the slack of the bound; no further attribution is drawn). It constrains the difficulty of the gate; it adds no dependency edge.

### Coincidence density and PDS

**Status: repository-proved + imported theorem (PR #77).** Lemma 5.36 supplies the repository equivalence between overlap productivity, coincidence density one, and a dense good set. Barge–Štimac–Williams supplies the dense-eventual-coincidence-to-PDS implication. The finite-stage good sets are not nested; the corrected proof uses only finite subdivision-point losses between stages.

## C. Parallel programme — G1 / renewal finiteness

### G1b-2

**Status: OPEN.** Since G1b-1 is proved, G1b-2 is the exact missing theorem for finite BPA.

Required statement: only finitely many realizable irreducible balanced pairs occur inside the established discrepancy bound.

A bounded local difference alphabet does not bound labelled first-return data. The intended structural route remains:

```text
realizable labelled first-return words
=> level-scaled contracting/Rauzy address
=> finite local return types / uniform discreteness
=> G1b-2
=> G1.
```

This programme is no longer completion-critical for Theorem 5.38, but it remains the canonical route to the stronger finite-BPA theorem.

### All-seed overlap productivity

**Status: OPEN.** Every overlap reachable from every swap seed is productive. This is the all-vertex form of manuscript Open Problem 5.35 and is stronger than the one-seed gate of Theorem 5.38.

### Overlap-depth route to finite BPA

**Status:** Conditional theorem (manuscript Proposition 5.46; `docs/bpa-termination-by-overlap-depth-2026-10-02.md`, Proposition 1).

```text
all-seed overlap productivity            [OPEN]
+ finite seed-patch overlap graph         [PROVED]
=> every reachable state has geometric length <= 2 beta^D ell_max
=> G1.
```

`D` is the largest first-coincidence depth of the graph. The proof uses that balanced cuts are simultaneous tile boundaries (`Q`-independence of `ell`) and that every overlap at level `n - D` has a coincident descendant inside its `beta^D`-scaled region; it needs no realization hypothesis. G1 therefore follows from either G1b-2 or all-seed overlap productivity.

### All-seed strict-zipper exclusion

**Status: OPEN.** No closed nonproductive strict-zipper set (manuscript Proposition 5.44(iii)(b): no offset-zero vertex) is reachable from any swap seed. This is the all-seed form of the strict-zipper branch of Open Problem 5.35 (issue #139); it is implied by all-seed overlap productivity and does not involve the strong-coincidence branch (issue #138).

### Half-coincidence route to finite BPA

**Status:** Conditional theorem (manuscript Proposition 5.47; `docs/bpa-termination-by-overlap-depth-2026-10-02.md`, Proposition 4 and Corollary 5).

```text
all-seed strict-zipper exclusion          [OPEN]
+ finite seed-patch overlap graph         [PROVED]
=> every reachable overlap has an offset-zero descendant within K' levels
=> every reachable state has geometric length <= 2 beta^K' ell_max
=> G1.
```

The proof of the overlap-depth route needs a coincidence only for its common vertex; an offset-zero descendant supplies one, and common vertices persist under inflation. G1 therefore follows from G1b-2, from all-seed overlap productivity, or from all-seed strict-zipper exclusion alone.

Consequently finiteness needs only the strict-zipper branch of the obstruction
problem (issue #139). The strong-coincidence branch (issue #138) is needed for
productivity and for pure discrete spectrum, but not for G1.

### PDS implies G1

**Status: repository-proved** (manuscript Proposition `prop:PDS-implies-G1`;
ledger `PDSImpliesRepoG1`, the Theorem S route; independently audited
2026-10-04, **human review pending** — `docs/side-notes-ledger.md` §7).

```text
pure discrete spectrum
=> no reachable strict zipper from any swap seed
   (a zipper gives a Phi^r-fixed pair in one MEF fibre sharing no tile,
    hence coincidence rank >= 2)          [IMPORTED: Barge coincidence rank]
=> G1, by the half-coincidence route above.
```

This is the direction the programme lacked. G1 is therefore a **necessary**
condition for PDS, not an artefact of the balanced-pair method: any proof of
PSC makes G1 true, and a counterexample to G1 would refute PSC. The
realization step is legitimate rather than a formal-recurrence shortcut: it
builds `Phi^r`-fixed tilings from *interior occurrences*, whose patches are
allowed for `sigma`, and takes integrality of the offset from the cycle
equation (manuscript Lemma 5.45) rather than by assumption.

The imports assume neither unimodularity nor irreducibility
(`docs/coincidence-rank-imports-literature-gate-2026-10-04.md`). One soft
link remains recorded there: the Barge item used is stated in a published
introduction's summary, whose own proofs that gate did not read.

**Since 2026-10-05 the repository side of this proof is in the closure, not
only in its prose citation.** Three inputs are ledger nodes:
`ReturnModuleFullRank` (Theorem R), `PeriodicPairOneFibre` (Proposition F,
which needs it) and `StrictZipperPeriodicPairForm` (Theorem B with Lemma C and
Corollary B′), so `PDSImpliesRepoG1` now requires all three alongside
`CoincidenceRankFibreTheorems` and its dependency closure is still complete —
no open premise enters. Manuscript Proposition 5.47 stays a prose citation on
purpose: the `G1HalfCoincidenceRoute` node bundles the half-coincidence bound
with its *open* all-seed premise, and what pure discrete spectrum supplies here
is exactly that premise, through `StrictZipperPeriodicPairForm`. Requiring the
bundled node would therefore have made an unconditional implication read as
conditional on an open gate.

### PDS implies seedwise termination

**Status: repository-proved** (manuscript Theorem `thm:seedwise`; ledger
`PDSImpliesSeedwiseTermination`, using the imported
`StrongCoincidenceFromPDS`; same review status as above).

PDS implies that the balanced-pair algorithm terminates with coincidence from
**every** seed `(ab, ba)`, legal factor or not. This answers in full what the
manuscript formerly carried as Open Problem 4.24, so the repository's
all-seed graph is covered rather than one convenient seed. Dated notes that
still call 4.24 open are history, not status.

## D. Parallel programme — SCC Producer under G1

Assume G1. Then nonproductivity reduces to a finite closed/sink recurrent noncoincident carrier.

### Concentration / aux-B

**Status: OPEN, not source-pending.** In the current cubic wedge dichotomy this is equivalent to excluding strict components with `K2 == 0`.

### Wedge productivity

**Status: OPEN, not source-pending.** Equivalent to excluding strict components with `K2 != 0`. The degree-two carrier-span implication is repository-proved, but full rational wedge span alone does not force productivity.

### Exact bounded-domain carrier results

Two fail-closed Mojo certificates give finite-domain theorems on the exact 4,554-member short-image corpus:

- no strict `K2=0`, first-`K3` component;
- no closed nonproductive recurrent nonzero-`K2` component.

Neither is a uniform theorem.

## E. Supporting structural programme

The C4/endpoint/defect hierarchy remains useful and theorem-grade where its notes say so. It includes sink-SCC reduction, endpoint synchronization, Barge–Diamond endpoint elimination, Parikh and signed defect intertwiners, orientation monodromy, higher-defect spectral sieves, ordered degree-two factorization, and recognizability/ancestry machinery.

The one-way chain

```text
C4 => C3-local => C2 => SCC Producer
```

remains a valid sufficiency chain. It is not the current shortest completion route.

## F. Realization / MEF bridge

**Status: OPEN bridge.** The source audit decomposes the former realization/coincidence-rank equivalence into obligations G0–G6.

Do not identify formal recurrence, global realization, and finite collar survival. Finite collar death remains evidence until an independent completeness bound is proved.

## G. Exact finite evidence

On the 4,554-member ternary PIP short-image corpus:

- all finite-certificate BPA builds terminate below their fail-closed caps;
- maximum reachable discrepancy: `14`;
- longest reachable state in the G1b-1 cross-check: `48,020`;
- seed-patch overlap graphs built / capped / failed: `4,554 / 0 / 0`;
- total overlap vertices: `1,118,850`;
- largest overlap graph: `2,640`;
- specimens with a nonproductive overlap: `0`;
- maximum first-coincidence depth: `18`;
- maximum first left-aligned depth: `17`;
- maximum prefix and suffix strong-coincidence depths: `15`;
- contracting lower bound on the hitting level (Proposition 5.42): at most `8`, excess of the hitting depth over it at most `14`;
- every specimen satisfies the tested two-sided strong-coincidence condition.

These results strongly guide proof search but do not establish a universal image-length/alphabet-size completeness bound.

## H. Independence / unimodularity / realization firewall

The final theorem must preserve all of the following.

- **Swap-patch legality is not an assumption.** Do not require `ab` to occur in the substitution language merely because the periodic comparison patch uses tile types `a,b`.
- **Tile-length independence is derived.** Do not add rational/integer independence as a separate assumption.
- **UD is derived.** Do not make unique decodability a standing hypothesis.
- **FI/boundary injectivity is extra.** It cannot enter the general proof silently.
- **No unimodularity leak.** Do not import `|det M|=1` through a converse or internal-space construction without marking the result restricted.
- **No false stable lattice.** Do not treat `pi_s(Z^A)` as a discrete lattice in general.
- **No realization shortcut.** A formal recurrent component is not automatically globally realized.
- **No computational self-certification.** A finite corpus or collar radius becomes universal only with an independent completeness theorem.

## I. Retired claims / routes

Do not use as completion arguments:

- predecessor contraction proving finite BPA;
- `UD => bounded total padding`;
- bounded discrepancy alone implying finite BPA;
- naive zero-sum-hyperplane contraction;
- uniformly short core in every long state;
- trivial two-letter renewal;
- unlabelled difference walks determining balanced states;
- rank-deficiency of a child-closed bad overlap set;
- nested finite-stage good sets in the coincidence-density proof;
- generic boundary-smallness to infer `PF(N_S)<beta` for a residual real-overlap SCC: the full expansion spectral radius is precisely the hard noncoincidence case in the potential-overlap algorithm.

## J. Source/provenance status

The missing historical v16 manuscript remains provenance metadata, not a live proof prerequisite.

- G1b-1 is independently repository-proved.
- Degree-two carrier span is independently repository-proved.
- Concentration is an open mathematical gate, not a missing-source theorem.
- The realization chain is an open bridge, not a missing-source theorem.
- The P0 manuscript hypothesis/attribution corrections have been implemented in the live manuscript.

## K. Priority ledger

1. **P0 — status synchronization.** Keep manuscript, claim/source map, proof ladder, this ledger, README and TLA comments consistent.
2. **P1 — seedwise overlap productivity.** Current critical theorem target.
3. **P2 — aligned/strict-zipper contradiction.** Use PR #88's normal form with full rank, exact ordered boundaries, and prefix-Parikh/Pisot geometry.
4. **P3 — G1b-2.** Stronger finite-BPA theorem; preserve non-unimodular generality.
5. **P4 — concentration and wedge productivity.** Alternative finite-BPA SCC route.
6. **P5 — realization bridge.** Secondary certificate route.

The project should not spend the primary proof budget on another fixed-size SCC sieve unless it supplies a uniform theorem feeding P1.
