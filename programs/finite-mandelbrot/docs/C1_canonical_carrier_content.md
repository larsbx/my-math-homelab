# C1 — CanonicalCarrierContent

Status: active C1 frontier proof target.

## Terminology declaration: CanonicalCarrierContent

**Genealogy:** This term packages standard finite-combinatorial ideas: canonical representatives, finite incidence data, sorted finite lists, and content equality up to presentation. It is not a new topological invariant and is not a substitute for classical fiber theory.

**Bridge claim:** Definition-only project term. `CanonicalCarrierContent(C)` is the finite normal form used by the C1 carrier-refinement machinery to compare two carrier presentations without trusting display labels, order of declaration, or prose names.

**Known leaks:** The normal form is only as good as the chosen finite atoms and unresolved obligations. Equality of canonical carrier content is not equality of classical fibers. Strict decrease of carrier content is a local proof-progress measure, not a proof of MLC or C1 by itself.

**Use discipline:** Use this term only for finite incidence records. Do not use it for metric size, diameter, analytic loci, circles, disks, arcs, or singleton points. At rank 2, only coordinate records, polynomial constraints, and quadrance scalars are available.

## Purpose

`NoRenamingAsRefinement` requires a stable comparison target. A carrier presentation may rename the carrier, reorder its components, or restate obligations in different prose. None of those changes should count as strict refinement.

The project therefore introduces a canonical finite content representation:

```text
CanonicalCarrierContent(C) = (
  sorted_incidence_atoms,
  sorted_unresolved_obligations,
  sorted_boundary_candidates,
  sorted_missing_links
)
```

Every field is finite and order-independent after normalization.

## Content atoms

An incidence atom has the logical shape:

```text
Atom(kind, normalized_id, payload_tag)
```

Allowed atom kinds for C1 are:

- `RootHandleRef`
- `RayAddressSetRef`
- `DyadicBoxRef`
- `SeparatorRef`
- `SideWitnessRef`
- `BoundaryCandidateRef`
- `ObligationRef`

The atom id must be normalized. Display names are ignored.

## Obligation atoms

An unresolved obligation has the logical shape:

```text
Obligation(kind, normalized_target, status)
```

Allowed obligation kinds are:

- `LandingTagMissing`
- `CatalogueLinkMissing`
- `WakeOrderUnderdetermined`
- `BoundaryEqualityCandidate`
- `CarrierTooCoarse`

Allowed statuses are:

- `open`
- `discharged`
- `rerouted`

## Equality rule

Two carrier presentations have the same canonical content exactly when all normalized finite fields agree:

```text
CanonicalCarrierContent(C0) = CanonicalCarrierContent(C1)
```

This equality ignores display labels and source ordering.

## Strict refinement rule

A carrier presentation `C1` is a strict refinement of `C0` only if at least one finite content component changes in a productive direction:

1. unresolved obligation count decreases;
2. a boundary candidate is refined to structural equality or rejected;
3. a missing link is discharged or rerouted to a named theorem/catalogue obligation;
4. a side witness or separator witness is added and routes to opposite-side separation;
5. a carrier-too-coarse atom is replaced by strictly more specific finite incidence atoms.

A pure rename, reorder, comment rewrite, or display-label update is not strict refinement.

## Non-claims

This document does not claim:

- C1 is proved;
- any generic fiber is trivial;
- finite content equality is classical fiber equality;
- a finite bounded search proves persistent non-separation;
- a rank-2 circle, disk, arc, or analytic locus exists.

## Next target

The next local proof target is:

```text
CanonicalContentRefinementOrder
```

It must show that the productive changes above induce a well-founded local order usable by `StrictCarrierRefinementWellFounded`.
