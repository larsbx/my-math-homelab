# C1 — ClassicalSeparationToFiniteWitness

Status: proof skeleton for the completeness direction of `SeparatorCatalogueAdequacy`.

This note isolates the direction

```text
ClassicallySeparated(A, B) => exists k. Separated_k(A, B)
```

for the C1 bridge. It does not prove MLC, fiber triviality, or convergence of finite nests. It only proves that every classical rational-ray separator admitted by the fiber definition is eventually represented by a finite catalogue code.

## 1. Inputs

A classical separation claim has the form:

```text
ClassicalSeparator(S, a, b)
```

where:

- `S` is a Schleicher-style rational-ray separation line or theorem-tagged component-boundary separator;
- `a` and `b` are classical referents of finite incidence objects `A` and `B`;
- `a` and `b` lie in opposite complementary components of the separator;
- the separator is admissible for the fiber definition.

The project is not allowed to invent generic boundary landings. Every separator must be backed by a permitted theorem tag.

## 2. Output

The finite output is:

```text
FiniteWitness(k, code, side_A, side_B)
```

with:

- `code` an admissible finite separator code;
- `code` appears in catalogue prefix `k`;
- `side_A` and `side_B` are accepted side-assignment witnesses;
- `side_A.side != side_B.side`;
- neither side is `OnSeparator`;
- `FinitePrefixToExistentialSeparation` then introduces `exists j <= k. Separated_j(A,B)`.

## 3. Decomposition

### CFW-1 Rational code extraction

Every classical rational-ray separator used by the fiber definition has finite rational address data:

```text
RayAddr(num, den)
```

with `den > 0`, `0 <= num < den`, and normalized representation.

### CFW-2 Landing tag preservation

The classical separator may enter the finite catalogue only through an admissible landing tag:

```text
RationalRayLanding
ParabolicLanding
HyperbolicBoundaryLanding
```

Rejected tags remain rejected:

```text
GenericBoundaryLanding
MLCBinding
```

### CFW-3 Side witness extraction

Classical opposite-side information must be re-expressed as finite side evidence:

```text
RayOrder
WakeMembership
ComponentBoundaryTag
```

This is where `WakeMembershipSoundness` and the companion order lemmas attach.

### CFW-4 Fair enumeration occurrence

Given an admissible finite code, `FairEnumerationLemma` must provide a finite prefix bound:

```text
exists k. AppearsInPrefix(code, k)
```

This is purely enumeration-theoretic. It does not assert stabilization.

### CFW-5 Existential introduction

Once the prefix and opposite accepted side witnesses are available,
`FinitePrefixToExistentialSeparation` gives:

```text
exists j <= k. Separated_j(A,B)
```

## 4. Remaining blockers

The hard direction is reduced to four local obligations:

1. `RationalSeparatorCodingCompleteness`
2. `LandingTagCompletenessForFiberSeparators`
3. `SideWitnessExtraction`
4. `FairEnumerationLemma`

Of these, the next highest-priority blocker is:

```text
RationalSeparatorCodingCompleteness
```

because no finite-prefix argument can begin until every classical separator in scope has a canonical finite code.

## 5. Non-claims

This note does not claim:

- finite non-separation implies same fiber;
- absence from a finite prefix implies nonexistence;
- every boundary parameter has a trivial fiber;
- MLC;
- renderer completeness;
- any analytic singleton point primitive.
