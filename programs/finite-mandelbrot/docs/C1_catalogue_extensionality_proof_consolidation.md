# C1 separator-catalogue adequacy proof consolidation

Status: active proof consolidation after alignment audit.

This file replaces the earlier project phrase `catalogue extensionality` with the literature-aligned decomposition required by the alignment audit:

```text
SeparatorCatalogueSoundness
SeparatorCatalogueCompleteness
SeparatorCatalogueAdequacy
```

The object of study is not an abstract catalogue in isolation. It is a finite separator catalogue whose entries are admissible rational-ray separator codes, landing theorem tags, and finite side/wake witnesses.

## Terminology declaration: separator-catalogue adequacy proof consolidation

Genealogy: This phrase packages a proof-assembly step relating finite rational-ray separator codes to the classical rational-ray separation relation used in Mandelbrot fiber theory. Its field ancestors are rational external rays, wakes, orbit portraits, kneading data, parameter-ray landing, and Schleicher-style fibers.

Bridge claim: Conditional bridge theorem. If the local soundness and completeness lemmas listed below are proved, then the finite separator catalogue is adequate for the classical rational-ray separation relation. This is not a theorem about all fibers being trivial.

Known leaks: Adequacy of rational-ray separator enumeration does not prove MLC, does not prove generic fiber triviality, and does not prove shrinkage of puzzle pieces or nests. Any later use of this bridge must still disclose the classical theorem tags used for landing/fiber semantics.

Use discipline: Use `SeparatorCatalogueAdequacy` for the two-sided finite/classical bridge. Use `SeparatorCatalogueSoundness` for finite-to-classical direction. Use `SeparatorCatalogueCompleteness` for classical-to-finite direction. Do not use the legacy phrase `catalogue extensionality` except when describing deprecated terminology.

## The local theorem

Let `A` and `B` be finite incidence objects admissible for the C1 bridge. Let `ClassicallySeparated(A,B)` mean that their corresponding classical representatives are separated by an allowed rational-ray separator in the classical fiber definition. Let `Separated_k(A,B)` mean that the finite separator-catalogue prefix `k` contains an admissible separator plus accepted opposite-side witnesses for `A` and `B`.

The local theorem is:

```text
SeparatorCatalogueAdequacy(A,B):
  ClassicallySeparated(A,B)
    iff exists k. Separated_k(A,B)
```

This theorem is not C1. It is the bridge that makes the finite separator-catalogue relation coextensive with the classical rational-ray separation relation, assuming the local lemmas below.

## Direction 1: SeparatorCatalogueSoundness

```text
exists k. Separated_k(A,B)
  => ClassicallySeparated(A,B)
```

Local lemmas used:

1. `SeparatorAdmissibilitySoundness`
   - finite separator codes use allowed rational-ray or theorem-tagged hyperbolic-boundary data;
   - generic boundary landing tags are rejected.

2. `SideAssignmentSoundness`
   - every accepted finite side witness maps to the matching classical side of the separator.

3. `OppositeSideSeparationSoundness`
   - accepted opposite-side witnesses for the same admissible separator imply classical separation by that separator.

4. `FinitePrefixToExistentialSeparation`
   - if the separator and witnesses appear in prefix `k`, then `exists j. Separated_j(A,B)` holds.

## Direction 2: SeparatorCatalogueCompleteness

```text
ClassicallySeparated(A,B)
  => exists k. Separated_k(A,B)
```

Local lemmas used:

1. `RationalSeparatorCodingCompleteness`
   - every allowed classical rational-ray separator has a normalized finite separator code;
   - duplicate ray addresses collapse rather than form a separator;
   - generic boundary landing tags are rejected.

2. `LandingTagCompletenessForFiberSeparators`
   - every separator admitted by the classical fiber definition uses one of the accepted theorem-tag families;
   - numerical landing guesses and MLC-only landing assertions are not tags.

3. `SideWitnessExtraction`
   - if the classical representatives lie on opposite sides of an allowed separator, finite side witnesses can be extracted from the separator data, incidence references, and wake/order evidence.

4. `FairEnumerationLemma`
   - every normalized finite separator code appears at some finite separator-catalogue prefix;
   - the prefix is bounded by a finite rank/height of the code;
   - fair enumeration does not assert stabilization.

## Proof: soundness direction

Assume `exists k. Separated_k(A,B)`. Choose a witness prefix `k` and a separator record `S` in that prefix.

By definition of `Separated_k`, `S` is admissible, both side witnesses are accepted, they refer to the same separator, and their open-side labels are opposite. `OnSeparator` cases are excluded.

By `SideAssignmentSoundness`, each finite side witness maps to the corresponding classical side relation. By `OppositeSideSeparationSoundness`, opposite accepted sides for the same admissible separator yield classical separation.

Therefore `ClassicallySeparated(A,B)`.

## Proof: completeness direction

Assume `ClassicallySeparated(A,B)`. Then there is an allowed classical rational-ray separator `S_classical` separating the two representatives in the classical fiber definition.

By `RationalSeparatorCodingCompleteness`, `S_classical` has a normalized finite separator code `S_code`. By `LandingTagCompletenessForFiberSeparators`, the landing evidence required by `S_code` is an accepted theorem-tag family, not a generic boundary assertion.

By `SideWitnessExtraction`, the classical opposite-side relation yields finite side witnesses for `A` and `B` relative to `S_code`.

By `FairEnumerationLemma`, `S_code` occurs in some finite separator-catalogue prefix `k`. Therefore prefix `k` contains an admissible separator plus accepted opposite-side witnesses.

By `FinitePrefixToExistentialSeparation`, `exists k. Separated_k(A,B)`.

## Immediate result

Once the local lemmas are discharged, the finite predicate

```text
exists k. Separated_k(A,B)
```

has the same separation content as the classical rational-ray separation relation used to define fibers.

The remaining C1 burden is therefore not separator-catalogue bookkeeping. It is the open-frontier statement:

```text
PersistentNonSeparation(A,B) forces collapse to boundary equality,
known trivial-fiber family, missing theorem/catalogue link, or contradiction.
```

The alignment audit marks any global elimination of residual persistent non-separation as MLC-strength unless restricted to established classes.

## What must happen next

The next proof work should target the frontier route, not more naming layers:

1. prove `CarrierProgressDichotomy` from the canonical content order;
2. prove well-founded descent for strict carrier refinements;
3. prove that every persistent wake ambiguity triggers descent, missing-link exposure, or boundary equality refinement;
4. eliminate the residual case where all links are present, no equality is exposed, and no descent occurs.

The last residual case is the current mathematical target and must not be hidden behind finite-state terminology.

## Forbidden shortcuts

The following do not prove C1:

- finite bounded search with no separator found;
- shrinking pictures or rendered images;
- metric diameter language imported into rank 2;
- circle, disk, arc, or analytic locus primitives at rank 2;
- generic boundary landing claims without theorem tags;
- terminology invention without genealogy and leaks;
- finite-state termination claims unless backed by a proved well-founded order tied to the actual carrier refinement relation.
