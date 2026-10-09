# C1 unresolved wake to carrier obstruction

Status: frontier proof route, not a solved theorem.

This note continues F1 obstruction extraction for the highest-priority conjecture C1:

```text
finite rational-ray nest stabilization
  <=> Mandelbrot fiber triviality frontier
```

The immediate target is to make unresolved wake evidence structurally useful. A persistent wake ambiguity should not remain a loose label. It must either refine away, become a boundary-carrier issue, or expose a missing catalogue-extensionality lemma.

## Terminology declaration: carrier obstruction

Genealogy: The term is project-local. It descends from the field-recognizable language of fibers, wakes, rational-ray separation, impressions, and boundary-access relations in one-dimensional complex dynamics. It is not an established standard phrase.

Bridge claim: definition-only project term. A carrier obstruction is a finite incidence-level explanation for why wake-side evidence does not yet yield a separator-side decision.

Known leaks: The term does not prove nontrivial fiber existence. It does not replace classical impressions, prime ends, wakes, or fibers. It only records that the finite incidence carrier is too coarse or incomplete for the attempted side assignment.

Use discipline: Use only in C1 frontier documents and C1 source files. When used outside C1 files, cite this declaration or add a local terminology declaration.

## Terminology declaration: unresolved wake evidence

Genealogy: Project-local refinement of wake-membership evidence. It is tied to rational external-address order and wake combinatorics, not to measured-angle geometry.

Bridge claim: definition-only project term. It records a finite attempt to place an incidence object relative to an admissible separator where the side cannot yet be certified as `Left` or `Right`.

Known leaks: It is not the same as classical non-separation. It is not a numerical failure. It may disappear under refinement, new theorem tags, or a stronger incidence carrier.

Use discipline: It may support obstruction extraction only when paired with a prefix/cofinality condition. A bounded failed search is not unresolved wake evidence.

## Rank-2 restriction

No rank-2 circle, disk, arc, circumference, or analytic locus is used. Wake evidence is symbolic and incidence-level: rational addresses, separator codes, side labels, and carrier references.

## Objects

```text
UnresolvedWakeEvidence := {
  object_ref,
  separator_code,
  prefix_index,
  attempted_side_data,
  failure_kind
}
```

Allowed `failure_kind` values:

1. `BoundaryEqualityCandidate` — the object may lie on the separator carrier.
2. `CarrierTooCoarse` — the incidence carrier lacks enough structure for side extraction.
3. `LandingTagMissing` — the separator has finite address data but no accepted theorem tag.
4. `CatalogueLinkMissing` — the separator code is admissible but not yet linked to a catalogue level.
5. `WakeOrderUnderdetermined` — finite address order data is insufficient to decide a side.

## Lemma target

```text
PersistentWakeAmbiguity(A,B)
  =>
    BoundaryEqualityRefinement(A,B)
    or CarrierObstruction(A,B)
    or MissingCatalogueExtensionality(A,B)
    or RefinesToOppositeSideSeparation(A,B)
```

This is not C1. It is a reduction step. Its job is to ensure that persistent ambiguity has a named structural cause.

## Proof plan

### UW-1. Normalize unresolved evidence

Every unresolved evidence record must be tied to:

- an admissible separator code;
- a prefix index;
- a finite incidence object;
- a theorem-tag status;
- a declared failure kind.

### UW-2. Exclude bounded-search failures

A finite list of failed separator attempts is not persistent ambiguity. The persistent object must quantify over cofinal prefix data or be explicitly marked as a frontier hypothesis.

### UW-3. Boundary equality reroute

If the unresolved evidence repeatedly lands in `BoundaryEqualityCandidate`, route to boundary-carrier refinement. Do not call this separation.

### UW-4. Carrier coarseness extraction

If side assignment fails because the incidence object lacks a carrier component required by the separator, extract `CarrierObstruction`.

### UW-5. Catalogue-link extraction

If the finite separator code exists but the prefix/catalogue link is missing, route to `MissingCatalogueExtensionality`.

### UW-6. Opposite-side refinement

If refinement supplies accepted opposite open-side witnesses for the same separator, route back to finite-prefix existential separation.

## Forbidden conclusions

This lemma may not conclude:

- C1 is proved;
- the fiber is trivial;
- the fiber is nontrivial;
- a finite bounded failure proves same fiber;
- rank-2 circle-like geometry is available.

## Next local target

Prove or formalize `CarrierRefinementProgress`:

```text
CarrierObstruction(A,B)
  =>
    a strictly refined finite carrier is required
    or a missing theorem/catalogue link is identified
```

This is the first place where the proof route must show progress rather than merely classify failure.