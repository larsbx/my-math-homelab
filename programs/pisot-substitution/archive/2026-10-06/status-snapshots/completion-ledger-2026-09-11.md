# PSC weekly completion ledger — 2026-09-11

**Status:** dated weekly ledger, a **historical snapshot as of 2026-09-11**. It is not a live record: every Level-3 statement in this file that treats concentration / aux-B as the sole remaining closed-carrier obligation was superseded on 2026-09-13 by the merged manuscript (`manuscripts/PSC_balanced_pair_state_2026-09-13.tex`, Proposition 5.20), which shows that the spectral route has two independent open obligations, concentration (no strict component with `K2 == 0`) and wedge productivity (no strict component with `K2 != 0`). For the current state read `docs/conjecture-ledger.md`, `docs/proof-ladder.md`, and `docs/current-proof-architecture-2026-09-11.md`. This file records the completion state of the proof program as of 2026-09-11 and the prioritized obligations that remained then. The live undated records are `docs/conjecture-ledger.md`, `docs/current-proof-architecture-2026-09-11.md`, `docs/proof-ladder.md`, and the machine-checked dependency form `proof/tla/Ledger.tla`. Where this ledger cites a result or a figure that cannot be reproduced from files on `main`, section X says so.

## Executive status

The project is not at a complete proof. The remaining mathematics is substantially more sharply isolated than in the v12-era architecture. The current frontier is the v16-track architecture plus the later realization/rank reformulation.

There are two genuinely independent proof gates.

| Gate | Status | What remains |
| --- | --- | --- |
| Level 2 / G1: finiteness of the balanced-pair automaton | **OPEN** | G1b-2 renewal finiteness |
| Level 3 / SCC Producer | **CLOSED MODULO one concentration lemma** in the strongest current attack (*superseded 2026-09-13*: the merged manuscript's wedge dichotomy shows the route has two independent open obligations, concentration for the `K2 == 0` case and wedge productivity for the `K2 != 0` case; see `docs/conjecture-ledger.md`) | *as recorded on 2026-09-11:* show dominant wedge growth concentrates in a closed recurrent carrier, then the Galois/span-rich machinery applies; *superseded:* wedge productivity (the `K2 != 0` case) is a second, independent open obligation |

The important correction from earlier versions: unique decodability (UD) is no longer an open issue, but **UD does not prove Level-2 finiteness**. The former padding argument silently crossed that gap. The v16 track explicitly retracts that inference.

The later MEF/realization work gives a valuable equivalence (nontrivial coincidence rank corresponds to a globally realized producer-free recurrent BPA component), but it is a reformulation/certificate framework, not a third proof of PSC. Its finiteness hypothesis is downstream of G1, and "globally realized" contains essentially the remaining coincidence obstruction.

## I. Current proof architecture

The most defensible current proof stack is

```text
primitive irreducible Pisot  =>  det M_sigma != 0  =>  UD
```

followed by two distinct branches.

### Level 2 — finiteness

```text
PIP  =>  quotient contraction  =>  bounded discrepancy (G1b-1)
```

and then the still-open implication

```text
[OPEN G1b-2]   bounded discrepancy + renewal structure  =>  |B_sigma| < infinity.
```

G1b-1 is theorem-grade in the v16 track: the adapted Lyapunov norm gives

```text
Disc(sigma w) <= c Disc(w) + 2 E_sigma,    c < 1.
```

Bounded height does not bound state length. A reduced difference walk can cycle indefinitely among nonzero lattice points while remaining inside the bounded box. The v16 track therefore isolates G1b-2 as:

> for fixed `R0`, only finitely many reduced interior-zero-free balanced pairs with `R(s) <= R0` are actually realizable.

This is a renewal/recognizability problem, not a norm estimate.

### Level 3 — coincidence

Assuming G1,

```text
|B_sigma| < infinity  =>  recurrent SCC analysis.
```

Universal exclusion of recurrent noncoincident cycles is no longer the target. Flipped Tribonacci killed that target: recurrent, noncoincident, zero-displacement cycles genuinely occur (`proof/tla/MCFlippedTribonacci.tla`). The corrected target is **SCC Producer**: recurrent noncoincident behavior cannot remain permanently producer-free.

The present closed-case route is

```text
closed recurrent SCC
  =(concentration)=>  phi_dom != 0
  =(Galois)=>         phi_1, phi_2, phi_3 != 0
  =>                  W_C = Lambda^2 R^3
  =>                  span-rich
  =>                  productive.
```

The Galois step is a real advance: irreducibility of `chi_{Lambda^2 M}` makes the wedge eigenfunctionals Galois conjugates, so the previously separate subdominant nonvanishing obligations disappear together. The remaining Gate-1 assumption is concentration of the expanding component in the closed carrier.

> **Superseded 2026-09-13 on the Level-3 gate.** The merged manuscript (`manuscripts/PSC_balanced_pair_state_2026-09-13.tex`, Proposition 5.20) shows that the spectral route has *two* independent open obligations: concentration (no strict component with `K2 == 0`) and wedge productivity (no strict component with `K2 != 0`). Concentration alone does not close Level 3. The live statement is in `docs/conjecture-ledger.md`. In the chain above, the final arrow `span-rich => productive` is the open wedge-productivity step.

This must not be conflated with G1b-2. That apparent unification was tested and rejected: Gate 1 is algebraic nonvanishing; Gate 2 is contracting-side renewal/discreteness.

## II. Level 2 / UD audit

### Established

**UD is closed.** The clean theorem requires only `det M_sigma != 0`. It does not require Pisot, primitivity, recognizability, or unimodularity: the defect theorem plus full incidence rank suffice (`archive/2026-09-08/manuscripts/PSC_PROOF_v15.tex`, Theorem `thm:UD`). UD must therefore not appear as an independent hypothesis in the final theorem.

The power-iterated version is available because

```text
det M_{sigma^r} = (det M_sigma)^r != 0.
```

**G1b-1 is closed in the v16 track.** Bounded discrepancy and the norm-conversion seam are proved there; the tests report no soundness violations in the corpus. Its detailed source is not yet on `main` (section X). *[2026-09-13: superseded; G1b-1 was independently reconstructed and proved without the contraction estimate, see `sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md`.]*

### Open

**G1b-2 is the exact Level-2 bottleneck.** The computational anatomy reported by the v16 audit:

| Quantity | Observed |
| --- | --- |
| difference vertices | 135 |
| edges | 623 |
| observed `(d, 2-window)` configurations (finite local closure) | 1,425 |
| BFS discovery saturation depth | <= 43 |
| first-return data carried by a single reduced state | length >= 17,078 |
| revisits of one difference vertex by one state | thousands |

So there is a finite local alphabet but apparently unbounded internal return data. That is exactly why the retired arguments below cannot work.

### Retired Level-2 arguments

Permanent "do not re-attempt without genuinely new input" entries.

1. **UD => bounded total padding.** False as used. The phase automaton only excludes complete-cutting non-diagonal recurrence; its `D(sigma)` counts phase states and does not control nonzero-offset recurrence or total padding length.
2. **Bounded discrepancy => finitely many balanced pairs.** False. Bounded-height walks can be arbitrarily long.
3. **The zero-sum hyperplane contracts in the naive norm.** False in the tested setup; a counterexample has spectral radius `1.155 > 1`.
4. **Long states contain a uniformly short core.** False: determinant-2 examples produced cores thousands of symbols long.
5. **Two letters make the renewal argument trivial.** False. Even a one-dimensional bounded `+-1` walk can bounce without returning to zero; the known two-letter theorem uses deeper substitution structure.
6. **Unlabelled difference walks determine states.** False: the audit found collisions, and `docs/p1b-labelled-renewal-program.md` pins the canonical `(001,100)` vs `(021,120)` collision. The labelled transition sequence carries information lost by the cumulative `d`-walk.

The best current Level-2 direction is the proposed level-scaled contracting/Rauzy address, but it must establish a genuine finite-return/Delone property rather than another bounded-norm statement. See section X on how this differs from the archived dead-ended Rauzy routes.

## III. Level 3 / SCC Producer ledger

### Established theorem-level pieces

- **Collision-producer lemma.** Equality of the initial image letters forces a coincidence single immediately. It accounts for 198/300 closed SCC specimens in one census and was checked on 4,086 collision-pair states.
- **Length identities** are exact:

  ```text
  |sigma(u_s)| = sum_c ell(c) + leak(s).
  ```

- **Leg-factor construction** upgraded from a deferred sketch to a proof: in the closed-nonproductive case `Sigma_C` is a genuine substitution with incidence `N_C^T`, and the first-leg map gives the required factor once `PF(N_C) = beta`.
- **Galois-conjugacy step** eliminates the former subdominant-eigenfunctional gap.

### Remaining conjectural bridge

> **Concentration / aux-B.** Under G1, the expanding wedge contribution generated by recurrent behavior has nonzero projection in a closed recurrent carrier.

Once derived rather than assumed, the Galois theorem forces the full wedge span and gives productivity of the closed obstruction. This is substantially narrower than the original SCC Producer conjecture.

> **Superseded 2026-09-13 on the Level-3 gate.** The merged manuscript (`manuscripts/PSC_balanced_pair_state_2026-09-13.tex`, Proposition 5.20) shows that the spectral route has *two* independent open obligations: concentration (no strict component with `K2 == 0`) and wedge productivity (no strict component with `K2 != 0`). Concentration alone does not close Level 3. The live statement is in `docs/conjecture-ledger.md`. The implication "full wedge span gives productivity" in the preceding sentence is not established; it is the open wedge-productivity problem.

### Why the pure spectral bound is insufficient

The earlier auxiliary spectral bounds do not by themselves prove productivity. The lower bound

```text
PF(N_C) >= beta |beta_2|
```

cannot contradict the exact ceiling

```text
PF(N_C) = beta
```

that the Parikh intertwiner gives on a strict closed nonproductive component (`docs/c4-parikh-intertwiner.md`). The interval is nonempty, so no contradiction is available from spectra alone.

## IV. Realization / MEF route

Under the finiteness hypothesis `H-fin`, the project has the equivalence

```text
cr(sigma) > 1
  <=>  exists distinct non-eventually-coincident tilings in one MEF fibre
  <=>  B_sigma^r contains a recurrent producer-free component that is globally realized.
```

For PSC this gives the normal form

```text
cr(sigma) = 1   <=>   no producer-free recurrent component is globally realized.
```

This converts the spectral problem into a realizability/nonexistence problem. It is not a proof of PSC: "globally realized" is load-bearing, and assuming that a formal BPA cycle persists through collars of every radius is precisely where the hard mathematics has moved.

The route has eliminated two mirages:

- `pi_s(Z^A)` is generally dense, so naive internal-lattice discreteness cannot close the argument;
- there is no justified general shortcut of the form `cr | det M_sigma`.

## V. Computational evidence

Strong enough to guide proofs; none of the finite bounds may be promoted to universal theorems.

### UD / incidence-rank evidence

The older exhaustive three-letter census contains 59,319 substitutions with image length at most three. Among them 7,491 were non-UD, and every non-UD case had `det M_sigma = 0`, exactly as the defect-theorem result predicts.

### Level-2 evidence

Across the 4,554 PIP specimens in the principal alphabet-three corpus, the computed BPA is finite in every case, with reduced-state imbalance at most 14. The obstacle is therefore not evidence of divergence; it is the absence of a theorem converting the observed renewal saturation into finiteness.

### Producer evidence

| Test | Result |
| --- | --- |
| closed recurrent SCCs productive | 300/300 |
| positive coincidence leakage | 200/200 |
| closed SCCs span-rich | 500/500 |
| closed + cyclic state => span-rich/productive | 400/400 |
| depth-one production in closed SCCs | 300/300 |
| closed-nonproductive triple SCCs across 4,554 PIP specimens / 759 relabeling orbits | 0 |

### Realizability evidence

| Quantity | Result |
| --- | --- |
| formal producer-free cycles | 1,764 |
| globally surviving cycles at tested collars | 0 |
| maximum observed death radius | 7 |
| collar tested to | 40 |

This is stronger than "no counterexample found": it identifies where the formal counterexamples fail. It remains empirical because no theorem says collar 40, or any fixed collar, is complete.

## VI. Contradictions and corrections

Carry these into the next manuscript audit.

1. **Level-2 padding claim — corrected.** The claim that UD + phase automaton supplied a complete padding bound is not defensible. The v16 track weakens it to a diagnostic statement. This is the largest architectural correction since v12.
2. **Gate-1/Gate-2 unification — refuted.** The producer obstruction and the renewal-finiteness obstruction are not two faces of one eigenvalue phenomenon; the Galois bridge test disproved that reading. Keep the gates independent.
3. **Pure spectral attack on SCC Producer — insufficient.** The `beta |beta_2|` lower bound cannot contradict the `beta` ceiling (section III).
4. **Closed versus closed-nonproductive — corrected.** The triple mass-balance condition must say closed nonproductive, not merely closed. Closed productive SCCs with `PF(N_C) < beta` exist.
5. **Span-rich theorem overclaim — corrected.** "No pure `beta`-zero closed SCC" depended on dominant-eigenspace intersection and is demoted until concentration is proved.
6. **Aperiodicity sentence — must be repaired.** The manuscript says aperiodicity is "automatic for primitive substitutions on `|A| >= 2`" (`PSC_PROOF_v15.tex` line 140; the same wording is reported in the v16 text). False as written: `a -> ab, b -> ab` is primitive and periodic. It does not threaten the PIP theorem (that example has singular/reducible incidence), but the manuscript must either derive aperiodicity from the full irreducible-Pisot standing hypotheses or retain it as a separate standing condition. Do not cite primitivity alone.
7. **Pisot versus recognizability wording — must be repaired.** Mossé recognizability follows from primitive + aperiodic structure; Pisot is not what supplies it. v15 line 114 ("the Pisot character of beta enters indirectly through Mossé recognizability") must be rewritten; the final input list (v15 line 574) already separates the roles correctly.
8. **Two-letter attribution — must be tightened.** Barge–Diamond 2002 prove strong coincidence for every pair when `d = 2`, not merely a "one seed" result (compare v15 line 576); their general-`d` result is the partial existence statement. Sirvent–Solomyak separately establish pure discrete spectrum for every two-symbol Pisot-type `R`-action. The bibliography must distinguish: Barge–Diamond (strong coincidence, `d = 2`); Sirvent–Solomyak (two-symbol PDS / BPA-overlap connection); any Hollander–Solomyak result cited only for its exact bridge/equivalence.

The full checklist is `docs/manuscript-p0-corrections-2026-09-11.md`.

## VII. Independence and unimodularity firewall

Make these explicit in every future proof audit.

- **Hidden independence risk — tile lengths.** Do not assume `Z`- or `Q`-independence of tile lengths separately. Derive it from irreducibility of the characteristic polynomial via the cyclic-vector argument, as the v16 track does.
- **Extra-structure risk — finite injectivity.** Prefix/suffix boundary injectivity, permutation boundary maps, or FI are strict extra hypotheses; useful experimentally, inadmissible in the general PSC proof. FI is distinct from UD.
- **UD-as-hypothesis risk.** UD stays a theorem from `det M_sigma != 0`. Listing it as a hypothesis silently weakens the headline result.
- **Unimodularity risk — contracting geometry.** Any Gate-2 Rauzy argument that assumes a purely Euclidean cut-and-project internal space, unit determinant, or invertibility over `Z` has silently returned to the unit/unimodular PSC. Non-unimodular substitution tilings require an internal space containing a profinite factor; the established model-set theory replaces the Euclidean-only internal space by Euclidean x profinite in the non-unimodular case. This applies directly to the proposed level-scaled Rauzy address for G1b-2.
- **Discreteness risk.** Do not treat `pi_s(Z^A)` as a lattice; its density is why the naive contracting-space proof failed.
- **Realization risk.** Do not infer "globally realized" from a formal SCC/cycle. The 1,764-cycle census shows that formal recurrence and realizability are different notions.
- **Computational-completeness risk.** "Dies by collar 40" becomes theorem-grade only after an independently proved collar-completeness bound. It cannot supply its own completeness proof.

## VIII. External literature delta

No public 2025–2026 result found in this check closes the general `|A| >= 3` primitive irreducible Pisot conjecture.

- **Nakaishi** (arXiv:2401.07771v1, 15 January 2024) claims a proof of one version of the conjecture via weak mixing of the prefix-suffix SFT; no later public revision found. Treat as an adjacent claimed proof, not imported machinery, until its precise hypotheses and disputed predecessor history are reconciled (v15 already records this stance).
- **Eng-Jon Ong** (February 2026) reports a balanced-pair termination result for a class of two-symbol S-adic systems. It does not touch the `|A| >= 3` gate directly, but its proof mechanism may be worth mining for the renewal/return decomposition missing in G1b-2.
- **Gohlke–Mitchell–Rust–Samuel** (2026) develop Rauzy fractals for random substitutions with canonical Rauzy objects and several equivalent constructions. Not a PSC result, but relevant background if Gate 2 is recast through a level-scaled contracting address.
- **Non-unimodular model sets (2022).** Architecturally the most immediately important item: it says what the Gate-2 internal space must be prepared to look like.

## IX. Prioritized completion ledger

| Priority | Obligation | Current status | What would close it |
| --- | --- | --- | --- |
| P0 | Fix manuscript hypothesis/attribution defects | small but mandatory | correct the aperiodicity sentence; separate Mossé/Pisot inputs; repair the Barge–Diamond / Sirvent–Solomyak attribution |
| P1-A | Concentration / aux-B (*superseded 2026-09-13:* together with wedge productivity, the `K2 != 0` case) | open | first-principles proof that expanding wedge mass reaches a closed recurrent carrier under G1, *and* a proof that no strict component has `K2 != 0` |
| P1-B | G1b-2 renewal finiteness | open; unavoidable Level-2 obligation | construct a level-scaled contracting address and prove finite-return/Delone-type discreteness for realizable reduced states |
| P2 | Preserve non-unimodular generality in P1-B | design constraint | formulate the internal space/address so that no unit-determinant, Euclidean-only, or projected-lattice assumption enters; keep any profinite factor first-class |
| P3 | SCC Producer assembly | conditional on both P1-A obligations + G1 | write the exact finite-graph argument from closed-carrier productivity to all recurrent SCCs producing coincidence |
| P4 | Realization/collar completeness | parallel certification route | prove an effective finite death-radius theorem or another criterion preventing global realization of producer-free formal cycles |
| P5 | Final PDS bridge audit | mostly established | verify the exact hypotheses of the chosen BSW / Sirvent–Solomyak / related bridge against the final BPA statement, with no unit or FI assumptions |
| P6 | Machine-check empirical lemmas/certificates | supporting | turn current exact computations into reproducible certificate-producing tests, especially G1b-2 return structure and collar death |

### Highest-value next proof move

Pursue P1-A and P1-B asymmetrically.

- **Attack concentration first.** The Galois work has made it a narrowly stated lemma with a very large payoff: it potentially removes the last substantial Level-3 closed-case assumption. (*Superseded 2026-09-13:* it does not; wedge productivity remains open independently.)
- **Keep the main long-horizon effort on G1b-2.** No Level-3 improvement produces the full theorem while BPA finiteness remains a hypothesis. The target is no longer "find another bounded quantity"; the experiments have killed that family. The target is

  ```text
  realizable first-return words
    -> level-scaled contracting address
    -> uniform discreteness / finite local return types
  ```

  with the construction non-unimodular from the outset.

The shortest honest path to completion, as recorded on 2026-09-11: one concentration theorem plus one renewal-finiteness theorem, then assembly. (*Superseded 2026-09-13:* two Level-3 theorems, concentration and wedge productivity, plus renewal finiteness, then assembly; see `docs/conjecture-ledger.md`.) The UD layer is finished.

## X. Repository cross-check (added on import to `main`)

This section records what the repository can and cannot substantiate in the ledger above.

1. **v16 provenance.** `archive/2026-09-08/README_READ_FIRST_2026_09_08.md` states that no file `PSC_PROOF_v16` has ever been found and that references to it should be treated as unreliable. The canonical archived manuscript is v15. Every "v16 track" claim above (G1b-1 proof, Galois propagation, exact aux-B formulation, leg-factor proof, collision-producer lemma, realization/rank equivalence) is therefore **reported, not verified on `main`**, and `proof/tla/Ledger.tla` deliberately keeps those results outside `ProvedDef`. Source import and audit remain P0.
2. **P0 defects are verifiable on `main` in v15.** The three wording defects of section VI items 6–8 occur at `PSC_PROOF_v15.tex` lines 140, 114, and 576 respectively, so the P0 obligation stands independently of whether a v16 file exists.
3. **Figures reproducible from `main`.** The 4,554-specimen PIP census and its BPA termination are pinned by the Mojo censuses and CI; the 500/500 span-rich figure appears in v15 and `V34_CLOSURE.md`; the G1b-2 anatomy figures are recorded in `docs/current-proof-architecture-2026-09-11.md`.
4. **Figures not reproducible from `main`.** The 59,319 / 7,491 UD census, the 198/300 and 4,086 collision counts, the 300/300, 200/200, 400/400 producer tests, the 759 relabeling orbits, the imbalance bound 14, and the 1,764-cycle collar census (death radius 7, collar 40) have no generating instrument or output on `main`. They are ledger-reported evidence and a P6 target for certificate-producing Mojo reproduction.
5. **Rauzy-address caution.** The archive's do-not-re-attempt list already contains "Rauzy/DT address" and "Rauzy tiling-boundary and radius-ceiling as exclusion mechanisms". The P1-B direction is admissible only insofar as it is genuinely new input: a **level-scaled** address on **labelled realizable first-return words** in a **non-unimodular (Euclidean x profinite)** internal space, aimed at a finite-return/Delone statement rather than an exclusion mechanism or radius ceiling. A P1-B note that does not state this distinction should be treated as a retired route.
