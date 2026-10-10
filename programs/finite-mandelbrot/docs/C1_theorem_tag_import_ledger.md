# C1 theorem-tag import ledger

Status: priority proof infrastructure.

This internal ledger records every classical complex-dynamical theorem family that the finite proof checker may import while proving the priority conjecture. The point is not to reprove analytic theorems in Mojo. The point is to prevent hidden imports from doing unrecorded work.

## Relation to the final proof

The final proof object may import an analytic theorem only through a checked theorem tag. A checked theorem tag must provide:

```text
TheoremTagName
SourceFamily
CoveredClass
ConclusionKind
AssumptionPayload
AdapterUse
StrengthClass
ImportStatus
```

A tag is acceptable for the final proof only if:

1. its source family is named;
2. its covered class is explicit;
3. its conclusion kind is one of the allowed conclusion kinds below;
4. all assumptions required by the theorem are present in the finite or adapter payload;
5. the tag does not assert a generic MLC-strength conclusion unless the final proof is already supplying the missing global argument;
6. the tag is not being used as a missing-link placeholder.

## Allowed conclusion kinds

The allowed conclusion kinds are:

```text
RationalParameterRayLanding
RationalRaySeparatorInterpretation
FiberDefinitionEquivalence
KnownTrivialFiberClass
YoccozPuzzleLocalConnectivityUnderHypotheses
RenormalizationWithAprioriBounds
BoundaryIdentificationSoundness
TuningKneadingSubstitution
HarmonicMeasureAlmostEveryFibreTrivial
```

Any other conclusion kind is rejected by the final proof checker until added to this ledger with source, scope, assumptions, and strength classification.

## Strength classes

```text
FINITE_ONLY
CLASSICAL_IMPORTED_LOCAL
CLASSICAL_IMPORTED_CLASS_SPECIFIC
MLC_STRENGTH_GLOBAL
FORBIDDEN_PLACEHOLDER
```

The final proof may use `FINITE_ONLY`, `CLASSICAL_IMPORTED_LOCAL`, and `CLASSICAL_IMPORTED_CLASS_SPECIFIC` tags when their assumptions are checked.

`MLC_STRENGTH_GLOBAL` may appear only as the theorem being proved or as an explicitly marked open frontier. It may not be imported as a premise for the priority conjecture.

`FORBIDDEN_PLACEHOLDER` is never final-proof admissible.

## Initial theorem-tag families

### Rational parameter-ray landing

Tag family:

```text
RationalParameterRayLanding
```

Source family: Douady-Hubbard parameter ray theory and Schleicher's combinatorial proof of landing of rational parameter rays for Multibrot sets.

Covered class: rational external addresses whose parameter rays are covered by the cited landing theorem.

Conclusion kind: `RationalParameterRayLanding`.

Assumption payload:

```text
rational_address
period_preperiod_data
family_identifier
landing_theorem_source
on_separator_convention
```

Strength class: `CLASSICAL_IMPORTED_LOCAL`.

Final use: allowed for separator certificates only after the finite address data and source-family scope are checked.

For the source-specific `c=-2`, address-`1/2` payload, the canonical checked
record is `rational_parameter_ray_landing_c_minus_2_tag_checked()`. That record
is admissible only when the consumer also validates the concrete source payload
and the proof-grade landing-target association; the checked record by itself is
not a landing proof.

### Rational-ray separator interpretation

Tag family:

```text
RationalRaySeparatorInterpretation
```

Source family: standard rational-ray separation/fiber definitions in the parameter plane.

Covered class: pairs of representatives for which the finite adapter has identified the classical parameter-plane representatives and the relevant rays have accepted landing tags.

Conclusion kind: `RationalRaySeparatorInterpretation`.

Assumption payload:

```text
accepted_landing_tags
same_separator_reference
opposite_open_side_witnesses
on_separator_cases_routed
adapter_representatives_declared
```

Strength class: `CLASSICAL_IMPORTED_LOCAL`.

Final use: allowed for separator-certificate soundness.

### Fiber-definition equivalence

Tag family:

```text
FiberDefinitionEquivalence
```

Source family: Schleicher-style fiber definitions and their equivalence with non-separation by admitted rational-ray separators under the selected conventions.

Covered class: the exact domain named by the adapter.

Conclusion kind: `FiberDefinitionEquivalence`.

Assumption payload:

```text
separator_family_matches_fiber_definition
on_separator_convention_matches_adapter
representatives_are_in_adapter_domain
all_separator_imports_checked
```

Strength class: `CLASSICAL_IMPORTED_LOCAL`.

Final use: allowed only after separator-catalogue adequacy is checked on the same domain.

### Known trivial-fiber classes

Tag family:

```text
KnownTrivialFiberClass
```

Source family: published trivial-fiber/local-connectivity results for specific classes, including Misiurewicz parameters and appropriate hyperbolic/parabolic boundary classes when covered by the cited theorem.

Covered class: a named class with exact hypotheses.

Conclusion kind: `KnownTrivialFiberClass`.

Assumption payload:

```text
class_name
finite_membership_certificate
source_family
hypotheses_checked
adapter_domain_matches
```

Strength class: `CLASSICAL_IMPORTED_CLASS_SPECIFIC`.

Final use: allowed only for class-specific closure. It cannot be used as a generic boundary theorem unless the source theorem actually has that scope.

For the exact `c=-2`, orbit-type `(2,1)` instance, the canonical checked
record is `misiurewicz_c_minus_2_trivial_fiber_tag_checked()`. It is consumed
only together with the proof-grade exact-target association and the
`known_trivial_fiber` payload. This authorizes the class-specific conclusion
for that instance only; it does not authorize generic MLC, all-fiber
triviality, `ResidualClosureNoMissingLinks`, or C1.

### Yoccoz-type local connectivity under hypotheses

Tag family:

```text
YoccozPuzzleLocalConnectivityUnderHypotheses
```

Source family: Yoccoz puzzle/parapuzzle local-connectivity theorems and later variants under their stated assumptions.

Covered class: the theorem's exact non-renormalizable or finitely renormalizable domain, depending on the source.

Conclusion kind: `YoccozPuzzleLocalConnectivityUnderHypotheses`.

Assumption payload:

```text
theorem_source
renormalization_status_certificate
combinatorial_recurrence_data
puzzle_or_parapuzzle_hypotheses_checked
adapter_domain_matches
```

Strength class: `CLASSICAL_IMPORTED_CLASS_SPECIFIC`.

Final use: allowed only when the exact hypotheses are checked. It is not a substitute for MLC.

### Renormalization with a priori bounds

Tag family:

```text
RenormalizationWithAprioriBounds
```

Source family: renormalization and a priori-bounds theorems in the quadratic/unicritical literature.

Covered class: the exact infinitely or finitely renormalizable class named by the source.

Conclusion kind: `RenormalizationWithAprioriBounds`.

Assumption payload:

```text
theorem_source
renormalization_combinatorics
apriori_bound_hypotheses
adapter_domain_matches
conclusion_scope
```

Strength class: `CLASSICAL_IMPORTED_CLASS_SPECIFIC` unless the source and assumptions are global, in which case using it as a premise for the priority conjecture is forbidden.

Final use: allowed only for class-specific exits.

### Boundary-identification soundness

Tag family:

```text
BoundaryIdentificationSoundness
```

Source family: adapter-level equality definitions plus theorem-tag sources needed to identify on-separator, co-landing, or class-specific boundary equality cases.

Covered class: adapter-declared representatives with finite equality payloads.

Conclusion kind: `BoundaryIdentificationSoundness`.

Assumption payload:

```text
finite_equality_payload
on_separator_cases_routed
co_landing_sources_if_used
adapter_domain_matches
label_only_equality_rejected
```

Strength class: `CLASSICAL_IMPORTED_LOCAL` or `CLASSICAL_IMPORTED_CLASS_SPECIFIC`, depending on the source used.

Final use: allowed only when equality is not merely a label or presentation identity.

### Tuning as a kneading substitution

Tag family:

```text
TuningKneadingSubstitution
```

Source family: Douady–Hubbard tuning (polynomial-like renormalization and the tuning operator on parameter space), written on kneading sequences in the symbolic dynamics of Bruin and Schleicher; the Derrida–Gervois–Pomeau star product for the real case.

Covered class: a superattracting centre of period `p` given by a periodic rational ray address, and the kneading sequences of the parameters in its tuned copy.

Conclusion kind: `TuningKneadingSubstitution`: the kneading sequence of the tuned parameter is the image of the kneading sequence of the base parameter under the constant-length-`p` substitution `s -> prefix . (s xor twist)` of `docs/C1_residual_directive_carrier.md`.

Assumption payload:

```text
centre_address
period
kneading_prefix
continuation_rule_source
tuning_theorem_source
angle_tuning_instances_checked
adapter_domain_matches
```

Strength class: `CLASSICAL_IMPORTED_CLASS_SPECIFIC`.

Final use: allowed only to read a residual directive carrier as a statement about kneading sequences of tuned parameters. It is not a statement about parameter-plane shrinking, a priori bounds, or fibre triviality, and it cannot be used as a residual exit.

### Harmonic-measure-almost-every fibre triviality

Tag family:

```text
HarmonicMeasureAlmostEveryFibreTrivial
```

Source family: harmonic measure and expansion on the boundary of the Mandelbrot set (Graczyk and Świątek), with the Collet-Eckmann symbolic-dynamics route (Smirnov). Both are reported results and must be pinned with their exact statements before any final use.

Covered class: harmonic-measure-almost every parameter of the boundary of `M`, that is, all external angles outside a Lebesgue-null set.

Conclusion kind: `HarmonicMeasureAlmostEveryFibreTrivial`: for almost every boundary parameter with respect to harmonic measure, the fibre is trivial and `M` is locally connected there.

Assumption payload:

```text
theorem_source
measure_declared
exceptional_set_is_null_not_empty
parameter_not_selected_from_the_exceptional_set
adapter_domain_matches
conclusion_scope
```

Strength class: `CLASSICAL_IMPORTED_CLASS_SPECIFIC`.

Final use: allowed only for statements whose conclusion is itself measure-theoretic, with the null exceptional set named. **It may not discharge `PersistentNonSeparation(A,B)` for any named pair, and it is not a residual exit.** A null set is not an empty one: the infinitely renormalizable parameters carried by `docs/C1_residual_directive_carrier.md` lie inside the exceptional set, and they are exactly the residual class the C1 route must still decide. `harmonic_measure_tag_discharges_a_named_pair()` returns `False`.

Relation to the finite side: `docs/C1_separated_pair_density.md` computes the exact measure of the pairs a finite catalogue prefix decides. That finite density is Lebesgue measure on external angles, not harmonic measure on the boundary; identifying the two is this tag's business, under this tag's hypotheses.

## Forbidden imports

The final proof may not import:

```text
GenericMLC
AllFibersTrivial
EveryPersistentNonSeparationCollapses
ResidualClosureNoMissingLinks
BoundedSearchTermination
RendererEvidence
NumericalPictureShrinkage
```

unless the imported statement is explicitly the theorem being proved by the final proof object. In particular, `ResidualClosureNoMissingLinks` cannot be a theorem tag premise for itself.

## Current bottleneck

This ledger supports the current priority block:

```text
ResidualClosureNoMissingLinks
```

The next proof step is to convert all class-specific residual exits into checked theorem-tag imports or finite separation/boundary-identification certificates. Any case that still exits as `MissingTheoremCatalogueLink` remains open and blocks the final proof.
