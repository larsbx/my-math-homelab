# C1 SideAssignmentSoundness

Status: proof skeleton for the finite fiber stabilization bridge.

This note isolates the next local theorem needed for C1:

```text
SideAssignmentSoundness
```

It does not prove MLC, does not prove generic singleton fibers, and does not add new implementation work.

## 1. Inputs

A finite side-assignment witness has:

1. an incidence-object reference `A`;
2. an admissible separator code `S`;
3. a side label in `{Left, Right, OnSeparator}`;
4. finite evidence of one of the allowed forms:
   - `RayOrder`;
   - `WakeMembership`;
   - `ComponentBoundaryTag`.

The separator code is already required to be admissible by `C1_admissible_separator_codes.md`.

## 2. Soundness target

For every accepted finite side-assignment witness:

```text
SideAssignment(A, S, Left)
```

or

```text
SideAssignment(A, S, Right)
```

there is a corresponding classical side relation relative to the Schleicher-style separation line represented by `S`.

Symbolically:

```text
FiniteSide(A, S, side)
=>
ClassicalSide(A*, S*, side)
```

where `A*` and `S*` are theorem-tag referents, not finite-core primitives.

## 3. Non-separating structural case

`OnSeparator` is not a side for separation. It is a structural equality case.

Therefore:

```text
SideAssignment(A, S, OnSeparator)
```

may be useful for landing/root-boundary bookkeeping, but it cannot discharge:

```text
Separated_k(A, B)
```

for any `B`.

## 4. Evidence cases

### 4.1 RayOrder

`RayOrder` records a finite cyclic-order relation among rational ray addresses.

Soundness obligation:

```text
RayOrderSoundness:
finite cyclic order of rational addresses
=>
classical order of the corresponding landed parameter rays
```

The analytic input is not inside the certificate. It is the theorem-tagged fact that the relevant rational rays land.

### 4.2 WakeMembership

`WakeMembership` records that an incidence object is inside the finite wake cut out by a rational-ray pair.

Soundness obligation:

```text
WakeMembershipSoundness:
finite wake address data
=>
classical containment in the corresponding wake component
```

This is the main bridge from symbolic address order to parameter-plane separation.

### 4.3 ComponentBoundaryTag

`ComponentBoundaryTag` records side information relative to a hyperbolic component boundary separator.

Soundness obligation:

```text
ComponentBoundarySoundness:
certified component-boundary tag
=>
classical side relation for the corresponding separation line
```

This remains theorem-tagged and is allowed only for rational/parabolic/hyperbolic-boundary separators already admitted by the separator-code grammar.

## 5. The theorem needed by finite separation

Once both assignments are sound, finite separation is sound:

```text
FiniteSide(A,S,Left)
FiniteSide(B,S,Right)
--------------------------------
ClassicallySeparated(A*,B*)
```

and symmetrically for `Right`/`Left`.

Same-side assignments do not separate.

`OnSeparator` assignments do not separate.

Generic landing tags do not produce side assignments.

## 6. Remaining local blockers

The C1 chain now needs three local lemmas:

1. `RayOrderSoundness`;
2. `WakeMembershipSoundness`;
3. `ComponentBoundarySoundness`.

The next highest-priority one is `WakeMembershipSoundness`, because it is what makes finite separator codes classify incidence objects on either side of a rational-ray pair.
