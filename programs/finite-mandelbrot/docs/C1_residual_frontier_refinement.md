# C1 residual frontier refinement

Status: active theorem route.

This file moves the C1 program from guardrail construction to the core proof route.

## Terminology declaration: residual frontier refinement

Genealogy: This term packages the remaining generic-boundary case after `SeparatorCatalogueAdequacy` has been decomposed into finite separator coding, landing tags, side witnesses, finite-prefix existential separation, and classical-to-finite coding. It is tied to the classical fiber definition by rational-ray separation and to the project C1 finite catalogue grammar.

Bridge claim: Definition-only project term plus conditional bridge theorem target. It is not a standard term in the field. Its role is to express that, once catalogue and side-witness links are unavailable as failure explanations, persistent non-separation must produce strict finite carrier refinement.

Known leaks: The term does not prove MLC. It does not prove all fibers are trivial. It depends on `SeparatorCatalogueAdequacy`, side-assignment soundness, and the well-founded carrier refinement order. It also assumes incidence carriers are canonical finite presentations, not analytic singleton points.

Use discipline: Use only for the implication from persistent non-separation with no missing theorem/catalogue link and no boundary equality to strict carrier refinement. Do not use for bounded searches, renderers, metric diameter, or rank-2 circle/locus claims.

## Central residual lemma

The serious remaining route toward C1 is:

```text
PersistentNonSeparation(A,B)
and NoMissingTheoremCatalogueLink(A,B)
and NoBoundaryEquality(A,B)
and CanonicalCarrierContent(A,B)
  => StrictCarrierRefinement(A,B)
```

This is the point where the project must earn the conjecture. If persistent non-separation cannot hide in a missing link or boundary equality, it must change finite incidence content in the well-founded refinement order.

## Proof plan

### Step R1: expose unresolved wake evidence

From persistent non-separation, use the obstruction extraction route:

```text
PersistentNonSeparation
  => PersistentWakeAmbiguity
     or UndeclaredBoundaryCarrier
     or NonShrinkingNestedCarrier
     or MissingCatalogueExtensionality
```

The current residual hypothesis rules out missing catalogue links and routes undeclared boundary carrier into boundary-equality refinement.

### Step R2: eliminate unproductive ambiguity

Apply the wake-ambiguity elimination dichotomy:

```text
PersistentWakeAmbiguity
  => BoundaryEqualityRefinement
     or CarrierObstruction
     or MissingTheoremCatalogueLink
     or RefinesToOppositeSideSeparation
```

The residual hypotheses rule out boundary equality and missing theorem/catalogue links. Refines-to-opposite-side immediately produces finite separation, contradicting persistent non-separation. Therefore the only surviving case is carrier obstruction.

### Step R3: carrier obstruction becomes progress

Apply CarrierProgressDichotomy:

```text
CarrierObstruction
  => StrictCarrierRefinement
     or MissingTheoremCatalogueLink
     or BoundaryEqualityRefinement
     or RefinesToOppositeSideSeparation
```

Again the residual hypotheses eliminate all but strict carrier refinement.

### Step R4: well-founded descent

Strict carrier refinement descends in the finite combinatorial order on canonical carrier content. Repeated residual failure therefore cannot continue forever unless one of the excluded alternatives reappears.

## Consequence

Under the local lemmas already named in the repository, the residual frontier reduces to the impossibility of an infinite strict descent in canonical finite carrier content.

```text
PersistentNonSeparation with no missing link and no boundary equality
  => strict carrier refinement
  => finite descent
  => contradiction or finite separation
```

This is the active attack on C1.

## Non-claims

This file does not claim C1 is proved. It records the exact proof route whose completion would force C1 forward.

It does not use circle, disk, arc, circumference, analytic locus, metric diameter, or analytic singleton point primitives. Rank-2 remains coordinate records plus polynomial constraints only.
