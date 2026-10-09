# C1 Catalogue Extensionality

Status: active blocker for the top conjecture.

This document states the exact proof needed to connect the finite catalogue grammar to Schleicher-style rational-ray separation. It is the current highest-priority proof obligation.

## 1. Finite side

A finite catalogue prefix `Cat_k` contains only finite records:

- rational ray addresses in `Q/Z`;
- theorem-tagged landed-ray records;
- finite separation-line records;
- incidence references, not analytic points;
- side labels for components cut by a certified separation line.

The finite relation is:

```text
Separated_k(A, B)
```

meaning: there exists a certified separation line in `Cat_k` whose finite side predicate places incidence object `A` and incidence object `B` on opposite sides.

The finite same-fiber prefix relation is the negation:

```text
SameFiber_k(A, B) := not Separated_k(A, B)
```

No finite prefix may claim generic fiber equality. It may only report absence of a separator in that prefix.

## 2. Classical side

Schleicher-style fibers are defined using separation by rational rays landing at known points of the Mandelbrot set. The classical relation is:

```text
Separated_classical(a, b)
```

meaning: some admissible rational-ray separation line separates the two referents.

The same-fiber relation is:

```text
SameFiber_classical(a, b) := not Separated_classical(a, b)
```

## 3. Catalogue extensionality statement

Let `interp(A)=a` and `interp(B)=b` be theorem-tagged interpretations of finite incidence objects as classical referents. Catalogue extensionality is:

```text
exists k. Separated_k(A, B)
    iff
Separated_classical(a, b)
```

Equivalently:

```text
forall k. SameFiber_k(A, B) for every finite prefix k
    iff
SameFiber_classical(a, b)
```

The left side is a meta-level stream statement, not a finite certificate of equality.

## 4. Direction CE-1: finite catalogue soundness

Claim:

```text
Separated_k(A, B) => Separated_classical(interp(A), interp(B))
```

Required checks:

1. every ray address in the line is rational and normalized;
2. every landed-ray record has a valid landing theorem tag;
3. the separation-line record is finite and well-formed;
4. the side predicate is computed from the finite line record, not from visual geometry;
5. incidence refs map to the intended theorem-tag referents.

This direction should be mostly definitional plus theorem-tag validation.

## 5. Direction CE-2: catalogue completeness

Claim:

```text
Separated_classical(a, b) => exists k. Separated_k(A, B)
```

This is the real proof burden.

Required checks:

1. every admissible classical rational-ray separation line has a finite code in the grammar;
2. the enumeration of catalogue prefixes is fair: every finite code appears at some finite depth;
3. the finite side predicate agrees extensionally with the classical separation relation for that line;
4. theorem-tagged interpretations of `A` and `B` preserve the relevant side relation.

No MLC assumption is allowed here. This is not a triviality claim; it is only a representation/exhaustion claim for rational-ray separators.

## 6. Consequence for C1

Once CE-1 and CE-2 are proven, the top conjecture can be stated cleanly:

```text
all finite rational-ray nests stabilize
    iff
all Schleicher fibers are trivial
    iff
MLC
```

The first equivalence is no longer a vague analogy. It is the stream form of catalogue extensionality plus the definition of fiber.

## 7. Explicit non-claims

Catalogue extensionality does not prove:

- MLC;
- generic singleton fibers;
- that any finite prefix proves same-fiber equality;
- that unresolved boxes shrink;
- that visual pixels are classified.

It proves only that the finite catalogue enumerates exactly the rational-ray separators used by the classical fiber relation.

## 8. Current blocker

The immediate missing lemma is:

```text
FairEnumerationLemma:
  every finite admissible rational-ray separation line code appears in some Cat_k.
```

This is now the next highest-priority lemma.
