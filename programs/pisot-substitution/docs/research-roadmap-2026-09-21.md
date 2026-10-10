# PSC research roadmap — 2026-09-21

**Status:** live completion roadmap for the current research frontier. This file is a planning/status surface, not a proof source. The authoritative claim taxonomy remains `docs/claim-status-and-source-map-2026-09-13.md`; theorem statements remain in `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`; machine dependencies remain generated from `tools/make_ledger.py`.

**Standing target:** pure discrete spectrum for primitive irreducible Pisot substitutions in the repository's standing regime, **without** silently adding seed legality, unique decodability, finite injectivity, rational/integer independence, or unimodularity.

**2026-10-02 synchronization:** PRs #181–#188 add the aligned fixed-edge /
alternating-E normal form, exact M-adic carry reduction, two conditional routes
from overlap hypotheses to G1 (manuscript Propositions 5.46–5.47), and complete
separation evidence on the 24,486-member ternary total-image-length-at-most-8 class.
None discharges seedwise overlap productivity, either obstruction branch, G1,
or PSC.

**2026-10-05 synchronization (PRs #210–#213):** two results change the shape of
this plan without moving any open premise.

1. **G1 is now necessary, not optional.** Pure discrete spectrum implies finite
   `B_sigma` (manuscript Proposition `prop:PDS-implies-G1`, ledger
   `PDSImpliesRepoG1`, the Theorem S route; independently audited 2026-10-04,
   **human review pending**). So the finiteness programme is a consequence of
   the conjecture rather than an independent obligation, and a substitution
   with an infinite `B_sigma` would refute PSC.
2. **Former Open Problem 4.24 is answered.** PDS implies termination with
   coincidence from every seed `(ab, ba)`, legal factor or not (manuscript
   Theorem `thm:seedwise`, ledger `PDSImpliesSeedwiseTermination`).

Planning consequence, carried into §11 and §12 below: by Corollary 5 of the
half-coincidence route, **#139 alone suffices for G1**, while #138 is needed
for productivity and PDS but not for finiteness. Closing #139 therefore buys
G1 as a by-product. Neither result discharges #84, #138, #139 or PSC, all of
which remain open. The imports behind Theorem S assume neither unimodularity
nor irreducibility; one soft link is recorded in
`coincidence-rank-imports-literature-gate-2026-10-04.md` §4, and the status
audit is `audit-2026-10-04.md`.

**2026-10-05 weekly completion audit integration (`main@96bed675`, after PR #215):**
the general conjecture remains **open**, but the completion boundary is now
concentrated enough to guide proof effort sharply.

- The shortest route still has exactly one open premise: seedwise overlap
  productivity (#84), split into aligned #138 and strict-zipper #139.
- Unique decodability, including every substitution power, is **closed** from
  full incidence rank; it is not a Level-2 hypothesis and must not be re-added
  as one. The live Level-2 gap is labelled first-return/renewal finiteness
  (G1b-2), not decoding.
- Pure discrete spectrum implies G1 and seedwise termination with coincidence
  from every swap seed; both repository results are independently audited but
  **human review remains pending**. Thus G1 is necessary for PSC, while it is
  still not a premise of the shortest #84 route.
- #139 is the highest-leverage proof branch: its exclusion alone gives G1 by
  Proposition 5.47/Corollary 5. #138 remains independently necessary for the
  productivity/PDS assembly unless a stronger theorem bypasses the split.
- The 2026-10-04 exact evidence materially narrows mechanism search:
  13,260 formal overlap carriers contain no closed survivor; `SC_all` has no
  failure on the 408,798 total-image-length-at-most-10 domain; and the recorded
  PPVC/SC combination yields the finite-domain PDS statement on 145,806
  substitutions, a finite-domain theorem since 2026-10-08 (see below).
- The proposed one-tile reduction is false: 360 standing-corpus substitutions
  have recurrent vertices with no catch-up witness and 210 are entirely
  catch-up-free. The broader total-length-at-most-8 computation has 654
  catch-up-free specimens. One-step M-adic valuation ascent is false on every
  one of those 210 and 654 specimens; observed ascent depth reaches 25.
- Literature use remains hypothesis-sensitive: the Akiyama–Lee
  overlap/strong-coincidence implication needs its height-group hypothesis;
  Barge–Kwapisz geometric realization is unimodular-only; non-unit #139 must
  retain the finite-place coordinates of the Minervino–Thuswaldner
  representation space; and the Barge coincidence-rank fibre criterion used
  in `PDS => G1` still has one source-chain item awaiting primary-proof
  human review.

This roadmap is the weekly completion ledger as well as the live planning
surface: theorem-level results, conditional implications, finite-domain
statements, empirical mechanisms, and review dependencies must remain
separate below. No item in this synchronization promotes #84, #138, #139, G1,
or general PSC.

**Reference update at `main@ff9e5d3`:** PR #154's
[Penrose 2D interface bridge](bridges/penrose-2d-to-psc-interface-program.md)
and PR #157's [Padovan / Plastic-A conjecture program](post-proof-padovan-plastic-a-conjectures-2026-09-23.md)
are non-load-bearing research references. The Penrose analogies are strongest
for P2/G1b-2 and P4 realization; its P1b/#139 comparison supplies no adelic
hitting theorem. PR #191 repairs CI and source integrity. These merges change
no mathematical status or closure priority: #84, #138, #139, G1, and general
PSC remain open.

## 1. Completion architecture

The shortest current route is still G1-free:

```text
primitive irreducible Pisot
=> G1b-1 bounded discrepancy                          [PROVED]
=> finite exact seed-patch overlap graph              [PROVED]
=> one swap seed has only productive reachable overlaps [OPEN: #84 / Open Problem 5.35]
=> coincidence density one / dense good set           [PROVED]
=> pure discrete spectrum                             [IMPORTED: Barge–Štimac–Williams]
```

The only open premise on this route is **seedwise overlap productivity**. The live obstruction normal form splits that gate into two mathematically different branches:

```text
bad closed irreducible nonproductive overlap SCC S
=> aligned branch: S exposes a non-eventually-coincident letter pair
   [#138: two-sided strong coincidence]
OR
=> strict-zipper branch: S has no offset-zero vertex and all ordered
   child factorizations remain strict
   [#139: contracting-space prefix-hitting problem].
```

This split replaces the older roadmap item "aligned/zipper obstruction" with two explicit theorem programs. Neither branch may be hidden inside a computational bound or imported through a theorem with stronger hypotheses.

## 2. Status vocabulary

Use the following distinctions throughout planning and review:

- **Repository theorem:** proved in-repo at the stated generality.
- **Imported theorem:** literature result with exact hypotheses checked.
- **Finite-domain theorem:** exact statement over a fully enumerated finite domain only.
- **Empirical evidence:** exact or numerical observation without universal completeness.
- **Conditional theorem:** valid once named open premises are supplied.
- **Conjectural bridge:** plausible mechanism without a proof or imported theorem.
- **Open dependency:** theorem still required for completion.

A finite census, collar depth, coincidence depth, automaton size, or lack of counterexamples is never promoted to a universal theorem without an independent completeness theorem.

## 3. Stable base — closed and not to be reopened as assumptions

### 3.1 Full incidence rank and unique decodability

**CLOSED.** Full incidence rank follows in the standing irreducible/nonzero-determinant setting. The defect theorem then gives unique decodability of the substitution image code, and the same argument applies to powers because `det M_{sigma^r}=(det M_sigma)^r != 0`.

**Firewall:** UD is a derived theorem. Adding it as an independent standing hypothesis would weaken the target and is prohibited.

### 3.2 G1b-1 bounded discrepancy

**CLOSED.** The PR #69 reconstruction proves bounded discrepancy from primitivity and Pisot contraction. It does not use unimodularity and does not imply finite BPA.

### 3.3 Finite exact seed-overlap graph

**CLOSED.** Bounded discrepancy yields a finite exact graph of overlaps reachable from a periodic swap seed. The periodic comparison patch uses two tile types; `ab` need not be a legal factor of the substitution language.

**Firewall:** seed legality is not a hypothesis of Theorem 5.38 or issue #84.

### 3.4 Bad-SCC normal form

**CLOSED.** A failure of seedwise productivity reduces to a finite child-closed irreducible nonproductive SCC `S` with full-rank intersection-vector span, inherited Galois spectrum, and Perron growth `PF(N_S)=beta`.

**Consequence:** do not search for a rank-deficiency contradiction. The hard obstruction is full rank.

### 3.5 Density-to-PDS bridge

**CLOSED on the repository side plus imported theorem.** The coincidence-density/dense-good-set equivalence is repository-proved; Barge–Štimac–Williams is imported with the needed hypotheses audited. G1 is not a prerequisite of this route.

## 4. P1 — close Open Problem 5.35 / issue #84

### P1a — aligned branch: issue #138

**Target:** prove that every pair of distinct letters in every ternary primitive irreducible Pisot substitution is eventually coincident, and likewise for the reversed substitution, or prove a strictly weaker statement that is still sufficient to eliminate every aligned bad SCC from #84.

**Established inputs:**

- offset-zero/right-aligned seed overlaps are exactly the prefix/suffix strong-coincidence cases;
- a bad aligned SCC exposes a pair that is not eventually coincident;
- Barge–Diamond supplies the repository's one-good-pair input and the hub-letter eliminator/normal form;
- endpoint maps of a bad aligned component are already sharply restricted;
- a conditional automaton bound controls the least coincidence level once nonemptiness is known.

**Exact finite evidence:** the current exact 4,554-member corpus satisfies the tested two-sided strong-coincidence condition. The exact automaton run decides 40,986 ordered letter pairs and re-derives every witness; the maximum prefix/suffix strong-coincidence depth is 15.

This is **finite evidence only**. It does not establish a uniform automaton-size bound, a uniform coincidence-depth bound, or the universal ternary theorem.

#### P1a literature gate

Before adding new machinery, keep the exact scope of the classical results visible:

- Arnoux–Ito: strong-coincidence/Rauzy consequences in the stated unimodular framework;
- Barge–Diamond: all-pairs result for two letters and an existence result in general, not the desired ternary all-pairs theorem;
- Hollander–Solomyak and Sirvent–Solomyak: two-symbol PDS/balanced-pair results in their stated settings;
- known special families: evidence for mechanisms, not a replacement for the universal ternary theorem.

**Attribution firewall:** never cite Barge–Diamond as an all-pairs theorem in alphabet size three.

#### P1a 2026-10-01 milestone

The recurrent first-child pair dynamics is now completely normalized after
fixing a Barge–Diamond-good edge. A bad aligned orbit has only two recurrent
templates:

1. a **fixed bad hub edge**; or
2. the unique **alternating type-E template**, where the hub is fixed and the
   two letters of the good edge are swapped.

There is no recurrent aligned pair cycle of period greater than two. In the
alternating template the good edge never synchronizes at the left endpoint, so
its Barge–Diamond eventual-coincidence witness is necessarily an **interior**
balanced-prefix witness. See
`docs/p1a-aligned-cycle-normal-form-2026-10-01.md`.

#### P1a next proof tasks

1. **A1 — fixed-edge interior forcing (open):** prove the fixed-edge
   interior-forcing lemma using substitution-word / balanced-prefix structure
   beyond the endpoint map. Corollary 2.2 does not supply an interior witness
   for this template.
2. **A2 — alternating-E interior-witness transport (open):** transport the
   interior good-edge witness supplied by Corollary 2.2 into a zero-return
   boundary descendant of one of the two bad hub edges, or derive a
   contradiction with closed nonproductivity. The established interior
   witness is specific to A2.
3. Apply the same reduction to the suffix branch by reversal.
4. If a proposed argument uses Rauzy geometry, classify every imported step as
   unit-only or non-unit-safe before using it.

**Closure evidence:** a proof that eliminates both fixed-edge and alternating-E
aligned templates for all ternary PIP substitutions, with reversal handled
explicitly and no FI, legality, or unimodularity assumption.

### P1b — strict-zipper branch: issue #139

**Target:** eliminate a closed irreducible nonproductive overlap SCC with no offset-zero vertex by forcing a prefix-Parikh boundary hit.

For an overlap offset `w`, the required hit is

```text
exists m: M^m w in P_m(i) - P_m(j),
```

where `P_m(i)` and `P_m(j)` are proper-prefix Parikh sets. Every vertex of a closed strict-zipper SCC lies on a cycle with ordered increment address `(d_0,...,d_{r-1})` satisfying

```text
(I - M^r) w_0 = sum_{k=0}^{r-1} M^{r-1-k} d_k.
```

Thus the offsets form finitely many purely periodic algebraic addresses. The unresolved step is to force one of them into the prefix-difference set.

#### What is settled negatively

Do **not** spend the next cycle reproving any of the following as if it were sufficient:

- cycle algebra alone;
- a zero-shift-free affine pump contradiction;
- bounded symbolic context by itself;
- generic Perron growth;
- `PF(N_S)=beta` as an immediate contradiction;
- the existing contracting **lower** bound on hitting depth.

The determinant-two regression already contains a six-edge zero-shift-free affine pump inside a productive graph, and the pump survives every tested collar radius. The current lower bound says a hit cannot happen too early; completion needs an upper-bound, recurrence, covering, or separation theorem that forces a hit.

#### P1b literature baseline — completed by PR #141

Issue #139 requires a source-by-source transfer audit:

| Source | Safe role in roadmap | Generality warning |
| --- | --- | --- |
| Ito–Rao | super-coincidence/geometric coincidence machinery in its stated setting | unit/unimodular hypotheses must not be erased |
| Barge–Kwapisz | geometric coincidence and the cited converse machinery | explicitly unimodular; cannot be imported unchanged into the non-unit branch |
| Akiyama–Lee | exact overlap algorithm and residual-component spectral criterion | `rho(residual)=beta` is the hard case, not an automatic contradiction |
| Minervino–Thuswaldner | non-unit Rauzy geometry and representation space with finite-place factors | this is the correct warning against a purely Euclidean internal space |
| Barge 2016/2018 family results | identify classes where PDS is proved and the mechanism used | family theorems do not close the universal PIP branch |

The transfer table is now complete in `p1b-strict-zipper-literature-gate-2026-09-21.md`, with machine-readable hypotheses in `p1b-strict-zipper-transfer-matrix.json`. It leaves one named open obligation, **AdelicPeriodicOffsetHitting**: force a realized purely periodic offset orbit to meet the actual prefix-difference cylinder in the full non-unit representation space.

#### P1b non-unimodular theorem target

The desired theorem must be formulated in the full contracting representation needed by the non-unit case: Euclidean contracting embeddings together with the required finite-place/non-Archimedean factors. A purely Euclidean proof is acceptable only if it separately proves that the omitted finite-place coordinates are irrelevant.

The high-value target is a uniform statement of one of the following forms:

1. **recurrence/covering:** every purely periodic bad offset in the finite digit set must meet a prefix-difference Rauzy piece;
2. **separation:** a closed strict-zipper nonproductive SCC would violate a proven separation property of the full representation;
3. **finite return:** the prefix-difference dynamics has a uniform return mechanism forcing an offset-zero descendant.

The theorem must be uniform in `|S|`; another necessary-condition sieve without a completeness statement is not completion progress.

#### P1b 2026-10-01 milestone

The finite-place side now has an exact M-adic prefix-difference filter. A
level-`m` hit requires the occurrence-labelled prefix difference to be zero
in `Z^3 / M^m Z^3`. On the determinant-two golden regression only 11 of 35
level-two occurrence pairs survive; on the unimodular Tribonacci control all
12 survive, as the trivial cokernel requires.

More importantly, the descaled zero-class candidate sets obey exactly the
existing occurrence-labelled affine overlap update. Thus quotient iteration
alone does not yet supply the missing forcing theorem: after descaling it reconstructs the reverse zero-offset basin of the
same affine graph. A separate finite-quotient completeness or coverage theorem
could still establish entry into that basin and is not excluded by this
identity. See `docs/p1b-madic-carry-reduction-2026-10-01.md`.

#### P1b 2026-10-08 synchronisation

Since the 2026-10-01 milestone, #139's obligation (boundary hitting at every
seed-reachable strict-zipper vertex) is decidable per specimen (`BH ⟺ PPVC`
on the box automaton, #211). On the catch-up-free `|det M| = 2` class it is
the whole of PSC, outside the open part of Theorem K's family (#232,
Proposition Z). It is proved on 47 infinite one-parameter families of
Theorem E's classes: Theorem L (#232), Theorem L′ (#234) and Theorem L″
(`p1b-boundary-hitting-progress-2026-10-08.md`). By Theorem W of the same
note, it is also proved on two-parameter wedges: every PIP member of class D
with `r ≥ q − 1`. The universal, uniform-in-`|S|` statement is untouched. The PR-by-PR account and the ordered next steps
(two-parameter wedges, vertex families for class A at slope 1, a uniform
depth bound on the class) are in that note.

#### P1b next proof tasks

1. Require a proved completeness or coverage map for any finite-quotient
   closure argument; quotient-depth accumulation alone does not supply it.
2. Prove the **occurrence-compatible adelic coverage lemma**: a realized
   periodic strict-zipper orbit must enter the graph-directed prefix-difference
   subtile corresponding to its reverse zero basin.
3. Keep the determinant-two affine pump, collar collision, unimodular control,
   and a genuine non-unit finite-place specimen as mandatory negative/positive
   controls.
4. Preserve ordered child occurrences and exact arithmetic in any executable
   theorem interface.

**Closure evidence:** a uniform full-representation hitting/coverage theorem
eliminating every strict-zipper bad SCC, or a further exact reduction that
strictly shrinks that theorem without reverting to another necessary-condition
sieve.

### P1 assembly

Issue #84 closes when the aligned and strict branches are both excluded, or when a single stronger theorem excludes every bad closed SCC directly.

No proof of G1b-2, finite BPA, concentration, wedge productivity, or realization is required by the current shortest PDS theorem.

## 5. P2 — Level 2 / G1b-2 renewal finiteness

**Status: OPEN, stronger parallel program; G1 is now known to be necessary for
PDS, but G1b-2 is not a dependency of the shortest #84 route.**

The target remains:

```text
G1b-1 bounded discrepancy [PROVED]
=> G1b-2 renewal finiteness [OPEN]
=> finite BPA (G1).
```

The decoding issue is closed. Full incidence rank gives `det M != 0`; the
defect-theorem argument gives unique decodability of
`{sigma(a): a in A}`, and the same argument applies to every power because
`det M_{sigma^r} = (det M_sigma)^r != 0`. **UD is therefore a derived theorem,
not a Level-2 assumption.**

What remains open is memory/return control. Bounded discrepancy controls the
difference walk but not the length, labels, order, or return memory of an
irreducible balanced pair. The standing corpus makes the separation explicit:
maximum reachable discrepancy is 14 while a reachable balanced-pair state has
length 48,020.

The useful structural program is

```text
realizable labelled first-return word
=> level-scaled contracting/adelic address
=> finite local return types / uniform discreteness
=> G1b-2.
```

**Retired Level-2 inference:** the old upgrade
`UD => uniformly bounded coincidence padding => finite BPA` is not available.
The complete-cutting phase argument controls only its own recurrence regime,
and the former predecessor-contraction inequality fails because a selected
child can carry only part of the inflated parent while noncoincident mass moves
to siblings. A replacement theorem must control realizable labelled returns,
not merely the norm of the cumulative difference.

**Independence/unimodularity firewall:**

- UD is already derived and may not be assumed as an extra premise.
- Any rational/integer tile-length independence used to identify geometric
  cuts with Parikh cuts must be derived from the standing irreducible/full-
  degree setting at the point of use, not added to the theorem statement.
- A bounded difference alphabet does not imply finite BPA.
- Do not replace the full non-unit internal space by a Euclidean stable plane.
- Do not treat `pi_s(Z^A)` as a discrete lattice.
- Preserve labels and order; the unlabelled cumulative difference walk is not
  a state classifier.

**Closure evidence:** a uniform finite-return theorem for every realizable
labelled first return in the standing PIP regime, with no independent UD,
tile-length-independence, or unimodularity assumption.


## 6. P3 — finite-BPA SCC route

**Status: OPEN parallel route, conditional on G1.**

Once a finite closed recurrent noncoincident carrier exists:

```text
K2 == 0  => concentration problem      [OPEN]
K2 != 0  => wedge productivity problem [OPEN].
```

The degree-two carrier-span theorem is proved. Full rational wedge span is a classification constraint, not a productivity theorem.

The exact 4,554-member corpus has zero survivors in the current degree-two and degree-three finite certificates. Those are finite-domain theorems only.

**Next task:** only pursue a new carrier invariant if it uses ordered/ancestral data absent from the child-count and wedge-span reductions. Do not add another fixed-size sieve unless it has a credible uniform completeness theorem.

## 7. P4 — realization / MEF / coincidence-rank route

**Status: OPEN bridge, secondary.**

Keep distinct:

```text
formal recurrent obstruction
!= global realization
!= survival through a finite collar.
```

The G0–G6 interface remains the governing checklist. The empirical fact that formal producer-free cycles die in tested collars is evidence, not a realization theorem.

**Closure evidence:** a rigorous implication from the formal recurrent obstruction to a globally realized tiling obstruction, or a uniform theorem excluding such realization.

## 8. Computational program

### Current exact evidence

On the declared 4,554-member ternary short-image PIP corpus:

- overlap graphs built / capped / failed: `4554 / 0 / 0`;
- total exact overlap vertices: `1,118,850`;
- largest graph: `2,640`;
- specimens containing a nonproductive overlap: `0`;
- maximum first-coincidence depth: `18`;
- maximum first left-aligned depth: `17`;
- maximum prefix/suffix strong-coincidence depth: `15`;
- ordered letter pairs decided by the coincidence automata: `40,986`, with
  every witness re-derived;
- unit/non-unit split: 2,628 unimodular and 1,926 determinant-two specimens;
- maximum reachable balanced-pair discrepancy is 14 while a reachable state
  reaches length 48,020.

The exact formal-carrier census on the same corpus is a stronger negative
control than the historical collar heuristic:

- formal carriers: **13,260**;
- realized / unrealized: **6,078 / 7,182**;
- closed carriers: **0** in both classes;
- formal nonproductive states outside the certified box: **0**.

See `evidence/formal-overlap-carriers-2026-10-04/summary.txt`. The old
unreproducible historical figures for producer-free cycles/collar death are
not a closure input.

The exact strong-coincidence census reports no `SC_all` failure on:

- the standing 4,554 corpus;
- the 24,486 total-image-length-at-most-8 domain;
- the 135,990 image-length-at-most-4 domain;
- the 408,798 total-image-length-at-most-10 domain.

With the separately recorded PPVC runs, the repository records a
**finite-domain PDS statement on 145,806 substitutions** (the union of image
length at most 4 and total image length at most 8). This is not a universal
theorem. *Update 2026-10-08:* it is recorded as the finite-domain theorem
`BoundedPureDiscreteSpectrum`. It no longer depends on Proposition V(2) or
Theorem B: Theorem Ω of `docs/pds-certificate-from-the-box-automaton-2026-10-07.md`
needs only the elementary step 1 of Proposition V, and either the imported
Lee–Moody–Solomyak criterion or Theorem 5.38. The two larger rows are guarded
by `.github/workflows/box-automaton-evidence.yml`. See also
`docs/strong-coincidence-census-2026-10-04.md`.

The exact catch-up/hit-witness census falsifies the proposed universal
one-tile reduction. Among 1,154,040 recurrent nonzero vertices in the standing
corpus, 1,056,816 reach a catch-up witness and 97,224 are simultaneous-only;
360 substitutions fail universal catch-up and 210 are entirely catch-up-free.
The total-image-length-at-most-8 computation contains 654 catch-up-free
substitutions. The proposed one-step M-adic valuation ascent then fails on all
210 and all 654 catch-up-free specimens; observed ascent depth reaches 25.

On the broader 24,486-member total-image-length-at-most-8 class, the canonical
separation sweep completed with no inconclusive specimen at its declared caps:
23,634 specimens have finite least separation radius (maximum `9`), while
852 have an exact proper-power collapse witness by level `6`. The radius
histogram is
`1:2264, 2:13688, 3:6092, 4:1230, 5:288, 6:60, 9:12`, independently
reproduced.

The exact cubic arithmetic audit reports zero disagreements against the
independent oracle on its declared tests, including wide-magnitude
Perron-sign checks.

### Generalization warning

The 4,554 corpus is not determinant-representative of the full non-unit
problem. The broader image-length-at-most-four screen contains determinant
classes `-2,-1,+1,+2,+3`, whereas the standing corpus contains only
`-1,+1,+2`.

Therefore determinant-two success or failure must not be promoted to "the
non-unimodular case", and no finite-domain depth/radius/collar maximum is a
universal bound without an independent completeness theorem.

### Role of computation going forward

Use computation to:

- falsify a named proposed universal lemma quickly;
- retain minimal replayable countermodels;
- measure which extra ordered/address data separate good from bad recurrence;
- audit source-to-code theorem predicates and finite-domain theorem premises;
- stress non-unit determinant classes outside the original corpus.

Do not use another deeper finite search as the closure condition for P1a,
P1b, or G1b-2 unless a separate theorem proves the search complete.


## 9. Hypothesis and attribution firewall

Every roadmap item must fail review if it silently uses any of the following:

1. **Seed legality:** `ab` need not be a language factor.
2. **Independent tile-length independence:** derive rational/integer
   independence from the standing irreducible/full-degree setting where used;
   cite that derivation at every load-bearing balanced-cut step.
3. **Independent UD:** UD, including UD for powers, is already derived from
   full incidence rank and may not be promoted to a standing assumption.
4. **FI / boundary injectivity / prefix-suffix permutation:** extra hypotheses
   unless explicitly stated as a restricted theorem.
5. **Unimodularity:** `|det M|=1` may define a restricted subtheorem, never
   the general completion theorem.
6. **Purely Euclidean non-unit geometry:** forbidden unless the finite-place
   coordinates are proved irrelevant. For #139, the Minervino–Thuswaldner
   adelic representation is the safe ambient model.
7. **Stable-lattice shortcut:** `pi_s(Z^A)` is not to be treated as a
   discrete lattice in the needed non-unit generality.
8. **Formal-to-real realization:** a graph cycle is not automatically a
   realized tiling object.
9. **Finite-search completeness:** no corpus/collar/depth threshold is
   universal without an independent theorem.
10. **Rank deficiency:** bad overlap SCCs are already known to be full rank.
11. **Residual spectral gap by naming:** Akiyama–Lee makes the residual
    spectral comparison load-bearing; `rho=beta` is the hard case, not an
    automatic contradiction.
12. **Akiyama–Lee strong-coincidence shortcut:** do not import an
    overlap-coincidence-to-strong-coincidence implication without its
    height-group hypothesis. The non-unit project route supplies the needed
    return/height information only through the separately proved Theorem R,
    which remains human-review pending.
13. **Barge–Kwapisz generalization:** their geometric-realization machinery is
    unimodular; deleting that hypothesis would silently change the theorem.
14. **Coincidence-rank source-chain overstatement:** `PDS => G1` is
    repository-proved at the current ledger status, but the imported
    disjoint-fibre/coincidence-rank item recorded from Barge still has a
    primary-proof source-chain check pending. Preserve the human-review flag.
15. **Strong-coincidence over-attribution:** do not turn the two-letter
    Barge–Diamond result into a ternary all-pairs theorem.
16. **Special-family promotion:** beta-substitution, injective-initial /
    constant-final, or other family theorems settle those classes only.
17. **Preprint promotion:** claimed general proofs remain non-load-bearing
    until their hypotheses, theorem version, and proof status are independently
    validated.

The generality audit is part of completion, not editorial cleanup: any proof
that reaches PSC only after inserting independence, legality, FI, or
unimodularity has proved a weaker theorem and does not close the roadmap.


## 10. Retired or demoted attacks

Do not spend primary proof effort on:

- `UD => bounded total padding`;
- bounded discrepancy alone `=>` finite BPA;
- the old predecessor-contraction inequality for a selected BPA child;
- naive contraction of the zero-sum hyperplane;
- uniformly short cores in every long balanced state;
- unlabelled difference-walk classification;
- universal exclusion of recurrent noncoincident cycles;
- one-step descent of a contracting norm as the forcing theorem;
- endpoint-only hitting;
- the claim that every recurrent vertex reaches a catch-up witness;
- one-step M-adic valuation ascent on the catch-up-free class;
- a universal law `K_V <= c/log(1/mu)` without new structure;
- rank-deficient bad SCCs;
- generic Perron-growth contradiction;
- automatic `rho(residual)<beta`;
- affine-cycle pumping without symbolic/realization control;
- bounded collars as a completeness theorem;
- a unimodular-only argument presented as general PSC;
- another fixed-size SCC sieve without a path to uniformity.

Countermodels and failed routes remain part of the project evidence and should
stay replayable. A falsified bridge is a closed item in the completion ledger:
do not quietly resurrect it under a new name.


## 11. Prioritized completion ledger

| Priority | Item | Status | Evidence needed to close | Immediate next deliverable |
| --- | --- | --- | --- | --- |
| **P0** | Status/provenance synchronization | current through `main@96bed675`; this roadmap is the live weekly completion surface | roadmap, proof ladder, claim map, manuscript, generated ledger and README preserve the same theorem/review boundary | keep #84/#138/#139, PDS=>G1, and finite-domain statements synchronized without promoting review-pending inputs |
| **P1b** | Strict-zipper hitting (#139) | **OPEN critical; highest leverage** — literature, periodic-pair, cylinder and M-adic carry reductions established | uniform non-unit-safe occurrence-compatible adelic hitting/coverage theorem, or a strictly smaller equivalent theorem | prove that every realized periodic zipper orbit enters its graph-directed reverse zero basin in the full representation |
| **P1a** | Aligned strong coincidence (#138) | **OPEN critical; the two templates are one at the square (Theorem C, 2026-10-05); A1′ proved on the whole catch-up-free `|det M| = 2` class (Theorem E), with all-pairs strong coincidence on its two-odd-letter part (Corollary H1) and outside one explicit family (Theorem K); inside that family Theorems Φ, Λ, Λ′, Λ″ close four `Delta` cells and Theorem Ζ every `Delta` with `Z_2` bounded (2026-10-07)** | uniform proof of A1′ (a bad edge whose letters are both `h`-fixed is eventually coincident), including reversal | on Theorem K's family, close unbounded `Z_2` (Lemma P1 linearized, `2 zfloor`; A1′ note §3m); in general, prove A1′ from the fixed-letter hypothesis, not via transitivity of eventual coincidence |
| **P1** | Seedwise overlap productivity (#84) | **OPEN — sole shortest-route premise** | P1a + P1b, or one stronger theorem excluding every bad closed SCC | assemble only after branch closure; do not substitute a larger finite census |
| **Review-0** | `PDS => G1` dependency package | **repository-proved; independently audited; human review pending** | direct human check of Theorem R, Proposition F, Theorem B/Lemma C and the primary proof chain behind the Barge fibre/coincidence-rank criterion | audit Theorem R and the Barge source chain first; both protect the non-unimodular import boundary |
| **P2** | G1b-2 renewal finiteness | **OPEN parallel; G1 is necessary for PDS but this is the least load-bearing of the three G1 routes** | uniform finite-return theorem for realizable labelled first returns | develop non-unit level-scaled labelled return/address theory; do not reuse UD-padding or predecessor contraction |
| **P3a** | Concentration, `K2=0` | **OPEN parallel under G1** | uniform exclusion of strict zero-wedge closed carriers | use ordered/ancestral information absent from current span data |
| **P3b** | Wedge productivity, `K2!=0` | **OPEN parallel under G1** | theorem converting full wedge span plus recurrence/order into coincidence | identify an order-sensitive invariant beyond the existing span classification |
| **P4** | Realization / MEF bridge | **OPEN secondary** | theorem relating formal recurrence to global realization, or excluding realization uniformly | preserve the formal/realized/collar firewall while testing any candidate bridge |
| **Support** | Exact computation and arithmetic | **strong finite evidence, not universal closure** — 13,260 formal carriers with no closed survivor; `SC_all` no failure through 408,798; finite-domain PDS statement on 145,806 | no amount of additional depth closes PSC without a completeness theorem | use exact runs to kill named mechanisms and preserve minimal countermodels, especially across non-unit determinant classes |
| **Estate** | Verification/provenance safeguards | **partially open** — large PPVC runs remain outside CI and branch protection/enforced status checks are administrative gaps | CI/governance coverage matching the claims actually cited | improve verification plumbing without changing mathematical status |


## 12. Highest-value task order

For the next research cycle:

1. **#139 occurrence-compatible adelic coverage first.** The literature
   baseline, full-representation cylinder, periodic-pair realization, M-adic
   compatibility filter, and integral carry recursion are explicit. Prove that
   a realized periodic strict-zipper orbit enters the graph-directed reverse
   zero basin. Deeper quotient iteration is not progress without a theorem
   saying why entry must occur.
2. **#138 template exclusion in parallel.** The aligned recurrent dynamics has
   only a fixed bad hub edge (A1) or the alternating type-E template (A2).
   For A1, prove the open fixed-edge interior-forcing lemma using
   substitution-word / balanced-prefix structure. For A2 only, transport the
   interior Barge–Diamond-good-edge witness supplied by Corollary 2.2 into a
   zero-return boundary descendant or derive a contradiction with closed
   nonproductivity. Handle both suffix cases by reversal. Theorem C
   (`p1a-template-collapse-2026-10-05.md`) makes the two templates one at the
   square: the obligation is A1′, *two one-sided fixed points anchored at a
   common point share a tile*. On the catch-up-free `|det M| = 2` class it is
   proved (Theorem E), and all-pairs strong coincidence holds there except on
   one explicit family (Theorem K, `p1a-a1-prime-2026-10-05.md` §3e); inside
   it the cells `delta = e_z`, `(s, Delta) = (+1, 1), (−1, −1), (−1, 0)` and
   every `Delta` with `s = +1, Z_2 <= 2` or `s = −1, Z_2 <= 3` are closed
   (Theorems Φ, Λ, Λ′, Λ″, Ζ; §§3g–3m). Unbounded `Z_2` is the open part,
   where Lemma P1 is needed only linearly (side-notes ledger, 2026-10-07).
3. **Human-review the `PDS => G1` chain without delaying P1 proof work.**
   Follow the Barge coincidence-rank/disjoint-fibre source chain to its primary
   proofs and recheck Theorem R, Proposition F and Theorem B/Lemma C. This is a
   review dependency, not a new open mathematical premise.
4. **Keep G1b-2 active as the Level-2 theorem, not as a hidden PSC dependency.**
   The target is labelled first-return finiteness in the full non-unit
   representation. UD is closed; bounded discrepancy and a finite difference
   alphabet do not control return memory.
5. **Use the catch-up-free and affine-pump specimens as mandatory negative
   controls.** Any proposed local monotone, valuation ascent, Euclidean-only
   hitting theorem, or endpoint-only forcing rule must first survive the 210
   standing and 654 total-length-at-most-8 catch-up-free cases.
6. **Do not expand fixed-size sieves unless they test a specific uniform
   lemma.** The 408,798-substitution `SC_all` result and 145,806 finite-domain
   PDS statement are calibration evidence, not substitutes for #138/#139.
7. **Enforce the hypothesis firewall during proof construction, not after it.**
   Every use of tile-length independence, a lattice, a torus, a Euclidean
   internal space, strong coincidence, or coincidence rank must carry the
   derivation/import that makes it valid in the standing non-unit target.

A successful week is not "more specimens passed." It is one of:

- P1b reduced to a strictly smaller source-checked non-unit hitting theorem;
- P1a reduced to a strictly smaller endpoint/occurrence theorem;
- one of those theorems proved;
- the `PDS => G1` human-review chain fully discharged;
- G1b-2 advanced by a genuine labelled-return finiteness lemma;
- or a proposed bridge falsified by a retained exact countermodel, thereby
  shrinking the search space without weakening the hypothesis firewall.

