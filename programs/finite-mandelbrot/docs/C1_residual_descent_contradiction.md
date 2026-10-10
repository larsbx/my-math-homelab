# C1 residual descent contradiction

Status: central proof route toward C1.

Terminology declaration: residual descent contradiction

Genealogy: This term names the finite-regime descent argument assembled from the previously introduced `ResidualFrontierRefinement`, `CanonicalContentRefinementOrder`, and `StrictCarrierRefinementWellFounded` proof routes. Its classical side is the fiber-theoretic idea that non-separation cannot persist without a genuine nontrivial fiber obstruction.

Bridge claim: Conditional bridge theorem. If residual persistent non-separation always forces strict canonical carrier refinement, and strict canonical carrier refinement is well-founded, then the residual case cannot persist indefinitely.

Known leaks: This is not a proof of MLC by itself. It depends on the local residual-refinement lemma and on the adequacy of the canonical carrier content order. It also assumes `SeparatorCatalogueAdequacy` has been discharged or separately theorem-tagged.

Use discipline: Use only for the contradiction step that rules out an infinite residual chain. Do not use it to claim finite-prefix non-separation proves same fiber, and do not replace classical fiber arguments with bounded search.

## Target theorem

Let `A` and `B` be finite incidence objects governed by the C1 catalogue.

Assume:

1. `PersistentNonSeparation(A,B)`;
2. `NoMissingTheoremCatalogueLink(A,B)`;
3. `NoBoundaryEquality(A,B)`;
4. `CanonicalCarrierContent(A,B)`;
5. `ResidualFrontierRefinement`;
6. `StrictCarrierRefinementWellFounded`.

Then the residual case cannot persist indefinitely.

In proof form:

```text
PersistentNonSeparation
  + NoMissingLink
  + NoBoundaryEquality
  + ResidualFrontierRefinement
  + WellFoundedStrictCarrierRefinement
  => contradiction to infinite residual persistence.
```

## Proof skeleton

### Step 1: residual hypotheses force refinement

By `ResidualFrontierRefinement`, every residual state satisfying the hypotheses yields a strict canonical carrier refinement:

```text
ResidualState_n => Carrier_n+1 < Carrier_n
```

where `<` is the canonical content refinement order.

### Step 2: persistence reconstitutes the hypotheses

Persistent non-separation supplies the recurrence condition needed to examine the next carrier. The exclusions `NoMissingTheoremCatalogueLink` and `NoBoundaryEquality` keep the next state in the residual branch rather than rerouting to a missing-link or equality case.

### Step 3: iterate the refinement

If residual persistence never exits, the construction gives an infinite strictly descending chain:

```text
Carrier_0 > Carrier_1 > Carrier_2 > ...
```

### Step 4: well-foundedness blocks the chain

`StrictCarrierRefinementWellFounded` forbids infinite descent in canonical carrier content.

Therefore residual persistence must exit through one of the non-residual outcomes:

- finite separation;
- boundary equality refinement;
- missing theorem/catalogue link;
- established trivial-fiber theorem tag.

## Consequence for C1

This theorem does not directly prove C1. It reduces C1 to closing the remaining exits:

1. `SeparatorCatalogueAdequacy`;
2. correctness of residual-frontier refinement;
3. correctness of strict carrier well-foundedness;
4. classification of boundary equality refinements;
5. closure of missing theorem/catalogue links.

Once those are discharged, persistent non-separation cannot witness a nontrivial unresolved fiber in the finite regime.

## Rank-2 ontology constraint

No part of this argument uses a rank-2 circle, disk, arc, circumference, analytic point, or metric locus. Rank-2 contributes coordinate records and polynomial constraints only. Carrier refinement is an incidence-level operation.
