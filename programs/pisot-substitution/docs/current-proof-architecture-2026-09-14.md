# Current PSC proof architecture — 2026-09-14

**Canonical architecture summary.** For theorem status and provenance use `docs/claim-status-and-source-map-2026-09-13.md`; for live priorities use `docs/research-roadmap-2026-09-21.md` and for the latest dated snapshot use `docs/completion-ledger-2026-10-02.md`; for full statements use `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`.

## Headline

The shortest current route to pure discrete spectrum is G1-free and has one open premise:

```text
PIP
=> G1b-1 bounded discrepancy                         [PROVED]
=> finite seed-patch overlap graph                   [PROVED]
=> productive overlaps from one swap seed            [OPEN: Open Problem 5.35]
=> coincidence density one / dense good set          [PROVED]
=> PDS                                                [IMPORTED: Barge–Štimac–Williams]
```

The swap seed uses any two distinct tile types; no assumption that `ab` is a legal factor of the substitution language is part of Theorem 5.38.

G1b-2, finite BPA, concentration, wedge productivity, SCC Producer, and the realization/rank bridge all remain open in their respective programmes. They are not hidden assumptions of manuscript Theorem 5.38.

Keep the hypotheses separate. Theorem 5.38 uses the one-seed premise shown above. Manuscript Open Problem 5.35 is the stronger all-vertex form; only that form has the Proposition 5.39(iii) two-sided strong-coincidence consequence, the every-vertex Corollary 5.41 hitting formulation, and the cited unimodular equivalence with PDS. No one-seed-to-all-vertices implication is claimed (`docs/audit-2026-09-20.md` §C).

## Primary gate — seedwise overlap productivity

For every primitive irreducible Pisot substitution, prove that there are distinct letters `a != b` such that every exact overlap reachable from the seed overlaps of `(ab,ba)` is productive.

The graph on which this is asked is already finite. PR #88 sharpens any hypothetical failure to a canonical obstruction rather than an arbitrary bad vertex.

Current constraints on a bad obstruction `S`:

1. **Full rank (PR #76).** The span of its intersection vectors is a nonzero rational `M_sigma`-invariant space; irreducibility forces full rank, and the child-count matrix inherits the Galois spectrum of `M_sigma`.
2. **Closed recurrent normal form (PR #88).** A failure contains a finite child-closed irreducible nonproductive SCC `S`; its child-count matrix has `PF(N_S)=beta` and the full-rank intertwiner applies.
3. **Endpoint alignment (PR #82).** Offset-zero and right-aligned seed overlaps are exactly the prefix/suffix strong-coincidence cases.
4. **Boundary-hitting criterion (PR #82).** An overlap reaches offset zero at level `m` iff `M^m w` is a difference of proper-prefix Parikh vectors, equivalently iff inflated descendants have a common left endpoint.
5. **Boundary/zipper dichotomy (PR #88).** Either `S` contains an offset-zero state, exposing a non-eventually-coincident letter pair, or no substituted top/bottom child starts ever tie and every child factorization in `S` is a strict monotone prefix-grid zipper.
6. **Strong finite evidence.** In the exact 4,554-member corpus, all 1,118,850 overlap vertices are productive; largest graph 2,640; largest first-coincidence depth 18; first left-aligned depth at most 17; prefix/suffix strong-coincidence depth at most 15.

The preferred next theorem now splits cleanly:

- **aligned branch:** force the exposed non-eventually-coincident pair into the available strong-coincidence structure;
- **strict-zipper branch:** retain ordered boundary-source data through inflation and use full rank plus exact prefix geometry to force a boundary hit or an impossible recurrent zipper.

Generic Perron growth alone is insufficient: the residual real-overlap graph can carry the full expansion spectral radius. Do not infer `rho(N_S)<beta` merely by calling the bad component a boundary graph.

## Stable base

### Unique decodability

UD and UD for powers are repository-proved consequences of full incidence rank / the defect theorem. They are not standing assumptions.

The externally supplied `PSC_PROOF_v9.pdf` independently re-derives this part cleanly and also gives the useful local observation that UD for powers fixes the hierarchy inside a specified supertile. The extraction audit is recorded in `docs/v9-extraction-audit-2026-09-23.md`. No status change follows: the v9 predecessor-contraction / finite-BPA inference and universal cycle-exclusion claims are not imported.

### Bounded discrepancy

G1b-1 is repository-proved by the PR #69 reconstruction using primitivity and the Pisot spectrum. It neither assumes unimodularity nor proves finite BPA.

### Finite overlap graph

PR #72 converts bounded discrepancy into an explicit finite set of exact seed-patch overlap types. This is the finite object used by the primary route.

### Density to PDS

Lemma 5.36 proves the repository side of the density condition. PR #77 imports the Barge–Štimac–Williams theorem with its hypotheses audited in the standing PIP regime. Therefore density-to-PDS is no longer an open bridge on this route.

## Parallel programme A — G1 / BPA finiteness

```text
G1b-1 bounded discrepancy [PROVED]
=> G1b-2 renewal finiteness [OPEN]
=> finite BPA (G1).
```

G1 has **three** alternative sufficient premises, each a conditional theorem with one open premise:

```text
G1b-2 renewal finiteness                   [OPEN]      -> G1
all-seed overlap productivity              [OPEN]      -> G1   (Prop 5.46, overlap-depth route)
all-seed strict-zipper exclusion alone     [OPEN]      -> G1   (Prop 5.47, half-coincidence route)
```

Both overlap routes are in `docs/bpa-termination-by-overlap-depth-2026-10-02.md` (Propositions 1 and 4 with Corollary 5). Because the half-coincidence route needs only a common vertex rather than a coincidence, finiteness requires only the strict-zipper branch (#139); the strong-coincidence branch (#138) is needed for productivity and PDS, not for G1.

**G1 is also necessary.** PDS implies finite `B_sigma` (manuscript Proposition `prop:PDS-implies-G1`, ledger `PDSImpliesRepoG1`, the Theorem S route; independently audited 2026-10-04, human review pending), and PDS implies termination from every seed, legal or not (manuscript Theorem `thm:seedwise`, former Open Problem 4.24). So this programme is no longer an independent obligation: it is a consequence of the conjecture.

G1b-2 remains the exact missing theorem for finite BPA. The target is a realizability/renewal statement for labelled first-return words, not another bounded norm. Any contracting-address proof must handle non-unimodular substitutions and may not treat the stable projection of the integer module as a lattice.

## Parallel programme B — finite-BPA closed carriers

Under G1:

```text
nonproductivity
=> finite closed/sink recurrent carrier
=> K2 == 0 or K2 != 0
=> concentration [OPEN] or wedge productivity [OPEN]
=> SCC Producer.
```

The degree-two carrier-span theorem is repository-proved. Full span alone does not imply productivity. The two 4,554-corpus exclusion certificates remain finite-domain theorems only.

## Parallel programme C — realization / MEF

The realization/coincidence-rank chain is an audited open bridge with obligations G0–G6. Formal recurrence, global realization, and survival to a finite collar are not interchangeable. This route is useful for certification/reformulation but is not required by the primary overlap theorem.

## Generality firewall

A valid general PSC proof must not silently add any of the following:

- legality of the two-letter periodic swap word as a substitution-language factor;
- rational/integer tile-length independence as an independent hypothesis;
- UD as an independent hypothesis;
- finite injectivity or prefix/suffix permutation hypotheses;
- unimodularity `|det M|=1`;
- purely Euclidean internal-space assumptions in a non-unimodular step;
- discreteness of `pi_s(Z^A)`;
- global realization of a formal recurrent component;
- completeness of a finite corpus or collar bound without an independent theorem.

## Priority order

1. **Overlap productivity / bad-overlap normal form.** Current shortest-path gate; attack the aligned and strict-zipper branches from PR #88.
2. **G1b-2 renewal finiteness.** Stronger independent BPA theorem.
3. **Concentration and wedge productivity.** Alternative finite-BPA SCC route.
4. **Realization bridge.** Secondary certificate route.
5. **Status synchronization and exact certificates.** Ongoing P0 discipline.

The project should not prioritize another fixed-size carrier sieve over item 1 unless that sieve yields a uniform theorem feeding the overlap gate.