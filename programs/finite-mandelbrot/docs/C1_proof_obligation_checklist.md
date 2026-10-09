# C1 Proof Obligation Checklist

Status: active proof target. This document supersedes implementation-side TODOs as the current project focus.

## C1 — finite fiber stabilization bridge

Top conjecture:

```text
finite rational-ray nest stabilization
  iff triviality of Mandelbrot fibers
  iff MLC
```

The project contribution is not a proof of MLC. The contribution is the finite-regime reduction: identify the finite objects whose stabilization is exactly fiber triviality, and separate established cases from the generic open frontier.

## Objects that must be defined before proof prose

1. `RayAddr`
   - rational address in `Q/Z`;
   - finite numerator/denominator record;
   - doubling is symbolic modular arithmetic.

2. `LandedRay`
   - ray address plus theorem tag proving classical landing in established cases;
   - no analytic ray parametrization inside the certificate.

3. `SeparationLine`
   - finite pair or finite set of landed rational rays plus optional landing vertex;
   - must be enough to define the complement components used by fiber theory;
   - cannot use measured angles or analytic point membership.

4. `Separated_k(a,b)`
   - finite predicate that two incidence objects are separated by a certified separation line from the depth-k finite catalogue.

5. `SameFiber_k(a,b)`
   - finite non-separation predicate over all certified separation lines up to depth k.

6. `FiberNest(a)`
   - descending sequence of finite non-separation classes:
     `SameFiber_0(a) >= SameFiber_1(a) >= ...`.

7. `Stabilizes(a)`
   - meta-level statement that the finite nest collapses to one incidence class / trivial fiber.
   - This is not a finite certificate for generic boundary points.

## Proof obligations

### PO-1: finite grammar matches Schleicher separation lines

Show that the finite `SeparationLine` grammar is extensionally the same kind of rational-ray separation data used in Schleicher fiber theory.

This is the first load-bearing bridge. If this fails, C1 is only an analogy.

### PO-2: SameFiber_k monotonicity

For each incidence object `a`:

```text
SameFiber_{k+1}(a) refines SameFiber_k(a)
```

because the depth-k+1 catalogue contains all depth-k certified separation lines plus more.

### PO-3: finite nest equals fiber definition

Show:

```text
intersection_k SameFiber_k(a) = SchleicherFiber(a)
```

provided the depth catalogues exhaust all certified rational separation lines.

This should be a definitional theorem once PO-1 is correct.

### PO-4: stabilization equals triviality

Show:

```text
FiberNest(a) stabilizes to a singleton incidence class
  iff SchleicherFiber(a) is trivial
```

This is the direct bridge from finite nests to fiber triviality.

### PO-5: global equivalence to MLC

Cite Schleicher's theorem/corollary:

```text
all fibers trivial iff Mandelbrot set locally connected
```

The certificate calculus does not reprove this.

### PO-6: established cases

For Misiurewicz parameters and hyperbolic-component boundary parameters, cite established fiber triviality and give finite witness sketches:

- rational ray landing tags;
- finite ray-address sets;
- finite separation-line catalogue sufficient for the established local proof;
- resulting `PointVertex` incidence package.

### PO-7: generic frontier

State explicitly:

```text
For generic boundary incidence objects, singleton stabilization is open and equivalent to the corresponding fiber-triviality / MLC obstruction.
```

No unconditional generic co-landing certificate may be claimed.

## Blocks removed from critical path

The following are blocked unless they directly support PO-1 through PO-7:

- bigint backend implementation;
- hash-root serialization;
- renderer/pixel pipeline;
- finite-field shadow experiments;
- Krawczyk optimization beyond established-case examples;
- broad arithmetic-dynamics exploration.

They remain useful engineering tasks, but they are not the current research bottleneck.
