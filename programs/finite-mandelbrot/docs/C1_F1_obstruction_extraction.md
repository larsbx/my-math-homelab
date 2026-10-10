# C1 Route F1: obstruction extraction

Status: active proof route.

This route treats the generic fiber-triviality frontier as solvable. It starts from the negation of C1-global and tries to extract a finite obstruction that the rational-ray catalogue can see.

## Target implication

```text
NontrivialFiber(A)
  => exists B != A. for all k, not Separated_k(A,B)
```

This statement alone is only the classical negation of triviality translated into finite catalogue language. The proof route must strengthen it into an obstruction that contradicts finite incidence discipline.

## Desired strengthening

Find a finite invariant `Obs(A,B)` such that:

```text
NontrivialFiber(A,B)
  => PersistentNonSeparation(A,B)
  => Obs(A,B)
  => contradiction with one of the C1 finite axioms.
```

The obstruction must be finite, replayable, and independent of renderer or numerical image evidence.

## Candidate obstruction forms

### F1-a: persistent wake ambiguity

Two distinct incidence objects remain in every shared wake interval induced by all admissible rational separators.

Required lemma:

```text
PersistentWakeAmbiguity(A,B)
  => not enough admissible wake refinements exist
```

This would contradict `SeparatorCatalogueAdequacy` if the classical fiber definition admits rational separators for all distinct fibers.

### F1-b: undeclared boundary carrier

The pair `A,B` stays non-separated only because the incidence carrier admits a hidden boundary object not expressible by the finite grammar.

Required lemma:

```text
HiddenBoundaryCarrier(A,B)
  => finite incidence grammar incomplete
```

This route either repairs the grammar or finds the exact missing object class.

### F1-c: non-shrinking nested carrier

A nested sequence of certified wake carriers remains non-singleton while adding no new admissible separator.

Required lemma:

```text
NonShrinkingCarrierStream(A,B)
  => violates well-founded carrier refinement measure
```

This overlaps Route F2 and is the most promising route if a finite measure can be identified.

## Proof obligations

1. Define `PersistentNonSeparation(A,B)` without analytic points.
2. Define a finite obstruction object `Obs(A,B)`.
3. Prove every nontrivial fiber yields at least one obstruction object.
4. Prove each obstruction object violates a finite C1 axiom, or record the exact missing axiom.
5. Preserve established theorem-tagged cases separately.

## Hard constraint

The obstruction cannot be:

- a floating-point pattern;
- a rendered image feature;
- an appeal to visual intuition;
- an infinite analytic singleton;
- a generic boundary landing oracle.

It must be a finite incidence/certificate object.

## Current next task

Define the data type for `PersistentNonSeparation` and list which finite observations it retains at each catalogue level.
