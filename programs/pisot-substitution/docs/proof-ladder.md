# Proof ladder

The current shortest route to the Pisot Substitution Conjecture in the standing regime has **one open mathematical premise**: seedwise overlap productivity. The finite-BPA/G1 and closed-carrier programmes remain important stronger structural routes, but they are no longer prerequisites of the shortest PDS sufficiency theorem.

For detailed claim status use `docs/claim-status-and-source-map-2026-09-13.md`; for the live completion priorities use `docs/research-roadmap-2026-09-21.md`; for the latest merged weekly snapshot use `docs/completion-ledger-2026-10-02.md`; theorem statements and imported hypotheses are in `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`.

# Stable base — incidence rank, UD, and bounded discrepancy

Established on `main`:

1. `det M_sigma != 0` gives full incidence rank / letter injectivity.
2. The defect theorem gives unique decodability of the image code `{sigma(a)}`.
3. UD propagates to powers because `det M_{sigma^r}=(det M_sigma)^r != 0`.
4. G1b-1 bounded discrepancy is repository-proved by the independent reconstruction merged in PR #69.

UD is therefore a theorem, not an independent standing hypothesis. Bounded discrepancy bounds the prefix-difference walk, not balanced-state length.

The old predecessor-contraction claim and the inference `UD => bounded total padding => finite BPA` are withdrawn permanently.

# Primary completion ladder — finite seed-patch overlaps, no G1

The current shortest honest chain is

```text
primitive irreducible Pisot
=> bounded discrepancy                                  [PROVED]
=> finite seed-patch overlap graph                      [PROVED]
=> one swap seed has only productive reachable overlaps [OPEN]
=> coincidence density one / dense good set             [PROVED equivalence]
=> pure discrete spectrum                               [IMPORTED theorem]
```

The two-letter periodic swap patch uses distinct tile types; `ab` need not be a legal factor of the substitution language.

## Finite seed-patch overlap graph

**Repository-proved.** Manuscript Theorem 4.22 / PR #72 shows that every exact overlap type reachable from a swap seed lies in an explicitly bounded integer-coordinate set derived from G1b-1. This graph is finite without assuming finite BPA, Meyer structure, or unimodularity.

## Overlap productivity — the current critical gate

**OPEN (Open Problem 5.35).** For every PIP substitution it is enough to prove existence of distinct letters `a != b` such that every overlap reachable from the seed overlaps of `(ab,ba)` is productive. (The manuscript states Open Problem 5.35 for every vertex of the overlap graph; this one-seed form is the weaker statement Theorem 5.38 needs.)

Do not transfer conclusions from the stronger all-vertex premise to this one-seed gate. Proposition 5.39(iii)'s two-sided strong-coincidence consequence, the every-vertex Corollary 5.41 hitting formulation, and the cited unimodular equivalence with PDS apply to all-vertex productivity. No one-seed-to-all-vertices implication is claimed. *Correction 2026-10-08:* through PDS one does hold (Theorem 5.38 forward, Corollary FP″ back, at the October 4 chain's review status); see Theorem SC of `docs/p1-seed-strength-2026-10-08.md`. The seed still matters for the proof, not for the truth.

The seed-relative growth accounting needed for this attack is now exact:
`docs/p1-overlap-seed-growth-bridge-2026-09-17.md` proves that the
multiple-edge update counts actual residual occurrences per inherited seed
period. The unresolved step is not the occurrence dictionary but the rigidity
claim excluding a full-growth, child-closed nonproductive realized component.

The ordered strict-zipper layer now has an exact finite affine-pump lemma:
every actual child occurrence satisfies `w'=Mw+q-p`, and a replayed cycle
satisfies the iterated cycle identity. This does not close the gate. A
productive non-unimodular graph already supplies a six-edge zero-shift-free
cycle, so the missing rung must use closed nonproductivity, occurrence context,
recognizability, and any required non-Archimedean internal factors.

Proving productivity for every seed or every vertex in the union graph is stronger than necessary for manuscript Theorem 5.38.

The current obstruction normal form combines PRs #76, #82 and #88. If the gate fails, we may pass to a finite child-closed irreducible nonproductive SCC `S` with

```text
PF(N_S) = beta,
N_S V_S = V_S M^T,
rank_Q(V_S) = |A|,
spec(M) subset spec(N_S).
```

Thus a bad set is algebraically **full rank**, not rank-deficient.

PR #88 further gives an exact dichotomy:

```text
bad S
=> contains an offset-zero state (i,j,0)
   and therefore exposes a non-eventually-coincident pair {i,j}
OR
=> contains no zero-shift state
   and every child factorization is a strict no-tie prefix-grid zipper.
```

The second branch preserves information erased by the child-count matrix: the ordered sequence of top/bottom subdivision boundary events. The next contradiction should use that order together with full rank and exact prefix-Parikh geometry.

The one-step context calibration shows that equal affine overlap states can
carry unequal paired prefix-suffix addresses. The radius-`m` collar in the
iterated periodic swap patch is now an exact finite object (Lemma 1 of
`docs/p1-overlap-collar-2026-09-16.md`): on the determinant-two graph the
separation radius is `1`, and the golden zero-shift-free pump lifts to a
collared cycle at every tested radius. Bounded-context equality therefore
cannot by itself exclude zero-shift-free recurrence; the missing rung must use
child closure and nonproductivity with the exact cycle identity, not loop
deletion from affine-state or bounded-context recurrence alone.

Generic spectral growth is not enough. A residual graph containing a genuine noncoincident real overlap may itself carry the full expansion spectral radius, so `PF(N_S)=beta` is the hard residual case rather than a contradiction.

## Coincidence density and PDS bridge

**Repository-proved:** Lemma 5.36 identifies seedwise overlap productivity with coincidence density one and density of the eventual-coincidence good set. The proof does not assume that the finite-stage good sets are nested; the corrected argument uses the finite subdivision-point difference between stages.

**Imported theorem:** Barge–Štimac–Williams supplies the dense-eventual-coincidence-to-PDS implication in the precise one-dimensional Pisot-family setting checked in manuscript Imported Theorem 5.37. Hence Theorem 5.38 has no G1 hypothesis.

## Endpoint-aligned boundary case

PR #82 proves:

- swapping tiling sides preserves productivity;
- offset-zero and right-aligned seed overlaps are productive exactly in the prefix/suffix strong-coincidence cases;
- an overlap reaches an offset-zero descendant at level `m` exactly when `M^m w` is a difference of proper-prefix Parikh vectors, equivalently when inflated subtiles have a common left endpoint;
- under strong coincidence, productivity reduces to this boundary-hitting statement.

PR #88 turns this into the aligned-versus-zipper case split above without assuming strong coincidence globally (manuscript Propositions 5.43–5.44). Manuscript Lemma 5.45 records the ordered cycle equation `(I - M^r) w_0 = sum_k M^{r-1-k} d_k`: every offset of a closed irreducible obstruction is determined by the ordered address of a cycle through it and has a purely periodic expansion in the increment set `F`, with no vanishing tail in the strict-zipper branch.

PR #87 adds the contracting lower bound (Proposition 5.42): a hit at level `m` forces `|varsigma(t)| <= C_varsigma sum_{s<=m} |varsigma(beta)|^{-s}` for every contracting embedding, decided exactly in `Q(beta)`; on the corpus this bound is at most 8 while the hitting depth reaches 17, leaving a gap of up to 14 inflations that this magnitude bound does not explain (the gap includes the slack of the bound; no further attribution is drawn).

# Stronger route A — Level 2 / finite BPA

The stronger Level-2 ladder remains

```text
primitive + Pisot spectrum
=> bounded discrepancy (G1b-1)       [PROVED]
=> renewal finiteness (G1b-2)         [OPEN]
=> finite BPA (G1).
```

## Overlap-depth route to G1

**Conditional theorem** (manuscript Proposition 5.46; `docs/bpa-termination-by-overlap-depth-2026-10-02.md`, Proposition 1; mechanism of Sirvent–Solomyak 2002, Theorem 5.6, per `docs/bpa-overlap-depth-literature-gate-2026-10-02.md`). G1 has a second sufficient premise on the overlap side:

```text
primitive irreducible Pisot
=> bounded discrepancy                                   [PROVED]
=> finite seed-patch overlap graph                       [PROVED]
=> every swap seed has only productive reachable overlaps [OPEN]
=> every reachable state has length <= 2 beta^D ell_max   [PROVED implication]
=> finite BPA (G1).
```

`D` is the largest first-coincidence depth of the overlap graph. Balanced cuts are simultaneous tile boundaries because the coordinates of `ell` are `Q`-independent, and every overlap at level `n - D` has a coincident descendant inside its `beta^D`-scaled region, so consecutive cuts are at most `2 beta^D ell_max` apart. No realization hypothesis is needed: every reachable state is a gap of a swap pair `(sigma^n(ab), sigma^n(ba))`. The premise is the all-seed form, stronger than the one-seed gate of Theorem 5.38, so this arrow does not shorten the PDS route; it makes G1 a consequence of the overlap programme rather than an independent obligation.


## Half-coincidence route to G1

**Conditional theorem** (manuscript Proposition 5.47; `docs/bpa-termination-by-overlap-depth-2026-10-02.md`, Proposition 4 and Corollary 5; half-coincidence form of Sirvent–Solomyak 2002, Theorem 5.6). The overlap-depth route needs less than productivity:

```text
finite seed-patch overlap graph                           [PROVED]
=> no reachable strict zipper from any swap seed           [OPEN, issue #139 form]
=> every reachable overlap has an offset-zero descendant   [equivalent, Corollary 5]
=> every reachable state has length <= 2 beta^K' ell_max   [PROVED implication]
=> finite BPA (G1).
```

A coincidence has offset zero, so `K' <= D` and this premise is implied by all-seed overlap productivity. The vertices with no offset-zero descendant form a closed nonproductive set with no offset-zero vertex, case (b) of manuscript Proposition 5.44(iii), and every reachable such set lies inside them. So finiteness needs only the strict-zipper branch of the obstruction problem; the strong-coincidence branch (P1a, issue #138) is needed for productivity and pure discrete spectrum, not for G1.

## PDS implies G1, so G1 is necessary

**Repository-proved** (manuscript Proposition `prop:PDS-implies-G1`; ledger `PDSImpliesRepoG1`, the Theorem S route of `docs/p1b-vertex-coincidence-box-2026-10-02.md` §5.1; independently audited 2026-10-04, **human review pending**, `docs/side-notes-ledger.md` §7).

```text
pure discrete spectrum
=> no reachable strict zipper from any swap seed    [via imported coincidence rank]
=> finite BPA (G1)                                  [half-coincidence route above]
```

A reachable strict zipper yields, by Theorem B and Corollary B′ of `docs/p1b-strict-zipper-periodic-pair-2026-10-02.md`, a pair of `Phi^r`-fixed tilings with a common interior centre, an integral centre offset and no common vertex; Proposition F and Theorem R put them in one fibre of the maximal equicontinuous factor; sharing no tile they force coincidence rank at least two, which excludes PDS by Barge's coincidence-rank theorems. Those imports assume neither unimodularity nor irreducibility (`docs/coincidence-rank-imports-literature-gate-2026-10-04.md`).

This closes the direction the ladder lacked. Until now G1 was a hypothesis whose relation to the conjecture was unknown, so the boxed conditional was one sufficient route among possible others. G1 is now a **necessary** condition for PDS: any proof of PSC makes G1 true, and a counterexample to G1 would refute PSC. The realization step is not a formal-recurrence shortcut — it builds the two tilings from interior occurrences, whose patches are allowed for `sigma`, and takes integrality of the offset from the cycle equation rather than assuming it.

Together with the seedwise bridge below, the finiteness side of the programme is no longer an independent obligation: it is a consequence of the conjecture, and it is implied by either half of the obstruction problem.

## PDS implies seedwise termination (former Open Problem 4.24)

**Repository-proved** (manuscript Theorem `thm:seedwise`; ledger `PDSImpliesSeedwiseTermination` with the imported `StrongCoincidenceFromPDS`; same review status as above). PDS implies termination with coincidence from **every** seed `(ab, ba)`, legal factor or not. The repository's all-seed graph is therefore covered, not one convenient seed, and the seed-family question the ladder used to carry as open is answered. Dated notes that still call Open Problem 4.24 open are history, not status.
## G1b-2 — renewal finiteness

**OPEN; equivalent to G1 after G1b-1. Not required by Theorem 5.38.**

Prove that only finitely many reachable irreducible balanced pairs occur inside the established discrepancy bound. A bounded difference alphabet does not suffice because labelled first-return words can revisit the same nonzero difference vertices indefinitely.

The structural target is

```text
realizable labelled first-return words
=> level-scaled contracting/Rauzy address
=> finite-return / uniform-discreteness theorem
=> G1b-2.
```

The proof must remain non-unimodular-safe:

- no `|det M|=1` assumption;
- no purely Euclidean internal-space assumption where a profinite/non-Archimedean factor is required;
- no claim that `pi_s(Z^A)` is a lattice;
- preserve label/order data lost by cumulative difference walks.

### Retired Level-2 shortcuts

Do not use:

- UD implies bounded total padding;
- bounded discrepancy implies finite BPA;
- naive zero-sum-hyperplane contraction;
- every long state has a uniformly short core;
- two-letter renewal is trivial;
- unlabelled cumulative difference walk determines a balanced state.

# Stronger route B — SCC Producer under G1

Assume G1. Nonproductivity then reduces to a finite closed/sink recurrent noncoincident carrier.

The current spectral split is

```text
closed recurrent carrier
=> K2 == 0 or K2 != 0
=> [OPEN] concentration or [OPEN] wedge productivity
=> productivity
=> SCC Producer.
```

## Concentration / aux-B

**OPEN.** Equivalent in the current cubic wedge dichotomy to excluding strict components with `K2 == 0`.

The archived degree-three theorem applies only to its explicit seeds. The live degree-two carrier-span statement is independently repository-proved; no missing v16 source is required.

## Wedge productivity

**OPEN.** Equivalent to excluding strict components with `K2 != 0`. Full rational wedge span is a classification constraint, not a productivity theorem.

The exact 4,554-member corpus has fail-closed finite-domain certificates excluding both first-defect branches in their stated domains. Those certificates are not uniform theorems.

## Relation to the overlap route

A proof of general overlap productivity is stronger than needed to bypass G1. In its all-seed form it also implies G1 (the overlap-depth route above) and supplies productivity of all reachable BPA states. Therefore the overlap theorem can feed SCC Producer, but the finite-BPA carrier route is not required to prove Theorem 5.38.

# Supporting structural machinery

The following remain theoremically useful where their individual notes mark them theorem-grade:

- bad-overlap closed-SCC normal form and aligned/strict-zipper dichotomy (PR #88);
- sink-SCC reduction under G1;
- endpoint synchronization quotient and A/B eliminator;
- Barge–Diamond type-G eliminator and hub-star normal form;
- Parikh intertwiner `P_C N_C = (M_sigma) P_C`;
- orientation monodromy and signed child-count matrices;
- signed first-defect intertwiners;
- degree-3, degree-4 and generalized-Witt spectral sieves;
- ordered degree-2 mid-area factorization and integral filters;
- bounded-gap zero-return calculus;
- finite Pisot ancestry states and legal ancestry towers;
- derived recognizability and relative hierarchy-offset states.

The C4 chain

```text
C4 => C3-local => C2 => C1
```

remains a valid one-way sufficiency route. It is not the headline completion ladder.

# Realization / MEF route

The realization programme remains an open bridge / certificate route. Its audited interface has obligations G0–G6. Do not identify:

```text
formal producer-free recurrence
= global realization
= survival to a finite collar bound.
```

Finite collar death is evidence until an independent completeness theorem is available.

# Exact finite calibration

Across the exact 4,554 short-image ternary PIP corpus:

- G1b-1 cross-check: maximum reachable discrepancy `14`, with reachable state length at least `48,020`;
- every BPA build used by the finite certificates terminates below its fail-closed cap;
- seed-patch overlap graphs: `4,554 / 0 / 0` built/capped/failed;
- total overlap vertices: `1,118,850`;
- largest overlap graph: `2,640`;
- specimens containing a nonproductive overlap: `0`;
- maximum first-coincidence depth: `18`;
- maximum first left-aligned depth: `17`;
- maximum prefix and suffix strong-coincidence depths: `15`;
- all specimens satisfy the tested two-sided strong-coincidence condition;
- the degree-two and degree-three finite carrier certificates have zero survivors in their stated domains.

These are exact finite-domain results/evidence according to their individual completeness contracts. They do not prove the general conjecture.

# Hypothesis firewall

Every proposed completion proof must preserve:

1. **Swap-patch legality is not assumed.** The two-letter periodic seed in Theorem 5.38 need not be a legal substitution-language factor.
2. **Tile-length independence is derived.** Do not add rational/integer independence as a separate PSC hypothesis when irreducibility supplies it.
3. **UD is derived.** Do not make unique decodability a standing assumption.
4. **FI/boundary injectivity is extra.** Do not silently restrict to permutation/injective boundary maps.
5. **No unimodularity leak.** Unit-only converse theorems or Euclidean-only Rauzy constructions remain restricted unless separately generalized.
6. **No false stable lattice.** `pi_s(Z^A)` is generally not a discrete lattice.
7. **No realization shortcut.** Formal recurrence does not imply global realization.
8. **No computational self-certification.** Finite corpus/collar bounds require an independent completeness theorem before universal use.

# Completion order

1. **P0 — synchronization.** Keep manuscript, claim/source map, conjecture ledger, proof ladder, README, roadmap, issue statements and TLA dependency comments aligned.
2. **P1a — aligned branch (#138).** Prove the ternary two-sided strong-coincidence statement needed to eliminate every aligned bad SCC, or reduce it to a strictly smaller named theorem. Keep the Barge–Diamond two-letter/general-existence scopes distinct.
3. **P1b — strict-zipper branch (#139).** The literature transfer audit is complete. Define the full adelic prefix-difference cylinder, then prove a uniform `AdelicPeriodicOffsetHitting` recurrence/coverage lemma for realized closed SCCs.
4. **P1 — overlap productivity (#84).** Assemble P1a and P1b, or replace them with one stronger theorem excluding every bad closed irreducible SCC. This remains the only open premise on the current shortest PDS route.
5. **P2 — G1b-2.** Continue as a stronger theorem on BPA finiteness, with the non-unimodular and label/order firewalls intact. G1 now has three sufficient premises — G1b-2, all-seed overlap productivity (overlap-depth route), or all-seed strict-zipper exclusion alone (half-coincidence route) — and is in any case a necessary consequence of PDS, so G1b-2 is the least load-bearing of the three.
6. **P3 — concentration and wedge productivity.** Continue as the alternative finite-BPA/SCC route only when new invariants add information beyond child counts and full wedge span.
7. **P4 — realization bridge.** Discharge G0–G6 only if pursuing the coincidence-rank/collar certification route.

No additional fixed-size SCC sieve, collar depth, coincidence-depth census, or determinant-restricted argument should displace P1a/P1b unless it supplies a credible uniform theorem feeding #84.
