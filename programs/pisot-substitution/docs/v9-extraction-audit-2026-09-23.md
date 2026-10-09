# PSC v9 extraction audit — 2026-09-23

## Purpose

This note records the parts of the externally supplied `PSC_PROOF_v9.pdf` that are mathematically reusable in the live repository, and separates them from claims that are incompatible with the current audited proof architecture.

This is an extraction/audit note, not a theorem-status promotion. The authoritative status surfaces remain:

- `docs/claim-status-and-source-map-2026-09-13.md`;
- `docs/proof-ladder.md`;
- `docs/current-proof-architecture-2026-09-14.md`;
- `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`;
- the generated TLA/ledger surfaces.

## Reusable material from v9

### 1. Concise defect-theorem proof of unique decodability

v9's cleanest contribution is the short derivation

```text
det M_sigma != 0
=> full incidence rank
=> the d image words cannot lie in a free submonoid of rank < d
=> {sigma(a) : a in A} is a code.
```

This is already repository-proved in the live manuscript as the unique-decodability theorem from the Berstel--Perrin--Perrot--Restivo defect theorem plus full incidence rank.

**Status:** useful exposition; no theorem-status change.

### 2. UD for powers

The same argument applies to every power because

```text
det M_{sigma^r} = (det M_sigma)^r != 0.
```

The repository already records `UDForPowers` as theorem-grade.

**Status:** useful exposition; no theorem-status change.

### 3. Unique hierarchy inside a *specified* supertile

v9 correctly highlights the following local consequence of UD for powers:

> once a level-`n` supertile is fixed, the complete hierarchy of lower-level supertile boundaries inside that word is uniquely determined by UD for the powers of `sigma`.

This is useful as a local hierarchy/witness statement and matches the live manuscript's local witness-injectivity result.

The scope is deliberately local: it does **not** assert that the whole bi-infinite tiling is determined from one supertile window, nor does it replace the separate global realization/productivity obligations.

**Status:** useful local lemma/exposition; no global bridge promotion.

## Claims from v9 that must not be imported

### A. `UD => bounded total padding => finite BPA`

Do not import the v9 predecessor-contraction/finiteness step.

The live proof ladder permanently withdraws both:

- the old predecessor-contraction claim; and
- the inference `UD => bounded total padding => finite BPA`.

Finite BPA (G1) remains open in general; after proved bounded discrepancy, the exact stronger-route obligation is G1b-2 renewal finiteness.

### B. `no recurrent noncoincident BPA cycle`

Do not import the v9 Level-3 cycle-exclusion theorem.

The flipped-Tribonacci PIP substitution

```text
1 -> 21
2 -> 31
3 -> 1
```

has a recurrent noncoincident period-3 cycle in its balanced-pair automaton. The component is productive because inflation produces coincidence siblings.

Therefore the correct recurrent target is **productivity of the relevant component/overlaps**, not exclusion of every recurrent noncoincident cycle.

### C. Global witness injectivity from one common supertile

UD for powers gives a unique hierarchy **inside a known common supertile**. It does not by itself identify the two complete bi-infinite tilings outside that window.

The live manuscript correctly records this as local witness injectivity.

### D. Diameter-only witness preservation

A bound saying a displacement is smaller than a supertile diameter does not imply that two points lie in the same supertile; they can lie on opposite sides of a boundary.

Any future global witness-preservation argument must retain its explicit geometric/interiority/realization hypotheses.

## Relation to the current proof architecture

The current shortest honest route remains

```text
primitive irreducible Pisot
=> bounded discrepancy                                  [PROVED]
=> finite seed-patch overlap graph                      [PROVED]
=> productive overlaps from one swap seed               [OPEN]
=> coincidence density one / dense good set             [PROVED]
=> pure discrete spectrum                               [IMPORTED]
```

The reusable v9 material strengthens the stable base and exposition but does not discharge the open overlap-productivity premise.

The stronger finite-BPA programme remains

```text
bounded discrepancy [PROVED]
=> renewal finiteness / G1b-2 [OPEN]
=> finite BPA.
```

## Extraction decision

**Keep:**
- concise UD proof via the defect theorem;
- UD for powers;
- unique hierarchy inside a specified supertile.

**Reject as live claims:**
- predecessor contraction as a proof of finite BPA;
- `UD => bounded total padding => finite BPA`;
- universal recurrent noncoincident-cycle exclusion;
- global pointed-realization injectivity from one supertile;
- diameter-only witness preservation.

No claim-status change is made by this extraction.
