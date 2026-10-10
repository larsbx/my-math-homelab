# C1 Finite Separation Predicate

Status: active C1 proof object.

This document defines the finite predicate that bridges admissible separator codes to the classical fiber relation. It is deliberately narrower than stabilization: it says when a finite separator proves two incidence objects are separated at a catalogue prefix. It does not claim that finite non-separation proves same fiber at finite time.

## Objects

An incidence object is a finite handle such as:

```text
IncidenceObjectRef(kind, id)
```

Allowed `kind` values on the C1 path:

- `RootHandle`
- `PointVertex`
- `DyadicBox`
- `RayAddressSet`

These are finite records. They are not analytic points.

A separator code is admissible only if it is accepted by the admissible separator-code grammar:

```text
AdmissibleSeparatorCode(code)
```

with theorem-tagged landing data restricted to already established classes:

- `RationalRayLanding`
- `ParabolicLanding`
- `HyperbolicBoundaryLanding`

The following are not admissible finite separator tags:

- `GenericBoundaryLanding`
- `MLCBinding`

## Side assignment

A separation line divides the finite presentation into two symbolic sides. A side assignment is a finite certificate:

```text
SideAssignment(object_ref, separator_code, side)
```

where

```text
side in {LeftSide, RightSide}
```

The project-owned finite check is only that:

1. `object_ref` is a finite incidence object;
2. `separator_code` is admissible;
3. the side label is one of the two allowed labels;
4. the side assignment is justified by a finite address/order/wake witness or by a theorem-tagged established separator.

## Finite separation predicate

For a catalogue prefix `Cat_k`, two incidence objects `A` and `B` are separated at level `k` iff there exists an admissible separator code `S` in `Cat_k` and certified side assignments placing `A` and `B` on different sides:

```text
Separated_k(A, B) :=
  exists S in Cat_k:
    AdmissibleSeparatorCode(S)
    and SideAssignment(A, S, LeftSide)
    and SideAssignment(B, S, RightSide)
```

or the same with left/right interchanged.

The predicate is symmetric:

```text
Separated_k(A,B) => Separated_k(B,A)
```

It is anti-reflexive for valid incidence objects:

```text
not Separated_k(A,A)
```

because a valid side assignment cannot place the same incidence handle on two distinct sides of the same separator.

## Same-fiber finite prefix relation

The finite prefix non-separation relation is defined negatively:

```text
SameFiberPrefix_k(A,B) := not Separated_k(A,B)
```

This is only a prefix relation. It is not equality of fibers.

The stream relation is the meta-level statement:

```text
SameFiberStream(A,B) := forall k, SameFiberPrefix_k(A,B)
```

Only the stream relation corresponds to classical same-fiber membership under `SeparatorCatalogueAdequacy`.

## Bridge target

The immediate theorem target is `SeparatorCatalogueAdequacy`:

```text
exists k. Separated_k(A,B)
  iff
ClassicallySeparated(A,B)
```

Once this is proved, the following becomes a definitional bridge:

```text
SameFiberStream(A,B)
  iff
not ClassicallySeparated(A,B)
```

and this is exactly Schleicher-style fiber membership, under the chosen finite-to-classical dictionary.

## Non-claims

This predicate does not prove MLC.

It does not prove generic singleton fibers.

It does not allow a finite prefix to claim stabilization.

It does not admit generic boundary landing as a finite separator.
