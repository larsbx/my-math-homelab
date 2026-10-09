# Alignment audit deep-research findings

Terminology used here is governed by `docs/terminology-registry.md`.

Status: incorporated research audit, September 2026.

This document records the findings from the deep literature and terminology audit and turns them into repository-facing obligations.

## Executive outcome

finite-mandlebrot-research is well aligned in one major respect: it distinguishes finite certificate vocabulary from classical analytic claims. The project already has a strong Genealogy / Bridge Claim / Known Leaks / Use Discipline discipline.

The critical correction is that several C1 proof-state terms describe statements whose mathematical strength is much larger than their finite bookkeeping presentation suggests.

Most importantly:

```text
PersistentNonSeparation(A,B)
  := forall k. not Separated_k(A,B)
```

combined with separator-catalogue adequacy gives the classical same-fiber relation on the covered domain. Therefore any argument that eliminates every distinct persistently non-separated pair has fiber-triviality strength. Under global coverage it is an MLC-strength result.

## Highest-priority corrections

### P0: Open-frontier strength classification

`ResidualFrontierRefinement` and any theorem that eliminates distinct persistent non-separation must be marked:

```text
OPEN_FRONTIER
potential_strength: fiber-triviality / MLC under catalogue adequacy and global coverage
```

until independently proved in conventional complex-dynamics language.

### P0: No finite-state-to-global-termination shortcut

A finite carrier at each stage does not imply the absence of an infinite chain. A global descent theorem requires either:

1. a uniform finite bound over all reachable states; or
2. a ranking function into a known well-founded order, with strict decrease on every internal transition.

Any phrase of the form `finite/bounded therefore terminates` is invalid unless it names the ranking or uniform-bound theorem.

### P0: Status semantics

Machine-readable status must distinguish:

- proof skeleton present;
- local obligations open;
- conditional theorem assembled;
- theorem proved;
- external theorem dependency;
- open frontier.

A status field must not say `assembled = true` in a way that can be misread as theorem completion while dependencies remain false.

### P1: Rename catalogue extensionality

The literature and formalization ecosystem use `extensionality` primarily for equality principles. The C1 bridge is not extensionality in that sense. It is an adequacy theorem for an encoding/enumeration.

Preferred names:

```text
SeparatorCatalogueSoundness
SeparatorCatalogueCompleteness
SeparatorCatalogueAdequacy
```

### P1: Rank-2 ontology wording

The correct invariant is not a broad mathematical denial that circles exist. It is a layer restriction:

```text
Circle, disk, arc, circumference, polar angle, connected component, interior,
boundary, and analytic locus are not primitive constructors, APIs, or inference
rules at the R2 certificate layer.
```

The rank-2 layer exposes coordinate records, coefficient operations, polynomial operations, polynomial predicates, and quadrance scalars only. Analytic/topological statements require an explicit higher-layer adapter.

### P1: Theorem tags become structured dependencies

A theorem tag must carry:

- exact source key;
- theorem name or number when available;
- hypotheses;
- instantiated object domain;
- conclusion imported;
- adapter lemma;
- proof status.

Bare prose tags are not proof objects.

### P1: Mojo role

Mojo is the first-class language for finite computation and certificate execution in this repository. It should own:

- normalized integer/rational arithmetic adapters;
- coordinate-record operations;
- interval and polynomial evaluators;
- separator-code normalization;
- certificate witness structs;
- finite combinatorial scans;
- SIMD/vectorization-ready kernels;
- memory-layout-conscious data structures.

Mojo is not the trusted theorem kernel. Mathematical proof-status claims must remain separate from executable witness checks unless a theorem adapter states exactly what is imported.

## Publishable target after remediation

The strongest tractable contribution is not a premature proof of MLC. It is:

```text
A finite, Mojo-executable certificate calculus for rational-ray separator
catalogues, with a proved adequacy theorem relative to the classical fiber
separation definition, plus explicit theorem-dependency and open-frontier gates.
```

After that, the genuinely new mathematical target is the residual frontier theorem in conventional complex-dynamics language.

## Immediate repository changes required

1. Add explicit `OPEN_FRONTIER` and `MLC_STRENGTH_CANDIDATE` status gates.
2. Replace ambiguous theorem status fields with `proof_skeleton_present` and `theorem_status`.
3. Introduce `SeparatorCatalogueAdequacy` vocabulary and retire `catalogue extensionality` for new work.
4. Reword R2 circle restrictions as layer/API restrictions.
5. Make Mojo the default first-class execution and encoding language.
6. Add tests that prevent finite-state and bounded-search language from proving global termination.
7. Add external-theorem dependency records for classical analytic imports.
