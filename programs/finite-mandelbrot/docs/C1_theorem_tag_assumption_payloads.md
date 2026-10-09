# TheoremTagAssumptionPayloads

Status: priority proof infrastructure for the final C1 proof object.

This document defines the finite assumption payloads required for theorem-tag imports. A theorem tag is not admissible merely because it names a classical result. It must also carry a checked payload showing that the finite representative lies in the source theorem's stated scope.

This file is internal proof infrastructure. It is not manuscript terminology.

## Rule

Every final theorem-tag import must provide:

```text
TheoremTagName
SourceFamily
ConclusionKind
StrengthClass
AssumptionPayloadKind
FiniteWitnessPayload
AdapterPayload
OpenFrontierUse = false
GenericMLCUse = false
```

A tag whose payload is absent, generic, or supplied only by a numerical picture is rejected.

## Payload kinds

### RationalParameterRayLandingPayload

Used for rational parameter-ray landing imports.

Required finite fields:

```text
rational_address_or_periodic_address_pair
address_denominators_nonzero
preperiod_period_or_periodic_data
landing_family_name
excluded_generic_boundary_assertion
adapter_to_parameter_ray_convention
```

Accepted use: landing and separator interpretation for the named rational-ray family.

Rejected use: proving local connectivity, triviality of every fiber, or residual closure.

### FiberDefinitionPayload

Used for imports connecting rational-ray separation data to the classical fiber relation.

Required finite fields:

```text
covered_representative_class
fiber_definition_convention
on_separator_case_policy
separator_family_matches_definition
boundary_identification_policy
adapter_to_classical_representatives
```

Accepted use: interpreting persistent non-separation as same-fiber only after separator-certificate adequacy is available.

Rejected use: asserting that same-fiber implies equality.

### KnownTrivialFiberPayload

Used for class-specific trivial-fiber imports such as Misiurewicz parameters, parabolic parameters under the cited hypotheses, or boundaries of named hyperbolic components where the cited theorem applies.

Required finite fields:

```text
class_name
classification_witness
source_theorem_family
hypothesis_match_witness
renormalization_status_if_required
adapter_to_boundary_equality
```

Accepted use: closing a residual case already classified into a theorem-covered family.

Rejected use: generic boundary closure.

### YoccozPuzzlePayload

Used only when a Yoccoz-style theorem is explicitly imported for a parameter class satisfying the theorem's hypotheses.

Required finite fields:

```text
puzzle_family
parameter_class
non_renormalization_or_control_hypothesis
combinatorial_recurrence_conditions
source_theorem_family
adapter_to_fiber_triviality
```

Accepted use: class-specific local connectivity or fiber-triviality conclusion under the theorem's hypotheses.

Rejected use: global MLC, arbitrary infinitely renormalizable cases, or unverified puzzle shrinkage.

### AprioriBoundsPayload

Used only when a theorem requiring a priori bounds is imported.

Required finite fields:

```text
renormalization_class
bounds_source
bounds_hypothesis_witness
modulus_or_combinatorial_control_record
source_theorem_family
adapter_to_local_connectivity_or_fiber_triviality
```

Accepted use: theorem-covered renormalizable classes.

Rejected use: assuming bounds for all infinitely renormalizable parameters.

## Final-proof admissibility

A theorem tag is admissible in the final proof only if:

1. its conclusion kind is one of the allowed final conclusion kinds;
2. its strength class is local, class-specific, or adapter-only;
3. it is not a generic MLC-strength import;
4. every required payload field is present;
5. the payload excludes the theorem itself from proving the residual closure theorem;
6. the adapter payload names how finite representatives are interpreted classically.

## Current priority after this file

After this payload format is in place, the next proof task is:

```text
TheoremTagPayloadInstances
```

That task should instantiate checked payload records for the first accepted families:

```text
RationalParameterRayLanding
FiberDefinitionEquivalence
MisiurewiczTrivialFiber
HyperbolicBoundaryTrivialFiber
```

No generic boundary tag is allowed as an instance.

## First source-specific instances

`kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo` binds the c=-2 finite data, replayed
on BigZ/Q (`kernel/mojo/certificates/c_minus_2/bigq_landing_target_adapter.mojo`: Krawczyk
localization and the five forbidden-collision exclusions on `beta_c_minus_2` at half-width
`2^-8`, and the `1/2` address orbit), to two explicit bibliography records:

- `SchleicherRationalParameterRays`, covering preperiodic rational parameter
  rays. The `1/2` address has replayed preperiod 1 and period 1. Final import
  admissibility comes from the proof-grade landing association, which verifies
  `R_{2,1}=C^3(C+2)` exactly, that `C=0` is lower type, and that `C=-2` has
  exact type `(2,1)`.
- `SchleicherFibersLC`, covering trivial fibers at Misiurewicz parameters. The
  `(ell, period) = (2, 1)` source scope is matched against the same replay;
  final import comes from the proof-grade class-specific classification.

The source-scope checks first ran on a checked Int64 path, since retired; the
BigZ/Q replay reproduces its verdicts exactly. These payload instances are not
a C1 proof, and the `TheoremTagPayloadInstances` proof block keeps the status
the ledger gives it.
