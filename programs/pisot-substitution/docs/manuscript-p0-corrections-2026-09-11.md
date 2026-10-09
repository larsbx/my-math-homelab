# P0 manuscript corrections — 2026-09-11

**Status:** mandatory before the next manuscript/version is treated as authoritative.

This note is a proof-hygiene checklist. It does not add new hypotheses or prove a new theorem; it prevents the current research program from silently strengthening assumptions or promoting conditional claims.

## 1. Aperiodicity

### Do not write

> Aperiodicity is automatic for primitive substitutions on an alphabet of size at least two.

This is false. For example,

```text
a -> ab
b -> ab
```

is primitive and periodic.

### Required replacement

Whenever Mossé recognizability is invoked, either:

- prove aperiodicity from the **full** standing hypotheses actually in force; or
- list aperiodicity as an explicit premise of that invocation.

For the PIP theorem, any derivation of aperiodicity must be written out rather than attributed to primitivity alone.

## 2. Mossé recognizability versus Pisot structure

### Do not write

> The Pisot property supplies Mossé recognizability.

### Required replacement

Mossé recognizability is invoked from primitive + aperiodic substitution dynamics. The Pisot hypothesis enters elsewhere: contracting conjugates, stable geometry, spectral restrictions, Barge–Diamond coincidence input, and related Pisot-specific arguments.

Keep those logical roles separate.

## 3. Two-letter literature attribution

The bibliography and theorem statements must distinguish at least these roles.

- **Barge–Diamond (2002):** strong coincidence for the two-letter Pisot case; in general alphabet size, existence of at least one eventually coincident pair.
- **Sirvent–Solomyak:** two-symbol Pisot-type pure discrete spectrum / the relevant two-letter spectral result.
- **Hollander–Solomyak:** cite only for the exact balanced-pair/overlap bridge actually used; do not use the citation as a generic substitute for the preceding claims.

Every manuscript citation should state the exact theorem imported and its hypotheses.

## 4. Closed versus closed-nonproductive

Any mass-balance or Perron statement whose proof uses absence of coincidence leakage must say **closed nonproductive**, not merely closed.

In particular, productive closed SCCs need not satisfy the same exact mass accounting used for a strict counterexample carrier.

## 5. Span-rich / dominant-wedge status

Any theorem that needs nonzero dominant wedge projection in the recurrent carrier remains **conditional on concentration / aux-B**.

Do not state “every closed SCC is span-rich” as a theorem unless the concentration premise has been independently proved or explicitly included.

The current strongest Level-3 route is:

```text
closed recurrent carrier
+ concentration / aux-B
=> dominant wedge nonzero
=> Galois propagation
=> full wedge span
=> productivity.
```

The first implication is still open.

## 6. Unique decodability is not a standing hypothesis

UD is derived from full incidence rank / `det M_sigma != 0` via the defect theorem. The power version follows because

```text
det M_{sigma^r} = (det M_sigma)^r != 0.
```

Do not list UD as an additional assumption in the headline PSC theorem.

## 7. Tile-length independence

Do not add separate `Q`- or `Z`-independence of tile lengths as an assumption when the standing irreducibility hypotheses already imply the required cyclic-vector independence.

If a proof uses this independence, cite/derive it from the incidence polynomial rather than importing it silently.

## 8. Finite injectivity / boundary maps

Prefix/suffix injectivity, boundary permutations, or FI-like hypotheses are strict extra structure. They may be used in experiments or restricted theorems but cannot appear in the general PSC proof without being clearly labelled as extra hypotheses.

## 9. Non-unimodularity firewall

Any contracting/Rauzy argument for G1b-2 must be designed for the non-unimodular case.

Do not assume:

- `|det M|=1`;
- that the internal space is purely Euclidean;
- that the projected integer module `pi_s(Z^A)` is a discrete lattice.

When the arithmetic requires an additional profinite/non-Archimedean factor, keep it first-class rather than collapsing back to the unit case.

## 10. Realization versus formal recurrence

A formal BPA SCC or cycle is not automatically globally realized by legal tilings / collars at all scales.

The formal producer-free cycles found computationally and their observed collar death are evidence precisely because this distinction is real.

Do not infer global realization from formal recurrence without a separate theorem.

## 11. Computational completeness

Statements such as

```text
all tested cycles die by collar 7
```

or

```text
no cycle survives collar 40
```

remain empirical until an independently proved collar-completeness/death-radius bound is available.

No computation may provide its own completeness justification.

## 12. Level-2 architecture

The manuscript must explicitly retract the old implication

```text
UD + phase automaton => bounded total padding => finite BPA.
```

The current Level-2 structure is

```text
UD
=> quotient contraction
=> bounded discrepancy (G1b-1)
=> [OPEN] renewal finiteness (G1b-2)
=> G1.
```

Bounded discrepancy does not bound state length.

## 13. Gate independence

Do not claim that concentration/aux-B and G1b-2 are two forms of one obstruction.

- aux-B is a recurrent-carrier wedge nonvanishing problem;
- G1b-2 is a renewal/discreteness problem needed before the finite carrier is globally available.

The two gates are independent in the current architecture.

## 14. Source provenance

The repository currently lacks the detailed v16/later manuscript/source that supports several theorem-grade status claims in the weekly completion ledger, especially:

- the full G1b-1 bounded-discrepancy proof;
- the Galois nonvanishing propagation step;
- the exact concentration / aux-B formulation;
- the later realization/rank equivalence in its final form.

These sources must be imported and audited before `main` is described as a self-contained proof record for those rungs.

## Acceptance checklist for the next manuscript

Before release, verify all of the following:

- no primitivity-alone aperiodicity claim;
- no “Pisot implies Mossé” wording;
- two-letter literature roles separated accurately;
- closed/nonproductive hypotheses stated where used;
- concentration-dependent results marked conditional;
- UD derived, not assumed;
- no hidden FI or unimodularity assumptions;
- no projected-lattice discreteness claim without proof;
- realization distinguished from formal recurrence;
- finite computational evidence labelled as evidence;
- G1b-2 stated explicitly as open until proved;
- imported v16/later sources have traceable repository provenance.