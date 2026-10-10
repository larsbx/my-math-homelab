# C1 Persistent Non-Separation

Status: frontier-reduction object, not a proof of same fiber or MLC.

This note introduces the F1 obstruction-extraction object named in
`docs/C1_F1_obstruction_extraction.md`.

The goal is to represent the statement

```text
for every finite catalogue prefix k, A and B are not separated in prefix k
```

without collapsing it into a finite computation or into a solved generic fiber claim.

## Definition

For finite incidence objects `A` and `B`, define:

```text
PersistentNonSeparation(A,B)
  := forall k. not Separated_k(A,B)
```

where `Separated_k` is the finite prefix predicate defined by the C1 separation
stack.

This is a meta-level universal statement over finite prefixes. It is not a
single finite search unless an independent theorem gives a finite bound.

## Allowed use

Persistent non-separation may be used as an obstruction-extraction hypothesis:

```text
PersistentNonSeparation(A,B)
  => ObstructionCandidate(A,B)
```

The obstruction candidate must be classified into one of the active F1 forms:

1. persistent wake ambiguity;
2. undeclared boundary carrier;
3. non-shrinking nested carrier;
4. missing catalogue-extensionality lemma.

## Disallowed use

This object must not imply by itself:

- `SameFiber(A,B)`;
- `A = B`;
- singleton stabilization;
- MLC;
- local connectivity;
- absence of a classical separator.

Those require `SeparatorCatalogueAdequacy` plus the relevant classical/fiber theorem
bridge.

## Frontier use

The intended proof route is contrapositive:

```text
NontrivialFiber(A)
  => exists B != A. PersistentNonSeparation(A,B)
  => one of the F1 obstruction forms
  => contradiction by finite stabilization machinery
```

The last implication is the solvable frontier target. It is not marked complete.

## Acceptance invariant

Any module that accepts `PersistentNonSeparation` must carry:

- distinct incidence object references;
- a universal-prefix flag;
- no finite bound unless separately proved;
- no singleton/fiber-triviality conclusion;
- an obstruction classification status.
