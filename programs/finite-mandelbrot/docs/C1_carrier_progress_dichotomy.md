# C1 CarrierProgressDichotomy

Status: active proof route for the highest-priority conjecture.

## Terminology declaration: carrier progress dichotomy

Genealogy: This is a project-local decomposition lemma for finite incidence carriers, modeled on standard proof-engineering dichotomies: either a finite obstruction produces a strictly smaller/refined object, or it exposes a missing hypothesis/bridge needed by the proof.

Bridge claim: Definition-only project term, intended to support the conditional bridge from finite separation catalogues to classical rational-ray fiber separation. It is not an isomorphism and it is not a classical theorem name.

Known leaks: The dichotomy does not prove MLC, fiber triviality, or singleton fibers. It assumes the surrounding separator-code, side-assignment, wake-membership, and catalogue-extensionality obligations are meaningful and separately governed.

Use discipline: Use only inside the C1 frontier proof route. Do not use it as evidence that every generic boundary fiber is trivial.

## Goal

For any accepted carrier obstruction record `O`, prove:

```text
AcceptedCarrierObstruction(O)
  => StrictCarrierRefinement(O)
   or MissingTheoremCatalogueLink(O)
   or BoundaryEqualityRefinement(O)
   or RefinesToOppositeSideSeparation(O)
```

This is the local productivity step needed by WakeAmbiguityElimination.

## Case 1: strict carrier refinement

The obstruction identifies finite incidence data that splits or sharpens the carrier:

```text
Carrier(A, n+1) < Carrier(A, n)
```

Here `<` is structural refinement of finite incidence carriers, not metric shrinkage and not a rank-2 circle/locus statement.

## Case 2: missing theorem/catalogue link

The obstruction does not refine because a theorem tag, landing tag, or catalogue link is missing. This is productive because it yields a precise obligation:

```text
Add theorem tag T
or prove catalogue link L
or reject the separator as inadmissible
```

## Case 3: boundary equality refinement

The obstruction is explained by an object lying on the separator boundary. This is not separation. It must route to structural equality or to a refined carrier that distinguishes boundary incidence from open-side incidence.

## Case 4: opposite-side separation

The obstruction refines enough to produce accepted opposite-side witnesses for the same admissible separator. Then it routes to the existing `OppositeSideSeparationSoundness` layer.

## Rank-2 ontology guard

No case may invoke a circle, disk, arc, circumference, analytic locus, or analytic singleton at rank 2. Rank-2 data contributes only coordinate records, polynomial constraints, and quadrance scalars. Carrier language lives at the incidence layer.

## Next local lemma

After the dichotomy is stated, the next proof target is:

```text
StrictCarrierRefinementWellFounded
```

That lemma must show that repeated strict carrier refinement cannot continue without either producing a separator, producing a boundary-equality refinement, or exposing a missing theorem/catalogue link.
