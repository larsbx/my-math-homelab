# C1 ExitClosureForC1

Status: highest-priority C1 proof route.

This file closes the next gap after `ResidualDescentContradiction`. The contradiction theorem says an infinite residual case cannot persist once residual refinement and well-founded strict carrier refinement are available. That still leaves a proof-management question: every permitted exit must land in a C1-relevant bucket rather than create a new open-ended obstruction.

## Terminology declaration: ExitClosureForC1

Genealogy: This term is a project proof-management layer over standard complex-dynamics alternatives: separation by rational parameter rays, boundary identification through accepted theorem tags, and known trivial-fiber families.

Bridge claim: Conditional finite proof route. It does not add a new complex-dynamical theorem. It states that the exits produced by the finite residual-descent machinery must be typed as separator evidence, theorem-tag evidence, or disclosed missing-link obligations.

Known leaks: This does not prove the residual frontier lemma, separator-catalogue adequacy, or MLC. It also does not reprove Douady-Hubbard landing, Yoccoz puzzle shrinkage, parapuzzle results, a-priori bounds, or Schleicher fiber theory. Those enter only through named theorem tags with audited assumptions.

Use discipline: Use only for the closure step that consumes allowed residual exits. Do not cite it as proof of C1 unless the needed separator-catalogue adequacy, residual refinement, strict-refinement well-foundedness, and theorem-tag assumptions have all been checked.

## Input theorem route

From the current stack we have a conditional route:

```text
ResidualDescentContradiction:
  PersistentNonSeparation
  + NoMissingTheoremCatalogueLink
  + NoBoundaryEquality
  + ResidualFrontierRefinement
  + WellFoundedStrictCarrierRefinement
  -> no infinite residual persistence
```

The permitted exits named there are:

```text
FiniteSeparation
BoundaryEqualityRefinement
MissingTheoremCatalogueLink
EstablishedTrivialFiberTag
```

## Closure obligation

`ExitClosureForC1` requires:

```text
FiniteSeparation
  -> exists k. Separated_k(A,B)

BoundaryEqualityRefinement
  -> SameClassicalObjectOrDeclaredBoundaryIdentification(A,B)
     or MissingTheoremCatalogueLink

MissingTheoremCatalogueLink
  -> finite obligation record with source theorem family, missing adapter,
     and affected separator/wake/carrier code

EstablishedTrivialFiberTag
  -> imported theorem tag with checked assumptions and finite adapter witness
```

The key discipline is that no exit may be accepted as plain prose.

## Mojo theorem-kernel representation

The Mojo theorem kernel owns the finite proof objects:

```text
ResidualExitCertificate
  kind: finite-separation | boundary-equality | missing-link | theorem-tag
  source_rule: residual-descent | manual-audit | imported-theorem
  finite_payload_present: Bool
  theorem_tag_checked: Bool
  adapter_checked: Bool
```

The kernel may check finite rule applications and adapter predicates. It must not silently internalize imported analytic results.

## C1 consequence route

Once every exit is closed:

1. finite separation gives the separated side of the fiber relation;
2. established trivial-fiber tags give known singleton-fiber cases under their audited hypotheses;
3. boundary equality reduces the pair to a declared identification rather than a non-separated distinct pair;
4. missing links are finite proof obligations, not generic counterexamples.

Therefore the remaining unsolved C1 pressure is exactly where the deep-research audit placed it:

```text
prove or refute ResidualFrontierRefinement at MLC-strength;
prove SeparatorCatalogueAdequacy under audited classical definitions;
validate theorem-tag adapters for known special families.
```

## Forbidden shortcuts

The following are rejected by this closure layer:

- treating bounded search failure as persistent non-separation;
- treating an image, renderer, or numerical plot as theorem evidence;
- accepting a theorem tag without assumptions and adapter checks;
- accepting a boundary-equality phrase without a finite identification witness;
- importing circle, disk, arc, circumference, polar-angle, or analytic-locus primitives into rank 2.

## Next proof move

The next target is `SeparatorCatalogueAdequacyProofObjects`: define the finite proof-object format that the Mojo theorem kernel checks for separator-catalogue soundness, completeness, and adequacy.
