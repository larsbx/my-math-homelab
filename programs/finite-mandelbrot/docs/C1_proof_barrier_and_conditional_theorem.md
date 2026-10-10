# C1 frontier reduction and conditional theorem

Status: active frontier-reduction note.

The current top conjecture is positioned at the central frontier:

```text
finite rational-ray nest stabilization
  <=> triviality of Mandelbrot fibers
  <=> MLC-style local-connectivity frontier
```

This file records what can be proved from the finite grammar already introduced, and what must be attacked directly to solve the generic-boundary case. The frontier is not treated as impossible or terminal. It is the target.

## What is now reducible to local finite lemmas

The repository has decomposed `SeparatorCatalogueAdequacy` into local obligations:

1. admissible rational separator coding;
2. landing-tag coverage for allowed rational-ray separators;
3. side-witness extraction;
4. fair finite enumeration;
5. opposite-side separation soundness;
6. finite-prefix existential introduction.

When these are discharged, the project may claim the following conditional theorem.

## Conditional theorem C1-local

For incidence objects `A` and `B`, assuming the local obligations above:

```text
ClassicallySeparated(A,B)
  <=> exists k. Separated_k(A,B)
```

This is `SeparatorCatalogueAdequacy`. It is not yet the global solution.

## Conditional theorem C1-global

Assuming `SeparatorCatalogueAdequacy` and using the classical fiber definition by rational-ray separation:

```text
SameFiberStream(A,B)
  <=> not exists k. Separated_k(A,B)
```

A finite nest stabilizes to a singleton incidence object exactly when the corresponding classical fiber is trivial.

## The frontier target

The remaining generic assertion is:

```text
for every boundary incidence object A, the fiber of A is trivial
```

This is the active target, not a reason to stop. The finite-regime project should attack it by replacing analytic point language with incidence objects, replacing visual/numerical intuition with rational-ray catalogues, and proving that nontrivial fibers force a finite combinatorial obstruction visible to the catalogue machinery.

## C1-frontier attack plan

The frontier is now split into three proof routes:

### Route F1: obstruction extraction

Assume a nontrivial fiber. Derive a persistent finite incidence obstruction:

```text
NontrivialFiber(A)
  => exists B != A. for all k, not Separated_k(A,B)
```

Then strengthen the catalogue until such persistent non-separation must violate one of the finite incidence axioms.

### Route F2: nest shrinkage forcing

Show that every valid finite nest either:

1. emits a separating code at a finite level; or
2. strictly refines the incidence carrier in a well-founded finite measure.

The intended contradiction is an infinite non-shrinking stream with no new separator.

### Route F3: established-case expansion

Extend theorem-tagged triviality beyond current established examples. Every new family gives a verified island where C1 is no longer conditional.

## Allowed established cases

The project may provide theorem-tagged examples for cases where classical work already supplies triviality of fibers, including:

- Misiurewicz parameters;
- points on boundaries of hyperbolic components;
- other literature-backed families only when a stable theorem tag is added.

## Disallowed claims

No file may claim:

- all generic boundary fibers are trivial without a proof route discharging F1/F2/F3;
- finite-prefix non-separation proves same fiber;
- finite-prefix shrinkage proves MLC by itself;
- fair enumeration proves stabilization;
- a renderer proves local connectivity;
- a numerical image proves a fiber statement.

## Current conclusion

The current conjecture is unsolved in the repository, but it remains the active solvable target:

```text
C1 is reduced to `SeparatorCatalogueAdequacy` plus the generic fiber-triviality frontier.
```

The next productive move is to finish local catalogue-extensionality, then attack the generic case through obstruction extraction and nest-shrinkage forcing rather than treating the frontier as closed.
