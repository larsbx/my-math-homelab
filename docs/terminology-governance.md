# Terminology governance: recognizable mathematics first

Status: repository invariant.

The project may introduce new finite-regime language, but it must not hide private jargon behind familiar mathematical words. Any term used in theorem statements, proof sketches, source comments, or public documentation must satisfy one of two routes.

## Route A: field-recognizable term

Use standard mathematical language when possible. Examples include:

- fiber;
- rational ray;
- external address;
- landing;
- Misiurewicz parameter;
- parabolic parameter;
- hyperbolic component;
- kneading data;
- orbit portrait;
- dyadic box;
- interval arithmetic;
- Krawczyk operator;
- squarefree polynomial;
- incidence relation;
- equivalence relation;
- finite prefix;
- witness;
- theorem tag.

A file using only Route A terms should still avoid overclaiming. Recognizable terminology does not make a statement true.

## Route B: declared novel bridge term

A novel or cross-pollinated term is allowed only when the file explicitly provides a terminology declaration with all required fields:

```text
Terminology declaration: <Term>
Status: novel bridge term | analogy | theorem-backed isomorphism | definition-only
Genealogy:
- source concept 1: ...
- source concept 2: ...
Bridge claim:
- exact theorem/isomorphism, conditional theorem, analogy, or definition-only relation
Known leaks:
- where the abstraction fails
- which structure is not preserved
- which claims must not be inferred
Use discipline:
- allowed context
- forbidden context
```

The declaration must distinguish between:

- an actual theorem-backed isomorphism;
- a conditional bridge theorem;
- a definition used for this project only;
- a metaphor or analogy.

## Required leak discipline

Every novel bridge term must list leaks. A leak is any structure that the abstraction does not preserve. Examples:

- rank-2 coordinate records preserve polynomial arithmetic but do not introduce analytic points;
- quadrance is a scalar polynomial, not a rank-2 circle object;
- finite prefix non-separation is not same-fiber equality;
- fair enumeration is not stabilization;
- a theorem tag is not an internal proof;
- a rendered image is not a proof of local connectivity.

## Forbidden moves

The following moves are disallowed unless a terminology declaration explicitly resolves them:

- inventing a name and using it as if it were a standard theorem;
- saying two structures are "the same" without naming the map and preserved structure;
- using "isomorphism" without stating the domain, codomain, map, inverse, and preserved operations/relations;
- using an analogy without stating where it breaks;
- using field-recognizable words in a nonstandard way without warning;
- treating cross-domain resemblance as proof transfer.

## Rank-2 reminder

At rank 2, the finite core has coordinate records, polynomial maps, operators, and quadrance scalars. A circle is undefined at rank 2. Locus-like language belongs only to higher incidence or constraint layers with explicit genealogy and leaks.

## Linter contract

The repository linter checks for two classes of violations:

1. banned ungoverned phrases such as "obvious isomorphism", "canonical analogy", or "same as" without a declaration;
2. declared novel terms missing `Genealogy`, `Bridge claim`, `Known leaks`, or `Use discipline`.

The linter is intentionally conservative. It will not prove mathematical correctness. It enforces intellectual hygiene so the paper trail remains readable to mathematicians outside the project.

The companion regime-correspondence audit validates
`spec/regime_correspondences.toml` and its Mojo source tags. Each mapping has a
closed correspondence class, preserved and non-inherited structure, domain
conditions, evidence, proof status, and a proof boundary. Specification and
source bindings are checked in both directions.
