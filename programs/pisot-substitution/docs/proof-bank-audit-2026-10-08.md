# Proof-bank and Lean environment audit — 2026-10-08

**Status:** governance and source audit. This records internal review of
already stated implications, not a proof of general PSC. Human review of
the mathematical notes remains pending. The generated bank inventories all
governed claims, all named local Lean proofs and apparent statement openings
in the existing claim-policy source scope. A source opening can be a proposal,
an imported statement or a repeated heading; inventory grants no proof status.

## Environment and audit contract

The remote session hook previously provisioned Python and Mojo only. The
Lean project already pinned `leanprover/lean4:v4.34.0-rc2` and Mathlib commit
`4edb0dbaa3b3cf729d86d1e2f035474d5ae2ac09` in its manifest, but the direct
Lake requirement did not repeat the revision. `tools/setup_lean.sh` installs
elan 4.2.4 from checksum-verified release assets, selects the checked-in Lean
release, fetches the manifest-bound Mathlib cache and verifies that neither
pins nor package revisions changed. It runs from any working directory.

`tools/check_lean.sh` builds the root library and always replays
`ProofBankAudit.lean`. The audit visits every compiled declaration from a
local project module, including generated helpers and definitions. Local
axioms and dependencies beyond `propext`, `Classical.choice`, `Quot.sound`
are errors. A structured completion receipt must cover every inventoried
named theorem. Missing imports, a failed build, absent receipt or stale
inventory refuses verification. This is fail closed by refusing to proceed;
it does not delete a proof or alter a mathematical status.

This replaces the nine selected `#print axioms` commands as the acceptance
gate. Those commands remain useful exposition. Grepping a successful build
message could miss both an unaudited theorem and a cached audit that never
replayed. Session provisioning, CI and local verification now share the
same scripts.

References: the [Lean distribution/toolchain manual](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Managing-Toolchains-with-Elan/),
the [Lake manual](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/),
and the pinned compiler's `Lean/Util/CollectAxioms.lean`. The pinned
[elan release](https://github.com/leanprover/elan/releases/tag/v4.2.4)
publishes the SHA-256 digests used by the bootstrap.

## Evidence-source correction

The proof-dependency table cited `Spectral.lean` as the proof of
`PhiSemisimplicity` and `ThetaIntertwining`. That file expressly excludes both
from its formalized results. Their evidence is the archived restricted
certificate, sections 3 and 5, with the C7 exact finite check supporting the
intertwining. `SeedCentralizer` and `Target1` have a formalized rational
noncommutation component in `Centralizer.lean`; the full tensor-sector
passage also needs the manuscript results. The bank marks this support as
partial. The existing mathematical statuses and sufficiency edges are
preserved; no unsupported Lean declaration is invented.

## Finite-box implication review

Review target: Lemma Ω1, Theorem Ω and consequence (a) of
[`pds-certificate-from-the-box-automaton-2026-10-07.md`](pds-certificate-from-the-box-automaton-2026-10-07.md).

For a fixed potential overlap, stable conjugate coordinates obey a bounded
affine recurrence and the real overlap coordinate lies between the tile
length endpoints. The full Minkowski image of its integer coordinate lattice
is discrete, so only finitely many descendants occur. On a cycle, closing
the recurrence removes the initial-coordinate term and bounds every stable
coordinate by the digit bound divided by one minus the contraction modulus.
The trace-dual coordinate estimate therefore places that cycle in the box.
No finite BPA, unimodularity or periodic-tiling converse is used.

If a potential overlap is nonproductive, it has a child and every child
remains nonproductive. Finite descent gives a nonproductive cycle, which the
previous bound places in the box. Thus productivity of every box vertex
implies formal productivity. The reverse direction is inclusion. These are
the canonical nodes `BoxCycleContainment` and `BoxAutomatonCertificate`.
They establish implications for each specimen, not their universal premise.

The targeted literature check preserves the note's existing stop/go decision:

| Primary source | Hypotheses and use | Boundary |
|---|---|---|
| [Lee–Moody–Solomyak 2003](https://arxiv.org/abs/0910.4450), Theorem 4.7, Definition 6.7, Lemmas 6.8–6.9 | Primitive repetitive FLC self-affine tiling; Meyer return translations; actual overlap paths to coincidence give pure point dynamical spectrum | Applies to actual tiling overlaps; no converse from actual-overlap productivity to all formal overlaps is imported |
| [Lee–Solomyak 2012](https://arxiv.org/abs/1002.0039), Theorem 4.3 and Corollary 2.13 | One-dimensional expansion by the Pisot Perron number meets the diagonalizability and equal-multiplicity conditions; supplies the Meyer property | Supplies this hypothesis, not pure discreteness by itself |
| [Akiyama–Lee 2011](https://arxiv.org/abs/1003.2898), Definition 2.4 and Theorem 2.5 | States the overlap-coincidence/pure-point criterion explicitly with the Meyer hypothesis | Existential paths suffice; a chosen occurrence lineage need not be productive |

Every actual overlap offset is an integer combination of tile lengths and
its children agree with the potential-overlap construction. Formal
productivity therefore covers the actual overlaps. The two imports and
`BoxAutomatonPDSCertificate` record this sufficiency route for the tiling R-action.
The route does not depend on Theorem B, Lemma C, Proposition F, Theorem R,
Theorem S or Proposition V(2). It does not assert the reverse direction,
the symbolic Z-action correspondence or productivity outside a replayed
finite domain. The existing finite-domain claim keeps its Mojo/workflow
warrant, not a Lean warrant.

## Leftmost-chain implication review

Review target: Lemma S and Proposition LC of
[`p1b-leftmost-chain-periodic-pair-2026-10-05.md`](p1b-leftmost-chain-periodic-pair-2026-10-05.md).
The note's section 5 already checks the closest constructions against the
unit/non-unit boundary; registration adds no new diagnostic or invariant.

When the offset is negative the later-starting top tile begins at the left
endpoint of the overlap. Its leftmost child has top index zero, while the
bottom child starts at or left of that endpoint. Hence the child offset is
negative or zero. Positive offsets exchange the two sides. The cycle sign
is constant. Repeated zero indices give a prefix occurrence on the later
side. Primitivity rules out an image consisting only of that letter.

Closing the other side's prefix recursion gives
`(I - M^r)w = ab(Q)`. The negative offset and `beta > 1` force `Q` nonempty;
the strict overlap inequality forces the remaining suffix nonempty too.
Irreducible Pisot implies no eigenvalue of `M^r` is one, so the inverse used
in the note exists. Integrality is inherited from the actual cycle; it is
not inferred from rational invertibility. The fixed-centre construction
gives a right-infinite prefix-side fixed point paired with the two-sided
interior-occurrence tiling on the common right half-line. It does not give
two two-sided tilings in one MEF fibre.

Independent exact hand replay for `1/12/022`: with
`M = [[0,0,1],[1,1,0],[0,1,2]]`, `(I-M)(0,1,-1) = (1,0,0)`;
`sigma(1)=1·2` is the prefix occurrence and `sigma(2)=0·2·2`
is the interior occurrence. Its mirrored cycle reverses the offset sign.
The existing canonical regression also guards the vacuous Tribonacci case,
an uncomputed large-offset case and capped-graph refusal. The canonical node
`LeftmostChainCycleStructure` (grouping Lemma S, LC and LC4) links this evidence. No
edge is added to a general G1, PPVC or PSC conclusion.

## Remaining proof work

Inventory completeness is now enforceable. Deductive coverage remains the
finite algebra explicitly proved in `PscVerif`: shuffle identities, six
seed tables, centralizer contradiction and trace obstruction. The full
tensor intertwining, semisimplicity/Galois spectral passage and all open
universal premises remain outside that Lean development. New statements
must enter the source inventory, and new Lean modules must enter the root
import closure, before the common gate can pass.

## Reconciliation and review repairs

The [reconciliation record](proof-ledger-reconciliation-2026-10-08.md) maps
the original #237 proposal onto the canonical nodes already merged by #241
and retains the more detailed #236 review and census-status repair. The
proof inventory includes root-module declarations. Dependency validation
rejects staged, unstaged, deleted, untracked or ignored inputs even at the
pinned HEAD, while permitting the declared ignored build-artifact caches.
Seven original negative cases reproduced both P2 findings; two more reproduce
the untracked-source gap identified by current-head review. Four additional
controls cover ignored Lean/configuration injection, including local Git
exclusions and configuration under a cache path.
Generated counts are reported by the current bank, not the earlier PR snapshot.

Tracked bytes are also compared with the pinned tree, independently of the
Git index flags. Four negative controls reproduce edits hidden by
assume-unchanged/skip-worktree flags; the full root/pin refusal matrix contains
seventeen passing negative cases. The real nine manifest checkouts pass the
exact-byte/pin checks; this does not credit an unavailable Lean compilation.
