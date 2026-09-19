# Experiments

All experiments should be exact and finite.

## Initial experiment suite

1. Enumerate small finite groups and selected conjugacy-class tuples.
2. Filter raw product-one tuples.
3. Filter generating tuples.
4. Quotient by simultaneous conjugation.
5. Compute Hurwitz braid orbits.
6. Attach selected self-dual / orthogonal representations.
7. Compute trace-Gram matrices:
   [
   K_{ij}=operatorname{Tr}(ho(g_i)ho(g_j)^{-1}).
   ]
8. Census which functions of (K) survive braid moves.
9. For finite fields, classify target rank-one quadratic groups as split or nonsplit and record point counts and image sizes.

## Output discipline

Every computation should emit:
- base field;
- group identifier;
- conjugacy-class identifiers;
- representation identifier;
- tuple;
- braid generator applied;
- pre/post trace-Gram data;
- invariant comparison;
- exact replay seed if randomized search is used.
