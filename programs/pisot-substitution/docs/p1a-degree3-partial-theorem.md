# P1-A degree-three partial concentration theorem

**Status:** proved only for the exact bounded corpus specified below. The
general concentration problem remains open. This result does not use the
the historical seed-specific Galois certificate or the open concentration gate.

## Statement

Let `S_3` be the set of substitutions on three letters whose three nonempty
images have length at most three, whose incidence matrix is primitive, and
whose characteristic polynomial is irreducible Pisot. For every `sigma` in
`S_3`, construct the reachable balanced-pair automaton from the three standard
seeds `(ab,ba)`, aborting the classification if its 20,000-state cap is met.

> **Bounded-corpus degree-three exclusion.** No resulting automaton contains a
> recurrent noncoincident component `C` which is closed under all children,
> has no coincidence child, satisfies `K2(T)=0` for every `T` in `C`, and has
> `K3(T)!=0` for some `T` in `C`.

Equivalently, no strict component of first defect degree three occurs in this
finite corpus. The enumeration contains 4,554 substitutions and reaches the
cap in zero cases.

## Proof certificate

`kernel/degree3_catalog.mojo` is the canonical exact computation. It:

1. enumerates the finite substitution domain and applies the exact PIP screen;
2. constructs every reachable automaton and rejects capped constructions as
   inconclusive;
3. computes recurrent noncoincident SCCs by the iterative graph kernel;
4. tests closure and nonproductivity on every outgoing child occurrence;
5. tests `K2=0` componentwise and `K3!=0` existentially; and
6. reports exactly zero strict first-degree-three components.

The same run finds 24 reachable degree-three states. It independently verifies
two stronger diagnostics for each: `Theta(K3)` does not commute with the
incidence matrix, and a coincidence is reached in at most two inflations.

The first diagnostic is tied to the proved general theorem. If a strict
component has first defect degree three, the signed intertwiner and
`rho(S)<=beta` put its rational `K3` image in the `det(M)` eigenspace of the
degree-three Lie representation. Under the `Theta` identification this implies
`M Theta(K3)=Theta(K3) M`. No Galois propagation is invoked.

## Countermodel preservation

The zero-result is not encoded by filtering candidates away. For each survivor
the Mojo driver first emits:

```text
D3_COUNTERMODEL_BEGIN {substitution indices and component size}
D3_COUNTERMODEL_STATE <state index> <exact normalized word pair>
D3_COUNTERMODEL_EDGE <source index> <target index>
D3_COUNTERMODEL_END
```

Only after that record is written does CI compare the survivor count with zero.
Thus a regression or enlarged corpus that refutes the bounded statement leaves
an exact replayable obstruction in the job log.

## Scope boundary

This proposition does not establish any of the following:

- concentration for arbitrary primitive irreducible Pisot substitutions;
- exclusion of first defect degree four or higher outside the bounded corpus;
- G1 or G1b-2;
- productivity of components with nonzero `K2`;
- the historical six-seed Galois theorem or the open concentration/aux-B gate.

For the general concentration gate, the surviving obligation is still to rule
out strict components with `K2` identically zero, including degree three and
higher, without an image-length bound and conditional only on the existence of
the finite carrier.
