# C1 Admissible Separator Codes

Status: C1 proof-track artifact. This document supports the highest-priority conjecture only.

## Purpose

`SeparatorCatalogueAdequacy` requires a finite grammar whose codes enumerate exactly the rational-ray separation lines used by the fiber definition. This document defines the admissible separator-code boundary.

The project-owned task is not to prove analytic ray landing inside the finite core. The finite core verifies that a code has the correct finite shape and then attaches theorem tags for the classical landing/separation facts.

## Objects

### Ray address

A ray address is a normalized rational address

```text
RayAddr(num, den)
```

with:

- `den > 0`;
- `0 <= num < den`;
- `gcd(num, den) = 1`.

The only operation on ray addresses needed for C1 is symbolic doubling:

```text
D(num/den) = (2*num mod den)/den
```

No measured-angle interpretation is permitted.

### Landing tag

A landing tag records which theorem discharges landing:

```text
LandingTag ::= RationalRayLanding | ParabolicLanding | HyperbolicBoundaryLanding
```

A generic boundary landing tag is forbidden. Generic stabilization is the open frontier, not a finite input.

### Two-ray separation line

A two-ray separator is:

```text
TwoRaySeparator(left: RayAddr, right: RayAddr, landing_tag: LandingTag)
```

Admissibility requires:

1. both addresses are normalized rational addresses;
2. `left != right`;
3. both addresses are landed by accepted theorem tags;
4. the pair is declared co-landing or endpoint-compatible by the tag-specific finite hypotheses;
5. the separator is used only as a finite separation relation between incidence objects, not as an analytic curve object.

### Component arc separator

Some fiber definitions allow separation lines that include arcs inside hyperbolic components. The finite grammar may encode these only as theorem-tagged component arcs:

```text
ComponentArcSeparator(root: RootHandle, component_id, landing_tag)
```

Admissibility requires the component arc to be attached to a known hyperbolic-boundary/root tag. No generic component boundary claim is allowed.

## Catalogue enumeration

A catalogue prefix at depth `N` must enumerate every admissible code whose size is at most `N`, where size is measured by:

```text
size(code) = max(bit_length(numerators), bit_length(denominators), tag_size, component_id_size)
```

Fairness means:

```text
forall admissible code c, exists N such that c in CataloguePrefix(N)
```

This is the enumeration lemma required by C1. It is not an MLC statement.

## Soundness direction

If a code appears in a catalogue prefix and validates, then it is a legitimate finite presentation of a classical rational-ray/hyperbolic separator.

This uses theorem tags for analytic landing. The finite core checks only rational address normalization, tag admissibility, endpoint compatibility, and incidence-object separation bookkeeping.

## Completeness direction

If a classical Schleicher-style rational-ray separation line is allowed by the chosen fiber definition, then it has a finite code in this grammar.

This is the catalogue-extensionality bridge. It depends on accurately matching the chosen fiber definition's allowed separation-line class.

## Non-claims

The grammar does not claim:

- generic ray landing;
- generic singleton fibers;
- finite-prefix stabilization;
- local connectivity;
- any renderer or pixel classification result.

It only defines the finite separator-code universe for C1.
