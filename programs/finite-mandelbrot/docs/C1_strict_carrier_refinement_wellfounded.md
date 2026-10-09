# C1 StrictCarrierRefinementWellFounded

Status: active proof route for the highest-priority conjecture.

Terminology declaration: strict carrier refinement well-foundedness

Genealogy: This term is a project-local proof obligation built from standard finite descent arguments, finite incidence refinement, and rational-ray separation/fiber language. It is not a new classical Mandelbrot term.

Bridge claim: Definition-only project term. It packages the claim that repeated accepted strict refinements of a finite incidence carrier must make progress in a finite combinatorial measure unless the process exposes separation, boundary equality, or a missing theorem/catalogue link.

Known leaks: A finite descent measure is not by itself a proof of fiber triviality. It only controls the project carrier language. The bridge to classical fibers still depends on `SeparatorCatalogueAdequacy` and theorem-tagged rational-ray separation.

Use discipline: Use only for finite carrier objects. Do not identify it with MLC, local connectivity, analytic shrinking, metric diameter, or any rank-2 circle/locus primitive.

## Purpose

The previous route established the intended productive cases for a carrier obstruction:

```text
AcceptedCarrierObstruction
  => StrictCarrierRefinement
   | MissingTheoremCatalogueLink
   | BoundaryEqualityRefinement
   | RefinesToOppositeSideSeparation
```

This file states the next local proof obligation: repeated `StrictCarrierRefinement` cannot continue indefinitely inside the finite carrier language without forcing one of the other productive outcomes.

## Finite carrier state

A carrier state is a finite incidence record with:

1. a finite list of carrier vertices;
2. a finite list of unresolved wake-side slots;
3. a finite list of boundary-equality candidates;
4. a finite list of required theorem/catalogue links;
5. a finite list of already discharged separator witnesses.

No analytic point, circle, disk, arc, circumference, or rank-2 locus is part of this state.

## Descent measure

Use a lexicographic finite measure:

```text
M(Carrier) = (
  unresolved_wake_slot_count,
  carrier_vertex_count,
  boundary_candidate_count,
  missing_link_count
)
```

A strict carrier refinement must either:

1. strictly reduce `unresolved_wake_slot_count`; or
2. split a carrier vertex into a finite set of sharper incidence vertices while immediately discharging at least one unresolved slot; or
3. convert an unresolved slot into `BoundaryEqualityRefinement`; or
4. convert an unresolved slot into `MissingTheoremCatalogueLink`; or
5. convert an unresolved slot into `RefinesToOppositeSideSeparation`.

A refinement that only renames a carrier or adds bookkeeping is not strict.

## Local theorem target

```text
StrictCarrierRefinementWellFounded:
  there is no infinite sequence
    C0 > C1 > C2 > ...
  of accepted strict carrier refinements
  that preserves all unresolved wake slots
  and produces none of the other productive outcomes.
```

This is a finite combinatorial theorem target, not a global Mandelbrot theorem.

## Why this matters for C1

The C1 frontier route tries to eliminate persistent wake ambiguity. If every carrier obstruction must either refine productively or expose a missing theorem/catalogue link, then persistent ambiguity cannot remain amorphous. It must become:

- an actual finite descent;
- a boundary-equality case;
- a missing bridge lemma;
- or an opposite-side separation witness.

## Next proof target

`NoRenamingAsRefinement`: prove that accepted strict refinement requires a decrease or productive case, and cannot be satisfied by carrier relabeling alone.
