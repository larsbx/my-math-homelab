# C1 — RationalSeparatorCodingCompleteness

Status: proof target for the completeness direction of `SeparatorCatalogueAdequacy`.

This note isolates the finite coding problem for classical rational-ray separators used in the fiber definition. It does not prove local connectivity, generic ray landing, or fiber triviality.

## Target lemma

```text
RationalSeparatorCodingCompleteness
```

For every classical separator used by the rational-ray fiber definition, if the separator is built from landed rational rays and an admissible landing theorem tag, then there is a canonical finite separator code accepted by the C1 grammar.

Symbolically:

```text
ClassicalRationalSeparator(S)
  and S uses only admitted landing classes
=> exists code.
     CanonicalSeparatorCode(code, S)
     and AdmissibleSeparatorCode(code)
```

This is only a coding lemma. It does not say that every pair of distinct fibers is separated by a finite prefix, and it does not say that absence from a finite prefix implies same fiber.

## Classical input shape

A classical rational-ray separator used here may be one of:

1. a two-ray separator whose boundary is a pair of landed rational parameter rays;
2. a parabolic wake boundary described by rational ray addresses and a parabolic landing tag;
3. a hyperbolic-component boundary separator, but only when the component-boundary theorem tag is explicit.

Generic boundary landing is not in scope.

## Finite code shape

The canonical finite code must contain:

1. normalized first ray address;
2. normalized second ray address;
3. separator kind;
4. landing tag;
5. optional component/wake identifier;
6. deterministic orientation convention;
7. theorem-tag identifier.

No measured angle, trigonometric datum, analytic singleton point, floating approximation, or renderer cell may appear in the code.

## Normalization rules

### Rational address

A ray address is encoded as:

```text
RayAddr(num, den)
```

with:

```text
den > 0
0 <= num < den
gcd(num, den) = 1
```

The address is an element of `Q/Z`. The pair `(num, den)` is the unique normalized representative.

### Pair ordering

A two-ray separator has two boundary addresses. The canonical code orders them lexicographically by `(den, num)` after normalization unless a theorem tag explicitly requires a named orientation.

The side labels are defined only after this canonical ordering. Reversing input rays must not produce a different separator identity.

### Duplicate collapse

If the two normalized addresses are equal, the code is invalid as a two-ray separator. Boundary equality is routed to structural incidence/equality handling, not separation.

### Landing tag

Accepted tags remain:

```text
RationalRayLanding
ParabolicLanding
HyperbolicBoundaryLanding
```

Rejected tags include:

```text
GenericBoundaryLanding
MLCBinding
NumericalLandingGuess
```

## Proof decomposition

### RSCC-1: rational normalization

Every rational address in `Q/Z` has a unique normalized representative.

This is elementary number theory.

### RSCC-2: separator identity invariance

Swapping the two boundary rays of a two-ray separator produces the same canonical separator identity.

The orientation convention is part of the finite schema, not part of the classical theorem.

### RSCC-3: admissible landing transfer

If the classical separator is justified by one of the admitted landing theorem tags, the finite code carries exactly that theorem-tag identifier.

This is a theorem-tag bookkeeping lemma, not a new analytic proof.

### RSCC-4: no generic landing smuggling

A separator depending on an unproved generic boundary landing fact cannot be encoded as admissible.

This keeps C1 equivalent to the known fiber/MLC frontier rather than accidentally assuming it.

## Output of the lemma

The output is only:

```text
CanonicalSeparatorCode(code, S)
AdmissibleSeparatorCode(code)
```

It is not:

```text
Separated_k(A,B)
SameFiber(A,B)
FiberTrivial(A)
MLC
```

Those require additional lemmas.

## Next blocker after this lemma

Once rational separator coding is accepted, the remaining hard-direction blockers are:

1. `LandingTagCompletenessForFiberSeparators`;
2. `SideWitnessExtraction`;
3. `FairEnumerationLemma`.

The most dangerous of these is `LandingTagCompletenessForFiberSeparators`: it must exactly match the classical fiber definition and may not import generic landing assumptions.
