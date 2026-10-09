# C1 PersistentWakeAmbiguityExtraction

Status: frontier lemma, not a solved theorem.

This note refines the F1 obstruction-extraction route.  The current frontier object is:

```text
PersistentNonSeparation(A,B) := forall k. not Separated_k(A,B)
```

The next goal is not to infer same fiber immediately.  The goal is to force persistent non-separation to present structured evidence.  The first such structure is persistent wake ambiguity.

## Target lemma

```text
PersistentNonSeparation(A,B)
  and declared boundary carriers for A and B
  and `SeparatorCatalogueAdequacy` for admissible separators
  and shrinking nest discipline
=> PersistentWakeAmbiguity(A,B)
   or UndeclaredBoundaryCarrier(A,B)
   or NonShrinkingNestedCarrier(A,B)
   or MissingCatalogueExtensionality
```

This is an obstruction-extraction lemma.  It does not prove C1 by itself.

## Persistent wake ambiguity

A persistent wake ambiguity is a cofinal family of catalogue prefixes in which A and B cannot be assigned opposite certified open sides of any admissible rational-ray separator, even though the relevant finite address data remains declared.

Finite record shape:

```text
PersistentWakeAmbiguity(
  pair: IncidencePair,
  cofinal_prefix_claim,
  unresolved_wake_side_family,
  excluded_explanations
)
```

The object is meta-finite: it names a universal/cofinal proof obligation, but all local witnesses remain finite.

## Required exclusions

Before an ambiguity may be accepted as the active obstruction, the proof must rule out:

1. undeclared boundary carrier;
2. missing separator admissibility;
3. missing landing tag for an otherwise classical separator;
4. missing side-witness extraction;
5. finite bounded search masquerading as cofinal non-separation.

## Why this matters

If every persistent non-separation instance can be normalized into a persistent wake ambiguity, then the generic-boundary problem becomes a wake-ambiguity elimination problem.  That is the first plausible route toward a direct solution rather than a passive reduction to MLC.

## Next local target

Define `WakeAmbiguityRecord` and prove:

```text
PersistentNonSeparation(A,B)
  + declared carriers
  + no catalogue defect
=> exists WakeAmbiguityRecord(A,B)
```

The follow-up frontier lemma is then:

```text
PersistentWakeAmbiguity(A,B) => contradiction
```

or, more cautiously, a classification theorem showing every ambiguity belongs to an already established trivial-fiber family.
