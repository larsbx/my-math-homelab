# Review of the box certificate and leftmost-chain ledger nodes — 2026-10-08

**Decision:** register Theorem Ω, its literature-backed PDS implication,
Proposition LC and Corollary LC5 as repository-proved implications, with
separate elementary and imported dependency nodes. No blocking error was
found in these arguments after the scope clarifications below. This is an
internal mathematical and implementation review, not human peer review or
a Lean formalization. Human review remains pending.

**Inspected baseline:** `main@cb9db58c9e25209c2a54ccd6955b509af88e8356`,
including merged PRs #227 and #233. Sources:

- [`pds-certificate-from-the-box-automaton-2026-10-07.md`](pds-certificate-from-the-box-automaton-2026-10-07.md), §§2–4 and §7;
- [`p1b-leftmost-chain-periodic-pair-2026-10-05.md`](p1b-leftmost-chain-periodic-pair-2026-10-05.md), Lemma S, Proposition LC and LC5;
- `kernel/psc/vertex_coincidence.mojo`, `kernel/psc/leftmost_chain.mojo`,
  their regression tests, the depth note and manuscript Proposition 5.47.

## 1. Literature stop/go and hypothesis transfer

The proposed registration is of implications for individual PIP substitutions,
not a proof that their finite predicates hold for every substitution.
Four primary texts were inspected before adding theorem-facing declarations:

| Primary text | Checked result and boundary |
| --- | --- |
| [Lee–Moody–Solomyak (2003)](https://arxiv.org/pdf/0910.4450), Theorem 4.7, Definition 6.7, Lemmas 6.8–6.9 | Coincidence reachability in the occurring-overlap graph gives pure discrete spectrum of a repetitive primitive tiling with Meyer return vectors. The theorem does not require unimodularity. |
| [Lee–Solomyak (2012)](https://arxiv.org/pdf/1002.0039), Definition 2.3, Theorem 4.3 | The scalar expansion satisfies diagonalizability and equal multiplicity; its Pisot family gives Meyer control points. Same-type return vectors lie in their difference set and are relatively dense, hence Meyer. |
| [Akiyama–Lee (2011)](https://arxiv.org/pdf/1003.2898), Definition 2.4, Theorem 2.5 | Confirms the overlap-coincidence criterion and the Meyer hypothesis. Its computational potential overlaps are a different construction from this repository's full integral-offset carrier. |
| [Siegel–Thuswaldner (2009)](https://www.dmg.tuwien.ac.at/nfn/Topological.pdf), Definition 5.1, Proposition 5.2 and its Appendix proof | Zero-expansion graphs are prior art. The proof's inverse-incidence step uses unimodularity; it cannot replace LC's integral cycle equation in the non-unit regime. |

Use a legal repetitive fixed tiling for a power of the primitive substitution;
FLC follows from the finite alphabet and positive lengths. Grouping child steps
does not change coincidence reachability. Every occurring overlap is a
potential overlap: after choosing a tile-start origin, all start differences
and same-type return translations belong to the integral tile-length module.
The child maps agree. Thus formal productivity supplies the published theorem's
premise on a superset of its graph. The recorded PDS conclusion here is the
Perron-length suspension **flow**; no additional flow-to-subshift theorem is
registered by this change.

**Proceed.** Restrict the new specialization to the exact box certificate and
the sign/prefix/interior structure. Do not import property (F), property (W),
or a unit-Pisot zero-expansion theorem as a non-unit hitting result. Relevant
negative controls remain the seed graph's missing box cycle vertices and
catch-up-free substitutions with terminal leftmost cycles.

## 2. Independent derivation of Ω1 and Ω

Normalize `ell` in `Q(beta)`. Irreducibility makes its three coordinates a
field basis. Their full embedding matrix is nonsingular; in the complex case
use real and imaginary parts. Consequently the image of `Z^3` is a lattice,
not merely an injective additive subgroup of `R^3`.

For a descendant path, `t_(n+1) = beta t_n + c_n`, the physical coordinate
stays bounded by `ell_max` because every state is an interior overlap. Each
contracting embedding satisfies
`|t_(n+1)^(k)| <= mu_k |t_n^(k)| + C_k`, so all descendants occupy one bounded
embedding region. It contains finitely many lattice points. A finite start set
has finite inflation closure as a consequence; the full potential-overlap set
is not asserted finite.

For a period-`r` cycle, summing the affine recurrence and using
`|1 - beta_k^r| >= 1 - |beta_k|^r` gives
`|t^(k)| <= C_k/(1 - mu_k)`. The trace-dual formula for each integral coordinate
then gives the box radii. The kernel uses rational upper bounds, counts the
complex conjugate twice, and includes all interior states in this slab. Its
solved coordinate may exceed its printed radius; this enlarges the start set
and does not omit a cycle vertex.

If a potential overlap is nonproductive, every child is nonproductive and
there is at least one child. Its finite descendant graph therefore contains a
nonproductive cycle. The cycle bound puts a vertex of that cycle in the box,
contradicting productivity of all box vertices. The reverse direction follows
because box vertices are potential overlaps. This proves Ω without any
periodic-tiling construction or Proposition V(2).

With the two checked imports, Ω yields the PDS certificate. The ledger closure
of that certificate contains neither Theorem B, Lemma C, Proposition F,
Theorem R, Theorem S nor the coincidence-rank imports. No PDS converse was
reviewed or newly registered here.

## 3. Independent derivation of LC and LC5

For negative offset, the parent's left endpoint is the top tile's start.
Exactly one half-open bottom subtile covers it. The top index is zero and the
bottom subtile starts at or to its left: the new offset is negative or zero.
Positive offset follows by exchanging the tiles. Thus the zero index is on
the **later-starting** side; several implementation comments said the opposite
although the branch logic and assertions used the correct side.

Finite descent makes a nonresolving leftmost orbit eventually periodic. On a
period-`r` cycle every prefix-side index is zero, hence `sigma^r(i) = i U`.
Primitivity excludes `U` empty. On the other side, composition gives
`(I - M^r) w = ab(Q)` after orienting the offset negatively. Pairing with `ell`
makes `Q` nonempty. The strict overlap inequality `-t < ell_j` makes the
remaining suffix `V` nonempty. `I - M^r` is invertible because no eigenvalue
of `M` has an `r`th power equal to one. Integrality is inherited from the
actual cycle's offset, not inferred for arbitrary occurrence data.

Iterating the prefix occurrence produces a legal right-infinite fixed ray;
the interior occurrence produces a legal two-sided fixed tiling. Translating
the latter by `t` aligns their centres at zero. Zero stays a vertex of the ray
at every cycle level and is interior to the other supertile at those levels,
hence is never a common vertex. The proposition's statement now exposes the
one-sided domain already explained in its proof; it uses the ray's displayed
hierarchy rather than an undefined two-sided centre for that ray. LC1's child-closure argument,
LC2's reachability invariance on SCCs and LC4's sign-reversing mirror involution
are consistent with this derivation. LC4's proof now excludes equality of the
two cycles as unbased cycles by their opposite signs, rather than presuming
that a fixed cycle would have to fix an individual vertex. LC3 counts at most three prefix rays by
periodic **starting letters**, not one ray per first-letter cycle.

For LC5, absence of terminal leftmost cycles in a complete finite box implies
every nonzero box vertex reaches offset zero along that function. A nonempty
strict child-closed obstruction from a swap seed would have a nonempty terminal
recurrent component. Its cycle vertices lie in the box and cannot have an
offset-zero descendant. This is a contradiction. Applying the manuscript's
half-coincidence bound (Proposition 5.47) gives finite BPA for this specimen.
The universal ledger node records this implication, with its local hypothesis
inside the statement; it does not establish the separate uniform `G1` node.

## 4. Implementation and evidence boundary

The box verdict distinguishes offset-zero reachability (`holds`) from
coincidence reachability (`productive`). Only the latter is the direct Ω/PDS
certificate. Capped graphs leave both verdicts false. Existing regressions
cover the aligned pairs, named specimens, missing seed-graph cycle vertices,
and capped refusals.

The LC walker uses occurrence indices, exact signs and an integer cycle-offset
replay. Its regression distinguishes a computed integral offset, a failed
replay and a deliberately uncomputed long-cycle offset. The recorded standing
census has 10,584 sign/shape checks, 10,128 integral replays and **456 uncomputed
offsets**. These are different warrants; a shape pass does not certify the
uncomputed arithmetic. The general integral assertion is justified by §3's
proof. No new full census is claimed by this registration.

The earlier [PR #227 cap-status review](https://github.com/larsbx/pisot-substitution-conjecture-research/pull/227#discussion_r4207186470)
also exposed a driver defect: a capped run printed `INCONCLUSIVE` but returned
success. The driver now calls a tested completion gate that raises for a cap,
inconsistent sign/shape counts or a failed integral replay, after printing the
diagnostic columns. Deliberately uncomputed offsets remain distinct from a
failed replay. The other #227 review threads concern the odd-letter family;
that family is not a dependency of these new records.

The Mojo tests now name the theorem records they guard; those declarations
are links to executable contracts, not machine proofs of the universal
theorems or the literature imports. The proof-record evidence includes this
review, its date, the inspected source revision and pending human review.

## 5. Ledger boundary and validation

The source table adds seven repository-theorem nodes and two import nodes.
`BoundedPureDiscreteSpectrum` remains the existing finite-domain claim. No
open premise or existing theorem is promoted. Generated TLA+, claim-map
bindings, index and relationship graph are regenerated together. In the
no-import model Ω and LC are established; the PDS certificate requires the
two imports. Even when every import is assumed, uniform `G1`, uniform `PDS`,
and the open overlap/strict-zipper premises remain unestablished.

Validation results are recorded in the accompanying PR's evidence table.
The added governance regressions guard the shortcut's dependency closure,
the reviewed evidence, and the distinction between a universal implication
and its undischarged per-specimen premise.

## 6. Reconciliation after merged PR #241

Sections 1–5 record the original #236 review and proposed registration at
its inspected baseline. The live node grouping and names now follow merged
#241, as mapped in [the reconciliation record](proof-ledger-reconciliation-2026-10-08.md).
The review's derivations and corrections are retained; seven competing
elementary/implication names are not separately registered. The explicit
Meyer import and per-specimen PDS certificate remain separate from the
unproved universal formal-productivity gate. No human review is inferred.
