# C1 — CanonicalContentRefinementOrder

Status: proof route, not a completed C1 proof.

## Terminology declaration: CanonicalContentRefinementOrder

Genealogy: This term is a project-local finite-order refinement of standard well-founded descent arguments on finite combinatorial data. It is tied to the existing C1 carrier-content vocabulary, not to analytic geometry.

Bridge claim: Definition-only project term. It provides the local order needed by `StrictCarrierRefinementWellFounded`; it is not a theorem about Mandelbrot fibers by itself.

Known leaks: A decrease in this order proves finite progress inside the carrier calculus only. It does not prove local connectivity, MLC, singleton fibers, or global absence of nontrivial fibers. It also does not use metric diameter, area, circles, disks, arcs, or analytic loci.

Use discipline: Use only for comparing canonical finite carrier-content records. Do not use it for visual regions, continuum objects, or rank-2 locus claims.

## Input object

A canonical carrier content record has four sorted finite lists:

```text
Content = (
  incidence_atoms,
  unresolved_obligations,
  boundary_candidates,
  missing_links
)
```

The order ignores display names and source presentation order.

## Local refinement order

`C1 < C0` is accepted only if one of the following finite changes occurs:

1. **Obligation discharge** — the number of unresolved obligations decreases.
2. **Carrier split** — at least one incidence atom is replaced by a finite proper family of strictly more informative atoms, and no obligation count increases.
3. **Boundary candidate discharge** — a boundary candidate is resolved into structural equality, side separation, or a missing-link record.
4. **Missing-link exposure** — an unresolved ambiguity is converted into an explicit missing theorem/catalogue link.

The fourth case is productive even if the missing-link count increases, because it changes an implicit failure into a named proof obligation.

## Rejected pseudo-refinements

The following are not refinement:

- changing display labels;
- reordering atoms;
- replacing a term by a synonym;
- moving an unresolved obligation between files;
- adding a prose explanation without changing canonical finite content;
- introducing rank-2 circle, disk, arc, circumference, or analytic locus language.

## Well-foundedness target

The local order is well-founded when restricted to a bounded finite proof search state:

```text
No infinite chain C0 > C1 > C2 > ...
```

unless the process repeatedly exposes genuinely new missing theorem/catalogue links. Those links are not descent failures; they are promoted proof obligations.

## Relation to C1

This order supports the frontier route:

```text
CarrierObstruction
  -> CarrierProgressDichotomy
  -> CanonicalContentRefinementOrder
  -> StrictCarrierRefinementWellFounded
```

It does not prove C1. It prepares the finite descent machinery needed for the obstruction-elimination strategy.