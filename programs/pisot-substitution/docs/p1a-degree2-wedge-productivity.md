# Bounded K2-nonzero wedge-productivity certificate

**Status:** exact finite-domain theorem for the corpus below. General wedge
productivity remains open.

## Statement

Let `S_3` be the set of substitutions on three letters whose three nonempty
images have length at most three, whose incidence matrix is primitive, and
whose characteristic polynomial is irreducible Pisot. Construct each reachable
balanced-pair automaton from the three standard swap seeds, rejecting the
entire classification if the 20,000-state cap is reached.

> **Bounded wedge-productivity exclusion.** No fully constructed automaton in
> `S_3` contains a recurrent noncoincident SCC `C` that is closed under all
> children, has no coincidence child, and has `K2(T) != 0` for some `T in C`.

By the proved wedge dichotomy, a hypothetical strict component in this case
would have its rational `K2` vectors span `Lambda^2 Q^3`. The computation
does not infer productivity merely from that span: it checks the defining
closure and coincidence-child predicates directly.

## Canonical certificate

`kernel/wedge_productivity_catalog.mojo` is the source of truth. It:

1. enumerates the exact 4,554-member bounded PIP corpus;
2. constructs every reachable automaton and fails closed on a capped build;
3. computes recurrent noncoincident SCCs;
4. checks every outgoing child occurrence for closure and coincidence;
5. tests nonzero `K2` exactly; and
6. reports zero strict `K2`-nonzero components.

The CI workflow separately rejects a retained cap marker, a nonzero process
status, or any countermodel marker.

## Countermodel retention

A survivor is emitted before the expected zero count is checked:

```text
D2_COUNTERMODEL_BEGIN {substitution indices and component size}
D2_COUNTERMODEL_STATE <state index> <exact normalized word pair>
D2_COUNTERMODEL_EDGE <source index> <target index>
D2_COUNTERMODEL_END
```

The substitution indices reconstruct the images in the driver's canonical
enumeration. The normalized word pairs and all child edges make the alleged
closed carrier independently replayable.

## Boundary of the result

This certificate does not prove:

- wedge productivity for arbitrary primitive irreducible Pisot substitutions;
- that every reachable balanced-pair automaton is finite;
- G1 or G1b-2;
- the `K2 == 0` concentration case outside the bounded corpus;
- SCC Producer or the Pisot substitution conjecture;
- the historical degree-three Galois certificate or the open concentration/aux-B gate.

Together with the bounded degree-three result, it excludes strict components
of first defect degree two or three only inside the stated corpus. Removing
the image-length and finite-enumeration restrictions still requires a uniform
closed-carrier argument.
