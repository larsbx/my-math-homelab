# C1 WakeMembershipSoundness

Status: focused proof skeleton for the highest-priority conjecture C1.

This note isolates the local blocker named by `C1_side_assignment_soundness.md`:

```text
WakeMembershipSoundness
```

The goal is not to prove MLC, not to certify generic boundary landing, and not to construct a renderer. The goal is narrower:

> If a finite witness says that an incidence object lies in the wake side of an admissible separator, then the corresponding classical object lies on the matching side of the corresponding rational-ray separation line.

## Objects

### Incidence object

An incidence object is finite data such as:

```text
IncidenceObjectRef(kind, stable_id)
```

It may refer to a root handle, ray-address set, dyadic box, or `PointVertex`. It is not an analytic singleton.

### Separator

A separator is an admissible code from `C1_admissible_separator_codes.md`:

```text
TwoRaySeparator(ray_left, ray_right, landing_tag)
ComponentArcSeparator(boundary_tag, landing_tag)
```

The landing tag must be one of the allowed theorem-backed tags. Generic boundary landing is forbidden.

### Wake side

For a two-ray separator with rational addresses `a` and `b`, the finite wake side is specified by a cyclic interval in `Q/Z`:

```text
WakeInterval(a, b, orientation)
```

The complementary side is the other cyclic interval. No measured angle, trigonometric coordinate, or analytic curve parameter is part of the finite witness.

## Finite witness

A wake-membership witness has the shape:

```text
WakeMembershipWitness(
  object_ref,
  separator_code,
  probe_address,
  interval_orientation,
  cyclic_order_certificate,
  theorem_tag
)
```

It is accepted only if:

1. the separator code is admissible;
2. the probe address is normalized in `Q/Z`;
3. the cyclic-order certificate places the probe address strictly inside one of the two cyclic intervals cut by the separator addresses;
4. the theorem tag licenses reading this symbolic wake relation as the corresponding classical wake side;
5. the object is linked to the probe address by finite incidence data.

## Local theorem target

```text
WakeMembershipSoundness:
  AcceptedWakeMembershipWitness(W, side)
  -> ClassicalSide(W.object_ref, W.separator_code, side)
```

This is a one-way soundness lemma.

The converse is not part of this local lemma. Completeness belongs to `SeparatorCatalogueAdequacy` and fair enumeration.

## Strict interval condition

If the probe address equals either separator boundary address, the witness is not a side witness. It is an `OnSeparator` structural case.

```text
probe = a or probe = b
  -> OnSeparator
  -> not a separation proof
```

This avoids collapsing landing at the separator into membership of either component side.

## Proof decomposition

### WM-1 Normalization

Every address in the witness is a normalized rational address:

```text
0 <= num < den, den > 0, gcd(num, den) = 1
```

### WM-2 Cyclic interval arithmetic

The predicate `strictly_between_cyclic(a, probe, b)` is finite arithmetic over integers:

- reduce all fractions to a common positive denominator;
- compare integer residues modulo the common denominator;
- use strict inequality after choosing orientation.

### WM-3 Boundary exclusion

If the probe is equal to a separator boundary address, the witness is rejected as wake membership and routed to `OnSeparator`.

### WM-4 Incidence binding

The probe address must be part of the object's incidence carrier or licensed by a theorem tag linking the object to that address.

### WM-5 Classical reading

The theorem tag translates symbolic wake membership to the classical side relation for the admissible separator.

This is the only analytic bridge in this local proof. It is externalized as a theorem tag rather than re-proved inside the finite calculus.

## Non-goals

This lemma does not show that two objects are in different fibers by itself. It supplies one side assignment. Separation requires two accepted side assignments for the same separator with opposite strict sides.

This lemma does not imply that failure to find wake membership means same fiber. Finite-prefix non-separation remains weaker than stream-level non-separation.

This lemma does not assert that all boundary objects have finite wake addresses. That belongs to the global C1/MLC frontier.

## Next blocker after this lemma

After `WakeMembershipSoundness`, the next blocker is:

```text
OppositeSideSeparationSoundness
```

which proves:

```text
AcceptedSide(A, sep, Left)
AcceptedSide(B, sep, Right)
--------------------------------
ClassicallySeparated(A, B)
```
