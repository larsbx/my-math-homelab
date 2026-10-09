# C1 WakeAmbiguityElimination

Status: active frontier proof route.

This note attacks the highest-priority conjecture by trying to eliminate the first obstruction class introduced in F1:

```text
PersistentWakeAmbiguity(A,B)
```

The aim is not to claim C1 is solved. The aim is to reduce persistent ambiguity to a finite set of sharper alternatives, each of which can be attacked directly.

## Rank-2 ontology reminder

At rank 2, a circle is undefined. The proof may use:

- finite rational addresses;
- cyclic order on address records;
- incidence objects;
- wake labels as theorem-tagged combinatorial regions;
- quadrance as a scalar polynomial when needed.

The proof may not use:

- circle;
- unit circle;
- disk;
- arc as rank-2 geometry;
- analytic point-locus language.

Any locus-like object must live at a higher incidence or constraint layer.

## Target lemma

```text
WakeAmbiguityElimination:
  PersistentWakeAmbiguity(A,B)
    -> contradiction
       or EstablishedTrivialFiberFamily(A,B)
       or NonShrinkingNestedCarrier(A,B)
       or MissingClassicalInput
```

The desired strongest version is:

```text
PersistentWakeAmbiguity(A,B) -> contradiction
```

but the current honest route keeps the weaker disjunction until the subcases are closed.

## Ambiguity data

A persistent wake ambiguity record consists of:

1. a pair of distinct incidence objects `A,B`;
2. a cofinal family of catalogue levels;
3. at each selected level, at least one admissible separator candidate whose side evidence fails to separate `A` and `B`;
4. an explanation of failure:
   - both sides unresolved;
   - one object on separator boundary;
   - conflicting wake assignments;
   - missing landing tag;
   - non-shrinking carrier;
   - missing catalogue-extensionality lemma.

## Elimination strategy

### E1. Boundary equality case

If either object is persistently `OnSeparator`, then the ambiguity is not open-side ambiguity. It becomes an incidence/refinement problem:

```text
OnSeparatorCofinal(A,S_n) -> BoundaryCarrierRefinement(A)
```

This should either classify `A` into an established theorem-tagged family or move the obstruction to `UndeclaredBoundaryCarrier`.

### E2. Conflicting wake assignments

If an object receives incompatible finite wake assignments for the same separator family, then one of the side witnesses is invalid or the separator identity has not been canonicalized.

Expected reduction:

```text
ConflictingWakeAssignments ->
  SideWitnessFailure or SeparatorCodingFailure
```

This should not survive once side-assignment soundness and canonical separator coding are proved.

### E3. Both sides unresolved

If both objects remain unresolved across a cofinal family, then the carrier sequence must be non-shrinking or the catalogue is missing separators that classical separation requires.

Expected reduction:

```text
CofinalUnresolvedWake ->
  NonShrinkingNestedCarrier or MissingCatalogueExtensionality
```

This is the key frontier subcase.

### E4. Missing landing tag

If ambiguity persists only because landing is unavailable, then the obstruction belongs to `LandingTagCompletenessForFiberSeparators`, not to wake ambiguity itself.

## Proof obligation split

The elimination route is split into local lemmas:

1. `BoundaryEqualityRefinement`;
2. `ConflictingWakeCollapse`;
3. `UnresolvedWakeToCarrierObstruction`;
4. `MissingLandingTagReroute`;
5. `NoResidualWakeAmbiguity`.

The highest-priority next lemma is:

```text
UnresolvedWakeToCarrierObstruction
```

because it is the place where a persistent failure of finite wake-side evidence should force the non-shrinking carrier obstruction that C1 must eventually eliminate.

## Disallowed shortcut

The following is invalid:

```text
many prefixes fail to separate A and B
therefore A and B are same fiber
```

Persistent non-separation is a universal prefix hypothesis, and even that only begins the obstruction-extraction route. It is not the result.
