# C1 final proof object skeleton

Status: priority-zero composition target.

This document defines the only final proof-object shape that may mark the priority conjecture as proved inside the repository. It is an internal checker contract, not manuscript terminology.

## Purpose

The final proof object is a finite composition certificate. It does not discover the proof by search. It records that every required theorem block has already been checked and then composes them into the final implication:

```text
A != B  =>  exists k. Separated_k(A,B)
```

Equivalently:

```text
forall k. not Separated_k(A,B)  =>  BoundaryEquality(A,B)
```

The object is accepted only when every analytic import is explicit, every finite rule has been checked by the Mojo proof layer, and the missing-link exit is absent.

## Required blocks

A final proof object must contain checked references to the following blocks:

1. `SeparatorCatalogueSoundness`
   - finite separator certificates imply classical rational-ray separation under the declared adapter.

2. `SeparatorCatalogueCompleteness`
   - every admitted classical rational-ray separator has a finite separator certificate at some prefix.

3. `FiberDefinitionAdapter`
   - persistent non-separation is interpreted as same-fiber membership on the covered classical domain.

4. `ResidualClosureNoMissingLinks`
   - every persistent non-separation case closes through finite separation, boundary equality, or an established trivial-fiber tag.
   - the `MissingTheoremCatalogueLink` exit is forbidden in the final proof.

5. `ExitClosureForC1`
   - each permitted residual exit has a sound final interpretation.

6. `BoundaryEqualitySoundness`
   - accepted boundary-equality certificates imply equality in the target boundary/fiber adapter.

7. `TheoremTagImportSoundness`
   - accepted trivial-fiber theorem tags name an external theorem, scope, and assumption payload.

## Forbidden final ingredients

The final proof object must reject:

- bounded search as evidence of universal persistent non-separation;
- numerical pictures or renderer output;
- label-only equality;
- rank-2 circle, disk, arc, circumference, or analytic locus primitives;
- generic landing claims without theorem tags;
- any final use of `MissingTheoremCatalogueLink`;
- any unchecked imported analytic theorem.

## Composition rule

The final composition rule is:

```text
Given A,B in the covered admissible domain.
Assume forall k. not Separated_k(A,B).
Use SeparatorCatalogueAdequacy and FiberDefinitionAdapter to obtain SameFiber(A,B).
Use ResidualClosureNoMissingLinks to obtain a permitted closed exit.
Use ExitClosureForC1 to interpret the exit.
If the exit is finite separation, contradict the assumption.
If the exit is boundary equality, conclude BoundaryEquality(A,B).
If the exit is an established trivial-fiber tag, conclude BoundaryEquality(A,B) through the checked theorem-tag adapter.
Therefore persistent non-separation implies boundary equality.
Contrapositively, distinct representatives are separated at some finite prefix.
```

## Kernel acceptance conditions

The Mojo proof layer may mark the final proof object accepted only if:

```text
all_required_blocks_checked = true
residual_missing_link_exit_absent = true
all_imported_theorem_tags_checked = true
boundary_equality_soundness_checked = true
finite_separator_soundness_checked = true
covered_domain_declared = true
no_rank2_locus_primitive_used = true
no_bounded_search_shortcut_used = true
```

If any condition is false, the object is not a C1 proof object.

## Current status

The skeleton is now defined, but the final proof is not complete. The next priority target is `FinalProofBlockLedger`: a ledger that records each required block as `unproved`, `proved`, `imported-with-assumptions`, or `rejected`, so the final checker can refuse partial proofs with precise diagnostics.
