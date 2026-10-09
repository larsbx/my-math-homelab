# Minimal-bad-SCC / inversion-dynamics track routing

**Status:** historical proposal and parallel research-track routing; no theorem
or claim-status promotion. **Stop/go review:** 2026-10-02.

## 1. Source and exact proposed target

The source is the user-supplied four-page PDF *Minimal bad SCC setup for the
general PSC*, original filename `MINIMAL_BAD_SCC_SETUP_NOTE.pdf`, available as
an [unaltered source snapshot](../sources/minimal-bad-scc/MINIMAL_BAD_SCC_SETUP_NOTE.pdf).
The [import record and checksum](../sources/minimal-bad-scc/README.md)
identify the exact bytes. Page/section numbers below refer to that PDF, not to
the earlier v12.2 relevance assessment or this routing note.

The source's final target (p. 4, §7) is exclusion of every minimal reachable
noncoincident SCC in its small-regime automaton. That is an **open historical
proposal**, not a proved PSC criterion. Its standing setup (p. 1, §1) is:

| Source label | Hypothesis in the PDF | Transfer boundary |
| --- | --- | --- |
| S1 | Primitive irreducible Pisot `sigma`, alphabet size at least four, `det(M) != 0`, and integer-independent tile lengths | PIP transfers; tile-length independence is derived from irreducibility in the live manuscript, not an extra standing assumption. The alphabet restriction does not establish a smaller-alphabet SRE base case. |
| S2 | `SRE(|A|)` fails: a periodic noncoincident cycle exists in the small regime of `B_sigma` | The PDF supplies neither a numerical small-regime definition nor its construction. Cycle existence does not imply nonproductivity. |
| S3 | `C` is a minimal reachable noncoincident SCC of `B_sigma^sm`; minimal means no proper sub-SCC is itself noncoincident | This does not supply closure under all actual children, absence of productive exits, or the canonical sink-SCC reduction. |
| S4 | The alphabet size is the smallest for which SRE fails | This is an additional reductio assumption, not a live PIP hypothesis or an established PSC counterexample. |

The source contains **six** inherited propositions, 2.1–2.6 (pp. 1–2):
permutation pairs, full support, bounded word length, recurrence, reachability,
and inversion dynamics. They are source assertions, not imported theorems.
In particular, the referenced “restricted ambiguity inheritance theorem,”
“finiteness engine,” “P1,” “bracket lemma,” and “dichotomy note, Theorem 3.2”
have no bibliographic or repository locator in the PDF. It also gives no full
definition of `Pi_inv`, no ordered child-selection convention for `Phi_sigma`,
and no proof that the return restriction `R_k` is determined by an aggregate
inversion vector. Those are provenance/contract gaps to close before reuse.

Definition 3.2 (p. 2) calls interval types/counts, interval Parikh vectors,
padding/child classifications and adjacent source-letter germs a **bracket
type**. Definitions 4.1 and §§5–6 (pp. 3–4) propose a return map and the
equation `x = R_k((M tensor M)^k x)`. The four proposed attacks are precisely:

| Source route (§6) | Proposed mechanism | Present disposition |
| --- | --- | --- |
| RS1 — Common-cut recurrence | Degrade the recurring bracket structure | No strict degradation theorem is supplied. |
| RS2 — Monotone invariant | Strict descent in a finite poset unless coincidence occurs | No invariant or descent proof is supplied. |
| RS3 — Inversion fixed-point impossibility | Exclude nonzero full-support solutions for realizable child restrictions | The profile, restriction, and realization contracts must first be defined and verified. |
| RS4 — Support-drop under return | Lose an active letter pair on each return | Strict support loss and “empty profile implies coincidence” remain unproved. |

## 2. Relationship to the live architecture

The authoritative route descriptions are the [README](../README.md),
[proof ladder](proof-ladder.md), [current architecture](current-proof-architecture-2026-09-14.md)
and [verification architecture](verification-architecture.md). They place the
**overlap-first route** ahead of the historical v12 mass-balance/boundary route:

1. PIP gives bounded discrepancy and a finite seed-patch overlap graph
   (repository-proved; no finite-BPA/G1 premise).
2. For each substitution, **one** selected swap seed has only productive
   reachable overlaps (`OP_seed`, open, issue #84).
3. That premise gives coincidence density one / a dense eventual-coincidence
   good set (repository-proved implication).
4. The audited Barge–Štimac–Williams density-to-PDS import yields pure discrete
   spectrum (conditional manuscript Theorem 5.38).

The stronger all-vertex `OP_all` formulation and all-seed G1 routes remain
distinct from `OP_seed`; this note adds no implication between them. The live
overlap obstruction is a finite **child-closed nonproductive overlap set**,
not the source's undefined small-regime BPA cycle. Transferring inversion or
bracket data to that object needs a new, explicit interface proof.

The **finite-BPA SCC Producer route is stronger parallel work**. Its complete
boundary sufficiency ladder, matching `tools/make_ledger.py`, is:

| Step | Premises and conclusion | Status/boundary |
| --- | --- | --- |
| Global finiteness | G1 gives a finite reachable `B_sigma` | G1 remains open; bounded discrepancy alone does not prove it. |
| Counterexample extraction | Under G1, a nonempty nonproductive set is forward-closed and contains a finite closed recurrent sink SCC | [Sink-SCC reduction](sink-scc-reduction.md), proved finite graph reduction; balanced-pair inflation supplies an outgoing child at each noncoincident state. |
| Local boundary target | C4 gives C3-local (newborn synchronizing boundary existence), which gives C2 through the [locality reduction](c3-locality-reduction.md) and [Boundary Synchronization Lemma](boundary-synchronization.md) | These are sufficient implications. Universal boundary existence remains open. |
| Global productivity | **G1 + SinkSCCReduction + C2 implies SCC Producer / C1** | The implication is proved; its open premises are not discharged. |
| PDS bridge | **G1 + SCC Producer implies PDS**, using the audited termination-with-coincidence bridge | Conditional sufficiency; SCC Producer alone does not exclude an infinite transient BPA path. |

Structural lemmas about an already-given finite closed SCC need not separately
assume G1. The **global extraction and the advertised BPA-to-PDS ladder do**.
This is the distinction enforced by the live ledger and its TLA+ models. C4
and boundary synchronization are supporting machinery, not the shortest
completion ladder. G1, SCC Producer and PSC keep their existing open status.

## 3. Targeted prior-art and hypothesis check

Four primary texts were inspected on 2026-10-02; only the pinpoint statements
listed here are used. The established BPA terminology/algorithm baseline is
also recorded in the repository's [BPA literature bridge](bpa-literature-bridge.md).

| Primary source | Relevant prior art | What does not transfer automatically |
| --- | --- | --- |
| Akiyama–Lee, *Algorithm for determining pure pointedness of self-affine tilings*, Adv. Math. 226 (2011), 2855–2883; [arXiv:1003.2898](https://arxiv.org/pdf/1003.2898), §4, equation (4.2), Theorem 4.1 | Actual/potential overlaps, multiplicity-preserving child edges, and the coincidence-leading/residual graph distinction are established constructions. | Their theorem assumes a realized self-affine tiling with Meyer return vectors. An abstract small-regime BPA cycle has not been identified with that graph. |
| Barge–Štimac–Williams, *Pure discrete spectrum in substitution tiling spaces*, DCDS 33 (2013), 579–597; [arXiv:1107.3598](https://arxiv.org/pdf/1107.3598), §3, Theorems 3.1–3.2 and Corollary 3.3 | Dense eventual coincidence of a suitable periodic patch gives PDS; a terminating-with-coincidence swap-seed BPA is sufficient. | Recurrence alone is insufficient. The density route accepts a possibly illegal periodic patch, but this does not make arbitrary source contexts legal for recognizability. See the [audited import](bsw-import-literature-gate-2026-09-21.md). |
| Mossé, *Reconnaissabilité des substitutions et complexité des suites automatiques*, BSMF 124 (1996), 329–346; [primary text](https://smf.emath.fr/system/files/2017-08/smf_bull_124_329-346.pdf), first part, §2, Theorems 1–2 | Primitive substitutions with nonperiodic fixed points have bilateral recognizability and local desubstitution control. | These theorems do not provide the source's equality `R(sigma^k) = R(sigma)` or a two-sided synchronization conclusion for arbitrary formal BPA words. |
| Durand–Leroy, *The constant of recognizability is computable for primitive morphisms*, JIS 20 (2017), 17.4.5; [arXiv:1610.05577](https://arxiv.org/pdf/1610.05577), §2, Definition 1 and Theorem 5 | A recognizability constant is substitution/context dependent and has an effective bound in the primitive aperiodic setting. | Existence or computability of a radius does not compare it with padding for all return powers. An explicit radius, admissible context, and padding estimate are required. |

No inspected source supplies RS1–RS4's missing contradiction. The recurrence
template is elementary finite-graph reasoning; no novelty is claimed for it,
overlap algorithms, or recognizability.

## 4. Negative controls and possible reuse

**Cycle existence is not a counterexample.** The live manuscript withdraws
universal noncoincident-cycle exclusion and records the flipped-Tribonacci
productive recurrent cycle. This control is outside S1's alphabet-at-least-four
scope; it does not refute that restricted proposal, but prevents replacing
nonproductivity by S2's cycle condition on the live route. The [cut-germ
calibrations](c4-recognizable-cut-germs.md) also exhibit a repeated finite germ
in productive Tribonacci, and a strict recurrent germ in a non-Pisot example.
Thus repetition supplies neither coincidence nor the PIP contradiction.

The [strong G/F negative control](target-aware-bpa-literature-gate-2026-10-02.md)
passes algebraic/endpoint layers but fails the claimed actual child
factorization. The [canonical target-aware diagnostic](target-aware-bpa-diagnostic-2026-10-02.md)
therefore retains actual ordered children, occurrence addresses and physical
orientation; zero residual or a target-free cycle alone does not close C4.

Three tools may be considered later, with the following obligations:

- **Finite-type recurrence:** define types on actual ordered child paths of a
  finite closed component. A repeated type is only recurrence; the strict
  decrease, escape, or synchronization step still needs proof.
- **Minimal-alphabet/full-support reduction:** source and prove restricted
  inheritance, including preservation of substitution closure and the relevant
  PIP/counterexample hypotheses. S4 and a missing inheritance theorem cannot
  establish full support by themselves.
- **Return padding and recognizability:** use a specified radius for a fixed
  substitution on certified admissible contexts, with a proved padding bound.
  The source's Proposition 4.2 and Remark 4.3 are not imported. The live
  [legal-context extraction](c4-recognizable-cut-germs.md) and
  [derived recognizability](c4-derived-recognizability.md) give the appropriate
  interfaces, while leaving the synchronization/existence gap open.

## 5. Stop/go decision and repository policy

**Redirect; proceed only with a parallel, non-load-bearing proposal.** Preserve
the source for audit, but stop treating its inherited propositions or final
cycle-exclusion target as proof inputs. Before an RS route gets theorem-facing
code, supply its missing definitions/references, actual factorization and
orientation contract, closed-nonproductivity hypothesis, primary-source
transfer check and known negative controls, as required by [AGENTS.md](../AGENTS.md).

Keep the overlap-first terminology and priorities of the live architecture.
Use historical v12 mass-balance/boundary vocabulary only when discussing that
stronger side route. SRE failure, minimal-alphabet assumptions, inversion
profiles, common-cut brackets and RS1–RS4 remain names of this proposal; none
is a new standing hypothesis or a dependency of the manuscript/proof ledger.
This routing repair changes no theorem, generated claim record or status.
