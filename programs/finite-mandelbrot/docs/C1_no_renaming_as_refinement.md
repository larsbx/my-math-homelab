# C1 — NoRenamingAsRefinement

Status: active local proof obligation for `StrictCarrierRefinementWellFounded`.

Terminology declaration: NoRenamingAsRefinement

Genealogy: This is a finite bookkeeping analogue of well-founded descent arguments in proof theory and rewriting systems: a reduction step must lower a measure or discharge an obligation, not merely change notation.

Bridge claim: definition-only local project rule. It is not a theorem about Mandelbrot fibers. It constrains the finite carrier-refinement machinery used in the C1 frontier route.

Known leaks: A syntactic carrier label may change when a genuine refinement occurs, but the label change is not the refinement. Conversely, two differently named carriers may encode the same finite incidence content. The rule therefore compares finite content and obligation status, not display names.

Use discipline: Use this term only for the local C1 carrier machinery. Do not use it to claim C1, MLC, local connectivity, singleton fibers, or global stabilization.

## Problem

The previous C1 step introduced a finite descent measure:

```text
M(Carrier) = (
  unresolved_wake_slot_count,
  carrier_vertex_count,
  boundary_candidate_count,
  missing_link_count
)
```

Strict carrier refinement is only meaningful if each refinement step either:

1. strictly decreases this measure;
2. produces opposite-side separation;
3. produces boundary-equality refinement;
4. exposes a missing theorem/catalogue link.

A step that merely renames a carrier, reorders equivalent finite fields, or changes presentation while preserving the same incidence content is not refinement.

## Finite content identity

Two carrier records are content-identical when they have the same finite incidence data after canonicalization:

```text
same carrier vertices
same unresolved wake slots
same boundary candidates
same missing-link obligations
same admissible separator references
```

Names, display order, file paths, and human-readable labels do not affect content identity.

## No-renaming rule

```text
RenamingOnly(C0, C1)
  => not StrictCarrierRefinement(C0, C1)
```

A proposed refinement must provide at least one productive certificate:

```text
MeasureDecrease
or OppositeSideSeparation
or BoundaryEqualityRefinement
or MissingTheoremCatalogueLink
```

## Role in C1

This rule prevents the F1 obstruction-extraction path from cycling through equivalent carriers. It does not prove that strict refinement terminates globally by itself; it is the local anti-cycle lemma needed by `StrictCarrierRefinementWellFounded`.

## Rank-2 ontology boundary

This proof route does not use a circle, disk, arc, circumference, or analytic locus at rank 2. Rank-2 data contributes coordinate records and quadrance scalars only; carrier refinement is an incidence-layer operation.

## Next target

After `NoRenamingAsRefinement`, the next local proof obligation is:

```text
CanonicalCarrierContent
```

That target defines the canonical finite content representation used to decide whether two carrier presentations are genuinely the same.
