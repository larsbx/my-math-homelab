# Oracles

Independent non-authoritative implementations for cross-checking canonical kernels.

`graph_snf.py` contains an exact small-matrix Smith-factor oracle based on
determinantal divisors, a separate tree-cycle bicycle enumerator, and
Cramer-based critical-group class coordinates. It imports no kernel code.
It is evidence for finite fixtures, not theorem authority.

`regular_snf.py` supplies a separate fixed-TU oracle. It uses the Bareiss
and all-minors Smith primitives, takes a different unit column basis from
the candidate, completes cycles with Cramer's rule, and tests their cut
condition. Quotient classes are enumerated from standard generators
independently of the theorem map. Literal potential enumeration handles
labeled non-TU controls. This module also imports no kernel code.
