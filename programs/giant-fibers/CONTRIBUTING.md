# Contributing to the research program

## Claim classes

Every mathematical claim added to the repository must be tagged in prose as one of:

- **classical** — standard theorem with a source;
- **literature** — theorem taken from an identified paper, with hypotheses stated;
- **proved here** — complete proof present in the repository;
- **conditional** — follows from explicitly named unclosed assumptions;
- **computational** — exact finite verification only;
- **conjectural/draft target** — not yet proved.

## Proof changes

A PR that promotes a claim to **proved here** should include:

1. a human-readable proof;
2. explicit characteristic and nondegeneracy hypotheses;
3. a dependency list;
4. exact regression tests when finite enumeration is practical;
5. no reliance on numerical approximation for an exact algebraic statement.

## Symmetry rule

If an argument changes coordinates, it must state which data are preserved.  In particular, projective orthogonal transitivity may not be used to justify an affine-chart count unless the chosen transformation preserves the chart/normalization or the effect is otherwise accounted for.

## Literature changes

Prefer primary papers and authoritative monographs/notes.  Record a URL and, where available, publication year and theorem number.  Surveys may orient the project but should not silently replace the primary source for a theorem used in a proof.
