# C1 FinitePrefixToExistentialSeparation

Status: local proof obligation for the C1 bridge.

This note closes a small but important logical gap in the finite-fiber program.  A
finite prefix of the separator catalogue may contain an accepted separator with
opposite-side witnesses.  That is not yet catalogue completeness, and it is not
fiber triviality.  It is only the existential claim that some finite level
separates the two incidence objects.

## Target lemma

Let `A` and `B` be finite incidence object references.  Let `k` be a natural
prefix level of the fair separator catalogue.  If the prefix contains a record

```text
PrefixWitness(k, S, side_A, side_B)
```

such that:

1. `S` is an admissible separator code;
2. `S` occurs in catalogue prefix `k`;
3. `side_A` is an accepted side-assignment witness for `A` relative to `S`;
4. `side_B` is an accepted side-assignment witness for `B` relative to `S`;
5. the sides are opposite open sides, not `OnSeparator`;
6. the theorem tag attached to `S` licenses classical reading of the separator;

then:

```text
exists j <= k such that Separated_j(A, B)
```

or, equivalently for the project grammar:

```text
ExistsFiniteSeparation(A, B)
```

## What this lemma does not prove

It does not prove:

- every classical separator appears in some prefix;
- absence of separation in prefix `k` implies same fiber;
- absence of separation in all checked prefixes implies same fiber;
- generic boundary landing;
- MLC;
- fiber triviality.

Those remain separate obligations.

## Dependency chain

This lemma depends on prior local objects:

```text
AdmissibleSeparatorCode
SideAssignmentWitness
SideAssignmentSoundness
OppositeSideSeparationSoundness
FairCataloguePrefix
```

It feeds the catalogue-extensionality bridge by giving the easy direction:

```text
finite accepted prefix witness => existential finite separation
```

The hard remaining direction is still:

```text
classical separation => eventually enumerated finite separator code
```

which belongs to `SeparatorCatalogueAdequacy` / fair enumeration.

## Proof sketch

1. Read the prefix witness as finite data.
2. Verify that the separator code is admissible.
3. Verify that the code occurs in prefix `k`.
4. Verify that both side assignments bind to the same separator.
5. Verify that the two incidence objects are distinct.
6. Verify that both sides are accepted open sides and are opposite.
7. Apply `OppositeSideSeparationSoundness`.
8. Introduce the existential witness using the concrete prefix index `k`.

The proof is intentionally local.  The existential index is supplied by the
prefix witness itself; no compactness, limit, or global boundary theorem is used.

## Acceptance criterion

The repository may mark this lemma complete only when the finite scaffold has a
record containing all of:

```text
prefix_level
separator_id
left_object_ref
right_object_ref
left_side_witness_id
right_side_witness_id
accepted_by_local_checks
```

and the tests verify that the resulting existential claim is unavailable when:

- the separator is missing from the prefix;
- the assignments use different separator ids;
- either side is `OnSeparator`;
- the sides are the same;
- either local witness is rejected;
- the code attempts to infer global same-fiber status.
