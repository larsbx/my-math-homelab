# C1 ResidualClosureNoMissingLinks

Status: priority-zero open proof block.

This file defines the next highest-priority proof obligation for C1. It strengthens `ExitClosureForC1` by removing the development-only exit through `MissingTheoremCatalogueLink`.

## Terminology declaration: ResidualClosureNoMissingLinks

Genealogy: This is a project proof-obligation name for the final residual case in the finite rational-ray separation program. Its field ancestors are Mandelbrot fibers, rational parameter-ray separation, known trivial-fiber classes, and standard proof-by-exhaustion over explicitly stated alternatives.

Bridge claim: Conditional proof criterion. If separator-catalogue adequacy and the fiber-definition adapter are already available, then this statement closes the nontrivial persistent non-separation case on the covered domain.

Known leaks: This statement has fiber-triviality / MLC strength under global boundary coverage. It is not allowed to assume puzzle shrinkage, compactness of impressions, local connectivity, or a priori bounds unless those appear as accepted theorem-tag imports with checked assumptions.

Use discipline: Use this name only for the final no-missing-link residual closure block. Development notes may expose missing links, but a final proof object for C1 must not end in a missing-link exit.

## Statement

For admissible finite representatives `A,B` in the covered domain:

```text
PersistentNonSeparation(A,B)
  and SeparatorCatalogueAdequacy(A,B)
  and FiberDefinitionAdapter(A,B)
  and ExitClosureForC1(A,B)
  and NoOpenMissingTheoremCatalogueLink(A,B)
=>
  BoundaryEquality(A,B)
  or EstablishedTrivialFiberTag(A,B)
```

Equivalently, once no missing theorem/catalogue link remains available, persistent non-separation cannot remain a distinct residual case.

## Accepted final exits

A final C1 proof object may close a residual case only by one of:

1. `FiniteSeparationCertificate`.
2. `BoundaryEqualityCertificate`.
3. `EstablishedTrivialFiberTag` with assumption checks.

The following is not an accepted final exit:

```text
MissingTheoremCatalogueLink
```

During research this exit is valuable because it exposes an honest gap. In the final C1 proof criterion it is forbidden as a terminal conclusion.

## Proof-object requirements

A Mojo-checked residual-closure proof object must include:

```text
ResidualCaseId
PersistentNonSeparationWitnessSchema
SeparatorCatalogueAdequacyDependency
FiberDefinitionAdapterDependency
ExitClosureCertificate
NoOpenMissingLinkCertificate
FinalExitCertificate
ImportedTheoremAssumptionPayloads
```

The finite checker must reject a proof object when:

- the final exit is a missing-link exit;
- an imported theorem tag lacks assumption payloads;
- boundary equality is represented only by matching labels;
- persistent non-separation is inferred from bounded search;
- a rank-2 circle, disk, arc, circumference, or analytic locus primitive is used.

## Relationship to the final conjecture

This block does not prove C1 alone. It is the last residual block needed after:

```text
SeparatorCatalogueSoundness
SeparatorCatalogueCompleteness
FiberDefinitionAdapter
ExitClosureForC1
```

If this block is proved on the global covered domain, then the remaining C1 proof is the formal composition of these already named blocks into a single final proof object.

## Next target

`C1FinalProofObjectSkeleton`: define the exact composition node accepted by the Mojo theorem kernel once all required blocks are proved.
