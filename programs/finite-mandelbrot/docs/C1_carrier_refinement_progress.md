# C1 CarrierRefinementProgress

Status: active frontier route, not a proof of C1.

This note continues the C1 path from `UnresolvedWakeToCarrierObstruction`. The purpose is to make a carrier obstruction productive: it must either refine the finite incidence carrier or expose a missing theorem/catalogue link.

## Terminology declaration: strict carrier refinement

Genealogy: The phrase is a project term built from ordinary refinement language in topology/combinatorics and from the project's finite incidence-carrier discipline. It is not a new classical object.

Bridge claim: Definition-only project term. A strict carrier refinement is a finite replacement of a carrier record by a smaller or more resolved carrier record, certified by an explicit refinement witness.

Known leaks: It does not imply metric shrinkage, local connectivity, fiber triviality, or singleton convergence. It may only be read as progress inside the finite incidence grammar.

Use discipline: Use this term only when a carrier record, a proposed refined carrier, and a finite witness of proper refinement are present. Do not use it for numerical resolution, visual resolution, or rank-2 locus language.

## Terminology declaration: missing theorem/catalogue link

Genealogy: This phrase records the boundary between the finite grammar and theorem-tagged classical inputs such as rational-ray landing, wake membership, and fibre separation.

Bridge claim: Definition-only project term. A missing theorem/catalogue link is a named gap showing that the current catalogue does not yet provide the theorem tag, separator code, side witness, or enumeration step needed by the C1 bridge.

Known leaks: It is not a counterexample. It is not evidence that C1 fails. It may reflect incomplete formalization, incomplete literature tagging, or a genuinely new lemma requirement.

Use discipline: Use only with a named link kind and the local C1 lemma it blocks.

## Progress target

Given a carrier obstruction produced from persistent wake ambiguity, prove one of:

```text
StrictCarrierRefinement
or MissingTheoremCatalogueLink
or BoundaryEqualityRefinement
or RefinesToOppositeSideSeparation
```

The target is not to prove C1 in one step. The target is to prevent unresolved wake ambiguity from being inert.

## Candidate progress cases

1. `CarrierTooCoarse` gives a strict carrier refinement candidate.
2. `LandingTagMissing` gives a missing theorem/catalogue link.
3. `CatalogueLinkMissing` gives a missing theorem/catalogue link.
4. `WakeOrderUnderdetermined` gives either strict carrier refinement or a missing order-comparison lemma.
5. `BoundaryEqualityCandidate` routes to boundary equality refinement, not separation.

## Rank-2 restriction

No case may introduce a circle, disk, arc, circumference, or analytic locus at rank 2. Rank-2 records supply coordinate data and polynomial constraints only.

## Next proof target

The next local lemma is:

```text
CarrierProgressDichotomy:
  CarrierObstruction -> StrictCarrierRefinement or MissingTheoremCatalogueLink or BoundaryEqualityRefinement or RefinesToOppositeSideSeparation
```

This is still a reduction lemma. It does not establish global fiber triviality.
