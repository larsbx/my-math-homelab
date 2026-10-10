# C1 proof definition and priority

Status: PRIORITY_ZERO.

This document defines what counts as a proof of the highest-priority conjecture C1 in finite-mandlebrot-research. It is the repository source of truth for C1 completion criteria.

## Terminology declaration: C1 proof criterion

Genealogy: The criterion combines Schleicher-style Mandelbrot fiber separation by rational parameter rays, the project finite separator-catalogue layer, theorem-tag import discipline, and Mojo finite proof-object checking.

Bridge claim: Conditional bridge theorem target. A C1 proof is accepted only when the finite separator-catalogue stream and the classical fiber relation are connected by named adequacy/adaptor lemmas, and the residual non-separation case is eliminated without an open missing-link exit.

Known leaks: This criterion does not lower the mathematical strength of the generic-boundary problem. In the global boundary form it has MLC/fiber-triviality strength. Mojo can check finite proof objects and imported theorem-tag assumptions, but it does not silently reprove classical analytic theorems.

Use discipline: Treat this document as priority zero. Any proposed C1 completion claim must reference this criterion and satisfy every required block below.

## C1 target statement

For admissible boundary representatives `A` and `B`, C1 is proved when the repository establishes:

```text
A != B  =>  exists k. Separated_k(A,B)
```

Equivalently:

```text
forall k. not Separated_k(A,B)  =>  BoundaryEquality(A,B)
```

where `Separated_k(A,B)` is a Mojo-checkable finite separator certificate at catalogue prefix `k`, and `BoundaryEquality(A,B)` is equality through the accepted boundary/fiber adapter, not display-name equality or carrier-label equality.

## Required proof blocks

A C1 proof requires all of the following blocks.

### Block 1: SeparatorCatalogueSoundness

```text
Separated_k(A,B) => ClassicallySeparated(A,B)
```

Every finite accepted separator certificate must map to a valid classical rational-ray separator with accepted theorem-tag imports and side-witness adapters.

### Block 2: SeparatorCatalogueCompleteness

```text
ClassicallySeparated(A,B) => exists k. Separated_k(A,B)
```

Every classical rational-ray separator admitted by the fiber definition must have a normalized finite separator code, accepted landing/theorem tags, extractable side witnesses, and fair enumeration into some finite prefix.

### Block 3: SeparatorCatalogueAdequacy

```text
ClassicallySeparated(A,B) iff exists k. Separated_k(A,B)
```

This is the conjunction of soundness and completeness. It proves catalogue adequacy only; it does not prove C1.

### Block 4: Fiber-definition adapter

```text
forall k. not Separated_k(A,B)
  => not ClassicallySeparated(A,B)
  => SameFiber(A,B)
```

The adapter must verify that the separator family is exactly the family used in the classical Mandelbrot fiber definition, with on-separator cases routed to boundary-identification logic.

### Block 5: ResidualClosureNoMissingLinks

```text
PersistentNonSeparation(A,B)
  => FiniteSeparation(A,B)
     or BoundaryEquality(A,B)
     or EstablishedTrivialFiberTag(A,B)
```

The forbidden outcome is an unresolved `MissingTheoremCatalogueLink`. A proof of C1 must eliminate that exit globally or close it into one of the accepted outcomes.

### Block 6: ExitClosureForC1

Every residual exit must close into a C1-relevant target:

```text
FiniteSeparation -> exists k. Separated_k(A,B)
BoundaryEquality -> accepted equality adapter
EstablishedTrivialFiberTag -> accepted theorem-tag import plus assumption checks
```

### Block 7: Mojo theorem-kernel certificate

The final proof must be represented by a finite proof object checked by the Mojo theorem kernel. The proof object must list:

```text
- theorem name: C1
- all finite premises and rule applications
- all theorem-tag imports
- all adapter assumptions
- all discharged missing-link obligations
- final conclusion
```

## Insufficient evidence

The following never proves C1:

```text
- bounded search with no counterexample
- renderer/picture shrinkage
- finite carrier state at each step without global descent
- local coverage of Misiurewicz, parabolic, or hyperbolic cases only
- a Mojo computation without theorem-tag import validation
- a residual proof that still allows MissingTheoremCatalogueLink
```

## Priority rule

C1 proof work outranks all other repo tasks unless a change directly protects the finite-regime invariants or the Mojo theorem kernel.

The current priority order is:

1. `ResidualClosureNoMissingLinks`
2. `SeparatorCatalogueAdequacyProofObjects`
3. `FiberDefinitionAdapterProofObject`
4. `C1FinalProofObject`
5. performance optimization of Mojo kernels used by those proof objects

## Current status

C1 is not proved. The repo has scaffolds for the proof route, but the remaining high-priority mathematical gap is:

```text
PersistentNonSeparation(A,B)
  => FiniteSeparation(A,B)
     or BoundaryEquality(A,B)
     or EstablishedTrivialFiberTag(A,B)
```

with no remaining missing-link exit.
