# Claim status and source map

**Status date:** 2026-10-08
**Historical baseline for earlier rows:** `main@b661f50` (through merged PR #212). The box/leftmost reconciliation against `main@33a1b8b` is recorded in `docs/proof-ledger-reconciliation-2026-10-08.md`; earlier rows retain their historical audit. The 2026-10-02 rows (Propositions 5.46/5.47) and the 2026-10-04 rows (`PDS` implies G1 and seedwise termination) are included; the status-audit record is `docs/audit-2026-10-04.md`.

This is the short authoritative index for deciding whether a mathematical statement is proved, imported, computationally certified on a finite domain, conditional, or open. It supplements the full exposition in `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`, the dependency structure in `docs/proof-ladder.md`, and the current architecture in `docs/current-proof-architecture-2026-09-14.md`.

The absence of a historical file and the absence of a proof are different conditions. A result can cease to be source-pending because it has been independently reconstructed, or because audit shows that it is an open conjectural obligation rather than a theorem awaiting recovery.

## Status vocabulary

| Tag | Meaning | Permitted use |
| --- | --- | --- |
| **Repository-proved** | A self-contained proof is present on `main`, with hypotheses exposed and review history preserved. | May be used on the no-assumption proof path under its stated hypotheses. |
| **Imported theorem** | An external or historical theorem is present with an exact statement and source. | May be used only with the imported theorem's hypotheses and scope. |
| **Historical restricted theorem** | Exact historical proof material is preserved, but proves only a special case. | May be cited for that case; it may not be generalized to a carrier theorem. |
| **Finite-domain theorem** | An exact, reproducible, fail-closed computation exhausts a stated finite domain. | May be asserted only for that domain. |
| **Conditional theorem** | The implication is proved once explicitly named open premises are assumed. | May not discharge its premises. |
| **Open conjectural gate** | The statement is a live mathematical obligation. No missing source is expected to close it automatically. | Must remain unavailable to the no-assumption proof path. |
| **Open bridge** | A proposed equivalence or transfer has named unproved interface obligations. | May organize research, but its endpoints may not be substituted for each other. |
| **Empirical evidence** | A bounded experiment has no independent completeness theorem. | Supports prioritization only. |
| **Retired claim** | The argument is false, incomplete, or superseded. | Must not be used. |
| **Historical source missing** | A reported document was not found in reachable history. | Metadata only unless a current proof still depends on it. |

## Live claim map

| Claim | Current status | Exact source | Scope and firewall |
| --- | --- | --- | --- |
| Full incidence rank from `det M_sigma != 0` | **Repository-proved** | State-of-program manuscript, standing algebraic setup | Does not assume unimodularity. |
| Unique decodability of substitution images and powers | **Repository-proved** | Manuscript Theorem 2.8 and power corollary | Derived from full incidence rank; not a standing hypothesis. |
| G1b-1 bounded discrepancy | **Repository-proved by reconstruction** | `sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md`; manuscript Theorem 4.4; PR #69 | Bounds the prefix-difference walk, not state length; does not imply G1. |
| G1b-2 renewal finiteness | **Open conjectural gate** | Manuscript Level-2 open problem; issue #44 | Equivalent to G1 after G1b-1; must be non-unimodular-safe; **not required by Theorem 5.38**. |
| Finite BPA, G1 | **Open conjectural gate** | Manuscript Propositions 4.11, 5.46 and 5.47 and open-problem list | Stronger structural theorem; no longer a premise of the shortest PDS route. Four sufficient premises: G1b-2, all-seed overlap productivity (overlap-depth route), all-seed strict-zipper exclusion alone (half-coincidence route), or formal productivity (box-automaton route). Also **necessary**: implied by PDS, see the two rows below. |
| All-seed overlap productivity implies finite BPA | **Conditional theorem** | Manuscript Proposition 5.46; `docs/bpa-termination-by-overlap-depth-2026-10-02.md`, Proposition 1 | If every overlap reachable from every swap seed is productive, with largest first-coincidence depth `D`, every reachable balanced-pair state has geometric length at most `2 beta^D ell_max`, so `B_sigma` is finite. Balanced cuts are simultaneous boundaries by `Q`-independence of `ell`; no realization hypothesis is used. Its only open premise is all-seed overlap productivity. |
| Sink-SCC reduction under G1 | **Conditional theorem** | `docs/sink-scc-reduction.md`; manuscript finite-carrier section | Requires finite BPA to extract a finite recurrent obstruction. |
| Degree-two carrier span / wedge dichotomy | **Repository-proved by reconstruction** | Manuscript Proposition 5.20; `docs/galois-aux-b-source-resolution-2026-09-13.md`; PR #68 | Nonzero `K2` gives full rational wedge span; this does not prove productivity. |
| Historical degree-three dominant capture | **Historical restricted theorem** | `archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md`, §§8–10 | Applies only to the explicitly certified seeds; SCC transfer remains restricted. |
| Concentration / aux-B | **Open conjectural gate, not source-pending** | Manuscript open problem; issue #43 | Alternative finite-BPA route: exclusion of strict components with `K2=0`. Not required by Theorem 5.38. |
| General wedge productivity | **Open conjectural gate, not source-pending** | Manuscript open problem and Proposition 5.20 discussion; issue #85 | Alternative finite-BPA route: exclusion of strict components with `K2!=0`. Full span alone is insufficient. |
| Bounded degree-three exclusion | **Finite-domain theorem** | `docs/p1a-degree3-partial-theorem.md`; canonical Mojo certificate; PR #67 | Only the exact 4,554 substitutions with three letters and image lengths at most three. |
| Bounded degree-two wedge productivity | **Finite-domain theorem** | `docs/p1a-degree2-wedge-productivity.md`; canonical Mojo certificate; PR #71 | Same 4,554-member domain; fail-closed and replayable-countermodel boundary. |
| Finite-domain pure discrete spectrum | **Finite-domain theorem** | `docs/pds-certificate-from-the-box-automaton-2026-10-07.md`, Theorem Ω and §5; canonical Mojo certificate `kernel/vertex_coincidence_census.mojo` (box automaton, `psc.vertex_coincidence`); PR #233 | Only the 145,806 PIP substitutions on three letters with images of length at most 4 or total image length at most 8 (the two domains share 14,670). The exact certificate is "every box-automaton vertex reaches a coincidence". It is equivalent to formal productivity by Lemma Ω1, which is elementary and uses no Theorem B, Lemma C, Proposition F, Theorem R, Theorem S or Proposition V(2). It gives PDS through the imported Lee–Moody–Solomyak 2003 overlap-coincidence criterion with the Lee–Solomyak 2012 Meyer property, and independently through Theorem 5.38. Guarding: the standing corpus is CI-pinned; total length ≤ 8 and images ≤ 4 are guarded by `.github/workflows/box-automaton-evidence.yml`. Says nothing outside the domain; the converse direction still rests on Theorem S. |
| Cycle vertices lie in the box automaton | **Repository-proved; human review pending** | Lemma Ω1 of `docs/pds-certificate-from-the-box-automaton-2026-10-07.md` §3 (Proposition V step 1; `docs/formal-overlap-carriers-2026-10-04.md` §2 item 5) | Every potential overlap has finitely many descendants, and every potential overlap on a cycle of the overlap graph has `|w_m| <= R_m`, so lies in the box automaton `𝔅`. A geometric-series bound in the contracting embeddings; uses no Theorem B, Lemma C or periodic tiling. Step 1 audited in `docs/audit-adversarial-prop-v-theorem-e-2026-10-07.md`. Independently reviewed 2026-10-08 (`docs/side-notes-ledger.md`); human review pending. |
| Box-automaton certificate for formal productivity | **Repository-proved; human review pending** | Theorem Ω of `docs/pds-certificate-from-the-box-automaton-2026-10-07.md` §4 | For a PIP `sigma`: formal productivity iff every vertex of `𝔅` reaches a coincidence. A per-specimen certificate, decided by `psc.vertex_coincidence.productive`; it proves FP for no substitution by itself. Independently reviewed 2026-10-08 (`docs/side-notes-ledger.md`); human review pending. |
| Formal productivity | **Open conjectural gate** | `docs/formal-productivity-reduction-2026-10-04.md`; `docs/pds-certificate-from-the-box-automaton-2026-10-07.md` | For every PIP `sigma`, every potential overlap (not only those reachable from a seed) is productive. Stronger than all-seed overlap productivity; implied by PDS through Corollary FP″ and Theorem S, so equivalent to PSC in the standing regime given those. Certified per specimen on 145,806 substitutions (the finite-domain row above); open uniformly. |
| Overlap-coincidence criterion | **Imported theorem** | Lee–Moody–Solomyak, DCG 29 (2003), Lemma 6.9 and Theorem 4.7; Lee–Solomyak, DCDS-A 32 (2012), Theorem 4.3 (Meyer property); stop/go record `docs/pds-certificate-from-the-box-automaton-2026-10-07.md` §7 | If from every overlap of a self-similar Pisot tiling of the line there is a path to a coincidence, the tiling flow has pure discrete spectrum. No unimodularity; the theorem quantifies over occurring overlaps, so a superset hypothesis is used for sufficiency only. |
| Pisot Meyer property | **Imported theorem** | Lee–Solomyak 2012, Definition 2.3 and Theorem 4.3; `docs/review-box-leftmost-ledger-2026-10-08.md` §1 | Primitive repetitive FLC suspension with scalar Pisot inflation; Meyer control points supply Meyer return vectors. No unimodularity; this supplies a hypothesis, not PDS. |
| Box-automaton PDS certificate | **Repository-proved; human review pending** | Box note, Theorem Ω consequence (a); dated box/leftmost review §§1–2 | For each fixed PIP specimen, a complete productive box gives PDS of its Perron-length suspension flow. Depends on Ω and both explicit imports, with no Theorem B, Lemma C, Proposition F, Theorem R, Theorem S or Proposition V(2). No uniform productivity assertion, PDS converse or flow-to-subshift theorem. |
| Formal productivity implies PDS (overlap coincidence) | **Conditional theorem** | Consequence (a) of `docs/pds-certificate-from-the-box-automaton-2026-10-07.md` §4 | Every LMS overlap is a potential overlap, so FP gives LMS Lemma 6.9(iii). Its only open premise is formal productivity; derives from the per-specimen box certificate and its separate Meyer and overlap-coincidence imports. Shares no step after FP with the seed route. Independently reviewed 2026-10-08 (`docs/side-notes-ledger.md`); human review pending. |
| Formal productivity implies PDS (seed route) | **Conditional theorem** | Consequence (b) of `docs/pds-certificate-from-the-box-automaton-2026-10-07.md` §4, with manuscript Lemma 5.36 and Theorem 5.38 | Every overlap reachable from a swap seed is a potential overlap, so FP gives seedwise overlap productivity, then density one and the Barge–Štimac–Williams import. Its only open premise is formal productivity. Independently reviewed 2026-10-08 (`docs/side-notes-ledger.md`); human review pending. |
| Formal productivity implies finite BPA | **Conditional theorem** | Consequence (c) of `docs/pds-certificate-from-the-box-automaton-2026-10-07.md` §4, with `docs/bpa-termination-by-overlap-depth-2026-10-02.md`, Proposition 1 | FP bounds every reachable balanced-pair state by `2 beta^D ell_max`, so `B_sigma` is finite and every state reaches a coincidence; a fourth alternative establishment of canonical G1. Its only open premise is formal productivity. Does not check ABBLS Theorem 5.3's seed hypotheses. Independently reviewed 2026-10-08 (`docs/side-notes-ledger.md`); human review pending. |
| Seed-patch overlap graph finiteness | **Repository-proved** | `docs/overlap-finiteness-and-coincidence-density-2026-09-13.md`; manuscript Theorem 4.22; PR #72 | Finite from bounded discrepancy; no G1 assumption. |
| Full-rank child-closed overlap constraint | **Repository-proved** | Manuscript Corollary 5.34; PR #76 | A nonempty child-closed noncoincidence set has full rational intersection-vector rank; this is a constraint, not an exclusion. |
| Closed irreducible bad-overlap normal form | **Repository-proved supporting reduction** | Manuscript Proposition 5.43; `docs/p1-overlap-minimal-obstruction-2026-09-14.md`, Proposition 2.1; PR #88 | Failure of overlap productivity has a finite child-closed recurrent nonproductive SCC with `PF(N_S)=beta`, full-rank `V_S`, and `spec(M) subset spec(N_S)`. Standard residual-SCC graph extraction is not claimed as novel. |
| Boundary obstruction / strict zipper dichotomy | **Repository-proved supporting reduction** | Manuscript Proposition 5.44 (with the first-/last-letter closure of the aligned pairs) and Lemma 5.45 (ordered cycle equation, purely periodic offsets); `docs/p1-overlap-minimal-obstruction-2026-09-14.md`, Proposition 3.1; exact Mojo/Python common-start checks; PR #88 | A bad SCC either contains an offset-zero non-eventually-coincident pair or all child factorizations are strict no-tie prefix-grid zippers. This constrains but does not close Open Problem 5.35. |
| Ordered affine overlap-cycle identity | **Repository-proved finite recurrence lemma** | `docs/p1-overlap-affine-pump-2026-09-15.md`, Lemma 1; canonical Mojo certificate and independent Python oracle | Actual ordered child occurrences satisfy `w'=Mw+q-p`; a replayed cycle satisfies the exact pump identity. A productive determinant-two example has such a cycle, so recurrence alone does not exclude a bad SCC. Context preservation and the recognizability/adelic contradiction remain open. |
| One-step overlap context equality | **Exact finite negative calibration** | `docs/p1-overlap-context-equality-2026-09-15.md`; canonical Mojo diagnostic and independent Python oracle | The same affine child state can arise with unequal paired prefix-suffix addresses. Affine-state equality alone cannot justify pumping. A depth-`k` periodic-patch collar and its recognizability bridge remain open. |
| Radius-`m` periodic-patch collar | **Repository-proved collar recursion lemma; exact finite calibration** | `docs/p1-overlap-collar-2026-09-16.md`, Lemmas 1–2; canonical Mojo diagnostic, independent Python oracle, corpus census | The collar of a child occurrence is a function of the parent's collar and the child indices, so the collared occurrence graph is finite; on the determinant-two graph one letter of context resolves every occurrence's one-step ancestry and the golden zero-shift-free pump lifts to a collared cycle at every tested radius. Bounded-context equality alone cannot exclude such pumps; the splicing/tiling-dictionary bridge remains open. |
| Unimodular seed-patch non-collapse | **Repository-proved** | `docs/unimodular-route-gate-2026-09-17.md`, Lemma 1; canonical Mojo regression and independent Python oracle | Restricted to unimodular `sigma`: no `sigma^n(ab)` is a proper power, at any level, by Parikh divisibility through `M^n` in `GL_A(Z)`. It removes the collapse branch of the periodic-patch context bridge on that branch only, supplies no separation radius, and is not progress on Open Problem 5.35. |
| Corpus determinant split | **Finite-domain theorem** | `docs/unimodular-route-gate-2026-09-17.md`, Computational Proposition 2; the regime split of `kernel/swap_overlap_census.mojo`; independent Python oracle | Only the exact 4,554-member domain: 2,628 unimodular and 1,926 determinant-two specimens; all 120 collapsing patches are non-unit, while zero-shift-free affine pumps occur on both branches (2,598 of 2,628 unimodular). It measures where the two obstructions live and proves nothing about the general regime. |
| Coincidence density / dense-good-set equivalence | **Repository-proved** | Manuscript Lemma 5.36; PR #77 | Corrected proof does not assume finite-stage good sets are nested. |
| Density-to-PDS bridge | **Imported theorem** | Barge–Štimac–Williams; manuscript Imported Theorem 5.37; PR #77; `docs/bsw-import-literature-gate-2026-09-21.md` | Exact hypotheses checked in the standing PIP regime and, on 2026-09-21, against the source text: patches need not be allowed, "densely" is a dense set of points, no unimodularity; no G1 hypothesis. |
| One-seed overlap productivity implies PDS | **Conditional theorem** | Manuscript Theorem 5.38 | Only open premise is seedwise overlap productivity. |
| Endpoint-aligned overlaps = strong-coincidence boundary cases | **Repository-proved** | Manuscript Proposition 5.39; PR #82 | Prefix/suffix boundary cases only; does not prove arbitrary interior overlap productivity. |
| Boundary-hitting criterion | **Repository-proved** | Manuscript Proposition 5.40 / Corollary 5.41; PR #82 | Offset-zero descendant iff exact prefix-Parikh/common-left-endpoint hit. |
| Seedwise overlap productivity / Open Problem 5.35 | **Open conjectural gate — current shortest-path gate** | Manuscript Open Problem 5.35 (all-vertex form); issue #84 (one-seed form) | It suffices that one swap seed have only productive reachable overlaps; legality of `ab` is not assumed. All-seed/all-vertex productivity is stronger. The gate contains two-sided strong coincidence (Proposition 5.39) and is equivalent to PDS for unimodular `sigma` (Barge–Kwapisz converse, cited, not imported). |
| All-seed overlap productivity | **Open conjectural gate** | Manuscript Open Problem 5.35 (all-vertex form) | Every overlap reachable from every swap seed is productive. Stronger than the one-seed gate that Theorem 5.38 needs; by the overlap-depth route it implies finite BPA (G1). |
| All-seed strict-zipper exclusion | **Open conjectural gate** | Manuscript Proposition 5.44(iii)(b), all-seed form; issue #139 | No closed nonproductive strict-zipper set (case (b): no offset-zero vertex) is reachable from any swap seed. Implied by all-seed overlap productivity; the strong-coincidence branch (case (a), issue #138) is not part of it. |
| Strict-zipper exclusion implies finite BPA | **Conditional theorem** | Manuscript Proposition 5.47; `docs/bpa-termination-by-overlap-depth-2026-10-02.md`, Proposition 4 and Corollary 5 | If every reachable overlap has an offset-zero descendant within `K'` levels, every reachable state has geometric length at most `2 beta^K' ell_max`; that hypothesis is exactly all-seed strict-zipper exclusion. Half-coincidence form of Sirvent–Solomyak Theorem 5.6. Its only open premise is all-seed strict-zipper exclusion. |
| PDS implies G1 | **Repository-proved; human review pending** | Manuscript Proposition `prop:PDS-implies-G1`; `docs/p1b-vertex-coincidence-box-2026-10-02.md` §5.1 (Theorem S), with Corollary B′ of `docs/p1b-strict-zipper-periodic-pair-2026-10-02.md`, Proposition F and Theorem R of `docs/p1b-periodic-pair-fibre-literature-gate-2026-10-02.md`, and Proposition 5.47 | Pure discrete spectrum implies finite `B_sigma`, so G1 is a **necessary** condition for PDS rather than an artefact of the balanced-pair method. A reachable strict zipper gives a `Phi^r`-fixed pair in one MEF fibre sharing no tile, hence coincidence rank at least two. The realization uses interior occurrences, whose patches are allowed for `sigma`, and takes offset integrality from the cycle equation. Independently audited 2026-10-04 (`docs/side-notes-ledger.md` §7); re-derived in `docs/audit-2026-10-04.md` §B.4. |
| PDS implies seedwise termination | **Repository-proved; human review pending** | Manuscript Theorem `thm:seedwise`; `docs/formal-productivity-reduction-2026-10-04.md`, Proposition FP | Answers in full what the manuscript formerly carried as Open Problem 4.24: PDS gives termination with coincidence from **every** seed `(ab, ba)`, legal factor or not. Covers the repository's all-seed graph, not one convenient seed. |
| Coincidence-rank fibre theorems | **Imported theorem** | Barge, arXiv:1301.7094, Theorem 4(5),(6); Barge, arXiv:1505.04408, §1 items (2)–(3); hypotheses audited in `docs/coincidence-rank-imports-literature-gate-2026-10-04.md` | Same fibre iff strongly regionally proximal; pairwise proximal tile-disjoint tilings number at most `cr`; PDS iff `cr = 1`. Assumes neither unimodularity nor irreducibility, so every PIP `sigma` qualifies. Soft link recorded in that gate: the item used is stated in a published introduction's summary, whose own proofs the gate did not read. |
| Full-rank return module | **Repository-proved; human review pending** | Theorem R of `docs/p1b-periodic-pair-fibre-literature-gate-2026-10-02.md` §5 | The uncollared return module `Lambda_ret` is all of `Z^A` whenever the frequency vector has `Q`-independent coordinates, so `Lambda_ret = Z^3` for every PIP `sigma`. Proved for a primitive substitution on any finite alphabet; it needs neither unimodularity nor irreducibility. Independently audited 2026-10-04 (`docs/side-notes-ledger.md` §7). Ledger node behind `PDS implies G1` since 2026-10-05. |
| Periodic pairs lie in one fibre | **Repository-proved; human review pending** | Proposition F of `docs/p1b-periodic-pair-fibre-literature-gate-2026-10-02.md` §4, from the full-rank return module via Solomyak's eigenvalue criterion | Two `Phi^r`-fixed legal tilings built from interior occurrences and sharing a centre have the same maximal-equicontinuous-factor image. This is what makes a strict zipper a *same-fibre* pair, so that the imported coincidence-rank theorems apply. Independently audited 2026-10-04 (`docs/side-notes-ledger.md` §7). Ledger node behind `PDS implies G1` since 2026-10-05. |
| Periodic-pair form of a strict zipper | **Repository-proved; human review pending** | Theorem B with Lemma C and Corollary B′ of `docs/p1b-strict-zipper-periodic-pair-2026-10-02.md` §§3–4 | A strict zipper reachable from a swap seed exists iff two `Phi^r`-fixed legal tilings with a common centre share no vertex — a failure of PeriodicPairVertexCoincidence, which is the reformulation of issue #139. Realization is by interior occurrences, whose patches are allowed for `sigma`, with offset integrality from the cycle equation, so the realization firewall is not breached (`docs/audit-2026-10-04.md` §B.4). Independently audited 2026-10-04 (`docs/side-notes-ledger.md` §7). Ledger node behind `PDS implies G1` since 2026-10-05. |
| Leftmost-chain cycles are prefix-vs-interior pairs | **Repository-proved; human review pending** | Lemma S, Proposition LC and Corollary LC4 of `docs/p1b-leftmost-chain-periodic-pair-2026-10-05.md` §§3–4, 8a; exact certificate `kernel/psc/leftmost_chain.mojo` | The prefix object is a right-infinite fixed ray, compared with a two-sided interior tiling on the right half-line. The census has 10,584 sign/shape checks, 10,128 integral replays and 456 uncomputed offsets. Every terminal cycle of the leftmost-child map on the box graph keeps one strict offset sign and is a prefix occurrence `sigma^r(i) = i U` against an interior occurrence `sigma^r(j) = Q j V` with `(I − M^r) w_0 = ab(Q)`; its centre is never a common vertex, and the cycles pair off under the tiling swap. A structure theorem for `CU`-failure, not an exclusion; no novelty is claimed for the cycle principle (Siegel–Thuswaldner zero-expansion graph). The stated cycle shape is checked on all 10,584 standing-corpus cycles; 10,128 offsets are replayed and 456 remain uncomputed. Settles neither T1, T2, PPVC nor #139. Independently reviewed 2026-10-08 (`docs/side-notes-ledger.md`); human review pending. |
| No terminal leftmost cycle implies finite BPA | **Repository-proved; human review pending** | Corollary LC5 of `docs/p1b-leftmost-chain-periodic-pair-2026-10-05.md` §8a, with manuscript Proposition 5.47 | Per specimen: if the box graph of `sigma` has no terminal leftmost cycle, all-seed strict-zipper exclusion and hence G1 hold for that `sigma`. Hypothesis met by 1,794 of the 4,554 standing specimens, where G1 is already certified; the uniform form is false (all 210 catch-up-free specimens have cycles), so this is not a route to uniform G1. Independently reviewed 2026-10-08 (`docs/side-notes-ledger.md`); human review pending. |
| Strong coincidence from PDS | **Imported theorem** | Akiyama–Lee, European J. Combin. 39 (2014), Corollary 4.5; height-group step by Theorem R; `docs/pds-strong-coincidence-literature-gate-2026-10-04.md` | PDS of an irreducible Pisot substitution gives simultaneous prefix strong coincidence of all letters. Used only in the seedwise-termination row. |
| SCC Producer / C1 | **Open theorem target** | `docs/conjecture-ledger.md`; manuscript unresolved statements | Can be reached through the finite-BPA carrier route; stronger overlap productivity also implies productivity of reachable BPA states. |
| Realization / coincidence-rank chain | **Open bridge, not source-pending** | `sources/issue-45/realization-coincidence-rank-audit.md`; PR #69 | Seven obligations G0–G6 remain; formal recurrence, global realization, and collar survival are distinct. |
| Finite collar death | **Empirical evidence** | Realization/collar notes and census artifacts | Requires an independent collar-completeness bound before theorem use. |
| BPA termination / literature interface | **Imported theorem plus repository-interface audit** | `docs/bpa-literature-bridge.md` and cited literature | Do not silently identify the normalized all-seed graph with a literature algorithm. |
| Pisot substitution conjecture in the standing regime | **Open** | Manuscript abstract / unresolved statements | Current shortest route has the single open seedwise-overlap-productivity premise. |

## Current completion frontier

The shortest no-G1 route is now:

```text
G1b-1 bounded discrepancy                       [PROVED]
=> finite seed-patch overlap graph              [PROVED]
=> one-seed overlap productivity                [OPEN: issue #84]
=> coincidence density one / dense good set     [PROVED]
=> PDS                                          [IMPORTED theorem].
```

Accordingly:

1. **Primary proof target:** seedwise overlap productivity, now normalized to a closed irreducible bad-overlap SCC and split into aligned versus strict-zipper branches by PR #88.
2. **Stronger parallel theorem:** G1b-2 renewal finiteness and finite BPA (issue #44).
3. **Alternative finite-BPA coincidence route:** concentration and wedge productivity (issues #43 and #85).
4. **Secondary certificate route:** realization/coincidence-rank bridge G0–G6.

The historical v16 manuscript is not a prerequisite in this list.

## Source-resolution decisions

### G1b-1

The reported historical contraction estimate

```text
Disc(sigma w) <= c Disc(w) + 2 E_sigma
```

was not recovered and is not used. PR #69 supplied a different global proof from bounded contracting components of inflated swap-seed prefixes. Therefore the mathematical claim is repository-proved even though the reported historical derivation remains unavailable.

### Degree-two carrier propagation and aux-B

The live carrier implication does not depend on recovery of a v16 manuscript. The degree-two rational carrier-span result is self-contained on `main`. The archived degree-three certificate is a different, restricted theorem.

“Aux-B” is not a proved theorem waiting for source recovery. Its live content is the open concentration statement.

### Realization and coincidence rank

The former status-level equivalence has been decomposed into obligations G0–G6. The correct status is **open bridge**, not **source-pending theorem**.

### P0 source/status issue

Issue #45 is closed as completed at the status level: the missing v16 artifact remains historical provenance metadata, while all live claims have a current proof, an exact imported source, or an explicit open classification. Recovery of v16 would trigger archive comparison, not automatic theorem promotion.

## Finite-certificate boundary

Finite-domain claims must preserve their exact domain and fail-closed semantics:

1. every domain parameter remains in the theorem statement;
2. catalogue caps fail closed;
3. zero-survivor conclusions require predicate calibration;
4. survivors are retained as replayable countermodels;
5. absence of observed higher-degree states or bad overlaps is empirical unless an independent completeness theorem excludes them;
6. the 4,554-member overlap census is extremely strong evidence for Open Problem 5.35 but not a universal theorem.

## Hypothesis / generality firewall

- Tile-length rational/integer independence must be derived from irreducibility where used, not added as a standing assumption.
- UD is derived from full incidence rank, not assumed.
- FI, prefix/suffix permutation, or boundary-injectivity conditions are extra hypotheses unless derived.
- Do not import unimodularity through a converse theorem or internal-space argument without restricting the statement.
- Do not treat `pi_s(Z^A)` as a discrete lattice in general.
- Do not identify formal recurrence with global realization.
- Do not treat a finite corpus or collar radius as self-certifying completeness.

## Retired / corrected routes

Do not use:

- predecessor contraction as a proof of finite BPA;
- `UD => bounded total padding`;
- bounded discrepancy alone as finite-BPA proof;
- naive zero-sum-hyperplane contraction;
- unlabelled difference-walk injectivity;
- rank-deficiency of a child-closed bad overlap set;
- nesting of finite-stage good sets in the coincidence-density proof;
- `rho(N_S)<beta` inferred merely from calling a residual real-overlap SCC a boundary system: Akiyama–Lee's residual graph can carry the full expansion spectral radius precisely when a genuine noncoincident overlap remains.

## Citation and maintenance rules

- Cite the current manuscript for exposition and the underlying proof note for load-bearing reconstructed arguments.
- Cite PR/merge identifiers for provenance, not as mathematical proof.
- Cite the archived certificate only with its seed-specific degree-three scope.
- Label the two exhaustively certified 4,554-corpus carrier exclusions as finite-domain theorems; the overlap productivity census remains finite evidence for the general gate.
- Never describe overlap productivity, G1b-2, concentration, general wedge productivity, realization G0–G6, SCC Producer, or PSC as proved.
- When a status changes, update this map, `docs/conjecture-ledger.md`, `docs/proof-ladder.md`, `docs/current-proof-architecture-2026-09-14.md`, the manuscript status table, and `proof/tla/Ledger.tla` as applicable.
